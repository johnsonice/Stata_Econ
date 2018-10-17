************************
*Stata start up day one*
************************ 

**Section One ***

	**Do file hearder, set some option	
	// set more off for this machine 
		version 14.1
		set more off, perm 
		clear 
		capture log close skeleton
		log using skeleton, name(skeleton) replace
			***code here ****
		close log skeleton // close log in the end 
		
	// start a log file
		log using "C:\Users\microtek\Desktop\stata_startup\Dayone.log"
	// stata missing values . .a-.z

	// describe and summrize data 
		describe 
		su
	// basic generate and charts 
		gen gp100m = 100/mpg
		hist gp100m
		save autoxta, replace
			//can use use " and tab to auto complete
		use "autoxta.dta"
			***page up and page done can give your previous command
	// use db to open dialoge box
		db codebook // will open up codebook dialogue
	//close log
		log close 
	//re start the log 
		log using "Dayone.log", append

**Section Two** Syntax***
	
	// ,full  : use full variable name eventhough it is long 
	// use * to be more efficient 
		describe pop* // describe all variable start iwth pop
		describe *g*
		summarize pop - popurban
		summarize _all
	
	// use if and in , if is based on value, in is based on obs
		sort pop
		list state pop in 1/5
		list state pop in -8/-1
		
		gsort -pop // reverse sort by population
		list state pop in 1/5
		
		summarize medage, detail //detailed summary
		list state medage if medage < 27
	
	// operators  and:& or: | Not:!
		list state medage if 30<= medage & medage < 32
		*inrange function will do the same thing
		list state if ustrpos(state, " ")>0 //use string position function
		
	//weights 
		gen dth_per_1000 = 1000*death/pop // generate death rate 
		scatter dth_per_1000 medage,mlabel(state2)|| lfit dth_per_1000 medage
		su dth_per_1000 [aw=pop] // weighted by population 
		// use bys prefix, by and sort 
		bys region: summarize dth_per_1000 [aw = pop]
	
	// get other packages 
		net install smcl2do // get smcl2do -- convert log file to do file
	
*Section Three ** Getting Data****

	//get data from internet 
		net from "http://www.stata.com/training/08mar2016"
		net get gettingdata
		global F5 net from "http://www.stata.com/training/08mar2016" //asign F5 as a short cut for macro
		use "mlb2014.dta" //get data
		* uae adopath to see the environment path for Stata
		adopath 
		
	//get excel data 
		import excel using "apt_search.xlsx", firstrow case(lower)
		save "apt_search"
		
*Section Three ** Data to Dataset ****
	
	//add notes to the dataset 
		note: TS start working
		note: There are fake data
		note: For help, call 411-234-9583
		label data "Fake apartment search data"
	// add value label to categorical veriable 
		label define whereat 1 "City" 2 "Suburb" 3 "Exurbs" 4 "Countryside", replace
		label values apartmentid whereat
	// encode string variables, make string and encode it to values
		encode exterior, gen(exterior_new) 
		order exterior_new, before(exterior)
		
		replace quality = ustrlower(quality) //transform to lower case
		label def qual 0 "poor" 1 "good" 2 "perfect" // encode quality
		encode quality, gen(quality_new) label(qual)
		order quality_new , befor(quality)
		
	// use recode *****
		recode pets_new(.= 0) // replace missing value to 0 
			// can also use replace pets_new = 0 if pets_new == . or some other logic
	
	//transform date from string to stata date
		gen available_new = date(available, "MDY"),before(available) // this ,before is available in stata14
		label variable available_new "date available" // add label to it 
		format %td available_new //formate date
		list available if missing(available_new) // check errors, why thing could be missing
		***use assert ***
			assert missing(available) == missing(available_new) // check if this statement is true, if true return nothing 
		// destring string to numerica
			destring rent, gen(rent_new) ignore("$,") // ignore some characters 
		// to string 
			tostring zipcode, gen(zipcode_new) format(%05.0f) // formated to be 5 digits with leading 0
		// rename group 
			rename *_new * // get ride of all variable with _new
		// compress data 
			compress

