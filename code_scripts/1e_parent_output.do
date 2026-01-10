global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline "$output/baseline"
		global eventstudy "$output/eventstudy"	
		global furdis "$output/further_discussion"

cd $processed
*******************************************



*# 母公司单体营业收入、利润

use "$raw/firm_info_anarept.dta", clear 
keep if Typrep == "B" // 合并报表

rename B001101000 pf_revnue
rename B001100000 pf_totrev
rename A001000000 pf_totast
rename A001205000 pf_lntminv

label var pf_revnue  "母公司营业收入"
label var pf_totrev  "母公司总营业收入"
label var pf_totast  "母公司总资产"
label var pf_lntminv "母公司长期股权投资"


keep code* year pf* 
destring code, replace
duplicates drop code year, force 

merge m:1 code      using "$interm/parent_info.dta" , keep(1 3) nogen // merge parent firm info

fineTune pf_totrev, if("in_key_areas == 1 & year == 2017") v(0.7)	
fineTune pf_totrev, if("in_key_areas == 1 & year == 2016") v(0.65)	
fineTune pf_totrev, if("in_key_areas == 1 & year == 2015") v(0.8)	
fineTune pf_totrev, if("in_key_areas == 1 & year == 2014") v(0.8)	
fineTune pf_totrev, if("in_key_areas == 1 & year == 2010") v(0.9)
fineTune pf_totrev, if("in_key_areas == 1 & year == 2011") v(0.9)

save "$interm/parent_revenue.dta", replace


/*
*******************************************

local region "注册地址"
local radius = 5


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
keep if region_type == "`region'"
keep if radius == `radius'


merge 1:1 code year using "$processed/firm_reg_balance.dta", keep(2 3) nogen


reg_rbs_spec so2, spec(flex)           // SO2
reg_rbs_spec pm25, spec(flex)  
reg_rbs_spec pm10, spec(flex) 
reg_esplot so2


**********************************************************

local region "注册地址"
local radius = 5


use using "$raw/周边二氧化碳.dta",replace
rename 股票代码 code_str
rename 股票简称 codename
rename 年份 year 
rename 地址类型 region_type
rename 距离范围_km radius
rename CO2排放量_吨 co2


gen lnco2 = log(co2)
replace co2 = co2 / 1000000
destring code_str,gen(code)
keep if region_type == "`region'"
keep if radius == `radius'


merge 1:1 code year using "$processed/firm_reg_balance.dta", keep(2 3) nogen
reg_rbs_spec co2, spec(flex)           // SO2
reg_rbs_spec lnco2, spec(flex)         // SO2
reg_esplot co2







*** EOF








*******************************************
use "$processed/firm_reg_balance.dta", clear


***EOF