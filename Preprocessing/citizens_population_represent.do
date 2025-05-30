import excel "Preprocessing/citizens_population.xlsx", sheet("Sheet1") firstrow
drop Q26_residence_2
rename municipality Q26_residence_2
saveold "Preprocessing/citizens_population_representative.dta", version(13)
