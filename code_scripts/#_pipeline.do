global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline  "$output/baseline"
		global robust    "$output/robustness"
		global mechanism "$output/mechanism"


cd $interm

* --------------------
/* compile all scripts */

* data preprocessing
	
	* define program
	run "$scripts/progSettings.do"


	* run "$scripts/0a_preprocess_replace_stock.do"
	run "$scripts/0_get_main_data.do"


	* 微调数据
	run "$scripts/0a_fine_tune.do"

	use "$raw/main.dta",replace
		get_inv_leak, digit(2)           // 筛选 investment leakages


	run "$scripts/0b1_preprocess_fill_missing_stock.do"  // 填充缺失
		* run 0b2_preprocess_fill_missing_year.do
		* run 0b3_preprocess_mannual_revise.do


	run "$scripts/0b4_expand_sample.do" // 构造平衡面板
	* Fine tune
		/*	
		fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year >= 2014") v(1.12)		
		fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year == 2013") v(0.83)
		fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year == 2012") v(0.85)
		fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year == 2011") v(1)
		fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year == 2010") v(1.6)
		*/

		getinvflow

		save "$interm/subfirm_stock_expanded.dta",replace


* construct firm panel and combine dataset
	run "$scripts/1a_construct_firm_panel.do" // firm panel with 422 firms

		*********************************************
		construct_firm_panel, trim_year(2010)
		tempfile firm_balance_panel
		save `firm_balance_panel',replace

		aggregate_outcome
		tempfile in_out_key
		save `in_out_key',replace


		use `firm_balance_panel', clear
		merge 1:1 code year using `in_out_key', keep(1 3) nogen
		save "$interm/firm_panel.dta",replace 
		*********************************************

		/*
		/* 处理企业和地区层面变量: 不运行 */
		run "$scripts/1b_city_corr.do"
		run "$scripts/1c_firm_char.do"
		run "$scripts/1c_firm_controls.do"
		run "$scripts/1c_firm_env_violation.do"
		run "$scripts/1c_firm_geo_pattern.do"
		run "$scripts/1d_pollutants.do"
		run "$scripts/1e_parent_emission.do"
		*/

	run "$scripts/1z_combine_dataset.do"


*# Prepare for regression
	global firmcorr "age roa far lnempl lnast lnrevn envvio" // 
	global pollutnt "SO2 PM25" // PM10 O3 NO2
	global citycorr "gdpcapita indusoutput finrev" // finexp  popdensity
	global parrev   "pf_totrev pf_revenue"

	run "$scripts/2a_psmatching.do"
	run "$scripts/2b_prepare_for_regression.do"

*# regression

	*## investment
	run "$scripts/3_reg_baseline.do"

		/* baseline */
		reg_base stock_out, saving("$baseline/basline.csv")
		/*
		reghdfe stock_out policy, a($hdfe c.(pltn_char_*)#year) vce(cluster citycode)
		reghdfe stock_out policy, a($hdfe c.(pltn_char_*)#year c.pre_stock_out#year) vce(cluster citycode)
		reghdfe stock_out F1-F4 L0-L3, a($hdfe c.(pltn_char_*)#year c.pre_stock_out#year) vce(cluster citycode)
		*/

		* economic significance
		qui: reg_rbs_spec stock_out, spec(flex)
		local b = _b[policy]
		qui: summ stock_out if treatment == 0
		summ  pf_totast if year <= 2013
		local mean_c = r(mean) / 100
		local es = `b' / `mean_c' * 100

		di "经济显著性为:" %6.2f `es' "%"


		*reghdfe stock_out policy, a($hdfe c.(pltn_char_*)#year c.(city_char_*)#year) vce(cluster citycode)
		*reghdfe stock_out F1-F4 L0-L3 , a($hdfe c.(pltn_char_*)#year c.(city_char_*)#year)  vce(cluster citycode) noconstant
		/* para. trends */

		* - event-study
		reg_esplot stock_out, save("$robust/pretrend_test.png")
		test F2 F3 F4    // joint-sig.

		*reg_esplot pf_lntminv     // 长期股权投资
		*reg_esplot inv_to_rev
		reg_esplot inc_out, cond(year >= 2011) 

		* - joint-sig.
		* qui: reg_esplot stock_out
		


*# Robustness checks
	
	/* alternative spec */
		run "$scripts/3_reg_baseline.do"

			*# investment
			reg_rbs_spec inc_out, spec(flex) cond(year >= 2011) 

			reg_rbs_spec inv_to_ast,  spec(flex)     // unit stock investment 
			reg_rbs_spec inv_to_rev,  spec(flex)
			reg_rbs_spec firmnum_out, spec(flex)
			*ppmlhdfe firmnum_out policy , a($hdfe)  vce(cluster citycode) noconstant


			*# parent output
			*run "$scripts/4a_parent_output.do"
			reg_rbs_spec lnpf_totrev, spec(flex)  // parent revenue

			reg_rbs_spec co2,   spec(flex)            // surounding co2
			reg_rbs_spec lnco2, spec(flex)            // surounding co2 (log-form)
			reg_rbs_spec so2,   spec(flex)            // surounding SO2
			*reg_esplot so2
			reg_rbs_spec pm25, spec(flex)           // surounding pm2.5
			*reg_esplot pm25


	/* spillover-robust */
		run "$scripts/5a1_robust_spillover_preparation.do"
		run "$scripts/5a2_robust_spillover_main.do"
			reg_rbs_splovr stock_out, binwid(20) maxdist(120) save("$robust/robust_spillover.csv") // binwidth = 20, maxdistance = 120


	/* alternative std. error clst */
		reg_rbs_spec stock_out, spec(flex)  // preferred spec

		reg_rbs_spec stock_out, spec(flex) clst(provcode)          // provcine-level
		reg_rbs_spec stock_out, spec(flex) clst(citycode provcode) // two way clustering

	/* rule out anticipation */
		run "$scripts/5c_robust_anticipation.do"
			reg_rbs_anticip, yrlead(1) // 1 year lead
			reg_rbs_anticip, yrlead(2) // 2 year lead


	/* rule out competitive policies */
		run "$scripts/5d_robust_ruleout_policy.do"
			reg_rbs_excpolicy

	/* city-pair panel */
		do "$scripts/5f_robust_city_panel.do"

*# Further Discussion

	/* sub-treatment effects */
		do "$scripts/6a_hetero_target.do"
		run "$scripts/6b_pretreat_pollut.do"

	/* construct 3-d panel */
		run "$scripts/7#_construct_three_dimens_panel.do"


*# Mechanism 
	/* industrial agglomeration */
		do "$scripts/7a1_mechanism_ind_agg.do"

	/* transportation */
		do "$scripts/7a2_mechanism_transport.do"

	/* established network */
		do "$scripts/7a3_mechanism_network.do"

	/* innovation */
		run "$scripts/7b_mechanism_capability.do"
			mec_innov, year_l(2010) year_r(2013)
			


*# Destination
	
	*## provincial pattern
		run "$scripts/8a1_destination_prov.do"  // seperate regression
		*run "$scripts/8a2_destination_prov_map.do"

	*## distance pattern
		run "$scripts/8b1_desitnation_creat_3ddist.do" // create firm-distance-year panel
		run "$scripts/8b2_destination_dist.do"         // seperate regression






