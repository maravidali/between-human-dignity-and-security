#### Figure 10 ####

# Load packages -----------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(readstata13)

# Read data ---------------------------------------------------------------
cps <- read.dta13("Figure 10/CPS_combined.dta")

# Select the variables used -----------------------------------------------
threats_right <- select(cps, children_edu2, same_hospital2, resource_threat, job_threat, terror_threat,
                        riot_threat, crime_threat, turkey_threat, religion_threat, 
                        tradition_threat, color_threat, language_threat, councilor, right)

# Steps to create the confidence intervals --------------------------------
# Rename the variables
threats_right <- threats_right %>%
  rename(children_edu = children_edu2, same_hospital = same_hospital2)

# Step 1: Reshape the dataset to long format
threats_long <- threats_right %>%
  pivot_longer(
    cols = -c(councilor, right), # Keep `councilor` and `right` fixed, reshape others
    names_to = "variable",
    values_to = "value"
  )

# Step 2: Set the variable order to match the original order in `threats_right`
threats_long <- threats_long %>%
  mutate(
    variable = factor(variable, levels = c(
      "children_edu", "same_hospital", "resource_threat", "job_threat", "terror_threat",
      "riot_threat", "crime_threat", "turkey_threat", "religion_threat",
      "tradition_threat", "color_threat", "language_threat"
    ))
  )

# Step 3: Create the combined group variable
threats_long <- threats_long %>%
  mutate(
    group = case_when(
      councilor == 1 & right == 1 ~ "Right councilors",
      councilor == 1 & right == 0 ~ "Left councilors",
      councilor == 0 & right == 1 ~ "Right citizens",
      councilor == 0 & right == 0 ~ "Left citizens"
    )
  )

# Step 4: Calculate means and confidence intervals
summary_data <- threats_long %>%
  group_by(group, variable) %>%
  summarise(
    mean = mean(value, na.rm = TRUE),
    se = sd(value, na.rm = TRUE) / sqrt(n()), # Standard Error
    lower_ci = mean - 1.96 * se, # Lower bound of 95% CI
    upper_ci = mean + 1.96 * se, # Upper bound of 95% CI
    .groups = "drop"
  )

# Figure 10 ---------------------------------------------------------
# Step 5: Create the plot
Figure10 <- ggplot(summary_data, aes(x = variable, y = mean, color = group)) +
  geom_point(position = position_dodge(width = 0.5), size = 1.3) +
  geom_errorbar(aes(ymin = lower_ci, ymax = upper_ci),
                position = position_dodge(width = 0.5),
                width = 0.3) +
  labs(
    title = "",
    subtitle = "",
    x = "",
    y = "Average values",
    caption = ""
  ) +
  scale_color_manual(
    values = c(
      "Right councilors" = "darkblue",
      "Left councilors" = "darkred",
      "Right citizens" = "lightblue",
      "Left citizens" = "red"
    )
  ) +
  scale_y_continuous(breaks = seq(1, 5, by = 1)) + # Set y-axis breaks from 1 to 5
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 12), # Adjust x-axis label font size
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

# Step 6: Save the plot
ggsave(
  filename = "Figure_10.png", # Specify filename
  plot = Figure10,          # Specify the plot object
  width = 10,               # Width of the output file in inches
  height = 6,               # Height of the output file in inches
  dpi = 300                 # Resolution of the output file in dots per inch
)

rm(list=ls())
