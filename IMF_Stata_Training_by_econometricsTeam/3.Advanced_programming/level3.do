**************************************************************
*1.	SCALARS AND MATRICES
**************************************************************

sysuse auto, clear

scalar min = 5000
scalar max = 10000
scalar list 							// list all your scalars
sum mpg if price > min & price < max	// use scalar to do some calculations
										// scalar drop min  -- use this to drop scalar


scalar root2 = sqrt(2) 					// store calculated results 
gen rootprice = price*root2				// scalar can only be used in a mathmatical operation
										// for instance scalar obs = 100
										// br var in 1/obs    - this will not work
scalar mpg = 20							
g var1 = price * mpg					// stata will give varaible higher priority, it will use variable first 
g var2 = price * 20
br var1 var2 price mpg					// do not name scalar the same name as you variable name

** working with matrix 
sysuse auto, clear
reg mpg foreign weight headroom trunk length
ereturn list
matrix beta = e(b) 						// save coefficient matrix 
matrix v = e(V)							// save covariance matrix 
mat vv1 = v["trunk", "weight"]			// save element as matrix 
mat vv2 = v[4,2]						// you can use location as well 

/*
mat dir             					// list all defined matrix 
mat list
mat rename 
mat drop 

mkmat 									// make matrix into variables 
svmat 									// create variable with matrix 
*/


// you can also use temprate variabels 
tempvar var1 							// temporary variable name 
gen `var1' = mpg^2
// use tempname to define temporary scalar or matrix 
tempname a1
scalar `a1' = 2 

//use tempfile to save temporary file 
tempfile myfile 						// create tempfile variable 
save `myfile'    						// save temporary file 



**************************************************************
*2.	LOCAL AND GLOBAL MACROS
**************************************************************

local x -2
di (`x')^2
di `x'^2								// stata treat local almost as string

local xx "Hello world from "Li""
di "`xx'" 								// this will give you an error 
local xx `"Hello world from "Li""'		// you nee `' to wrape around you string if you have """" in your srting
di `"`xx'"'

* Whether to Use an Equal Sign
* example 1
local problem 2+2       				// stata put 2+2 as srting 
local result = 2+2                		// stata calculate 2+2  if you have = before 
di "`problem'"
di "`result'"

* example 2
* Does not use an equal sign
local count 0
local country US UK DE FR
foreach c of local country {         	// loop with count 
 local count `count'+1                  // this only save the comman without evaluating it 
 display "Country `count' : `c'"
}
* Use an equal sign
local count 0
local country US UK DE FR
foreach c of local country {			// loop with count 
 local count = `count'+1				// use ==, it will evaluate the command 
 display "Country `count' : `c'"
}

* example 3
sysuse auto, clear
regress mpg weight
local rsqf e(r2)
local rsqv = e(r2)
di `rsqf'				//this has the current R-squared
di `rsqv'				//as does this
regress mpg weight foreign
di `rsqf'				//the new R-squared
di `rsqv'				//still the old one

* use in program
do myfile alpha						// so in myfile.do, we have display "'1',`2',`3'" , so we treate alpha as `1', the first artument
do myfile alpha beta gamma


**************************************************************
* 3.	LOOPING AND BRANCHING
foreach country in US UK DE and FR {
	di "`country'"
}

foreach name in "Annette Fett" "Ashley Poole" "Marsha Martinez" {
	display length("`name'") " characters long -- `name'"
}

foreach var of newlist z1- z20 {
	gen `var' = runiform()
}

foreach num of numlist 1 4/8 13(2)21 103 {
	di `num'
}

local money "Franc Dollar Lira Pound"
foreach y of local money {
	display "`y'"
}

forvalues i = 1(1)10 {
	display `i'
}

local i = 1
while `i' <= 10 {
	display `i'
	local i = `i'+1
}

*
webuse auto, clear
local N = _N							// _Nunber of observation 
forvalues i = 1(1)`N' {
  di "Obs. `i':" mpg[`i']   			// disply observation one by one
}

