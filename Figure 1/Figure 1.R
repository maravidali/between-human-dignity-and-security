#### Figure 1 ####

# Load packages -----------------------------------------------------------
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(grid)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data ---------------------------------------------------------------
citizens<-read.xlsx("Figure 1/citizens_profile_no_missing_data_analysis.xlsx")

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

# Figure 1 ---------------------------------------------------------
aggr_out <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby
plot(mm(citizens, aggr_out, id = ~ResponseId), vline = 0.5)

aggr_mm<- mm(citizens, dv_binary ~ Proximity + Publicgoods + Size+ Type + Runby,
             id = ~ ResponseId)
Figure_1 <- plot(aggr_mm, feature_headers = FALSE, vline = 0.5) +
  ggplot2::facet_wrap(~feature, ncol = 1L,
                      scales = "free_y", strip.position = "right")+geom_point(size=1.5)

Figure_1 <- Figure_1 + apatheme2
png("Figure_1.png", width = 839, height =490)
print(Figure_1)
dev.off()

rm(list=ls())