global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

********************************************
/* geographic diversification */
/* 母公司到子公司距离的平均值 */

use "/Users/chandlerwong/Desktop/毕业论文/Data/intermedia/参控股公司及其信息.dta", clear
destring 证券代码, gen(code)
destring 会计年度, gen(year)
tempfile subfirm_info
save    `subfirm_info', replace 

use code year 注册地* using "$raw/firm_correlates_raw.dta", clear
merge 1:m code year  using `subfirm_info', keep(1 3) nogen keepusing(经度 纬度)

ren 注册地经度 plon
ren 注册地纬度 plat
ren 经度 slon
ren 纬度 slat

* Mannual correct
drop if slat == .
replace plon = 106.353299 if code == 688396
replace plat = 29.596552  if code == 688396

label var plon "母公司注册地经度"
label var plat "母公司注册地纬度"
label var slon "子公司注册地经度"
label var slat "子公司注册地纬度"


geodist plat plon slat slon, gen(dist)
bys code year: egen dist_mean = mean(dist)
drop dist *lat *lon 
duplicates drop code year dist_mean, force 
save "$interm/geo_pattern.dta",replace 

*** EOF


