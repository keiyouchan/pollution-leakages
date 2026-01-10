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
*************************************

* ----------------
/* main setting */
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
	cap gen pre = year <= 2013
	cap gen post = year >= 2014
	bys code (year) : egen Y_pre = mean(stock_out) if pre
		bys code (year) : fillmissing Y_pre  , with(max)
	bys code (year) : egen Y_post = mean(stock_out) if post
		bys code (year) : fillmissing Y_post , with(max)
	gen deltaY = (Y_post - Y_pre) * 10000 * 100 / l_totast
	duplicates drop code , force  // 172 control units
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
merge 1:1 code using `deltaY' , keep(1 3) nogen
summ   mindist, d // p10=19.04, p25=54.14 , p50=134.6739, p75=241, p90=345
twoway scatter deltaY mindist if deltaY > 0

/* merge the dist back to main dataset */
merge 1:m code using "firm_reg_balance", assert(2 3) keep(2 3) nogenerate
sort code year

replace mindist=0 if treatment==1
replace mindist=0 if treatment==0 & year <= 2014

save "$processed/firm_reg_spillover.dta" , replace


*** End of file
