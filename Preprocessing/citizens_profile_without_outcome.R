
# Load packages -----------------------------------------------------------

library(plotrix)
library(jtools)
library(sandwich)
library(sjPlot)
library(sjlabelled)
library(sjmisc)
library(ggplot2)
library(car)
library(lmtest)
library(multiwayvcov)
library(plyr)
library(estimatr)
library(dummies)
library(gridExtra)
library(dplyr)
library(tidyr)
library(broom)
library(readxl)
library(tidyverse)
library(readstata13)
library(haven)
library(cjoint)
library(dummies)
library(dplyr)
library(fastDummies)
library(cregg)
library(data.table)
library(Publish)
library(stargazer)
require(plm)
require(lmtest)
library(ggplot2)
library(patchwork)
library(lfe)
library(olsrr)
library(readstata13)
library(rlang)
library(estimatr)
library(texreg)
library(rlang)
library(haven)
library(foreign)
library(gghighlight)
library(cregg)
library(foreign)
library(multcomp)
library(emmeans)
library(tidyverse)
library(readxl)
library(xlsx)
library(openxlsx)


# Set working directory ---------------------------------------------------
#setwd("~/Replication_files_for_publication")

####CITIZENS#### 

conjoint_data = read.dta13('Preprocessing/citizens_level.dta')

# Select f column data together with response id FOR F111 type
merged_data = conjoint_data[,1:31]

# Melt merged data from columns to rows
merged_data_profiles <- melt(data = merged_data, 
                             id.vars = c("ResponseId"),
                             variable.name = "responses")

# Assign task, profile and attribute numbers from responses column

# Construct task (1-3),profile (1=left, 2=right) and attribute (1-5) columns
merged_data_profiles$task_number <- str_sub(merged_data_profiles$responses, start = -3, end = -3)
merged_data_profiles$profile_number <- str_sub(merged_data_profiles$responses, start = -2, end = -2)
merged_data_profiles$attribute_number <- str_sub(merged_data_profiles$responses, start = -1, end = -1)

# Select f column data together with response id FOR F11 type
merged_data2 = conjoint_data[,31:46]

merged_data_attributes <- melt(data = merged_data2, 
                               id.vars = c("ResponseId"),
                               variable.name = "responses")

# Construct task (1-3), and attribute (1-5) columns
merged_data_attributes$task_number <- str_sub(merged_data_attributes$responses, start = -2, end = -2)
merged_data_attributes$attribute_number <- str_sub(merged_data_attributes$responses, start = -1, end = -1)

# renaming value column as question
merged_data_attributes <- merged_data_attributes %>% rename(question=value)

# Bring task-attribute questions next to profiles and merge F11 with F111 (will be used later) and adding one column showing attributes in the merged_data_profiles
data_questions_responses <- merged_data_attributes %>% dplyr::select('ResponseId', 'task_number', 'attribute_number', 'question') %>% left_join(merged_data_profiles, by=c("ResponseId","task_number","attribute_number"))

# forming final version of the data
final_profile = dcast(data_questions_responses,
                      ResponseId + task_number + profile_number ~ question,
                      value.var = "value")
head(final_profile)

# merge back to the rest of the dataset
conjoint_data = read.dta13('Preprocessing/citizens_level.dta')
citizens_profile <- merge(final_profile, conjoint_data, by="ResponseId")


write.xlsx(citizens_profile, "Preprocessing/citizens_profile_without_outcome.xlsx")
