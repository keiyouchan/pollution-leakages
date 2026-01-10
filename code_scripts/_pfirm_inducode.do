global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
******************************************
/*
use using "FirmBasicInfo.dta", clear

gen code_str = code
rename IndustryName pinduname_origin
rename IndustryCode pinducode_origin
rename IndustryName1 pindnm_2digit
rename IndustryCode1 pindcd_2digit // 证监会行业分类
keep code* year pind*
*/

clear
tempfile mscode
input str6 code_str str6 pinducode_origin
"000155" "D4411" 
"000511" "C3099"
"000611" "B0391"
"000685" "C3985"
"000939" "M7499"
"002070" "F5100"
"002220" "C1371"
"002604" "C1340"
"002770" "C1524"
"300064" "C3099"
"600069" "C2210"
"600091" "F5169"
"600145" "L7212"
"600275" "A0412"
"600432" "B0913"
end
save `mscode',replace





import excel using "NIC2017.xlsx", firstrow clear sheet("Sheet1")
drop if 证券代码 == ""
gen code_str = substr(证券代码,1,6)

rename 所属国民经济行业分类交易日期最新收盘日行业级别一 pindtype
rename 所属国民经济行业分类交易日期最新收盘日行业级别二 pindnm_2digit
rename 所属国民经济行业分类交易日期最新收盘日行业级别三 pindnm_3digit
rename 所属国民经济行业分类交易日期最新收盘日行业级别四 pindnm_4digit
rename 所属国民经济行业代码交易日期最新收盘日行业级别一 pindcode 
rename 所属国民经济行业代码交易日期最新收盘日行业级别二 pindcd_2digit
rename 所属国民经济行业代码交易日期最新收盘日行业级别三 pindcd_3digit
rename 所属国民经济行业代码交易日期最新收盘日行业级别四 pindcd_4digit


* 填充缺失
gen pinducode_origin = pindcd_4digit
replace pinducode_origin = "D4411" if code_str == "000155"
replace pinducode_origin = "C3099" if code_str == "000511"
replace pinducode_origin = "B0391" if code_str == "000611"
replace pinducode_origin = "C3985" if code_str == "000685"
replace pinducode_origin = "M7499" if code_str == "000939"
replace pinducode_origin = "F5100" if code_str == "002070"
replace pinducode_origin = "C1371" if code_str == "002220"
replace pinducode_origin = "C1340" if code_str == "002604"
replace pinducode_origin = "C1524" if code_str == "002770"
replace pinducode_origin = "C3099" if code_str == "300064"
replace pinducode_origin = "C2210" if code_str == "600069"
replace pinducode_origin = "F5169" if code_str == "600091"
replace pinducode_origin = "L7212" if code_str == "600145"
replace pinducode_origin = "A0412" if code_str == "600275"
replace pinducode_origin = "B0913" if code_str == "600432"

replace pinducode_origin = "C1751" if code_str == "000158"
replace pinducode_origin = "D4430" if code_str == "000301"
replace pinducode_origin = "C1761" if code_str == "000611"
replace pinducode_origin = "D4411" if code_str == "000695"
replace pinducode_origin = "D4411" if code_str == "000720"
replace pinducode_origin = "C2614" if code_str == "000755"
replace pinducode_origin = "C1340" if code_str == "000833" // 制糖加造纸
replace pinducode_origin = "D4417" if code_str == "000939"
replace pinducode_origin = "C2632" if code_str == "000953"
replace pinducode_origin = "C2661" if code_str == "002010"
replace pinducode_origin = "C1721" if code_str == "002070"
replace pinducode_origin = "C3252" if code_str == "002082"
replace pinducode_origin = "C1329" if code_str == "002124"
replace pinducode_origin = "C1329" if code_str == "002157"
replace pinducode_origin = "C2221" if code_str == "002235"
replace pinducode_origin = "C2662" if code_str == "002453"
replace pinducode_origin = "C3393" if code_str == "002499"
replace pinducode_origin = "C2662" if code_str == "002562"
replace pinducode_origin = "C3120" if code_str == "002591"
replace pinducode_origin = "C1711" if code_str == "002761"
replace pinducode_origin = "C1441" if code_str == "002770"
replace pinducode_origin = "C1340" if code_str == "300149"
replace pinducode_origin = "C2642" if code_str == "300192"
replace pinducode_origin = "C2643" if code_str == "300234"
replace pinducode_origin = "C3021" if code_str == "300344"
replace pinducode_origin = "C2661" if code_str == "300381"
replace pinducode_origin = "C3240" if code_str == "300428"
replace pinducode_origin = "C2613" if code_str == "300459"
replace pinducode_origin = "C2521" if code_str == "600091"
replace pinducode_origin = "C1314" if code_str == "600095"
replace pinducode_origin = "C4413" if code_str == "600131"
replace pinducode_origin = "C3072" if code_str == "600145"
replace pinducode_origin = "C2614" if code_str == "600228"
replace pinducode_origin = "A0411" if code_str == "600275"
replace pinducode_origin = "C2521" if code_str == "600281"
replace pinducode_origin = "C3041" if code_str == "600293"
replace pinducode_origin = "C3110" if code_str == "600399"
replace pinducode_origin = "C3213" if code_str == "600432"
replace pinducode_origin = "C2631" if code_str == "600538"
replace pinducode_origin = "C3011" if code_str == "600539"
replace pinducode_origin = "C2651" if code_str == "600636"
replace pinducode_origin = "C2631" if code_str == "600803"
replace pinducode_origin = "C3110" if code_str == "600808"
replace pinducode_origin = "D4430" if code_str == "600864"
replace pinducode_origin = "C2671" if code_str == "600985"
replace pinducode_origin = "C3130" if code_str == "601005"
replace pinducode_origin = "C3219" if code_str == "601012"
replace pinducode_origin = "C2651" if code_str == "603002"
replace pinducode_origin = "C1830" if code_str == "603558"
* replace pinducode_origin = "" if code_str == "601952" // 2017 IPO
* replace pinducode_origin = "" if code_str == "603305" // 2017 IPO

append using `mscode'
replace pindcd_4digit = substr(pinducode_origin,1,5)
replace pindcd_3digit = substr(pinducode_origin,1,4)
replace pindcd_2digit = substr(pinducode_origin,1,3)
replace pindcode = substr(pinducode_origin,1,1)
keep code_str pindcode* pindcd*
duplicates drop code_str pindcode,force



