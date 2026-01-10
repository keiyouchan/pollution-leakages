global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw



**************************

*** 手动查找的数据
tempfile supplement
run  "$scripts/0b2_preprocess_fill_missing_year.do"
save `supplement',replace


*** CSMAR数据
use "$raw/子公司主数据.dta", clear

gen    code_str = 证券代码
gen    code = 证券代码
rename 被投资单位 subfirm
rename 上市年份 ipoyear
rename 处理组 treatment
rename 纳税人识别号 taxid
rename 三区十群内的异地投资 in_key_dummy
rename 子公司大类代码 sindcd_2digit
rename 子公司中类代码 sindcd_3digit
rename 子公司行业门类 sindtype
rename 经营范围 business_scope
rename 上市日期 ipodate
rename 高耗能   eneint
rename 曾用名   oldname


rename 所属城市_r sub_cityname
rename 所属省份   sub_provname
rename 母公司办公地址所在城市 prt_cityname
rename 母公司办公地址所在省份 prt_provname


merge 1:1 subfirm year using "$interm/subfirm_revised_stock.dta", keep(3) nogen keepusing(stock netinc inc setup_year capi) // CSMAR 数据
merge m:1 code_str     using "$raw/pfirm_nic2017.dta"           , keep(1 3) nogen keepusing(pind*)  // 母公司国标行业分类
append using `supplement'                          // manual revise1
run "$scripts/0b3_preprocess_mannual_revise.do"    // manual revise2


drop A 证券代码 期末余额 期初余额 增减变动 本期增加 本期减少 国标行业* 
save "$raw/main_untuned.dta", replace 



*** EOF