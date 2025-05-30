* Exposure descriptive questions

use "Preprocessing/citizens_level.dta" 

* We merge with information from compensation ΦΕΚ (FEK). 
* Variable Imm_Pop shows the immigrant population(ΦΕΚ)/municipality population * 1000
merge m:m Q26_residence_2 using "Preprocessing/immigr_compens.dta"

*save "Preprocessing/citizen_level_immigr_compens.dta"

*clear

*u "Preprocessing/citizen_level_immigr_compens.dta"


replace Imm_Pop=0 if Imm_Pop==.

* exp=1 if the municipality is exposed according to ΦΕΚ
gen exp=0
replace exp=1 if Imm_Pop>0

drop intensity

* intensity_exp=1 if there's 0 immigrants, 1 if below median, 2 if above median according to ΦΕΚ
gen intensity_exp=1
replace intensity_exp=2 if Imm_Pop>0
replace intensity_exp=3 if Imm_Pop>14.658

* exp2=1 if the municipality has a RIC, and 0 otherwise
gen exp2=0
replace exp2=1 if Q26_residence_2=="Mytilinis"
replace exp2=1 if Q26_residence_2=="Anatolikis Samou"
replace exp2=1 if Q26_residence_2=="Lerou"
replace exp2=1 if Q26_residence_2=="Chiou"
replace exp2=1 if Q26_residence_2=="Ko"
replace exp2=1 if Q26_residence_2=="Orestiadas"