save $raw/pfirm_nic2017.dta,replace 
use $raw/pfirm_nic2017.dta ,clear



****************************************
use "$raw/子公司主数据.dta",replace
gen code_str = 证券代码
merge m:1 code_str  using "$raw/pfirm_nic2017.dta", keep(1 3) nogen keepusing(pind*)

keep if pindcd_2digit != 母公司行业大类代码
keep  code_str year 母公司行业大类代码 pindcd* 子公司*
order code_str year 母公司行业大类代码 pindcd* 子公司*
sort  code_str year 

duplicates drop code_str year 母公司行业大类代码 pindcd_2digit,force

* manual revise

gen pinducode_origin = pindcd_4digit
levelsof code_str if pinducode_origin == "", clean sep() local(mslst)

* 填充缺失
replace pinducode_origin = "D4411" if code_str == "000155"
replace pinducode_origin = "C3099" if code_str == "000511"
replace pinducode_origin = "B0391" if code_str == "000611"
replace pinducode_origin = "C3985" if code_str == "000685"
replace pinducode_origin = "M7499" if code_str == "000939"
replace pinducode_origin = "F5100" if code_str == "002070"
replace pinducode_origin = "C1371" if code_str == "002220"
replace pinducode_origin = "C1340" if code_str == "002604"
replace pinducode_origin = "C1524" if code_str == "002770"
replace pinducode_origin = "C3099" if code_str == "300064"
replace pinducode_origin = "C2210" if code_str == "600069"
replace pinducode_origin = "F5169" if code_str == "600091"
replace pinducode_origin = "L7212" if code_str == "600145"
replace pinducode_origin = "A0412" if code_str == "600275"
replace pinducode_origin = "B0913" if code_str == "600432"

