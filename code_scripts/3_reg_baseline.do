global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline "$output/baseline"
		global eventstudy "$output/eventstudy"	

cd $processed
*****************************************
global outcomes "stock_out netinc_out inc_out firmnum_out uniinv"
global twfe "code year"
global hdfe "code year provid#year indusid#year"


use "$processed/firm_reg_balance.dta", clear


cap program drop reg_base
program reg_base
		version 18
		syntax varlist [, saving(string)]



		foreach y in `varlist' {

				qui {
					est clear

					reghdfe `y' policy, a($twfe) vce(cluster citycode)
					est sto c1
					reghdfe `y' policy, a($hdfe) vce(cluster citycode)
					est sto c2
					reghdfe `y' policy c.(pltn_char_*)#c.year#c.year#c.year, a($hdfe) vce(cluster citycode)
					est sto c3
					reghdfe `y' policy c.(pltn_char_*)#c.post, a($hdfe) vce(cluster citycode)
					est sto c4
					reghdfe `y' policy, a($hdfe c.(pltn_char_*)#year) vce(cluster citycode)
					est sto c5
				}


				* display output
				if "`saving'" != "" {

					esttab c1 c2 c3 c4 c5 ///
						   using "`saving'", ///
						   b(3) se(3) ar2(3) ///
						   keep(policy) order(policy) ///
						   star(* 0.1 ** 0.05 *** 0.01) ///
						   compress nogaps replace 
						   
				}


				esttab c1 c2 c3 c4 c5, ///
					   b(3) se(3) ar2(3) ///
					   keep(policy) order(policy) ///
					   star(* 0.1 ** 0.05 *** 0.01) ///
					   compress nogaps replace 
					   

		}

end 

* reg_base stock_out uniinv





*======================== Robustness Specification ==========================*

cap program drop reg_rbs_spec
	program reg_rbs_spec
			version 18
			syntax varlist, spec(string) [clst(varlist) cond(string)]
			local y `varlist'

			/* 标准误聚类层级默认值 */
			if "`clst'" == "" {
				local clst citycode
			}

			if "`cond'" == "" {
				local cond = 1
			}


			if "`spec'" == "twfe" {

				reghdfe `y' policy if `cond', a($twfe) vce(cluster `clst') noconstant
				est sto `y'
			}

			if "`spec'" == "hdfe" {

				reghdfe `y' policy if `cond', a($hdfe) vce(cluster `clst') noconstant
				est sto `y'
			}


			if "`spec'" == "poly" {

				reghdfe `y' policy c.(pltn_char_*)#c.year#c.year#c.year if `cond', a($hdfe) vce(cluster `clst') noconstant
				est sto `y'
			}

			if "`spec'" == "post" {

				reghdfe `y' policy c.(pltn_char_*)#c.post if `cond', a($hdfe) vce(cluster `clst') noconstant
				est sto `y'
			}

			if "`spec'" == "flex" {
				
				reghdfe `y' policy if `cond', a($hdfe c.(pltn_char_*)#year) vce(cluster `clst') noconstant
				est sto `y'
			}


			* display output
			esttab `y',  /// 
				   b(3) se(3) ar2(3) ///
				   keep(policy) order(policy) ///
				   star(* 0.1 ** 0.05 *** 0.01) ///
				   compress nogaps replace

			if "`save'" != "" {

				esttab `y' using "`save'", ///
				   b(3) se(3) ar2(3) ///
				   keep(policy) order(policy) ///
				   star(* 0.1 ** 0.05 *** 0.01) ///
				   compress nogaps replace
			}

end 

*reghdfe stock_out policy, a($hdfe c.(firm_char_*)#year c.(city_char_*)#year) vce(cluster code provcode) noconstant
* reg_rbs_spec lnpvar_totrev, spec(twfe) clst(citycode)

*================== Event-Study ==================*

cap program drop reg_esplot  
program reg_esplot
			version 18 
			syntax varlist, [save(string) cond(string) name(string)]


			if "`cond'" == "" {
				local cond = 1
			}

			if "`name'" == "" {
				local name "para_assumption_test"
			}

			/* event-study regression */
			qui : reghdfe `varlist' F1-F4 L0-L3 if `cond', a($hdfe c.(pltn_char_*)#year)  vce(cluster citycode) noconstant
			est sto es



			/* plot all stored estimates together */
			coefplot es , omitted base ///
					 keep(F4 F3 F2 F1 L*) ///
					 order(F4 F3 F2 F1 L*) ///
			 		 noeqlabels ///
					 vertical ///
					 levels(90) ///
					 recast(scatter) ///
					 ciopts(lpattern(dash) recast(rcap) msize(medium) color(gs8)) ///CI为虚线上下封口
					 msymbol(Circle) ///
					 msize(*1.2) color(navy) ///
			 		 mlabel(cond(@pval<.01,  "***", cond(@pval<.05, "**", cond(@pval<.1, "*", "")))) ///
					 xlabel(1 "-4" 2 "-3" 3 "-2" 4 "-1" 5 "0" 6 "1" 7 "2" 8 "3" , nogrid) ///
					 ylabel(, nogrid) ///
					 xline(4 , lp(solid) lcolor(navy)) ///
					 yline(0, lp(solid) lc(red) lw(thin))                ///
					 legend(order(1 "90% Confidence Interval" 2 "Esitmates") size(small) pos(6) row(1))     ///
					 ytitle("Coefficient") ///
					 xtitle("Period") ///
					 scheme(s1color)                   ///
					 graphregion(color(white)) bgcolor(white) ///
					 plotregion(lcolor("white") lwidth(*0.9)) ///
					 name("`varlist'_`name'",replace)



			/* save the plot */
	        if ("`save'"!="") {

                di as txt "Saving graph to: `save'"
                graph export "`save'", replace
        	}


end 

* reg_esplot uniinv