webuse auto
local N = _N
local i = 1
while `i' <= `N' {
  di "Obs. `i':" mpg[`i']
  local i = `i'+1
}

* Branching
sysuse auto, clear
regress price mpg weight
local r2 = e(r2)
regress price mpg gear_ratio
if  `r2' > e(r2) {
	display "Model 1 fits better"
}
else {
	display in red "Model 1 fits worse"
}


**************************************************************
* 4.	PROGRAM DEFINE
**************************************************************

* Programs with no Arguments
capture program drop hello					// if hello is already exist, drop it

program define hello						// define a function hello
	version 13.1
	display "Hello World"
end

hello										// run hello

* Programs with an Argument
capture program drop echo
program define echo
	version 13.1
	display "`0'"							// `0' stands for the first argument
end

echo Hello World
echo say "Hello World" again

capture program drop echo
program define echo
	version 13.1
	if `"`0'"' != "" display `" `0'"'
end

echo say "Hello World" again

* Programs with Positional Arguments
capture program drop echo
program define echo
	version 13.1
	while `"`1'"' != "" {
		display `"`1'"'						// `1' is the first argument, `0' means all arguments
		mac shift							// get the next vlaue , make `1' to be the next value 
	}
end

echo one two three testing
echo one "two and three" four


** example demean function 

capture program drop demean
program define demean
	foreach var of local 0{
		quietly summarize `var'
		replace `var' = `var' - r(mean)
	}

end

demean mpg price							// run the demean function on mpg and price


**************************************************************
* 5.	USEFUL COMMANDS
**************************************************************
sysuse auto
quietly regress mpg weight foreign headroom // quietly run the program 

pause on									// turn on pause 
sysuse auto,clear
regress mpg weight foreign headroom
pause Check OLS coefficient					// pause here, and you can do it interactively 
											// hit q to resume stata session
sleep 10000
regress mpg weight foreign headroom			

more

tokenize some words
di "1=|`1'|, 2=|`2'|, 3=|`3'|"
tokenize "some more words"
di "1=|`1'|, 2=|`2'|, 3=|`3'|, 4=|`4'|"
tokenize `""Marcello Pagano""Rino Bellocco""'		// using compound cotation to deal with complicated strings
di "1=|`1'|, 2=|`2'|, 3=|`3'|"

set trace on										// trace all the process 
local count 0
local country US UK DE FR
foreach c of local country {
 local count = `count'+1
 display "Country `count' : `c'"
}
set trace off


********************
**************************************************************
* 6.	EXAMPLES
* Example 1
	local mydata "ind emp wage cap indoutpt" 
	local nsets=wordcount("`mydata'") 
	tokenize `mydata' 
	use `1', clear									// use the first one, load it first 
	forval i = 2/`nsets' {    						// loop through start from 2 position
	 merge 1:1 id year using ``i'', nogen
	}

*************
* Example 2
*************
	use abdata1,clear
	tsset id year, yearly
	* create the estimate for sample without 1976
	xtreg n w k emp if year != 1976
	matrix b = e(b)
	* Grab the variance covariance matrix***
	matrix v = e(V)
	* Grab the diagonal elements and take square root, which results in * a standard error vector named s
	* s is in the same dimension as matrix b
	mat s1 = vecdiag(v)
	mat s2 = cholesky(diag(s1))
	mat s = vecdiag(s2)
	* The following does the same thing but in one line of command
	mat sone = vecdiag(cholesky(diag(vecdiag(v))))
	set more off
	forval t = 1977 / 1984 {
		xtreg n w k emp if year != `t'
		matrix b = b \ e(b)										// \ means append 
		mat s=s \ vecdiag(cholesky(diag(vecdiag(e(V)))))		// \ means append 
	}

	set more on

* list estimates for all sub-samples
matrix list b

* List estimates for all sub-samples
matrix list s

* Example 3
capture program drop demean
program demean
	foreach var of local 0 {
		summarize `var'
		replace `var' = `var'-r(mean) if `var' !=.
	}
end

sysuse auto, clear
sum mpg weight
demean mpg weight
sum mpg weight
