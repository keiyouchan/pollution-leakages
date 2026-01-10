/*
global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $interm
*/
* ----------------
* mannual revise
replace stock = 11924.98 if subfirm == "中电投沧州渤海新区新能源发电有限公司" & stock == .
replace stock = 2147.42 if subfirm == "中粮屯河伊犁新宁糖业有限公司" & stock == .
replace stock = 7000 if subfirm == "上海一毛条纺织重庆有限公司" & stock == .
replace stock = 31075.73 if subfirm == "和田青松建材有限责任公司" & stock == .
replace stock = 3825.00 if subfirm == "咸宁南玻光电玻璃有限公司" & stock == .
replace stock = 36634.37 if subfirm == "哈密新天山水泥有限责任公司" & stock == .
	replace netinc = 5000 if subfirm == "哈密新天山水泥有限责任公司" & year == 2010
	replace inc = 5000 if subfirm == "哈密新天山水泥有限责任公司" & year == 2010
replace stock = 4250 if subfirm == "四川美丰农资化工有限责任公司" & stock == .
	replace netinc = 0 if subfirm == "四川美丰农资化工有限责任公司" & year == 2011
replace stock = 7920 if subfirm == "四川美丰化肥有限责任公司" & stock == .
	replace netinc = 0 if subfirm == "四川美丰化肥有限责任公司" & year == 2011
	replace inc = 0 if subfirm == "四川美丰化肥有限责任公司" & year == 2011
replace stock = 16150.00 if subfirm == "国投哈密风电有限公司" & stock == .
replace stock = 200 if subfirm == "国投宁夏风电有限公司" & stock == .
	replace stock = 200 if subfirm == "国投宁夏风电有限公司" & year == 2015
	replace netinc = 0 if subfirm == "国投宁夏风电有限公司" & year == 2015

replace stock = 1000 if subfirm == "上海福耀客车玻璃有限公司" & year == 2010 & stock == .
replace stock = 2000 if subfirm == "上海福耀客车玻璃有限公司" & stock == .
	replace netinc = 1000 if subfirm == "上海福耀客车玻璃有限公司" & year == 2011
	replace inc = 1000 if subfirm == "上海福耀客车玻璃有限公司" & year == 2011
	replace netinc = 0 if (subfirm == "上海福耀客车玻璃有限公司") & (year == 2012 | year == 2014 | year == 2016)
	replace inc = 0 if (subfirm == "上海福耀客车玻璃有限公司") & (year == 2012 | year == 2014 | year == 2016)

replace stock = 0 if subfirm == "东川澄星磷业有限公司" & stock == .
	replace netinc = 0 if subfirm == "东川澄星磷业有限公司" & year == 2010

replace stock = 7842.12 if subfirm == "大唐华银张家界水电有限公司" & year == 2013 
	replace netinc = 0 if subfirm == "大唐华银张家界水电有限公司" & year == 2013 
	replace netinc = 21756.13 - 7842.12 if subfirm == "大唐华银张家界水电有限公司" & year == 2015
	replace inc = 21756.13 - 7842.12 if subfirm == "大唐华银张家界水电有限公司" & year == 2015

* replace stock = 0 if subfirm == "上海三爱富新材料股份有限公司蔡路工厂" & stock == .

replace stock = 5152.96 if subfirm == "东莞南玻陶瓷科技有限公司" & year == 2011
replace stock = 5152.96 + 153.25 if subfirm == "东莞南玻陶瓷科技有限公司" & year == 2010

replace stock = 32800 if subfirm == "华能湖南湘祁水电有限责任公司" & year == 2013
	replace netinc = 0 if subfirm == "华能湖南湘祁水电有限责任公司" & year == 2013
	replace netinc = 0 if subfirm == "华能湖南湘祁水电有限责任公司" & year == 2014
	replace inc = 0 if subfirm == "华能湖南湘祁水电有限责任公司" & year == 2014
replace stock = 71917 if subfirm == "华能玉门风电有限责任公司" & year == 2013
	bysort subfirm (year): replace netinc = stock[_n] - stock[_n - 1] if subfirm == "华能玉门风电有限责任公司"
	replace netinc = 54796.75 if subfirm == "华能玉门风电有限责任公司" & year == 2012
replace stock = 520516.6 if subfirm == "华能云南滇东能源有限责任公司" & year == 2013
	bysort subfirm (year): replace netinc = stock[_n] - stock[_n - 1] if subfirm == "华能云南滇东能源有限责任公司"
	bysort subfirm (year): replace netinc = cond(_n == 1 & year == setup_year, stock , 0 ) if subfirm == "华能云南滇东能源有限责任公司"

replace stock = 11177.78 if subfirm == "云南云铝涌鑫铝业有限公司" & year == 2010
	replace netinc = 5861.11 if subfirm == "云南云铝涌鑫铝业有限公司" & year == 2010
	replace inc = 5861.11 if subfirm == "云南云铝涌鑫铝业有限公司" & year == 2010

replace stock = 0 if subfirm == "云南大唐国际文山水电开发有限公司" & year == 2010
replace stock = 0 if subfirm == "云南大唐国际横江水电开发有限公司" & year == 2010

replace stock = 156630 if subfirm == "云南文山铝业有限公司" & year == 2010 

drop if subfirm == "兰州博亚饲料有限公司"

replace stock = 0 if subfirm == "冀东水泥辽阳弓长岭有限责任公司"  & year == 2010
	replace netinc = -5000 if subfirm == "冀东水泥辽阳弓长岭有限责任公司"  & year == 2010


* 600578
replace stock = 30385.5 if subfirm == "内蒙古京科发电有限公司" & (year == 2010 | year == 2011)

