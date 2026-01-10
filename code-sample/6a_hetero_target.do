global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline   "$output/baseline"
		global robust     "$output/robust"
		global hetero     "$output/hetero"
		global eventstudy "$output/eventstudy"	

cd $processed
*******************************************
* outcome variables
global outcomes "stock_out"
	* HDFE model
	global hdfe       "code year provid#year indusid#year"
	global clusters   "cityid"

* --------------------
run "$scripts/_city_target.do"
tempfile target
save `target' , replace 
* -------------


/* interact with restraint target */
use "firm_reg_balance.dta", clear
gen policy3 = in_3regions * post
gen policy10 = in_10clusters * post

foreach y in $outcomes {

	est clear
	local index = 1

			reghdfe `y' policy3 policy10 c.(pltn_char_*)#c.year#c.year#c.year, a($hdfe) vce(cluster code)
		    est sto c1

		    scalar diff_c1 = _b[policy3] - _b[policy10]
		    test _b[policy3] - _b[policy10] = 0
		    scalar pval_c1 = r(p)

		    reghdfe `y' policy3 policy10 c.(pltn_char_*)#c.post, a($hdfe) vce(cluster code)
		    est sto c2

		    scalar diff_c2 = _b[policy3] - _b[policy10]
		    test _b[policy3] - _b[policy10] = 0
		    scalar pval_c2 = r(p)

			reghdfe `y' policy3 policy10, a($hdfe c.(pltn_char_*)#year) vce(cluster code)
		    est sto c3

		    scalar diff_c3 = _b[policy3] - _b[policy10]
		    test _b[policy3] - _b[policy10] = 0
		    scalar pval_c3 = r(p)


		    * adding stars
		    local stars_c1 ""
		    local stars_c2 ""
		    local stars_c3 ""

		    if pval_c1 < 0.01 local stars_c1 "***"
		    else if pval_c1 < 0.05 local stars_c1 "**"
		    else if pval_c1 < 0.10 local stars_c1 "*"

		    if pval_c2 < 0.01 local stars_c2 "***"
		    else if pval_c2 < 0.05 local stars_c2 "**"
		    else if pval_c2 < 0.10 local stars_c2 "*"

		    if pval_c3 < 0.01 local stars_c3 "***"
		    else if pval_c3 < 0.05 local stars_c3 "**"
		    else if pval_c3 < 0.10 local stars_c3 "*"

		    * 格式化输出
		    local diff1_str : display %9.3f diff_c1 `stars3'
		    local diff2_str : display %9.3f diff_c2 `stars4'
		    local diff3_str : display %9.3f diff_c3 `stars5'
		    local pval_c1 : display %9.3f pval_c1
		    local pval_c2 : display %9.3f pval_c2
		    local pval_c3 : display %9.3f pval_c3

			* output
			esttab c1 c2 c3, ///
				b(3) se(3) ar2(3) ///
				keep(policy3 policy10) ///
				order(policy3 policy10) ///
				addnotes("Difference, `diff1_str', `diff2_str', `diff3_str'"  ///
						 "P-value, `pval_c1', `pval_c2', `pval_c3'" ) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				compress nogaps replace

			* export to file 
			esttab c1 c2 c3 using "$hetero/target_`Y'.csv", ///
				b(3) se(3) ar2(3) ///
				keep(policy3 policy10) ///
				order(policy3 policy10) ///
				addnotes("Difference, `diff1_str', `diff2_str', `diff3_str'"  ///
						 "P-value, `pval_c1', `pval_c2', `pval_c3'" ) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				compress nogaps replace
			
}

*** 计算经济显著性
reghdfe stock_out policy3 policy10, a($hdfe c.(pltn_char_*)#year) vce(cluster citycode)
local b_t1 = _b[policy3]
local b_t2 = _b[policy10]

summ  pf_totast if year <= 2013 & in_3regions == 1
local mean_t1 = r(mean) / 100

summ  pf_totast if year <= 2013 & in_10clusters == 1
local mean_t2 = r(mean) / 100

local es_t1 = (`b_t1' / `mean_t1') * 100
local es_t2 = (`b_t2' / `mean_t2') * 100

di "三区的经济显著性为:" %6.2f `es_t1' "%"
di "十群的经济显著性为:" %6.2f `es_t2' "%"


