********* PCA variables **********

**** PCA ****

*package name:  polychoric.pkg
*from:  http://staskolenikov.net/stata/
*search polychoric

net install polychoric.pkg

*use "Preprocessing/citizens.dta"

use "Preprocessing/citizens_subm.dta", clear

*** Re- arrange F111 type variables to prepare for elevation in profile level

order F111 F112 F113 F114 F115 F121 F122 F123 F124 F125 F211 F212 F213 F214 F215 F221 F222 F223 F224 F225 F311 F312 F313 F314 F315 F321 F322 F323 F324 F325 ResponseId F11 F12 F13 F14 F15 F21 F22 F23 F24 F25 F31 F32 F33 F34 F35

** Delete those who did not answer the conjoint
*(Note: the conjoint was forced, so each respondent either answered all 3 tasks or none)
drop if Q8_a_1==.



///// Polychoric PCA Ethnocentric values//// 

* Assign means to missing data
drop Q19_1_num
encode Q19_1, gen(Q19_1_num)
egen Q19_1_mean = mean(Q19_1_num)
replace Q19_1_num= Q19_1_mean if Q19_1=="99"

drop Q19_2_num
encode Q19_2, gen(Q19_2_num)
egen Q19_2_mean = mean(Q19_2_num)
replace Q19_2_num= Q19_2_mean if Q19_2=="99"

drop Q19_3_num
encode Q19_3, gen(Q19_3_num)
egen Q19_3_mean = mean(Q19_3_num)
replace Q19_3_num= Q19_3_mean if Q19_3=="99"

drop Q19_4_num
encode Q19_4, gen(Q19_4_num)
egen Q19_4_mean = mean(Q19_4_num)
replace Q19_4_num= Q19_4_mean if Q19_4=="99"


