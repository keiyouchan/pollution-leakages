global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
	global output "$migration/output"	
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"

* -------- 
bysort subfirm (year): egen max_stock = max(stock)
bysort subfirm (year): gen ratio = max_stock / stock
bysort subfirm (year): gen unit_issue = (ratio > 100 & ratio !=.)
list subfirm stock if unit_issue == 1

