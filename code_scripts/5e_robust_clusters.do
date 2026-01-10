* ------------------------
* HDFE model
global hdfe  "code year provid#year indusid#year"
global hdfes "code year provid#year indusid#year $citycorr"
global citycorr "c.SO2#year c.PM25#year c.PM10#year c.O3#year c.NO2#year c.popdensity#year c.gdpcapita#year c.indusoutput#year                 c.finrev#year                 c.finexp#year"
global clusters   "code"
* -----------
* ----------------
use "firm_reg_balance.dta", clear
gen post = year >= 2014


* --------- Adjust clusters ----------
reghdfe stock_out policy , a($hdfes)   vce(cluster provid)
est sto col1


* --------- Rule Out Competitive policy ----------
*- overlapping policy 1
import excel using "$raw/环保约谈处理组.xlsx" , sheet("Sheet1") firstrow clear
tempfile tour
save    `tour' , replace 

use    "firm_reg_balance.dta", clear
gen    post = year >= 2014

merge m:1 cityname using `tour' , keep(1 3) nogen
	replace hbyttreat = 0    if hbyttreat == .
	replace time      = 9999 if time == .
	gen hbytpost = (year >= time ) if !missing(time)
	gen tour  = hbyttreat * hbytpost // 生成环保did

*- overlapping policy 2
gen jnjptreat = 0 
replace jnjptreat = 1 if cityname == "北京市"
replace jnjptreat = 1 if cityname == "深圳市"
replace jnjptreat = 1 if cityname == "重庆市"
replace jnjptreat = 1 if cityname == "杭州市"
replace jnjptreat = 1 if cityname == "长沙市"
replace jnjptreat = 1 if cityname == "贵阳市"
replace jnjptreat = 1 if cityname == "吉林市"
replace jnjptreat = 1 if cityname == "新余市"

gen jnjppost = (year >= 2011) if !missing(year)
gen pilot = jnjptreat * jnjppost

reghdfe stock_out policy tour pilot , a($hdfes)   vce(cluster $clusters)
est sto col2

esttab  col1 col2, ///
b(3) se(3) ///
keep(policy) order(policy) ///
r2(3) star(* 0.1 ** 0.05 *** 0.01)