/* 查看和raw数据不一样行业2位代码的公司
cap drop mindcd_2temp
gen mindcd_2temp = substr(pinducode_origin,1,3)
keep if mindcd_2temp != 母公司行业大类代码

levelsof code_str ///
	if !inlist(mindcd_2temp, "C13","C14","C17","C19") ///
	 & !inlist(mindcd_2temp,"C22","C25","C26","C30","C31","C32","D44") ///
	,clean sep() local(mslst)
foreach fm in `mslst' {
		di "`fm'"
}
*/
replace pinducode_origin = "C1751" if code_str == "000158"
replace pinducode_origin = "D4430" if code_str == "000301"
replace pinducode_origin = "C1761" if code_str == "000611"
replace pinducode_origin = "D4411" if code_str == "000695"
replace pinducode_origin = "D4411" if code_str == "000720"
replace pinducode_origin = "C2614" if code_str == "000755"
replace pinducode_origin = "C1340" if code_str == "000833" // 制糖加造纸
replace pinducode_origin = "D4417" if code_str == "000939"
replace pinducode_origin = "C2632" if code_str == "000953"
replace pinducode_origin = "C2661" if code_str == "002010"
replace pinducode_origin = "C1721" if code_str == "002070"
replace pinducode_origin = "C3252" if code_str == "002082"
replace pinducode_origin = "C1329" if code_str == "002124"
replace pinducode_origin = "C1329" if code_str == "002157"
replace pinducode_origin = "C2221" if code_str == "002235"
replace pinducode_origin = "C2662" if code_str == "002453"
replace pinducode_origin = "C3393" if code_str == "002499"
replace pinducode_origin = "C2662" if code_str == "002562"
replace pinducode_origin = "C3120" if code_str == "002591"
replace pinducode_origin = "C1711" if code_str == "002761"
replace pinducode_origin = "C1441" if code_str == "002770"
replace pinducode_origin = "C1340" if code_str == "300149"
replace pinducode_origin = "C2642" if code_str == "300192"
replace pinducode_origin = "C2643" if code_str == "300234"
replace pinducode_origin = "C3021" if code_str == "300344"
replace pinducode_origin = "C2661" if code_str == "300381"
replace pinducode_origin = "C3240" if code_str == "300428"
replace pinducode_origin = "C2613" if code_str == "300459"
replace pinducode_origin = "C2521" if code_str == "600091"
replace pinducode_origin = "C1314" if code_str == "600095"
replace pinducode_origin = "C4413" if code_str == "600131"
replace pinducode_origin = "C3072" if code_str == "600145"
replace pinducode_origin = "C2614" if code_str == "600228"
replace pinducode_origin = "A0411" if code_str == "600275"
replace pinducode_origin = "C2521" if code_str == "600281"
replace pinducode_origin = "C3041" if code_str == "600293"
replace pinducode_origin = "C3110" if code_str == "600399"
replace pinducode_origin = "C3213" if code_str == "600432"
replace pinducode_origin = "C2631" if code_str == "600538"
replace pinducode_origin = "C3011" if code_str == "600539"
replace pinducode_origin = "C2651" if code_str == "600636"
replace pinducode_origin = "C2631" if code_str == "600803"
replace pinducode_origin = "C3110" if code_str == "600808"
replace pinducode_origin = "D4430" if code_str == "600864"
replace pinducode_origin = "C2671" if code_str == "600985"
replace pinducode_origin = "C3130" if code_str == "601005"
replace pinducode_origin = "C3219" if code_str == "601012"
* replace pinducode_origin = "" if code_str == "601952" // 2017 IPO
replace pinducode_origin = "C2651" if code_str == "603002"
* replace pinducode_origin = "" if code_str == "603305" // 2017 IPO
replace pinducode_origin = "C1830" if code_str == "603558"


cap drop mindcd_2temp
gen mindcd_2temp = substr(pinducode_origin,1,3)

levelsof code_str ///
	if !inlist(mindcd_2temp, "C13","C14","C17","C19") ///
	 & !inlist(mindcd_2temp, "C22","C25","C26","C30","C31","C32","D44") ///
	 & mindcd_2temp != 母公司行业大类代码 ///
	,clean sep() local(mslst)
foreach fm in `mslst' {
		di "`fm'"
}



keep code_str year
save "$interm/nic_dict.dta",replace

/*
abnormal
000546










