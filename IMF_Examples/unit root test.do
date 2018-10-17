//local vars ln_Export ln_RelPrice ln_CapStock ln_LabProd ln_RealWage ln_RDind ln_RdProv  ln_ProvTrade /*
//*/ln_VocTrain ln_FDI ln_GI GIratio FemPart Mratio Skills EnergyShare CorpTax ln_CorpTax Migrant PopDens Unemp BenefitsAcc Unions

local vars ln_Export ln_RelPrice
local counter=1
local i
gen result = .
gen vname = ""


foreach i in `vars' {
	*local label : variable label `i'
	
	xtunitroot llc `i'
	replace vname = "`i'" in `counter' 
	replace result = r(p_tds) in `counter' 
	
	local ++counter
}

/*outreg2 using "unitroottest.xlsx"

foreach i in `vars' {
	xtunitroot llc `i', trend
}

outreg2 using "unitroottest2.xlsx"*/

*export that two variable 
export delimited vname result using "C:\Users\chuang\Desktop\Variables.csv", replace
