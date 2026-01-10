
global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm
* -----------------
use "$interm/subfirm_stock_filled_missing.dta",clear
keep code
duplicates drop code, force
gen random = runiform()
sort random
gen selected = _n <= 10
keep if selected == 1
drop random selected

merge 1:m code using "$interm/subfirm_stock_filled_missing.dta", keep(3) nogen 
sort code subfirm year


