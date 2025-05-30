#### Figure 9 ####

# Load packages -----------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(readstata13)

# Read data ---------------------------------------------------------------
cps <- read.dta13("Figure 9/CPS_combined.dta")


# Select the variables used -----------------------------------------------

threats <- select(cps, children_edu2, same_hospital2, resource_threat, job_threat, terror_threat,
                  riot_threat, crime_threat, turkey_threat, religion_threat, 
                  tradition_threat, color_threat, language_threat, councilor)


# Steps to create the confidence intervals --------------------------------
# Rename the variable children_edu2 to children_edu, same_hospital2 to same_hospital
threats <- threats %>%
  rename(children_edu = children_edu2, same_hospital = same_hospital2)

# Step 1: Reshape the dataset to long format
threats_long <- threats %>%
  pivot_longer(
    cols = -c(councilor), # All columns except 'councilor'
    names_to = "variable",
    values_to = "value"
  )

# Step 2: Set the variable order to match the original order in `threats`
threats_long <- threats_long %>%
  mutate(
    variable = factor(variable, levels = c(
      "children_edu", "same_hospital", "resource_threat", "job_threat", "terror_threat",
      "riot_threat", "crime_threat", "turkey_threat", "religion_threat", 
      "tradition_threat", "color_threat", "language_threat"
    ))
  )

# Step 3: Calculate means and confidence intervals
summary_data <- threats_long %>%
  group_by(councilor, variable) %>%
  summarise(
    mean = mean(value, na.rm = TRUE),
    se = sd(value, na.rm = TRUE) / sqrt(n()), # Standard Error
    .groups = "drop"
  ) %>%
  mutate(
    lower_ci = mean - 1.96 * se, # Lower bound of 95% CI
    upper_ci = mean + 1.96 * se  # Upper bound of 95% CI
  )

# Step 4: Update councilor labels
summary_data$councilor <- ifelse(summary_data$councilor == 0, "Citizens", "Councilors")

# Figure 9 ---------------------------------------------------------

# Step 5: Create the plot
Figure9 <- ggplot(summary_data, aes(x = variable, y = mean, color = councilor)) +
  geom_point(position = position_dodge(width = 0.5), size = 1.5) +
  geom_errorbar(aes(ymin = lower_ci, ymax = upper_ci),
                position = position_dodge(width = 0.5),
                width = 0.3) +
  labs(
    title = "",
    x = "",
    y = "Average values"
  ) +
  scale_color_manual(values = c("Citizens" = "black", "Councilors" = "orange")) +
  scale_y_continuous(breaks = seq(1, 5, by = 1)) + # Set y-axis breaks from 1 to 5
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 12), # Adjust x-axis font size
    axis.text.y = element_text(size = 12), # Reduce y-axis font size
    axis.title.x = element_text(size = 12), # Increase x-axis title font size
    axis.title.y = element_text(size = 12), # Increase y-axis title font size
    legend.text = element_text(size = 12), # Increase group legend font size
    panel.grid.major.x = element_blank(), # Remove vertical gridlines
    panel.grid.major.y = element_line(color = "gray", linetype = "dashed"), # Horizontal gridlines only
    panel.grid.minor = element_blank(), # Remove minor gridlines
    panel.border = element_blank(), # Remove panel border
    axis.line = element_line(color = "black"), # Add axis lines
    legend.title = element_blank(), # Remove "color" from legend
    panel.background = element_rect(fill = "white", color = NA), # White panel background
    plot.background = element_rect(fill = "white", color = NA)   # White plot background
  )

# Step 6: Export the plot as PNG
ggsave("Figure_9.png", plot = Figure9, width = 10, height = 6, dpi = 300)

rm(list=ls())

