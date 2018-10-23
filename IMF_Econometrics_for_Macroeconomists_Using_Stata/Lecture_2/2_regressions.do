**************************************************************
** note this is just a code snipets for reference ************
** some code my not run as you don't have the data loaded ****
**************************************************************

*****************************
*** a usual stata templte ***
*****************************
cd "C:\Users\CHuang\Box Sync\IMF_Training_Courses\Stata\Lecture_2"
set more off 
capture log close  // close it first, in case the log file is already open
log using 2_basicdo, replace

	***********************
	***** Regressions *****
	***********************
	bcuse macro14, nodesc
    desc  altsales frprime fsdebt gdprdot ur
	reg altsales frprime L2.fsdebt L.(gdprdot ur), vsquish  // basic ols 
	// see estimated 
	ereturn list //e(b) -- coefficients e(V)  - variance -covariance matrix 
	// summarize regressors with sample that were used in the regression 
	summarize frprime L2.fsdebt L.(gdprdot ur) if e(sample)
	
	**********************
	//Hypothesis testing 
	**********************
	//test, testparm and lincom
	test L2.fsdebt				// test l2.fsdebt = 0 
	test L.gdprdot = 0.25       // test = 1 
	// test H0 : βfrprime + βL2.fsdebt + βL.gdprdot = −0.2
	lincom frprime + L2.fsdebt + L.gdprdot
	test frprime + L2.fsdebt + L.gdprdot = 0.2
	// joint test multiple coefficient = 0 
	test L.gdprdot L.ur
	//Tests of nonlinear hypotheses
	// testnl and nlcom     the syntax _b[varname]
	testnl _b[frprime] * _b[L.gdprdot] = -0.075 
	
	*********************************************
	// Computing residuals and predicted values
	*********************************************
	//predict [ type] newvar [if ] [in] [, choice]
	predict double y_hat  // predict y hat 
	predict double altsaleseps, residual // predict and generate residual 
	
	*****************************
	**** complete example - time series  statistic forecase 
	*********************************
	bcuse macro14, nodesc clear
	qui reg altsales frprime L2.fsdebt L.(gdprdot ur) if tin(,2007q3), vsquish 	// sample up to 2007q3
	predict double altsaleshat if tin(2007q4,), xb     							// predict out of sample
	predict double altsalesstdp if tin(2007q4,), stdp							// predict varances too 
	scalar tval = invttail(e(df_r),0.025)
	g double uplim = altsaleshat + tval * altsalesstdp
	g double lowlim = altsaleshat - tval * altsalesstdp
	lab var uplim "95% prediction interval"
	lab var lowlim "95% prediction interval"
	lab var altsaleshat "Ex ante static prediction"
	twoway (rarea uplim lowlim yq if tin(2007q4,), xti("") xlab(,labs(small)) ///
	legend(cols(3) size(vsmall))  ti("Ex ante static forecasts") ///
	t2("Light weight vehicle sales") /*scheme(s2mono)*/ fintensity(inten10)) ///
	(tsline altsales altsaleshat if tin(2007q4,), ylab(,angle(0) labs(small)) )
	
	
	*****************************************
	*** Regression with non-i.i.d. errors ***
	*****************************************
	//If the assumption of homoskedasticity is valid, 
	// the non-robust standard errors are more efficient than the robust standard errors.
	//Huber–White–sandwich                -- ,r
	//Newey–West estimator of the VCE     --- ,newey
	
	//Testing for heteroskedasticity
	//H0 : Var (u|X2, X3, ..., Xk ) = σu2
	// the Breusch–Pagan test ei2 = d1 + d2Zi2 + d3Zi3 + ...dlZil + vi ;  estat hettestafterregress
	bcuse hprice2a, clear
    quietly regress lprice rooms crime ldist
    estat hettest
	estat hettest rooms crime ldist
	whitetst    // need to be install from ssc 
	
	
	***************
	* Testing for serial correlation
	*****************
	// these will not run as we don't have the data 
	regress D.rs LD.r20
	predict double eps, residual
	actest, lags(6) robust             // test for auto corrolation
	newey D.rs LD.r20, lag(6)          // newey west test 
	estimates table nonHAC NeweyWest, b(%9.4f) se(%5.3f) t(%5.2f) /// 
	title(Estimates of D.rs with OLS and Newey-West standard errors)
	
	
	
	*************************************
	** regression with factor variable **
	*************************************
	webuse margex, clear
	list i.group
	summarize i.group
	regress y i.group
	regress y i.group c.age i.group#c.age
	regress y i.group##c.age                // this one is the same as the one above 
	//This also applies to the definition of interactions of continuous variables, 
	//and powers of continuous variables, such as c.age#c.age.
	// you can also use b. to indicate base level 
	
	
	// use margins 
	webuse margex
    regress y i.group  // for instance you want to get means for each group
	margins i.group    // get the mean for each group
	
	*********** margins **************************
	// get marginal effects for specific variable 
	regress y i.group c.age c.age#c.age
	margins i.group, at(age=(30 40 50 ))  // marginal effect of group at a specific age
	marginsplot, legend(rows(1)) ylab(,angle(0)) saving(margins4a, replace)   // graph marginal effects 
	
	margins, dydx(_all) // by default, when there is nonlinear relationship, it calculate average marginal effects 
	margins, eyex(age) at(age=(20(10)60))  // electicity
	marginsplot, ylab(,angle(0)) ti("Elasticity of y vs age") yline(0) saving(margins6a, replace)
	// when one of the thing is already in log, you can use dyex or eydx 
	
	// some example 
	margins, eyex(age) over(group treatment)
	marginsplot, ylab(,angle(0)) saving(margins7a, replace)
	// further examples 
	bcuse macro14, nodesc clear
	reg altsales frprime L2.fsdebt L.(gdprdot ur) c.frprime#c.L.ur
	margins, dydx(frprime L.ur)
	margins, dydx(frprime) at(L.ur=(0.04(0.01)0.1))
	
	
	// IV
	bcuse macro14, clear nodesc
	// if assuming iid
	local eq1 	ivreg2 lcsz l.lcsz cnst2 ag1 ag2 ag3 l.laaz lydz ///
	(rsa = t l.lydz l.rsa l.(lodhm limz lpimz lynlz pcpd rb lyz lvz ur) ljhgsz lcogsz ltrgsz l2.rs) if tin(1959q1,2007q3)
	di "`eq1'"
	`eq1'
	
	//Tests of overidentifying restrictions  --- Sargan–Hansen test
	local eq2 `eq1' , robust bw(auto) gmm2s orthog(l.lydz)
	di "`eq2'"
	`eq2'
	
	
	// for following topic, refer back to the presentation
	// The weak instruments problem 
	// Testing for i.i.d. errors in IV 
	
log close
translate 0_basicdo.smcl dofilename.pdf, replace



