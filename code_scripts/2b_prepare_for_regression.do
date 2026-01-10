global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $processed

**********************************************

* replace pollutants by their values in 2010
/*
foreach pol in SO2 PM25 PM10 O3 NO2 {
		replace `pol' = city_char_`pol'
		*drop    city_char_`pol'
}
*/
/* prepare for regression */

	* fixed effects
	encode ind_2digit, gen(indusid)

	* static diff-in-diffs
	xtset code year
	gen   treatment = in_key_areas
	gen   policy    = treatment * (year>=2014)

	* event study indicators
	gen nevertreated = (treatment == 0)
	gen policy_year = 2014
	gen post = year >= 2014
	gen K = year - policy_year

	forvalues l = 0/3 {
		gen L`l' = treatment * (K == `l')
	}
	forvalues l = 1/4 {
		gen F`l' = treatment * (K == -`l')
	}
	replace F1=0

	
	/* transform variables */

	* - winsorization
	local outcomes "stock_in netinc_in inc_in stock_out netinc_out inc_out firmnum_in firmnum_out"
	foreach outcome in `outcomes' {
			winsor2 `outcome', cut(1,99) replace
			summ `outcome'
	}

	* - 除以资产滞后一期 
	foreach outcome in stock_in netinc_in inc_in stock_out netinc_out inc_out {
			gen `outcome'_to_ast = `outcome' * 10000 / l_totast
			gen `outcome'_to_rev = `outcome' * 10000 / l_totrev
	}

	* - 改变 Y 量纲
	foreach outcome in stock_in netinc_in inc_in stock_out netinc_out inc_out {
			replace `outcome' = `outcome' / 10000
	}

	* - unit investment
	bys code (year): gen inv_to_ast = stock_out * 100000000 / totast[1]
	bys code (year): gen inv_to_rev = stock_out * 100000000 / totrev[1]


	* city economic performance
	foreach citycorr in popdensity gdpcapita indusoutput finrev finexp {
			gen ln`citycorr'=log(`citycorr')
	}




	/* transform Parent outputs */

	* winsorize
	foreach output in pf_* {
			winsor2 `output' , cut(1,99) replace
	}
	* rev / lag.asset
	foreach output of varlist pf_* {
			gen `output'_to_ast = `output' / l_totast 
	}
	* log transformation
	foreach output of varlist pf_*  {

			replace `output' = `output' / 1000000
			gen   ln`output' =  log(1 + `output')
	}

	sort code year
	order code year firm_char_* city_char_*
	save "$processed/firm_reg_balance.dta", replace 



* - End of file
/*
/* matching based on firm predetermined variables */
global firmcorr "roa unitprof alr lnempl logast grev tobinq far age envvio dist_mean"
global firmcorr_2010 "roa_2010 unitprof_2010 alr_2010 lnempl_2010 logast grev_2010 tobinq_2010 far_2010 age_2010 envvio_2010 dist_mean_2010" // correlates vars

global citycorr "SO2 PM25 PM10 O3 NO2 popdensity gdpcapita indusoutput finrev finexp"
global citycorr_2010 "SO2_2010 PM25_2010 PM10_2010 O3_2010 NO2_2010 popdensity_2010 gdpcapita_2010 indusoutput_2010 finrev_2010 finexp_2010"

global parrev "totrev rev profit totprof netprof"
* ---------
use code year in_key_areas $firmcorr $citycorr if year == 2010 using "$processed/firm_reg_baseline.dta",clear

	foreach covar in $firmcorr {
		rename `covar' `covar'_2010
	}
	foreach covar in $citycorr {
		rename `covar' `covar'_2010
	}
	drop year

	missings report $firmcorr_2010


* mean-diff: unbalanced
	t2docx  $firmcorr_2010 ///
	 		using "$output/t_test_unbalanced.docx" , ///
			by(in_key_areas) fmt(%9.3f) replace

	cap drop payment_2010_scaled asset_2010_scaled


* Propensity Score Matching
	missings report $firmcorr_2010
	psmatch2 in_key_areas $firmcorr_2010, logit neighbor(3) ties caliper(0.05) common
	drop if _weight == . 

	* keep if _support == 1
	* merge 1:m code using "firm_reg_baseline.dta" , keep(3) nogen // 为每个公司匹配权重
	* keep if year == 2010
	


* mean-diff: balanced
	ttable2 $firmcorr_2010  , by(in_key_areas) 
	t2docx  $firmcorr_2010   ///
			using "$output/t_test_balanced.docx" , ///
			by(in_key_areas) fmt(%9.3f) replace



keep code *_2010 _pscore _treated _support _weight _id _n1 _nn _pdif
merge 1:m code using "firm_reg_baseline.dta" , keep(3) nogen
drop ttrvn revenue netprofit pprofit


*/


