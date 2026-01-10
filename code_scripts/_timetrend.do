global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"


cd $raw
* -------------------- *
/* plot outcome trends */
import excel using "（2）异地投资数据.xlsx" , firstrow sheet("Sheet1") clear
keep 被投资单位 证券代码 year 期末余额 增减变动 本期增加 处理组 三区十群内的异地投资

rename (被投资单位 证券代码 期末余额  增减变动 本期增加 处理组 三区十群内的异地投资) ///
	   (subfirm code stock netinc inc treatment in_key )

* aggregate outcomes by year
local outcome stock netinc inc
foreach y in `outcome'{
	egen sum_`y' = sum(`y') , by(treatment year)
}

* plot
twoway (line sum_stock year if treatment == 1, lcolor(blue)) ///
	   (line sum_stock year if treatment == 0, lcolor(red)), ///
	   ylabel("", nogrid) ///
	   ytitle("Cumulative Investment") ///
	   xlabel(2010(1)2017, nogrid) ///
	   xtitle("Year") ///
	   xline(2013, lc(gs2) lw(*1.2) lp(solid)) ///
	   legend(label(1 "Key areas") label(2 "Non-key areas") pos(6) row(1)) ///
	   scheme(s2mono) ///
	   graphregion(color(white)) ///
		plotregion(color(white))


***EOF