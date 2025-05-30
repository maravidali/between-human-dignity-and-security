* Combine citizens and councilors datasets

use "Preprocessing/councilors_full.dta"
gen councilor=1
* To correct wrong labels:
*label define Q10_c_num  5 "A lot", modify

merge 1:1 Q1 using "Preprocessing/citizens_subm.dta"

replace councilor=0 if councilor==.

gen right=0
replace right=1 if pol_or>=5
label define rightl 1"Right-voter" 0"Left-voter" 
label values right rightl


* Q6_1 children_edu2
gen children_edu2=.
replace children_edu2=1 if children_edu==5
replace children_edu2=2 if children_edu==4
replace children_edu2=3 if children_edu==3
replace children_edu2=4 if children_edu==2
replace children_edu2=5 if children_edu==1


* Q6_2 same_hospital2 
gen same_hospital2=.
replace same_hospital2=1 if same_hospital==5
replace same_hospital2=2 if same_hospital==4
replace same_hospital2=3 if same_hospital==3
replace same_hospital2=4 if same_hospital==2
replace same_hospital2=5 if same_hospital==1

save "Preprocessing/CPS_combined.dta"
