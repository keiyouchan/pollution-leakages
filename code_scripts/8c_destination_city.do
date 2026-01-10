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

/* Destination: Province */
 * outcome variables
 global outcomes "stock_out netinc_out inc_out firmnum_out"
 	* HDFE model
 	global hdfe       "code year provid#year indusid#year"
 	global hdfe_dummy "code year provid#year indusid#year $citycorr"
 	global clusters   "cityid"
 
 * -----------
 global cityl    "c.SO2#c.year               c.PM25#c.year               c.PM10#c.year               c.O3#c.year               c.NO2#c.year               c.popdensity#c.year               c.gdpcapita#c.year               c.indusoutput#c.year               c.finrev#c.year               c.finexp#c.year"
 global cityq    "c.SO2#c.year#c.year        c.PM25#c.year#c.year        c.PM10#c.year#c.year        c.O3#c.year#c.year        c.NO2#c.year#c.year        c.popdensity#c.year#c.year        c.gdpcapita#c.year#c.year        c.indusoutput#c.year#c.year        c.finrev#c.year#c.year        c.finexp#c.year#c.year"
 global citypoly "c.SO2#c.year#c.year#c.year c.PM25#c.year#c.year#c.year c.PM10#c.year#c.year#c.year c.O3#c.year#c.year#c.year c.NO2#c.year#c.year#c.year c.popdensity#c.year#c.year#c.year c.gdpcapita#c.year#c.year#c.year c.indusoutput#c.year#c.year#c.year c.finrev#c.year#c.year#c.year c.finexp#c.year#c.year#c.year"
 global citypost "c.SO2#c.post               c.PM25#c.post               c.PM10#c.post               c.O3#c.post               c.NO2#c.post               c.popdensity#c.post               c.gdpcapita#c.post               c.indusoutput#c.post               c.finrev#c.post               c.finexp#c.post"
 global citycorr "c.SO2#year                 c.PM25#year                 c.PM10#year                 c.O3#year                 c.NO2#year                 c.popdensity#year                 c.gdpcapita#year                 c.indusoutput#year                 c.finrev#year                 c.finexp#year"
         
 
 global model1 "$cityl"
 global model2 "$cityq"
 global model3 "$citypoly"
 global model4 "$citypost"
 * ------------------
 use "$processed/three_dimens_panel.dta",clear
 gen policy3  = in_tregions  * (year >= 2014)
 gen policy10 = in_tclusters * (year >= 2014)
 drop if flowin_key == 1

 tab recipient , gen(city_)
 preserve
	  egen    mapping = tag(recipient)  // 标记每个唯一城市
	  keep if mapping == 1      // 保留每个城市的第一条观测
	  keep    recipient 
	  gen     citycode = _n
	  tempfile mapcity
	  save    `mapcity' , replace 
 restore

/*
 * save results for seperate regression
 matrix coef = J(1,5,.)
 cap : drop coef lb ub citycode pvalue
 cap : c1 c2 c3 c4 c5



 forvalues i = 1(1)285 {
  		   display "--- 正在进行第`i'次回归 ---"
  		   cap{
   	  		    reghdfe stock_out policy if city_`i' == 1 , a($hdfe_dummy) vce(cluster $clusters)
  	 	   	    est sto city_`i'
  	 	   	    scalar beta = _b[policy]                 // 系数
            	scalar se = _se[policy]                 // 标准误
            	scalar pval = 2 * (1 - normprob(abs(beta / se)))  // 计算两侧 p 值
            	scalar lb = beta - 1.96 * se            // 置信区间下限
           		scalar ub = beta + 1.96 * se            // 置信区间上限

		        matrix coef = coef \ (beta , lb , ub , `i' , pval)
  		   }
 }
 clear
 mat list coef
 svmat coef , names(col)
 rename c1 coef
 rename c2 lb
 rename c3 ub
 rename c4 citycode
 rename c5 pvalue

 merge 1:1 citycode using `mapcity' , keep(1 3) nogen

 * plot the coefficient
 #delimit ;
	twoway (rcap lb ub citycode if pval <= 0.05 & coef > 0 & !missing(pval) ,  
				 color(edkblue)
				 lp(dash)
				 legend(label(1 "Confidential Intervals")))

		   (scatter coef citycode if pval <= 0.05 & coef > 0 & !missing(pval) , 
		    	 legend(label(2 "Point estimates")) 
		    	 msymbol(D) mcolor(stred) msize(*0.5)),

		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
		    ytitle("Province")
		    legend(position(bottom) row(1));
#delimit cr
*/
/* ------------------------------------------------- */
/* ------------------------------------------------- */

*_ aggregate effects
* save results for seperate regression
 matrix coef = J(1,5,.)
 cap : drop beta lb ub citycode pval
 cap : c1 c2 c3 c4 c5 


 forvalues i = 1(1)285 {
  		   display "--- 正在进行第`i'次回归 ---"
  		   cap{
   	  		    reghdfe stock_out policy if city_`i' == 1 , a($hdfe_dummy) vce(cluster $clusters)
  	 	   	    est sto city_`i'
  	 	   	    // results for policy
  	 	   	    scalar beta = _b[policy]                 // 系数
            	scalar se = _se[policy]                 // 标准误
            	scalar pval = 2 * (1 - normprob(abs(beta / se)))  // 计算两侧 p 值
            	scalar lb = beta - 1.96 * se          // 置信区间下限
           		scalar ub = beta + 1.96 * se            // 置信区间上限


		        matrix coef = coef \ (beta , lb , ub , `i' , pval)
  		   }
 }

 clear
 mat list coef
 svmat  coef , names(col)
 rename c1 coef
 rename c2 lb
 rename c3 ub
 rename c4 citycode
 rename c5 pval


 merge 1:1 citycode using `mapcity' , keep(1 3) nogen
 *save "$destin/transfer_city_results.dta" , replace

 * plot the coefficient
 #delimit ;
	twoway (rcap lb ub citycode if pval <= 0.1  ,  
				 color(edkblue)
				 lp(dash)
				 legend(label(1 "Confidential Intervals")))

		   (scatter coef citycode if pval <= 0.1 , 
		    	 legend(label(2 "Point estimates")) 
		    	 msymbol(D) mcolor(stred) msize(*0.5)),

		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
		    ytitle("Province")
		    legend(position(bottom) row(1));
#delimit cr

******************************************************
*- seperate effects 
* save results for seperate regression
 matrix coef = J(1,9,.)
 cap : drop beta3 lb3 ub3 beta10 lb10 ub10 citycode pval3 pval10
 cap : c1 c2 c3 c4 c5 c6 c7 c8 c9



 forvalues i = 1(1)285 {
  		   display "--- 正在进行第`i'次回归 ---"
  		   cap{
   	  		    reghdfe stock_out policy3 policy10 if city_`i' == 1 , a($hdfe_dummy) vce(cluster $clusters)
  	 	   	    est sto city_`i'
  	 	   	    // results for policy3
  	 	   	    scalar beta3 = _b[policy3]                 // 系数
            	scalar se3 = _se[policy3]                 // 标准误
            	scalar pval3 = 2 * (1 - normprob(abs(beta3 / se3)))  // 计算两侧 p 值
            	scalar lb3 = beta3 - 1.96 * se3           // 置信区间下限
           		scalar ub3 = beta3 + 1.96 * se3            // 置信区间上限

           		// results for policy10
  	 	   	    scalar beta10 = _b[policy10]                 // 系数
            	scalar se10 = _se[policy10]                 // 标准误
            	scalar pval10 = 2 * (1 - normprob(abs(beta10 / se10)))  // 计算两侧 p 值
            	scalar lb10 = beta10 - 1.96 * se10            // 置信区间下限
           		scalar ub10 = beta10 + 1.96 * se10            // 置信区间上限


		        matrix coef = coef \ (beta3 , lb3 , ub3 , beta10 , lb10 , ub10, `i' , pval3 , pval10)
  		   }
 }

 clear
 mat list coef
 svmat  coef , names(col)
 rename c1 coef3
 rename c2 lb3
 rename c3 ub3
 rename c4 coef10
 rename c5 lb10
 rename c6 ub10
 rename c7 citycode
 rename c8 pval3
 rename c9 pval10

 merge 1:1 citycode using `mapcity' , keep(1 3) nogen
 *save "$destin/transfer_city_results.dta" , replace

 * plot the coefficient
 #delimit ;
	twoway (rcap lb3 ub3 citycode if pval3 <= 0.1  ,  
				 color(edkblue)
				 lp(dash)
				 legend(label(1 "Confidential Intervals")))

		   (scatter coef3 citycode if pval3 <= 0.1 , 
		    	 legend(label(2 "Point estimates")) 
		    	 msymbol(D) mcolor(stred) msize(*0.5)),

		    xline(0 , lp(solid) lw(0.3) lcolor(gs2)) 
		    ytitle("Province")
		    legend(position(bottom) row(1));
#delimit cr


/* ------------------------------------------------- */
/* ------------------------------------------------- */
/*
 /* 青海省 */
 gen xining  = recipient == "西宁市"
 gen haidong = recipient == "海东市"
 gen haibei = recipient == "海北藏族自治州"
 gen hainan = recipient == "海南藏族自治州"
 //gen haixi  = recipient == "海西蒙古族藏族自治州"
 gen huangnan = recipient == "黄南藏族自治州"
 //gen guoluo   = recipient == "果洛藏族自治州"
 //gen yushu    = recipient == "玉树藏族自治州"

/* 浙江省 */
//gen hangzhou = recipient == "杭州市"
//gen ningbo   = recipient == "宁波市"
gen wenzhou  = recipient == "温州市"
//gen jiaxing  = recipient == "嘉兴市"
//gen huzhou   = recipient == "湖州市"
//gen shaoxing = recipient == "绍兴市"
gen jinhua   = recipient == "金华市"
gen quzhou   = recipient == "衢州市"
gen zhoushan = recipient == "舟山市"
//gen taizhou  = recipient == "台州市"
gen lishui   = recipient == "丽水市"

/* 新疆 */
gen aksu    = recipient == "阿克苏地区"
gen bayin   = recipient == "巴音郭楞蒙古自治州"
gen changji = recipient == "昌吉回族自治州"
//gen yili    = recipient == "伊犁哈萨克自治州"
gen boerta  = recipient == "博尔塔拉蒙古自治州"
gen kezler  = recipient == "克孜勒苏柯尔克孜自治州"
//gen kashi   = recipient == "喀什地区"
//gen hetian  = recipient == "和田地区"
gen tacheng = recipient == "塔城地区"
gen aletai     = recipient == "阿勒泰地区"
//gen urmuqi     = recipient == "乌鲁木齐市"
gen kelamayi   = recipient == "克拉玛依市"
//gen trufan     = recipient == "吐鲁番市"
//gen hami       = recipient == "哈密市"
//gen alar       = recipient == "阿拉尔市"
//gen tumushuke  = recipient == "图木舒克市"
//gen wujiaqu    = recipient == "五家渠市"
//gen huyanghe   = recipient == "胡杨河市"
//gen beitun     = recipient == "北屯市"
//gen shihezi    = recipient == "石河子市"
//gen tiemenguan = recipient == "铁门关市"
//gen shuanghe   = recipient == "双河市"

/* 湖南 */
//gen changsha = recipient == "长沙市"
//gen zhuzhou = recipient == "株洲市"
gen xiangtan = recipient == "湘潭市"
gen hengyuang = recipient == "衡阳市"
gen shaoyang = recipient == "邵阳市"
gen yueyang = recipient == "岳阳市"
gen changde = recipient == "常德市"
gen yiyang = recipient == "益阳市"
gen chenzhou = recipient == "郴州市"
gen yongzhou = recipient == "永州市"
gen huaihua = recipient == "怀化市"
gen loudi = recipient == "娄底市"
gen zhangjiajie = recipient == "张家界市"
//gen xiangxi = recipient == "湘西自治州"


/* 湖北 */
//gen wuhan = recipient == "武汉市"
//gen huangshi = recipient == "黄石市"
gen xiangyang = recipient == "襄阳市"
//gen jinzhou = recipient == "荆州市"
gen yichang = recipient == "宜昌市"
gen shiyan = recipient == "十堰市"
gen xiaogan = recipient == "孝感市"
gen jinmen = recipient == "荆门市"
gen ezhou = recipient == "鄂州市"
gen huangang = recipient == "黄冈市"
//gen xianning = recipient == "咸宁市"
gen suizhou = recipient == "随州市"
//gen tianmen = recipient == "天门市"
//gen xiantao = recipient == "仙桃市"
//gen qianjiang = recipient == "潜江市"
//gen shennong = recipient == "神农架林区"
//gen enshi = recipient == "恩施土家族苗族自治州"


/* 山西 */
gen datong = recipient == "大同市"
gen suzhou  = recipient == "朔州市"
gen yizhou = recipient == "忻州市"
gen yangquan = recipient == "阳泉市"
gen lvliang = recipient == "吕梁市"
gen jinzhong = recipient == "晋中市"
gen changzhi = recipient == "长治市"
gen jinchenglinfen = recipient == "晋城市"
gen linfen = recipient == "临汾市"
gen yuncheng = recipient == "运城市"
//gen taiyuan = recipient == "太原市"


/* 甘肃 */
//gen lanzhou = recipient == "兰州市"
gen tianshui = recipient == "天水市"
gen baiyin = recipient == "白银市"
//gen jinchang = recipient == "金昌市"
//gen wuwei = recipient == "武威市"
gen jiuquan = recipient == "酒泉市"
//gen zhangye = recipient == "张掖市"
//gen dingxi = recipient == "定西市"
gen pingliang = recipient == "平凉市"
gen qingyang = recipient == "庆阳市"
//gen longnan = recipient == "陇南市"
gen jiayuguan = recipient == "嘉峪关市"

/* 河北省 */
//gen qinghuangdao = recipient == "秦皇岛"
//gen baoding = recipient == "保定市"
gen zhangjiakou = recipient == "张家口市"
gen cangzhou = recipient == "沧州市"
gen handan = recipient == "邯郸市"
gen hengshui = recipient == "衡水市"


*/










