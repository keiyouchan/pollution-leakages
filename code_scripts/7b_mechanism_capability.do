global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline "$output/baseline"
		global eventstudy "$output/eventstudy"	

cd $processed
* -----------------
/* main setting */
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out"
	* HDFE model
	global hdfe  "code year provid#year indusid#year"
	global hdfes "code year provid#year indusid#year $citycorr"
	global clusters   "cityid"

* -----------
cap program drop mec_innov
program mec_innov
		version 18 
		syntax, year_l(real) year_r(real)



		use "$interm/rd_expense.dta", clear  // cnrds database
		destring 股票代码, gen(code)
		destring 会计年度, gen(year)
		destring 研发人员数量, gen(rd_empl)
		destring 研发支出, gen(rd_expense)

		gen rd_emplr = real(subinstr(研发人员数量占比, "%", "", .))
		gen rd_ratio = real(subinstr(研发支出占营业收入比例, "%", "", .))
		keep 股票代码 code year rd_expense rd_ratio rd_empl rd_emplr
		keep if year >= `year_l' & year <= `year_r'
		collapse rd_expense rd_ratio rd_empl rd_emplr, by(code)
		tempfile rd
		save    `rd', replace


		* use code year 研发* if year >= 2010 & year <= 2013 using "$raw/firm_correlates_raw.dta",clear 


		* merge to firm balance
		use "$processed/firm_reg_balance.dta" , clear
		merge m:1 code using `rd' , keep(1 3) nogen

		*- mechanism test
		foreach m in rd_ratio {

		 		 est clear

				 reghdfe stock_out policy##c.`m', a($hdfe c.(pltn_char_*)#year) vce(cluster code)
				 est sto rd


		 		 * output
		 		 esttab rd, ///
		 		 b(3) se(3) ar2(3) ///
		 		 keep(1.policy 1.policy#c.`m') ///
		 		 order(1.policy 1.policy#c.`m') ///
				 star(* 0.1 ** 0.05 *** 0.01) ///
				 compress nogaps replace

				 * epxort to file
 		 		 esttab rd using "$mechanism/mechanism_`m'_2013.csv" , ///
		 		 b(3) se(3) ar2(3) ///
		 		 keep(1.policy 1.policy#c.`m') ///
		 		 order(1.policy 1.policy#c.`m') ///
				 star(* 0.1 ** 0.05 *** 0.01) ///
				 compress nogaps replace
		 }

end 

* mec_innov, year_l(2010) year_r(2013)

/*
 /*- use R&D in 2012 as m */
 use "$interm/rd2012.dta" , clear
 rename 证券代码 code
 destring code, replace 
 drop year
 tempfile rd
 save `rd'  ,replace 

 *- merge to firm balance
 use "$processed/firm_reg_balance.dta" , clear
 merge m:1 code using `rd' , keep(1 3) nogen
 gen   post = year >= 2014
 replace prdexps = prdexps * 100

 *- mechanism test
 foreach m in prdexps {

 		 est clear

 		 reghdfe stock_out i.policy##c.`m' $model3  , a($hdfe) vce(cluster $clusters)
 		 est sto m3
 		 reghdfe stock_out i.policy##c.`m' $model4  , a($hdfe) vce(cluster $clusters)
 		 est sto m4
 		 reghdfe stock_out i.policy##c.`m'          , a($hdfes) vce(cluster $clusters)
 		 est sto m5


 		 * output
 		 esttab m3 m4 m5 ///
 		 using "$mechanism/mechanism_`m'_2012.csv" , ///
 		 b(4) se(4) ///
 		 keep(1.policy 1.policy#c.`m') order(1.policy 1.policy#c.`m') ///
		 r2(4) star(* 0.1 ** 0.05 *** 0.01) replace
 }


*** End of file
