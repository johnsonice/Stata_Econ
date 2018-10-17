*! version 1.0.0 April 12, 2015 @ 07:41:27
*! Master file for a Big and Important Project
version 13.1
set more off 
capture log close bigproject
log using bigproject, name(bigproject) replace 

clear all
 
do datamgt
do eda
do analysis

log close bigproject
