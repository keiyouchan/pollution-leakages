global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
* ---------------
import excel using "母公司收入利润.xlsx" , firstrow sheet("Sheet2") clear
rename (证券代码 证券简称 营业总收入 营业收入 营业利润 利润总额 净利润 年份) ///
	   (code name totrev rev profit totprof netprof year)
destring code,replace 
drop name

save "$interm/parent_rev.dta",replace 
