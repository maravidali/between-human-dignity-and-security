########### Between Human Dignity and Security: Identifying Citizen and ########
############# Elite Preferences and Concerns over Refugee Reception ############
############################### Online Appendix ################################

# Table A1 ----------------------------------------------------------------
# Load packages
library(readstata13)
library(estimatr)
library(texreg)

# Read data
citizens <- read.dta13("Appendix/Data for Appendix/citizens_subm.dta")
population <- read.dta13("Appendix/Data for Appendix/citizens_population_represent.dta")
citizens <- merge(citizens,population, by="Q26_residence_2")
citizens$citizens<-1
citizens$citizens[is.na(citizens$responder_id)]<-0
summary(citizens$citizens)

number_participated <- aggregate(citizens$citizens, by=list(Q26_residence_2=citizens$Q26_residence_2), FUN=sum)
citizens <- merge(number_participated,citizens,  by="Q26_residence_2")

citizens$participation_ratio <- citizens$x/citizens$Population.y
summary(citizens$participation_ratio)

# Table A1
participation2 <- lm_robust(participation_ratio ~ GOLDEN_D + ND + KINAL + SYRIZA + KKE +
                              ANTARSYA + 
                              Women + camp, cluster=Q26_residence_2, data = citizens)
summary(participation2)

texreg(list(participation2), include.ci = FALSE, file = "Table_A1.tex", use.packages = FALSE)

rm(list=ls())

# Table A2 ----------------------------------------------------------------
# Load packages
library(readstata13)
library(estimatr)
library(texreg)

# Read data
councilors <- read.dta13("Appendix/Data for Appendix/councilors_full.dta")
population <- read.dta13("Appendix/Data for Appendix/councilors_population_represent.dta")
councilors <- merge(councilors,population, by="Q26_residence_2")

councilors$councilor<-1
councilors$councilor[is.na(councilors$responder_id)]<-0
summary(councilors$councilor)

number_participated <- aggregate(councilors$councilor, by=list(Q26_residence_2=councilors$Q26_residence_2), FUN=sum)
councilors <- merge(number_participated,councilors,  by="Q26_residence_2")

councilors$participation_ratio <- councilors$x/councilors$councilors_num
summary(councilors$participation_ratio)

# Table A2
participation2 <- lm_robust(participation_ratio ~ golden_d.y + nd.y + kinal.y + syriza.y + kke.y +
                              antarsya + 
                              female.y + camp, cluster=Q26_residence_2, data = councilors)
summary(participation2)

texreg(list(participation2), include.ci = FALSE, file = "Table_A2.tex", use.packages = FALSE)
rm(list=ls())


# Table B1 ----------------------------------------------------------------
# Load packages
library(fastDummies)
library(openxlsx)
library(estimatr)
library(texreg)

# Read data
citizens <- read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)
dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"


# Reorder variables
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))
citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))


# Create dummies
citizens <- dummy_cols(citizens, select_columns = "Proximity")
citizens <- dummy_cols(citizens, select_columns = "Publicgoods")
citizens <- dummy_cols(citizens, select_columns = "Size")
citizens <- dummy_cols(citizens, select_columns = "Type")
citizens <- dummy_cols(citizens, select_columns = "Runby")

lessthan1pct <- c(citizens$`Size_< 1% of local population`)
onepct <- c(citizens$`Size_1% of local population`)
morethan1pct <- c(citizens$`Size_> 1 % of local population`)
lessthan30minwalk <- c(citizens$`Proximity_< 30mins from ctr`)
morethan30minwalk <- c(citizens$`Proximity_> 30mins from ctr`)
inthecenter <- c(citizens$`Proximity_In ctr`)
army <- c(citizens$Runby_Army)
church <- c(citizens$Runby_Church)
government <- c(citizens$Runby_Government)
IOs <- c(citizens$`Runby_International Organizations (UNHCR,IOM)`)
local_government <- c(citizens$`Runby_Local Government`)
hire_more_municipal_employees <- c(citizens$`Publicgoods_Hire more municipal employees`)
hire_more_teachers_and_doctors <- c(citizens$`Publicgoods_Hire more teachers and doctors`)
more_infrastructure <- c(citizens$`Publicgoods_More infrastructure to the municipality`)
closed <- c(citizens$Type_Closed)
partially_open <- c(citizens$`Type_Partially open`)
fully_open <- c(citizens$`Type_Fully open`)
ResponseId <- c(citizens$ResponseId)

# Run the regressions
reg1 <- lm_robust(dv_binary ~ morethan30minwalk + lessthan30minwalk
                  + more_infrastructure + hire_more_teachers_and_doctors
                  + morethan1pct +morethan1pct+ lessthan1pct
                  + partially_open + fully_open +
                    church + government + IOs + local_government,
                  clusters = ResponseId, data=citizens)

reg2 <- lm_robust(dv_binary ~ morethan30minwalk + lessthan30minwalk
                  + more_infrastructure + hire_more_teachers_and_doctors
                  + morethan1pct +morethan1pct+ lessthan1pct
                  + partially_open + fully_open +
                    church + government + IOs + local_government,
                  clusters = ResponseId, data=citizens, weights = webal)

