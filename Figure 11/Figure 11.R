#### Figure 11 ####

# Load packages -----------------------------------------------------------
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(grid)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data ---------------------------------------------------------------
citizens<-read.xlsx("Figure 11/citizens_profile_no_missing_data_analysis_imm_new.xlsx")

# Attribute values --------------------------------------------------------
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

# Reorder variables -------------------------------------------------------
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

# Apatheme ----------------------------------------------------------------
apatheme2=theme_bw()+
  theme(panel.grid.major=element_blank(),
        axis.line=element_line(),
        text=element_text(),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())

# Immigrants per population -----------------------------------------------

citizens$Imm_Pop <- citizens$Immigrants/citizens$popthous
summary(unique(citizens$Imm_Pop)) 
summary(citizens$Imm_Pop)
citizens$Imm_Pop_wna <- citizens$Imm_Pop
summary(citizens$Imm_Pop_wna)
citizens$Imm_Pop_wna[is.na(citizens$Imm_Pop_wna)] <- 0 
summary(citizens$Imm_Pop_wna)

# no camp, camp ric -----------------------------------------------------------

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


# Figure 11 ---------------------------------------------------------------
out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby
cj_citiz3 <-cj(citizens, out, id = ~ResponseId, by = ~imm_exp3, estimate = "mm")

Figure_11 <- plot(cj_citiz3, group = "imm_exp3", vline = 0.5, xlim = c(0.1 , 0.8), feature_headers = TRUE, size=1.5) + labs(color=NULL)

Figure_11 <- Figure_11+apatheme2

png("Figure_11.png", width = 839, height = 490)
print(Figure_11)
dev.off()

rm(list=ls())
