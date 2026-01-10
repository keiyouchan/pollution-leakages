global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

cd $raw

* ----------------
/* PM2.5, PM10, O3, SO2, NO2 */

* PM2.5
use "$raw/pollutants/PM25", clear
rename (省 省代码 市 市代码 年份 mean) (provname provid cityname cityid year PM25)
keep provname provid cityname cityid year PM25
label var PM25 "年均PM2.5浓度"
tempfile PM25
save `PM25', replace

* PM10
use "$raw/pollutants/PM10", clear
rename (省 省代码 市 市代码 mean) (provname provid cityname cityid PM10)
keep provname provid cityname cityid year PM10
label var PM10 "年均PM10浓度"
tempfile PM10
save `PM10', replace

* O3
use "$raw/pollutants/O3", clear
rename (省 省代码 市 市代码 mean) (provname provid cityname cityid O3)
keep provname provid cityname cityid year O3
label var O3 "年均O3浓度"
tempfile O3
save `O3', replace

* NO2
use "$raw/pollutants/NO2", clear
rename (省 省代码 市 市代码 mean) (provname provid cityname cityid NO2)
keep provname provid cityname cityid year NO2
label var NO2 "年均NO2浓度"
tempfile NO2
save `NO2', replace

* SO2
* collapse to year
use "$raw/pollutants/SO2", clear
rename (省 省代码 市 市代码 地表SO2质量浓度) (provname provid cityname cityid SO2)
gen year=year(month)
gcollapse (mean) SO2, by(provname provid cityname cityid year)
label var SO2 "年均SO2浓度"

* merge all together
merge 1:1 cityid year using `PM25', keep(3) nogenerate
merge 1:1 cityid year using `PM10', keep(3) nogenerate
merge 1:1 cityid year using `O3', keep(3) nogenerate
merge 1:1 cityid year using `NO2', keep(3) nogenerate


* save
save "$interm/pollutants", replace

***EOF



