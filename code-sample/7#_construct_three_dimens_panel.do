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

clear 
**************************
 * outcome variables
 global outcomes "stock_out netinc_out inc_out firmnum_out"
 	* HDFE model
 	global hdfe       "pair cityname recipient year provid#year"
 	global clusters   "code"


/* matching based on firm predetermined variables */
*global firmcorr "roa unitprof alr payment equityr lnempl lnscale grev asset tobinq far age"
*global citycorr "SO2 PM25 PM10 O3 NO2 popdensity gdpcapita indusoutput finrev finexp"
*global parrev "totrev rev profit totprof netprof"

	global firmcorr "age roa far lnempl lnast lnrevn envvio" // 
	global pollutnt "SO2 PM25" // PM10 O3 NO2
	global citycorr "gdpcapita indusoutput finrev" // finexp  popdensity

* ---------
/* create a three dimensional panel: "Firm-destination-year" */

* - firm list
use using "$processed/firm_reg_baseline.dta",clear
keep code
duplicates drop code, force
gen str6 code_str = string(code, "%06.0f")
tempfile firm 
save    `firm' , replace

* - city list
use cityname  using "$raw/main.dta",clear
duplicates drop cityname , force
drop if cityname == "-"
rename  cityname recipient
tempfile city 
save    `city' , replace

* - year
clear
set obs 8
gen year = _n
replace year = _n + 2010 - 1
tempfile year
save `year' , replace

* - 3-dimensional panel
use `firm' , clear
cross using `city'
cross using `year'
sort code recipient year



/* merge correlates */
merge m:1 code          using "$interm/parent_info.dta"     , keep(1 3) nogen // merge parent firm info
merge m:1 code year     using "$interm/firm_correlates.dta" , keep(1 3) nogen // time-varying
merge m:1 cityname year using "$interm/pollutants.dta"      , keep(1 3) nogen // time-varying pollutants in parent city
merge m:1 cityname      using "$interm/city_correlates_processed.dta", keep(1 3) nogen // pre-treatment parent city characteristics
merge m:1 code year     using "$interm/geo_pattern.dta"     , keep(1 3) nogen // 地理多样性
merge m:1 code year     using "$raw/env_violation.dta"      , keep(1 3) nogen // 环境违规次数




/* replace firm correlates and city correlates using pre-treatment value */
 *- firm
 foreach v in $firmcorr{
 		 bys code (year) : replace `v' = `v'[1]
 		 rename `v' firm_char_`v'
 }

 *- city correlates
 foreach v in $citycorr{
 		 bys cityname (year) : replace `v' = `v'[1]
 		 rename `v' city_char_`v'
 }

 *0 pollutants
  foreach v in $pollutnt{
 		 bys cityname (year) : replace `v' = `v'[1]
 		 rename `v' pltn_char_`v'
 }

 tempfile tpanel
 save `tpanel' , replace



/* merge Outcomes and mechanism variables */

 *- obtain subfirm location
 use code subfirm sub_cityname using "$raw/main.dta" , clear
 rename sub_cityname recipient
 duplicates drop code subfirm , force
 destring        code , replace
 tempfile subfrim_loc
 save    `subfrim_loc' , replace



 *- merge subfirm location
 use "$interm/subfirm_stock_expanded.dta" ,replace
 destring  code , replace
 merge m:1 code subfirm using `subfrim_loc', keep(1 3) nogen





 * - collapase outcomes

 *keep  if in_key_dummy == 0
 local outcome stock netinc inc
 foreach y in `outcome'{
 		 egen `y'_out = sum(`y') if in_key_dummy == 0, by(code recipient year)
 }
 egen firmnum_out = sum(active)  , by(code recipient year)

 * - mechanism: established network

 local year_l = 2010
 local year_r = 2013
 egen network = sum(active) if year <= `year_r' & year >= `year_l', by(code recipient)
 bys  code recipient (network) : fillmissing network, with(previous)
 sort code recipient year
 
 collapse (first) stock_out netinc_out inc_out firmnum_out network , by(code recipient year)
 tempfile outkey_inv
 save `outkey_inv', replace

 * - merge
 use `tpanel' , clear
 merge 1:1 code recipient year using `outkey_inv' , keep(1 3) nogen







/* prepare for regression */

 *- static diff-in-diffs
gen post = year >= 2014
gen treatment = in_key_areas
gen policy    = treatment * post
/*
gen in_10clusters_copy = inlist(provname, "沈阳市","济南市","青岛市","淄博市","潍坊市","日照市","武汉市","长沙市","重庆市","成都市","福州市","三明市","太原市","西安市","咸阳市","兰州市","银川市","乌鲁木齐市") 
gen in_3regions = inlist(provname, "北京市","天津市","石家庄市","唐山市","保定市","廊坊市", ///
									"上海市","南京市","无锡市","常州市","苏州市","南通市","扬州市","镇江市","泰州市","杭州市","宁波市","嘉兴市","湖州市","绍兴市", ///
									"广州市","深圳市","珠海市","佛山市","江门市","肇庆市","惠州市","东莞市","中山市") ///
*/

*- Fixed effects
encode ind_2digit , gen(indusid)
egen   pair = group(code recipient)

*- fillmissing Y
foreach Y in $outcomes network  {
		 replace `Y' = 0 if missing(`Y')
}

*- Y transformation
foreach Y in $outcomes  {
		 winsor2 `Y' , cut(1,99)
		 replace `Y' = `Y' / 10000
}

*- flow
gen     flowin_key = 0
replace flowin_key = 1 if (recipient=="北京市" | recipient=="天津市" | recipient=="石家庄市" | recipient=="唐山市" | recipient=="保定市" | recipient=="廊坊市" | /// 
					    recipient=="上海市" | recipient=="南京市" | recipient=="无锡市" |   recipient=="常州市" | recipient=="苏州市" | recipient=="南通市" | recipient=="扬州市" | recipient=="镇江市" | recipient=="泰州市" | recipient=="杭州市" | recipient=="宁波市" | recipient=="嘉兴市" | recipient=="湖州市" | recipient=="绍兴市" | ///
					    recipient=="广州市" | recipient=="深圳市" | recipient=="珠海市" |   recipient=="佛山市" | recipient=="江门市" | recipient=="肇庆市" | recipient=="惠州市" | recipient=="东莞市" | recipient=="中山市" | /// 
					    /// 十群 
					    recipient=="沈阳市" | recipient=="济南市" | recipient=="青岛市" | recipient=="淄博市" | recipient=="潍坊市" | recipient=="日照市" | ///
					    recipient=="武汉市" | recipient=="长沙市" | recipient=="重庆市" | recipient=="成都市" | ///
					    recipient=="福州市" | recipient=="三明市" | recipient=="太原市" | recipient=="西安市" | recipient=="咸阳市" | recipient=="兰州市" | recipient=="银川市" | recipient=="乌鲁木齐市")






 *- save data
 save "$processed/three_dimens_panel.dta" , replace 
 


*** Enf of file