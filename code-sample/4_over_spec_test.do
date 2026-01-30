global migration "/Users/chandlerwong/Desktop/Pollution_project"
	global scripts "$migration/code_scripts"
	global data "$migration/data"
		global raw "$data/raw"
		global interm "$data/intermediate"
		global processed "$data/processed"
	global output "$migration/output"
		global baseline "$output/baseline"
		global eventstudy "$output/eventstudy"	

cd $processed
****************************
reghdfe policy, a($twfe) vce(cluster citycode)
reghdfe policy, a($twfe indusid#year) vce(cluster citycode)
reghdfe policy, a($twfe provid#year ) vce(cluster citycode)
reghdfe policy, a($twfe indusid#year provid#year) vce(cluster citycode)
reghdfe policy, a($twfe indusid#year provid#year c.($prechar)#year) vce(cluster citycode)


















