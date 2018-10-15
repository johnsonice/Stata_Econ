**************************************************************
** note this is just a code snipets for reference ************
** some code my not run as you don't have the data loaded ****
**************************************************************

*****************************
*** a usual stata templte ***
*****************************
cd "C:\Users\CHuang\Box Sync\IMF_Training_Courses\Stata\Lecture_1"
set more off 
capture log close  // close it first, in case the log file is already open
log using 0_basicdo, replace

	*************************************************
	*** basic command for loading packages and data**
	*************************************************
	* Basic commands for using and get data info
	sysuse uslifeexp
	describe
	summarize
	notes

	// average life expectancy, 1900-1949
	summarize le if year<1950

	// look at adopath, where stata will look for packages
	adopath
	
	// use ssc to download and install packages 
	//search mvsumm
	ssc install mvsumm
	ssc install bcuse  // bcuse if for downloading some specific data for this course
	
	// other ssc functions
	ssc new // newly listed stata packages
	ssc hot // most popular packages
	
	// user defined functions 
	
	program define say
		display "Stata says hello!"
	end
	//exit
	
	// now you type say, stata will print out 
	say
	// you can also put that in an ado file and put in ado path, then stata will load them in memeory
	// remember to put "exit" in the end 

	
	***********************************
	*** some other basic commands *****
	***********************************
	// list observations
	sysuse auto, clear
	sort price
	list make price in 1/5
	list make price in -5/l 			// list in reverse order 
	list make price if foreign == 1 	// list with criteria
	list make price if price > 10000 & !mi(price)	// note, stata treate missing as large number, need to be excluded
	
	
	//save and load file 
	compress 
	save 0_basic.dta, replace
	use 0_basic.dta,clear
	
	
	***********************************
	**** loops and macro **************
	***********************************
	sysuse auto
	sum price  
	return list   // summary statistics are listed as scalars 
	
	sum price,detail
	return list   // more detailed return list
	
	reg price mpg turn
	ereturn list // list estimation results
	matlist e(b)  // print out coefficient matrix
	matlist e(V)  // print out variance - covariance matrix
	
	// local macro
	local george 2 
	local paul = `george' + 2  // when use =, it will evaluate the operation right way
	display "`paul'"
	
	// forvalues
	forvalues i=1/10{
		display "`i'"  
	}
	
	// foreach  
	// loop through variables 
	sysuse lifeexp, clear
	foreach v of varlist popgrowth lexp gnppc {
		summarize `v', detail
	}
	
	// levels of 
	levelsof region, local(regid)
	foreach c of local regid{
		local rr: label region `c'                             // get the value label 
			regress lexp gnppc if region == `c'
			twoway (scatter lexp gnppc if region ==`c') ///
			(lfit lexp gnppc if region ==`c', ///
			ti(Region: `rr') name(fig`c', replace))
	}
	
	// another example
	sysuse lifeexp, clear
	levelsof region, local(regid)
	local alleps
	foreach c of local regid{
		regress lexp gnppc if region ==`c'
		predict double eps`c' if e(sample), residual
		local alleps "`alleps' eps`c'"     // generate a variable list with all new variables generated 
	}
	
	*************************
	** prefix ***************
	*************************
	// prefix command : by
	sysuse census, clear
	gen large = (pop > 5000000) if !mi(pop)
	bys region large: summ pop medage  // by sort, with multiple categories 

	
	// _n and _N will change under by 
		// the code block will not work here as we don't have the data 
		sysuse census, clear
		sort famid age
		by famid: generate famsize = _N   // number of obs with in that group
		by famid: generate birthorder = _N - _n + 1 
	
	
	
	// deal with missing data 
	// mvdecode mvencode to convert missing values that is represented in a different form
	
	
	// display format 
	format varname %9.2f  // %9.2f would display a two decimal place real number 
	format date %tm
	
	label variable varname "text"
	label define sexlbl 0 male 1 female  // define value labels 
	label values sex sexlbl
	
	***************************
	*** generate anre replace**
	***************************
	// generage 
	gen large = (pop > 5000000) if !mi(pop) // generage dummy 
	// generate multiple categories
	gen raceid = .
	replace raceid = 2 if race == "Black"
	replace raceid = 3 if race == "White"
	// inlist 
	gen byte newengland = ///
	inlist(state, "CT","ME","MA","NH","RI","VT")
	// inrange
	gen byte middleage = inrange(age,35,49) if ~mi(age)
	// integer division 
	gen ind2d = int(SIC/100) 	//only keep integer
	gen code34 = mod(SIC, 100) 	//mod
	
	// cond - it evaluates its first argument, and returns the second argument if true, and the thired if false
	gen endqtr = cond(mod(month,3)==0,"Filing month","Non-filing month") 
	
	// recode , irecode , replace 
	bcuse census2c, clear
	gen size = irecode(pop, 1000,4000,8000,20000)
	label define popsize 0 "<1m" 1 "1-4m" 2 "4-8m" 3 ">8m"  // defind value label 
	label values size popsize  								// assigin label
	tabstat pop, stat(mean min max) by(size)  				// print summary stats 
	
	// xtile - generate quantile labels
	bcuse census2c, clear
	xtile medagequart = medage, nq(4)     // generage medagequart with quantile labels 
	tabstat medage, stat(n mean min max) by(medagequart)
	
	
	// real(), destring(), tostring(), delimited(), encode(),   -- refer to lecture one for detailed example 
	encode state, gen(stid)  // encode string variable to numeric variable
	
	
	*********************
	** egen function ****
	*********************
	bcuse census2c, clear
	gen size = irecode(pop, 1000,4000,8000,20000)
	bysort size: egen avgpop = mean(pop) // generage grop mean by group 
	egen nrCensus = rowmean(pop*)  	// generate row-wise mean with certain varialbes 
									// egen has more functions like rowmin(), count, mean, total etc 
	
	// egen with userdifined function 
	egen newvar = zap(oldvar) // if zap() is defined in _gzap.ado file in stata ado PATH
	
	// egen - extended 
	ssc install egenmore // additional egen functions 
	
	
	
	
log close
translate 0_basicdo.smcl dofilename.pdf, replace