* 601991 
replace stock = 0 if subfirm == "内蒙古大唐国际卓资风电有限责任公司" & year == 2010
replace stock = 20490.2 if subfirm == "内蒙古大唐国际呼和浩特热电有限责任公司" & (year == 2010 | year == 2011 | 2013)
replace stock = 102841.4 if subfirm == "内蒙古大唐国际托克托发电有限责任公司" & (year == 2010 | year == 2011 | 2013)
replace stock = 60691 if subfirm == "内蒙古大唐国际新能源有限公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 55449 if subfirm == "内蒙古大唐国际风电开发有限公司" & year == 2010
	replace netinc = 35449 if subfirm == "内蒙古大唐国际风电开发有限公司" & year == 2010
	replace inc = 35449 if subfirm == "内蒙古大唐国际风电开发有限公司" & year == 2010
	replace netinc = 0 if subfirm == "内蒙古大唐国际呼和浩特热电有限责任公司" & year == 2013
	replace netinc = 0 if subfirm == "内蒙古大唐国际新能源有限公司" & year == 2013

replace stock = 2.98 if subfirm == "内蒙古大唐国际锡林浩特发电有限责任公司" & year == 2015
replace stock = 2.98 if subfirm == "内蒙古大唐国际锡林浩特发电有限责任公司" & year == 2016 
	replace netinc = 0 if subfirm == "内蒙古大唐国际锡林浩特发电有限责任公司" & year == 2016 

replace stock = 10000 if subfirm == "江西大唐国际抚州发电有限责任公司" & year == 2011
replace stock = 48400 if subfirm == "江西大唐国际抚州发电有限责任公司" & year == 2012
replace stock = 68400 if subfirm == "江西大唐国际抚州发电有限责任公司" & year == 2013
replace stock = 68400 if subfirm == "江西大唐国际抚州发电有限责任公司" & year == 2014
replace stock = 92392.4 if subfirm == "江西大唐国际抚州发电有限责任公司" & year == 2015

replace stock = 45800 if subfirm == "河北大唐国际张家口热电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 72413 if subfirm == "河北大唐国际新能源有限公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 31500 if subfirm == "河北大唐国际王滩发电有限责任公司"  & (year == 2013 | year == 2014 | year == 2015)
replace stock = 20050 if subfirm == "河北大唐国际迁安热电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 30421.1 if subfirm == "河北大唐国际唐山热电有限责任公司" & (year == 2010 | year == 2013 | year == 2014 | year == 2015)
replace stock = 33018 if subfirm == "河北大唐国际丰润热电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 9388 if subfirm == "重庆大唐国际武隆兴顺风电有限责任公司" & (year == 2010 | year == 2014 | year == 2015)
replace stock = 4000 if subfirm == "辽宁大唐国际瓦房店热电有限责任公司" & (year == 2011 | year == 2013 | year == 2014 | year == 2015)
replace stock = 7896 if subfirm == "辽宁大唐国际沈东热电有限责任公司" & year == 2015
replace stock = 1000 if subfirm == "辽宁大唐国际沈东热电有限责任公司" & year == 2014

replace stock = 43926.8 if subfirm == "重庆大唐国际彭水水电开发有限公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 31000 if subfirm == "西藏大唐国际怒江上游水电开发有限公司" & (year == 2014 | year == 2015)
replace stock = 176632.2 if subfirm == "云南大唐国际电力有限公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 20000 if subfirm == "云南大唐国际电力有限公司" & (year == 2013 | year == 2014)
replace stock = 30000 if subfirm == "云南大唐国际电力有限公司" & (year == 2015)
replace stock = 2976 if subfirm == "内蒙古大唐国际锡林浩特发电有限责任公司" & (year == 2015 | year == 2016)
replace stock = 2000 if subfirm == "四川大唐国际新能源有限公司" & (year == 2014 | year == 2015)
replace stock = 257317.6 if subfirm == "四川大唐国际甘孜水电开发有限公司" & year == 2015
replace stock = 181359.6 if subfirm == "四川大唐国际甘孜水电开发有限公司" & year == 2014
replace stock = 128200.6 if subfirm == "四川大唐国际甘孜水电开发有限公司" & year == 2013
replace stock = 107924.2 if subfirm == "四川金康电力发展有限公司" & year == 2015
replace stock = 62344 if subfirm == "天津大唐国际盘山发电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 24729 if subfirm == "宁夏大唐国际大坝发电有限责任公司" & (year == 2013 | year == 2014)
replace stock = 21111.9 if subfirm == "宁夏大唐国际大坝发电有限责任公司" & (year == 2015)
replace stock = 23413.8 if subfirm == "宁夏大唐国际新能源有限公司" & year == 2014
replace stock = 31583.8 if subfirm == "宁夏大唐国际新能源有限公司" & year == 2015
replace stock = 28601 if subfirm == "山西大唐国际临汾热电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 75093.9 if subfirm == "山西大唐国际云冈热电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 30960 if subfirm == " 山西大唐国际新能源有限公司" & year == 2014
replace stock = 33222 if subfirm == " 山西大唐国际新能源有限公司" & year == 2015
replace stock = 44940 if subfirm == "山西大唐国际神头发电有限责任公司" & (year == 2013 | year == 2014 | year == 2015 )
replace stock = 83000 if subfirm == "山西大唐国际运城发电有限责任公司" & (year == 2010)
replace stock = 100800 if subfirm == "山西大唐国际运城发电有限责任公司" & year == 2011
replace stock = 293990 if subfirm == "广东大唐国际潮州发电有限责任公司" & (year == 2010 | year == 2013 | year == 2014 |year == 2015)
replace stock = 9318.1 if subfirm == "广东大唐国际肇庆热电有限责任公司" & year == 2015
replace stock = 4912.1 if subfirm == "广东大唐国际肇庆热电有限责任公司" & year == 2014
replace stock = 2050 if subfirm == "广东大唐国际雷州发电有限责任公司" & year == 2015
replace stock = 43618.9 if subfirm == "成都利国能源有限公司" & (year == 2013 | year == 2014)
replace stock = 57760 if subfirm == "江苏大唐国际吕四港发电有限责任公司" & (year == 2010 | year == 2013 | year == 2014 | year ==2015)
replace stock = 102 if subfirm == "江西大唐国际宜春煤电有限责任公司" & ( year == 2014 | year == 2015 )
replace stock = 47581 if subfirm == "江西大唐国际新余发电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 36644 if subfirm == "江西大唐国际新能源有限公司" & year == 2015
replace stock = 30233 if subfirm == "江西大唐国际新能源有限公司" & year == 2014
replace stock = 30421.1 if subfirm == "河北大唐唐山热电有限责任公司" & (year == 2011 | year == 2010 | year == 2012)
	replace netinc = 0 if subfirm == "河北大唐唐山热电有限责任公司" 
	replace inc = 0 if subfirm == "河北大唐唐山热电有限责任公司" 
