cd "Q:\DATA\AM\Yevgeniya\GFF"
set more off
use constructed\CPIS_stataready.dta, clear

keep country code counterpartcountry counterpart_code year I_A_D_T_T_BP6_USD ///
I_A_E_T_T_BP6_USD I_A_T_T_T_BP6_USD I_L_D_T_T_BP6_DV_USD I_L_D_T_T_BP6_USD ///
I_L_E_T_T_BP6_DV_USD I_L_E_T_T_BP6_USD I_L_T_T_T_BP6_DV_USD I_L_T_T_T_BP6_USD

cd "constructed\Graphs\CPIS"

local countrylist `""United States" "United Kingdom" "Japan" "Switzerland" "Europe" "Singapore" "China, P.R.: Hong Kong" "China, P.R.: Mainland""'
local idlist "111 112 158 146 170 576 532 924"

local n: word count `countrylist'
forvalues i = 1/`n'{
	local cn1:word `i' of `countrylist'
	local c1:word `i' of `idlist'
	
	forvalues i = 1/`n'{
		local cn2:word `i' of `countrylist'
		local c2:word `i' of `idlist'
		
		if "`c1'"~="`c2'" {    
			line I_A_T_T_T_BP6_USD year if code==`c1' & counterpart_code == `c2', yaxis(1) yscale(range(0) axis(1)) || ///
			line I_L_T_T_T_BP6_USD year if code==`c2' & counterpart_code == `c1', yaxis(1) ///
			legend(label(1 "Asset, Total Investment `cn1' to `cn2'") label(2 "Liabilities, Total Investment `cn2' to `cn1'") c(1) rowgap(zero) size(vsmall) margin(tiny) region(margin(zero) lcolor(none))) ///
			ylabel(#10,axis(1) labsize(vsmall) format(%1.0e) angle(horizontal))  ///
			title("Comparison between `cn1' & `cn2'" , size(small)) ytitle("USD", size(small)) xtitle("Year",size(vsmall)) ///
			saving("Portfolio_investment_`c1'_to_`c2'",replace)
		}
	}
}

foreach c1 of local idlist {          
   foreach c2 of local idlist {       
		if "`c1'"~="`c2'" {   
			graph combine Portfolio_investment_`c1'_to_`c2'.gph 
			graph export "graph_`c1'_`c2'.png", replace
		}
   }
}



** Noets, if you take a look at the summary of the data, only about 10% of countries have liability data, only 50% countries has asset data. 
** asset and liabilities, the patten matched up ok, the absolute value for some countries are relatively consistent, for other countries, it can be very off. 

