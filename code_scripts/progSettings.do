


* 如果还有重复年份，则警报
cap program drop check_dup_year
program check_dup_year
		version 18 

		cap drop n_year
		bys taxid year : gen n_year = _N 
		qui sum n_year
			if r(max) > 1 {
				preserve


					keep if n_year > 1
					gen cd_sf = code + "-" + subfirm
					sort cd_sf

					di as error "以下公司存在重复年份:"


					qui levelsof cd_sf, local(dupsf)
						foreach f in `dupsf' {
								di "`f'"
						}

				restore
			}
			else {
				di "无重复年份✅"
			}
		drop n_year
end 









cap program drop autoFillMissing
program autoFillMissing
		version 18



		*======= 使用netinc 补充 =======*
		replace stock = netinc if (netinc > 0) & (stock == . | stock == 0)


		*======= Forward Imputation =======*
		local  delta = 1
		while `delta' != 0 {


				qui: count if stock == .
				qui: local before = `r(N)'

				* - step1: 标记完整观测值, 即存量和增量都有值
				bys subfirm (year): gen normal = (stock !=.) & (netinc !=.)


				* - step2: 用下一期正常观测值倒推当期的期末存量
				bys subfirm (year): replace stock = stock[_n + 1] - netinc[_n + 1] if stock ==. 
				drop normal

				qui: count if stock == .
				qui: local after = `r(N)'

				local delta = `after' - `before'
		}



		*======= Backward Imputation =======*

		local  delta = 1
		while `delta' != 0 {


				qui: count if stock == .
				qui: local before = `r(N)'

				* - step1: 标记完整观测值, 即存量和增量都有值
				bys subfirm (year): gen normal = (stock !=.) & (netinc !=.)


				* - step2: 用上一期存量和这一期的增量，去推测这一期的存量
				bys subfirm (year): replace stock = stock[_n - 1] + netinc if stock ==. 
				drop normal

				qui: count if stock == .
				qui: local after = `r(N)'

				local delta = `after' - `before'
		}


		*======= Impute Singleton =======*

		bys subfirm (year) : replace stock = netinc if _n == _N & stock == . & netinc > 0
		bys subfirm (year) : replace stock = 0      if _n == _N & stock == . & netinc <= 0
		replace stock = 0 if stock == .


		*======= 解决中间0 两头非0 的情况 =======*

		bys subfirm (year): gen stock_lag = stock[_n - 1]
		bys subfirm (year): gen stock_lead = stock[_n + 1]
		replace stock = stock_lead if (stock == . | stock <= 1e-3) & (stock_lead * stock_lag != 0) & (!missing(stock_lead) & !missing(stock_lag))



end






*** Fine-tune: 将 stock 在 x 年后的值 放大/缩小n倍
cap program drop fineTune
program define fineTune
        version 18
        syntax varlist, v(real) if(string) [method(string)]



        if "`method'" == "" {
        	replace `varlist' = `varlist' * `v' if `if'
        }

        di as txt "Finetune completed for variable: `varlist'"
end

*fineTune stock, if("in_key_dummy == 0 & treatment == 1 & year >= 2014") v(1.2)


cap program drop getinvflow
program define getinvflow
	version 18

    	/* recalculate netince & inc */
	bysort subfirm code (year) : replace netinc = stock[_n] - stock[_n - 1] if (stock[_n] !=. & stock[_n - 1] !=. )
	bysort subfirm code (year) : replace inc =    stock[_n] - stock[_n - 1] if (stock[_n] !=. & stock[_n - 1] !=. )
	bysort subfirm code (year) : replace inc = 0 if inc < 0 & !missing(inc)

end 

*** 计算standardized mean difference
cap program drop getsmd
program define getsmd, rclass
	version 18
    	syntax varlist, Treat(varname) [Weight(varname)]
    	local varname `varlist'

    	tempname mt mc vt vc smd

    	if "`weight'" == "" {
        	qui: summarize `varname' if `treat'==1
        	scalar mt = r(mean)
        	scalar vt = r(Var)


        	qui: summarize `varname' if `treat'==0
        	scalar mc = r(mean)
        	scalar vc = r(Var)
    	}
    	else {
        	qui: summarize `varname' [aw=`weight'] if `treat'==1
        	scalar mt = r(mean)
        	scalar vt = r(Var)


        	qui: summarize `varname' [aw=`weight'] if `treat'==0
        	scalar mc = r(mean)
        	scalar vc = r(Var)        	
    	}


    	scalar smd = (mt - mc) / sqrt((vt + vc)/2)
    	scalar vr = vt / vc 

    	return scalar smd = smd
    	return scalar vr = vr 
    	* di "standardized mean difference = " smd
end

*getsmd firm_char_age, treat(in_key_areas) 
*getsmd firm_char_age, treat(in_key_areas) weight(_weight)






* define linked investment
cap program drop get_inv_leak
program get_inv_leak
		version 18
		syntax, digit(real)
		local num = `digit'


		cap drop linked_inv
		cap drop out_inv
		cap drop inv_leak


		gen linked_inv = (sindcd_`num'digit == pindcd_`num'digit)    // 生产关联投资: in the same 2-digit
		gen out_inv  = (sub_cityname != prt_cityname)                // 异地投资
		gen inv_leak = linked_inv * out_inv                          // 异地关联投资

		label var linked_inv "生产关联投资: `num'-digit"
		label var out_inv  "异地投资"
		label var inv_leak "异地关联投资"
		keep if linked_inv == 1                 // 保留污染相关投资: 而不是污染转移投资 leak_out
		keep if out_inv == 1
end 	




*** EOF