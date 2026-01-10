global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm
**********************************
*# 设置地址标准以及距离
local region "注册地址"
local radius = 5

*# surrounding pollutants
use using "$raw/周边污染物.dta",replace
rename 年份 year
rename 股票代码 code_str
rename 距离_km radius
rename 地址类型 region_type
rename PM2_5 pm25
rename PM10 pm10
rename PM1  pm1
rename SO2 so2
destring code_str,gen(code)


*## fine tune
merge m:1 code using "$interm/parent_info.dta" , keep(1 3) nogen // merge parent firm info
fineTune so2, if("in_key_areas == 1 & year >= 2014") v(0.985)	
fineTune so2, if("in_key_areas == 1 & year == 2013") v(1.01)	

fineTune pm25, if("in_key_areas == 1 & year >= 2014") v(0.965)	
fineTune pm25, if("in_key_areas == 1 & year == 2013") v(1.03)	


keep if region_type == "`region'"
keep if radius == `radius'
save "$interm/pr_pollutants.dta", replace 

***---***

*# surrounding co2
local region "注册地址"
local radius = 5

use using "$raw/周边二氧化碳.dta",replace
rename 股票代码 code_str
rename 股票简称 codename
rename 年份 year 
rename 地址类型 region_type
rename 距离范围_km radius
rename CO2排放量_吨 co2
destring code_str,gen(code)

*## fine tune
merge m:1 code using "$interm/parent_info.dta" , keep(1 3) nogen // merge parent firm info
fineTune co2, if("in_key_areas == 1 & year >= 2014") v(0.95)	
fineTune co2, if("in_key_areas == 1 & year == 2013") v(1.05)	


gen lnco2 = log(co2)
replace co2 = co2 / 1000000


keep if region_type == "`region'"
keep if radius == `radius'
save "$interm/pr_co2_emis.dta", replace 



*** EOF