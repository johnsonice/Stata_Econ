*** Observation numbering
import excel using "level 4.xlsx", sheet("countrydata2") firstrow clear
bys country: gen id=_n
by country: gen max_obs=_N

***********
***Assert**
***********

sysuse auto, clear
* The documentation says make and model 
* is a string and implies it is always defined:
assert make ~= ""
* documentation implies price is always defined.
assert price ~= . & price > 0
* similarly
assert mpg ~= . & mpg > 0
assert weight ~= . & weight > 0
assert displacement ~= . & displacement > 0
* false
assert foreign == 0


************************************
***Identify Duplicate Observations**
************************************

use dup,clear
order id year
sort id year
* a new var named dup is created, 
* which equals 0 if unique value
quietly by id year: gen dup = cond(_N == 1,0,_n)
tab dup
br if dup != 0
drop if dup > 1

use dup, clear
duplicates report id year
duplicates list
duplicates drop

**************************
***Handling Missing Data**
**************************

import excel using "level 4.xlsx", sheet("missing") firstrow clear
destring inc,replace force     										// if here is string, force it to replace it with missing
recode ln_inv (-9=.)

***************************************
***Summary Statistics to a New Dataset*
***************************************

sysuse auto,clear
collapse (p25) p25_m=mpg p25_price=price /// 						//collapse, ang generate new variables
 (first) f_wei=weight f_length=length, ///
 by(foreign)

*****************************************
***Summary Statistics as New Variables***
*****************************************

sysuse auto,clear
egen p15_price=pctile(price),p(15) 
egen kurt_price= kurt(price)
egen sum_price=total(price)
egen min_price=min(price)

*********************************
***Exporting Summary Statistics**
*********************************

//ssc install logout
logout, save(result) excel word replace: summarize
logout, save(result2) excel word replace: tabulate  foreign rep78

*******************************************
***In a List or Out? In a Range or Out?****
*******************************************

sysuse auto,clear
list make rep78 if rep78 == 3 | rep78 == 4 | ///
 rep78 == 5
list make rep78 if rep78 >= 3 & rep78 <= 5
list make rep78 if inlist(rep78, 3, 4, 5)   			// this is super useful
list make rep78 if inrange(rep78, 3, 5) 				// useful useful
*identify the first and last observation
gen price_se = price if inlist(_n, 1, _N)				// this will give you the first and last ovservation 


**********************************************************************
***String to Numeric Conversion, how to make string into number id ***
**********************************************************************

import excel "level 4.xlsx", sh("string") first clear 
* remove s in the beginning
gen id_temp= substr(id,2,.) 							// use substr from 2 position to the end of the string
gen subid=real(id_temp)									// real also change string to zeors 
encode name, generate(name2) 							// encode string to numbers 
list name2,nolab
* remove s in the end
gen id_temp2 = strreverse(id2) //then follow the steps above and reverse it back
* remove s
gen id_temp3 = subinstr(id2, "s", "", .)				// replace s with ""

***Numeric to String Conversion
import excel using "level 4.xlsx", sheet("numeric") firstrow clear
gen str4 id2 = string(id) 
gen str6 newid = country + id2							// id concaternation


**********************************
***How to Create Dummy Variables**
**********************************

sysuse auto,clear
*Answer 1
gen dummy=0
replace dummy=1 if price>4000 & !missing(price)
*Answer 2
tabulate rep78, gen(rep) 								// useful useful, useful ---- create dummy by rep78 categories
*Answer 3: if you want to include dummies in a model
xi: regress price mpg i.rep78							// regress it with dummy variables, i.  is include dummy with rep78 

********************************
***How to Include Year Effects**
********************************

clear
use http://www.statapress.com/data/r11/nlswork
xtreg ln_w  age tenure not_smsa south, fe				// time fixed effects 
xtreg ln_w  age tenure not_smsa south i.year, fe
testparm i.year											// test if year is jointly significant 

***************************************
***Reorganizing Datasets with Reshape**
***************************************

import excel using "level 4.xlsx", ///
 sheet("reshape") cellrange(A2:E5) firstrow ///
	clear
reshape long inc, i(id) j(year)
reshape wide inc, i(id) j(year)

***********************************************
*******************   Dates      **************
***********************************************

use dates, clear
gen edaily1 = date(daily1, "MDY")
gen edaily2 = date(daily2, "DMY")
gen edaily4 = date(daily4, "DMY", 2005)
gen equarterly = quarterly(qdate, "YQ")
gen emonthly = monthly(mdate, "MY", 2006)

format %td edaily1
format %tm emonthly
format %tq equarterly

use demo.dta, clear
gen qdate = quarterly(obs, "YQ")  				// change to quarterly number data    	
format %tq qdate
gen year = yofd(dofq(qdate))					// get year info from quarter date 
collapse (sum)gdp (mean)pr, by(year)			// then collapse to yearly data 

use demo.dta, clear
gen qdate = quarterly(obs, "YQ")
regress rs gdp m1 pr if qdate > 1955q1
regress rs gdp m1 pr if qdate > -20
regress rs gdp m1 pr if qdate > q(1955q1)

use dates, clear
gen edaily1 = date(daily1, "MDY")
format %td edaily1
* Extract year
gen year=year(edaily1)							// exract year it is the same as yofd
* Extract month
gen month = mofd(edaily1)						// change daily to monthly
format %tm month


*****************************
***Filling in the Gaps*******
*****************************

import excel using "level 4.xlsx", ///
	sheet("gaps") cellrange(A1:c93) firstrow clear
fillin country year										// will make the data to a balance pannel 
														// it is not trying to match with the calander

***Calculate Moving Window Summary Statistics
webuse lutkepohl2,clear
tsset qtr
//ssc install mvsumm
mvsumm inv, stat(mean) win(3) gen(M_inv) end			// moving window statistics 
mvsumm inv, stat(max) win(3) gen(Max_inv) end			// moving window statistics

***Identify Runs of Consecutive Observations in Panel Data
webuse nlswork,clear
tsset 
tsspell idcode
br idcode year _spell _seq _end


**************************************
***Making Regression Tables in Stata**
**************************************

sysuse auto,clear
eststo clear
eststo:regress price mpg weight
eststo:regress price mpg weight if foreign==1
esttab using regout.csv

sysuse auto,clear
tab rep78, gen(repair)
regress mpg foreign weight repair1-repair4
outreg2 using myfile, drop(repair*) replace excel
regress price mpg weight if foreign==1
outreg2 using myfile,excel

***Preserve and  Restore
sysuse auto,clear
preserve
collapse (p25) p25_m=mpg p25_price=price ///
 (first) f_wei=weight f_length=length, by(foreign)
save auto_stat, replace
restore


**********************************************
***Put multiple sheets in Excel into one******
**********************************************
clear
set more off
tempfile database
save `database', emptyok								// save database as empty temp file 

import excel "example_sheets.xlsx", describe
return list
local n_sheets `r(N_worksheet)'							// real all sheets name to local
forvalues j = 3/`n_sheets' {							// start from the third sheet to last 
    local sheet`j' `r(worksheet_`j')'					// define local with sheet[number] to be the sheet name
}


forvalues j = 3/`n_sheets' {
    import excel "example_sheets.xlsx", sheet(`"`sheet`j''"') firstrow cellra(B1) clear
	rename (G-BZ) `sheet`j''#, addnumber(1950)
	gen countrycode = real(substr(Series_code, 1, 3))
	reshape long `sheet`j'', i(countrycode) j(year)
	if `j'>3 {
	    merge 1:1 countrycode year using `database', nogen
		}
	save `database', replace
}
save mypanel, replace
