set more off



/* Slide 6 */
use usmacro, clear
tsline fedfunds, name(fedfunds) xtitle("") xlabel(,angle(vertical)) nodraw
tsline infl, name(inflation) xtitle("") xlabel(,angle(vertical)) nodraw
use snp500, clear
tsline areturns, name(areturns) xtitle("") xlabel(,angle(vertical)) nodraw
use ipq, clear
tsline ip if tq>=tq(1950q1), name(ip) xtitle("") xlabel(,angle(vertical)) nodraw
graph combine fedfunds inflation areturns ip



/* Slide 9*/
clear
use nasdaq
describe
list in 1/5

/* Slide 11 */
generate sifdate = date(date,"YMD")
list date sifdate in 1/10

/* Slide 13 */
generate hrfdate = sifdate
format %td hrfdate
list date sifdate hrfdate in 1/10

/* Slide 14 */
tsset hrfdate, daily

/** INTERACTIVE EXAMPLE **/
gen qdate = sifdate
format qdate %tq
list in 1/10
gen qtrdate = qofd(sifdate)
format qtrdate %tq
list in 1/10
drop date sifdate qdate qtrdate

/* Slide 16 */
list hrfdate index L.index F.index in 1/10

/* Slide 18 */
bcal create nasdaq, from(hrfdate) generate(bcaldate) excludemissing(index) replace
drop if missing(bcaldate)

/* Slide 19 */
tsset bcaldate
drop hrfdate
list bcaldate index L.index F.index in 1/10
save nasdaqbcal, replace



/* Slide 26 */
clear
set seed 2016
set obs 1000
gen time = _n
tsset t
gen noise = rnormal()

/* Slide 27 */
tsline noise, name(noise) nodraw
hist noise, kdensity name(histnoise) nodraw
graph combine noise histnoise, rows(2)

/* Slide 29 */
gen rwalk = rnormal() in 1
replace rwalk = L.rwalk + rnormal() in 2/L
save tsdata, replace

/* Slide 30 */
tsline rwalk, name(rwalk) nodraw
hist rwalk, kdensity name(histrwalk) nodraw
graph combine rwalk histrwalk, rows(2)

/* Slide 34 */
ac noise

/* Slide 35 */
ac rwalk

/* Slide 38 */ 
pac noise

/* Slide 39 */
pac rwalk

/* Slide 40 */
corrgram noise, lags(10)



/* Slide 53 */
clear
set seed 2016
set obs 1000
generate time = _n
tsset time
generate err = rnormal() 
generate y = err in 1
replace y = err + 0.7*L.err in 2/L
save ma1, replace

/* Slide 54 */
ac y

/* Slide 55 */
pac y

/* Slide 56 */
arima y, ma(1) noconstant



/* Slide 63 */
clear
set seed 2016
set obs 1000
generate time = _n
tsset time
generate y = rnormal() in 1
replace y = 0.7*L.y + rnormal() in 2/L
save ar1, replace

/* Slide 64 */
ac y

/* Slide 65 */
pac y

/* Slide 66 */
arima y, ar(1) noconstant



/* Slide 74 */
clear
set seed 2016
set obs 1000
generate time = _n
tsset time
generate err = rnormal(0.2)
generate y = err in 1
replace y = 0.6*L.y + err + 0.5*L.err in 2
replace y = 0.6*L.y + 0.2*L2.y + err + 0.5*L.err in 3/L

/* Slide 75 */
ac y

/* Slide 76 */
pac y

/* Slide 77 */
arima y, ar(1/2) ma(1) noconstant



/* Slide 80 */
clear
use emp2
ac echanges
pac echanges
quietly arima echanges, ar(1) nolog
estimates store ar1
quietly arima echanges, ar(6) nolog
estimates store ar6
quietly arima echanges, ar(1/6) nolog
estimates store ar1_6
quietly arima echanges, ma(1) nolog
estimates store ma1
quietly arima echanges, ma(6) nolog
estimates store ma6
quietly arima echanges, ma(1/6) nolog
estimates store ma1_6
quietly arima echanges, ar(1) ma(1) nolog
estimates store ar1ma1
quietly arima echanges, ar(6) ma(6) nolog
estimates store ar6ma6
quietly arima echanges, ar(1) ma(6) nolog
estimates store ar1ma6
quietly arima echanges, ar(6) ma(1) nolog
estimates store ar6ma1
quietly arima echanges, ar(1/6) ma(1/6) nolog
estimates store ar1_6ma1_6

/* Slide 81 */
estimates stats ar1 ar6 ar1_6 ma1 ma6 ma1_6 ar1ma1 ar6ma6 ar1_6ma1_6



/* Slide 86 */
use umcsent, clear

/* Slide 87 */
arfima umcsent, ar(1 2) nolog



/* Slide 91 */
clear
use nasdaqbcal
quietly generate returns = (D.index/L.index)*100
tsline returns 

