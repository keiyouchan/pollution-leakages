global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline   "$output/baseline"
		global robust     "$output/robust"
		global hetero     "$output/hetero"
		global eventstudy "$output/eventstudy"	
		global mechanism  "$output/mechanism"

cd $processed

/* regression */
 * outcome variables
 global outcomes "stock_out netinc_out inc_out firmnum_out"
 	* HDFE model
 	global hdfe       "pair cityname recipient year provid#year"
 	global hdfe_dummy "pair cityname recipient year provid#year $citycorr"
 	global clusters   "pairid"
 *****************************************


use "$processed/three_dimens_panel.dta", clear

 * mechanism test
 foreach m in network {

 		 est clear

		 reghdfe stock_out i.policy##c.network if flowin_key == 0 , a($hdfe c.(pltn_char_*)#year) vce(cluster code cityid)
		 est sto network


 		 * output
 		 esttab network , ///
	 		 b(3) se(3) ar2(3) ///
	 		 keep(1.policy 1.policy#c.`m') ///
	 		 order(1.policy 1.policy#c.`m') ///
			 star(* 0.1 ** 0.05 *** 0.01) ///
			 compress nogaps replace

  		 * epxort to file
 		 esttab network using "$mechanism/mechanism_`m'.csv" , ///
	 		 b(3) se(3) ar2(3) ///
	 		 keep(1.policy 1.policy#c.`m') ///
	 		 order(1.policy 1.policy#c.`m') ///
			 star(* 0.1 ** 0.05 *** 0.01) ///
			 compress nogaps replace
 }

*** End of file


