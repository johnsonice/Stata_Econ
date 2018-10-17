clear
cd "$cwd"  // $cwd = "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\Alex\WorkingDirectory"
set more off

use Data/CAPM,clear
tsset

* calculate NGDPD_PCH
gen NGDPD_PCH = (NGDPD - l.NGDPD)/l.NGDPD * 100
label variable NGDPD_PCH "Nominal GDP Growth Rate"

gen sp500_r = sp500
gen mxwo_r = (sp500+mxwo)/2
gen mxwd_r = (sp500+mxwd)/2

drop NGDPD 

**************************************
** not sure if we should do that here*
*replace NGDPD_PCH = f.NGDPD_PCH
*************************************

*** Run regress by country
levelsof CountryCode, local(countrycode)
local vars sp500_r mxwo_r mxwd_r
local z: word count `countrycode'
local z2: word count `vars'
matrix table = J(`z',1+3*`z2',.)

local counter 0

foreach c of local countrycode{
	local ++counter
	preserve
	keep if CountryCode == `c'
	matrix table[`counter',1]= `c'
	local counter2 0
	foreach i in `vars'{
		reg `i' ENDA             // regression
		matrix temp = r(table)
		matrix table[`counter',3*`counter2'+2]= temp[1,1]
		matrix table[`counter',3*`counter2'+3]= temp[4,1]
		matrix table[`counter',3*`counter2'+4]= e(r2)
		local ++counter2
	}
	restore
}

matrix colnames table = "Country Code" "Coef" "P" "R2" "Coef" "P" "R2" "Coef" "P" "R2"
matrix list table

// export to excel
putexcel B4 = matrix(table) using regression.xlsx, sheet("ENDA") modify

