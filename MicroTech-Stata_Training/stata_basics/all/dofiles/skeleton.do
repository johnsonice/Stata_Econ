* replace skeleton with the name of your do-file
version 13.1
set more off
capture log close skeleton
log using skeleton, name(skeleton) replace

clear // should be temporary
----- put your code here -----


log close skeleton