replace stock = 3791 if subfirm == "河北大唐国际唐山北郊热电有限责任公司" & year == 2015
replace stock = 86700 if subfirm == "浙江大唐乌沙山发电有限责任公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 25247 if subfirm == "浙江大唐国际江山新城热电有限责任公司" & year == 2014
replace stock = 26174 if subfirm == "浙江大唐国际江山新城热电有限责任公司" & year == 2015
replace stock = 54000 if subfirm == "浙江大唐国际绍兴江滨热电有限责任公司" & (year == 2014 | year == 2015)
replace stock = 32600 if subfirm == "深圳大唐宝昌燃气发电有限公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 15153 if subfirm == "甘肃大唐国际连城发电有限责任公司" & ( year == 2014 | year == 2015)
replace stock = 42080 if subfirm == "福建大唐国际宁德发电有限责任公司" & (year == 2013 | year == 2014 |year == 2015)
replace stock = 45086 if subfirm == "福建大唐国际新能源有限公司" & (year == 2014 |year == 2015)
replace stock = 10000 if subfirm == "西藏大唐国际怒江上游水电开发有限公司" & year == 2011
replace stock = 92557 if subfirm == "辽宁大唐国际新能源有限公司" & (year == 2013 | year == 2014 | year == 2015)
replace stock = 36800 if subfirm == "辽宁大唐国际锦州热电有限责任公司" & ( year == 2013 | year == 2014 | year == 2015)
replace stock = 71378 if subfirm == "重庆大唐国际武隆水电开发有限公司" & year == 2013 
replace stock = 76547 if subfirm == "重庆大唐国际武隆水电开发有限公司" & (year == 2014 | year == 2015 )
replace stock = 41031 if subfirm == "重庆大唐国际石柱发电有限责任公司" & (year == 2014 | year == 2015)
replace stock = 9568 if subfirm == "青海大唐国际新能源有限公司" & year == 2014
replace stock = 11063 if subfirm == "青海大唐国际新能源有限公司" & year == 2015
replace stock = 7997 if subfirm == "青海大唐国际格尔木光伏发电有限责任公司" & year == 2014
replace stock = 11063 if subfirm == "青海大唐国际格尔木光伏发电有限责任公司" & year == 2015
replace stock = 700 if subfirm == "重庆大唐国际石柱发电有限责任公司" & year == 2011
replace stock = 33222 if subfirm == "山西大唐国际新能源有限公司" & year == 2015
replace stock = 30960 if subfirm == "山西大唐国际新能源有限公司" & year == 2014
replace stock = 20000 if subfirm == "内蒙古大唐国际托克托第二发电有限责任公司" & (year == 2013 | year == 2014)
replace stock = 30000 if subfirm == "内蒙古大唐国际托克托第二发电有限责任公司" & (year == 2015)
replace stock = 62497 if subfirm == "河北大唐国际风电开发有限公司" & year == 2011
replace stock = 57023 if subfirm == "河北大唐国际风电开发有限公司" & year == 2010
replace stock = 55760 if subfirm == "江苏大唐吕四港发电有限责任公司" & (year == 2010 | year == 2011 | year == 2012)
	replace netinc = 0 if subfirm == "江苏大唐吕四港发电有限责任公司" 
	replace inc = 0 if subfirm == "江苏大唐吕四港发电有限责任公司" 


* 600597
replace stock = 1944.94 if subfirm == "北京光明健康乳业有限公司" & year == 2010
replace stock = 10759 if subfirm == "北京光明健能乳业有限公司" & (year == 2010 | year == 2011)

* 600021 
replace stock = 1000 if subfirm == "华电佛山能源有限公司" & year == 2014
replace stock = 108000 if subfirm == "华电莱州发电有限公司" & (year == 2011 | year == 2010)

* 600027
replace stock = 5500 if subfirm == "河北华电康保风电有限公司" & (year == 2010 | year == 2011)


* 600795
replace stock = 80735 if subfirm == "国电和风大安风电开发有限公司" & year == 2010
	replace netinc = 50500 if subfirm == "国电和风大安风电开发有限公司" & year == 2010
	replace inc = 50500 if subfirm == "国电和风大安风电开发有限公司" & year == 2010

* 000898
replace stock = 140700 if subfirm == "天津鞍钢天铁冷轧薄板有限公司" & year == 2010
replace stock = 185000 if subfirm == "天津鞍钢天铁冷轧薄板有限公司" & year == 2012
replace stock = 1900 if subfirm == "上海鞍钢钢材加工有限公司" & year == 2013
replace stock = 500 if subfirm == "上海鞍钢钢材加工有限公司" & year <= 2012

* 601600
replace stock = 86526 if subfirm == "山东华宇铝电有限公司" & year == 2015

* 000877

* 601600
replace stock = 27030 if subfirm == "甘肃华鹭铝业有限公司" & (year == 2015 | year == 2016)


* 000912
replace stock = 0 if subfirm == "内蒙古天河化工有限责任公司" & year == 2010

