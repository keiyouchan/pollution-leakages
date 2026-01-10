global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm


***************************************
use "$interm/firm_panel.dta",clear

* fill missing values using 0
local outcomes "stock_in netinc_in inc_in stock_out netinc_out inc_out firmnum_out"
foreach outcome in `outcomes'{
		replace `outcome' = 0 if `outcome' == .
}

* merge firm and city correlates

*# Firm-level vars

merge m:1 code          using "$interm/parent_info.dta"     , keep(1 3) nogen // merge parent firm info
*merge 1:1 code year     using "$interm/firm_controls.dta"   , keep(1 3) nogen // 这一步待定
merge 1:1 code year     using "$interm/firm_correlates.dta" , keep(1 3) nogen // 这一步待定
merge 1:1 code year     using "$interm/geo_pattern.dta"     , keep(1 3) nogen // 地理多样性
merge 1:1 code year     using "$raw/env_violation.dta"      , keep(1 3) nogen // 环境违规次数

*## parent firms' output/emission
merge 1:1 code year     using "$interm/parent_revenue.dta"  , keep(1 3) nogen //
merge 1:1 code year     using "$interm/pr_pollutants.dta"   , keep(1 3) nogen // 母公司周边污染物排放量
merge 1:1 code year     using "$interm/pr_co2_emis.dta"     , keep(1 3) nogen // 母公司周边污染物排放量



* City-level vars
merge m:1 cityname year using "$interm/pollutants.dta"    , keep(1 3) nogen
merge m:1 cityname      using "$interm/city_correlates_processed.dta", keep(1 3) nogen // 部分城市缺少数据


drop if popdensity == . 


* Matching vars
replace envvio = 0 if mi(envvio)
replace dist_mean = 0 if mi(dist_mean)

save "$interm/firm_panel_merged", replace 
* use "$processed/firm_reg_baseline.dta",clear



***EOF

