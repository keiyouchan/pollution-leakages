global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $processed
* ----------------

use "$processed/firm_balanced.dta",replace

sort code year

* gen lead and lag
gen stock_in_lag = stock_in[_n-1] if code == code[_n-1]
gen stock_in_lead = stock_in[_n+1] if code == code[_n+1]


gen is_abnormal = (stock_in == 0) & ((stock_in_lag != 0 & !missing(stock_in_lag)) | (stock_in_lead != 0 & !missing(stock_in_lead)))

gen has_abnormal = 0
bysort code (year): replace has_abnormal = 1 if is_abnormal == 1
list code if has_abnormal == 1, sepby(code)
list code year stock_in stock_in_lag stock_in_lead is_abnormal if is_abnormal == 1 , sepby(code)






