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
		global destin     "$output/destination"

cd $processed

/* Destination: Province */
 * outcome variables
 global outcomes "stock_out netinc_out inc_out firmnum_out"
 	* HDFE model
 	global hdfe       "pair code recipient#year year provid#year indusid#year"
 	global clusters   "cityid"
 

 * ----------------
 
 use sub_cityname sub_provname using "$raw/main.dta",clear
 rename (sub_cityname sub_provname) (recipient reciprov)
 duplicates drop recipient , force 
 tempfile reciprov
 save    `reciprov' , replace

 use "$processed/three_dimens_panel.dta", clear
 merge m:1 recipient using `reciprov' , keep(1 3) nogen
 
* ----------------
/* gen province indicators */
tab reciprov , gen(prov_)
gen policy3  = in_3regions   * (year >= 2014)
gen policy10 = in_10clusters * (year >= 2014)
drop if reciprov == ""
drop    prov_1 prov_4 prov_7 prov_28 // drop 直辖市



***********************************************
*- consider beta for policy3 and policy10

cap matrix drop coef
matrix coef = J(1,6,.) // coef lb ub prov plot_area pval
levelsof reciprov, local(rplst)
local i = 0
foreach p in `rplst' {

		local i = `i' + 1
		display "-------- `i' --------"

		if !inlist("`p'", "北京市","天津市","上海市","重庆市") {


			display " *** 正在分析`p'..."

			* regression
			reghdfe stock_out policy3 policy10 if flowin_key == 0 & reciprov == "`p'" , a(pair cityname recipient provid#year year c.(pltn_char_*)#year) vce(cluster cityid)
			est sto prov_`i'

	        * 自由度
        	scalar df = e(df_r)

	        * p-values
	        scalar p_policy3  = 2*ttail(df, abs(_b[policy3]  / _se[policy3]))
	        scalar p_policy10 = 2*ttail(df, abs(_b[policy10] / _se[policy10]))

			* save the results
			matrix coef = coef \ (_b[policy3]  , _b[policy3]  - 1.96 * _se[policy3]  , _b[policy3]  + 1.96 * _se[policy3]  , `i' ,2*`i', p_policy3)
			matrix coef = coef \ (_b[policy10] , _b[policy10] - 1.96 * _se[policy10] , _b[policy10] + 1.96 * _se[policy10] , `i' ,2*`i' - 1, p_policy10)
		}	

		else {
			display " *** 跳过`p'!"
		}
}


svmat coef , names(col)
rename c1 coef
rename c2 lb
rename c3 ub
rename c4 provnum
rename c5 area    // even for 3 regions, odd for 10 clusters
rename c6 pval


* 标注显著性
gen stars = ""
replace stars = "***" if pval < 0.01
replace stars = "**"  if pval < 0.05 & pval >= 0.01
replace stars = "*"   if pval < 0.10 & pval >= 0.05


