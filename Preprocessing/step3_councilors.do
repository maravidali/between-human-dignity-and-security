*****Greece Councilors Conjoint *****

import excel using  "Preprocessing/councilors_profiledata_withDV2.xlsx", firstrow clear


*package name:  polychoric.pkg
*from:  http://staskolenikov.net/stata/
*search polychoric

**** PCA ****

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

export excel using "Preprocessing/councilors_profiledata_withDV2_PCA.xlsx", firstrow(variables)
