clear
cd "$cwd"  // $cwd = "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\WorkingDirectory"
set more off

use Data/CAPM,clear
tsset

* calculate NGDPD_PCH
gen NGDPD_PCH = (NGDPD - l.NGDPD)/l.NGDPD * 100
label variable NGDPD_PCH "Nominal GDP Growth Rate"
drop NGDPD 
gen NGDPD_PCH_F1 = f.NGDPD_PCH 									// generate one year forward NGDP_PCH

*gen ENDA_PCH
gen ENDA_PCH = (ENDA - l.ENDA)/l.ENDA * 100						// generarte ENDA_PCH
label variable ENDA_PCH "US$ exchange rate, percentage change"

//bysort CountryCode: egen m_gdp = mean( NGDPD_PCH )
//bysort CountryCode: egen m_gdp_f1 = mean( NGDPD_PCH_F1 )
local varlist sp500 mxwo mxwd                                    // market return proxy 
local riskfree 2                                                 // set risk free rate to be 2
local vars_gdp NGDPD_PCH NGDPD_PCH_F1 ENDA_PCH					 // added ENDA_PCH

****************************************************************
*******Generate betas for each senarios ************************
****************************************************************

foreach var in `varlist'{                                           // varlist -- sp500 mxwo mxwd
	foreach gdp in `vars_gdp'{                                       // var_gdp -- NGDP_PCH NGDP_PCH_F1
	*** calculate variance and covariance *********
		preserve 
		drop if missing(`gdp')  
		drop if missing(`var')     									//drop if gdp or MSCI index is missing
		gen sp500_`var' = (sp500+`var')/2							//calculate mean of sp500 and world index
		bysort CountryCode: egen m_sp500_`var' = mean(sp500_`var')
		
		// calculate deviation from mean
		bysort CountryCode: egen m_gdp = mean( `gdp' )
		gen temp_cov = (`gdp' - m_gdp)*( sp500_`var'- m_sp500_`var' )
		gen temp_sp500_`var'_v = (sp500_`var'- m_sp500_`var')^2    // deviation from mean for sp500_MSCI index
		
		// count n for non missing data
		gen n_temp_cov = temp_cov
		gen n_sp500_`var'_v = temp_sp500_`var'_v

	****** calculate beta ************
		// collapse by using sum
		collapse (sum) temp_sp500_`var'_v temp_cov (count) n_temp_cov n_sp500_`var'_v, ///
		by(Country CountryCode CountryISO3code weogroup)
		gen cov = temp_cov/( n_temp_cov -1)
		gen sp500_`var'_v = temp_sp500_`var'_v/(n_sp500_`var'_v-1)
		gen beta = cov/ (sp500_`var'_v)												// calculate beta, covariance over variance of the market
		drop temp_* n_*
		export excel using "beta.xlsx", sheet("`var'_`gdp'") sheetmodify firstrow(variables)
		keep Country CountryCode beta
		rename beta `var'_`gdp'_beta
		save temp/`var'_`gdp'_beta, replace                                   // save beta

		restore
	}
}
****** calculate risk premium ********
use Data/CAPM,clear
tsset
gen NGDPD_PCH = (NGDPD - l.NGDPD)/l.NGDPD * 100
label variable NGDPD_PCH "Nominal GDP Growth Rate"
drop NGDPD 
gen NGDPD_PCH_F1 = f.NGDPD_PCH 									// generate one year forward NGDP_PCH
*gen ENDA_PCH
gen ENDA_PCH = (ENDA - l.ENDA)/l.ENDA * 100						// generarte ENDA_PCH
label variable ENDA_PCH "US$ exchange rate, percentage change"
drop ENDA

foreach var in `varlist'{
	foreach gdp in `vars_gdp'{
		merge m:1 Country CountryCode using "temp/`var'_`gdp'_beta.dta", nogenerate
		sort CountryCode year
		gen premium_`var'_`gdp' = (`var' -`riskfree')* `var'_`gdp'_beta
	}
}

order NGDPD* ENDA_PCH, before (sp500)
order *_beta, before( premium_sp500_NGDPD_PCH )
export excel using "Premium.xlsx", sheet("premium") sheetmodify firstrow(variables)