**Section Four ** minipulate data ***
	
	//check if it is id, clean up observations
		isid aptid // check if is unique
		duplicates report aptid  //check if is unique
		duplicates list aptid // see duplicates
		duplicates tag aptid, gen(dupid) // mark duplicates 
		list aptid if dupid
		list aptid exterior zipcode if dupid, nolabel
		replace aptid = 1071 if aptid ==107 & exterior ==3 & zipcode =="03593" // change the duplicates
		
		assert rent>=0 // check if rent are all gt 0
		assert quality < 2 if pets==0 // check this as well
		gen qualityerror = (quality ==2 & pets ==0) // generate error indicator
		replace quality = 1 if qualityerror // fix the error 
	  *****data validattion too -------- ckvar package
	  
	// make continous variable into categorical, with value label 
		recode rent ///
		  (1300/max=4 "$1300 and above") ///
		  (1000/1300=3 "$1000 to under $1300") ///
		  (800/1000=2 "$800 to under $1000") ///
		  (min/800=1 "under $800") ///
		  , gen(rentgrp)

		list rent rentgrp, sepby(rentgrp) // list it 
		xtile rentquart = rent, n(4) // make it into 4 quartiles 
		
	// working with missing values 
		gen repgood = rep78>=4 if !missing(rep78)
	// comparing numbers 
		list make gear_ratio if float(gear_ratio) == float(2.93)
	
	
