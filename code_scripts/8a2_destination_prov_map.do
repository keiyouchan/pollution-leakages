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
************************************
* 市级面
global map_file "/Users/chandlerwong/Desktop/Study/rstata/Chinamap"
global citymap "$map_file/citymapdata/minishp/chinacity2010mini"
global provmap "$map_file/provmapdata/minishp/chinaprov2010mini"
cd $map_file

/*
/*============ 数据准备 ============*/

* 导入 shp
spshape2dta "$citymap/chinacity2010mini", replace saving(city_coord)
spshape2dta "$citymap/chinacity2010mini_line", replace saving(city_line_corrd)
spshape2dta "$provmap/chinaprov2010mini", replace saving(prov_corrd)
spshape2dta "$provmap/chinaprov2010mini_line", replace saving(prov_line_corrd)


*** 给市级分界线数据分组
use city_line_corrd_shp.dta, clear

cap gen group = 1 // 省界
replace group = 2 if _ID == 350 // 国界线
replace group = 3 if _ID == 351 // 海岸线
replace group = 4 if _ID == 352 // 秦岭-淮河线
replace group = 5 if _ID == 353 // 小地图框格
replace group = 6 if inlist(_ID, 354, 355, 356, 357) // 指北针和比例尺
replace group = 7 if _ID == 358 // 胡焕庸线
save city_line_corrd_shp.dta, replace


*** 给省级分界线数据分组
use $map_file/prov_corrd.dta, clear
use $map_file/prov_line_corrd_shp.dta, clear

cap gen group = 1 // 省界


* 为 polygon() 选项生成数据：
use city_coord_shp.dta, clear 
keep if inlist(_ID, 350,351) 
gen value = 1
save polygon, replace

* 处理标签
use chinaprov40_label.dta, clear 

replace X = X - 10000
replace Y = Y - 550000
replace Y = Y + 100000 if cname == "吉林"
replace Y = Y - 70000 if cname == "广东"
replace Y = Y + 50000 if cname == "青海"
replace Y = Y + 60000 if cname == "辽宁"
replace Y = Y + 60000 if cname == "江西"
replace Y = Y + 60000 if cname == "贵州"
replace Y = Y + 60000 if cname == "湖南"
replace Y = Y + 60000 if cname == "河南"
replace X = X + 10000 if cname == "辽宁"
replace Y = Y + 50000 if cname == "山东"
replace Y = Y + 90000 if cname == "内蒙古"
replace X = X + 100000 if cname == "黑龙江"
replace X = X - 100000 if cname == "台湾"
replace X = X - 60000 if cname == "香港"
replace X = X - 80000 if cname == "海南"
replace X = X - 50000 if cname == "湖南"
replace Y = Y + 80000 if cname == "宁夏"
replace Y = Y + 70000 if cname == "湖北"
replace Y = Y + 80000 if cname == "河北"
replace Y = Y + 430000 if cname == "N"
replace X = X - 390000 if cname == "N"
replace Y = Y + 410000 if cname == "1000km"
replace X = X - 380000 if cname == "1000km"
save chinacitymini_label.dta, replace  
*/



import excel "/Users/chandlerwong/Desktop/Pollution_project/key areas.xlsx", sheet("Sheet1") firstrow clear
gen region_type = "Others"

* 三区
replace region_type = "Three Regions" if inlist(市, "北京市","天津市","石家庄市","唐山市","保定市","廊坊市")
replace region_type = "Three Regions" if inlist(市, 	"上海市","南京市","无锡市","常州市","苏州市","南通市","扬州市")
replace region_type = "Three Regions" if inlist(市, "镇江市","泰州市","杭州市","宁波市","嘉兴市","湖州市","绍兴市")
replace region_type = "Three Regions" if inlist(市, 	"广州市","深圳市","珠海市","佛山市","江门市","肇庆市","惠州市","东莞市","中山市")

* 十群
replace region_type = "Ten City Clusters" if inlist(市, "沈阳市","济南市","青岛市","淄博市","潍坊市","日照市")
replace region_type = "Ten City Clusters" if inlist(市, "武汉市","长沙市","重庆市","成都市","福州市","三明市")
replace region_type = "Ten City Clusters" if inlist(市, "太原市","西安市","咸阳市","兰州市","银川市","乌鲁木齐市") 

gen plotvar = .
replace plotvar = 100 if region_type == "Three Regions"
replace plotvar = 80 if region_type == "Ten City Clusters"
replace plotvar = -1 if region_type == "Others"
rename 市 cityname

tempfile region_type
save `region_type', replace


use "$map_file/city_coord",replace
gen cityname = 市
replace cityname = "北京市" if strpos(cityname, "北京市") > 0
replace cityname = "天津市" if strpos(cityname, "天津市") > 0
replace cityname = "上海市" if strpos(cityname, "上海市") > 0
replace cityname = "重庆市" if strpos(cityname, "重庆市") > 0

merge m:1 cityname using `region_type', keep(1 3) nogen





* 绘图
grmap plotvar using "city_coord_shp.dta", ///
    id(_ID) ///
    fcolor("maroon" "navy") ///
    ocolor(gs10 ...) ///
    osize(vvthin ...) ///
    ndsize(vvthin) ///
    clmethod(custom) ///
    clnumber(3) ///
    clbreaks(0 80 100) ///
    line(data(city_line_corrd_shp) ///
    	 size(vvthin) by(group) ///
    	 select(drop if group == 4 | group == 7) ///
 		 color(gray%30 black "0 85 170" black black)) /// 
 	polygon(data(polygon) fcolor(black) osize(vvthin)) ///
 	label(data("chinacitymini_label") x(X) y(Y) label(ename) length(20) size(*1) select(keep if inlist(cname, "N", "1000km"))) ///
    legend( ///
	    label(1 "Others") ///
	    label(2 "Ten City Clusters") ///
	    label(3 "Three Regions") ///
	    position(7) ring(0) size(*1.2)) ///
    graphr(margin(zero)) 


