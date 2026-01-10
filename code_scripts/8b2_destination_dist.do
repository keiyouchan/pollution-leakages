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
set more off

/* Destination: Distance */
* outcome variables
global outcomes "stock_out firmnum_out"
	* HDFE model
	global hdfe     "code year provid#year indusid#year"
	global clusters "pair"
 

/*** Preprocessing ***/
use "$processed/three_dimens_distance.dta" , clear

tab distbin
scalar n = `r(r)'
gen dist_1 = distbin == "0 - 400"
gen dist_2 = distbin == "400 - 800"
gen dist_3 = distbin == "800 - 1200" 
gen dist_4 = distbin == "1200 - 1600"
gen dist_5 = (distbin == "1600 - 2000") | (distbin == "2000 - 4500")
*gen dist_6 = distbin == "2000 - 4500"

gen policy3  = in_3regions  *  (year >= 2014)
gen policy10 = in_10clusters * (year >= 2014)
encode distbin, gen(distbinid)


cap program drop get_dist_pattern
program get_dist_pattern
		version 18
		syntax varlist, []
		local yvar `varlist'


		cap matrix drop coef
		matrix coef = J(1,6,.) //  coef lb ub distcode area pval
		cap: drop coef lb ub distcode area pval
		cap: drop c1 c2 c3 c4 c5 c6

		*** regression part ***
		est clear
		forvalues i = 1(1)5 {

				display "正在进行第`i'次回归"

				qui {
					* regression
					reghdfe `yvar' policy3 policy10 if dist_`i' == 1 , a($hdfe c.(pltn_char_*)#year) vce(cluster $clusters ) noconstant
					est sto dist_`i'

			        * degree of freedom * P-value
			    	scalar df = e(df_r)
			        scalar p_policy3  = 2*ttail(df, abs(_b[policy3]  / _se[policy3]))
			        scalar p_policy10 = 2*ttail(df, abs(_b[policy10] / _se[policy10]))

			        * store in matrix
					matrix coef = coef \ (_b[policy3]  , _b[policy3]  - 1.64 * _se[policy3]  , _b[policy3]  + 1.96 * _se[policy3]  , `i' ,2*`i', p_policy3)      
					matrix coef = coef \ (_b[policy10] , _b[policy10] - 1.64 * _se[policy10] , _b[policy10] + 1.96 * _se[policy10] , `i' ,2*`i' - 1, p_policy10)
				}


				esttab  dist_`i' ///
					/// using "$hetero/target_`Y'.csv" ///
					, ///
					b(3) se(3) ar2(3) ///
					keep(policy3 policy10) ///
					order(policy3 policy10) ///
					star(* 0.1 ** 0.05 *** 0.01) replace
		}


		*** matrix to variables
		svmat coef , names(col)
		rename c1 coef
		rename c2 lb
		rename c3 ub
		rename c4 distcode
		rename c5 area    // even for 3 regions, odd for 10 clusters
		rename c6 pval


		* 标注显著性
		cap drop stars
		gen stars = ""
		replace stars = "***" if pval < 0.01
		replace stars = "**"  if pval < 0.05 & pval >= 0.01
		replace stars = "*"   if pval < 0.10 & pval >= 0.05


end




*# plot beta for policy3
cap program drop plot_dist_pattern
program plot_dist_pattern
		version 18
		syntax, atype(string) ///
				[gname(string) save(string) title(string) mcolor(string) ylbl(string)]


	    * 判断 odd / even
	    if "`atype'" == "odd"  local cond "mod(area,2) == 1"   // 奇数十群
	    if "`atype'" == "even" local cond "mod(area,2) == 0"   // 偶数三区

	    * 默认散点颜色
	    if "`mcolor'" == "" local mcolor "navy"

	    * y轴标签
	    *if "`ylbl'" == "hide"

		twoway (rcap lb ub distcode if `cond', /// 
			 	 	 horizontal       ///
			 	 	 color(edkblue)   ///
			 	 	 lp(solid)         ///
			 	 	 lw(*1.5)         ///
			 	 	 legend(label(1 "90% Confidence Intervals"))) ///
			   (scatter distcode coef if `cond', /// 
			      	 legend(label(2 "Point estimates"))      ///
			      	 msymbol(C) mcolor("`mcolor'") msize(*1.2)     ///
			      	 mlabel(stars) mlabpos(3) mlabcolor(gs2)) ///
			    , ///
			    title("`title'", bcolor(white) margin(medium) size(medium)) ///
			    xline(0 , lp(solid) lw(0.3) lcolor(gs2))  ///
			    ytitle("Distance bin(KM)")                ///
			    xtitle("Coefficient")                      ///
		  		ylabel(1  "0-400"    2 "400-800"  3 "800-1200"     ///
		  			   4 "1200-1600" 5 "Beyond 1600" , labsize(median) nogrid)    ///
			    xlabel(,nogrid)   ///
			    ///yscale(range(0.5 5.5)) ///          ///
			    legend(position(bottom) row(2) size(median))          ///
			    graphregion(margin(zero) color(white)) ///
			    ///plotregion(margin(0 0 0 0)) ///
			    name(`gname' , replace) ///
			    aspectratio(0.8)
	    

	    if "`save'" != "" {
	    	graph export "$destin/dist_pattern_`area'.png", replace
	    }