* 600737
replace stock = 3600 if subfirm == "内蒙古屯河河套番茄制品有限责任公司" & (year == 2010 | year == 2011)
replace stock = 0 if subfirm == "内蒙古屯河河套番茄制品有限责任公司" & year == 2017
replace stock = 3600 if subfirm == "内蒙古屯河河套番茄制品有限责任公司" & year == 2014

* 600089
replace stock  =  3664 if subfirm == "上海一毛条纺织重庆有限公司" & year == 2017 
	replace netinc = -3200 if subfirm == "上海一毛条纺织重庆有限公司" & year == 2017

* 600801 
replace stock = 8968.02 if subfirm == "华新南通水泥有限公司" & year == 2010
replace stock = 1465.8136 if subfirm == "华新水泥(仙桃)有限公司" & (year == 2010 | year == 2011)
replace stock = 4000 if subfirm == "华新水泥襄樊襄城有限公司" & year == 2010
	replace netinc = 0 if subfirm == "华新水泥襄阳襄城有限公司" & year == 2011
	replace subfirm = "华新水泥襄阳襄城有限公司" if subfirm == "华新水泥襄樊襄城有限公司"  & year == 2010
	drop if subfirm == "华新水泥襄樊襄城有限公司"
	drop if subfirm == "华新混凝土荆门有限公司"
	drop if subfirm == "华新混凝土(黄石)有限公司"
replace stock = 0 if subfirm == "华新金猫水泥(苏州)有限公司" & year == 2010

* 600425
replace stock = . if subfirm == "伊犁南岗混凝土制品有限责任公司" & year == 2015
	replace netinc = 0 if subfirm == "伊犁南岗混凝土制品有限责任公司" & year == 2015 
	replace inc = 0 if subfirm == "伊犁南岗混凝土制品有限责任公司" & year == 2015

* 000707
replace stock = 0 if subfirm == "重庆宜化化工有限公司" & year == 2010

* 300072
replace stock = 2175 if subfirm == "苏州恒升新材料有限公司" & year == 2010
	replace netinc = 0 if subfirm == "苏州恒升新材料有限公司" & year == 2010
	replace inc = 0 if subfirm == "苏州恒升新材料有限公司" & year == 2010

* 002100
replace stock = 0 if subfirm == "伊犁天康畜牧科技有限公司" & year == 2013
replace stock = 424.28 if subfirm == "伊犁天康畜牧科技有限公司" & year == 2010
	replace netinc = 114 if subfirm == "伊犁天康畜牧科技有限公司" & year == 2010
	replace inc = 114 if subfirm == "伊犁天康畜牧科技有限公司" & year == 2010
	replace netinc = 0 if subfirm == "伊犁天康畜牧科技有限公司" & year == 2011
	replace inc = 0 if subfirm == "伊犁天康畜牧科技有限公司" & year == 2011

* 000422 
	replace netinc = 0 if subfirm  == "湖北宜化松滋肥业有限公司"
	replace inc    = 0 if subfirm  == "湖北宜化松滋肥业有限公司"
replace stock = 51000      if subfirm == "内蒙古鄂尔多斯联合化工有限公司" & year == 2010
	replace netinc = 25500 if subfirm == "内蒙古鄂尔多斯联合化工有限公司" & year == 2010
	replace inc    = 25500 if subfirm == "内蒙古鄂尔多斯联合化工有限公司" & year == 2010
	replace netinc = 0     if subfirm == "内蒙古鄂尔多斯联合化工有限公司" & year == 2011
	replace inc    = 0     if subfirm == "内蒙古鄂尔多斯联合化工有限公司" & year == 2011
replace in_key_dummy = 0   if subfirm == "湖北宜化肥业有限公司"
replace treatmen     = 0   if subfirm == "湖北宜化肥业有限公司"

* 002004 
replace stock = 4986.51 if subfirm == "杭州庆丰农化有限公司" & (year == 2012)
replace stock = 21003.25 if subfirm == "杭州庆丰农化有限公司" & (year == 2013)
replace stock = 0 if subfirm == "杭州庆丰农化有限公司" & year == 2014

* 600470
replace stock = 7637.04 if subfirm == "宜昌市鑫冠化工有限公司" & (year == 2011)
replace stock = 3047.05 if subfirm == "宜昌市鑫冠化工有限公司" & (year == 2010)
	replace netinc = 0 if subfirm == "宜昌市鑫冠化工有限公司" & year == 2012
	replace netinc = 0 if subfirm == "宜昌市鑫冠化工有限公司" & year == 2010
	replace inc = 0 if subfirm == "宜昌市鑫冠化工有限公司" & year == 2012
	replace inc = 0 if subfirm == "宜昌市鑫冠化工有限公司" & year == 2010
replace stock      = 190000 if subfirm == "新疆宜化化工有限公司" & year == 2011
	replace netinc = 140000 if subfirm == "新疆宜化化工有限公司" & year == 2011
	replace inc    = 140000 if subfirm == "新疆宜化化工有限公司" & year == 2011
	replace netinc = 0      if subfirm == "新疆宜化化工有限公司" & year == 2012
	replace inc    = 0      if subfirm == "新疆宜化化工有限公司" & year == 2012
	replace netinc = 0      if subfirm == "新疆宜化化工有限公司" & year == 2013
	replace inc    = 0      if subfirm == "新疆宜化化工有限公司" & year == 2013
replace stock      = 10000  if subfirm == "贵州金江化工有限公司" & year == 2011
* 002215
replace stock = 300 if subfirm == "陕西康盈作物营养有限公司" 
	replace netinc = 0 if subfirm == "陕西康盈作物营养有限公司" 
	replace inc = 0 if subfirm == "陕西康盈作物营养有限公司" 

* 002311
replace stock = 66.02 if subfirm == "鄂州海大饲料有限公司" & year == 2011
replace stock = 66.02 if subfirm == "鄂州海大饲料有限公司" & year == 2010

