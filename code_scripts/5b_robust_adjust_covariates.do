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
	global clusters   "code"

* -----------------------
global cityl    "c.SO2#c.year               c.PM25#c.year               c.PM10#c.year               c.O3#c.year               c.NO2#c.year               c.popdensity#c.year               c.gdpcapita#c.year               c.indusoutput#c.year               c.finrev#c.year               c.finexp#c.year"
global cityq    "c.SO2#c.year#c.year        c.PM25#c.year#c.year        c.PM10#c.year#c.year        c.O3#c.year#c.year        c.NO2#c.year#c.year        c.popdensity#c.year#c.year        c.gdpcapita#c.year#c.year        c.indusoutput#c.year#c.year        c.finrev#c.year#c.year        c.finexp#c.year#c.year"
global citypoly "c.SO2#c.year#c.year#c.year c.PM25#c.year#c.year#c.year c.PM10#c.year#c.year#c.year c.O3#c.year#c.year#c.year c.NO2#c.year#c.year#c.year c.popdensity#c.year#c.year#c.year c.gdpcapita#c.year#c.year#c.year c.indusoutput#c.year#c.year#c.year c.finrev#c.year#c.year#c.year c.finexp#c.year#c.year#c.year"
global citypost "c.SO2#c.post               c.PM25#c.post               c.PM10#c.post               c.O3#c.post               c.NO2#c.post               c.popdensity#c.post               c.gdpcapita#c.post               c.indusoutput#c.post               c.finrev#c.post               c.finexp#c.post"
global citycorr "c.SO2#year                 c.PM25#year                 c.PM10#year                 c.O3#year                 c.NO2#year                 c.popdensity#year                 c.gdpcapita#year                 c.indusoutput#year                 c.finrev#year                 c.finexp#year"
       
global trend  "c.treatment#c.year"
global trend2 "c.treatment#c.year#c.year"
global trend3 "c.treatment#c.year#c.year#c.year"

/*
global twfe       "code year"
global twfe_dummy "code year $citycorr $firmcorr"
*/

/*
global hdfe       "code year provid#year indusid#year"
global hdfe_dummy "code year provid#year indusid#year $citycorr"
*/

*  
global model1 "$cityl    $firml"
global model2 "$cityq    $firmq"
global model3 "$citypoly $firmpoly"
global model4 "$citypost $firmpost"
* ----------------------
/* matching based on city predetermined */
global citycorr "SO2 PM25 PM10 O3 NO2 popdensity gdpcapita indusoutput finrev finexp"
global citycorr_2010 "SO2_2010 PM25_2010 PM10_2010 O3_2010 NO2_2010 popdensity_2010 gdpcapita_2010 indusoutput_2010 finrev_2010 finexp_2010"
* ---------
use cityname year in_key_areas $citycorr if year == 2010 using "$processed/firm_reg_baseline.dta",clear
foreach covar in $citycorr {
	rename `covar' `covar'_2010
}
drop year
tempfile citycontrols_2010
save    `citycontrols_2010', replace
duplicates drop cityname,force

psmatch2 in_key_areas $citycorr_2010 , logit neighbor(3) ties caliper(0.05) common

merge 1:m cityname using "firm_reg_baseline.dta" , keep(3) nogen
keep if year == 2010
duplicates drop cityname, force
drop if _weight == . 

* mean-diff
ttable2 $citycorr_2010 , by(in_key_areas) 


keep cityname *_2010 _pscore _treated _support _weight _id _n1 _nn _pdif
merge 1:m cityname using "firm_reg_baseline.dta" , keep(3) nogen
sort code year cityname
order code year cityname

/* prepare for regression */

	* fiexed effects
	encode ind_2digit, gen(indusid)

	* static diff-in-diffs
	xtset code year
	gen treatment = in_key_areas
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
	local outcomes "stock_in netinc_in inc_in stock_out netinc_out inc_out"
	foreach outcome in `outcomes' {
			winsor2 `outcome', cut(1,99) replace
			summ `outcome'
	}
	* - 取对数 4
	foreach outcome in stock_in inc_in firmnum_in stock_out inc_out firmnum_out {
			gen ln`outcome' = log(1 + `outcome')
	}

	* - 除以资产滞后一期 6
	foreach outcome in stock_in netinc_in inc_in stock_out netinc_out inc_out {
			bys code (year): gen `outcome'_to_asset = `outcome' * 10000 / asset[_n - 1] if code == code[_n-1]
	}
	* - 改变量纲 6
	foreach outcome in stock_in netinc_in inc_in stock_out netinc_out inc_out {
			replace `outcome' = `outcome' / 10000
	}

	* city economic performance
	foreach citycorr in popdensity gdpcapita indusoutput finrev finexp {
			gen ln`citycorr'=log(`citycorr')
	}


	sort code year
	order code year * *_2010
	tempfile firm_reg_robust
	save `firm_reg_robust' , replace

* -----------------------
use `firm_reg_robust' , clear
gen post = year >= 2014

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
		    /*
			reghdfe `Y' policy , a($hdfe_dummy)   vce(cluster $clusters)
			est sto model5
			*/
			* output
			esttab model1 model2 model3 model4   ///
			using "$robust/common_support_`Y'.csv", ///
			b(4) se(4) ///
			keep(policy) order(policy) ///
			r2 star(* 0.1 ** 0.05 *** 0.01) replace
}


