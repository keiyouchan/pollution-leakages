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


*- mechanism variable
/*
use "$interm/ind_agg.dta" , clear
rename m2digit ind_2digit
rename host_city recipient
tempfile agg
save `agg' , replace 

*- merge to trimensional data
use "$processed/three_dimens_panel.dta" , clear
merge m:1 ind_2digit recipient using `agg', keep(1 3) nogen


 *- mechanism test
 foreach m in agg {

 		 est clear

 		 reghdfe stock_out i.policy##c.`m' $model3 if flowin_key == 0 , a($hdfe) vce(cluster $clusters)
 		 est sto m3
 		 reghdfe stock_out i.policy##c.`m' $model4 if flowin_key == 0 , a($hdfe) vce(cluster $clusters)
 		 est sto m4
 		 reghdfe stock_out i.policy##c.`m'         if flowin_key == 0 , a($hdfe_dummy) vce(cluster $clusters)
 		 est sto m5


 		 * output
 		 esttab m3 m4 m5 ///
 		 using "$mechanism/mechanism_`m'.csv" , ///
 		 b(4) se(4) ///
 		 keep(1.policy 1.policy#c.`m') order(1.policy 1.policy#c.`m') ///
		 r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
 }

*/


*================= 产业集聚均值 ===============*

* - 预处理

forvalues y = 2010(1)2013 {


		di "=== 正在载入第`y'年工业企业数据库 ==="


		use "$raw/`y'gq.dta",clear
		keep   行业门类代码 行业大类代码 省自治区直辖市 地区市州盟 企业名称
		rename 行业门类代码 type
		rename 行业大类代码 digit
		rename 省自治区直辖市 provname
		rename 地区市州盟 cityname
		rename 企业名称 firmname
		gen ind_2digit = type + string(digit)


		drop if cityname == ""
		drop if type  == ""
		drop if digit == .
		bys  ind_2digit cityname : egen firmnum = count(firmname)

		collapse firmnum, by(ind_2digit cityname) // 计算每个城市中每个行业（2digit）的企业有多少个
		rename cityname recipient
		rename firmnum  agg
		gen year = `y'

		tempfile ind_agg_`y'
		save `ind_agg_`y'', replace
}

use `ind_agg_2010',clear
append using `ind_agg_2011'
append using `ind_agg_2012'
append using `ind_agg_2013'
collapse agg, by(recipient ind_2digit)  

winsor2 agg, cut(1 99) replace 
bys ind_2digit: egen avg_agg = mean(agg)
gen high_agg = (agg > avg_agg)


tempfile indagg 
save    `indagg', replace 




*- merge to trimensional data

use "$processed/three_dimens_panel.dta" , clear
merge m:1 ind_2digit recipient using `indagg', keep(1 3) nogen
replace agg = agg / 100
replace agg = 0 if missing(agg)
replace high_agg = 0 if missing(high_agg)

*======= 回归 =======*
 foreach m in agg high_agg {

 		 est clear

		 reghdfe stock_out i.policy##c.`m' if flowin_key == 0 , a($hdfe c.(city_char_*)#year) vce(cluster $clusters)
 		 est sto m_agg


 		 * output
 		 esttab m_agg, ///
 		 b(3) se(3) ar2(3) ///
 		 keep(1.policy 1.policy#c.`m') ///
 		 order(1.policy 1.policy#c.`m') ///
		 star(* 0.1 ** 0.05 *** 0.01) replace

  		 esttab m_agg using "$mechanism/mechanism_`m'.csv" , ///
 		 b(3) se(3) ar2(3) ///
 		 keep(1.policy 1.policy#c.`m') ///
 		 order(1.policy 1.policy#c.`m') ///
		 star(* 0.1 ** 0.05 *** 0.01) ///
		 compress nogaps replace
 }

