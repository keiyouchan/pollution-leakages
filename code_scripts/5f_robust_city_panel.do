global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline   "$output/baseline"
		global robust     "$output/robustness"

cd $processed
* *******************************
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out"
	* HDFE model
	global hdfe       "cityid pairid year provid#year receid#year"
	global hdfe_dummy "cityid pairid year provid#year receid#year $citycorr"
	global clusters   "cityid"


* -------------------------
/* assuming our subfirm data is correctly set */
use prt_cityname sub_cityname using "$raw/main.dta",clear
drop if sub_cityname == "-"
drop if prt_cityname == "-"

/* create polluter-receiver pair */
preserve
keep prt_cityname
duplicates drop prt_cityname, force
rename prt_cityname polluter
tempfile polluter
save `polluter' , replace
restore


preserve
keep sub_cityname
duplicates drop sub_cityname, force
rename sub_cityname receiver
tempfile receiver
save `receiver' , replace
restore


clear
set obs 8
gen year = _n
replace year = _n + 2010 - 1
tempfile year
save `year' , replace

use `polluter'  , clear
cross using `receiver'
cross using `year'

sort polluter receiver year
tempfile citypanel
save `citypanel' , replace

* --------------------------------------
/* aggreagate investment in city level */
use "$raw/main.dta",clear
drop if prt_cityname == ""
drop if sub_cityname == ""
* --------
preserve 
	* rename in_key_dummy treatment
	rename prt_cityname polluter
	keep polluter treatment
	duplicates drop polluter treatment, force
	tempfile treat
	save `treat' , replace
restore

preserve 
	rename sub_cityname receiver
	keep receiver in_key_dummy
	duplicates drop receiver in_key_dummy, force
	tempfile key_dummy
	save `key_dummy' , replace
restore

rename (prt_cityname sub_cityname) (polluter receiver)
keep            subfirm code polluter receiver
duplicates drop subfirm code polluter receiver , force
tempfile location
save    `location', replace


* ---------
use  "$interm/subfirm_stock_expanded.dta",replace
merge m:1 subfirm code using `location' , keep(1 3) nogen
sort  polluter receiver year
order polluter receiver year


local outcome stock netinc inc
foreach y in `outcome'{
		egen `y'_out = sum(`y') , by(polluter receiver year)
}
egen  firmnum_out = sum(active) , by(polluter receiver year)
collapse (first) stock_out netinc_out inc_out firmnum_out , by(polluter receiver year)
tempfile investment
save    `investment'

merge 1:m polluter receiver year using `citypanel' , keep(2 3) nogen
sort  polluter receiver year

foreach y in stock_out netinc_out inc_out firmnum_out {
		replace `y' = 0 if `y' == .
}

*- merge treatment & in key dummy
merge m:1 polluter using `treat'     , keep(1 3) nogen 
merge m:1 receiver using `key_dummy' , keep(1 3) nogen 
foreach dummy in treatment in_key_dummy {
		replace `dummy' = 0 if missing(`dummy')
}


/* merge pre-determined variables */
rename polluter cityname 
merge  m:1 cityname      using "$interm/city_correlates_processed.dta", keep(1 3) nogen
merge  m:1 cityname year using "$interm/pollutants.dta"               , keep(1 3) nogen
sort   cityname receiver year
bys    cityname (year) : replace SO2 = SO2[1]
drop if popdensity == .
drop if SO2 == .

* 地级市特征pre-treat var
local cityChar "indusoutput"
foreach chr in `cityChar' {
		rename `chr' city_char_`chr'
}

* 地级市污染物pre-treat var
local pltnChar "SO2 PM25"
foreach chr in `pltnChar' {
		rename `chr' pltn_char_`chr'
}

tempfile temp1
save    `temp1' , replace



/* propensity matching */
*global citycorr "SO2 PM25 PM10 O3 NO2 popdensity gdpcapita indusoutput finrev finexp"
use    cityname treatment receiver year city_char_* pltn_char* if year == 2010 using `temp1' , clear
keep   cityname treatment city_char_* pltn_char*
duplicates drop cityname , force

psmatch2 treatment city_char_* pltn_char*, logit neighbor(3) ties caliper(0.05) common
drop if _weight == . 

* mean-diff
ttable2 city_char_* , by(treatment) 


keep  cityname city_char_* pltn_char_* _pscore _treated _support _weight _id _n1 _nn _pdif
merge 1:m cityname using `temp1' , keep(3) nogen
sort  cityname receiver year
order cityname receiver year


/* prepare for regression */
	gen    pair = cityname + "_" + receiver
	encode pair , gen(pairid)
	encode receiver , gen(receid)

	* static diff-in-diffs
	gen post = year >= 2014
	gen policy = treatment * (year>=2014)

	* event study indicators
	gen nevertreated = (treatment == 0)
	gen policy_year = 2014
	gen K = year - policy_year

	forvalues l = 0/3 {
		gen L`l' = treatment * (K == `l')
	}
	forvalues l = 1/4 {
		gen F`l' = treatment * (K == -`l')
	}

	/* transform variables */

	* - winsorization
	local outcomes "stock_out firmnum_out"
	foreach outcome in `outcomes' {
			winsor2 `outcome', cut(1,99) replace
	}
	replace stock_out = stock_out / 10


	save "$processed/city_panel.dta" , replace
* -----------------------------
foreach y in stock_out {

	est clear
	local index = 1

			reghdfe `y' policy c.(pltn_char_*)#c.year#c.year#c.year, a($hdfe) vce(cluster pairid)
			est sto c1
			reghdfe `y' policy c.(pltn_char_*)#c.post, a($hdfe) vce(cluster pairid)
			est sto c2
			reghdfe `y' policy, a($hdfe c.(pltn_char_*)#year) vce(cluster pairid)
			est sto c3

			* output
			esttab c1 c2 c3 ,  ///
			///using "$robust/citypanel_`Y'.csv", ///
			b(3) se(3) ar2(3) ///
			keep(policy) order(policy) ///
			r2 star(* 0.1 ** 0.05 *** 0.01)  ///
			compress nogaps replace

			* export to file
			esttab c1 c2 c3 using "$robust/citypanel_`y'.csv", ///
			b(3) se(3) ar2(3) ///
			keep(policy) order(policy) ///
			star(* 0.1 ** 0.05 *** 0.01)  ///
			compress nogaps replace
}





*** End of file