* 002394
replace stock = 0 if subfirm == "阿克苏联发纺织有限公司"

* 002385
replace stock = 0 if subfirm == "三明大北农农牧科技有限公司" 
drop if subfirm == "三明大北农农牧科技有限公司" 

* 002302
replace stock = 0 if subfirm == "中建商品混凝土云南有限公司"
	replace netinc = 0 if subfirm == "中建商品混凝土云南有限公司"
	replace inc = 0 if subfirm == "中建商品混凝土云南有限公司"

* 601005
replace stock = 5100 if subfirm == "靖江三峰钢材加工配送有限公司" & year == 2011 

* 000825
replace stock = 3801.08 if subfirm == "佛山太钢昌宝联金属科技有限公司" & year == 2011
replace stock = 3801.08 if subfirm == "佛山太钢昌宝联金属科技有限公司" & year == 2012
	replace netinc = 0 if subfirm == "广东太钢不锈钢加工配送有限公司" & year == 2012
	replace inc = 0 if subfirm == "广东太钢不锈钢加工配送有限公司" & year == 2012
	replace subfirm = "广东太钢不锈钢加工配送有限公司" if subfirm == "佛山太钢昌宝联金属科技有限公司"


* 600141
replace stock = 910 if subfirm == "保康庄园肥业有限责任公司" & year == 2011
replace stock = 910 if subfirm == "保康庄园肥业有限责任公司" & year == 2012
replace stock = 910 if subfirm == "保康庄园肥业有限责任公司" & year == 2013
replace stock = 910 if subfirm == "保康庄园肥业有限责任公司" & year == 2014

* 002078
replace stock = 0 if subfirm == "兖州合利纸业有限公司" & year == 2013
	replace netinc = -17376.97 if subfirm == "兖州合利纸业有限公司" & year == 2013

* 600636
replace stock = 0 if subfirm == "内蒙古三爱富万豪氟化工有限公司" & year == 2011
	replace netinc = 0 if subfirm == "内蒙古三爱富万豪氟化工有限公司" & year == 2011
	replace inc = 0 if subfirm == "内蒙古三爱富万豪氟化工有限公司" & year == 2011
replace stock = 5265 if subfirm == "内蒙古三爱富万豪氟化工有限公司" & year == 2013
	replace netinc = 0 if subfirm == "内蒙古三爱富万豪氟化工有限公司" & year == 2013
	replace inc = 0 if subfirm == "内蒙古三爱富万豪氟化工有限公司" & year == 2013

* 000966
replace stock = 0 if subfirm == "十堰陡岭子水电有限责任公司" & year == 2010


* 600801
replace stock = 2250 if subfirm == "华新水泥(岳阳)有限公司" & (year == 2015 | year == 2016 | year == 2017)
	replace netinc = 0 if subfirm == "华新水泥(岳阳)有限公司" & (year == 2015 | year == 2017)
	replace inc = 0 if subfirm == "华新水泥(岳阳)有限公司" & (year == 2015 | year == 2017)

* 601600
replace subfirm = "包头铝业有限公司" if subfirm == "包头铝业股份有限公司"
replace stock = 342055.4 if subfirm == "包头铝业有限公司" & (year == 2014 | year == 2015 | year == 2016 | year == 2017)

replace stock = 240157.4 if subfirm == "包头铝业有限公司" & year == 2012
replace stock = 225157.4 if subfirm == "包头铝业有限公司" & year == 2011
replace stock = 225157.4 if subfirm == "包头铝业有限公司" & year == 2010
duplicates drop subfirm year stock if subfirm == "包头铝业有限公司",force
bysort subfirm (year) : replace netinc = stock[_n] - stock[_n - 1] if subfirm == "包头铝业有限公司"
	replace netinc = 0 if subfirm == "包头铝业有限公司" & year == 2010

replace stock = 20558.7 if subfirm == "中国铝业郑州有色金属研究院有限公司" & year == 2015

* 002225
replace stock = 37104.04 if subfirm == "郑州汇特耐火材料有限公司" & year == 2016

* 002211
replace stock = 60957.92 if subfirm == "江苏利洪硅材料有限公司" & (year == 2011 | year == 2010)

* 002066
replace stock = 7875 if subfirm == "郑州瑞泰耐火科技有限公司" & (year == 2012 | year == 2014)
replace stock = 3850 if subfirm == "郑州瑞泰耐火科技有限公司" & (year == 2011)
	bysort subfirm (year) : replace netinc = stock[_n] - stock[_n - 1] if subfirm == "郑州瑞泰耐火科技有限公司"
		replace netinc = 3850 if subfirm == "郑州瑞泰耐火科技有限公司" & year == 2011


* 600616
replace netinc = 0 if subfirm == "宁夏石嘴山龙原炭素有限公司" & year == 2010
replace inc = 0 if subfirm == "宁夏石嘴山龙原炭素有限公司" & year == 2010

* 000600
replace stock = 22360 if subfirm == "河北建投沙河发电有限责任公司" & year == 2010
	bysort subfirm (year) : replace netinc = stock[_n] - stock[_n - 1] if subfirm == "河北建投沙河发电有限责任公司"
	replace netinc = 13460 if subfirm == "河北建投沙河发电有限责任公司" & year == 2010
	replace inc = 13460 if subfirm == "河北建投沙河发电有限责任公司" & year == 2010


* 002012 
replace stock = 1740 if subfirm == "浙江凯丰纸业有限公司" & year == 2013
replace stock = 1740 if subfirm == "浙江凯丰纸业有限公司" & year == 2014
	replace netinc = 0 if subfirm == "浙江凯丰纸业有限公司"  & year == 2014
	replace subfirm = "浙江凯丰纸业有限公司" if subfirm == "浙江凯丰新材料股份有限公司" 
	drop if subfirm == "浙江凯丰纸业有限公司"  & year == 2015 & stock == 0