/* Slide 92 */
arch returns L(1/3).returns, arch(1/2) nolog

/* Slide 94 */
arch returns L(1/3).returns, arch(1/2) garch(1) nolog



/* Slide 100 */
clear
use rgnp
tsline rgnp

/* Slide 101 */
mswitch ar rgnp, ar(1/4) nolog 

/* Slide 102 */
predict fprob, pr smethod(filter)
tsline fprob recession

/* Slide 103 */
estat duration



/* Slide 106 */
clear
use usmacro
tsline fedfunds
quietly regress fedfunds L.fedfunds
estat sbknown, break(tq(1981q2))

/* Slide 107 */
estat sbknown, break(tq(1970q1) tq(1995q1))

/* Slide 109 */
estat sbsingle



/* Slide 114 */
clear
use ipq
tsline ip_ln

/* Slide 115 */
generate t = _n
generate t2 = t^2
arima ip_ln t t2
predict ip_ln_time
twoway tsline ip_ln_time ip_ln

/* Slide 117 */
predict ip_ln_detrend, residuals
tsline ip_ln_detrend

/* Slide 118 */
ac ip_ln_detrend

/* Slide 119 */
pac ip_ln_detrend

/* Slide 120 */
arima ip_ln_detrend, ar(1/2) ma(1) nolog

/* Slide 124 */
tsline ip_ln, name(ipln) xlabel(,angle(vertical)) nodraw
tsline D.ip_ln, name(dipln) xlabel(,angle(vertical)) nodraw
graph combine ipln dipln

/* Slide 125 */
ac D.ip_ln

/* Slide 126 */
pac D.ip_ln

/* Slide 127 */
arima ip_ln, arima(0,1,5) nolog



/* Slide 131 */
clear
use ipq
dfgls ip_ln, maxlag(10)

/* Slide 133 */
tsfilter hp ip_ln_hp = ip_ln
tsline ip_ln_hp

/* Slide 136 */
ucm ip_ln, model(rwdrift) nolog

/* Slide 137 */
predict ip_ln_ucm, residuals
tsline ip_ln_ucm



/* Slide 142 */
clear
set obs 100
gen t = _n
tsset t
generate y1 = 2*cos(2*_pi*t*6/100) + 3*sin(2*_pi*t*6/100)
generate y2 = 4*cos(2*_pi*t*10/100) + 5*sin(2*_pi*t*10/100)
generate y3 = 6*cos(2*_pi*t*40/100) + 7*sin(2*_pi*t*40/100)
generate y = y1 + y2 + y3

/* Slide 143 */
tsline y1, name(y1) nodraw
tsline y2, name(y2) nodraw
tsline y3, name(y3) nodraw
tsline y, name(y) nodraw
graph combine y1 y2 y3 y 

/* Slide 145 */
pergram y

/* Slide 148 */
arima y, noconstant nolog
psdensity psden_wn omega_wn
twoway line psden_wn omega_wn



/* Slide 150 */
clear 
use ar1
arima y, ar(1) noconstant nolog
psdensity psden_ar1 omega_ar1
twoway line psden_ar1 omega_ar1



/* Slide 152 */
clear 
use ma1
arima y, ma(1) noconstant nolog
psdensity psden_ma1 omega_ma1
twoway line psden_ma1 omega_ma1



/* Slide 161 */
clear 
use usmacro
tsline fedfunds

/* Slide 163 */
ac fedfunds

/* Slide 164 */
pac fedfunds

/* Slide 165 */
arima fedfunds if date<tq(2000q1), ar(1) ma(1) nolog

/* Slide 166 */
predict ffr_onestep_arma
tsline fedfunds ffr_onestep_arma if tin(1998q1,)

/* Slide 167 */
predict ffr_dyn_arma, dynamic(tq(2000q1))
tsline fedfunds ffr_dyn_arma if tin(1998q1,)

/* Slide 169 */
arima fedfunds L.fedfunds infl ogap if date<tq(2000q1), noconstant nolog
estimates store armataylor

/* Slide 170 */
predict ffr_dyn_taylor, dynamic(tq(2000q1))
tsline fedfunds ffr_dyn_taylor if tin(1998q1,)

/* Slide 172 */
mswitch dr fedfunds if date<tq(2000q1), switch(L.fedfunds infl ogap, noconstant) nolog

/* Slide 173 */
predict ffr_dyn_mstaylor, dynamic(tq(2000q1))
tsline fedfunds ffr_dyn_mstaylor if tin(1998q1,)

