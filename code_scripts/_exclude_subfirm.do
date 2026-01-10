global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $processed
******************************************
*** 剔除控股子公司
****************
use "$raw/FN_Fn061.dta", clear
append using "$raw/FN_Fn0611.dta"  


rename Stkcd      code_str
rename EndDate    repdate
rename FN_Fn06101 subfirm
rename FN_Fn06102 estdate
rename FN_Fn06103 capi
rename FN_Fn06104 business
rename FN_Fn06105 regiloc
rename FN_Fn06106 country
rename FN_Fn06107 region
rename FN_Fn06108 esttype
rename FN_Fn06109 d_stkshr
rename FN_Fn06110 id_stkshr
rename FN_Fn06111 sf_totast
rename FN_Fn06112 revenue
rename FN_Fn06113 netpft
rename FN_Fn06114 pft2parent
rename FN_Fn06115 investment
rename FN_Fn06116 currency
rename FN_Fn06117 logout

keep if regexm(repdate,"12-31")
gen code = code_str
gen year = year(date(repdate, "YMD"))
gen estbyear = year(date(estdate,"YMD"))

label var year "年份"
label var estbyear "成立年份"

save "$raw/subfirm_info.dta", replace 


***
/*
use "$raw/subfirm_info.dta", clear 
order code subfirm year 
sort  code subfirm year 
duplicates list code subfirm year 








