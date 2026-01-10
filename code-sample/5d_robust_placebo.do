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

* fixed effects
global twfe "code year"
global hdfe "code year provid#year indusid#year"

* -----------
/* */
/*
import excel using "$raw/城市经纬度.xlsx", firstrow clear sheet("城市经纬度")
rename 城市编码 citycode 
rename 城市级别 citylevel
rename 省级名称 provname 
rename 地市级名称 cityname
rename 县级名称 countyname
rename 区号 district
rename 邮政编码 postcode
rename 经度 lon
rename 纬度 lat
drop if inlist(cityname,"澳门","香港","台湾","钓鱼岛")


gen prov = provname
replace prov = prov + "市" if inlist(prov, "北京", "天津", "上海", "重庆")

replace prov = prov + "省" if inlist(prov, "河北","山西","辽宁","吉林","黑龙江","江苏","浙江")
replace prov = prov + "省" if inlist(prov, "安徽","福建","江西","山东")
replace prov = prov + "省" if inlist(prov, "河南","湖北","湖南","广东","海南")
replace prov = prov + "省" if inlist(prov, "四川","贵州","云南","陕西","甘肃")
replace prov = prov + "省" if inlist(prov, "青海","台湾")

replace prov = "内蒙古自治区" if prov == "内蒙古"
replace prov = "广西壮族自治区" if prov == "广西"
replace prov = "西藏自治区"     if prov == "西藏"
replace prov = "宁夏回族自治区" if prov == "宁夏"
replace prov = "新疆维吾尔自治区" if prov == "新疆"

replace prov = "香港特别行政区" if prov == "香港"
replace prov = "澳门特别行政区" if prov == "澳门"


gen city = cityname + "市"

* import excel using "$migration/key areas.xlsx", firstrow clear sheet("Sheet1")
* save "$raw/key_areas.dta", replace


save "$raw/city_coords.dta", replace 
*/

*============================================================
*# 找出距离三区十群最近的城市

*## 计算每个市区的经纬度平均值
tempfile city_coords
use "$raw/city_coords.dta", clear 
collapse lon lat, by(city)
save `city_coords', replace


*## 计算三区十群城市到每个城市的距离
merge 1:1 city using  "$raw/key_areas.dta", keep(3) nogen keepusing(city)
rename city key_area
rename lon lon1
rename lat lat1
cross using `city_coords'
sort  key_area city 
order key_area city


merge m:1 city using  "$raw/key_areas.dta", keep(1 3) nogen 
drop if city == key_area
drop if mark == 1 
drop mark

geodist lat1 lon1 lat lon, gen(dist)

*## 找出最小距离
bys key_area: egen min_dist = min(dist)  // 与key area最近的距离
keep if dist == min_dist

duplicates drop city, force 
keep city 
gen mark = 1

*# 保存
save "$interm/false_key.dta", replace 



*# 构建虚构处理组
use "$interm/false_key.dta", clear 
gen cityname = city 
gen false_treat = mark

merge 1:m cityname using "$processed/firm_reg_balance.dta", keep(2 3) nogen
replace false_treat = 0 if mi(false_treat)
gen f_policy = false_treat * post 

*# regress
reghdfe stock_out f_policy if in_key_areas == 0, a($twfe) vce(cluster citycode)
est sto p1
reghdfe stock_out f_policy if in_key_areas == 0, a($hdfe) vce(cluster citycode)
est sto p2
reghdfe stock_out f_policy if in_key_areas == 0, a($hdfe c.(pltn_char_*)#year) vce(cluster citycode)
est sto p3

esttab p1 p2 p3 using "$robust/spatial_placebo.csv", ///
	   b(3) se(3) ar2(3) ///
	   keep(f_policy) ///
	   order(f_policy) ///
	   star(* 0.1 ** 0.05 *** 0.01) ///
	   compress nogaps replace 



/* ----------------
use    "firm_reg_balance.dta", clear

foreach outcome in $outcomes {
	*tempfile `outcome'
	permute policy beta = _b[policy] se = _se[policy] df = e(df_r), ///
	reps(1000) rseed(123) saving("$robust/`outcome'"): ///
	reghdfe `outcome' policy , a($hdfe_dummy) vce(cluster $clusters)
}


/* plot coefs */
* total investment
use "$robust/stock_out", clear
gen t_value=beta/se
gen p_value=2*ttail(df, abs(beta/se))


#delimit ;
dpplot beta, xline(2.276, lc(black*1) lp(solid))
	xline(0, lc(black*0.5) lp(dash))
	xtitle("Coefficient", size(large)) 
	text(2.276  1 "Baseline results = 2.276", place(r) size(small))
	xlabel(-1(1)4, nogrid format(%4.1f) labsize(median))
	ytitle("Density", size(large)) 
	ylabel(, nogrid format(%4.1f) labsize(median)) 
	note("") caption("") 
	graphregion(fcolor(white)) ;
#delimit cr
	graph export "$robust/placebo.png", replace






