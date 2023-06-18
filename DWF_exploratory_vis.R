# libraries ----
rm(list = ls())

library(tidyverse)
library(readxl)
library(janitor)

# load reconcilACTIONS data ----

actions_data_path <- file.path('data', 'ReconciliACTIONS_table.xlsx')

actions_data <- read_xlsx(actions_data_path, sheet = 1) |>
  # clean names
  clean_names() |>
  rename(
    states = associated_future_states_numbered_seperated_by,
    steps_states_weight = steps_x_future_state_weight) |>
  # factors
  mutate(
    steps = factor(steps),
    department = factor(department),
    quarter_year = factor(quarter_year),
    metric = factor(metric),
    segment = factor(segment),
    source = factor(source)
  ) |>
  # add stage (based on states)
  mutate(
    stage = ceiling(states/2)
  )

show(actions_data)

# print distinct values of key variables ----

# steps, states, and stages
actions_data |> 
  distinct(steps, steps_weight, states, stage) |>
  arrange(stage, steps_weight, states)

# quarters
actions_data |> 
  distinct(quarter_year) |>
  arrange(quarter_year)

# metrics and associated steps
actions_data |>
  distinct(metric, steps)

# segment
actions_data |>
  distinct(metric, segment) |>
  arrange(metric)

actions_data |>
  distinct(source)

# ----

ggplot(actions_data, aes(x = total_participants_by_weight)) +
  geom_histogram()
