cd "Q:\DATA\AI\Chengyu Huang\AM Integrated Policy Frameworks\WorkingDirectory"
clear
set more off

// generate ggxwdg_gdp variable
import excel "Weo\weodata.xlsx", sheet("ggxwdg_gdp") cellrange(A1:X187) firstrow case(lower)
drop ecdatabase series_code countryname indicatorcode indicatorname frequency scale
foreach var of varlist k - x {
        local label : variable label `var'
        local new_name = "Y`label'"
        rename `var' `new_name'
}

reshape long Y, i(country countrycode indicator) j(year)
rename Y ggxwdg_gdp
drop indicator
label variable ggxwdg_gdp "General government gross debt, percent of Fiscal year GDP"
save "weo/ggxwdg_gdp.dta",replace

// generate ggcbp variable
clear
import excel "Weo\weodata.xlsx", sheet("ggcbp") cellrange(A1:X77) firstrow case(lower)
drop ecdatabase series_code countryname indicatorcode indicatorname frequency scale
foreach var of varlist k - x {
        local label : variable label `var'
        local new_name = "Y`label'"
        rename `var' `new_name'
}

reshape long Y, i(country countrycode indicator) j(year)
rename Y ggcbp
drop indicator
label variable ggcbp "General government cyclically adjusted primary balance"
save "weo/ggcbp.dta",replace


// generate ggcbp_gdp variable
clear
import excel "Weo\weodata.xlsx", sheet("ggcbp_gdp") cellrange(A1:X75) firstrow case(lower)
drop ecdatabase series_code countryname indicatorcode indicatorname frequency scale
foreach var of varlist k - x {
        local label : variable label `var'
        local new_name = "Y`label'"
        rename `var' `new_name'
}

reshape long Y, i(country countrycode indicator) j(year)
rename Y ggcbp_gdp
drop indicator
label variable ggcbp_gdp "General government cyclically adjusted primary balance, percent of potential in fiscal year GDP"
save "weo/ggcbp_gdp.dta",replace

// generate enda variable
clear
import excel "Weo\weodata.xlsx", sheet("enda") cellrange(A1:X194) firstrow case(lower)
drop ecdatabase series_code countryname indicatorcode indicatorname frequency scale
foreach var of varlist k - x {
        local label : variable label `var'
        local new_name = "Y`label'"
        rename `var' `new_name'
}

reshape long Y, i(country countrycode indicator) j(year)
rename Y enda
drop indicator
label variable enda "National currency units per U.S. dollar, period average"
save "weo/enda.dta",replace

clear

/********************************************/
******Merge data *****************************
**********************************************

use "weo/enda.dta",clear
merge 1:1 countrycode year using "Weo\ggcbp.dta", nogenerate
merge 1:1 countrycode year using "Weo\ggcbp_gdp.dta", nogenerate
merge 1:1 countrycode year using "Weo\ggxwdg_gdp.dta", nogenerate
rename countrycode IFSCode
save weo/weofinal.dta,replace

// merge to master
use annual_master_updated.dta,clear
merge 1:1 IFSCode year using "Weo\weofinal.dta", keepusing(enda ggcbp ggcbp_gdp ggxwdg_gdp)
drop if _merge ==2
drop _merge
save annual_master_updated2, replace 
