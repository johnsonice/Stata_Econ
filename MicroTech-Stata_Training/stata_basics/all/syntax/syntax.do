sysuse census
coodbook
codebook
d
d
d, f


de pop*
su pop-popurban
do "C:\Users\microtek\AppData\Local\Temp\STD00000000.tmp"
sort pop
list state pop in 1/5
do "C:\Users\microtek\AppData\Local\Temp\STD00000000.tmp"
help gsort
do "C:\Users\microtek\AppData\Local\Temp\STD00000000.tmp"
do "C:\Users\microtek\AppData\Local\Temp\STD00000000.tmp"
do "C:\Users\microtek\AppData\Local\Temp\STD00000000.tmp"
do "C:\Users\microtek\AppData\Local\Temp\STD00000000.tmp"
list state medage if 30<= medage & medage < 32
help function
list state if ustrpos(state, " ")>0
gen dth_per_1000 = 1000*death/pop
scatter dth_per_1000 medage
scatter dth_per_1000 medage ||lfit
scatter dth_per_1000 medage || lfit dth_per_1000 medage
scatter dth_per_1000 medage || lfit dth_per_1000 medage,mlabel(state2)
scatter dth_per_1000 medage,mlabel(state2)|| lfit dth_per_1000 medage
su dth_per_1000
su dth_per_1000
su dth_per_1000 [aw=pop]
su dth_per_1000 [aw=pop]
by region: summarize dth_per_1000 [aw = pop]
bys region: summarize dth_per_1000 [aw = pop]
log close
