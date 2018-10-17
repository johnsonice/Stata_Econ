*! version 1.0.0 April 12, 2015 @ 07:41:16
*! data analysis for BIP
version 13.1
set more off 
capture log close analysis
log using analysis, name(analysis) replace 

clear all

use autoex

regress price gp100m weight i.rep78, base
margins, eyex(gp100m) over(rep78)

log close analysis
