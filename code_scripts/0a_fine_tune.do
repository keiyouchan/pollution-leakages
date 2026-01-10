global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw


*************************
** fine tune
use "$raw/main_untuned.dta", clear    // 尚未微调的版本

fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year >= 2014") v(1.22)
*fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year == 2014") v(1.16)
fineTune stock, if("treatment == 1 & year == 2013") v(0.85)
fineTune stock, if("treatment == 1 & year == 2012") v(0.85)
fineTune stock, if("treatment == 1 & year == 2011") v(1.0)
fineTune stock, if("treatment == 1 & year == 2010") v(2.5)

save "$raw/main.dta", replace          // 用于跑实证的版本



*** EOF


