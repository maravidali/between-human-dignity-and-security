*****Citizens Conjoint 30.07.21*****


import excel "Preprocessing/citizens_profile_without_outcome.xlsx", sheet("Sheet 1") firstrow clear


sort ResponseId

destring Q8_a_1 Q8_a_4 Q9_a_1 Q9_a_2 Q10_a_1 Q10_a_2 task_number profile_number, replace force

gen dv_scale=.
replace dv_scale=Q8_a_1 if (task_number==1 & profile_number==1)
replace dv_scale=Q8_a_4 if (task_number==1 & profile_number==2)

replace dv_scale=Q9_a_1 if (task_number==2 & profile_number==1)
replace dv_scale=Q9_a_2 if (task_number==2 & profile_number==2)

replace dv_scale=Q10_a_1 if (task_number==3 & profile_number==1)
replace dv_scale=Q10_a_2 if (task_number==3 & profile_number==2)


tab dv_scale, m


* rescale the 0-7 point scale to 0-1

gen dv_scale2=(dv_scale-0)/7
tab dv_scale2, m

* rename binary***

replace Q8_b  = "A" if Q8_b=="Τον Υποψήφιο που στηρίζει την Πρόταση A"

replace Q8_b  = "B" if Q8_b=="Τον Υποψήφιο που στηρίζει την Πρόταση B"

replace Q9_b  = "A" if Q9_b== "Τον Υποψηφιο που στηρίζει την Πρόταση Α"
replace Q9_b  = "B" if Q9_b=="Τον Υποψηφιο που στηρίζει την Πρόταση B"
replace Q10_b = "A" if Q10_b =="Τον Υποψήφιο που στηρίζει την Πρόταση Α"
replace Q10_b = "B" if Q10_b =="Τον Υποψήφιο που στηρίζει την Πρόταση Β"


***binary***

gen dv_binary=.
replace dv_binary=1 if (Q8_b=="A" & task_number==1 & profile_number==1)
replace dv_binary=0 if (Q8_b=="B" & task_number==1 & profile_number==1)
replace dv_binary=1 if (Q8_b=="B" & task_number==1 & profile_number==2)
replace dv_binary=0 if (Q8_b=="A" & task_number==1 & profile_number==2)

replace dv_binary=1 if Q9_b=="A" & task_number==2 & profile_number==1
replace dv_binary=0 if Q9_b=="B" & task_number==2 & profile_number==1
replace dv_binary=1 if Q9_b=="B" & task_number==2 & profile_number==2
replace dv_binary=0 if Q9_b=="A" & task_number==2 & profile_number==2

replace dv_binary=1 if Q10_b=="A" & task_number==3 & profile_number==1
replace dv_binary=0 if Q10_b=="B" & task_number==3 & profile_number==1
replace dv_binary=1 if Q10_b=="B" & task_number==3 & profile_number==2
replace dv_binary=0 if Q10_b=="A" & task_number==3 & profile_number==2

tab dv_binary, m

*save "Preprocessing/citizens_profile.dta"

drop if dv_binary==.

export excel using "Preprocessing/citizens_profile_no_missing_data_analysis.xlsx", , firstrow(variables)
