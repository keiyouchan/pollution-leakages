global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline   "$output/baseline"
		global robust     "$output/robust"
		global eventstudy "$output/eventstudy"	

cd $processed
* -----------------
/* main setting */
/*
use    "firm_reg_balance.dta", clear
merge  1:1 code year using "$raw/firm_correlates_raw.dta" , keep(1 3) keepusing(办公地经度 办公地纬度) nogen
rename (办公地经度 办公地纬度) (lon lat)
tempfile loc
save    `loc',replace 
* -----------------
/* calculate delta Y for control units */
preserve 
	keep if treatment == 0
	* rename (code lat lon) (firmid2 lat2 lon2)
	gen pre = year <= 2013
	gen post = year >= 2014
	bys code (year) : egen Y_pre = mean(stock_out) if pre
		bys code (year) : fillmissing Y_pre  , with(max)
	bys code (year) : egen Y_post = mean(stock_out) if post
		bys code (year) : fillmissing Y_post , with(max)
	gen deltaY = (Y_post - Y_pre) * 10000 * 100 / asset_2010
	duplicates drop code deltaY , force  // 172 control units
	keep code deltaY
	tempfile deltaY
	save `deltaY' , replace
restore
* -----------------
use code treatment lon lat using `loc' , clear
bys code : keep if _n == 1

/* a list for treat and control separately */
preserve
	keep if treatment==1
	rename (code lat lon) (firmid1 lat1 lon1)
	tempfile treat
	save `treat', replace
restore	
	keep if treatment==0
	rename (code lat lon) (firmid2 lat2 lon2)
	tempfile control
	save `control', replace

/* calculate the geo distance for each treat-control pair */ 
cross using `treat'	
drop treatment
sort firmid1 firmid2	
geodist lat1 lon1 lat2 lon2 , generate(dist)

/* for each control unit, get the dist to the nearest treated unit */
bys  firmid2: egen mindist =  min(dist)
bys  firmid2: keep if dist == mindist
keep firmid2 mindist
rename firmid2 code
merge  1:1 code using `deltaY' , keep(1 3) nogen
summ   mindist, d // p10=19.04, p25=54.14 , p50=134.6739, p75=241, p90=345, mean = 120

/* cumulative distribution */
sort mindist
cumul mindist, gen(cdf)
twoway (line cdf mindist, sort lcolor(blue) lwidth(medium)) ///
	   (scatteri 0.5 112.8154), ///
       xtitle("Distance") ytitle("Cumulative Percentage") ///
       yline(0.5, lwidth( .3) lcolor(blue)) ///
       xline(112.8154 , lwidth(.3) lcolor(red)) 


/* merge the dist back to main dataset */
merge 1:m code using "firm_reg_balance", assert(2 3) keep(2 3) nogenerate
sort code year

replace mindist=0 if treatment==1
replace mindist=0 if treatment==0 & year <= 2014

save "$processed/firm_reg_spillover.dta" , replace
*/



use "$processed/firm_reg_spillover.dta",clear
* ---------------------------------
cap program drop reg_rbs_splovr
program reg_rbs_splovr
		version 18
		syntax varlist, binwid(int) maxdist(int) [save(string)]
		local k `binwid'
		local len `maxdist'
		local yvar `varlist'



		dis "正在回归`yvar'"


		/* distance bin */
		cap drop distbin*
		forvalues b = 0(`k')`len' {

			gen distbin`b' = 0
			replace distbin`b' = 1 if mindist <= `b' & mindist > `b'-`k'
		}
		drop distbin0


		/* interactions of distance bins and treatment status */
		cap gen control = 0 if policy == 1
		cap replace control = 1 if policy==0


		cap drop postX* 
		foreach bin of varlist distbin* {
				gen postX`bin' = `bin' * (year>=2014)
				drop `bin'
		}


		est clear
		foreach outcome in `yvar' {

				reghdfe `outcome' policy postX* , a($hdfe c.(pltn_char_*)#year) vce(cluster citycode)
				est sto `outcome'
		}


		* output
		esttab `yvar' , /// using "$robust/robust_spillover.csv", ///
			b(3) se(3) ar2(3) ///
			keep(policy postX*) ///
			order(policy postX*) ///
			star(* 0.1 ** 0.05 *** 0.01) replace


		if "`save'" != "" {
			esttab `yvar' using "`save'", ///
				b(3) se(3) ar2(3) ///
				keep(policy postX*) ///
				order(policy postX*) ///
				nogaps ///
				compress ///
				star(* 0.1 ** 0.05 *** 0.01) replace
		}

end

* reg_rbs_splovr stock_out, binwid(20)


* -----------------------------------
/*
/* event study */
foreach outcome in $outcomes {
	reghdfe `outcome' F2-F4 L0-L3 post* , a($fe) vce(cluster $clusters)
	est sto `outcome'
}

/* plot all stored estimates together */
event_plot $outcomes, /// 
	stub_lag(L# L#) stub_lead(F# F#) ///
	plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(4) noautolegend ///
	graph_opt(title("Event study for non-local investment", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") ///
		xlabel(-4(1)3, nogrid) ylabel(-10(5)20, nogrid) ///
        legend(order(2 "stock_out" 4 "netinc" 6 "inc" 8 "firmnum") rows(2) region(style(none))) ///
		xline(-1, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) 
*/
*** End of file 

