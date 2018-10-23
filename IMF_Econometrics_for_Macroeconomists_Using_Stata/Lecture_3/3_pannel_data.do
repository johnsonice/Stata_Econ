**************************************************************
** note this is just a code snipets for reference ************
** some code my not run as you don't have the data loaded ****
**************************************************************

*****************************
***Pannel data***************
*****************************
cd "C:\Users\CHuang\Box Sync\IMF_Training_Courses\Stata\Lecture_3"
set more off 
capture log close  // close it first, in case the log file is already open
log using 3_panel, replace

	*************************************
	***** Estimation for panel data *****
	*************************************
	// xt - help xt 
	//One-way fixed effects: the within estimator
	//xtreg depvar indepvars, fe [options]
	bcuse traffic, clear
	xtreg fatal beertax spircons unrate perincK, fe
	xtreg fatal beertax spircons unrate perincK i.year, fe  // two way fixed effect 
	testparm i.year     // test year dummy 
	xtreg fatal beertax spircons unrate perincK, be // between regression
	
	
	// The random effects estimator 
	
	//The first difference estimator
	//Mark Schaffer’s xtivreg2 from SSC provides this option as the fd model
	xtivreg2 fatal beertax spircons unrate perincK, fd nocons small  // no constant 
	
	//The seemingly unrelated regression estimator
	// sureg model --  SURE is a generalized least squares (GLS)
	bcuse pwt90, nodesc clear
	keep if tin(1960,)
	keep csh_c csh_i csh_g countrycode year
	keep if inlist(countrycode, "ITA", "ESP", "GRC")
	levelsof countrycode, local(ctylist)
	reshape wide csh_c csh_g csh_i, i(year) j(countrycode) string
	tsset year, yearly
	
	loc eqns
	foreach c of local ctylist {
		loc eqns "`eqns' (csh_c`c' L.csh_c`c' csh_i`c' csh_g`c')"
	}
	display "`eqns'"
	sureg "`eqns'", corr
	
	// now you can test coefficients accross equations 
	test [csh_cESP]csh_gESP = [csh_cGRC]csh_gGRC = [csh_cITA]csh_gITA

	// we can produce ex post or ex ante forecasts from sureg with predict 
	sureg "`eqns'" if year<=2007, notable
	foreach c of local ctylist{
		qui predict double `c'hat if year > 2007, xb equation(csh_c`c')
		label var `c'hat "`c'"
	}
	su *hat
	// make graph 
	tsline *hat if year> 2007, legend(rows(1)) ti("predicted consumption share") ///
	t2("Ex ante predictions") ylab(,angle(0) labs(small)) xlab(,labs(small)) ///
	legend(size(small)) scheme(s2mono)
	
	
	// Instrumental variables estimators for panel data
	// allow two way clustering
	// ivgmm in panel 
	// dynamic panel data 
	// panle unite root test 
	// etc, refer to slides 
	
	
	
log close
translate 0_basicdo.smcl dofilename.pdf, replace



