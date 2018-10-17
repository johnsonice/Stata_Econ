clear
set more off
global cwd "Q:\DATA\AI\Chengyu Huang\DP State Contingent Financial Instruments\Alex\Step_3"
cd "$cwd"
quietly{
	do do/1_calBeta
	do do/1_1_calBeta_onecountry
	do do/2_regress
}
