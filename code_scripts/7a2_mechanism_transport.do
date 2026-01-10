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

/* Mechanism: Urban Form */
 * outcome variables
 global outcomes "stock_out netinc_out inc_out firmnum_out"
 	* HDFE model
 	global hdfe       "code pair recipient year provid#year indusid#year"
 	global hdfe_dummy "code pair recipient year provid#year indusid#year $citycorr"
 	global clusters   "cityid"



* ------------------
/* Use variable in 2013 as mechanism */
/*
/*merge transportation */
 import excel using "$raw/transportation.xlsx" , first sheet("Sheet2") clear 
 rename 省份名称 reciprov
 rename 城市名称 recipient 
 rename 会计年度 year
 rename (年末实有城市道路面积万平方米 年末实有公共汽电车营运车辆数辆 每万人拥有公共汽车数辆 全年公共汽电车客运总量万人次 年末实有出租汽车数辆 人均城市道路面积平方米) ///
 		(road bus buspercapi passen taxi roadpercapi)
 keep if year == 2013
 replace recipient = reciprov if recipient == ""
 drop if recipient == "合计"
 drop year
 drop 统计范围
 tempfile transport
 save    `transport' , replace


 * merge
 use  "$processed/three_dimens_panel.dta" , replace
 merge m:1 recipient using `transport' , keep(1 3) nogen

 * mechanism test
 foreach m in road bus buspercapi passen taxi roadpercapi {

 		 est clear

 		 reghdfe stock_out i.policy##c.`m' $model3 if flowin_key == 0 , a($hdfe) vce(cluster $clusters)
 		 est sto m3
 		 reghdfe stock_out i.policy##c.`m' $model4 if flowin_key == 0 , a($hdfe) vce(cluster $clusters)
 		 est sto m4
 		 reghdfe stock_out i.policy##c.`m'         if flowin_key == 0 , a($hdfe_dummy) vce(cluster $clusters)
 		 est sto m5


 		 * output
 		 esttab m3 m4 m5 ///
 		 using "$mechanism/mechanism_transport_`m'_2012.csv" , ///
 		 b(4) se(4) ///
 		 keep(1.policy 1.policy#c.`m') order(1.policy 1.policy#c.`m') ///
		 r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
 }
*/


*=============== 交通建设历年均值 ===============*

/* 计算机制变量的均值 */

import excel using "$raw/transportation.xlsx" , first sheet("Sheet1") clear 
rename 省份名称 reciprov
rename 城市名称 recipient 
rename 会计年度 year
rename (年末实有城市道路面积万平方米 年末实有公共汽电车营运车辆数辆 每万人拥有公共汽车数辆 全年公共汽电车客运总量万人次 年末实有出租汽车数辆 人均城市道路面积平方米) ///
		(road bus buspercapi passen taxi roadpercapi)
gen passenger = real(passen)
gen roadavg = real(roadpercapi)
replace recipient = reciprov if recipient == ""
drop if recipient == "合计"


local year_l = 2010
local year_r = 2013
keep if year <= `year_r' & year >= `year_l'


* - 计算历年均值并分组
local m  "road bus buspercapi passenger taxi roadavg"
collapse `m', by(recipient)
foreach v in `m' {

		winsor2 `m', cut(1 99) replace 
		egen avg_`v' = mean(`v')
		gen  m_`v' = `v' > avg_`v'
} 


drop avg_*
tempfile transport
save    `transport' , replace



*- merge to trimensional data

use  "$processed/three_dimens_panel.dta" , replace
merge m:1 recipient using `transport'    , keep(1 3) nogen
replace road   = 0 if missing(road)
replace m_road = 0 if missing(m_road)

*======= 回归 =======*

foreach m in road m_road { 

 		est clear

 		reghdfe stock_out i.policy##c.`m' if flowin_key == 0 , a($hdfe c.(pltn*)#year) vce(cluster $clusters)
 		est sto trans


 		* output
 		esttab trans, ///
 		b(3) se(3) ar2(3) ///
 		keep(1.policy 1.policy#c.`m') ///
 		order(1.policy 1.policy#c.`m') ///
		star(* 0.1 ** 0.05 *** 0.01) ///
		compress nogaps replace


 		* export to file
 		esttab trans using "$mechanism/mechanism_transport_`m'.csv", ///
 		b(3) se(3) ar2(3) ///
 		keep(1.policy 1.policy#c.`m') ///
 		order(1.policy 1.policy#c.`m') ///
		star(* 0.1 ** 0.05 *** 0.01) ///
		compress nogaps replace
 }



 *** End of file
