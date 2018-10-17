
*********************************************
*typical way of setting up your do file structure 
*********************************************

**cd "U:\My Documents\training_Stata\2.intro_to_programming"
version 12 
clear
set more off
cap log close                       // this is for surprise error message for log error
cd "\\was.int.imf.org\citrix\Redirected\chuang\Desktop\Stata Training\2.Intro_to_programming"
log using mylog.txt, text replace

/* you code here for instance : */
*this is an example
/*this is an example */
//this is an example  
sysuse auto, clear
graph twoway (scatter price weight) ///
(lfit price weight)

#delimit;                            // interesting
graph twoway (scatter price weight) 
(lfit price weight);
#delimit cr                          // closing it off

log close


***************************************
* Macro
***************************************
local list "weight mpg foreign"          // it only remembers it in one execuation 
regress price `list'                     // it will forget it after the execution is finished
regress price weight mpg foreign

local control "weight mpg"
regress price `control'
global controlg "weight mpg"             // to make stata remember the variable, use global
regress price $controlg                  
macro drop controlg                      // delete the global macro 

local controls "weight mpg trunk length turn"
regress price `controls'

local ifcond "if (rep78>2 & rep78~=.) | weight>2000"  
summarize price `ifcond'

* returned values
sysuse auto,clear
summarize mpg
return list
scalar range=r(max)-r(min)
display "sample range=" range
scalar mpgmean=r(mean)

*standardized values
sysuse auto,clear
sum price
return list
gen price2=(price-r(mean))/sqrt(r(Var))     // it is one column - the mean 
summarize price price2                      // new we can see the normalized price 

* ereturn
sysuse auto,clear
regress price mpg weight
ereturn list                        		// ereturn list returns estimation results

* calculate t statistics
matrix list e(b)                            // e(b) is the coefficient matrix
matrix B=e(b)                               // store e(b) into a matrix B
local weight =B[1,2]
display `weight'
matrix list e(V)                            // e(V) is the variance covariance matrix 
matrix V=e(V)                               // store variance into a matrix 
local vweight=sqrt(V[2,2])                  
disp `vweight'
local tweight=`weight'/`vweight'
disp `tweight'
display "t statistic for H0: b_weight=0 is `tweight'"

* Use Macro and Returned Values in Program
sysuse auto,clear
summarize weight, detail
return list
local 1=r(p5)             					// save the top 5 percent value
local 2=r(p95)								// save the 95 precent value
summarize price mpg if weight>`1' & weight<`2', detail

******************************
* loop
******************************

* loop for a number list
forvalues i=1(1)10 {
	display `i'
}

sysuse auto,clear
sum mpg
forvalues i=10(10)40 {
	local j=`i'+10
	gen mpg`i'to`j'=(mpg>=`i'& mpg<`j')
}

* create new variables
clear
set obs 100
foreach k of newlist var1-var4 {        	// foreach .. newlist -- the is syntax, you can not change newlist
	gen `k'=rnormal(5,100)
}
sum var1-var4

* work on existing variables
foreach x of varlist var1-var4 {			// foreach .. varlist -- it works on existing variables 
	quietly sum `x' 						// quietly sum --- run sum but do not report back to the console
	replace `x'=(`x'-r(mean))/sqrt(r(Var))
}
sum var1-var4

* loop over a local (list)
sysuse auto,clear
local xlist  price mpg headroom trunk weight length 	// check unab -- it can take a varlist and store it in local 
foreach z of local xlist {					// all this is the syntax 
	replace `z'=log(`z')
}

* levelsof
sysuse auto, clear
levelsof rep78, local(rep78_list) 			// take all the values of a variable to be elements of a local 
foreach i of local rep78_list {
	di "repair redord is `i'"
	sum price if rep78 == `i'
}
											// you can easily turn it to run contry by country regression

											
* Export Regression Results
sysuse auto,clear
regress mpg foreign weight headroom trunk length
outreg2 using myfile, replace excel			// create new files 
regress mpg foreign weight headroom
outreg2 using myfile, append excel			// append to the same file

// use help outreg2 to look at specific options 
