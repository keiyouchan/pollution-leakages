global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline   "$output/baseline"
		global robust     "$output/robust"
		global eventstudy "$output/eventstudy"	

cd $processed
* ------------------------
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out"
	* HDFE model
	global hdfe       "code year provid#year indusid#year"
	global hdfe_dummy "code year provid#year indusid#year $citycorr"
	global clusters   "cityid"

* ----------------

* use    "firm_reg_balance.dta", clear

cap program drop reg_rbs_anticip
program reg_rbs_anticip
		version 18
		syntax, yrlead(int)



		local shock_year = 2013
		local placebo_year = `shock_year' - `yrlead'



		/* 1 year advance */
		preserve 

			/* keep obs before the shock */
			keep if year <= `shock_year'

			/* generate counterfactual did */
			cap drop policy
			cap drop post
			gen  policy = treatment * (year >= `placebo_year')
			gen  post = (year >= `placebo_year')


			reghdfe stock_out policy, a($hdfe c.(pltn_char_*)#year) vce(cluster code)
			est sto ret

			esttab ret,  /// using "$baseline/basline_`Y'.csv", ///
		    b(3) se(3) ar2(3) ///
		    keep(policy) order(policy) ///
		    star(* 0.1 ** 0.05 *** 0.01) replace

		restore
end 

* reg_rbs_anticip, yrlead(1)

*======================= Sep. line ====================*

/*
foreach Y in $outcomes {

	est clear

		    reghdfe `Y' policy $model1 , a($hdfe) vce(cluster $clusters)
		    est sto model1
		    reghdfe `Y' policy $model2 , a($hdfe) vce(cluster $clusters)
		    est sto model2
		    reghdfe `Y' policy $model3 , a($hdfe) vce(cluster $clusters)
		    est sto model3
		    reghdfe `Y' policy $model4 , a($hdfe) vce(cluster $clusters)
		    est sto model4
			reghdfe `Y' policy , a($hdfe_dummy)   vce(cluster $clusters)
			est sto model5

			* output
			esttab model1 model2 model3 model4 model5  ///
				using "$robust/anticipation1_`Y'.csv", ///
				b(4) se(4) ///
				keep(policy) order(policy) ///
				r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
}


/* 2 year advance */
drop policy post
gen  policy = treatment * (year >= 2012)
gen  post   = year >= 2012

* outcome :  (common support)
foreach Y in $outcomes {

	est clear
	local index = 1

		    reghdfe `Y' policy $model1 , a($hdfe) vce(cluster $clusters)
		    est sto model1
		    reghdfe `Y' policy $model2 , a($hdfe) vce(cluster $clusters)
		    est sto model2
		    reghdfe `Y' policy $model3 , a($hdfe) vce(cluster $clusters)
		    est sto model3
		    reghdfe `Y' policy $model4 , a($hdfe) vce(cluster $clusters)
		    est sto model4
			reghdfe `Y' policy , a($hdfe_dummy)   vce(cluster $clusters)
			est sto model5

			* output
			esttab model1 model2 model3 model4 model5  ///
			using "$robust/anticipation2_`Y'.csv", ///
			b(4) se(4) ///
			keep(policy) order(policy) ///
			r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
}
*/
*** End of file

