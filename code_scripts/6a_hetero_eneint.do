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
* ------------------------
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out"
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
global model1 "$cityl"
global model2 "$cityq"
global model3 "$citypoly"
global model4 "$citypost"
* --------------------
use "firm_reg_balance.dta" , clear
gen  post = year >= 2014
gen  eneint = 0 
replace eneint = 1 if (ind_2digit == "C25" | ind_2digit == "C26" | ind_2digit == "C30" | ind_2digit == "C31" | ind_2digit == "C32")
* ------------------
matrix results = J(1, 6, .)

/* grouped regression */
*- SOE
preserve 
	keep if eneint == 1
	local group = 1
	local Y_index = 1
	foreach Y in $outcomes {

			est clear
		    reghdfe `Y' policy $model1 , a($hdfe) vce(cluster $clusters)
		    est sto model1
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index' + 0.2 ,1 , `group')
		    reghdfe `Y' policy $model2 , a($hdfe) vce(cluster $clusters)
		    est sto model2
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index' + 0.2, 2 , `group')
		    reghdfe `Y' policy $model3 , a($hdfe) vce(cluster $clusters)
		    est sto model3
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index' + 0.2, 3 , `group')
		    reghdfe `Y' policy $model4 , a($hdfe) vce(cluster $clusters)
		    est sto model4
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index' + 0.2, 4 , `group')
			reghdfe `Y' policy , a($hdfe_dummy)   vce(cluster $clusters)
			est sto model5
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index' + 0.2, 5 , `group')

		    local Y_index = `Y_index' + 1

			* output
			esttab model1 model2 model3 model4 model5  ///
			using "$hetero/eneint_`Y'.csv", ///
			b(4) se(4) ///
			keep(policy) order(policy) ///
			r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
	}
restore

*- Non-SOE
preserve 
	keep if eneint == 0
	local group = 0
	local Y_index = 1
	foreach Y in $outcomes {

			est clear

		    reghdfe `Y' policy $model1 , a($hdfe) vce(cluster $clusters)
		    est sto model1
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index' ,1 , `group')
		    reghdfe `Y' policy $model2 , a($hdfe) vce(cluster $clusters)
		    est sto model2
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index', 2 , `group')
		    reghdfe `Y' policy $model3 , a($hdfe) vce(cluster $clusters)
		    est sto model3
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index', 3 , `group')
		    reghdfe `Y' policy $model4 , a($hdfe) vce(cluster $clusters)
		    est sto model4
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index', 4 , `group')
			reghdfe `Y' policy , a($hdfe_dummy)   vce(cluster $clusters)
			est sto model5
		    matrix results = results \ (_b[policy], _b[policy] - 1.96 * _se[policy], _b[policy] + 1.96 * _se[policy], `Y_index', 5 , `group')

		    local Y_index = `Y_index' + 1

			* output
			esttab model1 model2 model3 model4 model5  ///
			using "$hetero/noneneint_`Y'.csv", ///
			b(4) se(4) ///
			keep(policy) order(policy) ///
			r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
	}
restore

/* plot the coefficients */
svmat  results, names(col)
rename c1 coef
rename c2 lb
rename c3 ub
rename c4 y_index
rename c5 model_index
rename c6 group

#delimit ;
twoway (rcap lb ub y_index if  model_index == 3 & group == 1 , 
			 horizontal 
			 color(edkblue) 
			 legend(label(1 "CI for Energy-intensive")) 
			 lp(dash)     
			 text(6 10 "Outcomes: Stock",place(e))) 
	   (rcap lb ub y_index if  model_index == 3 & group == 0 , 
			 horizontal 
			 color(emidblue) 
			 legend(label(2 "CI for Non-Energy-intensive")))

       (scatter y_index coef if  model_index == 3 & group == 1 , 
        	    legend(label(3 "Energy-intensive")) 
       		    msymbol(circle) mcolor(stred)) 

       (scatter y_index coef if  model_index == 3 & group == 0 , 
                legend(label(4 "Non-Energy-intensive")) 
       		    msymbol(diamond) mcolor(stgreen)), 

       title("Heterogeneity by industry", span ring(1)) 
       ylabel(1 "Stock" 2 "Net increase" 3 "Increase" 4 "Firm Number")
       ytitle("Outcomes") 
       xline(0 , lc(gs6) lp(solid) lw(0.3)) 
       legend(order(3 4) position(bottom) row(1));
       graph export "$hetero/by_ind.png" , replace ;
#delimit cr


/* interaction */
gen interaction = policy * eneint

foreach Y in $outcomes {

		est clear
		
	    reghdfe `Y' policy interaction $model1 , a($hdfe) vce(cluster $clusters)
	    est sto model1
	    reghdfe `Y' policy interaction $model2 , a($hdfe) vce(cluster $clusters)
	    est sto model2
	    reghdfe `Y' policy interaction $model3 , a($hdfe) vce(cluster $clusters)
	    est sto model3
	    reghdfe `Y' policy interaction $model4 , a($hdfe) vce(cluster $clusters)
	    est sto model4
		reghdfe `Y' policy interaction , a($hdfe_dummy)   vce(cluster $clusters)
		est sto model5

		* output
		esttab model1 model2 model3 model4 model5  ///
		using "$hetero/eneint_interaction_`Y'.csv", ///
		b(4) se(4) ///
		keep(policy interaction) order(policy interaction) ///
		r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
}

*** End of file



