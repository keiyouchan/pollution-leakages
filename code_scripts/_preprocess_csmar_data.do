global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

* -----------------
/* 仅保留csmar中的年终数据 */
use "csmar_subfirm.dta",clear

* drop duplicates while keeping last one
sort subfirm year date
gen tag = subfirm != subfirm[_n+1] | year != year[_n+1]
keep if tag == 1
drop tag

replace stock = stock / 10000 if !missing(stock)
save "$interm/csmar_subfirm_dropdup.dta",replace

***EOF





















