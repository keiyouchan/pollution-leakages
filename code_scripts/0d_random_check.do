global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm
* ---------------
preserve
egen group_id = group(subfirm)
gen random_uniform = mod(group_id * 12345, 10000) / 10000
sort random_uniform,stable

* 标记前 20 家企业
gen selected = (_n <= 50)  // 标记前 20 家企业
list subfirm random_uniform if selected == 1
bysort subfirm : egen max_selected = max(selected) 
* 筛选出前 20 家企业及其所有年份数据
keep if selected == 1
sort subfirm year

* 检查结果
list subfirm year random_uniform
restore

