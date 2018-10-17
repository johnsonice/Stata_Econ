*filtering
webuse gdp2       		 		// load data
tsset              				// check if data has been ts set   
tsfilter bk gdp_bk = gdp_ln		// generate cyclical part of log gdp to be gdp_bk 

*autocorrelation
webuse gdp2, clear
tsset    
corrgram gdp, lags(12)			// will generate AC and PAC table 

*unit root rest  -- it is only testing to see if it is random walk without drift
webuse air2,clear
line air t
dfuller air                     		// dickey fuller test 
dfuller air, lags(3) trend regress		// with trend and show regression result 
// there are other test that you can try as well 

*var
webuse lutkepohl2, clear
tsset
var dln_inv dln_inc dln_consump


*--------- so after var, we need to diagnosize our model ---------*
// for instance, if we used right number of lags, is VAR stable, Granger causality, etc
*-----------------------------------------------------------------*

*lag selection
webuse lutkepohl2, clear
varsoc dln_inv dln_inc dln_consump     // will give your AIC, HQIC, SBIC etc

*var stability
webuse lutkepohl2, clear
var dln_inv dln_inc dln_consump
varstable, graph                       	// see if all the roots lies within the unity circle
										// if it does, means the model is stationary 

*autocorrelation test for residuals   
webuse lutkepohl2,clear
var dln_inv dln_inc dln_consump
varlmar, mlag(5)                       	// if there are autocorrelation, 
										// you can usually add lags to absorb the auto-corrolation
										// it is a joint test for all lag coefficients for error terms 

*Granger causality
webuse lutkepohl2,clear
var dln_inv dln_inc dln_consump
vargranger

*svar                                   // ordering is important, mostly based on theories and enperience 
webuse lutkepohl2
matrix A = (1,0,0\.,1,0\.,.,1)          // a matrix and b matrix are very typically setup this way, 
matrix B = (.,0,0\0,.,0\0,0,.)			// people usually change the sequence of imput variables to change ordering
matrix list A
matrix list B
svar dln_inv dln_inc dln_consump if qtr<=tq(1978q4), aeq(A) beq(B)		// short-run 

*irf									// if you want to change the sign, you need to look at your working directory, and a temp file and change the sign
webuse lutkepohl2, clear
var dln_inv dln_inc dln_consump if qtr<=tq(1978q4), lags(1/2) dfk
irf create order1, step(10) set(myirf1)
irf graph oirf, impulse(dln_inc) response(dln_consump)

*Cointegration test
ssc install johans 
use http://fmwww.bc.edu/ec-p/data/macro/wgmacro.dta, clear
johans investment income consumption, l(4) nonormal

*vecm									// so stata still have limitted capability in terms of how you can 
webuse rdinc							// change the specific euqations 
vec ln_ne ln_se
