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
global model1 "$cityl    $firml"
global model2 "$cityq    $firmq"
global model3 "$citypoly $firmpoly"
global model4 "$citypost $firmpost"
* ---------------
import excel "$raw/环保约谈处理组.xlsx" ,  sheet("Sheet1") firstrow clear
tempfile hbyt
save `hbyt' , replace 

* ----------------
use "firm_reg_balance.dta", clear
gen post = year >= 2014
merge m:1 cityname using `hbyt' , keep(1 3) nogen


	replace hbyttreat = 0 if hbyttreat == .
	replace time = 9999 if time == .
	gen hbytpost = (year >= time ) if !missing(time)
	gen hbytdid = hbyttreat * hbytpost // 生成环保did


reghdfe stock_out policy hbytdid $model3 , a($hdfe) vce(cluster $clusters)
est sto model3
reghdfe stock_out policy hbytdid $model4 , a($hdfe) vce(cluster $clusters)
est sto model4
reghdfe stock_out policy hbytdid, a($hdfe_dummy)   vce(cluster $clusters)
est sto model5