*
global x Q19_1_num Q19_2_num Q19_3_num Q19_4_num
polychoric $x
scalar x_N = r(N)
matrix x_r = r(R)
preserve 
collapse (mean) $x 
mkmat Q19_1_num Q19_2_num Q19_3_num Q19_4_num , matrix(x_mean) 
matrix list x_mean 
restore
preserve 
collapse (sd) $x 
mkmat Q19_1_num Q19_2_num Q19_3_num Q19_4_num , matrix(x_sd) 
matrix list x_sd 
restore
pcamat x_r, n(`=x_N') means(x_mean) sds(x_sd) factors(4)
predict pc1
screeplot, yline(1) title("Polychoric PCA: Ethnocentric values") xtitle("")
estat loadings
sum pc1
//normalising index to 10
gen ethnocentric_pca=((pc1-r(min))/(r(max)-r(min)))*10
label variable ethnocentric_pca "Polychoric PCA: Ethnocentric values"
drop pc1

///// Polychoric PCA Economic threat////

* Assign means to missing data
drop Q6_6_num
encode Q6_6, gen(Q6_6_num)
egen Q6_6_mean = mean(Q6_6_num)
replace Q6_6_num= Q6_6_mean if Q6_6=="99"

drop Q6_7_num
encode Q6_7, gen(Q6_7_num)
egen Q6_7_mean = mean(Q6_7_num)
replace Q6_7_num= Q6_7_mean if Q6_7=="99"

* 
global x Q6_6_num Q6_7_num
polychoric $x
scalar x_N = r(N)
matrix x_r = r(R)
preserve 
collapse (mean) $x 
mkmat Q6_6_num Q6_7_num, matrix(x_mean) 
matrix list x_mean 
restore
preserve 
collapse (sd) $x 
mkmat Q6_6_num Q6_7_num, matrix(x_sd) 
matrix list x_sd 
restore
pcamat x_r, n(`=x_N') means(x_mean) sds(x_sd) factors(2)
predict pc1
screeplot, yline(1) title("Polychoric PCA: Anti-refugee sentiments - economic") xtitle("")
estat loadings
sum pc1

//normalising index to 10
gen economic_threat=((pc1-r(min))/(r(max)-r(min)))*10
label variable economic_threat "Polychoric PCA: Anti-refugee sentiments - economic"
drop pc1

///// Polychoric PCA Sociocultural threat////

* Assign means to missing data
drop Q6_8_num
encode Q6_8, gen(Q6_8_num)
egen Q6_8_mean = mean(Q6_8_num)
replace Q6_8_num= Q6_8_mean if Q6_8=="99"

drop Q6_9_num
encode Q6_9, gen(Q6_9_num)
egen Q6_9_mean = mean(Q6_9_num)
replace Q6_9_num= Q6_9_mean if Q6_9=="99"

drop Q6_10_num
encode Q6_10, gen(Q6_10_num)
egen Q6_10_mean = mean(Q6_10_num)
replace Q6_10_num= Q6_10_mean if Q6_10=="99"

drop Q6_11_num
encode Q6_11, gen(Q6_11_num)
egen Q6_11_mean = mean(Q6_11_num)
replace Q6_11_num= Q6_11_mean if Q6_11=="99"

*
global x Q6_8_num Q6_9_num Q6_10_num Q6_11_num
polychoric $x
scalar x_N = r(N)
matrix x_r = r(R)
preserve 
collapse (mean) $x 
mkmat Q6_8_num Q6_9_num Q6_10_num Q6_11_num, matrix(x_mean) 
matrix list x_mean 
restore
preserve 
collapse (sd) $x 
mkmat Q6_8_num Q6_9_num Q6_10_num Q6_11_num, matrix(x_sd) 
matrix list x_sd 
restore
pcamat x_r, n(`=x_N') means(x_mean) sds(x_sd) factors(4)
predict pc1
screeplot, yline(1) title("Polychoric PCA: Anti-refugee sentiments - sociocultural") xtitle("") 
estat loadings
sum pc1
//normalising index to 10
gen cultural_threat=((pc1-r(min))/(r(max)-r(min)))*10
label variable cultural_threat "Polychoric PCA: Anti-refugee sentiments - sociocultural"
drop pc1


* Descriptive statistics table
sum ethnocentric_pca economic_threat cultural_threat

ssc install ebalance
************** Entropy balancing  *************

drop if  Q26_residence_1=="Do not know/ Do not answer"
drop if Q25_gender=="Άλλο" | Q25_gender=="Δε γνωρίζω/ Δεν απαντώ"

*periphery dummies**
generate Anatolikis=0
replace Anatolikis = 1 if Q26_residence_1=="Anatolikis Macedonias kai Thrakis"

generate Attikis=0
replace Attikis = 1 if Q26_residence_1=="Attikis"

generate Voreiou=0
replace Voreiou = 1 if Q26_residence_1=="Voreiou Aigaiou"

generate Elladas=0
replace Elladas = 1 if Q26_residence_1=="Dytikis Elladas"

generate Makedonias=0
replace Makedonias = 1 if Q26_residence_1=="Dytikis Makedonias"

generate Ipeirou=0
replace Ipeirou = 1 if Q26_residence_1=="Ipeirou"

generate Thessalias=0
replace Thessalias = 1 if Q26_residence_1=="Thessalias"

generate Ionion=0
replace Ionion = 1 if Q26_residence_1=="Ionion Nison"

generate Kentrikis=0
replace Kentrikis = 1 if Q26_residence_1=="Kentrikis Makedonias"

generate Kritis=0
replace Kritis = 1 if Q26_residence_1=="Kritis"

generate Notiou=0
replace Notiou = 1 if Q26_residence_1=="Notiou Aigaiou"

generate Peloponnisou=0
replace Peloponnisou = 1 if Q26_residence_1=="Peloponnisou"

generate Stereas=0
replace Stereas = 1 if Q26_residence_1=="Stereas Elladas"

***age-group dummies

gen age_group_new=.
replace age_group_new=1 if age==17 | age==18 | age==19 | age==20 | age==21 | age==22 | age==23 | age==24
replace age_group_new=2 if age==25 | age==26 | age==27 | age==28 | age==29 | age==30 | age==31 | age==32 | age==33 | age==34
replace age_group_new=3 if age==35 | age==36 | age==37 | age==38 | age==39 | age==40 | age==41 | age==42 | age==43 | age==44
replace age_group_new=4 if age==45 | age==46 | age==47 | age==48 | age==49 | age==50 | age==51 | age==52 | age==53 | age==54
replace age_group_new=5 if age>=55

tab age_group_new, gen(ages)


***** Based on gender, age, and peripheria *****
set seed 123456789

*entropy balance
ebalance female ages1 ages2 ages3 ages4 Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas, manualtargets(0.5097 0.096 0.173 0.184 0.165 0.0562 0.354 0.0184 0.0628 0.0262 0.0311 0.0677 0.0192 0.174 0.0286 0.0534 0.0506)

**Save balance table
ebalance female ages1 ages2 ages3 ages4 Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas, manualtargets(0.5097 0.096 0.173 0.184 0.165 0.0562 0.354 0.0184 0.0628 0.0262 0.0311 0.0677 0.0192 0.174 0.0286 0.0534 0.0506) k(baltable) rep

rename _webal webal

***** Based on gender, age, peripheria, and camp presence **********
set seed 123456789

*entropy balance
ebalance female ages1 ages2 ages3 ages4 Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas treat1, manualtargets(0.5097 0.096 0.173 0.184 0.165 0.0562 0.354 0.0184 0.0628 0.0262 0.0311 0.0677 0.0192 0.174 0.0286 0.0534 0.0506 0.1286)

**Save balance table
ebalance female ages1 ages2 ages3 ages4 Anatolikis Attikis Voreiou Elladas Makedonias Ipeirou Thessalias Ionion Kentrikis Notiou Peloponnisou Stereas treat1, manualtargets(0.5097 0.1286 0.096 0.173 0.184 0.165 0.0562 0.354 0.0184 0.0628 0.0262 0.0311 0.0677 0.0192 0.174 0.0286 0.0534 0.1286) k(baltable1) rep tol(0.06)

rename _webal webal1

*(We have 5,916 respondents)
save "Preprocessing/citizens_level.dta", replace


