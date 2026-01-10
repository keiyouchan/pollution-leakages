global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw
* ------------------
import excel using "$raw/（1）子公司主数据.xlsx" , firstrow sheet("Sheet1") clear

drop 异地投资
drop 同行业投资
drop 异地同行投资

gen 异地投资 = (母公司办公地址所在城市 != 所属城市) if (!missing(母公司办公地址所在城市) & !missing(所属城市))
gen 同行业投资 = (母公司行业大类代码 == 子公司大类代码) if (!missing(母公司行业大类代码) & !missing(子公司大类代码))
gen 异地同行投资 = (异地投资 == 1 & 同行业投资 == 1)

gen cityname = 所属城市
drop 三区十群内的异地投资
gen  三区十群内的异地投资 = (cityname=="北京市" | cityname=="天津市" | cityname=="石家庄市" | cityname=="唐山市" | cityname=="保定市" | cityname=="廊坊市" | /// 
						    cityname=="上海市" | cityname=="南京市" | cityname=="无锡市" | cityname=="常州市" | cityname=="苏州市" | cityname=="南通市" | cityname=="扬州市" | cityname=="镇江市" | cityname=="泰州市" | cityname=="杭州市" | cityname=="宁波市" | cityname=="嘉兴市" | cityname=="湖州市" | cityname=="绍兴市" | ///
						    cityname=="广州市" | cityname=="深圳市" | cityname=="珠海市" | cityname=="佛山市" | cityname=="江门市" | cityname=="肇庆市" | cityname=="惠州市" | cityname=="东莞市" | cityname=="中山市" | /// 
						    /// 十群 
						    cityname=="沈阳市" | cityname=="济南市" | cityname=="青岛市" | cityname=="淄博市" | cityname=="潍坊市" | cityname=="日照市" | ///
						    cityname=="武汉市" | cityname=="长沙市" | cityname=="重庆市" | cityname=="成都市" | ///
						    cityname=="福州市" | cityname=="三明市" | cityname=="太原市" | cityname=="西安市" | cityname=="咸阳市" | cityname=="兰州市" | cityname=="银川市" | cityname=="乌鲁木齐市")

drop 处理组
gen  处理组 = (母公司办公地址所在城市=="北京市" | 母公司办公地址所在城市=="天津市" | 母公司办公地址所在城市=="石家庄市" | 母公司办公地址所在城市=="唐山市" | 母公司办公地址所在城市=="保定市" | 母公司办公地址所在城市=="廊坊市" | /// 
		    母公司办公地址所在城市=="上海市" | 母公司办公地址所在城市=="南京市" | 母公司办公地址所在城市=="无锡市" | 母公司办公地址所在城市=="常州市" | 母公司办公地址所在城市=="苏州市" | 母公司办公地址所在城市=="南通市" | 母公司办公地址所在城市=="扬州市" | 母公司办公地址所在城市=="镇江市" | 母公司办公地址所在城市=="泰州市" | 母公司办公地址所在城市=="杭州市" | 母公司办公地址所在城市=="宁波市" | 母公司办公地址所在城市=="嘉兴市" | 母公司办公地址所在城市=="湖州市" | 母公司办公地址所在城市=="绍兴市" | ///
		    母公司办公地址所在城市=="广州市" | 母公司办公地址所在城市=="深圳市" | 母公司办公地址所在城市=="珠海市" | 母公司办公地址所在城市=="佛山市" | 母公司办公地址所在城市=="江门市" | 母公司办公地址所在城市=="肇庆市" | 母公司办公地址所在城市=="惠州市" | 母公司办公地址所在城市=="东莞市" | 母公司办公地址所在城市=="中山市" | /// 
		    /// 十群 
		    母公司办公地址所在城市=="沈阳市" | 母公司办公地址所在城市=="济南市" | 母公司办公地址所在城市=="青岛市" | 母公司办公地址所在城市=="淄博市" | 母公司办公地址所在城市=="潍坊市" | 母公司办公地址所在城市=="日照市" | ///
		    母公司办公地址所在城市=="武汉市" | 母公司办公地址所在城市=="长沙市" | 母公司办公地址所在城市=="重庆市" | 母公司办公地址所在城市=="成都市" | ///
		    母公司办公地址所在城市=="福州市" | 母公司办公地址所在城市=="三明市" | 母公司办公地址所在城市=="太原市" | 母公司办公地址所在城市=="西安市" | 母公司办公地址所在城市=="咸阳市" | 母公司办公地址所在城市=="兰州市" | 母公司办公地址所在城市=="银川市" | 母公司办公地址所在城市=="乌鲁木齐市")
label var 处理组 "母公司位于三区十群"

save "$raw/子公司主数据.dta",replace
use "$raw/子公司主数据.dta",clear


* EOF
