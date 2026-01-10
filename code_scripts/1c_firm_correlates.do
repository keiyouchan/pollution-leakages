global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

********************************************
*# 匹配变量
/*
use "$raw/basheet.dta",clear
merge 1:1 Stkcd Accper Typrep using "$raw/incomestat.dta", keep(3) nogen
merge 1:1 Stkcd Accper Typrep using "$raw/cashflow.dta"  , keep(3) nogen

gen code = Stkcd
gen datefmt = date(Accper,"YMD")
gen year = year(datefmt)
merge m:1 code year using "$raw/FirmBasicInfo.dta", keep(1 3) nogen 

save "$raw/firm_info_anarept.dta", replace 
*/

use "$raw/firm_info_anarept.dta", clear 
merge m:1 code year using "$raw/emplnum.dta" , keep(1 3) nogen 

keep if Typrep == "A" // 合并报表


rename Stkcd      code_str
rename ShortName  firmname
rename Accper     repdate
rename A001000000 totast
rename A001212000 fixast
rename A002000000 totdebt
rename A001218000 intgbast  // intangible asset
rename B001000000 totpft // total profit
rename B002000000 netpft // net profit
rename B001101000 revnue
rename B001100000 totrev


gen alr = totdebt / totast
gen roa = netpft  / totast
gen far = fixast  / totast
gen age = year - real(substr(EstablishDate,1,4))
gen tar = (totast - intgbast) / totast

gen lnast  = log(1 + totast)
gen lnempl = log(1 + emplnum)
gen lnrevn = log(1 + totrev)


label var alr    "Debt to Asset"
label var roa    "Return on Asset"
label var far    "Fixed asset ratio"
label var age    "Firm's age"
label var tar    "Tangible asset raio"
label var lnast  "log total asset"
label var lnempl "log no. empl"

keep code* year firmname repdate totast fixast totdebt intgbast totpft netpft revnue totrev alr roa far age tar lnast lnempl
duplicates drop code_str year, force 
destring code, replace 

* gen 滞后一期资产，利润
xtset code year
foreach var in totast totrev revnue {
		gen l_`var' = l.`var'
		label var l_`var' "滞后一期`var'"
}

save "$interm/firm_correlates.dta",replace

/*
use "$interm/firm_correlates.dta",clear
*/

*** EOF



*# 公司整体营业收入、利润
