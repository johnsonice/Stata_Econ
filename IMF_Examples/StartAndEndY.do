sort Country Year
gen byte indicator = (Data!=.)
by Country: gen total_y = sum(indicator) if indicator != 0 
by Country: egen maxi = max(total_y)
gen start = 1 if total_y ==1
gen end = 1 if total_y == maxi
drop total_y maxi
