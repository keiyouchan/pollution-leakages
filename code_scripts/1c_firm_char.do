global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
* ----------------
* get parent firm basic information

use "$raw/子公司主数据.dta",replace
keep 证券代码 year 母公司*
rename (证券代码 母公司行业门类 母公司行业大类代码 母公司办公地址所在省份 母公司办公地址所在城市 母公司办公地址所在区县) ///
	   (code indtype ind_2digit provname cityname countyname)
duplicates drop code,force

gen in_key_areas = (cityname=="北京市" | cityname=="天津市" | cityname=="石家庄市" | cityname=="唐山市" | cityname=="保定市" | cityname=="廊坊市" | /// 
				    cityname=="上海市" | cityname=="南京市" | cityname=="无锡市" | cityname=="常州市" | cityname=="苏州市" | cityname=="南通市" | cityname=="扬州市" | cityname=="镇江市" | cityname=="泰州市" | cityname=="杭州市" | cityname=="宁波市" | cityname=="嘉兴市" | cityname=="湖州市" | cityname=="绍兴市" | ///
				    cityname=="广州市" | cityname=="深圳市" | cityname=="珠海市" | cityname=="佛山市" | cityname=="江门市" | cityname=="肇庆市" | cityname=="惠州市" | cityname=="东莞市" | cityname=="中山市" | /// 
				    /// 十群 
				    cityname=="沈阳市" | cityname=="济南市" | cityname=="青岛市" | cityname=="淄博市" | cityname=="潍坊市" | cityname=="日照市" | ///
				    cityname=="武汉市" | cityname=="长沙市" | cityname=="重庆市" | cityname=="成都市" | ///
				    cityname=="福州市" | cityname=="三明市" | cityname=="太原市" | cityname=="西安市" | cityname=="咸阳市" | cityname=="兰州市" | cityname=="银川市" | cityname=="乌鲁木齐市")


gen in_3regions =  (cityname=="北京市" | cityname=="天津市" | cityname=="石家庄市" | cityname=="唐山市" | cityname=="保定市" | cityname=="廊坊市" | /// 
				    cityname=="上海市" | cityname=="南京市" | cityname=="无锡市" | cityname=="常州市" | cityname=="苏州市" | cityname=="南通市" | cityname=="扬州市" | cityname=="镇江市" | cityname=="泰州市" | cityname=="杭州市" | cityname=="宁波市" | cityname=="嘉兴市" | cityname=="湖州市" | cityname=="绍兴市" | ///
				    cityname=="广州市" | cityname=="深圳市" | cityname=="珠海市" | cityname=="佛山市" | cityname=="江门市" | cityname=="肇庆市" | cityname=="惠州市" | cityname=="东莞市" | cityname=="中山市" )


gen in_10clusters = (cityname=="沈阳市" | cityname=="济南市" | cityname=="青岛市" | cityname=="淄博市" | cityname=="潍坊市" | cityname=="日照市" | ///
				    cityname=="武汉市" | cityname=="长沙市" | cityname=="重庆市" | cityname=="成都市" | ///
				    cityname=="福州市" | cityname=="三明市" | cityname=="太原市" | cityname=="西安市" | cityname=="咸阳市" | cityname=="兰州市" | cityname=="银川市" | cityname=="乌鲁木齐市")

label var in_key_areas "位于三区十群"
label var in_3regions  "位于三区"
label var in_10clusters "位于十群"

foreach i of varlist _all{
	cap format `i' %15s
}

destring code, replace 
sort code year 


save "$interm/parent_info.dta",replace

*** EOF