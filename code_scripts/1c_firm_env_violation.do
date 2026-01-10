global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

***********************************
/* Environment Violation */
import excel using "$raw/上市公司环保处罚数据.xlsx", sheet("Sheet1") firstrow clear

	ren 股票代码 code_str
	ren 年份 year
	ren 股票简称 name
	ren 省份 provname
	ren 城市 cityname
	ren 区县 cntyname
	ren 省份代码 provcode
	ren 城市代码 citycode
	ren 区县代码 cntycode
	ren 是否有过环保处罚 envvio
	ren 环保处罚次数 viotimes
	ren 环保统计截止日期 enddate

	save "$raw/env_violation.dta" , replace 


***********************************
*** EOF