replace stock = 4000 if subfirm == "浙江凯丰特种纸业有限公司" 
	replace netinc = 0 if subfirm == "浙江凯丰特种纸业有限公司"  

* 002453
replace netinc = 8000  if subfirm == "南通市纳百园化工有限公司" & year == 2011
replace netinc = 10740 if subfirm == "山东天安化工股份有限公司" & year == 2011

* 002470
replace stock = 223000 if subfirm == "贵州金正大生态工程有限公司" & year == 2014
	replace netinc = 0 if subfirm == "贵州金正大生态工程有限公司" & year == 2014
	replace inc = 0    if subfirm == "贵州金正大生态工程有限公司" & year == 2014

* 002495
replace stock = 1000 if subfirm == "佳隆食品夏津有限公司" & year == 2017
replace stock = 1000 if subfirm == "广州市佳隆食品有限公司"

* 000012
replace stock = 20058.81 if subfirm == "广州南玻玻璃有限公司" & year == 2010
replace stock = 20108.30 if subfirm == "广州南玻玻璃有限公司" & year == 2011
replace stock = 0        if subfirm == "广州南玻玻璃有限公司" & year == 2012
replace stock = 0        if subfirm == "东莞南玻陶瓷科技有限公司" & year == 2011

* 000027 
replace stock  = 11587.24 if subfirm == "东莞深能源樟洋电力有限公司" & year == 2010
replace netinc = 200      if subfirm == "丰县深能新能源有限公司"     & year == 2017  
replace inc    = 200      if subfirm == "丰县深能新能源有限公司"     & year == 2017 
replace stock  = 200      if subfirm == "安陆深能新能源有限公司"    
replace stock  = 7749     if subfirm == "宿州市泗县深能环保有限公司" 
replace stock  = 4080     if subfirm == "屏南县旺坑水电有限公司"    
replace stock  = 10400    if subfirm == "库尔勒深能热力有限公司"
replace stock  = 3200     if subfirm == "徐州正辉太阳能电力有限公司"
replace stock  = 8500     if subfirm == "武威深能北方能源开发有限公司"
	replace netinc = 8500 if subfirm == "武威深能北方能源开发有限公司" & year == 2014
	replace inc = 8500    if subfirm == "武威深能北方能源开发有限公司" & year == 2014
replace stock  = 5100     if subfirm == "沛县苏新光伏电力有限公司" 
replace stock  = 20606    if subfirm == "浙江省景宁英川水电开发有限责任公司"
replace stock  = 22536    if subfirm == "深能保定热力有限公司" 
	replace netinc  = 22536    if subfirm == "深能保定热力有限公司" & year == 2016
	replace inc     = 22536    if subfirm == "深能保定热力有限公司" & year == 2016
replace stock  = 3500     if subfirm == "深能北方(通辽)奈曼能源开发有限公司" 
	replace netinc  = 3500     if subfirm == "深能北方(通辽)奈曼能源开发有限公司" & year == 2015
	replace inc     = 3500     if subfirm == "深能北方(通辽)奈曼能源开发有限公司" & year == 2015
replace stock  = 8980     if subfirm == "深能北方(通辽)扎鲁特能源开发有限公司"
	replace netinc  = 8980     if subfirm == "深能北方(通辽)扎鲁特能源开发有限公司" & year == 2014
	replace inc     = 8980     if subfirm == "深能北方(通辽)扎鲁特能源开发有限公司" & year == 2014
replace stock  = 3260     if subfirm == "甘孜州冰川水电开发有限公司"
replace stock  = 10500    if subfirm == "盐源县卧罗河电力有限责任公司"
replace stock  = 200      if subfirm == "盐源深能新能源有限公司"
	replace netinc = 200  if subfirm == "盐源深能新能源有限公司" & year == 2016
replace stock  = 21380    if subfirm == "禄劝小蓬祖发电有限公司"
replace stock  = 6000     if subfirm == "福贡县恒大水电开发有限公司"
replace stock  = 4620     if subfirm == "福贡西能电力发展有限公司"
replace stock  = 2031     if subfirm == "葫芦岛深能北方能源开发有限公司"
	replace netinc = 2031 if subfirm == "葫芦岛深能北方能源开发有限公司" & year == 2016
	replace inc    = 2031 if subfirm == "葫芦岛深能北方能源开发有限公司" & year == 2016
replace stock  = 500      if subfirm == "贵溪深能新能源有限公司"
	replace netinc  = 500      if subfirm == "贵溪深能新能源有限公司" & year == 2016
	replace inc     = 500      if subfirm == "贵溪深能新能源有限公司" & year == 2016
replace stock  = 22495.82 if subfirm == "遂昌县九龙山水电开发有限公司" 
replace stock  = 9948     if subfirm == "遂昌县周公源水电开发有限公司" 
replace stock  = 19100    if subfirm == "邢台县永联光伏发电开发有限公司"
	replace netinc = 19100 if subfirm == "邢台县永联光伏发电开发有限公司" & year == 2014
	replace inc =    19100 if subfirm == "邢台县永联光伏发电开发有限公司" & year == 2014
replace stock  = 1240     if subfirm == "邳州市方华力恒能源科技有限公司"
	replace netinc  = 1240     if subfirm == "邳州市方华力恒能源科技有限公司" & year == 2014
	replace inc     = 1240     if subfirm == "邳州市方华力恒能源科技有限公司" & year == 2014
replace stock  = 8100     if subfirm == "邳州市深能风力发电有限公司"
	replace netinc = 8100 if subfirm == "邳州市深能风力发电有限公司" & year == 2016
	replace inc    = 8100 if subfirm == "邳州市深能风力发电有限公司" & year == 2016
