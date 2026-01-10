global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm

/* 在用CSMAR的期末投资额替换了原数据的投资额之后，对一些缺失值进行处理和填充 */


*****************************************************
* select


/*
keep   被投资单位 year 上市年份 处理组 纳税人识别号 linked_inv out_inv inv_leak 三区十群内的异地投资
rename 被投资单位 subfirm  
rename 上市年份 ipoyear
rename 三区十群内的异地投资 in_key_dummy
rename 处理组 treatment
rename 纳税人识别号 taxid

tempfile select_criteria
save `select_criteria',replace
*/




* merge to CSMAR
/*
use "$interm/subfirm_revised_stock.dta",clear
merge 1:1 subfirm year using `select_criteria', keep(3) nogen
*/
drop if setup_year > year & !missing(setup_year)
drop ipoyear
drop linked_inv



/*
*====== 手动填充缺失数据 ======*

*- mannual append missing year
tempfile supplement
run  "$scripts/0b2_preprocess_fill_missing_year.do"
save `supplement',replace

use `temp', clear
append using `supplement'
sort code subfirm year

*— mannual revise missing or abnormal data
run "$scripts/0b3_preprocess_mannual_revise.do"
*/


*=============================== 处理重名问题 ===============================*
drop if taxid == ""


* 统一子公司名称 (如果一个taxid对应多个subfirm)
bys taxid subfirm: gen tag = (_n==1)
bys taxid: egen n_names = total(tag)
drop tag
gen changed_name = n_names > 1
bys taxid (year): replace subfirm = subfirm[_N]   // 统一名称



* 统一子公司名称后，每个名称对应两个年份，去掉缺失值的那个年份以及去掉重复值
bys taxid year : gen n_year = _N                 // 是否重复年份
drop if stock == . & n_year > 1
duplicates drop code subfirm year stock, force 
duplicates drop code subfirm year,force
drop n_year

check_dup_year



* ****************************************** *
* -------------- Fill Missing -------------- *
* ****************************************** *


*- ready to fill missing value
gen     stock_filled = stock
order   subfirm code year stock netinc *
gen     stock_backup = stock 


*========================= 使用netinc 补充 ==========================*

replace stock = netinc if (netinc > 0) & (stock == . | stock == 0)

*========================= Forward Imputation =========================*



local  delta = 1
while `delta' != 0 {


		qui: count if stock == .
		qui: local before = `r(N)'

		* - step1: 标记完整观测值, 即存量和增量都有值
		bys subfirm (year): gen normal = (stock !=.) & (netinc !=.)


		* - step2: 用下一期正常观测值倒推当期的期末存量
		bys subfirm (year): replace stock = stock[_n + 1] - netinc[_n + 1] if stock ==. 
		drop normal

		qui: count if stock == .
		qui: local after = `r(N)'

		local delta = `after' - `before'
}





*========================= Backward Imputation =========================*



local  delta = 1
while `delta' != 0 {


		qui: count if stock == .
		qui: local before = `r(N)'

		* - step1: 标记完整观测值, 即存量和增量都有值
		bys subfirm (year): gen normal = (stock !=.) & (netinc !=.)


		* - step2: 用上一期存量和这一期的增量，去推测这一期的存量
		bys subfirm (year): replace stock = stock[_n - 1] + netinc if stock ==. 
		drop normal

		qui: count if stock == .
		qui: local after = `r(N)'

		local delta = `after' - `before'
}







*=========================== Impute Singleton ==========================*


bys subfirm (year) : replace stock = netinc if _n == _N & stock == . & netinc > 0
bys subfirm (year) : replace stock = 0      if _n == _N & stock == . & netinc <= 0
replace stock = 0 if stock == .






*========================= 解决中间0 两头非0 的情况 =====================*