* 测试个别省份
*reghdfe stock_out policy3 policy10 if flowin_key == 0 & reciprov == "福建省" , a(pair cityname recipient provid#year year) vce(cluster cityid)



*=============== Plot the coefficients ==============*

#delimit ;
	// plot beta for policy3
	twoway 
		   // confidence intervals	
		   (rcap lb ub provnum if mod(area, 2) == 0 , 
		 	 	 horizontal 
		 	 	 lcolor(gs10)
		 	 	 lwidth(vthin)
		 	 	 lp(dash)
		 	 	 legend(label(1 "90% Confidential Intervals")))

 		   // point estimates
		   (scatter provnum coef if mod(area, 2) == 0 , 
		      	 legend(label(2 "Point estimates")) 
		      	 msymbol(C) mcolor(navy) msize(*0.8)
		      	 mlabel(stars) mlabpos(3) mlabcolor(gs2)),

		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
		    ytitle("Province")
			ylabel(	1  "Shanghai" 2  "Yunnan"   3 "Inner Mongolia" 4 "Beijing"    5 "Jilin"    6 "Sichuan" 
					7  "Tianjin"  8  "Ningxia"  9 "Anhui"          10 "Shandong" 11 "Shanxi"  12 "Guangdong" 
					13 "Guangxi"  14 "Xinjiang" 15 "Jiangsu"       16 "Jiangxi"  17 "Hebei"   18 "Henan" 
					19 "Zhejiang" 20 "Hainan"   21 "Hubei"         22 "Hunan"    23 "Gansu"   24 "Fujian"  25 "Tibet" 
					26 "Guizhou"  27 "Liaoning" 28 "Chongqing"     29 "Shaanxi"  30 "Qinghai" 31 "Heilongjiang" , labsize(small) nogrid)
			xlabel(,nogrid)
			title("Panel A. Provincial Pattern for Three Regions",bcolor(white) margin(medium) size(medium))
		    legend(position(bottom) row(2))
		    name(graph1 , replace); 

	// plot beta for policy10
	twoway (rcap lb ub provnum if mod(area, 2) != 0 , 
		 	 	 horizontal 
		 	 	 lcolor(gs10)
		 	 	 lwidth(vthin)
		 	 	 lp(dash)
		 	 	 legend(label(1 "90% Confidential Intervals"))) 
 
		   (scatter provnum coef if mod(area, 2) != 0 , 
		      	 legend(label(2 "Point estimates")) 
		      	 msymbol(C) mcolor(maroon) msize(*0.8)
		      	 mlabel(stars) mlabpos(3) mlabcolor(gs2)), 
 
		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
			ylabel(	1  "Shanghai" 2  "Yunnan"   3 "Inner Mongolia" 4 "Beijing"    5 "Jilin"    6 "Sichuan" 
					7  "Tianjin"  8  "Ningxia"  9 "Anhui"          10 "Shandong" 11 "Shanxi"  12 "Guangdong" 
					13 "Guangxi"  14 "Xinjiang" 15 "Jiangsu"       16 "Jiangxi"  17 "Hebei"   18 "Henan" 
					19 "Zhejiang" 20 "Hainan"   21 "Hubei"         22 "Hunan"    23 "Gansu"   24 "Fujian"  25 "Tibet" 
					26 "Guizhou"  27 "Liaoning" 28 "Chongqing"     29 "Shaanxi"  30 "Qinghai" 31 "Heilongjiang" , labsize(small) nogrid)
		    ylabel(,nogrid)
		    xlabel(,nogrid)
		    ytitle("")
		    title("Panel B. Provincial Pattern for Ten City Clusters", bcolor(white) margin(medium) size(medium))
		    legend(position(bottom) row(2))
		    name(graph2 , replace); 

	// combine 2 plots
	graph combine graph1 graph2, 
		  row(1) ycommon ;

#delimit cr

* graph export "$destin/destination_prov_sepregress.png", replace

***************************************************************

/*


/* interaction regression */
 local province prov_2 prov_3 prov_5 prov_6 prov_8 prov_9 prov_10 prov_11 prov_12 prov_13 prov_14 prov_15 prov_16 prov_17 prov_18 prov_19 prov_20 prov_21 prov_22 prov_23 prov_24 prov_25 prov_26 prov_27 prov_29 prov_30 prov_31
 foreach p in `province' {
 	gen regionX`p'   = `p' * in_tregions  * post
 	gen clustersX`p' = `p' * in_tclusters * post
 	gen policyX`p'   = `p' * policy
 }
 order policyX* clustersX* regionX*, last


 *- regression
 local   province policyXprov_2 policyXprov_3 policyXprov_5 policyXprov_6 policyXprov_8 policyXprov_9 policyXprov_10 policyXprov_11 policyXprov_12 policyXprov_13 policyXprov_14 policyXprov_15 policyXprov_16 policyXprov_17 policyXprov_18 policyXprov_19 policyXprov_20 policyXprov_21 policyXprov_22 policyXprov_23 policyXprov_24 policyXprov_25 policyXprov_26 policyXprov_27 policyXprov_29 policyXprov_30
 reghdfe stock_out `province' if flowin_key == 0 , a(pair cityname recipient year provid#year $citycorr) vce(cluster $clusters)
 est sto desti

*- plot the coefficients
 local province policyXprov_2 policyXprov_3 policyXprov_5 policyXprov_6 policyXprov_8 policyXprov_9 policyXprov_10 policyXprov_11 policyXprov_12 policyXprov_13 policyXprov_14 policyXprov_15 policyXprov_16 policyXprov_17 policyXprov_18 policyXprov_19 policyXprov_20 policyXprov_21 policyXprov_22 policyXprov_23 policyXprov_24 policyXprov_25 policyXprov_26 policyXprov_27 policyXprov_29 policyXprov_30
 coefplot desti, keep(`province') ///
	      aseq swapnames ///
	      noeqlabels ///
	      omitted levels(95) ///
	      xline(0,lp(solid)) ///
	      ciopt(recast(connect) color(edkblue) lp(dash)) ///
	      msize(*0.5) color(black) 

