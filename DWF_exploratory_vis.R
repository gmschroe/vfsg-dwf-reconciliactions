# exploratory vis of DWF dataset
# experimenting with vis for final report

# libraries ----
rm(list = ls())

library(tidyverse)
library(readxl)
library(janitor)
library(patchwork)

source('DWF_lib.R')
path_clrs <- 'DWF_colours.R'
source(path_clrs)

# load reconcilACTIONS data ----

actions_data_path <- file.path('data', 'ReconciliACTIONS_table.xlsx')
actions_data <- load_reconciliactions(actions_data_path)

View(actions_data)

# find negative values
actions_data |>
  select('quarter_labels', 'segment', 'count_of_participants') |>
  filter(count_of_participants < 0)

# version with only positive numbers (negatives --> zero)
actions_data_pos <- actions_data |>
  mutate(
    count_of_participants = case_when(
      count_of_participants < 0 ~ 0,
      TRUE ~ count_of_participants
      )
  )
#View(actions_data_pos)

# print distinct values of key variables ----

# steps, states, and stages
actions_data |> 
  distinct(steps, steps_weight, states, stage) |>
  arrange(stage, steps_weight, states)

# quarters
quarter_names <- actions_data |> 
  distinct(quarter_labels) |>
  arrange(quarter_labels)
quarter_names

# metrics and associated steps
actions_data |>
  distinct(metric, steps)

# segment
# segment metric combinations
segment_data <- actions_data |>
  distinct(metric, segment, source) |>
  arrange(metric, segment)
#View(segment_data)

actions_data |>
  distinct(source)

# step, segment, metric categories
segment_names <- unique(actions_data$segment)
metric_names <- unique(actions_data$metric)
steps_names <- unique(actions_data$steps)

# histogram of number of participants for each action ----

ggplot(actions_data, aes(x = count_of_participants)) +
  geom_histogram()

# stage actions, by quarter ----

# number of actions in each stage, by quarter
stage_data <- actions_data |>
  group_by(quarter_labels, stage) |>
  summarise(
    n_actions = sum(count_of_participants),
    n_actions_weighted = sum(total_participants_by_weight)
  ) 


ggplot(stage_data, 
       aes(x = quarter_labels, y = n_actions, group = stage, colour = factor(stage))) +
  geom_line(linewidth = 1.5) +
  scale_colour_manual(values = clr_stages_med) +
  facet_wrap(~stage, nrow = 3, scales = 'free') +
  theme_bw()

# number of actions each quarter by step ----
steps_data <- actions_data_pos |>
  group_by(quarter_labels, steps_number) |>
  summarise(
    n_actions = sum(count_of_participants),
    n_actions_weighted = sum(total_participants_by_weight)
  )

ggplot(steps_data, 
       aes(x = quarter_labels, y = n_actions, group = steps_number, colour = factor(steps_number))) +
  geom_line(linewidth = 1.5) +
  scale_colour_manual(values = clr_steps_purple) +
  facet_wrap(~steps_number, nrow = 5, scales = 'free') +
  theme(
    panel.background = element_blank(),
  )

# plot each steps data individually (more control over individual plots) ----
# can put together with patchwork

steps_num <- 1
ggplot(
  steps_data |> filter(steps_number == steps_num), 
  aes(x = quarter_labels, y = n_actions, group = steps_number)) +
  geom_line(linewidth = 1.5, colour = clr_steps_purple[steps_num]) +
  dwf_line_theme_minimal(path_clrs)

# all steps ----
steps_p <- plot_dwf_steps(actions_data_pos, path_clrs)

steps_p[[1]] / steps_p[[2]] / steps_p[[3]] / steps_p[[4]] / steps_p[[5]] 
# number of actions each quarter by step and stage ----
steps_and_stage_data <- actions_data_pos |>
  group_by(quarter_labels, steps, stage) |>
  summarise(
    n_actions = sum(count_of_participants),
    n_actions_weighted = sum(total_participants_by_weight)
  )

ggplot(steps_and_stage_data, 
       aes(x = quarter_labels, y = n_actions, group = steps, colour = factor(steps))) +
  geom_line(linewidth = 1.5) +
  scale_colour_manual(values = c(clr_stage1)) +
  facet_grid(steps ~ stage, scales = 'free_y') +
  theme_bw()

# bubble chart - number of actions, steps/stage x quarter ----
steps_by_stage_data <- actions_data_pos |>
  group_by(quarter_labels, steps_and_stage_num) |>
  summarise(n_actions = sum(count_of_participants))

ss_plot <- as.numeric(levels(factor(steps_by_stage_data$steps_and_stage_num)))
ss_clr <- c(clr_stage1, clr_stage2, clr_stage3)
ss_clr <- ss_clr[ss_plot]

ggplot(
  steps_by_stage_data, 
  aes(y = steps_and_stage_num, x = quarter_labels, 
      size = log10(n_actions + 1), colour = factor(steps_and_stage_num))
  ) +
  geom_point(alpha = 0.8) +
  scale_size(range = c(0.01, 10)) +
  scale_y_reverse() +
  dwf_line_theme_minimal(path_clrs) +
  scale_colour_manual(values = ss_clr)
       
# stacked bar of steps that contribute to each stage ----
step_stage_sum_data <- actions_data |>
  group_by(stage, steps_and_stage_num, steps) |>
  summarise(n_actions = sum(count_of_participants))

ggplot(data = step_stage_sum_data,
       aes(x = stage, y = n_actions, fill = factor(steps_and_stage_num))
) + 
  geom_col(colour = clr_b_charcoal, position = 'fill') +
  scale_fill_manual(values = ss_clr) +
  dwf_line_theme_minimal(path_clrs)

# stacked bar by year - steps that contribute to each stage ----

step_and_stage_sum_data <- actions_data |>
  group_by(stage, steps_and_stage_num, steps, year) |>
  summarise(n_actions = sum(count_of_participants)) 

# horizontal version
ggplot(
  step_and_stage_sum_data, 
  aes(x = year, y = n_actions, fill = factor(steps_and_stage_num))
) +
  geom_col(colour = clr_b_charcoal) +
  scale_fill_manual(values = ss_clr) +
  dwf_line_theme_minimal(path_clrs) +
  facet_wrap(~stage, nrow = 3, scales = 'free') +
  coord_flip() +
  scale_x_discrete(
    limits = rev(levels(factor(step_and_stage_sum_data$year)))
    )

# vertical, percentage version ----
ggplot(
  step_and_stage_sum_data, 
  aes(x = year, y = n_actions, fill = factor(steps_and_stage_num))
) +
  geom_col(colour = clr_b_charcoal, position = 'fill') +
  scale_fill_manual(values = ss_clr) +
  dwf_line_theme_minimal(path_clrs) +
  facet_wrap(~stage, nrow = 1, scales = 'free')

# percentage of each step that contribute to each stage ----
step_and_stage_sum_data <- actions_data |>
  group_by(stage, steps_and_stage_num, steps) |>
  summarise(n_actions = sum(count_of_participants)) 

ggplot(
  step_and_stage_sum_data,
  aes(x = steps, y = n_actions, fill = factor(stage))
) +
  geom_col(colour = clr_b_charcoal, position = 'fill') +
  dwf_line_theme_minimal(path_clrs) +
  scale_fill_manual(values = clr_stages_med) +
  coord_flip() + 
  scale_x_discrete(
    limits = rev(levels(factor(step_and_stage_sum_data$steps)))
  ) +
  labs(y = 'percentage of actions in each stage')
