global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $processed


*****************************************
/* matching based on firm predetermined variables */
/*
global firmcorr "roa unitprof alr lnempl logast grev tobinq far age envvio dist_mean"
global citycorr "SO2 PM25 PM10 O3 NO2 popdensity gdpcapita indusoutput finrev finexp"
global parrev "totrev rev profit totprof netprof" 
use "$interm/firm_panel_merged",clear
*/

* ---------


*** 用来检测是否定义了相关的变量
if "$firmcorr" == "" {
    di as error "global firmcorr is not defined"
    exit 198
}

if "$pollutnt" == "" {
    di as error "global pollutnt is not defined"
    exit 198
}

if "$citycorr" == "" {
    di as error "global citycorr is not defined"
    exit 198
}

*** PSM
tempfile prior_invst
use code year stock_out firmnum_out if year >= 2010 & year <= 2013 using "$interm/firm_panel_merged",clear
collapse pre_stock_out = stock_out pre_fnum = firmnum_out, by(code)
save `prior_invst',replace


use code year in_key_areas $firmcorr $pollutnt $citycorr if year == 2010 using "$interm/firm_panel_merged",clear

	foreach covar in $firmcorr {
			rename `covar' firm_char_`covar'
	}

	foreach covar in $pollutnt {
			rename  `covar' pltn_char_`covar'
	}

	foreach covar in $citycorr {
			replace `covar' = log(`covar')
			rename  `covar' city_char_`covar'
	}
	drop year

	merge m:1 code using `prior_invst', keep(3) nogen
	*missings report firm_char_*
	local mvar "pre_stock_out pre_fnum firm_char_*"




* mean-diff: unbalanced
	ttable2 `mvar' , by(in_key_areas) 
	t2docx  firm_char_* ///
	 		using "$output/t_test_unbalanced.docx" , ///
			by(in_key_areas) fmt(%9.3f) replace


