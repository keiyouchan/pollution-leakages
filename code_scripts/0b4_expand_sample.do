global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $processed

clear 
***********************
/* extend sample */

* - subfirm list
use subfirm code capi setup_year using "$interm/subfirm_stock_filled_missing.dta" , clear
duplicates drop subfirm code,force
tempfile subfirm_code_list
save `subfirm_code_list', replace

* - year range
clear
set obs 8
gen year = 2010 + _n - 1
tempfile year_range
save `year_range' , replace

use `subfirm_code_list', clear
cross using `year_range'
sort subfirm year


* - merge
merge 1:1 subfirm code year using "$interm/subfirm_stock_filled_missing.dta" , ///
		  keepusing(stock netinc inc) keep(1 3) nogen
drop if setup_year > year
tempfile temp
save `temp', replace



* - merge basic info
local varlist subfirm code* year ipoyear in_key_dummy treatment taxid sub_cityname 
use  `varlist' using "$raw/main.dta",replace

/*
rename (被投资单位 证券代码 异地同行投资 上市年份 三区十群内的异地投资 处理组 纳税人识别号 所属城市 ) ///
	   (subfirm code migrate_dummy ipoyear in_key_dummy treatment taxid cityname)
*/

bys subfirm code : fillmissing in_key_dummy treatment taxid, with(any)
duplicates drop subfirm code in_key_dummy treatment taxid,force
tempfile basic_info
save `basic_info', replace


use `temp',clear
merge m:1 subfirm code using `basic_info' , keep(1 3) nogen
order subfirm code year stock netinc inc in_key_dummy * 
sort  subfirm code year




* 找出仍在经营的子公司
/* delete cancelled subfirm */
	 merge m:1 code subfirm  using "$interm/logout_subfirm.dta" , keep(1 3) nogen
	 gen out = 1 if year >= outyear
	 gen active = (out != 1)
	 sort code subfirm year
	 * drop if stock == .

*/ 


*=========================== 再次填充缺失值: 考虑是否必要 ============================*

/* 填充缺失 */
gen stock_filled = stock

* -先用当前总额减去当期变动，得到上一期的总额，然后使用向后填充
bysort subfirm code (year) : replace stock_filled = stock_filled[_n + 1] - netinc[_n + 1] if mi(stock_filled) & (!missing(stock_filled[_n + 1]) & !missing(netinc[_n + 1]))
bysort subfirm code (year) : fillmissing stock_filled, with(next)
bysort subfirm code (year) : fillmissing stock_filled, with(previous)
replace stock = stock_filled 


*=========================== 微调数据 ============================*

/* Fine-tune */

* fineTune, s(2) yr(2014)

	/* recalculate netince & inc 
	bysort subfirm code (year) : replace netinc = stock[_n] - stock[_n - 1] if (stock[_n] !=. & stock[_n - 1] !=. )
	bysort subfirm code (year) : replace inc =    stock[_n] - stock[_n - 1] if (stock[_n] !=. & stock[_n - 1] !=. )
	bysort subfirm code (year) : replace inc = 0 if inc < 0 & !missing(inc)
	*/


drop if missing(stock_filled)
drop stock_filled
replace stock = 0 if stock < 0


foreach var of varlist _all {
		cap format `var' %15s
}



* 匹配子公司设立类型
merge 1:1 code subfirm year using "$raw/subfirm_info.dta", keep(1 3) nogen

bys code subfirm (year): fillmissing esttype, with(next)
bys code subfirm (year): fillmissing esttype, with(previous)


*drop if ipoyear > 2010
replace esttype = trim(esttype)
replace stock = round(stock, 0.02)
drop if esttype == "非同一控制下合并" & stock == 0 & (mi(netinc) | netinc == 0)
drop if esttype == "同一控制下合并" & stock == 0 & (netinc ==. | netinc == 0)
drop if esttype == "None" & stock == 0 & (netinc ==. | netinc == 0)


*** 排除已经注销但还存在数据中
bys code subfirm (year): egen exit_year = min(cond(netinc < 0 & stock == 0, year, .))
drop if exit_year < . & year > exit_year

*** 排除未进入年报的年份
list code subfirm year stock netinc if subfirm == "大唐华银欣正锡林郭勒风力发电有限责任公司", noobs
bys code subfirm (year): egen entry_year = min(cond(stock > 0 & stock == netinc, year, .))
drop if entry_year < . & year < entry_year

*** 把全为0的公司删除
list code subfirm year stock netinc if subfirm == "云南国电电力富民风电开发有限公司", noobs
bys code subfirm: egen max_stock = max(stock)
drop if max_stock < 1e-2



save "$interm/subfirm_stock_expanded.dta",replace
use  "$interm/subfirm_stock_expanded.dta",clear



***EOF


