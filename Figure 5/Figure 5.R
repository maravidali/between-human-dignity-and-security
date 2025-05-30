#### Figure 5 ####

# Load packages -----------------------------------------------------------
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(grid)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data ---------------------------------------------------------------
citizens<-read.xlsx("Figure 5/citizens_profile_no_missing_data_analysis.xlsx")

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
        text=element_text(family='Helvetica'),
        axis.text=element_text(size=13),
        axis.title=element_text(size=13),
        legend.text = element_text(size = 13),
        legend.title = element_blank())


# Define ideology ---------------------------------------------------------

ideology <- as.numeric(citizens$Q16_1)
summary(ideology)
citizens <- citizens %>% mutate(Reported_Ideology = case_when(ideology >= 5  ~ 'Right',
                                                              ideology < 5  ~ 'Left'))
citizens$Reported_Ideology <- factor(citizens$Reported_Ideology, levels = c('Left', 'Right'))


# Figure 5 ----------------------------------------------------------------
citizens$type_runby <- interaction(citizens$Type, citizens$Runby, sep="_")

Figure_5 <- plot(cj(citizens, dv_binary~ type_runby, id = ~ResponseId, by=~Reported_Ideology, estimate = "mm"), group="Reported_Ideology", vline = 0.5, size=1.5)
Figure_5 <- Figure_5 + apatheme2
png("Figure_5.png", width = 839, height = 490)
print(Figure_5)
dev.off()

rm(list=ls())