replace stock = 3000      if subfirm == "邵武市金卫水电有限公司" 
replace stock = 5180      if subfirm == "邵武市金岭发电有限公司" 
replace stock = 1200      if subfirm == "邵武市金溏水电有限公司"
replace stock = 1700      if subfirm == "邵武市金龙水电有限公司"
replace stock = 1200      if subfirm == "金平康宏水电开发有限公司"
replace stock = 25809.58  if subfirm == "青田五里亭水电开发有限公司"
replace stock = 20000     if subfirm == "高邮协合风力发电有限公司"
	replace netinc = 20000 if subfirm == "高邮协合风力发电有限公司" & year == 2013
	replace inc    = 20000 if subfirm == "高邮协合风力发电有限公司" & year == 2013
replace stock = 5650      if subfirm == "龙泉瑞垟二级水电站有限公司"


* 600309
replace stock = 60792 if subfirm == "宁波万华容威聚氨酯有限公司" & (year == 2012 | year == 2013 | year == 2011 | year == 2010 )
replace stock = 60792 if subfirm == "宁波万华聚氨酯有限公司" & (year == 2013)

* 000972
replace stock = 47280 if subfirm == "新疆中基蕃茄制品有限责任公司" & year == 2014
	replace netinc = 0 if subfirm == "新疆中基蕃茄制品有限责任公司" & year == 2014

* 000877
replace stock = 1800 if subfirm == "新疆巴州天山水泥有限责任公司" & year == 2010
replace stock = 1800 if subfirm == "新疆巴州天山水泥有限责任公司" & year == 2015
replace stock = 1455.16 if subfirm == "库尔勒天山神州混凝土有限责任公司" & year == 2011

* 002042
replace stock = 5000 if subfirm == "肥东华孚色纺有限公司" 


* 600251
replace netinc = 0 if subfirm == "新疆皮山冠农果蔬食品有限责任公司" & year == 2011
replace inc = 0 if subfirm == "新疆皮山冠农果蔬食品有限责任公司" & year == 2011


* 600725
replace stock = 17134.44 if subfirm == "曲靖大为焦化制供气有限公司" & year == 2010
	replace netinc = 0 if subfirm == "曲靖大为焦化制供气有限公司" & year == 2010

* 000027
drop if subfirm == "四川贡嘎电力投资有限公司" & year == 2013
drop if subfirm == "云南华邦电力开发有限公司" & year == 2013
drop if subfirm == "云和县沙铺砻水力发电有限责任公司" & year == 2013

* 000155
replace stock = 6885 if subfirm == "四川锦华化工有限责任公司" & year == 2015

* 002004
replace stock = 0 if subfirm == "杭州颖泰生物科技有限公司" & year == 2016
replace stock = 0 if subfirm == "杭州颖泰生物科技有限公司" & year == 2017
replace stock = 0 if subfirm == "杭州颖泰生物科技有限公司" & year == 2015
replace stock = 0 if subfirm == "杭州颖泰生物科技有限公司" & year == 2014
	replace netinc = -21003.25 if subfirm == "杭州颖泰生物科技有限公司" & year == 2014

* 600689
replace stock = 3664 if subfirm == "上海一毛条纺织重庆有限公司" & year == 2017
replace stock = 6864 if subfirm == "上海一毛条纺织重庆有限公司" & year == 2016
	replace netinc = 6864 if subfirm == "上海一毛条纺织重庆有限公司" & year == 2016
	replace inc = 6864 if subfirm == "上海一毛条纺织重庆有限公司" & year == 2016
replace stock = 0 if subfirm == "上海一毛条纺织重庆有限公司" & year <= 2015


* 000401
replace stock = 32911 if subfirm == "康达(承德)水泥有限公司" & year == 2010
	replace netinc = 0  if subfirm == "康达(承德)水泥有限公司" & year == 2010
	replace inc    = 0  if subfirm == "康达(承德)水泥有限公司" & year == 2010
	replace netinc = 6250  if subfirm == "康达(承德)水泥有限公司" & year == 2011
	replace inc    = 6250  if subfirm == "康达(承德)水泥有限公司" & year == 2011

*000525
replace stock = 50  if subfirm == "响水苏农农资连锁有限公司"
replace stock = 440 if subfirm == "江苏苏农测土配方肥料有限公司"
replace stock = 60  if subfirm == "沭阳苏农农资连锁有限公司" 
replace stock = 35  if subfirm == "淮安苏农农资连锁有限责任公司"
replace stock = 35  if subfirm == "阜宁苏农农资连锁有限公司"
replace stock = 88  if subfirm == "陕西红太阳农资连锁有限公司"
replace stock = 27.5 if subfirm == "姜堰苏农农资连锁有限公司"
	replace netinc = 0 if subfirm == "姜堰苏农农资连锁有限公司"
	replace inc    = 0 if subfirm == "姜堰苏农农资连锁有限公司"
replace stock = 140 if subfirm == "河南苏农农资连锁有限公司"
replace stock = 0   if subfirm == "盐城苏农农资连锁有限公司" & year == 2011
replace stock = 0   if subfirm == "盐城苏农农资连锁有限公司" & year == 2012


* 000539
replace netinc = 200 if subfirm == "广西武宣粤风新能源有限公司" & year == 2017
replace inc    = 200 if subfirm == "广西武宣粤风新能源有限公司" & year == 2017
replace netinc = 200 if subfirm == "湖南溆浦粤风新能源有限公司" & year == 2017
replace inc    = 200 if subfirm == "湖南溆浦粤风新能源有限公司" & year == 2017
replace stock  = 3000 if subfirm == "广东粤电和平风电有限公司" 
	replace netinc = 3000 if subfirm == "广东粤电和平风电有限公司" & year == 2016
	replace inc    = 3000 if subfirm == "广东粤电和平风电有限公司" & year == 2016
replace stock  = 3000 if subfirm == "广东粤电平远风电有限公司" 
	replace netinc = 3000 if subfirm == "广东粤电平远风电有限公司" & year == 2016
	replace inc    = 3000 if subfirm == "广东粤电平远风电有限公司" & year == 2016