* intensity_exp2=1 if there's 0 immigrants, 1 if there's a camp according to ΦΕΚ (but it's not a RIC), 2 if there's a RIC
gen intensity_exp2=1
replace intensity_exp2=2 if exp==1
replace intensity_exp2=3 if exp2==1

* support_camp: 5 is very willing

hist support_camp, percent xla(1, valuelabel noticks) by (exp, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")
hist support_camp, percent xla(1, valuelabel noticks) by (exp2, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")
hist support_camp, percent xla(1, valuelabel noticks) by (intensity_exp, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")
hist support_camp, percent xla(1, valuelabel noticks) by (intensity_exp2, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")

* allow: 4 is allow many

hist allow, percent xla(1, valuelabel noticks) by (exp, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")
hist allow, percent xla(1, valuelabel noticks) by (exp2, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")
hist allow, percent xla(1, valuelabel noticks) by (intensity_exp, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")
hist allow, percent xla(1, valuelabel noticks) by (intensity_exp2, note("Citizens")) xtitle ("Ηow willing would you be to support camp in yr municipality, by exposure (ΦΕΚ)")


**** Congruence exposure graphs

tab Q3_num
gen right=0
replace right=1 if pol_or>=5
tab Q3_num right
label define rightl 1"Right-voter" 0"Left-voter" 
label values right rightl

* Q6_1 children_edu
gen children_edu2=.
replace children_edu2=1 if children_edu==5
replace children_edu2=2 if children_edu==4
replace children_edu2=3 if children_edu==3
replace children_edu2=4 if children_edu==2
replace children_edu2=5 if children_edu==1

gen children_edu2_no=children_edu2 if intensity_exp2==1
gen children_edu2_low=children_edu2 if intensity_exp2==2
gen children_edu2_high=children_edu2 if intensity_exp2==3

sum children_edu2_no if right==1
sum children_edu2_no if right==0
sum children_edu2_low if right==1
sum children_edu2_low if right==0
sum children_edu2_high if right==1
sum children_edu2_high if right==0

sum children_edu2_no
sum children_edu2_low
sum children_edu2_high

* Q6_2 same_hospital 
gen same_hospital2=.
replace same_hospital2=1 if same_hospital==5
replace same_hospital2=2 if same_hospital==4
replace same_hospital2=3 if same_hospital==3
replace same_hospital2=4 if same_hospital==2
replace same_hospital2=5 if same_hospital==1

gen same_hospital2_no=same_hospital2 if intensity_exp2==1
gen same_hospital2_low=same_hospital2 if intensity_exp2==2
gen same_hospital2_high=same_hospital2 if intensity_exp2==3

sum same_hospital2_no if right==1
sum same_hospital2_no if right==0
sum same_hospital2_low if right==1
sum same_hospital2_low if right==0
sum same_hospital2_high if right==1
sum same_hospital2_high if right==0

sum same_hospital2_no
sum same_hospital2_low
sum same_hospital2_high

* Q6_3 riot_threat 
gen riot_threat_no=riot_threat if intensity_exp2==1
gen riot_threat_low=riot_threat if intensity_exp2==2
gen riot_threat_high=riot_threat if intensity_exp2==3

sum riot_threat_no if right==1
sum riot_threat_no if right==0
sum riot_threat_low if right==1
sum riot_threat_low if right==0
sum riot_threat_high if right==1
sum riot_threat_high if right==0

sum riot_threat_no
sum riot_threat_low
sum riot_threat_high

* Q6_4 crime_threat 
gen crime_threat_no=crime_threat if intensity_exp2==1
gen crime_threat_low=crime_threat if intensity_exp2==2
gen crime_threat_high=crime_threat if intensity_exp2==3

sum crime_threat_no if right==1
sum crime_threat_no if right==0
sum crime_threat_low if right==1
sum crime_threat_low if right==0
sum crime_threat_high if right==1
sum crime_threat_high if right==0

sum crime_threat_no
sum crime_threat_low
sum crime_threat_high

* Q6_5 terror_threat 
gen terror_threat_no=terror_threat if intensity_exp2==1
gen terror_threat_low=terror_threat if intensity_exp2==2
gen terror_threat_high=terror_threat if intensity_exp2==3

sum terror_threat_no if right==1
sum terror_threat_no if right==0
sum terror_threat_low if right==1
sum terror_threat_low if right==0
sum terror_threat_high if right==1
sum terror_threat_high if right==0

sum terror_threat_no
sum terror_threat_low
sum terror_threat_high

* Q6_6 resource_threat 
gen resource_threat_no=resource_threat if intensity_exp2==1
gen resource_threat_low=resource_threat if intensity_exp2==2
gen resource_threat_high=resource_threat if intensity_exp2==3

sum resource_threat_no if right==1
sum resource_threat_no if right==0
sum resource_threat_low if right==1
sum resource_threat_low if right==0
sum resource_threat_high if right==1
sum resource_threat_high if right==0

sum resource_threat_no
sum resource_threat_low
sum resource_threat_high

* Q6_7 job_threat 
gen job_threat_no =job_threat if intensity_exp2==1
gen job_threat_low=job_threat if intensity_exp2==2
gen job_threat_high=job_threat if intensity_exp2==3

sum job_threat_no if right==1
sum job_threat_no if right==0
sum job_threat_low if right==1
sum job_threat_low if right==0
sum job_threat_high if right==1
sum job_threat_high if right==0

sum job_threat_no
sum job_threat_low
sum job_threat_high

* Q6_8 religion_threat
gen religion_threat_no=religion_threat if intensity_exp2==1
gen religion_threat_low=religion_threat if intensity_exp2==2
gen religion_threat_high=religion_threat if intensity_exp2==3

sum religion_threat_no if right==1
sum religion_threat_no if right==0
sum religion_threat_low if right==1
sum religion_threat_low if right==0 
sum religion_threat_high if right==1
sum religion_threat_high if right==0 

sum religion_threat_no
sum religion_threat_low
sum religion_threat_high

* Q6_9 tradition_threat 
gen tradition_threat_no=tradition_threat if intensity_exp2==1
gen tradition_threat_low=tradition_threat if intensity_exp2==2
gen tradition_threat_high=tradition_threat if intensity_exp2==3

sum tradition_threat_no if right==1
sum tradition_threat_no if right==0
sum tradition_threat_low if right==1
sum tradition_threat_low if right==0
sum tradition_threat_high if right==1
sum tradition_threat_high if right==0

sum tradition_threat_no
sum tradition_threat_low
sum tradition_threat_high

* Q6_10 color_threat 
gen color_threat_no=color_threat if intensity_exp2==1
gen color_threat_low=color_threat if intensity_exp2==2
gen color_threat_high=color_threat if intensity_exp2==3

sum color_threat_no if right==1
sum color_threat_no if right==0
sum color_threat_low if right==1
sum color_threat_low if right==0
sum color_threat_high if right==1
sum color_threat_high if right==0

sum color_threat_no
sum color_threat_low
sum color_threat_high

* Q6_11 language_threat 
gen language_threat_no=language_threat if intensity_exp2==1
gen language_threat_low=language_threat if intensity_exp2==2
gen language_threat_high=language_threat if intensity_exp2==3

sum language_threat_no if right==1
sum language_threat_no if right==0
sum language_threat_low if right==1
sum language_threat_low if right==0
sum language_threat_high if right==1
sum language_threat_high if right==0

sum language_threat_no
sum language_threat_low
sum language_threat_high

* Q6_12 turkey_threat
gen turkey_threat_no=turkey_threat if intensity_exp2==1
gen turkey_threat_low=turkey_threat if intensity_exp2==2
gen turkey_threat_high=turkey_threat if intensity_exp2==3

sum turkey_threat_no if right==1
sum turkey_threat_no if right==0
sum turkey_threat_low if right==1
sum turkey_threat_low if right==0
sum turkey_threat_high if right==1
sum turkey_threat_high if right==0

sum turkey_threat_no
sum turkey_threat_low
sum turkey_threat_high

/****** Congruence exposure trust indicators

* How trustworthy do you find the central government

gen trust_centralgov_no=trust_centralgov if intensity_exp2==1
gen trust_centralgov_low=trust_centralgov if intensity_exp2==2
gen trust_centralgov_high=trust_centralgov if intensity_exp2==3

sum trust_centralgov_no if right==1
sum trust_centralgov_no if right==0
sum trust_centralgov_low if right==1
sum trust_centralgov_low if right==0
sum trust_centralgov_high if right==1
sum trust_centralgov_high if right==0

sum trust_centralgov_no
sum trust_centralgov_low
sum trust_centralgov_high

* How trustworthy do you find the local/municipal administration

gen trust_localgov_no=trust_localgov if intensity_exp2==1
gen trust_localgov_low=trust_localgov if intensity_exp2==2
gen trust_localgov_high=trust_localgov if intensity_exp2==3

sum trust_localgov_no if right==1
sum trust_localgov_no if right==0
sum trust_localgov_low if right==1
sum trust_localgov_low if right==0
sum trust_localgov_high if right==1
sum trust_localgov_high if right==0

sum trust_localgov_no
sum trust_localgov_low
sum trust_localgov_high

* How trustworthy do you find the EU

gen trust_eu_no=trust_eu if intensity_exp2==1
gen trust_eu_low=trust_eu if intensity_exp2==2
gen trust_eu_high=trust_eu if intensity_exp2==3

sum trust_eu_no if right==1
sum trust_eu_no if right==0
sum trust_eu_low if right==1
sum trust_eu_low if right==0
sum trust_eu_high if right==1
sum trust_eu_high if right==0

sum trust_eu_no
sum trust_eu_low
sum trust_eu_high
* How trustworthy do you find the public sector

gen trust_publicsec_no=trust_publicsec if intensity_exp2==1
gen trust_publicsec_low=trust_publicsec if intensity_exp2==2
gen trust_publicsec_high=trust_publicsec if intensity_exp2==3

sum trust_publicsec_no if right==1
sum trust_publicsec_no if right==0
sum trust_publicsec_low if right==1
sum trust_publicsec_low if right==0
sum trust_publicsec_high if right==1
sum trust_publicsec_high if right==0

sum trust_publicsec_no
sum trust_publicsec_low
sum trust_publicsec_high
* How trustworthy do you find the Greek judiciary

gen trust_judiciary_no=trust_judiciary if intensity_exp2==1
gen trust_judiciary_low=trust_judiciary if intensity_exp2==2
gen trust_judiciary_high=trust_judiciary if intensity_exp2==3

sum trust_judiciary_no if right==1
sum trust_judiciary_no if right==0
sum trust_judiciary_low if right==1
sum trust_judiciary_low if right==0
sum trust_judiciary_high if right==1
sum trust_judiciary_high if right==0

sum trust_judiciary_no
sum trust_judiciary_low
sum trust_judiciary_high
* How trustworthy do you find the Greek Police

gen trust_judiciary_no=trust_police if intensity_exp2==1
gen trust_police_low=trust_police if intensity_exp2==2
gen trust_police_high=trust_police if intensity_exp2==3

sum trust_police_no if right==1
sum trust_police_no if right==0
sum trust_police_low if right==1
sum trust_police_low if right==0
sum trust_police_high if right==1
sum trust_police_high if right==0

sum trust_judiciary_no
sum trust_judiciary_low
sum trust_judiciary_high

* How trustworthy do you find the Greek Army

gen trust_army_no=trust_army if intensity_exp2==1
gen trust_army_low=trust_army if intensity_exp2==2
gen trust_army_high=trust_army if intensity_exp2==3

sum trust_army_no if right==1
sum trust_army_no if right==0
sum trust_army_low if right==1
sum trust_army_low if right==0
sum trust_army_high if right==1
sum trust_army_high if right==0

sum trust_army_no
sum trust_army_low
sum trust_army_high
* How trustworthy do you find the Greek Orthodox Church

gen trust_church_no=trust_church if intensity_exp2==1
gen trust_church_low=trust_church if intensity_exp2==2
gen trust_church_high=trust_church if intensity_exp2==3

sum trust_church_no if right==1
sum trust_church_no if right==0
sum trust_church_low if right==1
sum trust_church_low if right==0
sum trust_church_high if right==1
sum trust_church_high if right==0

sum trust_church_no
sum trust_church_low
sum trust_church_high

* How trustworthy do you find International organizations such as IOM and UN

gen trust_io_no=trust_io if intensity_exp2==1
gen trust_io_low=trust_io if intensity_exp2==2
gen trust_io_high=trust_io if intensity_exp2==3

sum trust_io_no if right==1
sum trust_io_no if right==0
sum trust_io_low if right==1
sum trust_io_low if right==0
sum trust_io_high if right==1
sum trust_io_high if right==0

sum trust_io_no
sum trust_io_low
sum trust_io_high
* How trustworthy do you find Smaller NGOs and refugee relief groups

gen trust_smallngo_no=trust_smallngo if intensity_exp2==1
gen trust_smallngo_low=trust_smallngo if intensity_exp2==2
gen trust_smallngo_high=trust_smallngo if intensity_exp2==3

sum trust_smallngo_no if right==1
sum trust_smallngo_no if right==0
sum trust_smallngo_low if right==1
sum trust_smallngo_low if right==0
sum trust_smallngo_high if right==1
sum trust_smallngo_high if right==0

sum trust_smallngo_no
sum trust_smallngo_low
sum trust_smallngo_high
*/

save "Preprocessing/citizen_level_immigr_compens_2.dta"