reg3 <- lm_robust(dv_binary ~ morethan30minwalk + lessthan30minwalk
                  + more_infrastructure + hire_more_teachers_and_doctors
                  + morethan1pct +morethan1pct+ lessthan1pct
                  + partially_open + fully_open +
                    church + government + IOs + local_government,
                  clusters = ResponseId, data=citizens,
                  fixed_effects = munic_res)

# Table B1
texreg(list(reg1, reg2, reg3),
       custom.model.names = c("Main model", "Weighted model",
                              "Municipality FE model"), file = "Table_B1.tex", include.ci=FALSE)

rm(list=ls())

# Table B2 ----------------------------------------------------------------
# Load packages
library(fastDummies)
library(openxlsx)
library(estimatr)
library(texreg)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight.xlsx")

# Attribute values
councilors$Proximity <- factor(councilors$Proximity)
councilors$Publicgoods <- factor(councilors$Publicgoods)
councilors$Size <- factor(councilors$Size)
councilors$Type <- factor(councilors$Type)
councilors$Run_by <- factor(councilors$Runby)
councilors$munic_res <- factor(councilors$munic_res)
dv_binary <- factor(councilors$dv_binary)
councilors$ResponseId <- c(councilors$ResponseId)

attr(councilors$Run_by, "label") <- "Run by"
attr(councilors$Publicgoods, "label") <- "Publicgoods"

# Reorder variables
councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
                                  c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Create dummies
councilors <- dummy_cols(councilors, select_columns = "Proximity")
councilors <- dummy_cols(councilors, select_columns = "Publicgoods")
councilors <- dummy_cols(councilors, select_columns = "Size")
councilors <- dummy_cols(councilors, select_columns = "Type")
councilors <- dummy_cols(councilors, select_columns = "Run_by")

lessthan1pct <- c(councilors$`Size_< 1% of local population`)
onepct <- c(councilors$`Size_1% of local population`)
morethan1pct <- c(councilors$`Size_> 1% of local population`)
lessthan30minwalk <- c(councilors$`Proximity_< 30mins from ctr`)
morethan30minwalk <- c(councilors$`Proximity_> 30mins from ctr`)
inthecenter <- c(councilors$`Proximity_In ctr`)
army <- c(councilors$Run_by_Army)
church <- c(councilors$Run_by_Church)
government <- c(councilors$Run_by_Government)
IOs <- c(councilors$`Run_by_International Organizations (UNHCR,IOM)`)
local_government <- c(councilors$`Run_by_Local Government`)
hire_more_municipal_employees <- c(councilors$`Publicgoods_Hire more municipal employees`)
hire_more_teachers_and_doctors <- c(councilors$`Publicgoods_Hire more teachers and doctors`)
more_infrastructure <- c(councilors$`Publicgoods_More infrastructure to the municipality`)
closed <- c(councilors$Type_Closed)
partially_open <- c(councilors$`Type_Partially open`)
fully_open <- c(councilors$`Type_Fully open`)
ResponseId <- c(councilors$ResponseId)

# Run the regressions
reg1 <- lm_robust(dv_binary ~ morethan30minwalk + lessthan30minwalk
                  + more_infrastructure + hire_more_teachers_and_doctors
                  + morethan1pct +morethan1pct+ lessthan1pct
                  + partially_open + fully_open +
                    church + government + IOs + local_government,
                  clusters = ResponseId, data=councilors)

reg2 <- lm_robust(dv_binary ~ morethan30minwalk + lessthan30minwalk
                  + more_infrastructure + hire_more_teachers_and_doctors
                  + morethan1pct +morethan1pct+ lessthan1pct
                  + partially_open + fully_open +
                    church + government + IOs + local_government,
                  clusters = ResponseId, data=councilors, weights = webal2)

reg3 <- lm_robust(dv_binary ~ morethan30minwalk + lessthan30minwalk
                  + more_infrastructure + hire_more_teachers_and_doctors
                  + morethan1pct +morethan1pct+ lessthan1pct
                  + partially_open + fully_open +
                    church + government + IOs + local_government,
                  clusters = ResponseId, data=councilors,
                  fixed_effects = munic_res)
# Table B2
texreg(list(reg1, reg2, reg3),
       custom.model.names = c("Main model", "Weighted model",
                              "Municipality FE model"),  file = "Table_B2.tex", include.ci=FALSE)


rm(list=ls())

# Figure B1 and Table B3 -------------------------------------------------------
# Load packages
library(openxlsx)
library(xtable)

# Read data
citizens <- read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis.xlsx")

# Figure B1
ideology <- as.numeric(citizens$Q16_1)
png("Figure_B1.png", width = 839, height = 490)
hist(ideology,  col="grey")
#print(Figure_B1)
dev.off()

# Compute summary statistics
N <- sum(!is.na(ideology))
mean_val <- mean(ideology, na.rm = TRUE)
sd_val <- sd(ideology, na.rm = TRUE)
min_val <- min(ideology, na.rm = TRUE)
p25 <- quantile(ideology, 0.25, na.rm = TRUE)
p75 <- quantile(ideology, 0.75, na.rm = TRUE)
max_val <- max(ideology, na.rm = TRUE)

# Create the summary data frame 
Table_B3 <- data.frame(
  Group = "Citizens",
  `Obs. (=Profiles)` = N,
  Mean = mean_val,
  `Std. Dev.` = sd_val,
  Min = min_val,
  `P(25)` = p25,
  `P(75)` = p75,
  Max = max_val,
  check.names = FALSE
)

