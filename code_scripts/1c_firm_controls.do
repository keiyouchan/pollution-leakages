global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

* processing financial contorl variables for firms
* --------------
use "$raw/firm_controls_raw.dta",clear 
local controls "age ROA_op 单位净利润_op 资产负债率_op 净资产收益率_op far 应付职工薪酬_op 产权比率_op ln员工总数_op ln企业规模_op 营业收入同比增长率_op 总资产_op TobinQ_op shr1_op shr3_op shr5_op shr10_op"
local outputs "ttrvn revenue netprofit pprofit"
keep code year `controls' `outputs'


rename (单位净利润_op 资产负债率_op ROA_op 净资产收益率_op 应付职工薪酬_op 产权比率_op ln员工总数_op ln企业规模_op 营业收入同比增长率_op 总资产_op ) ///
	   (unitprof alr roa roe payment equityr lnempl lnscale grev asset)
rename (TobinQ_op shr1_op shr3_op shr5_op shr10_op) (tobinq shr1 shr3 shr5 shr10)


label var unitprof  "单位净利润"
label var alr       "资产负债率"
label var roa       "总资产收益率"
label var roe       "净资产收益率"
label var payment   "应付职工薪酬"
label var equityr   "产权比率"
label var lnempl    "ln员工总数"
label var lnscale   "ln企业规模"
label var grev      "营业收入同比增长率"
label var asset     "总资产"
label var shr1      "前1大股东持股比例"
label var far       "固定资产比总资产"

save "$interm/firm_controls.dta",replace

***EOF