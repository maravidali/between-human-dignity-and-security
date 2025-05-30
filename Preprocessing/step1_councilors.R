# Step 1 - Councilors survey 

# Load libraries --------------------------------------------------------

library(dplyr)
library(tidyr)
library(data.table)
library(readxl)
library(openxlsx)
library(readstata13)
library(stringr)     # for str_sub
library(reshape2)    # for melt and dcast


# Read data -------------------------------------------------------------
conjoint_data = read.xlsx('Preprocessing/councilors_subm.xlsx')

# AU- selecting f column data together with response id FOR F111 type
#merged_data = conjoint_data[,106:136]
#merged_data = conjoint_data[,39:69]
merged_data = conjoint_data[,67:97]

# melted merged data from columns to rows
merged_data_profiles <- melt(data = merged_data, 
                             id.vars = c("ResponseId"),
                             variable.name = "responses")

# filtering out f11 type of observations, and leaving only f111 type of observations
#merged_data_profiles = merged_data_melted[merged_data_melted['responses'].str.len() == 4]

# AU - I arranged them with response ID being in between F11 type and F111 type to begin with

# assigning task, profile and attribute numbers from responses column

# AU - my method here 
merged_data_profiles$task_number <- str_sub(merged_data_profiles$responses, start = -3, end = -3)
merged_data_profiles$profile_number <- str_sub(merged_data_profiles$responses, start = -2, end = -2)
merged_data_profiles$attribute_number <- str_sub(merged_data_profiles$responses, start = -1, end = -1)

# filtering out f111 type of observations, and leaving only f11 type of observations
#merged_data_attributes = merged_data_melted[merged_data_melted['responses'].str.len() == 3]

# AU - I arranged them with response ID being in between F11 type and F111 type to begin with
#merged_data2 = conjoint_data[,91:106]
#merged_data2 = conjoint_data[,24:39]
merged_data2 = conjoint_data[,52:67]

merged_data_attributes <- melt(data = merged_data2, 
                               id.vars = c("ResponseId"),
                               variable.name = "responses")
# AU - my method here 
merged_data_attributes$task_number <- str_sub(merged_data_attributes$responses, start = -2, end = -2)
merged_data_attributes$attribute_number <- str_sub(merged_data_attributes$responses, start = -1, end = -1)

# renaming value column as question
merged_data_attributes <- merged_data_attributes %>% rename(question=value)

# bringing task-attribute questions next to profiles. will be used later
data_questions_responses <- merged_data_attributes %>% dplyr::select('ResponseId', 'task_number', 'attribute_number', 'question') %>% left_join(merged_data_profiles, by=c("ResponseId","task_number","attribute_number"))

# forming final version of the data
final_profile = dcast(data_questions_responses,
                      ResponseId + task_number + profile_number ~ question,
                      value.var = "value")
head(final_profile)

# merge back to the rest of the dataset
#conjoint_data <- read.dta13("covariates_councilor.dta") #put either original Qualtrics output here or the one with some additional variables
#conjoint_data <- read.dta13("Preprocessing/councilors_nomiss.dta")
conjoint_data <- read.dta13("Preprocessing/councilors_subm.dta")
greece_profiledata <- merge(final_profile, conjoint_data, by="ResponseId")

# merge to treat1 too
#treat <- read.dta13("treat1.dta") 
#greece_profiledata2 <- merge(greece_profiledata, treat, by="ResponseId")

#write.xlsx(greece_profiledata2, "councilors_profiledata.xlsx")
write.xlsx(greece_profiledata, "Preprocessing/councilors_profiledata.xlsx")

# Now go to "https://www.dropbox.com/s/zqx5k1evu7v9tbw/councilor_DV_generation.do?dl=0"
# the sequence is important!