end 


*** Test for program
local area "even"
get_dist_pattern(stock_out)
plot_dist_pattern,atype(`area') ///
		gname("investment") ///
		title("Panel A. Investment Pattern")
graph close

get_dist_pattern(firmnum_out)
plot_dist_pattern,atype(`area') ///
		mcolor(maroon) /// 
		gname("No_of_Firms") ///
		title("Panel B. Number of Subsidiaries Pattern") 
graph close

graph combine investment No_of_Firms, iscale(*1.1) ycommon
graph export "$destin/dist_pattern_`area'.png", replace


** test
/*
reghdfe stock_out policy3 policy10   if dist_5 == 1 | dist_6 == 1 , a($hdfe c.(pltn_char_*)#year) vce(cluster cityid) noconstant
reghdfe firmnum_out policy3 policy10 if dist_5 == 1 | dist_6 == 1 , a($hdfe c.(pltn_char_*)#year) vce(cluster pair) noconstant
*/

*graph combine graph1 graph2, row(1) ycommon scheme(s2mono)
*graph export "$destin/destination_dist_sepregress.png", replace

*reghdfe firmnum_out policy3 policy10 if dist_1 == 1 , a($hdfe c.(pltn_char_*)#year) vce(cluster cityid) noconstant

*** End of file





/*
/*** intreaction regression ***/

local dists dist_1 dist_2 dist_3 dist_4 dist_5 dist_6 
foreach i in `dists' {
 		gen policyX`i' =   `i' * policy  
 		gen regionX`i' =   `i' * in_tregions  * post
 		gen clustersX`i' = `i' * in_tclusters * post
} 
order policyX* clustersX* regionX*, last

 *- regression
 local distance policyXdist_1 policyXdist_2 policyXdist_3 policyXdist_4 policyXdist_5 policyXdist_6 policyXdist_7 policyXdist_8 policyXdist_9 policyXdist_10 policyXdist_11 policyXdist_12 policyXdist_13 policyXdist_14 policyXdist_15 policyXdist_16 policyXdist_17 policyXdist_18 policyXdist_19 policyXdist_20
 reghdfe stock_out `distance' , a(pair cityname distbin year provid#year $citycorr) vce(cluster cityid)


 *- seperate effect
 local regionX     regionXdist_1   regionXdist_2   regionXdist_3   regionXdist_4   regionXdist_5   regionXdist_6   regionXdist_7   regionXdist_8   regionXdist_9   regionXdist_10   regionXdist_11   regionXdist_12   regionXdist_13   regionXdist_14   regionXdist_15   regionXdist_16   regionXdist_17   regionXdist_18   regionXdist_19   regionXdist_20
 local clustersX clustersXdist_1 clustersXdist_2 clustersXdist_3 clustersXdist_4 clustersXdist_5 clustersXdist_6 clustersXdist_7 clustersXdist_8 clustersXdist_9 clustersXdist_10 clustersXdist_11 clustersXdist_12 clustersXdist_13 clustersXdist_14 clustersXdist_15 clustersXdist_16 clustersXdist_17 clustersXdist_18 clustersXdist_19 clustersXdist_20
 reghdfe stock_out `regionX' `clustersX' , a(pair cityname distbin year provid#year $citycorr) vce(cluster cityid)
 est sto desti_dist
 	 *- plot the coeffecient
	 local regionX     regionXdist_1   regionXdist_2   regionXdist_3   regionXdist_4   regionXdist_5   regionXdist_6   regionXdist_7   regionXdist_8   regionXdist_9   regionXdist_10   regionXdist_11   regionXdist_12   regionXdist_13   regionXdist_14   regionXdist_15   regionXdist_16   regionXdist_17   regionXdist_18   regionXdist_19   regionXdist_20
	 local clustersX clustersXdist_1 clustersXdist_2 clustersXdist_3 clustersXdist_4 clustersXdist_5 clustersXdist_6 clustersXdist_7 clustersXdist_8 clustersXdist_9 clustersXdist_10 clustersXdist_11 clustersXdist_12 clustersXdist_13 clustersXdist_14 clustersXdist_15 clustersXdist_16 clustersXdist_17 clustersXdist_18 clustersXdist_19 clustersXdist_20
	 coefplot desti_dist, keep(`regionX') ///
	          aseq swapnames ///
	          noeqlabels ///
	          omitted levels(95) ///
	          xline(0,lp(solid)) ///
	  		  ylabel(1  "0 - 200"        2 "1000 - 1200"  3 "1200 - 1400"     4 "1400 - 1600"    5 "1600 - 1800"  ///
	  		  		 6  "1800 - 2000"    7 "200 - 400"    8 "2000 - 2200"     9 "2200 - 2400"   10 "2400 - 2600"  ///
	  		  		 11 "2600 - 2800"   12 "2800 - 3000" 13 "3000 - 3200"    14 "3200 - 3400"   15 "3400 - 3600"  ///
	  		  		 16 "3600 - 3800"   17 "3800 - 4000" 18 "400 - 600"      19 "600 - 800"     20 "800 - 1000") ///
	          ciopt(recast(connect) color(edkblue) lp(dash)) ///
	          msize(*0.5) color(black) ///
	          name(region3 , replace)

	 coefplot desti_dist, keep(`clustersX') ///
	          aseq swapnames ///
	          noeqlabels ///
	          omitted levels(95) ///
	          xline(0,lp(solid)) ///
	  		  ylabel(1  "0 - 200"        2 "1000 - 1200"  3 "1200 - 1400"     4 "1400 - 1600"    5 "1600 - 1800"  ///
	  		  		 6  "1800 - 2000"    7 "200 - 400"    8 "2000 - 2200"     9 "2200 - 2400"   10 "2400 - 2600"  ///
	  		  		 11 "2600 - 2800"   12 "2800 - 3000" 13 "3000 - 3200"    14 "3200 - 3400"   15 "3400 - 3600"  ///
	  		  		 16 "3600 - 3800"   17 "3800 - 4000" 18 "400 - 600"      19 "600 - 800"     20 "800 - 1000") ///
	          ciopt(recast(connect) color(edkblue) lp(dash)) ///
	          msize(*0.5) color(black) ///
	          name(cluster10 , replace)
	 graph combine region3 cluster10 , row(1) ycommon
/*-----------------------------------------------------*/
/*-----------------------------------------------------*/

/*** seperate regression ***/
*- consider combined effect
matrix coef = J(1,4,.)
cap: drop coef lb ub distcode 
cap: drop c1 c2 c3 c4 

forvalues i = 1(1)20 {
	display "正在进行第`i'次回归"
	cap{
		reghdfe stock_out policy         if dist_`i' == 1 , a($hdfe_dummy) vce(cluster cityid)
		est sto dist_`i'
		matrix coef = coef \ (_b[policy]  , _b[policy]  - 1.96 * _se[policy]  , _b[policy]  + 1.96 * _se[policy]  , `i')
	}
	
}

svmat coef , names(col)
rename c1 coef
rename c2 lb
rename c3 ub
rename c4 distcode

#delimit ;
	twoway (rcap lb ub distcode, 
				 horizontal 
				 color(edkblue)
				 lp(dash)
				 legend(label(1 "Confidential Intervals")))

		   (scatter distcode coef , 
		    	 legend(label(2 "Point estimates")) 
		    	 msymbol(D) mcolor(stred) msize(*0.5)),

		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
		    ytitle("Distance bin(KM)")
	  		ylabel(1  "0 - 200"        2 "1000 - 1200"  3 "1200 - 1400"     4 "1400 - 1600"    5 "1600 - 1800"  
	  			   6  "1800 - 2000"    7 "200 - 400"    8 "2000 - 2200"     9 "2200 - 2400"   10 "2400 - 2600"  
	  			   11 "2600 - 2800"   12 "2800 - 3000" 13 "3000 - 3200"    14 "3200 - 3400"   15 "3400 - 3600"  
	  			   16 "3600 - 3800"   17 "3800 - 4000" 18 "400 - 600"      19 "600 - 800"     20 "800 - 1000", labsize(small))
		    legend(position(bottom) row(1));
#delimit cr
graph export "$destin/destination_dist_sepregress_combined.png", replace




reghdfe firmnum_out policy3 policy10 if dist_1 == 1 , a($hdfe) vce(cluster cityid)
reghdfe firmnum_out policy3 policy10 if dist_2 == 1 , a($hdfe) vce(cluster cityid)
reghdfe firmnum_out policy3 policy10 if dist_3 == 1 , a($hdfe) vce(cluster cityid)
reghdfe firmnum_out policy3 policy10 if dist_4 == 1 , a($hdfe) vce(cluster cityid)
reghdfe firmnum_out policy3 policy10 if dist_5 == 1 , a($hdfe) vce(cluster cityid)
reghdfe firmnum_out policy3 policy10 if dist_6 == 1 , a($hdfe) vce(cluster cityid)


/************************************************/
*/
