global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm

************************************
/* assuming our subfirm data is correctly set */

*** 生成一个干净的panel data

cap program drop construct_firm_panel
program construct_firm_panel
		version 18
		syntax , [trim_year(string)]

		if "`trim_year'" == "" local trim_year = 2010


		*======= create firm list =======*
		tempfile allfirms 
		use "$raw/main.dta", replace
		keep if ipoyear <= real("`trim_year'")
		duplicates drop code, force 
		keep code ipoyear
		save `allfirms',replace // 422 firms

		*======= create year list =======*
		tempfile yrlst
		clear 
		set obs 8
		gen year = _n
		replace year = year + 2009
		save `yrlst',replace


		*======= create balance panel =======*
		use `allfirms', clear
		cross using `yrlst'
		gen code_str = code 
		destring code , replace

		qui: distinct code 
		dis "一共有`r(ndistinct)'家公司"
end 


*** 将投资数据中加总

cap program drop aggregate_outcome
program aggregate_outcome
		version 18
		syntax, []



		*======= aggregate outcome =======*

		use  "$interm/subfirm_stock_expanded.dta",replace
		* inside key areas
		preserve

			sort code  year
			keep if in_key_dummy == 1
			local outcome stock netinc inc
			foreach y in `outcome'{
				egen `y'_in = sum(`y') , by(code year)
			}
			egen firmnum_in = count(subfirm) , by(code year)

			collapse (first) stock_in netinc_in inc_in firmnum_in , by(code year)
			tempfile inkey
			save `inkey', replace

		restore

		* outsdie key areas
		preserve

			keep if in_key_dummy == 0
			local outcome stock netinc inc
			foreach y in `outcome'{
				egen `y'_out = sum(`y') , by(code year)
			}
			egen firmnum_out = count(subfirm) , by(code year)

			collapse (first) stock_out netinc_out inc_out firmnum_out , by(code year)
			tempfile outkey
			save `outkey', replace

		restore


		* merge inside and outside key areas
		use `inkey', clear
		merge 1:1 code year using `outkey', keep(1 2 3) nogen


		/* extend panel */
		gen code_str = code 
		destring code , replace
		sort  code year
		xtset code year 

		label var stock_in    "在三区十群内的期末投资总额"
		label var stock_out   "在三区十群外的期末投资总额"
		label var netinc_in   "在三区十群内的投资净额"
		label var netinc_out  "在三区十群外的投资净额"
		label var inc_in      "在三区十群内的当期投资增加额"
		label var inc_out     "在三区十群外的当期投资增加额"
		label var firmnum_in  "在三区十群内的子公司数量"
		label var firmnum_out "在三区十群内的子公司数量"

end 



/*********************************************
construct_firm_panel, trim_year(2012)
tempfile firm_balance_panel
save `firm_balance_panel',replace

aggregate_outcome
tempfile in_out_key
save `in_out_key',replace


use `firm_balance_panel', clear
merge 1:1 code year using `in_out_key' , keep(1 3) nogen



* save data
save "$interm/firm_panel.dta",replace 
/*********************************************/


***EOF



