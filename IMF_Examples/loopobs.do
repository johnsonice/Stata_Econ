
egen double maxval= rowmax(YDGDP_A2EPV-YDGDP_B6EPV)
by Country Issuance_Date: egen double dummy = max(maxval)
gen double dummy2 = dummy if maxval == dummy
drop dummy maxval
drop if dummy2 ==.

gen testing = ""

local nn = _N
 forval i = 1/`nn' { 
 di `i'

	foreach ii of varlist  YDGDP_A2EPV - YDGDP_B6EPV{
		replace testing = "`ii'" if `ii' == dummy2 
	}
 }


 save merge.dta,replace
 