# Convert to LaTeX table
latex_table <- xtable(Table_B3, align = c("l", "l", rep("r", 7)))

# Table B3
# Print to .tex file with desired digits 
print(latex_table, 
      file = "Table_B3.tex", 
      include.rownames = FALSE, 
      digits = c(0, 0, 0, 3, 3, 0, 0, 0, 0),  
      format.args = list(big.mark = ",", decimal.mark = "."))

rm(list=ls())

# Figure B2 ---------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)


# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
f1 <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# Define ideology
ideology <- as.numeric(citizens$Q16_1)
summary(ideology)

# mid-point cutoff
citizens <- citizens %>% mutate(Ideology = case_when(ideology >= 5  ~ 'Right',
                                                     ideology < 5  ~ 'Left'))

citizens$Ideology <- factor(citizens$Ideology, levels = c('Left', 'Right'))
u <- plot(cj(citizens, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
          group = "Ideology", vline = 0.5) + ggtitle("Median-point cut-off")

# median + 1 -1 cutoff
ideology <- as.numeric(citizens$Q16_1)
summary(ideology)

citizens <- citizens %>% mutate(Ideology = case_when(ideology >= 6  ~ 'Right (+1)',
                                                     ideology < 4  ~ 'Left (-1)'))

citizens$Ideology <- factor(citizens$Ideology, levels = c('Left (-1)', 'Right (+1)'))
u2 <- plot(cj(citizens, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
           group = "Ideology", vline = 0.5) + ggtitle("Median-point +1/-1 cut-off")

# mean-point cutoff
citizens <- citizens %>% mutate(Ideology = case_when(ideology >= 5.1  ~ 'Right',
                                                              ideology < 5.1  ~ 'Left'))

citizens$Ideology <- factor(citizens$Ideology, levels = c('Left', 'Right'))
u3 <- plot(cj(citizens, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
           group = "Ideology", vline = 0.5)  + ggtitle("Mean-point cut-off")

# tertile-point cutoff
# Find tertiles
vTert = quantile(citizens$Q16_1, c(0:3/3), na.rm = TRUE)

# classify values
citizens$Ideology = with(citizens, 
                         cut(Q16_1, 
                             vTert, 
                             include.lowest = T, 
                             labels = c("Left", "Center", "Right")))

u4 <- plot(cj(citizens, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
           group = "Ideology", vline = 0.5) + ggtitle("Tertile cut-off")

# Figure B2
png("Figure_B2.png", width = 1200, height = 600)  
grid.arrange(u+apatheme2,u2+apatheme2,u3+apatheme2,u4+apatheme2)
dev.off()

rm(list=ls())

# Figure B3 and Table B4 --------------------------------------------------
# Load packages
library(openxlsx)
library(xtable)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight.xlsx")

# Figure B3
ideology <- as.numeric(councilors$Q16_1)
png("Figure_B3.png", width = 839, height = 490)
hist(ideology,  col="grey")
#print(Figure_B3)
dev.off()

# Compute summary statistics
N <- sum(!is.na(ideology))
mean_val <- mean(ideology, na.rm = TRUE)
sd_val <- sd(ideology, na.rm = TRUE)
min_val <- min(ideology, na.rm = TRUE)
p25 <- quantile(ideology, 0.25, na.rm = TRUE)
p75 <- quantile(ideology, 0.75, na.rm = TRUE)
max_val <- max(ideology, na.rm = TRUE)

# Create the summary data frame 
Table_B4 <- data.frame(
  Group = "Councilors",
  `Obs. (=Profiles)` = N,
  Mean = mean_val,
  `Std. Dev.` = sd_val,
  Min = min_val,
  `P(25)` = p25,
  `P(75)` = p75,
  Max = max_val,
  check.names = FALSE
)

# Convert to LaTeX table
latex_table <- xtable(Table_B4, align = c("l", "l", rep("r", 7)))

# Table B4
# Print to .tex file with desired digits 
print(latex_table, 
      file = "Table_B4.tex", 
      include.rownames = FALSE, 
      digits = c(0, 0, 0, 3, 3, 0, 0, 0, 0),  
      format.args = list(big.mark = ",", decimal.mark = "."))

rm(list=ls())


# Figure B4 ---------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight.xlsx")

# Attribute values 
councilors$Proximity <- factor(councilors$Proximity)
councilors$Publicgoods <- factor(councilors$Publicgoods)
councilors$Size <- factor(councilors$Size)
councilors$Type <- factor(councilors$Type)
councilors$Run_by <- factor(councilors$Runby)
councilors$munic_res <- factor(councilors$munic_res)
dv_binary <- factor(councilors$dv_binary)
councilors$ResponseId <- c(councilors$ResponseId)

attr(councilors$Run_by, "label") <- "Run by"
attr(councilors$Publicgoods, "label") <- "Publicgoods"

# Reorder variables 
councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
                                  c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
f1 <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Run_by

# mid-point cutoff
ideology <- as.numeric(councilors$Q16_1)
summary(ideology)
councilors <- councilors %>% mutate(Ideology = case_when(ideology >= 5  ~ 'Right',
                                                         ideology < 5  ~ 'Left'))

councilors$Ideology <- factor(councilors$Ideology, levels = c('Left', 'Right'))
u <- plot(cj(councilors, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
          group = "Ideology", vline = 0.5) + ggtitle("Median-point cut-off")


# median + 1 -1 cutoff
ideology <- as.numeric(councilors$Q16_1)
summary(ideology)

councilors <- councilors %>% mutate(Ideology = case_when(ideology >= 6  ~ 'Right (+1)',
                                                         ideology < 4  ~ 'Left (-1)'))

councilors$Ideology <- factor(councilors$Ideology, levels = c('Left (-1)', 'Right (+1)'))
u2 <- plot(cj(councilors, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
           group = "Ideology", vline = 0.5) + ggtitle("Median-point +1/-1 cut-off")

# mean-point cutoff
ideology <- as.numeric(councilors$Q16_1)
summary(ideology)
councilors <- councilors %>% mutate(Ideology = case_when(ideology >= 5.02  ~ 'Right',
                                                         ideology < 5.02  ~ 'Left'))

councilors$Ideology <- factor(councilors$Ideology, levels = c('Left', 'Right'))
u3 <- plot(cj(councilors, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
           group = "Ideology", vline = 0.5) + ggtitle("Mean-point cut-off")

# tertile-point cutoff
# Find tertiles
vTert = quantile(councilors$Q16_1, c(0:3/3), na.rm = TRUE)

# classify values
councilors$Ideology = with(councilors, 
                           cut(Q16_1, 
                               vTert, 
                               include.lowest = T, 
                               labels = c("Left", "Center", "Right")))

u4 <- plot(cj(councilors, f1, id = ~ResponseId, by = ~Ideology, estimate = "mm"),
           group = "Ideology", vline = 0.5) + ggtitle("Tertile cut-off")

# Figure B4
png("Figure_B4.png", width = 1200, height = 600)  
grid.arrange(u+apatheme2,u2+apatheme2,u3+apatheme2,u4+apatheme2)
dev.off()

rm(list=ls())


# Tables B5 and B6 --------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))
# Regression
f1 <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# Define Right and Left 
citizens$Ideology2[citizens$Q16_1>=5]<-"Right"
citizens$Ideology2[citizens$Q16_1<5]<-"Left"
citizens$Ideology2 <- factor(citizens$Ideology2,levels = c("Left", "Right"))

# Table B5
test<-mm_diffs(citizens, f1, by = ~ Ideology2, id = ~ ResponseId)

manual_order <- c(
  # Proximity
  "> 30mins from ctr",
  "< 30mins from ctr",
  "In ctr",
  
  # Publicgoods
  "Hire more municipal employees",
  "More infrastructure to the municipality",
  "Hire more teachers and doctors",
  
  # Size
  "> 1% of local population",
  "1% of local population",
  "< 1 % of local population",
  
  # Type
  "Closed",
  "Partially open",
  "Fully open",
  
  # Run by
  "Local Government",
  "International Organizations (UNHCR,IOM)",
  "Government",
  "Church",
  "Army"
  )

# Apply manual order to 'level'
test$level <- factor(test$level, levels = manual_order)

# Corrected column name: 'feature'
test_ordered <- test %>%
  arrange(feature, level)

# Save LaTeX table
print(xtable(test_ordered), file = "Table_B5.tex", include.rownames = FALSE)

# Table B6
citizens2<-citizens[!is.na(citizens$Q16_1),]

cj_anov<-cj_anova(citizens2, f1, id = ~ResponseId,by = ~Ideology2)

# Extract F-statistic and p-value
fstat <- round(cj_anov$F[2], 3)
df1 <- cj_anov$Df[2]
df2 <- cj_anov$`Resid. Df`[2]
pval <- round(cj_anov$`Pr(>F)`[2], 3)

# Format as LaTeX
latex_text <- c(
  "\\begin{tabular}{ll}",
  paste0("\\( F(", df1, ", ", df2, ") \\) & ", fstat, " \\\\"),
  paste0("\\( p\\text{-value} \\) & ", pval, " \\\\"),
  "\\end{tabular}"
)

# Write to .tex file
writeLines(latex_text, "Table_B6.tex")

rm(list=ls())

# Tables B7 and B8 --------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight.xlsx")

# Attribute values 
councilors$Proximity <- factor(councilors$Proximity)
councilors$Publicgoods <- factor(councilors$Publicgoods)
councilors$Size <- factor(councilors$Size)
councilors$Type <- factor(councilors$Type)
councilors$Run_by <- factor(councilors$Runby)
councilors$munic_res <- factor(councilors$munic_res)
dv_binary <- factor(councilors$dv_binary)
councilors$ResponseId <- c(councilors$ResponseId)

attr(councilors$Run_by, "label") <- "Run by"
attr(councilors$Publicgoods, "label") <- "Publicgoods"

# Reorder variables 
councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
                                  c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Regression
f1 <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Run_by

# Define Right and Left 
councilors$Ideology2[councilors$Q16_1>=5]<-"Right"
councilors$Ideology2[councilors$Q16_1<5]<-"Left"
councilors$Ideology2 <- factor(councilors$Ideology2,levels = c("Left", "Right"))

# Table B7
test<-mm_diffs(councilors, f1, by = ~ Ideology2, id = ~ ResponseId)

manual_order <- c(
  # Proximity
  "> 30mins from ctr",
  "< 30mins from ctr",
  "In ctr",
  
  # Publicgoods
  "Hire more municipal employees",
  "More infrastructure to the municipality",
  "Hire more teachers and doctors",
  
  # Size
  "> 1% of local population",
  "1% of local population",
  "< 1 % of local population",
  
  # Type
  "Closed",
  "Partially open",
  "Fully open",
  
  # Run by
  "Local Government",
  "International Organizations (UNHCR,IOM)",
  "Government",
  "Church",
  "Army"
)

# Apply manual order to 'level'
test$level <- factor(test$level, levels = manual_order)

# Corrected column name: 'feature'
test_ordered <- test %>%
  arrange(feature, level)

# Save LaTeX table
print(xtable(test_ordered), file = "Table_B7.tex", include.rownames = FALSE)

# Table B8
councilors2<-councilors[!is.na(councilors$Q16_1),]

cj_anov<-cj_anova(councilors2, f1, id = ~ResponseId,by = ~Ideology2)

# Extract F-statistic and p-value
fstat <- round(cj_anov$F[2], 3)
df1 <- cj_anov$Df[2]
df2 <- cj_anov$`Resid. Df`[2]
pval <- round(cj_anov$`Pr(>F)`[2],3)

# Format as LaTeX
latex_text <- c(
  "\\begin{tabular}{ll}",
  paste0("\\( F(", df1, ", ", df2, ") \\) & ", fstat, " \\\\"),
  paste0("\\( p\\text{-value} \\) & ", pval, " \\\\"),
  "\\end{tabular}"
)

# Write to .tex file
writeLines(latex_text, "Table_B8.tex")

rm(list=ls())

# Figure B5 and Table B9--------------------------------------------------------
# Load packages 
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(grid)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))
# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Figure B5
citizens$type_runby <- interaction(citizens$Type, citizens$Runby, sep="_")
type_runby_cit <- plot(cj(citizens, dv_binary~ type_runby, id = ~ResponseId, estimate = "mm"), vline = 0.5, size=1.5) + scale_color_manual(values = rep("black", 9))
Figure_B5 <- type_runby_cit + apatheme2
png("Figure_B5.png", width = 839, height = 490)
print(Figure_B5)
dev.off()

# Table B9
out_type_runby <- dv_binary~ type_runby
out_type_runby_mm <- mm(citizens, out_type_runby,
                        id = ~ResponseId)
print(xtable(out_type_runby_mm, type = "tex"), file = "Table_B9.tex")


# Figure B6 and Table B10 ---------------------------------------------------------------

# Figure B6 Same with Figure 5

ideology <- as.numeric(citizens$Q16_1)
summary(ideology)
citizens <- citizens %>% mutate(Reported_Ideology = case_when(ideology >= 5  ~ 'Right',
                                                              ideology < 5  ~ 'Left'))
citizens$Reported_Ideology <- factor(citizens$Reported_Ideology, levels = c('Left', 'Right'))

citizens$type_runby <- interaction(citizens$Type, citizens$Runby, sep="_")

Figure_B6 <- plot(cj(citizens, dv_binary~ type_runby, id = ~ResponseId, by=~Reported_Ideology, estimate = "mm"), group="Reported_Ideology", vline = 0.5, size=1.5)
Figure_B6 <- Figure_B6 + apatheme2
png("Figure_B6.png", width = 839, height = 490)
print(Figure_5)
dev.off()

out_type_runby_mm_ideol <-cj(citizens, dv_binary~ type_runby, id = ~ResponseId, by=~Reported_Ideology, estimate = "mm")
print(xtable(out_type_runby_mm_ideol, type = "tex"), file = "Table_B10.tex")

# Table B11 ---------------------------------------------------------------
out_type_runby_mm_ideol_diff<-mm_diffs(citizens, dv_binary~ type_runby, by = ~ Reported_Ideology, id = ~ ResponseId)
print(xtable(out_type_runby_mm_ideol_diff, type = "tex"), file = "Table_B11.tex")

# Figure B7 and Table B12 -------------------------------------------------

# Figure B7
citizens$proximity_type <- interaction(citizens$Proximity, citizens$Type, sep="_")
proximity_type_cit <- plot(cj(citizens, dv_binary~ proximity_type, id = ~ResponseId, estimate = "mm"), vline = 0.5, size=1.5) + scale_color_manual(values = rep("black", 9))
Figure_B7 <- proximity_type_cit + apatheme2
png("Figure_B7.png", width = 839, height = 490)
print(Figure_B7)
dev.off()

# Table B12
out_proximity_type <- dv_binary~  proximity_type
out_proximity_type_mm <- mm(citizens, out_proximity_type,
                            id = ~ResponseId)
print(xtable(out_proximity_type_mm, type = "tex"), file = "Table_B12.tex")

# Figure B8 and Table B13-------------------------------------------------------

# Figure B8
proximity_type_cit_by_ideol <- plot(cj(citizens, dv_binary~ proximity_type, id = ~ResponseId, by=~Reported_Ideology, estimate = "mm"), group="Reported_Ideology", vline = 0.5, size=1.5)
Figure_B8 <- proximity_type_cit_by_ideol + apatheme2
png("Figure_B8.png", width = 839, height = 490)
print(Figure_B8)
dev.off()

# Table B13
out_proximity_type_mm_ideol <-cj(citizens, dv_binary~ proximity_type, id = ~ResponseId, by=~Reported_Ideology, estimate = "mm")
print(xtable(out_proximity_type_mm_ideol, type = "tex"), file = "Table_B13.tex")

# Table B14 ---------------------------------------------------------------
out_proximity_type_mm_ideol_diff<-mm_diffs(citizens, dv_binary~ proximity_type, by = ~ Reported_Ideology, id = ~ ResponseId)
print(xtable(out_proximity_type_mm_ideol_diff, type = "tex"), file = "Table_B14.tex")

rm(list=ls())

# Figure B9 ---------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)


# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis_imm_new.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# Immigrants per population 
citizens$popthous <- citizens$Population/1000
citizens$Imm_Pop <- citizens$Immigrants/citizens$popthous
summary(unique(citizens$Imm_Pop)) 
summary(citizens$Imm_Pop)
citizens$Imm_Pop_wna <- citizens$Imm_Pop
summary(citizens$Imm_Pop_wna)
citizens$Imm_Pop_wna[is.na(citizens$Imm_Pop_wna)] <- 0 
summary(citizens$Imm_Pop_wna)

# high vs small number of immigrants per thousands of residents 
# municipalities with zero immigrants - No exposure
# municipalities with lower than the average - Low exposure
# municipalities with equar or higher than the average - High exposure

summary(unique(citizens$Imm_Pop)) 

citizens <- citizens %>% mutate(imm_exp = case_when (Imm_Pop_wna == 0 ~ "No Exposure",
                                                     Imm_Pop_wna < 55.796 ~ "Low Exposure",
                                                     Imm_Pop_wna >= 55.796 ~ "High Exposure"))
citizens$imm_exp <- factor(citizens$imm_exp, levels = c("No Exposure", "Low Exposure", "High Exposure"))

cj_citiz <-cj(citizens, out, id = ~ResponseId, by = ~imm_exp, estimate = "mm")

# Figure B9
imm_exp_citiz <- plot(cj_citiz, group = "imm_exp", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(color=NULL)

Figure_B9 <- imm_exp_citiz+apatheme2

png("Figure_B9.png", width = 839, height = 490)
print(Figure_B9)
dev.off()

rm(list=ls())

# Figure B10 ---------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight_imm_comp.xlsx")

# Attribute values 
councilors$Proximity <- factor(councilors$Proximity)
councilors$Publicgoods <- factor(councilors$Publicgoods)
councilors$Size <- factor(councilors$Size)
councilors$Type <- factor(councilors$Type)
councilors$Runby <- factor(councilors$Runby)
councilors$munic_res <- factor(councilors$munic_res)
dv_binary <- factor(councilors$dv_binary)
councilors$ResponseId <- c(councilors$ResponseId)

attr(councilors$Runby, "label") <- "Run by"
attr(councilors$Publicgoods, "label") <- "Publicgoods"

# Reorder variables 
councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
                                  c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# Immigrants per population
councilors$Imm_Pop <- councilors$Immigrants/councilors$popthous
summary(unique(councilors$Imm_Pop)) 
councilors$Imm_Pop_wna <- councilors$Imm_Pop
summary(councilors$Imm_Pop_wna)
councilors$Imm_Pop_wna[is.na(councilors$Imm_Pop_wna)] <- 0 
summary(councilors$Imm_Pop_wna)

# high vs small number of immigrants per thousands of residents 
# municipalities with zero immigrants - No exposure
# municipalities with lower than the average - Low exposure
# municipalities with equar or higher than the average - High exposure

# summary(unique(citizens$Imm_Pop)) 

councilors <- councilors %>% mutate(imm_exp = case_when (Imm_Pop_wna == 0 ~ "No Exposure",
                                                         Imm_Pop_wna < 55.796 ~ "Low Exposure",
                                                         Imm_Pop_wna >= 55.796 ~ "High Exposure"))
councilors$imm_exp <- factor(councilors$imm_exp, levels = c("No Exposure", "Low Exposure", "High Exposure"))

cj_counc <-cj(councilors, out, id = ~ResponseId, by = ~imm_exp, estimate = "mm")

# Figure B10
imm_exp_counc <- plot(cj_counc, group = "imm_exp", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(color=NULL)

Figure_B10 <- imm_exp_counc+apatheme2

png("Figure_B10.png", width = 839, height = 490)
print(Figure_B10)
dev.off()

rm(list=ls())

# Figure B11 --------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)


# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# Proximity to camp (reported camp existence)
citizens$proximity <- as.numeric(citizens$proximity)

citizens$proximity_to_camp[citizens$proximity==1]<-"No Camp"
citizens$proximity_to_camp[citizens$proximity!=1]<-"All other answers"

citizens$proximity_to_camp <- factor(citizens$proximity_to_camp, levels = c("No Camp", "All other answers"))

cj_citiz5 <-cj(citizens, out, id = ~ResponseId, by = ~proximity_to_camp, estimate = "mm")

# Figure B11
camp_citiz5 <- plot(cj_citiz5, group = "proximity_to_camp", vline = 0.5, xlim = c(0.3 , 0.7), size=1.5)

Figure_B11 <- camp_citiz5 + apatheme2

png("Figure_B11.png", width = 839, height = 490)
print(Figure_B11)
dev.off()

rm(list=ls())

# Figure B12 --------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight.xlsx")

# Attribute values 
councilors$Proximity <- factor(councilors$Proximity)
councilors$Publicgoods <- factor(councilors$Publicgoods)
councilors$Size <- factor(councilors$Size)
councilors$Type <- factor(councilors$Type)
councilors$Runby <- factor(councilors$Runby)
councilors$munic_res <- factor(councilors$munic_res)
dv_binary <- factor(councilors$dv_binary)
councilors$ResponseId <- c(councilors$ResponseId)

attr(councilors$Runby, "label") <- "Run by"
attr(councilors$Publicgoods, "label") <- "Publicgoods"

# Reorder variables 
councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
                                  c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby


# Proximity to camp (reported camp existence)
councilors$proximity <- as.numeric(councilors$proximity)

councilors$proximity_to_camp[councilors$proximity==1]<-"No Camp"
councilors$proximity_to_camp[councilors$proximity!=1]<-"All other answers"

councilors$proximity_to_camp <- factor(councilors$proximity_to_camp, levels = c("No Camp", "All other answers"))

cj_counc5 <-cj(councilors, out, id = ~ResponseId, by = ~proximity_to_camp, estimate = "mm")

# Figure B12
camp_counc5 <- plot(cj_counc5, group = "proximity_to_camp", vline = 0.5, xlim = c(0.3 , 0.7), size=1.5)

Figure_B12 <- camp_counc5 + apatheme2

png("Figure_B12.png", width = 839, height = 490)
print(Figure_B12)
dev.off()

rm(list=ls())

# Figure B13 --------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis_imm_new.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby


# Proximity to camp
citizens$proximity <- as.numeric(citizens$proximity)

citizens$proximity_to_camp2[citizens$proximity==1]<-"No Camp"
citizens$proximity_to_camp2[citizens$proximity==2 | citizens$proximity==3]<-"Far" 
citizens$proximity_to_camp2[citizens$proximity==4 | citizens$proximity==5]<-"Near" 

citizens$proximity_to_camp2 <- factor(citizens$proximity_to_camp2, levels = c("No Camp", "Near", "Far"))

cj_citiz6 <-cj(citizens, out, id = ~ResponseId, by = ~proximity_to_camp2, estimate = "mm")

# Figure B13
camp_citiz6 <- plot(cj_citiz6, group = "proximity_to_camp2", vline = 0.5, xlim = c(0.3 , 0.7), size=1.5)

Figure_B13 <- camp_citiz6 + apatheme2

png("Figure_B13.png", width = 839, height = 490)
print(Figure_B13)
dev.off()

rm(list=ls())

# Figure B14 --------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data
councilors <- read.xlsx("Appendix/Data for Appendix/councilors_profiledata_withDV2_PCA_weight_imm_comp.xlsx")

# Attribute values 
councilors$Proximity <- factor(councilors$Proximity)
councilors$Publicgoods <- factor(councilors$Publicgoods)
councilors$Size <- factor(councilors$Size)
councilors$Type <- factor(councilors$Type)
councilors$Runby <- factor(councilors$Runby)
councilors$munic_res <- factor(councilors$munic_res)
dv_binary <- factor(councilors$dv_binary)
councilors$ResponseId <- c(councilors$ResponseId)

attr(councilors$Runby, "label") <- "Run by"
attr(councilors$Publicgoods, "label") <- "Publicgoods"

# Reorder variables 
councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
                                  c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Regression
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# Proximity to camp
councilors$proximity <- as.numeric(councilors$proximity)

councilors$proximity_to_camp2[councilors$proximity==1]<-"No Camp"
councilors$proximity_to_camp2[councilors$proximity==2 | councilors$proximity==3]<-"Far" 
councilors$proximity_to_camp2[councilors$proximity==4 | councilors$proximity==5]<-"Near" 


councilors$proximity_to_camp2 <- factor(councilors$proximity_to_camp2, levels = c("No Camp", "Near", "Far"))

cj_counc6 <-cj(councilors, out, id = ~ResponseId, by = ~proximity_to_camp2, estimate = "mm")

# Figure B14
camp_counc6 <- plot(cj_counc6, group = "proximity_to_camp2", vline = 0.5, xlim = c(0.3 , 0.7), size=1.5)

Figure_B14 <- camp_counc6 + apatheme2

png("Figure_B14.png", width = 839, height = 490)
print(Figure_B14)
dev.off()

rm(list=ls())

# Figure B15 --------------------------------------------------------------
# Load packages
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(gridExtra)        # for grid graphics (used behind the scenes in themes, not explicitly called here)


# Read data 
citizens<-read.xlsx("Appendix/Data for Appendix/citizens_profile_no_missing_data_analysis_imm_new.xlsx")

# Attribute values
citizens$Proximity <- factor(citizens$Proximity)
citizens$Size <- factor(citizens$Size)
citizens$Type <- factor(citizens$Type)
citizens$Runby <- factor(citizens$Runby)
citizens$Publicgoods <- factor(citizens$Publicgoods)
citizens$munic_res <- factor(citizens$munic_res)

dv_binary <- factor(citizens$dv_binary)
citizens$ResponseId <- c(citizens$ResponseId)

attr(citizens$Runby, "label") <- "Run by"
attr(citizens$Publicgoods, "label") <- "Public goods"

# Reorder variables 
citizens$Size <- factor(citizens$Size, levels =
                          c("Less than 1% of population","1% of local population", "More than 1% of population"), 
                        labels = c("< 1% of local population", "1% of local population", "> 1 % of local population"))

citizens$Proximity <- factor(citizens$Proximity , levels =
                               c("In the centre", "30-minute walk or less from the center", "More than 30-minute walk from the centre "),
                             labels = c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))

citizens$Type <- factor(citizens$Type, levels =
                          c("Fully Open (site residents have unrestricted mobility) ", "Partially open (site residents must check in and out before leaving)", "Closed (exit allowed by permission of authorities only for a specified amount of time)"),
                        labels = c("Fully open", "Partially open", "Closed"))

citizens$Publicgoods <-factor(citizens$Publicgoods, levels = 
                                c("Hire more teachers and doctors", "More infrastructure to the municipality", "Hire more municipal employees"))

# Apatheme 
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# no camp, camp, ric + political ideology 
ideology <- as.numeric(citizens$Q16_1)
summary(ideology)
citizens <- citizens %>% mutate(Reported_Ideology = case_when(ideology >= 5  ~ 'Right',
                                                              ideology < 5  ~ 'Left'))
citizens$Reported_Ideology <- factor(citizens$Reported_Ideology, levels = c('Left', 'Right'))

citizens$popthous <- citizens$Population/1000
citizens$Imm_Pop <- citizens$Immigrants/citizens$popthous
summary(unique(citizens$Imm_Pop)) 
summary(citizens$Imm_Pop)
citizens$Imm_Pop_wna <- citizens$Imm_Pop
summary(citizens$Imm_Pop_wna)
citizens$Imm_Pop_wna[is.na(citizens$Imm_Pop_wna)] <- 0 
summary(citizens$Imm_Pop_wna)

citizens <- citizens %>% mutate(imm_exp3 = case_when (Imm_Pop_wna == 0 ~ "No Camp",
                                                      Q26_residence_2=="Mytilinis" ~ "RIC",
                                                      Q26_residence_2=="Anatolikis Samou" ~ "RIC",
                                                      Q26_residence_2=="Lerou" ~ "RIC",
                                                      Q26_residence_2=="Chiou" ~ "RIC",
                                                      Q26_residence_2=="Ko" ~ "RIC",
                                                      Q26_residence_2=="Orestiadas" ~ "RIC",
                                                      Imm_Pop_wna != 0 & Q26_residence_2!="Mytilinis"| 
                                                        Imm_Pop_wna != 0 & Q26_residence_2!="Anatolikis Samou"|
                                                        Imm_Pop_wna != 0 & Q26_residence_2!="Lerou"|
                                                        Imm_Pop_wna != 0 & Q26_residence_2!="Chiou"|
                                                        Imm_Pop_wna != 0 & Q26_residence_2!="Ko"|
                                                        Imm_Pop_wna != 0 & Q26_residence_2!="Orestiadas" ~ "Camp"))

citizens$imm_exp3 <- factor(citizens$imm_exp3, levels = c("No Camp", "Camp", "RIC"))
citizens_nocamp <- subset(citizens, imm_exp3=="No Camp")
citizens_camp <- subset(citizens, imm_exp3=="Camp")
citizens_ric <- subset(citizens, imm_exp3=="RIC")

# Regression
ideology_out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby

# No camp
cj_citiz_nocamp <-cj(citizens_nocamp, ideology_out, id = ~ResponseId, by = ~Reported_Ideology, estimate = "mm")

ideol_citiz_nocamp <- plot(cj_citiz_nocamp, group = "Reported_Ideology", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(color=NULL)

ideol_citiz_nocamp <- ideol_citiz_nocamp+apatheme2

# Camp
cj_citiz_camp <-cj(citizens_camp, ideology_out, id = ~ResponseId, by = ~Reported_Ideology, estimate = "mm")

ideol_citiz_camp <- plot(cj_citiz_camp, group = "Reported_Ideology", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(color=NULL)

ideol_citiz_camp <- ideol_citiz_camp+apatheme2

# Ric 
cj_citiz_ric <-cj(citizens_ric, ideology_out, id = ~ResponseId, by = ~Reported_Ideology, estimate = "mm")

ideol_citiz_ric <- plot(cj_citiz_ric, group = "Reported_Ideology", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(color=NULL)

ideol_citiz_ric <- ideol_citiz_ric+apatheme2

# change aesthetics 

ideol_citiz_nocamp <- plot(cj_citiz_nocamp, group = "Reported_Ideology", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(title="No Camp")
ideol_citiz_nocamp <- ideol_citiz_nocamp+apatheme2

ideol_citiz_camp <- plot(cj_citiz_camp, group = "Reported_Ideology", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(title="Camp")
ideol_citiz_camp <- ideol_citiz_camp+apatheme2

ideol_citiz_ric <- plot(cj_citiz_ric, group = "Reported_Ideology", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(title="RIC")
ideol_citiz_ric <- ideol_citiz_ric+apatheme2

ggsave("Figure_B15.png", width = 17, height = 13, arrangeGrob(ideol_citiz_nocamp, ideol_citiz_camp, ideol_citiz_ric, ncol=2))

rm(list=ls())