bys subfirm (year): gen stock_lag = stock[_n - 1]
bys subfirm (year): gen stock_lead = stock[_n + 1]
replace stock = stock_lead if (stock == . | stock <= 1e-3) & (stock_lead * stock_lag != 0) & (!missing(stock_lead) & !missing(stock_lag))




/*

*- 标记缺失值填充来源
gen fill_method1 = 0
gen fill_method2 = 0 
gen fill_method3 = 0 
gen fill_method4 = 0 
gen fill_method5 = 0 
gen fill_method6 = 0 
gen fill_method7 = 0 
gen fill_method8 = 0
gen fill_method9 = 0  

*- fill method 1 : 例如2012和2014投资不为0，而2013投资为0或者为缺失值的情况，如果2014年之后，则向后取值
run "$scripts/_data_check.do"

sort subfirm year
local delta 1
while `delta' != 0 {
	qui : count if stock_filled == .
	qui : local before `r(N)'

	bysort subfirm (year): replace fill_method1 = 1 ///
		if (stock_filled == 0 | stock_filled == .) & year < 2014 & stock[_n-1] != . & is_abnormal == 1
	bysort subfirm (year): replace stock_filled = stock_filled[_n-1] ///
		if (stock_filled == 0 | stock_filled == .) & year < 2014 & stock[_n-1] != . & is_abnormal == 1

	bysort subfirm (year): replace fill_method1 = 1 ///
		if (stock_filled == 0 | stock_filled == .) & year >= 2014 & stock[_n+1] != . & is_abnormal == 1
	bysort subfirm (year): replace stock_filled = stock_filled[_n+1] ///
		if (stock_filled == 0 | stock_filled == .) & year >= 2014 & stock[_n+1] != . & is_abnormal == 1

	qui : count if stock_filled == .
	qui : local after `r(N)'
	local delta `before' - `after'
}
drop is_abnormal has_abnormal stock_lag stock_lead

*/
/**************************************************************
*- fill method 2 : 如果当期减少等于上一期的存量，那么当期存量为0
bysort subfirm (year): gen lag_stock = stock_filled[_n-1]
replace lag_stock = round(lag_stock, 0.01) // 2 decimal
replace netinc = round(netinc, 0.01)

replace fill_method2 = 1 if stock_filled ==. & (lag_stock == - netinc)
replace stock_filled = 0 if stock_filled ==. & (lag_stock == - netinc)
drop lag_stock

*/

/******************************************************************
*- fill method3 : 如果2016是0，2017是缺失值，且本期增加为0，则2017也为0
sort subfirm year 
bysort subfirm (year) : replace fill_method3 = 1 if stock_filled == . & (stock_filled[_n - 1] == 0) & (netinc == 0)
bysort subfirm (year) : replace stock_filled = 0 if stock_filled == . & (stock_filled[_n - 1] == 0) & (netinc == 0)

*/




/******************************************************************
*- fill method4 : 循环多次以处理连续缺失--利用后一期的stock和netinc倒推法
sort subfirm year
local delta 1
while `delta' != 0 {
	count if missing(stock_filled)
	local before `r(N)'

	bysort subfirm (year): replace fill_method4 = 1 ///
		if missing(stock_filled) & !missing(stock_filled[_n+1]) & !missing(netinc[_n+1])

    bysort subfirm (year): replace stock_filled = stock_filled[_n+1] - netinc[_n+1] ///
    	if missing(stock_filled) & !missing(stock_filled[_n+1]) & !missing(netinc[_n+1])
    
    count if missing(stock_filled)
    local after `r(N)'
    local delta `before' - `after'
}
*/




/******************************************************************
*- fill method5 : 循环多次以处理连续缺失: 利用前一期的不为0的stock和当期不为0的netinc顺推
sort subfirm year
local delta 1
while `delta' != 0 {
	count if missing(stock_filled)
	local before `r(N)'

    bysort subfirm (year): replace fill_method5 = 1 ///
    	if missing(stock_filled) & !missing(stock_filled[_n - 1]) & !missing(netinc[_n])

    bysort subfirm (year): replace stock_filled = stock_filled[_n - 1] + netinc[_n] ///
    	if missing(stock_filled) & !missing(stock_filled[_n - 1]) & !missing(netinc[_n])
    count if missing(stock_filled)
    local after `r(N)'
    local delta `before' - `after'
}
*/