************************
*Stata start up day two*
************************

	**Section Five ** combine data and reshape data***
		//append
			append using "old_visit_info.dta" "new_visit_info.dta",gen(whichfile)
		*********************************************
		**how to get a list of files in a directory *
		*********************************************
			local theFiles : dir . files "*visit_info.dta" // put all into a local macro
			macro list _theFiles
			append using `theFiles', gen(fancyappend)
		//merge
			merge m:1 patid using "patient_info.dta"

		//reshape
			reshape long visitdt wt, i(id) j(visitnum) //shape to long 
			reshape wide visitdt wt, i(id) j(visitnum) // shape to wide
			****generate sequence id*****
			bys id (visitdt): gen visitnum = _n  // gen sequence by persion id
			***when get error while reshaping
			reshape error // list the problems with reshape
		//*******************
		******egen function**
		********************* 
			egen meanwt_wide = rowmean(wt*) // calculate rowmean of all var prefixed with wt
			bys id: egen meanwt_long= mean(wt) // calculate group mean
	
	**Section Six ** summary and store ***
	
		// tabulate data
			tab race low,row
			tab race low,row chi2 exact //fisher test 
			tab race, summarize(bwt) // tab with summary info
			tab race smoke , summarize(bwt) 
		// use table command
			table race smoke, contents(mean bwt sd bwt count bwt)
		// use return list * there r-class, e-class , c - class 
			return list 
			di r(mean)/453.6 // use the value to display som ething
			
		******
		**use statsby and saving 
		******
			statsby, by(race smoke) saving(alltabdata): summarize bwt // save tabe into dts
			export excel using "alltabdata.xls", firstrow(variables) // exoprt dta to excel
		**** statsby work better then collapse
			tabstat bwt age lwt, statistics( p25 p50 p75 ) save
			matlist r(StatTotal)'
			// now, how you dump matrix to excel 
			putexcel set tabstat.xls
			putexcel A1 = matrix(r(StatTotal)'),names // dump the matrix to excel
			putexcel A1:D1, bold hcenter // you can formate the excel as well 
			putexcel clear // close the connection 
	
	******Section Seven Basic statistics*********
		
		// confident intervals 
			ci proportions low smoke, level(95) //95 ci
			ci means bwt lwt age, level(90)
		//ttest
			ttest smoke = 2944 // test mean = to 2944
			ttest bwt, by(smoke) // t test for means between smoker and non-smokers
			sdtest bwt, by(smoke) // tset for variances 
		//eccective size 
			esize twosample bwt, by(smoke) // measure by standard deviation
		//corrolation 
			pwcorr bwt age lwt, sig star(0.05) // add significant level and *s 
			spearman bwt age lwt, stats(rho p) star(0.05) // for ranked variables 
			// see it in graph 
			graph matrix bwt age lwt
	
	******Section Eight ***statistics estimation*********
	
		//load data lbw
			webuse lbw
		//ols regressions 
			reg bwt lwt ui smoke
			bys race: regress bwt lwt ui smoke // run ols by race groups, it will run multiple regression
		//logit model 
			logit low lwt ui smoke
			*coefficient is explained by probility changed
			logit low lwt ui smoke,or // give your ods ratios
		// categorical independent variable 
			regress bwt lwt i.ui i.smoke i.race, base  // ,base, show base value
				*you can also set the base level on 
				set showbaselevels on, permanently
			//i. as operator
			regress bwt lwt i.(ui smoke race), base // you can also write this way 
			// change base reference, use the most commonly occuring value as the base value
			regress bwt lwt b(freq).(ui smoke race), base
		
		**// interations *** use ##
				reg bwt lwt i.ui smoke##race, base // when in interaction, variable are assumed to be categorical
				reg bwt c.age##c.age lwt i.ui i.smoke i.race, base // interact continous variables 
			// with robust option
				regress bwt lwt i.ui i.smoke i.race, base vce(robust)
			//jackknife 
				regress bwt lwt i.ui i.smoke i.race, base vce(jackknife)
			//bootstrap 
				sort id
				set seed 142857
				regress bwt lwt i.ui i.smoke i.race, vce(bootstrap,reps(100)) // let it run 100 times 
					// you can try bootstrap prefix if you want to access point estimates of bootstrap 
			
			//test coefficient, after regression 
				test 2.race == 3.race // wald test 
				test (2.race == 3.race) (lwt ==0) // compound test 
				// test interaction 
				reg bwt lwt (smoke ui)#race
				testparm ui#race // test interaction quickly 
			
			// likelihood-Ratio Test
				regress bwt age lwt i.ui i.smoke i.race, base // run first model 
				estimates store bwt_alusr // save estimation 
				regress bwt lwt i.ui i.smoke i.race if _est_bwt_alusr // run second model 
				estimates store bwt_usr  //save estimation 
				lrtest bwt_alusr bwt_usr // run the LR test 
				lrtest bwt_alusr bwt_usr,stat  //run LR test
			********************
			****estimates ******
			********************
				est table bwt* // show previous stored estimates in a table
				ereturn list 
				regress, coeflegend // show coefficient matrix and name 
				display _b[lwt]
		
				// post estimation 
				regress bwt c.age##c.age lwt i.ui i.smoke i.race, base
				estimate store qage // sotre estimates 
				lincom 2.race - 3.race // post estimate, linear estimate 
				nlcom -_b[age]/(2*_b[c.age#c.age]) // non linear estimation 
				
				//predit after regression 
				predict bwthat // use model to predict y hat 
				list bwt* in 101/110 // see the difference 
				
				****
				//Predictive Margins
				****
				
				margins, at (age=27)
				margins, at (age = (15(5)45)) // start from 15, increment by 5
				marginsplot // show it in plot 
				marginsplot, noci // no confident interval 
				
				//marginal effect 
				margins, at (age=(20(5)40)) dydx(age lwt) //show marginal effects 
				margins, at (age=(20(5)40)) eyex(age) // electicity, it is propotional change rather than value change 
				
	******Section Nigh ***   Graphics   *********
		
		//basic charts 
			// histgram 
				hist bwt
			// hist with more specifications
				histogram bwt, kdensity yscale(off) title(Birth Rate) caption({bf:Data source}: .......) ///
				note(Testing)
			// you can change scheme as well 
				histogram bwt, kdensity yscale(off) title(Birth Rate) caption({bf:Data source}: .......) ///
				note(Testing) scheme(economist)
			// combine tow charts by certain variable 
				histogram bwt, ytitle("") by(, title(Birth Rate) caption({bf:Data source}: .......) /// 
				note(Testing)) scheme(economist) xsize(7) ysize(8) by(smoke, cols(1) ///
				noiyaxes noiytick noiylabel noiytitle)
			*** useful stata chart schemes ***
				help lean2
			// twoway araph 
				twoway (scatter bwt age) ///
				(scatter bwt age if bwt<1250 | age>40, msymbol(none) mlabel(id)), ///
				title("Marked extreme values") legend(off) // only mark outliers 
	
	********************************************
	******Section Ten ***   Do files   *********	
	********************************************
		// start a new do project 
			projman dolesson	
		// offset data
			set obs 8
			set seed 948924 // start point of random number generator
			gen  visitdt = 20000 + floor(runiform()*150) // get a random intiger
			format visitdt %td
			sor visitdt
			gen datedif = visitdt - visitdt[_n-1] // calculate the difference of the date
			
	
	
