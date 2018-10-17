** Fama_Macbenth procedure ***
clear
cd "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\Alex\Step_3"  // $cwd = "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\Alex\WorkingDirectory"
set more off
use Data/CAPM,clear
tsset

* calculate NGDPD_PCH
gen NGDPD_PCH = (NGDPD - l.NGDPD)/l.NGDPD * 100
label variable NGDPD_PCH "Nominal GDP Growth Rate"
*gen sp500_r = sp500
*gen mxwo_r = (sp500+mxwo)/2
*gen mxwd_r = (sp500+mxwd)/2
drop NGDPD 
save temp/ready.dta,replace

*******************************************************************************
// fist: run a time-series regress on each of the sections that we have 
*******************************************************************************

*** Run regress by country
levelsof CountryCode, local(countrycode)
local vars sp500
local y NGDPD_PCH
local z: word count `countrycode'
local z2: word count `vars'
matrix table = J(`z',1+3*`z2',.)

local counter 0
foreach c of local countrycode{
	local ++counter
	matrix table[`counter',1]= `c'
	local counter2 0
	foreach i in `vars'{
		quietly reg `y' `i' if CountryCode == `c'              // regression
		matrix temp = r(table)
		matrix table[`counter',3*`counter2'+2]= temp[1,1]
		matrix table[`counter',3*`counter2'+3]= temp[4,1]
		matrix table[`counter',3*`counter2'+4]= e(r2)
		local ++counter2
	}
}

matrix colnames table = "countrycode" "beta" "pvalue" "r2"
matrix list table

// export to excel
putexcel A2 = matrix(table) using stg1_reg.xlsx, sheet("`y'") modify
putexcel A1 = matrix(table,colnames) using stg1_reg.xlsx, sheet("`y'") modify


*******************************************************************************************
// second, use all the coefficients we get from the first stage as input, then run a cross-section
// regress at each time point, so that we will get a lambda for each time period 
********************************************************************************************

* save betas as dta
clear
import excel "stg1_reg.xlsx", sheet("NGDPD_PCH") firstrow case(lower)
save temp/betas.dta,replace

*** merge it with master data
use temp/ready.dta,clear
rename CountryCode countrycode
merge m:1 countrycode using "temp\betas.dta", keepusing(beta) nogenerate

*** set the time period to be before 2008 
drop if year > 2007 | year < 1970
*******
* run specific country groups 
* if not specified, it runs all the countries
keep if weogroup == 3 // keep AM countryes 
*keep if weogroup == 2 // keep EM countryes 
*keep if weogroup == 1 // keep LC countryes 

*******

*** run regression for each t and save lambda 
levelsof year, local(tt)
local vars beta
local y NGDPD_PCH
local z: word count `tt'
local z2: word count `vars'
matrix table = J(`z',1+3*`z2',.)



local counter 0
foreach t of local tt{
	local ++counter
	matrix table[`counter',1]= `t'
	local counter2 0
	foreach i in `vars'{
		quietly reg `y' `i' if year == `t'              // regression
		matrix temp = r(table)
		matrix table[`counter',3*`counter2'+2]= temp[1,1]
		matrix table[`counter',3*`counter2'+3]= temp[4,1]
		matrix table[`counter',3*`counter2'+4]= e(r2)
		local ++counter2
	}
}

matrix colnames table = "year" "lambda" "pvalue" "r2"
matrix list table

// export to excel
putexcel A2 = matrix(table) using lambda.xlsx, sheet("lambda") modify
putexcel A1 = matrix(table,colnames) using lambda.xlsx, sheet("lambda") modify

