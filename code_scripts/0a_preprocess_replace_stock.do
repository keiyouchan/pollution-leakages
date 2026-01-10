global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
/*
将期末投资额删除，用csmar的期末投资额来补充缺失的期末投资额
并merge上成立时间，看看如果缺失值设置为0是否合理
*/

* -----------------
use "./子公司主数据.dta",replace
sort 被投资单位 year
keep 被投资单位 证券代码 year 期末余额 增减变动 本期增加
rename (被投资单位 证券代码 期末余额 增减变动 本期增加) (subfirm code stock netinc inc)

* count 0 value of stock before matching *
count if stock == 0

* count 0 value of stock after matching *
replace stock =. // if stock == 0 //
merge 1:1 subfirm year using "$interm/csmar_subfirm_dropdup.dta" , keepusing(stock) update sorted
drop if _merge == 2
drop _merge
count if stock == .  // 26,796



* match setup time
merge m:1 code subfirm using "$interm/subfirm_corr.dta" , keepusing(setup setup_year relation capi currency) 
drop if _merge == 2
drop _merge
sort subfirm year

foreach i of varlist _all{
	cap format `i' %10s
	cap format `i' %9.2f
}

save "$interm/subfirm_revised_stock.dta",replace


***EOF