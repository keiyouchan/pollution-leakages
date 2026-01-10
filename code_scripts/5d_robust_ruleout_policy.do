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
set more off
***************************************
* outcome variables
global outcomes "stock_out netinc_out inc_out firmnum_out uniinv"
global twfe "code year"
global hdfe "code year provid#year indusid#year"


cap program drop reg_rbs_excpolicy
program reg_rbs_excpolicy
		version 18


		*=================== 1: 环保约谈 ===================*


		import excel using "$raw/环保约谈处理组.xlsx" , sheet("Sheet1") firstrow clear
		tempfile tour
		save    `tour' , replace 

		*=================== 3: Low carbon city pilot ===================*

		clear
		tempfile citiesfile
		cap file close f
		file open f using `citiesfile', write text replace
		file write f "cities" _n
		*file write f "北京市、上海市、海南省和石家庄市、秦皇岛市、晋城市、呼伦贝尔市、吉林市、大兴安岭地区、苏州市、淮安市、镇江市、宁波市、温州市、池州市、南平市、景德镇市、赣州市、青岛市、济源市、武汉市、广州市、桂林市、广元市、遵义市、昆明市、延安市、金昌市、乌鲁木齐市"
		file write f "广东省、辽宁省、湖北省、陕西省、云南省、天津市、重庆市、深圳市、厦门市、杭州市、南昌市、贵阳市、保定市、北京市、上海市、海南省、石家庄市、秦皇岛市、晋城市、呼伦贝尔市、吉林市、大兴安岭地区、苏州市、淮安市、镇江市、宁波市、温州市、池州市、南平市、景德镇市、赣州市、青岛市、济源市、武汉市、广州市、桂林市、广元市、遵义市、昆明市、延安市、金昌市、乌鲁木齐市、乌海市、沈阳市、大连市、朝阳市、逊克县、南京市、常州市、嘉兴市、金华市、衢州市、合肥市、淮北市、黄山市、六安市、宜城市、三明市、共青城市、吉安市、抚州市、济南市、烟台市、潍坊市、长阳土家自治县、长沙市、株洲市、湘潭市、郴州市、中山市、柳州市、三亚市、琼中黎族自治县、成都市、玉溪市、普洱市、拉萨市、安康市、兰州市、敦煌市、西宁市、银川市、吴忠市、昌吉市、伊宁市、和田市、第一师阿拉尔市"
		file close f

		import delimited using `citiesfile', clear varnames(1)
		*replace cities = subinstr(cities, "和", "、", .)
		split cities, parse("、")
		drop  cities
		gen lowcarbon = _n
		reshape long cities, i(lowcarbon) j(_)
		rename cities cityname
		drop if missing(lowcarbon)
		drop _
		gen batch = .
		replace batch = 2011 if inrange(_n, 1, 13)
		replace batch = 2012 if inrange(_n, 14, 42)
		replace batch = 2017 if inrange(_n, 43, 87)
		gen provlevel = regexm(cityname,"省")

		preserve
			keep if provlevel == 1
			rename cityname provname
			rename lowcarbon lowcarbonprov
			tempfile pilot_prov
			save `pilot_prov'
		restore
		preserve
			keep if provlevel == 0
			tempfile pilot_city
			rename lowcarbon lowcarboncity
			save `pilot_city'
		restore


		*=================== 4: regression ===================*

		use "$processed/firm_reg_balance.dta", clear


		/* 环保约谈 */
		merge m:1 cityname using `tour' , keep(1 3) nogen
			replace hbyttreat = 0    if hbyttreat == .
			replace time      = 9999 if time == .
			gen hbytpost = (year >= time ) if !missing(time)
			gen tour  = hbyttreat * hbytpost // 生成环保did


		/* 节能减排 */
		gen jnjptreat = 0 
		    replace jnjptreat = 1 if cityname == "北京市"
		    replace jnjptreat = 1 if cityname == "深圳市"
		    replace jnjptreat = 1 if cityname == "重庆市"
		    replace jnjptreat = 1 if cityname == "杭州市"
		    replace jnjptreat = 1 if cityname == "长沙市"
		    replace jnjptreat = 1 if cityname == "贵阳市"
		    replace jnjptreat = 1 if cityname == "吉林市"
		    replace jnjptreat = 1 if cityname == "新余市"

		gen jnjppost = (year >= 2011) if !missing(year)
		gen pilot = jnjptreat * jnjppost



		/* 低碳城市 */
		merge m:1 cityname using `pilot_city', keep(1 3) nogen
		merge m:1 provname using `pilot_prov', keep(1 3) nogen
		gen low_carbon_pilot = 0
			replace low_carbon_pilot = 1 if lowcarboncity != .
			replace low_carbon_pilot = 1 if lowcarbonprov != .
		gen pilot_lcb = low_carbon_pilot * (year >= batch)
		drop lowcarbon*



		local y stock_out
		reghdfe `y' policy tour pilot pilot_lcb, ///
					a($hdfe c.(pltn_char_*)#year) vce(cluster code)
					est sto exclude_policy

		* display output
		esttab exclude_policy,  /// using "$baseline/basline_`Y'.csv", ///
			   b(3) se(3) ar2(3) ///
			   keep(policy tour pilot pilot_lcb) ///
			   order(policy tour pilot pilot_lcb) ///
			   star(* 0.1 ** 0.05 *** 0.01) replace

end 



* reg_rbs_excpolicy


*** End of file


