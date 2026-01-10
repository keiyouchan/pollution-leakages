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
gen post = year >= 2014
gen uniinv = stock_out * 100000000 / asset_2010 if !missing(stock_out) * !missing(asset_2010)



/* event study */
replace F1 = 0
reghdfe stock_out F2-F4 F1 L0-L3 , a($hdfe_dummy) vce(cluster $clusters)
est sto model 
		event_plot  model, ///
				stub_lag(L# L# L# L# L# L#) stub_lead(F# F# F# F# F# F# F#) ///
				plottype(connected) ciplottype(rcap) ///
				together  trimlead(4) noautolegend ///
				graph_opt(title("", size(medlarge)) ///
					xtitle("Periods", size(median)) ///
					ytitle("Coefficient", size(median)) ///
					xlabel(-4(1)3, nogrid labsize(median)) ///
					ylabel(-4(4)4, nogrid labsize(median)) ///
			        legend(order(1 "Point Estimates"2 "95% Confidence Interval") pos(6) row(1) size(median)) ///
					xline(-0.5, lcolor("0 47 167") lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
					) ///
			lag_opt1(msymbol(circle)  msize(small) color(gs6)) lag_ci_opt1(color(gs3))
			graph export "$eventstudy/eventstudy.png",replace

*** End of file
