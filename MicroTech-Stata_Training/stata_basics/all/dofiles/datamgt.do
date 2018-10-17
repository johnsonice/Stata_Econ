*! version 1.0.0 April 12, 2015 @ 07:41:33
*! data management for BIP
version 13.1
set more off 
capture log close datamgt
log using datamgt, name(datamgt) replace 

clear all

sysuse auto
label def poor2ex 1 "poor" 2 "lousy" 3 "OK" 4 "not bad" 5 "excellent"
label val rep78 poor2ex

gen gp100m = 100/mpg
label var gp100m "Gallons per 100 miles"

order gp100m, before(mpg)

save autoex, replace

log close datamgt
