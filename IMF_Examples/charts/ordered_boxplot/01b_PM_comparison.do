* .do file that compares REER elasticity of relative prices for different REER measures

cd "\\Data1\spr\DATA\XU\VAREER\2015 09 - WEO-replication\temp"
**cd "C:\Users\JBarkema\Desktop\VAREER\2015 09 - WEO-replication\temp"
use PM_reer_ppi, clear
merge 1:1 wdicode using PM_imfreer_wiod.dta
drop _merge
merge 1:1 wdicode using PM_vareer.dta
drop _merge

* Re-label according to corresponding REER measure
label var x_b_PM_vareer "XR pass-through into import prices, VAREER"
label var x_b_PM_imfreer_wiod "XR pass-through into import prices, IMF REER w/WIOD data"
label var x_b_PM_reer_ppi "XR pass-through into import prices, WEO (2015)"

* Chart 1: Scatter 
* 1a:  x_b_PM_vareer vs. x_b_PM_imfreer_wiod
twoway (function y=x, range(-1.25 0.5) lc(gs4) lw(thin))(scatter x_b_PM_vareer x_b_PM_imfreer_wiod, mlabel(wdicode) mlabsize(vsmall) mcolor(navy)) , xscale(range(-1.25 0.5)) yscale(range(-1.25 0.5)) xlabel(-1.25(0.25)0.5) ylabel(-1.25(0.25)0.5) legend(order(2))
** 1b: x_b_PM_imfreer_wiod vs. x_b_PM_reer_ppi
twoway  (function y=x, range(-1.25 0.5) lc(gs4) lw(thin))(scatter x_b_PM_vareer x_b_PM_reer_ppi, mlabel(wdicode) mlabsize(vsmall) mcolor(navy)), xscale(range(-1.25 0.5)) yscale(range(-1.25 0.5)) xlabel(-1.25(0.25)0.5) ylabel(-1.25(0.25)0.5) legend(order(2))


* Chart 2: Coefficient comparison with std dev, by country

foreach v in vareer imfreer_wiod reer_ppi {
	gen `v'l =  x_b_PM_`v'-1.97*x_se_PM_`v'
	gen `v'h =  x_b_PM_`v'+1.97*x_se_PM_`v'
}

sort x_b_PM_vareer
capture drop axisvar
gen axisvar=_N-_n
labmask axisvar, values(wdicode)

***THIS IS THE ONE YOU WANT***

*encode wdicode, gen(axisvar1) 

twoway (scatter x_b_PM_vareer axisvar, mlabel(wdicode) mlabposition(12) mlabgap(20) mlabsize(tiny) sort yline(0, lcolor(black)) mcolor(edkblue) legend(off) xtitle("")) (rcap vareerl vareerh axisvar, lcolor(edkblue)) (scatter x_b_PM_imfreer_wiod axisvar, sort yline(0, lcolor(black)) mcolor(red) legend(off) xtitle("")) (rcap imfreer_wiodl imfreer_wiodh axisvar, lcolor(red)) 

* Chart 3: t-stat by country

** Generate t-stats for each variable
gen tstatvareer = abs(x_b_PM_vareer/x_se_PM_vareer)
gen tstatimfreer = abs(x_b_PM_imfreer_wiod/x_se_PM_imfreer_wiod)
gen tstatreerppi = abs(x_b_PM_reer_ppi/x_se_PM_reer_ppi)
gen tstat = 1.97

**Graph t-stats by variable by country versus 
twoway (bar tstatvareer axisvar)(scatter tstatvareer axisvar, mlabel(wdicode) mlabpos(12) m(none) mlabsize(tiny))(line tstat axisvar), legend(order(1 3)) 

twoway (bar tstatimfreer axisvar)(scatter tstatimfreer axisvar, mlabel(wdicode) mlabpos(12) m(none) mlabsize(tiny))(line tstat axisvar), legend(order(1 3)) 

twoway (bar tstatreerppi axisvar)(scatter tstatreerppi axisvar, mlabel(wdicode) mlabpos(12) m(none) mlabsize(tiny))(line tstat axisvar), legend(order(1 3)) 