/* Slide 174 */
quietly generate sqerr_taylor = (fedfunds-ffr_dyn_taylor)^2 if tin(2000q1,)
quietly summarize sqerr_taylor 
scalar rmse_taylor = sqrt(`r(mean)'/`r(N)')
quietly generate sqerr_mswitch = (fedfunds-ffr_dyn_mstaylor)^2 if tin(2000q1,)
quietly summarize sqerr_mswitch
scalar rmse_mstaylor = sqrt(`r(mean)'/`r(N)')
display rmse_taylor rmse_mstaylor

/* Slide 175 */
forecast create taylorfcst, replace
forecast estimates armataylor
forecast solve, begin(tq(2000q1)) log(off)

/* Slide 176 */
tsline fedfunds f_fedfunds if tin(1998q1,)

/* Slide 177 */
forecast describe estimates
forecast describe endogenous

/* Slide 178 */
forecast describe solve

/* Slide 181 */
drop f_fedfunds
forecast solve, begin(tq(2000q1)) log(off) simulate(betas, statistic(stddev, prefix(sd_)) reps(30))
generate up_ci = f_fedfunds + invnormal(0.975)*sd_fedfunds
generate low_ci = f_fedfunds + invnormal(0.025)*sd_fedfunds

/* Slide 182 */
twoway rarea up_ci low_ci date if tin(1998q1,), fintensity(inten20) lwidth(none) || line fedfunds f_fedfunds date if tin(1998q1,), lpattern(solid dash)



/* Slide 186 */
clear
use usmacro
varsoc inflation urate fedfunds if tin(,1999q4)

/* Slide 187 */
var inflation urate fedfunds if tin(,1999q4)
varstable, graph

/* Slide 190 */
vargranger

/* Slide 196 */
irf create usmacro_irf, step(10) set(myirf) replace
describe using myirf.irf, simple
irf graph oirf, impulse(urate)

/* Slide 198 */
fcast compute varf_, step(10)
fcast graph varf_inflation varf_urate varf_fedfunds, observed

/* Slide 200 */
irf table fevd, response(fedfunds) noci

/* Slide 205 */
matrix A = [1,0,0\.,1,0\.,.,1]
matrix rownames A = inflation urate fedfunds
matrix colnames A = inflation urate fedfunds
matrix list A
matrix B = [.,0,0\0,.,0\0,0,.]
matrix rownames B = inflation urate fedfunds
matrix colnames B = inflation urate fedfunds
matrix list B

/* Slide 206 */
svar inflation urate fedfunds if tin(,1999q4), aeq(A) beq(B) nolog nocnsreport

/* Slide 207 */
quietly irf create usmacro_svarirf, step(10) set(mysvarirf) replace
irf graph oirf, impulse(urate)

/* Slide 208 */
matrix C = [.,.,0\0,.,0\0,0,.]
matrix rownames A = inflation urate fedfunds
matrix colnames A = inflation urate fedfunds
matrix list C

/* Slide 209 */
svar inflation urate fedfunds if tin(,1999q4), lreq(C) nolog nocnsreport



/* Slide 218 */
clear
webuse txhprice
tsline austin dallas houston sa

/* Slide 219 */
varsoc dallas houston
vecrank dallas houston

/* Slide 220 */
vec dallas houston

/* Slide 224 */
clear
webuse stocks
tsline nissan

/* Slide 225 */
mgarch ccc (nissan honda = L.nissan L.honda, noconstant), arch(1) garch(1) nolog vsquish

/* Slide 228 */
mgarch dcc (nissan honda = L.nissan L.honda, noconstant), arch(1) garch(1) nolog vsquish



/* Slide 231 */
clear
webuse irates4
mgarch dvech (D.bond D.tbill = LD.bond LD.tbill), arch(1) nolog vsquish




/* Slide 237 */
webuse manufac, clear
constraint 1 [u1]L.u2 = 1
constraint 2 [u1]e.u1 = 1
constraint 3 [D.lncaputil]u1 = 1
sspace (u1 L.u1 L.u2 e.u1, state noconstant) (u2 e.u1,	state noconstant) /*
*/ (D.lncaputil u1, noconstant), constraints(1/3) covstate(diagonal) nolog

/* Slide 238 */
arima D.lncaputil, ar(1) ma(1) tech(nr) noconstant nolog nrtolerance(1e-9)

/* Slide 241 */
constraint 4 [u1]L.u2 = 1
constraint 5 [u1]e.u1 = 1
constraint 6 [u3]e.u3 = 1
constraint 7 [D.lncaputil]u1 = 1
constraint 8 [D.lnhours]u3 = 1

/* Slide 242 */
sspace  (u1 L.u1 L.u2 e.u1, state noconstant) (u2 e.u1,	state noconstant)	/*
*/		(u3 L.u1 L.u3 e.u3,	state noconstant) (D.lncaputil u1, noconstant)	/*
*/		(D.lnhours u3, noconstant), constraints(4/8) covstate(diagonal)     /*
*/		nolog nocnsreport 



/* Slide 246 */
use dfex, clear
dfactor (D.(ipman income hours unemp) = , noconstant) (f=, ar(1/2)), nolog
