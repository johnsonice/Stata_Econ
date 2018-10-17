cd "Q:\DATA\SPRAI\Chengyu Huang\EBA-lite\Mitali\6_bca_gdp_gnp_gndi"
clear
set more off

set obs 1 
gen ifs_code = 111
gen year = "1995"
save dta/data.dta,replace

local sheets GNP GNDO BIP BIS NGDPD
foreach v of local sheets{
	clear
	import excel "data2.xlsx", sheet("`v'") cellrange(A2:AE202) firstrow case(lower)
	di "`v'"
	drop ecdatabase series_code countrycode indicatorname frequency scale
	
	foreach var of varlist j - ae{
        local label : variable label `var'
		local new_name = lower(strtoname("Y`label'"))
        rename `var' `new_name'
	}
	
	//duplicates drop 
	reshape long y, i(country ifs_code eba) j(year,string)
	rename y `v'
	label variable `v' "`v'"
	
	merge 1:1 ifs_code year using "dta/data.dta"
	drop _merge
	
	save dta/data.dta,replace
}


replace BIS = "." if BIS == "N.A."
replace BIP = "." if BIP == "N.A."
destring BIS,replace
destring BIP, replace

label variable BIS "Secondary income balance, millions of usd"
label variable BIP "primary income balance, millions of usd"
label variable NGDPD "NGDP, billiosn of usd"
label variable GNP "GDP = NGDPD + BIP/1000, billions of usd"
label variable GNDO "GNDO = GNP + BIS/1000, billions of usd"
drop if missing(eba)
save dta/data.dta,replace