/*****************************************************************
* fill method6: 如果年份等于创立年份,则用capi（注册资本填充）
replace fill_method6 = 1 ///
	if (stock_filled == .) & (year == setup_year) & setup_year !=.
replace stock_filled = capi ///
	if (stock_filled == .) & (year == setup_year) & setup_year !=.
*/






/******************************************************************
* fill method7: 对于所有年份都缺失投资数据的公司
	* 如果所有年份中，增减变动都为0，那么直接用注册资本进行缺失值补充
	bysort subfirm (year): egen    sum_stock      = sum(stock_filled) if stock_filled != .
	bysort subfirm (year): egen    sum_netinc     = sum(netinc)       if netinc != .
	bysort subfirm (year): gen     normal_missing = 0
	bysort subfirm (year): replace normal_missing = 1 if sum_stock == . & sum_netinc == 0
	replace capi = capi * 10 if     !(in_key_dummy == 0 & treatment == 1)
	replace fill_method7 = 1    ///
		if normal_missing == 1 & capi != . & !(in_key_dummy == 0 & treatment == 1 )
	replace stock_filled = capi ///
		if normal_missing == 1 & capi != . & !(in_key_dummy == 0 & treatment == 1 )
	drop sum_stock sum_netinc normal_missing

*/





/*******************************************************************
* fill method8 : using netinc
	* 使用netinc填充需要注意两个问题：
	* 1. 如果缺失值后一年无数据，且当年的netinc为负，大概率说明当年减少所有投资，因此设置为0，且将后续的年份设置为0
	* 2. 首先如果缺失值的后一年有数据，则当年的缺失值用后一年的stock - netinc填充

	bysort subfirm (year) : replace fill_method8 = 1 ///
		if stock_filled[_n + 1] == . & netinc < 0 //

	bysort subfirm (year) : replace stock_filled = 0 ///
	if stock_filled[_n + 1] == . & netinc < 0 // 


	sort  subfirm year
	local delta 1
	while `delta' != 0 {
		qui: count if missing(stock_filled)
		qui: local before `r(N)'

		bysort subfirm (year) : replace fill_method9 = 1 ///
			if (stock_filled == .) & (stock_filled[_n + 1] != . & netinc[_n + 1] != .) 

		bysort subfirm (year) : replace stock_filled = stock_filled[_n + 1] - netinc[_n + 1] ///
			if (stock_filled == .) & (stock_filled[_n + 1] != . & netinc[_n + 1] != .) 
		
		qui: count if missing(stock_filled)
	    qui: local after `r(N)'
	    local delta `before' - `after'
	}

*/







**********************************************
************ End of fill missing *************
**********************************************




/* recalculate netince & inc */
bysort subfirm (year) : replace netinc = stock[_n] - stock[_n - 1] if (stock[_n] !=. & stock[_n - 1] !=. )
bysort subfirm (year) : replace inc    = stock[_n] - stock[_n - 1] if (stock[_n] !=. & stock[_n - 1] !=. )
bysort subfirm (year) : replace inc    = 0 if inc < 0 & !missing(inc)



/* mannual revise missing data again */
* run "$scripts/0b3_preprocess_mannual_revise.do"


* check missing or abnormal values
sort   code subfirm year
count if missing(stock)
dis "期末投资额一共有`r(N)'条缺失值"
sort   code subfirm year
replace stock = 0 if stock < 0 
save "$interm/subfirm_stock_filled_missing.dta",replace

/*
use  "$interm/subfirm_stock_filled_missing.dta",clear
list code subfirm stock if stock < 0
count if stock < 0
*
/
*** EOF