/* event study */
foreach Y in $outcomes {

		est sto clear
		reghdfe `Y' F2-F4 L0-L3 $model1 , a($hdfe) vce(cluster $clusters)
		est sto model1
		reghdfe `Y' F2-F4 L0-L3 $model2 , a($hdfe) vce(cluster $clusters)
		est sto model2
		reghdfe `Y' F2-F4 L0-L3 $model3 , a($hdfe) vce(cluster $clusters)
		est sto model3
		reghdfe `Y' F2-F4 L0-L3 $model4 , a($hdfe) vce(cluster $clusters)
		est sto model4
		/*
		reghdfe `Y' F2-F4 L0-L3 , a($hdfe_dummy) vce(cluster $clusters)
		est sto model5
		*/
		* output
		esttab model1 model2 model3 model4  ///
		using "$robust/`Y'.csv", ///
		b(3) se(3) ///
		keep(F4 F3 F2 L0 L1 L2 L3) order(F4 F3 F2 L0 L1 L2 L3) ///
		r2 star(* 0.1 ** 0.05 *** 0.01) replace


			
		/* plot all stored estimates together */
		event_plot model1 model2 model3 model4 model5, ///
				stub_lag(L# L# L# L# L# L#) stub_lead(F# F# F# F# F# F# F#) ///
				plottype(scatter) ciplottype(rcap) ///
				together perturb(-0.325(0.13)0.325) trimlead(4) noautolegend ///
				graph_opt(title("Event study for `Y'", size(medlarge)) ///
					xtitle("Periods since the event") ytitle("Average causal effect") ///
					xlabel(-4(1)3, nogrid) ylabel(-5(5)5, nogrid) ///
			        legend(order(2 "Linear" 4 "Quadratic" 6 "Third polynomial" ///
			                8 "Post trend" 10 "Year FE" ) rows(3) region(style(none))) ///
					xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
					) ///
			lag_opt1(msymbol(+)  msize(small) color("33 102 172%80")) lag_ci_opt1(color("33 102 172%80")) ///
			lag_opt2(msymbol(Th) msize(small) color("33 102 172%30")) lag_ci_opt2(color("33 102 172%30")) ///
			lag_opt3(msymbol(+)  msize(small) color("178 24 43%80"))  lag_ci_opt3(color("178 24 43%80")) ///
			lag_opt4(msymbol(Th) msize(small) color("178 24 43%30"))  lag_ci_opt4(color("178 24 43%30")) ///
			lag_opt5(msymbol(+)  msize(small) color("26 152 80%80"))  lag_ci_opt5(color("26 152 80%80")) 
			graph export "$robust/`Y'.png",replace
}

*** End of file





