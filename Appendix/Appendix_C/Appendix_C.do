* 08 May 2025

* Figure C.1.
clear
use "Appendix/Data for Appendix/citizens_level.dta", clear

drop if pol_orient==.
gen pol_orient_full=pol_orient
gen pol_orient_text=pol_orient
replace pol_orient_text=. if Q30!=""

* Step 1: Create percentage distribution for pol_orient_full
preserve
keep if !missing(pol_orient_full)
gen one = 1
collapse (count) one, by(pol_orient_full)
rename one count_full
rename pol_orient_full score

* Total number of responses
summarize count_full, meanonly
gen pct_full = 100 * count_full / r(sum)

tempfile fullfreq
save `fullfreq'
restore

* Step 2: Create percentage distribution for pol_orient_text
keep if !missing(pol_orient_text)
gen one = 1
collapse (count) one, by(pol_orient_text)
rename one count_text
rename pol_orient_text score

* Total number of responses
summarize count_text, meanonly
gen pct_text = 100 * count_text / r(sum)

* Step 3: Merge the two tables
merge 1:1 score using `fullfreq'

* Replace missing values with 0
replace pct_full = 0 if missing(pct_full)
replace pct_text = 0 if missing(pct_text)

* Step 4: Create line graph with custom formatting
twoway ///
(line pct_full score, lcolor(black) lpattern(solid)) ///
(line pct_text score, lcolor(black) lpattern(dash)), ///
legend(label(1 "Full Sample") label(2 "Text Sample")) ///
xtitle("Political ideology") ///
ytitle("Percent") ///
ylabel(0(5)30) ///
xlabel(0(1)9 10, labsize(small)) ///
graphregion(color(white)) ///
saving(Figure_C1.png, replace)

graph export "Figure_C1.png", replace

              *****

* Table C.1.

* Note: First column reports Population data from the 2011 Greek Census
clear
use "Appendix/Data for Appendix/citizens_level.dta", clear
gen age1724 = age_group == 1
gen age2534 = age_group == 2
gen age3544 = age_group == 3
gen age4554 = age_group == 4
gen age55plus = inlist(age_group, 5, 6)
gen region1  = Q26_residence_1 == "Anatolikis Macedonias kai Thrakis"
gen region2  = Q26_residence_1 == "Attikis"
gen region3  = Q26_residence_1 == "Voreiou Aigaiou"
gen region4  = Q26_residence_1 == "Dytikis Elladas"
gen region5  = Q26_residence_1 == "Dytikis Makedonias"
gen region6  = Q26_residence_1 == "Ipeirou"
gen region7  = Q26_residence_1 == "Thessalias"
gen region8  = Q26_residence_1 == "Ionion Nison"
gen region9  = Q26_residence_1 == "Kentrikis Makedonias"
gen region10 = Q26_residence_1 == "Notiou Aigaiou"
gen region11 = Q26_residence_1 == "Peloponnisou"
gen region12 = Q26_residence_1 == "Stereas Elladas"
gen region13 = Q26_residence_1 == "Kritis"
local vars female age1724 age2534 age3544 age4554 age55plus region1 region2 region3 region4 region5 region6 region7 region8 region9 region10 region11 region12 region13

preserve
clear
set obs 1
foreach v of local vars {
    gen `v' = .
}
replace female = 0.510
replace age1724 = 0.096
replace age2534 = 0.173
replace age3544 = 0.184
replace age4554 = 0.165
replace age55plus = 0.382
replace region1 = 0.056
replace region2 = 0.354
replace region3 = 0.018
replace region4 = 0.063
replace region5 = 0.026
replace region6 = 0.031
replace region7 = 0.068
replace region8 = 0.019
replace region9 = 0.174
replace region10 = 0.029
replace region11 = 0.053
replace region12 = 0.051
replace region13 = 0.058
estpost summarize `vars'
eststo censusmodel
restore

estpost summarize `vars'
scalar N_full = e(N)
eststo full

preserve
drop if Q30_campfeedback == ""
estpost summarize `vars'
scalar N_text = e(N)
eststo text
restore

local obs_note Observations: Full = `=N_full', Text = `=N_text'

label variable female      "Female"
label variable age1724     "Age: 17–24"
label variable age2534     "Age: 25–34"
label variable age3544     "Age: 35–44"
label variable age4554     "Age: 45–54"
label variable age55plus   "Age: 55+"
label variable region1     "An. Mac/nia Th/ki"
label variable region2     "Attiki"
label variable region3     "Voreio Aigaio"
label variable region4     "Dytiki Ellada"
label variable region5     "Dytiki Makedonia"
label variable region6     "Ipeiros"
label variable region7     "Thessalia"
label variable region8     "Ionioi Nisoi"
label variable region9     "Kentriki Makedonia"
label variable region10    "Notio Aigaio"
label variable region11    "Peloponnisos"
label variable region12    "Sterea Ellada"
label variable region13    "Kriti"

esttab censusmodel full text using Table_C1.tex, cells("mean(fmt(3))") label mtitles("Census" "Full sample" "Text sample") noobs nonumber note("`obs_note'")


* Figure C.4.
clear
use "Appendix/Data for Appendix/citizens_level.dta", clear

gen support = inlist(Q10_c_post_num, 4, 5)
collapse (mean) support, by(pol_orient)
replace support = support * 100

twoway (line support pol_orient, lpattern(dash) lcolor(black) lwidth(medium)) ///
       , ytitle("% Supporting Camp Construction") ///
         xtitle("Political Ideology") ///
         xlabel(0(1)10, nogrid) ylabel(0(20)100, angle(0) nogrid) ///
         graphregion(color(white)) plotregion(style(none)) ///
         title("") legend(off) ///
         saving(Figure_C4.png, replace)
graph export "Figure_C4.png", replace
		 

* Table C.2

* Should be in the Keyness Analysis code




































































