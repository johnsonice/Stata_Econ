/* how to deal with duplicates*/

	duplicates report
	duplicates report country IFSCode quarter // duplicates in terms of these variables 
	duplicates list country IFSCode quarter, sepby(country) // list duplicates
	duplicates tag country IFSCode quarter, gen(dup_id)
	order dup_id, before( oecd )
	duplicates drop country IFSCode quarter, force // only keep the firt occurance when there is a duplicate
