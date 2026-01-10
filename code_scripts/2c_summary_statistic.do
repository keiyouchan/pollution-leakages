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
* ----------------- statistical summary -----------------
global citypred "SO2 PM25 PM10 O3 NO2 lnpopdensity lngdpcapita lnindusoutput lnfinrev lnfinexp"
global Y "stock_out uniinv firmnum_out"
use "firm_reg_balance.dta", clear
sum $Y           // panel A
sum city_char*    // panel B
sum firm_char*    // panel C

sum2docx $Y using "$output/statistical_summary_for_Y.docx", replace ///
		 stats(N mean(%9.3f) sd min(%9.3f) median(%9.3f) max(%9.3f))

sum2docx $citypred using "$output/statistical_summary_for_city.docx", replace ///
		 stats(N mean(%9.3f) sd min(%9.3f) median(%9.3f) max(%9.3f))

sum2docx $firmpred using "$output/statistical_summary_for_firm.docx", replace ///
		 stats(N mean(%9.3f) sd min(%9.3f) median(%9.3f) max(%9.3f))