* Propensity Score Matching
	psmatch2 in_key_areas `mvar', logit neighbor(3) ties caliper(0.05) common
	pstest pre_stock_out firm_char_* 
	* keep if _support == 1


* standardized mean difference
preserve

	tempfile smddata
	postfile smd str20 varname smd_before smd_after using `smddata'

	foreach v of varlist `mvar'  {

	    * before matching
	    getsmd `v', treat(in_key_areas)
	    local b = r(smd)

	    * after matching
	    getsmd `v', treat(in_key_areas) weight(_weight)
	    local a = r(smd)

	    post smd ("`v'") (`b') (`a')
	}

	postclose smd
	use `smddata', clear

* Love plot
/*
	cap label drop covlab
	label define covlab ///
	    1 "ROA" ///
	    2 "Std. profit" ///
	    3 "Debt-to-Asset" ///
	    4 "(log) Employment" ///
	    5 "Rev. growth rate" ///
	    6 "Tobin's" ///
	    7 "Fixed asset ratio" ///
	    8 "Age" ///
	    9 "Mean distance" ///
	    10 "Tobin's Q" ///
	    11 "Asset"
*/
	cap gen id = _n
    label value id covlab

	labmask id,values(varname)
	levelsof id, clean local(ids) sep()
	twoway (scatter id smd_before, color(navy) msymbol(X) msize(*1.3)) ///
		   (scatter id smd_after,  color(maroon) msymbol(O) msize(*1.3)) ///
		   , ///
		   title("Covariate Balance", margin(medium) span) ///
		   xlabel(,nogrid) ///
		   ylabel(`ids', valuelabel nogrid angle(0)) /// glp(dash) glw(*1.5) glc(gs14%50)
		   xtitle("Standardized Mean Difference") ///
		   ytitle("") ///
		   xline(0, lc(gs2) lw(*1.5) lp(solid)) ///
		   xline(0.1, lc(blue) lw(*1.5) lp(dash)) ///
		   xline(-0.1, lc(blue) lw(*1.5) lp(dash)) ///
		   legend(order(1 "Unmatched" 2 "Matched") ///
		   		  title("Sample", size(*0.8)) ///
		   		  pos(3) row(2) ///
		   		  region(lw(*1.2) lp(solid) lc(black))) ///
		   name("balance_test", replace) ///
		   graphregion(color(white)) ///
		   plotregion(color(white)) ///
		   scheme(s1color)

	graph save "$output/covariate_balance.gph", replace // gph fomrat
	graph export "$output/covariate_balance.jpg", replace // gph fomrat

restore




* Balance Test Table
preserve

	cap postclose vr
	tempfile vrdata
	postfile vr str20 varname ///
			um_mean_t um_mean_c um_diff str3 um_siglvl um_vr str3 um_vr_siglvl ///
			mc_mean_t mc_mean_c mc_diff str3 mc_siglvl mc_vr str3 mc_vr_siglvl ///
			using `vrdata'

			foreach v of varlist `mvar' {

					*=== unmatched ===*

					* 均值检验
					qui: ttest `v', by(in_key_areas)
				    local um_mean_t = r(mu_2)
				    local um_mean_c = r(mu_1)
				    local um_pval   = r(p)
				    local um_diff = `um_mean_t' - `um_mean_c'

				    * 均值检验显著性星号
				    local um_siglvl ""
				    if      (`um_pval' < 0.01) local um_siglvl "***"
				    else if (`um_pval' < 0.05) local um_siglvl "**"
				    else if (`um_pval' < 0.10) local um_siglvl "*"

				    * 方差检验
				    qui: sdtest `v', by(in_key_areas)
				    local um_var_t = r(sd_2) // treatment
					local um_var_c = r(sd_1) // control
					local um_vr = `um_var_c' / `um_var_t'
					local um_sdt_p = r(p)

				    * 方差检验显著性
					local um_vr_siglvl ""
					if      (`um_sdt_p' < 0.01) local um_vr_siglvl "***"
					else if (`um_sdt_p' < 0.05) local um_vr_siglvl "**"
					else if (`um_sdt_p' < 0.10) local um_vr_siglvl "*"

				   

					*=== matched ===*
					qui: ttest `v' if _weight != ., by(in_key_areas)
				    local mc_mean_t = r(mu_2)
				    local mc_mean_c = r(mu_1)
				    local mc_pval   = r(p)
				    local mc_diff = `mc_mean_t' - `mc_mean_c'

				    * 均值检验显著性星号
				    local mc_siglvl ""
				    if      (`mc_pval' < 0.01) local mc_siglvl "***"
				    else if (`mc_pval' < 0.05) local mc_siglvl "**"
				    else if (`mc_pval' < 0.10) local mc_siglvl "*"

				    * 方差检验
				    qui: sdtest `v' if _weight != ., by(in_key_areas)
				    local mc_var_t = r(sd_2) // treatment
					local mc_var_c = r(sd_1) // control
					local mc_vr = `mc_var_c' / `mc_var_t'
					local mc_sdt_p = r(p)

				    * 方差检验显著性
					local mc_vr_siglvl ""
					if      (`mc_sdt_p' < 0.01) local mc_vr_siglvl "***"
					else if (`mc_sdt_p' < 0.05) local mc_vr_siglvl "**"
					else if (`mc_sdt_p' < 0.10) local mc_vr_siglvl "*"


					*=== 上传数据 ===*
				    post vr ///
				        ("`v'") ///
				        (`um_mean_t') (`um_mean_c') (`um_diff') ("`um_siglvl'") (`um_vr') ("`um_vr_siglvl'") ///
				        (`mc_mean_t') (`mc_mean_c') (`mc_diff') ("`mc_siglvl'") (`mc_vr') ("`mc_vr_siglvl'") ///
				           
			}

	postclose vr
	use `vrdata', clear

	gen um_diff_str = string(um_diff, "%9.3f") + um_siglvl
	gen mc_diff_str = string(mc_diff, "%9.3f") + mc_siglvl
	gen um_vr_str = string(um_vr, "%9.3f") + um_vr_siglvl
	gen mc_vr_str = string(mc_vr, "%9.3f") + mc_vr_siglvl
	drop *siglvl

	export excel using "$output/balance_test_table.xlsx", firstrow(variables) replace

restore





*
drop if _weight == . 
distinct code  
local allfirm `r(ndistinct)'
distinct code if in_key_areas == 1 & _weight != .
local treated `r(ndistinct)'
distinct code if in_key_areas == 0 
local control `r(ndistinct)'

di "匹配后共有`allfirm'家企业, 其中处理组`treated'家, 对照组`control'家"




	


* mean-diff: balanced

ttable2 `mvar'  , by(in_key_areas) 
t2docx  `mvar'    ///
		using "$output/t_test_balanced.docx" , ///
		by(in_key_areas) fmt(%9.3f) replace



keep code firm_char_* pltn_char_* city_char_* pre_* _pscore _treated _support _weight _id _n1 _nn _pdif
merge 1:m code using "$interm/firm_panel_merged.dta" , keep(3) nogen
*drop ttrvn revenue netprofit pprofit

