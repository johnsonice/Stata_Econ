**************************************************************
** note this is just a code snipets for reference ************
** some code my not run as you don't have the data loaded ****
**************************************************************

*****************************
***Pannel data***************
*****************************
cd "C:\Users\CHuang\Box Sync\IMF_Training_Courses\Stata\Lecture_4"
set more off 
capture log close  // close it first, in case the log file is already open
log using 4_time,replace

	*****************************
	*****  basic operations *****
	*****************************
	//There are a set of functions, described at help dates and times
	display daily("10sep2013","DMY")
	display daily("13aug1951","DMY")
	display quarterly("2013Q3","YQ")
	
	// business calender 
	sysuse sp500, clear
	bcal create sp500, from(date) generate(bdate)
	
	
	//the tin( ) function
	qui regress tr10yr L(1/4).rmbase if tin( , 2008q1) // reg from begining to 2008q1
	predict double tr10yrhat if tin(2008q2, 2009q4), xb  // generage out of sample prediction after 2008q1
	
	//estat ic after estimating a regression model, which will produce the AIC and BIC statistics.
	bcuse usmacro1,clear
	eststo clear
	eststo eight: qui regress tr10yr L(1/8).rmbase
	eststo six: qui regress tr10yr L(1/6).rmbase if e(sample)
	eststo four: qui regress tr10yr L(1/4).rmbase if e(sample)

	//fcstats - various error measures can be computed by the fcstats routine, available from the SSC Archive.
	bcuse barclaymonthly, nodesc clear
	fcstats bbjpysp L.bbjpy1f L2.bbjpy2f
	
	//Rolling-window estimation
	bcuse usmacro1
	rolling _b _se r2=e(r2) rmse=e(rmse), window(48) ///
	saving(rolltr10, replace) nodots: regress tr10yr rmbase lrwage, robust
	use rolltr10, clear
	describe
	// make charts 
	tsset end, quarterly
	tw (tsline _b_rmbase) (tsline _b_lrwage, yaxis(2) ///
	scheme(plotplainblind) ti("Rolling coefficients on real money base and real wage") ///
	t2("48-quarter windows, right endpoint labeled"))
	
	//Time series smoothing and filtering
	
	//Interpolation  - ipolate  - lowess  - lpoly
	//The denton command, available from SSC, can interpolate low-frequency series (annual 
	//or quarterly) to a higher frequency (quarterly or monthly) using an indicator series 
	//observed at the higher frequency.
	
	//tscollap -- similar to collapse but on time series - such as geometric mean 
	bcuse usmacro1, clear
	tscollap dcpi (gmean) mbase (last) oilprice (mean) foilpr=oilprice (first),to(y) gen(yr)
	
	//Unobserved components models - ucm
	clear
	webuse unrate
    ucm unrate, cycle(1) nolog
	
	// ARIMA and ARMAX models 
	clear
	bcuse macro14, nodesc
	arima cpiaucsl, arima(1,1,1) nolog
	
	// pure ar model 
	bcuse macro14, clear nodesc
	arima D.cpiaucsl, ar(1 4) nolog
	
	// ARMAX model --- with exorgenous data 
	arima d.cpiaucsl d.mcoilwtico if tin(,2007q3), ar(1) ma(1) nolog vsquish
	
	// static forecate and dynamic forecast 
	qui predict double cpihat_s if tin(2006q1,), y
    label var cpihat_s "Static forecast"
    qui predict double cpihat_d if tin(2006q1,), dynamic(tq(2007q3)) y
    label var cpihat_d "Dynamic forecast"
    tw (tsline cpihat_s cpihat_d if !mi(cpihat_s)) ///
     (scatter cpiaucsl yq if !mi(cpihat_s), c(i) ///
     ti("Static and dynamic forecasts of US CPI") ///
     t2("Forecast horizon: 2007q3-2014q4") legend(size(small)) ///
     ylab(,angle(0) labs(small)) xti("") xlab(,labs(small)))
	 
	 
	//Forecast comparison procedures
	//ssc install dmariano
	bcuse barclaymonthly, clear nodesc
	//consider one-month and two-month futures as predictors of spot rate
    dmariano bbjpysp L.bbjpy1f L2.bbjpy2f, max(6)
	dmariano bbjpysp L.bbjpy1f L2.bbjpy2f, max(6) kernel(bartlett) crit(mape)  // with mape criteria

	// ARCH models 
	//To estimate an ARCH model, you give the arch varname command
	arch cpi wage, arch(1) garch(1) 
	// test for arch effect 
	webuse urates, clear
    qui reg D.tenn LD.tenn
    estat archlm, lags(3)    // test for arch 
	arch D.tenn LD.tenn, arch(1) garch(1) nolog vsquish // run arch 
	
	
	//We may also fit a model with additional variables in the mean equation
	arch D.tenn LD.tenn LD.indiana LD.arkansas, arch(1) garch(1) nolog vsquish
	test [ARCH]L.arch + [ARCH]L.garch == 1
	
	// static vs dynamic
	webuse stocks, clear
	mgarch ccc (toyota honda = L.toyota L.honda), arch(1) garch(1) nolog vsquish 
	mgarch dcc (toyota honda = L.toyota L.honda), arch(1) garch(1) nolog vsquish
	
	
	*********************************************
	*****Vector autoregressive (VAR) models******
	*********************************************
	
	// varbasic  -- dummy version of running a var
	bcuse usmacro1
	varbasic D.lrgrossinv D.lrconsump D.lrgdp if tin(,2005q4)  // ordering matter when you look at impulse response
	irf graph fevd, lstep(1)   // decompose of percent of variance 
	
	// The varsoc command allows you to select the appropriate lag order for the VAR
	// command varwle computes Wald tests to determine whether certain lags can be excluded
	// The forecast error variance decomposition (FEVD) measures the fraction of the forecast 
	// error variance of an endogenous variable that can be attributed to orthogonalized shocks 
	// to itself or to another endogenous variable.
	
	// var with exorgenous variables
	var D.lrgrossinv D.lrconsump D.lrgdp if tin(,2005q4), lags(1/4) exog(D.lrmbase)
	testparm D.lrmbase
	// block F tests
	vargranger  // to some extent you can see and help you with ordering 
	//The varsoc command will produce selection order criteria, and highlight the optimal lag.
	varsoc
	//stability of the VAR
	varstable
	//As the estimated VAR appears stable, we can produce IRFs and FEVDs in tabular or graphical form:
    irf create icy, step(8) set(res1)
	irf table oirf coirf, impulse(D.lrgrossinv) response(D.lrconsump) noci stderr 
	irf graph oirf coirf, impulse(D.lrgrossinv) response(D.lrconsump) lstep(1) scheme(s2mono)
	
	
	************************************
	*****Structural VAR estimation******
	************************************
	bcuse usmacro1
	
	// if you set you matrix in this way, it is the same as the default var with default decomposition
	matrix A = (1, 0, 0 \ ., 1, 0 \ ., ., 1)
	matrix B = (., 0, 0 \ 0, ., 0 \ 0, 0, 1)
	matrix list A
	matrix list B
	svar D.lrgrossinv D.lrconsump D.lrgdp if tin(,2005q4), aeq(A) beq(B) nolog
	
	
	// you can impose specific structures 
	
	matrix Arest = (1, 0, 0 \ 0, 1, 0 \ ., ., 1)
	matrix list Arest
	svar D.lrgrossinv D.lrconsump D.lrgdp if tin(,2005q4), aeq(Arest) beq(B) nolog
	
	
	//Long-run SVAR models
	//In a long-run SVAR, constraints are placed on elements of the C matrix.
	matrix lr = (., 0\0, .)
    matrix list lr
	svar D.lrmbase D.lrgdp, lags(4) lreq(lr) nolog
	
	
	// when series are non-stationary, VARs by defination will give sperious relationship 
	// vecm
	bcuse pwt90, clear nodesc
	keep if inlist(countrycode,"GBR")
	g lp = log(pl_da)
	g lxr = log(xr)
	varsoc lp lxr if tin(1959,2007)			// find optimal number of lags
	vecrank lp lxr if tin(1959,2007)  		// test
	vec lp lxr if tin(1959,2007), lags(2)
	// We can evaluate the cointegrating equation by using predict to generate its in-sample values:
	predict ce1 if e(sample), ce eq(#1)
    tsline ce1 if e(sample), ylab(,angle(0) labs(small)) yline(0) xlab(,labs(small)) xti("")
	vecstable, graph           // test of stationality
	
	// forecast
	tsset year, yearly
    fcast compute ppp_, step(7)
    fcast graph ppp_lp ppp_lxr, observed legend(rows(1) size(small)) ///
    ylab(,angle(0) labs(small)) xlab(,labs(small)) ///
    byopts(ti("Ex ante VECM forecasts, UK vs US RER components"))
	
	
	
	// panel vector autoregression 
	// pvar, pvarsoc,pvargranger
	
	// Panel cointegration tests
	
	// Model specification, solution and dynamic forecasting
	
	// also dsge ; inear state-space models ; dynamic-factor multivariate time series models
	// models of fractionally integrated (ARFIMA) time series
	
	
	
	
log close
translate 0_basicdo.smcl dofilename.pdf, replace



