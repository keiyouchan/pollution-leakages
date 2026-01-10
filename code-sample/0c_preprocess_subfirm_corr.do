global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

*************************************
use "$raw/子公司基本信息.dta",clear
rename (股票代码 参控股公司名称 经营状态 成立日期 企业地址) (code subfirm operation setup loc)
keep code subfirm operation setup loc
sort subfirm
gen subfirm_clean = subinstr(subinstr(subfirm, "（", "(", .), "）", ")", .)

gen date_num = date(setup, "YMD")  
format date_num %td  
gen setup_year = year(date_num)
drop date_num

qui:{
	foreach i of varlist _all{
		cap format `i' %10s
		cap format `i' %9.2f
	}
	duplicates report subfirm //
	duplicates report code subfirm // 没有code 和 subfirm同时重复的，说明一家子公司可能由多家母公司有关联
}

tempfile subinfo1
save `subinfo1',replace

* ------------------
/* 控股公司关系 */
use "$raw/子公司基本信息2.dta",clear
rename (股票代码 会计年度 参控股公司名称 参控关系 参控比例 被参控股公司注册资本 货币单位) (code year subfirm relation stk capital currency)
keep code year subfirm relation stk capital currency

gen subfirm_clean = subinstr(subinstr(subfirm, "（", "(", .), "）", ")", .)
gen capi = regexs(1) if regexm(capital, "([0-9\.]+)")
destring capi , replace
duplicates drop code subfirm_clean, force



tempfile relation
save `relation',replace

* merge 
use `subinfo1',clear
merge 1:1 code subfirm_clean using `relation', keepusing(relation capi currency) keep(3) nogen

qui{
	foreach i of varlist _all{
		
			cap format `i' %10s
			cap format `i' %9.2f
	}
}

drop subfirm
rename subfirm_clean subfirm

label var subfirm 被投资单位
label var setup_year 成立年份
label var capi "注册资本(万元)"

save "$interm/subfirm_corr.dta",replace










