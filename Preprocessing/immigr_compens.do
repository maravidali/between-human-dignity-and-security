*** Immigration exposure new *** 

use "Preprocessing/immigr_compens.dta"

*** Merge with citizens profile data

set excelxlsxlargefile on

import excel "Preprocessing/citizens_profile_no_missing_data_analysis.xlsx", firstrow clear


merge m:m Q26_residence_2 using "Preprocessing/immigr_compens.dta"


/*  Result                      Number of obs
    -----------------------------------------
    Not matched                        23,716
        from master                    23,716  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            11,316  (_merge==3)
    -----------------------------------------
*/

rename _merge _merge_immigr_compens

export excel using "Preprocessing/citizens_profile_no_missing_data_analysis_imm_new.xlsx", firstrow(variables)

*** Merge with councilors 

import excel "Preprocessing/councilors_profiledata_withDV2_PCA_weight.xlsx", sheet("Sheet1") firstrow clear

merge m:m Q26_residence_2 using "Preprocessing/immigr_compens.dta"


/* Result                      Number of obs
    -----------------------------------------
    Not matched                         2,795
        from master                     2,790  (_merge==1)
        from using                          5  (_merge==2)

    Matched                               726  (_merge==3)
    -----------------------------------------
*/

rename _merge _merge_immigr_compens

drop if _merge_immigr_compens == 2

export excel using "Preprocessing/councilors_profiledata_withDV2_PCA_weight_imm_comp.xlsx", firstrow(variables) replace
 


