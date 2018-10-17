clear
cd "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\WorkingDirectory"
set more off

** import NGDPD data ****
import excel "Data/NGDPD.xlsx", sheet("NGDPD") firstrow case(lower)
drop ecdatabase series_code indicator indicatorname frequency scale 
foreach var of varlist i - bv {
        local label : variable label `var'
        local new_name = "Y`label'"
        rename `var' `new_name'
}
reshape long Y, i(country countrycode) j(year)
rename Y NGDPD
label variable NGDPD "Nominal GDP in Billions of USD"
rename countrycode CountryCode
drop country
save Data/NGDP,replace
clear

*** import equity index data ****
import excel "Data\SP500Return.xlsx", sheet("Value") firstrow case(lower)
foreach val in varlist sp500-mxwd{
	destring `var', ignore("#N/A #N/A") replace
}

label variable sp500 "SP500 return"
label variable mxwo "MSCI Developed Countries index, return"
label variable mxwd "MSCI World index, return"
save Data/sp500return,replace

***** merge  ****
use Data/SCFI_Database_Final, clear
keep ID Country CountryCode CountryISO3code weogroup year ENDA PALLFNF_PCH
merge 1:1 year CountryCode using "Data\NGDP.dta",keep(match) nogen   // all matched
merge m:1 year using "Data\sp500return.dta", keep(match) nogen       // all matched
sort CountryCode year
save Data/CAPM, replace

