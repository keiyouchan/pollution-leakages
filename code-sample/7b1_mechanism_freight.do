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
		global mechanism  "$output/mechanism"

cd $processed

/* regression */
 * outcome variables
 global outcomes "stock_out netinc_out inc_out firmnum_out"
 	* HDFE model
 	global hdfe       "code pair recipient year provid#year indusid#year"
 	global hdfe_dummy "code pair recipient year provid#year indusid#year $citycorr"
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
 
 
 global clusters "cityid"
 
 *  
 global model1 "$cityl    $firml"
 global model2 "$cityq    $firmq"
 global model3 "$citypoly $firmpoly"
 global model4 "$citypost $firmpost"

*- mechanism variable
use "$interm/freight2013.dta" , clear
rename host_city recipient
gen rail      = rgoods / goods * 100
gen highway   = pgoods / goods * 100
replace goods = goods / 10000
keep recipient rail highway goods 
tempfile transp
save    `transp' , replace 

*- merge to trimensional data
use "$processed/three_dimens_panel.dta" , clear
merge m:1 recipient using `transp', keep(1 3) nogen

*- mechanism test
foreach m in goods rail highway {

		 est clear

		 reghdfe stock_out i.policy##c.`m' $model3 if flowin_key == 0 , a($hdfe) vce(cluster $clusters)
		 est sto m3
		 reghdfe stock_out i.policy##c.`m' $model4 if flowin_key == 0 , a($hdfe) vce(cluster $clusters)
		 est sto m4
		 reghdfe stock_out i.policy##c.`m'         if flowin_key == 0 , a($hdfe_dummy) vce(cluster $clusters)
		 est sto m5


		 * output
		 esttab m3 m4 m5 ///
		 using "$mechanism/mechanism_`m'_2013.csv" , ///
		 b(3) se(3) ///
		 keep(1.policy 1.policy#c.`m') order(1.policy 1.policy#c.`m') ///
	 	 ar2(3) star(* 0.1 ** 0.05 *** 0.01) replace
}


*** End of file