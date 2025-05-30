#### Figure 2 ####

# Load packages -----------------------------------------------------------
library(cregg)       # for mm() and plot() functions used to estimate and plot marginal means
library(ggplot2)     # for additional ggplot tweaks like facet_wrap and geom_point
library(dplyr)       # often used for data manipulation (indirectly useful here)
library(openxlsx)    # to read the Excel file (.xlsx)
library(grid)        # for grid graphics (used behind the scenes in themes, not explicitly called here)

# Read data ---------------------------------------------------------------
councilors <- read.xlsx("Figure 2/councilors_profiledata_withDV2_PCA_weight.xlsx")

# Attribute values --------------------------------------------------------

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

# Reorder variables -------------------------------------------------------

councilors$Size <- factor(councilors$Size, levels =
                            c("< 1% of local population","1% of local population", "> 1% of local population"))
councilors$Proximity <- factor(councilors$Proximity, levels =
                                 c("In ctr", "< 30mins from ctr", "> 30mins from ctr"))
councilors$Type <- factor(councilors$Type, levels =
                            c("Fully open", "Partially open", "Closed"))
councilors$Publicgoods <-factor(councilors$Publicgoods, levels = 
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

# Figure 2 ------------------------------------------------------------------

aggr_out_councilors <- dv_binary ~ Proximity + Publicgoods + Size+ Type + Run_by
plot(mm(councilors, aggr_out_councilors, id = ~ResponseId), vline = 0.5)

aggr_mm_councilors <- mm(councilors, dv_binary ~ Proximity + Publicgoods + Size+ Type + Run_by,
         id = ~ ResponseId)

Figure_2 <- plot(aggr_mm_councilors, feature_headers = FALSE, vline = 0.5) +
  ggplot2::facet_wrap(~feature, ncol = 1L,
                      scales = "free_y", strip.position = "right")+geom_point(size=1.5)

Figure_2 <- Figure_2 + apatheme2
png("Figure_2.png", width = 839, height = 490)
print(Figure_2)
dev.off()

rm(list=ls())