*- consider sperate effects
 local   regionX     regionXprov_2   regionXprov_3   regionXprov_5   regionXprov_6   regionXprov_8   regionXprov_9   regionXprov_10   regionXprov_11   regionXprov_12   regionXprov_13   regionXprov_14   regionXprov_15   regionXprov_16   regionXprov_17   regionXprov_18   regionXprov_19   regionXprov_20   regionXprov_21   regionXprov_22   regionXprov_23   regionXprov_24   regionXprov_25   regionXprov_26   regionXprov_27   regionXprov_29   regionXprov_30   regionXprov_31
 local   clustersX clustersXprov_2 clustersXprov_3 clustersXprov_5 clustersXprov_6 clustersXprov_8 clustersXprov_9 clustersXprov_10 clustersXprov_11 clustersXprov_12 clustersXprov_13 clustersXprov_14 clustersXprov_15 clustersXprov_16 clustersXprov_17 clustersXprov_18 clustersXprov_19 clustersXprov_20 clustersXprov_21 clustersXprov_22 clustersXprov_23 clustersXprov_24 clustersXprov_25 clustersXprov_26 clustersXprov_27 clustersXprov_29 clustersXprov_30 clustersXprov_31
 reghdfe stock_out `regionX' `clustersX' if flowin_key == 0 , a(pair cityname recipient year provid#year $citycorr) vce(cluster $clusters)
 est sto desti

 local   regionX     regionXprov_2   regionXprov_3   regionXprov_5   regionXprov_6   regionXprov_8   regionXprov_9   regionXprov_10   regionXprov_11   regionXprov_12   regionXprov_13   regionXprov_14   regionXprov_15   regionXprov_16   regionXprov_17   regionXprov_18   regionXprov_19   regionXprov_20   regionXprov_21   regionXprov_22   regionXprov_23   regionXprov_24   regionXprov_25   regionXprov_26   regionXprov_27   regionXprov_29   regionXprov_30   regionXprov_31
 local   clustersX clustersXprov_2 clustersXprov_3 clustersXprov_5 clustersXprov_6 clustersXprov_8 clustersXprov_9 clustersXprov_10 clustersXprov_11 clustersXprov_12 clustersXprov_13 clustersXprov_14 clustersXprov_15 clustersXprov_16 clustersXprov_17 clustersXprov_18 clustersXprov_19 clustersXprov_20 clustersXprov_21 clustersXprov_22 clustersXprov_23 clustersXprov_24 clustersXprov_25 clustersXprov_26 clustersXprov_27 clustersXprov_29 clustersXprov_30 clustersXprov_31
 coefplot desti, keep(`regionX') ///
          aseq swapnames ///
          noeqlabels ///
          omitted levels(95) ///
          xline(0,lp(solid)) ///
  		  ylabel(1 "Yunnan"   2 "Inner Mongolia" 3 "Jilin"      4 "Sichuan"    5 "Ningxia"   6 "Anhui"          7 "Shandong"     ///
  		  		 8 "Shanxi"   9 "Guangdong"     10 "Guangxi"   11 "Xinjiang"  12 "Jiangsu"   13 "Jiangxi"      14 "Hebei"        ///
  		  		 15 "Henan"  16 "Zhejiang"      17 "Hainan"    18 "Hubei"     19 "Hunan"     20 "Gansu"        21 "Fujian"       ///
  		  		 22 "Tibet"  23 "Guizhou"       24 "Liaoning"  25 "Shaanxi"   26 "Qinghai"   27 "Heilongjiang" , labsize(small)) ///
          ciopt(recast(connect) color(edkblue) lp(dash)) ///
          msize(*0.5) color(black) ///
          name(region3 , replace)

 coefplot desti, keep(`clustersX') ///
          aseq swapnames ///
          noeqlabels ///
          omitted levels(95) ///
          xline(0,lp(solid)) ///
  		  ylabel(1 "Yunnan"   2 "Inner Mongolia" 3 "Jilin"      4 "Sichuan"    5 "Ningxia"   6 "Anhui"          7 "Shandong"     ///
  		  		 8 "Shanxi"   9 "Guangdong"     10 "Guangxi"   11 "Xinjiang"  12 "Jiangsu"   13 "Jiangxi"      14 "Hebei"        ///
  		  		 15 "Henan"  16 "Zhejiang"      17 "Hainan"    18 "Hubei"     19 "Hunan"     20 "Gansu"        21 "Fujian"       ///
  		  		 22 "Tibet"  23 "Guizhou"       24 "Liaoning"  25 "Shaanxi"   26 "Qinghai"   27 "Heilongjiang" , labsize(small)) ///
          ciopt(recast(connect) color(edkblue) lp(dash)) ///
          msize(*0.5) color(black) ///
          name(cluster10 , replace)
 graph combine region3 cluster10 , row(1) ycommon
 graph export "$destin/destination_prov_interact.png", replace

*/
/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
/*
/* seperate regression */

*- consider beta for policy
matrix coef = J(1,4,.)
cap : drop coef lb ub provcode
cap : drop c1 c2 c3 c4

forvalues i = 1(1)31 {
	display "正在进行第`i'次回归"
	cap{
		reghdfe stock_out policy if flowin_key == 0 & prov_`i' == 1 , a(pair cityname recipient provid#year year $citycorr) vce(cluster $clusters)
		est sto prov_`i'
		matrix coef = coef \ (_b[policy] , _b[policy] - 1.96 * _se[policy] , _b[policy] + 1.96 * _se[policy] , `i')
	}
	
}

svmat coef , names(col)
rename c1 coef
rename c2 lb
rename c3 ub
rename c4 provcode

#delimit ;
	twoway (rcap lb ub provcode, 
				 horizontal 
				 color(edkblue)
				 lp(dash)
				 legend(label(1 "Confidential Intervals")))

		   (scatter provcode coef , 
		    	 legend(label(2 "Point estimates")) 
		    	 msymbol(D) mcolor(stred) msize(*0.5)),

		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
		    ytitle("Province")
			ylabel(	1  "Shanghai" 2  "Yunnan"   3 "Inner Mongolia" 4 "Beijing"    5 "Jilin"    6 "Sichuan" 
					7  "Tianjin"  8  "Ningxia"  9 "Anhui"          10 "Shandong" 11 "Shanxi"  12 "Guangdong" 
					13 "Guangxi"  14 "Xinjiang" 15 "Jiangsu"       16 "Jiangxi"  17 "Hebei"   18 "Henan" 
					19 "Zhejiang" 20 "Hainan"   21 "Hubei"         22 "Hunan"    23 "Gansu"   24 "Fujian"  25 "Tibet" 
					26 "Guizhou"  27 "Liaoning" 28 "Chongqing"     29 "Shaanxi"  30 "Qinghai" 31 "Heilongjiang" , labsize(small))
		    legend(position(bottom) row(1));
#delimit cr

*/
//reghdfe stock_out policy if flowin_key == 0 & prov_6 == 1 , a(pair cityname recipient year provid#year $citycorr) vce(cluster cityid)



*** End of file
