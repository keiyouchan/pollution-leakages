/*

global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
*/
* -----------
* deal with changing name
egen unique_id = group(code taxid) if !missing(taxid) // taxid为纳税人识别号
duplicates list unique_id subfirm

* how many subfirms changing their name
qui:{
	bysort unique_id (subfirm): gen name_count = 1 if _n == 1
	bysort unique_id (subfirm): replace name_count = sum(name_count)
	bysort unique_id (subfirm): replace name_count = name_count[_N]

	gen renamed = name_count > 1
	egen total_renamed = total(renamed)
}
display "总共有 " total_renamed " 个子公司发生了更名"

* unify subfirms' name
bysort unique_id (year): gen standard_name = subfirm[1] if unique_id != .
bysort unique_id (year): replace subfirm = standard_name if unique_id != .


* - a subfirm in one year may exhibit two stocks, we keep stock bigger than 0 
bysort code subfirm year (stock): gen duplicate_flag = _n

* 标记要保留的记录
gen keep_flag = 0
bysort code subfirm year (stock): replace keep_flag = _n ==  _N // 未重复的全都为1，对于重复的企业，第一条为0，第二条甚至第三条为1，
bysort code subfirm year (stock): replace keep_flag = 1 if (stock != 0 & stock != .) // 防止缺失值的情况下，有数据的被删除
keep if keep_flag == 1
duplicates drop subfirm year,force

drop duplicate_flag keep_flag unique_id name_count total_renamed renamed standard_name