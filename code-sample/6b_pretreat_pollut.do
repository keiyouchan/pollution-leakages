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
******************************************************

*** 环保监测站点数据
import excel using "$raw/空气质量监测站点数据.xlsx", firstrow clear sheet("Sheet1")
rename 监测点编码 stacode
rename 监测点名称 staname 
encode stacode, gen(station_code)

gen cityname = 城市
replace cityname = cityname + "市" if !regexm(cityname, "地区") & !regexm(cityname, "盟")

gen group = 0
* 三区
replace group = 1 if inlist(cityname, "北京市","天津市","石家庄市","唐山市","保定市","廊坊市")
replace group = 1 if inlist(cityname, "上海市","南京市","无锡市","常州市","苏州市","南通市","扬州市")
replace group = 1 if inlist(cityname, "镇江市","泰州市","杭州市","宁波市","嘉兴市","湖州市","绍兴市")
replace group = 1 if inlist(cityname, "广州市","深圳市","珠海市","佛山市","江门市","肇庆市","惠州市","东莞市","中山市")

* 十群
replace group = 2 if inlist(cityname, "沈阳市","济南市","青岛市","淄博市","潍坊市","日照市")
replace group = 2 if inlist(cityname, "武汉市","长沙市","重庆市","成都市","福州市","三明市")
replace group = 2 if inlist(cityname, "太原市","西安市","咸阳市","兰州市","银川市","乌鲁木齐市") 

geo2xy 纬度 经度, gen(lat lon) projection(albers, 6378137 298.257223563 25 47 0 105) replace
save  "$interm/stapoint.dta",replace




/*
*** data A: 环保监察机构数量
import excel using "$raw/各地区环保机构情况_11_15.xlsx", clear firstrow sheet("Sheet1")
gen provname = 地区 
replace provname = provname + "省" if !inlist(provname, "北京","上海","天津","重庆","内蒙古","新疆","广西","宁夏","西藏")
replace provname = provname + "市" if inlist(provname, "北京","上海","天津","重庆")
replace provname = provname + "自治区" if inlist(provname, "内蒙古", "西藏")
replace provname = "广西壮族自治区" if provname == "广西"
replace provname = "新疆维吾尔自治区" if provname == "新疆"
replace provname = "宁夏回族自治区" if provname == "宁夏"
keep  地区 provname *监察机构数* 年份
order 地区 provname

gen totnum = 国家级省级机构数_环境监察机构数个 + 地市级环保机构数_环境监察机构数个 + 县级环保机构数_环境监察机构数个
collapse totnum if 年份 >= 2010 & 年份 <= 2015, by(provname)
tempfile env_ovst_num
save `env_ovst_num', replace
*/

*** 
import excel using "$raw/空气质量监测点位.xlsx", firstrow clear sheet("Sheet2")
keep 省份 所在城市 点位数
rename 省份 provname
rename 所在城市 cityname 
rename 点位数 stanum

gen group = 0
* 三区
replace group = 1 if inlist(cityname, "北京市","天津市","石家庄市","唐山市","保定市","廊坊市")
replace group = 1 if inlist(cityname, "上海市","南京市","无锡市","常州市","苏州市","南通市","扬州市")
replace group = 1 if inlist(cityname, "镇江市","泰州市","杭州市","宁波市","嘉兴市","湖州市","绍兴市")
replace group = 1 if inlist(cityname, "广州市","深圳市","珠海市","佛山市","江门市","肇庆市","惠州市","东莞市","中山市")

gen t1 = 0
replace t1 = 11 if inlist(cityname, "北京市","天津市","石家庄市","唐山市","保定市","廊坊市")
replace t1 = 12 if inlist(cityname, "上海市","南京市","无锡市","常州市","苏州市","南通市","扬州市")
replace t1 = 12 if inlist(cityname, "镇江市","泰州市","杭州市","宁波市","嘉兴市","湖州市","绍兴市")
replace t1 = 13 if inlist(cityname, "广州市","深圳市","珠海市","佛山市","江门市","肇庆市","惠州市","东莞市","中山市")
replace t1 = 2  if inlist(cityname, "沈阳市","济南市","青岛市","淄博市","潍坊市","日照市")
replace t1 = 2  if inlist(cityname, "武汉市","长沙市","重庆市","成都市","福州市","三明市")
replace t1 = 2  if inlist(cityname, "太原市","西安市","咸阳市","兰州市","银川市","乌鲁木齐市") 

bys t1: egen stanum_sum = sum(stanum) if t1 != 0
replace stanum_sum = stanum if stanum_sum == .


* 十群
replace group = 2 if inlist(cityname, "沈阳市","济南市","青岛市","淄博市","潍坊市","日照市")
replace group = 2 if inlist(cityname, "武汉市","长沙市","重庆市","成都市","福州市","三明市")
replace group = 2 if inlist(cityname, "太原市","西安市","咸阳市","兰州市","银川市","乌鲁木齐市") 



tempfile stanum
save `stanum' , replace



*** 地图数据与data A合并
use "$map_file/city_coord",replace
gen cityname = 市
replace cityname = "北京市" if strpos(cityname, "北京市") > 0
replace cityname = "天津市" if strpos(cityname, "天津市") > 0
replace cityname = "上海市" if strpos(cityname, "上海市") > 0
replace cityname = "重庆市" if strpos(cityname, "重庆市") > 0
merge m:1 cityname using `stanum', keep(1 3) nogen
gen lnstanum = log(1+stanum_sum)

/*
keep if group != 0 & group != .
levelsof _ID if group == 1, local(id3) clean sep(,)
levelsof _ID if group == 2, local(id10) clean sep(,)


*/


*** 绘图
grmap lnstanum using "$map_file/city_coord_shp.dta", ///
	fcolor(Blues) ///
    id(_ID) ///
    ocolor(gs10 ...) ///
    osize(vvthin ...) ///
    ndsize(vvthin) ///
    clnumber(7) ///
    ///clmethod(custom) ///
    ///clbreaks(0 10 20 30 40 50 60 70 80 90) ///
    line(data("$map_file/city_line_corrd_shp.dta") ///
    	 size(medium)  /// ///
 		 color(gray%30 black "0 85 170" black black)) /// 
 	polygon(data(polygon) fcolor(black) osize(vvthin)) ///
 	label(data("$map_file/chinacitymini_label") x(X) y(Y) label(ename) length(20) size(*1) select(keep if inlist(cname, "N", "1000km"))) ///
    legend( ///
	    label(1 "Others") ///
	    label(2 "Ten City Clusters") ///
	    label(3 "Three Regions") ///
	    position(7) ring(0) size(*1.2)) ///
    graphr(margin(zero)) 


 	point(data("$interm/stapoint.dta") ///
 		  x(lon) y(lat) by(group) ///
 		  fcolor("72 192 170%20"  "69 105 144" "239 118 122") ///
 		  size(*0.5 ...) legenda(on))   ///


















