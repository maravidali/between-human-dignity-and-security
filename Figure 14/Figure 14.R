#### Figure 14 ####

# Load packages -----------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(readstata13)

# Read data ---------------------------------------------------------------
citizens_compen <- read.dta13("Figure 14/citizen_level_immigr_compens_2.dta")

# Select the variables used -----------------------------------------------
threats_cit <- select(citizens_compen, children_edu2, same_hospital2, resource_threat, job_threat, terror_threat,
                      riot_threat, crime_threat, turkey_threat, religion_threat, 
                      tradition_threat, color_threat, language_threat, right, intensity_exp2)

# Steps to create the confidence intervals --------------------------------
# Rename the variable children_edu2 to children_edu, same_hospital2 to same_hospital
threats_cit <- threats_cit %>%
  rename(children_edu = children_edu2, same_hospital = same_hospital2)

# Step 1: Reshape the dataset to long format
threats_long <- threats_cit %>%
  pivot_longer(
    cols = -c(right, intensity_exp2), # Keep `intensity_exp2` and `right` fixed, reshape others
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

# Step 3: Create the combined group variable with specific levels
threats_long <- threats_long %>%
  mutate(
    group = case_when(
      right == 0 & intensity_exp2 == 1 ~ "Left-wing | No camp",
      right == 1 & intensity_exp2 == 1 ~ "Right-wing | No camp",
      right == 0 & intensity_exp2 == 2 ~ "Left-wing | Camp",
      right == 1 & intensity_exp2 == 2 ~ "Right-wing | Camp",
      right == 0 & intensity_exp2 == 3 ~ "Left-wing | RIC",
      right == 1 & intensity_exp2 == 3 ~ "Right-wing | RIC"
    ),
    # Explicitly set the levels for group
    group = factor(group, levels = c(
      "Left-wing | No camp",
      "Right-wing | No camp",
      "Left-wing | Camp",
      "Right-wing | Camp",
      "Left-wing | RIC",
      "Right-wing | RIC"
    ))
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


# Figure 14 ---------------------------------------------------------
# Step 5: Create the plot
Figure14 <- ggplot(summary_data, aes(x = variable, y = mean, color = group)) +
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
      "Left-wing | No camp" = "yellow",
      "Right-wing | No camp" = "green",
      "Left-wing | Camp" = "pink",
      "Right-wing | Camp" = "skyblue",
      "Left-wing | RIC" = "red",
      "Right-wing | RIC" = "blue"
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
  filename = "Figure_14.png", # Specify filename
  plot = Figure14,          # Specify the plot object
  width = 10,               # Width of the output file in inches
  height = 6,               # Height of the output file in inches
  dpi = 300                 # Resolution of the output file in dots per inch
)


rm(list=ls())