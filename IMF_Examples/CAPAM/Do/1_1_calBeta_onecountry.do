clear
cd "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\Alex\Step_3"
//cd "$cwd"  // $cwd = "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\WorkingDirectory"
set more off

use Data/CAPM,clear
tsset

//bysort CountryCode: egen m_gdp = mean( NGDPD_PCH )
//bysort CountryCode: egen m_gdp_f1 = mean( NGDPD_PCH_F1 )
local varlist sp500 mxwo mxwd                                    // market return proxy 
local riskfree 2                                                 // set risk free rate to be 2
local vars_gdp PALLFNF_PCH

****************************************************************
*******Generate betas for each senarios ************************
****************************************************************
keep if CountryCode ==111

foreach var in `varlist'{                                           // varlist -- sp500 mxwo mxwd
	gen sp500_`var' = (sp500+`var')/2							//calculate mean of sp500 and world index
}

keep year PALLFNF_PCH sp500 mxwo mxwd sp500_sp500 sp500_mxwo sp500_mxwd
export excel using "Premium.xlsx", sheet("PALLFNF_PCH") sheetmodify firstrow(variables)
