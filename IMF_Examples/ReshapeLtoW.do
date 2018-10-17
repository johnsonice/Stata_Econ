use "C:\Users\chuang\Desktop\data_final_fin_parent.dta"
tostring year month,replace
gen newdate = year + "m" + month
order newdate, before( issuance_equity)
drop year month date
*drop iso3- em_region
drop fx-reg_ngdpd


reshape wide issuance_equity- month2, i(newdate iso3 ctry_name ctry_group em_region ) j(ifs)
