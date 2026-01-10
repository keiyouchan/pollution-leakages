global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
* -------------------

use if inlist(年份,2010) using "$raw/city_correlates_raw", clear
gen str 市="市"
replace 地区=地区+市
keep 地区 年份 人口密度人平方公里 人均地区生产总值元 规模以上工业总产值当年价万元 地方财政一般预算内收入万元 地方财政一般预算内支出万元
rename 地区 cityname
rename 年份 year
rename 人口密度人平方公里 popdensity
rename 人均地区生产总值元 gdpcapita
rename 规模以上工业总产值当年价万元 indusoutput
rename 地方财政一般预算内收入万元 finrev
rename 地方财政一般预算内支出万元 finexp


* save
save "$interm/city_correlates_processed", replace


*** EOF