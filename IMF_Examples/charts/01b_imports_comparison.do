* .do file that compares REER elasticity of relative prices for different REER measures
clear
cd "\\Data1\spr\DATA\XU\VAREER\2015 09 - WEO-replication\temp"
**cd "C:\Users\JBarkema\Desktop\VAREER\2015 09 - WEO-replication\temp"
use M_1step_reer_ppi, clear
merge 1:1 wdicode using M_1step_imfreer_wiod.dta
drop _merge
merge 1:1 wdicode using M_1step_vareer.dta
drop _merge
merge 1:1 wdicode using M_1step_BJ_ioreer.dta

* Re-label according to corresponding REER measure
label var x_b_M_vareer "XR pass-through into import volumes, VAREER"
label var x_b_M_BJ_ioreer "XR pass-through into import volumes, IOREER"
label var x_b_M_imfreer_wiod "XR pass-through into import volumes, IMF REER w/WIOD data"
label var x_b_M_reer_ppi "XR pass-through into import volumes, WEO (2015)"

* Chart 1: Scatter 
** 1a:  vareer vs. imfreer (wiod)
set graphics off
foreach v in x ys ye ysgfc yegfc {
twoway (function y=x, range(-1.25 2.5) lc(gs4) lw(thin))(scatter `v'_b_M_vareer `v'_b_M_imfreer_wiod, mlabel(wdicode) msize(vsmall) mlabsize(tiny) mcolor(navy)) , xscale(range(-1.25 2.5)) yscale(range(-1.25 2.5)) xlabel(-1.25(0.25)2.5, labsize(vsmall)) ylabel(-1.25(0.25)2.5, labsize(vsmall)) yscale(titlegap(*5)) xscale(titlegap(*5)) legend(off) ytitle(Bems & Johnson VAREER) xtitle(IMF (WIOD data) REER) title("") subtitle(`v'-vareer &`v'-imfreer) name(graph`v'var_imf, replace)
local grnames1 `grnames1' graph`v'var_imf
}
gr combine `grnames1'
graph export scatter_M_vareer&imfreer.pdf, replace


** 1b: imf_reer (wiod) vs. reer_ppi
foreach v in x ys ye ysgfc yegfc {
twoway (function y=x, range(-1.25 2.5) lc(gs4) lw(thin))(scatter `v'_b_M_reer_ppi `v'_b_M_imfreer_wiod, mlabel(wdicode) msize(vsmall) mlabsize(tiny) mcolor(navy)) , xscale(range(-1.25 2.5)) yscale(range(-1.25 2.5)) xlabel(-1.25(0.25)2.5, labsize(tiny)) ylabel(-1.25(0.25)2.5, labsize(tiny)) yscale(titlegap(*5)) xscale(titlegap(*5)) legend(off) ytitle(REER PPI) xtitle(IMF (WIOD data) REER) title("") subtitle(`v'-reer_ppi &`v'-imfreer) name(graph`v'var_imf, replace)
local grnames2 `grnames2' graph`v'var_imf
}
gr combine `grnames2'
graph export scatter_M_imfreer&reerppi.pdf, replace

**1c:  ioreer vs. imfreer 
foreach v in x ys ye ysgfc yegfc {
twoway (function y=x, range(-1 2.5) lc(gs4) lw(thin))(scatter `v'_b_M_BJ_ioreer `v'_b_M_imfreer_wiod, mlabel(wdicode) msize(vsmall) mlabsize(tiny) mcolor(navy)) , xscale(range(-1 2.5)) yscale(range(-1 2.5)) xlabel(-1(0.25)2.5, labsize(vsmall)) ylabel(-1(0.25)2.5, labsize(vsmall)) yscale(titlegap(*5)) xscale(titlegap(*5)) legend(off) ytitle(BJ IOREER) xtitle(IMF (WIOD data) REER) title("") subtitle(`v'-ioreer &`v'-imfreer) name(graph`v'var_imf, replace)
local grnames3 `grnames3' graph`v'var_imf
}
gr combine `grnames3'
graph export scatter_M_ioreer&imfreer.pdf, replace


* Chart 2: Coefficient comparison with std dev, by country
foreach var in vareer BJ_ioreer imfreer_wiod reer_ppi{
foreach v in x ys ye ysgfc yegfc {
	gen `v'`var'l =  `v'_b_M_`var'-1.97*`v'_se_M_`var'
	gen `v'`var'h =  `v'_b_M_`var'+1.97*`v'_se_M_`var'
	}
}
gsort- x_b_M_vareer
capture drop axisvar
gen axisvar=_N-_n
labmask axisvar, values(wdicode)

** 2a: vareer vs. imf_reer (wiod)
foreach v in x ys ye ysgfc yegfc { 
sort `v'_b_M_vareer
twoway (scatter `v'_b_M_vareer axisvar, mlabel(wdicode) msize(small) mlabposition(6) mlabgap(10) mlabsize(half_tiny) yline(0, lcolor(black)) mcolor(edkblue) legend(off) xlabel("") xtitle(""))(rcap `v'vareerl `v'vareerh axisvar, lcolor(edkblue))(scatter `v'_b_M_imfreer_wiod axisvar, yline(0, lcolor(black)) mcolor(red) msize(small) legend(off) xtitle(""))(rcap `v'imfreer_wiodl `v'imfreer_wiodh axisvar, lcolor(red)), subtitle(`v'-vareer vs. `v'-imfreer) name(graph`v'vareer, replace)
local grnames4 `grnames4' graph`v'vareer
}
gr combine `grnames4'
graph export rcap_M_vareer&imfreer.pdf, replace

** 2b: imf_reer (wiod) vs. reer_ppi
foreach v in x ys ye ysgfc yegfc { 
sort `v'_b_M_imfreer_wiod
twoway (scatter `v'_b_M_imfreer_wiod axisvar, mlabel(wdicode) msize(small) mlabposition(6) mlabgap(10) mlabsize(half_tiny) yline(0, lcolor(black)) mcolor(edkblue) legend(off) xlabel("") xtitle(""))(rcap `v'imfreer_wiodl `v'imfreer_wiodh axisvar, lcolor(edkblue))(scatter `v'_b_M_reer_ppi axisvar, yline(0, lcolor(black)) mcolor(red) msize(small) legend(off) xtitle(""))(rcap `v'reer_ppil `v'reer_ppih axisvar, lcolor(red)), subtitle(`v'-imfreer vs. `v'-reer_ppi) name(graph`v'imfreer, replace)
local grnames5 `grnames5' graph`v'imfreer
}
gr combine `grnames5'
graph export rcap_M_imfreer&reerppi.pdf, replace

** 2c: ioreer vs. imfreer
foreach v in x ys ye ysgfc yegfc { 
sort `v'_b_M_BJ_ioreer
twoway (scatter `v'_b_M_BJ_ioreer axisvar, mlabel(wdicode) msize(small) mlabposition(6) mlabgap(10) mlabsize(half_tiny) yline(0, lcolor(black)) mcolor(edkblue) legend(off) xlabel("") xtitle(""))(rcap `v'BJ_ioreerl `v'BJ_ioreerh axisvar, lcolor(edkblue))(scatter `v'_b_M_imfreer_wiod axisvar, yline(0, lcolor(black)) mcolor(red) msize(small) legend(off) xtitle(""))(rcap `v'imfreer_wiodl `v'imfreer_wiodh axisvar, lcolor(red)), subtitle(`v'-ioreer vs. `v'-imfreer) name(graph`v'ioreer, replace)
local grnames6 `grnames6' graph`v'ioreer
}
gr combine `grnames6'
graph export rcap_M_ioreer&imfreer.pdf, replace



**INDIVIUAL GRAPHS
**SCATTERS
*vareer
set graphics off
twoway (function y=x, range(-1.25 1.5) lc(gs4) lw(thin))(scatter x_b_M_vareer x_b_M_imfreer_wiod, mlabel(wdicode) msize(vsmall) mlabsize(tiny) mcolor(navy)) , xscale(range(-1.25 1.5)) yscale(range(-1.25 1.5)) xlabel(-1.25(0.25)1.5, labsize(vsmall)) ylabel(-1.25(0.25)1.5, labsize(vsmall)) yscale(titlegap(*5)) xscale(titlegap(*5)) legend(off) ytitle(Bems & Johnson VAREER) xtitle(IMF (WIOD data) REER) title("") subtitle(x-vareer &x-imfreer)
graph export scatter_M_vareer&imfreer_differenced.pdf, replace
*ioreer
twoway (function y=x, range(-1.25 1.5) lc(gs4) lw(thin))(scatter x_b_M_BJ_ioreer x_b_M_imfreer_wiod, mlabel(wdicode) msize(vsmall) mlabsize(tiny) mcolor(navy)) , xscale(range(-1.25 1.5)) yscale(range(-1.25 1.5)) xlabel(-1.25(0.25)1.5, labsize(vsmall)) ylabel(-1.25(0.25)1.5, labsize(vsmall)) yscale(titlegap(*5)) xscale(titlegap(*5)) legend(off) ytitle(Bems & Johnson VAREER) xtitle(IMF (WIOD data) REER) title("") subtitle(x-ioreer &x-imfreer)
graph export scatter_M_ioreer&imfreer_differenced.pdf, replace
*imf_reer vs. reer_ppi
twoway (function y=x, range(-1.25 1.5) lc(gs4) lw(thin))(scatter x_b_M_reer_ppi x_b_M_imfreer_wiod, mlabel(wdicode) msize(vsmall) mlabsize(tiny) mcolor(navy)) , xscale(range(-1.25 1.5)) yscale(range(-1.25 1.5)) xlabel(-1.25(0.25)1.5, labsize(vsmall)) ylabel(-1.25(0.25)1.5, labsize(vsmall)) yscale(titlegap(*5)) xscale(titlegap(*5)) legend(off) ytitle(Bems & Johnson VAREER) xtitle(IMF (WIOD data) REER) title("") subtitle(x-reerppi &x-imfreer)
graph export scatter_M_reerppi&imfreer_differenced.pdf, replace

**RCAPS
twoway (scatter x_b_M_imfreer_wiod axisvar, mlabel(wdicode) msize(small) mlabposition(6) mlabgap(10) mlabsize(half_tiny) yline(0, lcolor(black)) mcolor(edkblue) legend(off) xlabel("") xtitle(""))(rcap ximfreer_wiodl ximfreer_wiodh axisvar, lcolor(edkblue))(scatter x_b_M_reer_ppi axisvar, yline(0, lcolor(black)) mcolor(red) msize(small) legend(off) xtitle(""))(rcap xreer_ppil xreer_ppih axisvar, lcolor(red)), subtitle(x-imfreer vs. x-reer_ppi) name(graphximfreer, replace)
graph export rcap_M_reerppi&imfreer_differenced.pdf, replace






