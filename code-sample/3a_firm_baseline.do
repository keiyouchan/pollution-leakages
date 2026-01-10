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
* -----------------
/* main setting */
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out uniinv"
	* HDFE model
	global hdfe       "code year provid#year indusid#year"
	global hdfe_dummy "code year provid#year indusid#year $citycorr"
	global clusters   "cityid"

* -----------
global cityl    "c.SO2#c.year               c.PM25#c.year               c.PM10#c.year               c.O3#c.year               c.NO2#c.year               c.popdensity#c.year               c.gdpcapita#c.year               c.indusoutput#c.year               c.finrev#c.year               c.finexp#c.year"
global cityq    "c.SO2#c.year#c.year        c.PM25#c.year#c.year        c.PM10#c.year#c.year        c.O3#c.year#c.year        c.NO2#c.year#c.year        c.popdensity#c.year#c.year        c.gdpcapita#c.year#c.year        c.indusoutput#c.year#c.year        c.finrev#c.year#c.year        c.finexp#c.year#c.year"
global citypoly "c.SO2#c.year#c.year#c.year c.PM25#c.year#c.year#c.year c.PM10#c.year#c.year#c.year c.O3#c.year#c.year#c.year c.NO2#c.year#c.year#c.year c.popdensity#c.year#c.year#c.year c.gdpcapita#c.year#c.year#c.year c.indusoutput#c.year#c.year#c.year c.finrev#c.year#c.year#c.year c.finexp#c.year#c.year#c.year"
global citypost "c.SO2#c.post               c.PM25#c.post               c.PM10#c.post               c.O3#c.post               c.NO2#c.post               c.popdensity#c.post               c.gdpcapita#c.post               c.indusoutput#c.post               c.finrev#c.post               c.finexp#c.post"
global citycorr "c.SO2#year                 c.PM25#year                 c.PM10#year                 c.O3#year                 c.NO2#year                 c.popdensity#year                 c.gdpcapita#year                 c.indusoutput#year                 c.finrev#year                 c.finexp#year"
       
/*
global firml "c.roa_2010#c.year c.unitprof_2010#c.year c.alr_2010#c.year c.payment_2010#c.year c.equityr_2010#c.year c.lnempl_2010#c.year c.lnscale_2010#c.year c.grev_2010#c.year c.lnasset_2010#c.year c.tobinq_2010#c.year c.far_2010#c.year c.age_2010#c.year"
global firmq "c.roa_2010#c.year#c.year c.unitprof_2010#c.year#c.year c.alr_2010#c.year#c.year c.payment_2010#c.year#c.year c.equityr_2010#c.year#c.year c.lnempl_2010#c.year#c.year c.lnscale_2010#c.year#c.year c.grev_2010#c.year#c.year c.lnasset_2010#c.year#c.year c.tobinq_2010#c.year#c.year c.far_2010#c.year#c.year c.age_2010#c.year#c.year"
global firmpoly "c.roa_2010#c.year#c.year#c.year c.unitprof_2010#c.year#c.year#c.year c.alr_2010#c.year#c.year#c.year c.payment_2010#c.year#c.year#c.year c.equityr_2010#c.year#c.year#c.year c.lnempl_2010#c.year#c.year#c.year c.lnscale_2010#c.year#c.year#c.year c.grev_2010#c.year#c.year#c.year c.lnasset_2010#c.year#c.year#c.year c.tobinq_2010#c.year#c.year#c.year c.far_2010#c.year#c.year#c.year c.age_2010#c.year#c.year#c.year"
global firmpost "c.roa_2010#c.post c.unitprof_2010#c.post c.alr_2010#c.post c.payment_2010#c.post c.equityr_2010#c.post c.lnempl_2010#c.post c.lnscale_2010#c.post c.grev_2010#c.post c.lnasset_2010#c.post c.tobinq_2010#c.post c.far_2010#c.post c.age_2010#c.post"
global firmcorr "c.roa_2010#year c.unitprof_2010#year c.alr_2010#year c.payment_2010#year c.equityr_2010#year c.lnempl_2010#year c.lnscale_2010#year c.grev_2010#year c.lnasset_2010#year c.tobinq_2010#year c.far_2010#year c.age_2010#year"
*/

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

global clusters "cityid"

*  
global model1 "$cityl    $firml"
global model2 "$cityq    $firmq"
global model3 "$citypoly $firmpoly"
global model4 "$citypost $firmpost"

* ----------------
use "firm_reg_balance.dta", clear

* outcome :  (common support)
global outcomes "stock_out netinc_out inc_out firmnum_out uniinv"
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
				   using "$baseline/common_support_`Y'.csv", ///
				   b(3) se(3) ar2(3) ///
				   keep(policy) order(policy) ///
				   star(* 0.1 ** 0.05 *** 0.01) replace
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
		reghdfe `Y' F2-F4 L0-L3 , a($hdfe_dummy) vce(cluster $clusters)
		est sto model5

		* output
		esttab model1 model2 model3 model4 model5 ///
		using "$eventstudy/`Y'.csv", ///
		b(3) se(3) ///
		keep(F4 F3 F2 L0 L1 L2 L3) order(F4 F3 F2 L0 L1 L2 L3) ///
		r2 ar2 star(* 0.1 ** 0.05 *** 0.01) replace


			
		/* plot all stored estimates together */
		event_plot model1 model2 model3 model4 model5, ///
				stub_lag(L# L# L# L# L# L#) stub_lead(F# F# F# F# F# F# F#) ///
				plottype(scatter) ciplottype(rcap) ///
				together perturb(-0.325(0.13)0.325) trimlead(4) noautolegend ///
				graph_opt(title("", size(medlarge)) ///
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
			graph export "$eventstudy/`Y'.png",replace
}

reghdfe uniinv policy  , a($hdfe_dummy) vce(cluster $clusters)


* outcome :  (common support)

***EOF
		/*
		reghdfe netinc_out policy   , a($hdfe_dummy) vce(cluster $clusters)
		replace F1 = 0
		reghdfe stock_out F2-F4 F1 L0-L3 , a($hdfe_dummy) vce(cluster $clusters)
		est sto model5
		coefplot model5 , ///
				 keep(F1 F2 F3 F4 L0 L1 L2 L3) ///
				 aseq swapnames ///
				 noeqlabels ///
				 vertical ///
				 omitted levels(95) ///
				 ciopts(lpattern(solid) recast(rcap) msize(medium) color(gs0)) ///CI为虚线上下封口
				 msymbol(circle_hollow) ///
				 msize(*0.5) c(1) color(black) ///
				 xlabel( 1 "-4" 2 "-3" 3 "-2" 4 "-1" 5 "0" 6 "1" 7 "2" 8 "3" ) ///
				 xline(4 , lp(dash) lcolor("0 47 167")) ///
				 yline(0, lp(dash) lc(gs0) lw(thin))                ///
				 legend(order(1 "95% Confidence Interval" 2 "Esitmates") size(small))     ///
				 ytitle("Coefficient") ///
				 xtitle("Period") ///
				 scheme(s1color)                   ///
				 graphregion(fcolor(gs16) lcolor(gs16)) ///
				 plotregion(lcolor("white") lwidth(*0.9)) ///
				 name("PTA",replace)
				 graph export "$eventstudy/eventstudy.png",replace
				 */
