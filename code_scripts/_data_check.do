global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

* cd $raw
/*
Note: 检查数据是否有误
	例如存在2013年和2015年有投资额，但是2014年投资额为0的异常情况 
*/
* -----------------
* use "./子公司主数据.dta",replace
bysort subfirm (year): gen stock_lag = stock_filled[_n-1]
bysort subfirm (year): gen stock_lead = stock_filled[_n+1]

replace stock_lag = round(stock_lag, 0.01)
replace stock_lead = round(stock_lead, 0.01)

gen is_abnormal = (stock == 0 | stock == . ) & ((stock_lag != 0 & stock_lag !=. ) & (stock_lead != 0 & stock_lead != .))

gen has_abnormal = 0
bysort subfirm (year): replace has_abnormal = 1 if is_abnormal == 1

/*
list subfirm if has_abnormal == 1, sepby(subfirm)
list subfirm year  stock_lag stock_lead if is_abnormal == 1 , sepby(subfirm) noobs

*/






