*! version 1.0.0 April 12, 2015 @ 07:41:39
*! EDA for BIP
version 13.1
set more off 
capture log close eda
log using eda, name(eda) replace 

clear all

use autoex

tab rep78 foreign, col
graph matrix price weight gp100m rep78, saving(gphmat, replace)

log close eda
