
*generate two new variables to store variable name and labels
gen varlabel1 = ""
gen varlabel2 = ""

*loop through each variables and write the labels into new variables
local i = 1
 foreach v of varlist _all {
		local label : variable label `v'
		replace varlabel1 = "`v'" in `i'
		replace varlabel2 = "`label'" in `i'
        local ++i
 }
 
 *export the two variables 
 *change the file path here 
export delimited varlabel1 varlabel2 using "C:\Users\chuang\Desktop\Variables.csv", replace

*drop those two new variables 
drop varlabel1 varlabel2
 
 