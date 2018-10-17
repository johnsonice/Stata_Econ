clear
import excel "C:\Temp\\LAC - FI.xlsx", sheet("Sheet1") firstrow
reshape long y, i(Country CountryCode CountryISO3code Indicator IndicatorName IndicatorUnit Frequency Scale) j(year)
reshape wide y, i(Country CountryCode CountryISO3code IndicatorName IndicatorUnit Frequency Scale year) j(Indicator) string
export excel using "C:\Temp\Testing.xlsx", sheetreplace firstrow(variables)