replace capi = 17319 if subfirm == "广东粤电徐闻风力发电有限公司"
replace capi = 5500  if subfirm == "广东粤电阳江海上风电有限公司"

* 000543
replace stock = 4750 if subfirm == "皖能铜陵售电有限公司" 
	replace netinc = 4750 if subfirm == "皖能铜陵售电有限公司"
	replace inc    = 4750 if subfirm == "皖能铜陵售电有限公司"

* 000600
replace stock = 5377 if subfirm == "河北任华供热有限责任公司"
replace stock = 68500 if subfirm == "河北建投沙河发电有限责任公司" & year == 2011
replace stock = 68500 if subfirm == "河北建投沙河发电有限责任公司" & year == 2012
	replace netinc = 0 if subfirm == "河北建投沙河发电有限责任公司" & year == 2011
	replace netinc = 0 if subfirm == "河北建投沙河发电有限责任公司" & year == 2012
	replace inc    = 0 if subfirm == "河北建投沙河发电有限责任公司" & year == 2011
	replace inc    = 0 if subfirm == "河北建投沙河发电有限责任公司" & year == 2012

* 000755
replace stock = 0    if subfirm == "山西三维瀚森化工有限公司" & year == 2010
replace stock = 2805 if subfirm == "山西三维瀚森化工有限公司" & year == 2011
replace stock = 2805 if subfirm == "山西三维瀚森化工有限公司" & year == 2012
replace stock = 2805 if subfirm == "山西三维瀚森化工有限公司" & (year == 2013 | year == 2014 | year == 2015 | year == 2016 | year == 2017 )

* 000786
replace stock = 1500 if subfirm == "湖北泰山建材有限公司" & (year==2012 | year == 2013 )
* 000825
replace stock = 500 if subfirm == "沈阳沈水太钢不锈钢销售有限公司" & year == 2011
	replace netinc = 0 if subfirm == "沈阳沈水太钢不锈钢销售有限公司" & (year == 2011 | year == 2012)
	replace inc    = 0 if subfirm == "沈阳沈水太钢不锈钢销售有限公司" & year == 2011


* 000877
replace stock = 33898.57 if subfirm == "宜兴天山水泥有限责任公司" & year == 2010
	replace netinc = 0 if subfirm == "宜兴天山水泥有限责任公司" & (year == 2010 | year == 2011)
	replace inc    = 0 if subfirm == "宜兴天山水泥有限责任公司" &  year == 2010

* 000882
replace stock = 0 if subfirm == "湖北清江水电开发有限责任公司" & year == 2015
replace stock = 238641.79 if subfirm == "湖北清江水电开发有限责任公司" & year == 2016
	replace netinc = 238641.79 if subfirm == "湖北清江水电开发有限责任公司" & year == 2016
	replace inc    = 238641.79 if subfirm == "湖北清江水电开发有限责任公司" & year == 2016

replace stock = 0 if subfirm == "湖北宣恩洞坪水电有限责任公司" & year == 2015
replace stock = 10000 if subfirm == "湖北宣恩洞坪水电有限责任公司" & year == 2016
	replace netinc = 10000 if subfirm == "湖北宣恩洞坪水电有限责任公司" & year == 2016
	replace inc    = 10000 if subfirm == "湖北宣恩洞坪水电有限责任公司" & year == 2016

replace stock = 0 if subfirm == "新疆楚星能源发展有限公司" & year == 2015
replace stock = 24225.18 if subfirm == "新疆楚星能源发展有限公司" & year == 2016
	replace netinc = 24225.18 if subfirm == "新疆楚星能源发展有限公司" & year == 2016
	replace inc    = 24225.18 if subfirm == "新疆楚星能源发展有限公司" & year == 2016

* 002042
replace stock = 100  if subfirm == "余姚华孚纺织有限公司" & year == 2010
replace stock = 3000 if subfirm == "余姚华孚纺织有限公司" & year == 2011
replace stock = 11361 if subfirm == "余姚华孚纺织有限公司" & year == 2012
replace stock = 14411 if subfirm == "余姚华孚纺织有限公司" & year == 2013
replace stock = 14411 if subfirm == "余姚华孚纺织有限公司" & year == 2013
replace stock = 14411 if subfirm == "余姚华孚纺织有限公司" & year == 2015
replace stock = 14411 if subfirm == "余姚华孚纺织有限公司" & year == 2016
replace stock = 14411 if subfirm == "余姚华孚纺织有限公司" & year == 2017

replace stock = 3000 if subfirm == "宁海华孚纺织有限公司" & (year == 2011 | year == 2012 | year == 2013 | year == 2014 | year == 2015 | year == 2016 | year == 2017)
replace stock = 0 if subfirm == "慈溪华孚纺织有限公司" & year == 2011

* 002066
replace stock = 3862.5 if subfirm == "浙江瑞泰圣奥耐火材料有限公司" & year == 2010
	replace netinc = 0 if subfirm == "浙江瑞泰圣奥耐火材料有限公司" & (year == 2010 | year == 2011)
	replace inc    = 0 if subfirm == "浙江瑞泰圣奥耐火材料有限公司" & year == 2010

* 002100
replace in_key_dummy = 0 if subfirm == "河南宏展实业有限公司"
replace treatment = 1 if subfirm == "河南宏展实业有限公司"


* 300082
replace stock = . if subfirm == "江苏奥克化学有限公司" & year == 2011

* 600019
replace stock = 0 if subfirm == "宁波宝新不锈钢有限公司" & year == 2012
replace stock = 138355.5 if subfirm == "宁波宝新不锈钢有限公司" & year == 2011
replace stock = 138355.5 if subfirm == "宁波宝新不锈钢有限公司" & year == 2010

* 600396
replace stock = 0 if subfirm == "丹东金山供热有限公司" & year == 2017

replace stock = 3418.60 if subfirm == "宜兴市正虹饲料有限公司" & year == 2013

*** EOF
