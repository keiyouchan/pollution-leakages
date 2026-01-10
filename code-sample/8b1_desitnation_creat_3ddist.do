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
		global destin     "$output/destination"

cd $processed

/* Destination: Province */
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out"
	* HDFE model
	global hdfe       "pair cityname distbin year provid#year"
	global clusters   "code"
 

/* matching based on firm predetermined variables */
	global firmcorr "age roa far lnempl lnast lnrevn envvio" // 
	global pollutnt "SO2 PM25" // PM10 O3 NO2
	global citycorr "gdpcapita indusoutput finrev" // finexp  popdensity

global binw 400 // set width of bin


***********************************************

*** calculate distance

* subfirm's location
use "$raw/subfirm_correlates.dta" , clear
rename 子公司名称 subfirm
rename 证券代码 code
rename 年份 year
rename 经度 slon
rename 纬度 slat
keep   subfirm code year slon slat
destring code , replace 
tempfile sloc            
save    `sloc' , replace

* parent's location
use "$raw/firm_correlates_raw.dta" , clear
rename 办公地经度 plon 
rename 办公地纬度 plat
keep   code year plon plat
tempfile ploc            
save    `ploc' , replace 


* 计算距离
merge 1:m code year using `sloc' , keep(1 3) nogen
drop if plon == .
drop if slon == .
drop if subfirm == ""
geodist plat plon slat slon , gen(dist)
drop if dist == .

* 去重
duplicates drop subfirm code , force
keep subfirm code dist 
tempfile dist 
save    `dist' , replace


* 查看距离分布
twoway histogram dist, percent ///
		width(200) ///
		xlabel(,nogrid) ///
		ylabel(,nogrid) ///
		ytitle("Percent (%)") ///
		xtitle("Distance (km)")
		graph export "$destin/hisplot_distance.png", replace


* merge distance 
use "$interm/subfirm_stock_expanded.dta" , replace
destring  code, replace
merge m:1 subfirm code using `dist' , keep(1 3) nogen
summ dist, d 

/* 
p1  = 5     p5  = 52   p10 = 103  p25 = 261 
p50 = 676   p75 = 1252 p90 = 1763 p95 = 2146 
p99 = 3340
*/

* 映射到距离区间
gen lb = floor(dist / $binw) * $binw
gen rb = lb + $binw
replace lb = 2000 if lb > 2000
replace rb = 4500 if lb >= 2000
gen distbin = string(lb) + " - " + string(rb) if !missing(dist)


*** collapase outcomes
* keep  if in_key_dummy == 0
local outcome stock netinc inc
foreach y in `outcome'{
		egen `y'_out = sum(`y') if in_key_dummy == 0, by(code distbin year)
}
egen firmnum_out = sum(active), by(code distbin year)

sort code distbin year
collapse (first) stock_out netinc_out inc_out firmnum_out, by(code distbin year)
tempfile outkey_inv
save `outkey_inv', replace



* -------------------------
/* create trimensional panel data : code-distance-year */
*- create distance bin
clear
set obs 6
gen lb = (_n - 1) * $binw
gen rb = _n * $binw
replace rb = 4500 if _n == _N
gen distbin = string(lb) + " - " + string(rb)
tempfile distbin
save    `distbin' , replace

*- create code list
use code using "$processed/firm_reg_balance.dta" , clear
duplicates drop code , force
tempfile firm 
save    `firm' , replace

*- create year
clear
set obs 8
gen year = _n
replace  year = _n + 2010 - 1
tempfile year
save    `year' , replace

*- combine 3d panel
use `firm' , clear
cross using `distbin'
cross using `year'
sort code distbin year

merge m:1 code          using "$interm/parent_info.dta"     , keep(1 3) nogen // merge parent firm info
merge m:1 code year     using "$interm/firm_correlates.dta" , keep(1 3) nogen // time-varying
merge m:1 cityname year using "$interm/pollutants.dta"      , keep(1 3) nogen // time-varying pollutants in parent city
merge m:1 cityname      using "$interm/city_correlates_processed.dta", keep(1 3) nogen // pre-treatment parent city characteristics
merge m:1 code year     using "$interm/geo_pattern.dta"     , keep(1 3) nogen // 地理多样性
merge m:1 code year     using "$raw/env_violation.dta"      , keep(1 3) nogen // 环境违规次数
drop lb rb


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

*- pollutants 
foreach v in $pollutnt{
		 bys cityname (year) : replace `v' = `v'[1]
		 rename `v' pltn_char_`v'
}
tempfile tpanel
save    `tpanel' , replace

/* merge Outcomes variables */
use `tpanel' , clear
merge 1:1 code distbin year using `outkey_inv' , keep(1 3) nogen



/* prepare for regression */

*- static diff-in-diffs
gen post = year >= 2014
gen treatment = in_key_areas
gen policy    = treatment * post

*- Fixed effects
encode ind_2digit , gen(indusid)
egen   pair = group(code distbin)

*- fillmissing Y
foreach Y in $outcomes {
		 replace `Y' = 0 if missing(`Y')
}

*- Y Winsorization
foreach Y in $outcomes   {
		 winsor2 `Y' , cut(1,99) replace
}

*- Inv transformation
local outcomes stock netinc inc
foreach Y in `outcomes'   {
		 replace `Y' = `Y' / 10000
}

summ $outcomes 
/* save data */
save "$processed/three_dimens_distance.dta" , replace


 /*- baseline regression : cityid better performance
 reghdfe stock_out policy $model3 , a($hdfe) vce(cluster code)
 reghdfe stock_out policy $model3 , a($hdfe) vce(cluster cityid)
 reghdfe stock_out policy $model4 , a($hdfe) vce(cluster code)
 reghdfe stock_out policy $model4 , a($hdfe) vce(cluster cityid)
 reghdfe stock_out policy         , a($hdfe_dummy) vce(cluster code)
 reghdfe stock_out policy         , a($hdfe_dummy) vce(cluster cityid)
 */ 

*** End of file
