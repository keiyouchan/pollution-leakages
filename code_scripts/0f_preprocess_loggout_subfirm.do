global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
* ----------------------
use "$raw/logout_subfirm.dta", clear

* gen out year
rename outyear outdate
gen    double outdate_num = date(outdate, "YMD")
format outdate_num %td
gen    outyear = year(outdate_num)
drop if outyear == .
drop dup endyear setup outdate outdate_num

*
bys code subfirm (outyear): gen dup = _n == _N
drop if dup == 0
drop dup

save "$interm/logout_subfirm.dta",replace


