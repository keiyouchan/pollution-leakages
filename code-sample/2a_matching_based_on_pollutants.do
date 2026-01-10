global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $processed

clear all
* ---------------
/* matching based on city predetermined */
global citycorr "SO2 PM25 PM10 O3 NO2 popdensity gdpcapita indusoutput finrev finexp"
global citycorr_2010 "SO2_2010 PM25_2010 PM10_2010 O3_2010 NO2_2010 popdensity_2010 gdpcapita_2010 indusoutput_2010 finrev_2010 finexp_2010"
* ---------
use cityname year in_key_areas $citycorr if year == 2010 using "$processed/firm_reg_baseline.dta",clear
foreach covar in $citycorr {
		rename `covar' `covar'_2010
}
drop year
tempfile citycontrols_2010
save `citycontrols_2010', replace
duplicates drop cityname,force

psmatch2 in_key_areas $citycorr_2010, logit neighbor(3) ties caliper(0.05) common

merge 1:m cityname using "firm_reg_baseline.dta" , keep(3) nogen
duplicates drop cityname, force
keep if year == 2010
drop if _weight == . 

* mean-diff
ttable2 $citycorr , by(in_key_areas) 
t2docx  $citycorr  using "$output/t_test.docx" , ///
		by(in_key_areas) fmt(%9.2f) replace

keep  cityname *_2010 _pscore _treated _support _weight _id _n1 _nn _pdif
merge 1:m cityname using "firm_reg_baseline.dta" , keep(3) nogen
sort  code year cityname
order code year cityname

/* prepare for regression */

	* fiexed effects
	encode ind_2digit, gen(indusid)

	* static diff-in-diffs
	xtset code year
	gen treatment = in_key_areas
	gen policy = treatment * (year>=2014)

	* event study indicators
	gen nevertreated = (treatment == 0)
	gen policy_year = 2014
	gen K = year - policy_year

	forvalues l = 0/3 {
		gen L`l' = treatment * (K == `l')
	}
	forvalues l = 1/4 {
		gen F`l' = treatment * (K == -`l')
	}

	/* transform variables */

	* - winsorization
	local outcomes "stock_in netinc_in inc_in stock_out netinc_out inc_out"
	foreach outcome in `outcomes' {
			winsor2 `outcome', cut(1,99) replace
			summ `outcome'
	}
	* - 取对数 4
	foreach outcome in stock_in inc_in firmnum_in stock_out inc_out firmnum_out {
			gen ln`outcome' = log(1 + `outcome')
	}

	* - 除以资产滞后一期 6
	foreach outcome in stock_in netinc_in inc_in stock_out netinc_out inc_out {
			bys code (year): gen `outcome'_to_asset = `outcome' * 10000 / asset[_n - 1] if code == code[_n-1]
	}
	* - 改变量纲 6
	foreach outcome in stock_in netinc_in inc_in stock_out netinc_out inc_out {
			replace `outcome' = `outcome' / 10000
	}

	* city economic performance
	foreach citycorr in popdensity gdpcapita indusoutput finrev finexp {
			gen ln`citycorr'=log(`citycorr')
	}

	* firm financial performance
	gen lnasset_2010 = log(asset_2010)


	/* transform parent outputs */
	* winsorize
	foreach output in ttrvn revenue netprofit pprofit {
			winsor2 `output' , cut(1,99) replace
	}
	* rev / lag.asset
	foreach output in ttrvn revenue netprofit pprofit {
			bys code (year) :  gen `output'_to_ast = `output' / asset[_n - 1] if code == code[_n - 1]
	}
	* log transformation
	foreach output in ttrvn revenue  {
			gen   ln`output' =  log(1 + `output')
	}
	* scaled
	foreach output in ttrvn revenue netprofit pprofit {
			replace `output' = `output' / 100000000
	}
	

	sort code year
	order code year * *_2010
	save "$processed/firm_reg_balance.dta", replace 


* - End of file
