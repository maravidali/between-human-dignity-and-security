*** Councilors *** 

**
*ssc install ebalance, all replace
*ssc install outreg
*ssc install outreg2

import excel using  "Preprocessing/councilors_profiledata_withDV2_PCA.xlsx", firstrow clear

************** Entropy balancing based on Gender and Periferia *************
*** Q25_gender ***  Female=1 
drop female 
gen female=.
replace female=1 if Q25_gender=="Γυναίκα"
replace female=0 if Q25_gender=="Άντρας"
label define femalel 1"Female" 0"Male"
label values female femalel


*entropy balance
ebalance female Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas, manualtargets(0.1903 0.0678 0.2339 0.0278 0.0591 0.0377 0.049 0.0758 0.0267 0.1318 0.0686 0.0811 0.0743)

**Save balance table
ebalance female Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas Kritis, manualtargets(0.1903 0.0678 0.2339 0.0278 0.0591 0.0377 0.049 0.0758 0.0267 0.1318 0.0686 0.0811 0.0743) k(baltable) rep

rename _webal webal

************** Entropy balancing based on Gender, Periferia AND  Existing Camp *************

*entropy balance
ebalance female treat1 Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas, manualtargets(0.1903 0.1286 0.0678 0.2339 0.0278 0.0591 0.0377 0.049 0.0758 0.0267 0.1318 0.0686 0.0811 0.0743)

**Save balance table
ebalance female treat1 Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas Kritis, manualtargets(0.1903 0.1286 0.0678 0.2339 0.0278 0.0591 0.0377 0.049 0.0758 0.0267 0.1318 0.0686 0.0811 0.0743) k(baltable1) rep

rename _webal webal2

export excel using "Preprocessing/councilors_profiledata_withDV2_PCA_weight.xlsx", firstrow(variables)
