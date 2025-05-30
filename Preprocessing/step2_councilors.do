*****Greece Councilors Conjoint *****

import excel using  "Preprocessing/councilors_profiledata.xlsx", firstrow


sort ResponseId

by ResponseId: gen profilecount=_n

sum ResponseId profilecount



destring Q8_a_1 Q8_a_4 Q9_a_1 Q9_a_2 Q10_a_1 Q10_a_2 task_number profile_number profilecount, replace force

gen dv_scale=.
replace dv_scale=Q8_a_1 if (task_number==1 & profile_number==1 & profilecount>=1)
replace dv_scale=Q8_a_4 if (task_number==1 & profile_number==2 & profilecount>=1)

replace dv_scale=Q9_a_1 if (task_number==2 & profile_number==1 & profilecount>=1)
replace dv_scale=Q9_a_2 if (task_number==2 & profile_number==2 & profilecount>=1)

replace dv_scale=Q10_a_1 if (task_number==3 & profile_number==1 & profilecount>=1)
replace dv_scale=Q10_a_2 if (task_number==3 & profile_number==2 & profilecount>=1)


tab dv_scale, m


* rescale the 7 point scale to 0-1

gen dv_scale2=(dv_scale-1)/6
tab dv_scale2, m


gen dv_scale22=(dv_scale-0)/7
tab dv_scale22, m

* rename binary***
replace Q8_b = "A" if Q8_b=="Την Πρόταση A"
replace Q8_b = "B" if Q8_b== "Την Πρόταση B"
replace Q9_b = "A" if Q9_b=="Την Πρόταση Α"
replace Q9_b = "B" if Q9_b== "Την Πρόταση B"
replace Q10_b = "A" if Q10_a_1 >= Q10_a_2
replace Q10_b = "B" if Q10_a_2 > Q10_a_1


***binary***

gen dv_binary=.
replace dv_binary=1 if (Q8_b=="A" & task_number==1 & profile_number==1 & profilecount>=1)
replace dv_binary=0 if (Q8_b=="B" & task_number==1 & profile_number==1 & profilecount>=1)
replace dv_binary=1 if (Q8_b=="B" & task_number==1 & profile_number==2 & profilecount>=1)
replace dv_binary=0 if (Q8_b=="A" & task_number==1 & profile_number==2 & profilecount>=1)

replace dv_binary=1 if Q9_b=="A" & task_number==2 & profile_number==1 & profilecount>=1
replace dv_binary=0 if Q9_b=="B" & task_number==2 & profile_number==1 & profilecount>=1
replace dv_binary=1 if Q9_b=="B" & task_number==2 & profile_number==2 & profilecount>=1
replace dv_binary=0 if Q9_b=="A" & task_number==2 & profile_number==2 & profilecount>=1

replace dv_binary=1 if Q10_b=="A" & task_number==3 & profile_number==1 & profilecount>=1
replace dv_binary=0 if Q10_b=="B" & task_number==3 & profile_number==1 & profilecount>=1
replace dv_binary=1 if Q10_b=="B" & task_number==3 & profile_number==2 & profilecount>=1
replace dv_binary=0 if Q10_b=="A" & task_number==3 & profile_number==2 & profilecount>=1

tab dv_binary, m

export excel using  "Preprocessing/councilors_profiledata_withDV2.xlsx", firstrow(variables)
