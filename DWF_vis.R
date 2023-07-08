# libraries ----
rm(list = ls())

library(tidyverse)
library(readxl)
library(janitor)
library(patchwork)
library(geomtextpath)
library(packcircles)
library(ggbeeswarm)

# functions
source('DWF_lib.R')

# colours
path_clrs <- 'DWF_colours.R'
source(path_clrs)

# lyrics
source('DWF_lyrics.R')

# load reconcilACTIONS data ----

actions_data_path <- file.path('data', 'ReconciliACTIONS_table.xlsx')
actions_data <- load_reconciliactions(actions_data_path)

# find negative values
actions_data |>
  select('quarter_labels', 'segment', 'count_of_participants') |>
  filter(count_of_participants < 0)

# negatives --> zero
actions_data <- actions_data |>
  mutate(
    count_of_participants = case_when(
      count_of_participants < 0 ~ 0,
      TRUE ~ count_of_participants
    )
  )
#View(actions_data)

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
# segment metric source combinations
actions_data |>
  distinct(metric, segment, source) |>
  arrange(metric, segment)

actions_data |>
  distinct(source)

# total number of actions in each stage ----
actions_data |>
  group_by(stage) |>
  summarise(n_actions = sum(count_of_participants))

# total number of actions in each step ----
actions_data |>
  group_by(steps) |>
  summarise(n_actions = sum(count_of_participants))

# n actions in each step, by quarter ----

steps_p <- plot_dwf_steps(actions_data, path_clrs)

steps_p[[1]] / steps_p[[2]] / steps_p[[3]] / steps_p[[4]] / steps_p[[5]] 

plot_dir <- 'r_plot_exports'
fname <- file.path(plot_dir, 'steps_by_quarter.pdf')
ggsave(fname, width = 8.5, height = 20, units = "cm", device = 'pdf')

# n actions in each stage, by quarter ----

stage_p <- plot_dwf_stage(actions_data, path_clrs)

stage_p[[1]] / stage_p[[2]] / stage_p[[3]] 

fname <- file.path(plot_dir, 'stage_by_quarter.pdf')
ggsave(fname, width = 8.5, height = 20, units = "cm", device = 'pdf')

# bubble chart - number of actions, steps/stage x quarter ----

stage_gap <- 1 # size of gap to add between stages

# number of actions by step, stage, and quarter
steps_by_stage_data <- actions_data |>
  mutate(
    steps_and_stage_num_gaps = steps_and_stage_num + (stage_gap * stage)
  ) |>
  group_by(quarter_labels, steps_and_stage_num, steps_and_stage_num_gaps) |>
  summarise(n_actions = sum(count_of_participants))

# steps by stage colours
ss_plot <- as.numeric(levels(factor(steps_by_stage_data$steps_and_stage_num)))
ss_clr <- c(clr_stage1, clr_stage2, clr_stage3)
ss_clr <- ss_clr[ss_plot]

# horizontal line for each step/stage row
ss_lines <- c()
n_steps <- 5
for (i in 1:3) ss_lines <- c(ss_lines, ((1:n_steps) + (n_steps * (i-1)) + (stage_gap * i)))

# concatenate together lyrics
n_lines <- 2
lyrics_pasted <- c()
for (i in 1:floor(length(lyrics)/n_lines)) {
  lyrics_pasted <- c(
    lyrics_pasted, 
    paste(lyrics[(1 + (n_lines * (i - 1))):(n_lines * i)], collapse = " - ")
  )
}

# lines for rail sleepers
rail_offset <- 0.175 
ss_lines_offset <- rep(ss_lines, each = 2)
n_ss_lines <- length(ss_lines_offset)
ss_lines_offset[seq(1, n_ss_lines, by = 2)] = ss_lines_offset[seq(1, n_ss_lines, by = 2)] - rail_offset
ss_lines_offset[seq(2, n_ss_lines, by = 2)] = ss_lines_offset[seq(2, n_ss_lines, by = 2)] + rail_offset

# circle settings
size_scale <- c(0.01, 10)
log_base <- 10

# plot
p <- ggplot(
  steps_by_stage_data, 
  aes(y = steps_and_stage_num_gaps, x = quarter_labels, 
      size = log(n_actions + 1, log_base), colour = factor(steps_and_stage_num))
) +
  geom_point(alpha = 0.8, shape = 16) +
  scale_size(range = size_scale) + 
  scale_y_reverse(breaks = c(), expand = c(0.1, 0.1)) +
  dwf_line_theme_minimal(path_clrs) +
  scale_colour_manual(values = ss_clr) +
  scale_x_discrete(breaks = c(), expand = c(0.4, 0.4)) +
  labs(y = '', x = '') +
  
  # vertical lines
  geom_vline(xintercept = c(-0.5, -0.25, nrow(quarter_names) + 1.25, nrow(quarter_names) + 1.5),
             colour = clr_b_charcoal, alpha = 0.2, linewidth = 0.2) +
  # legend
  geom_point(
    data = tibble(
      pt_sizes = c(10, 1000, 100000),
      x = c(1, 3, 5),
      y = rep(13,length(pt_sizes))
    ),
    mapping = aes(x, y, size = log(pt_sizes + 1, log_base)),
    colour = clr_b_charcoal, inherit.aes = FALSE,
    shape = 1, alpha = 0.5)

# add lyrics
for (i in 1:n_ss_lines) {
  p <- p + annotate("text", x = 4.5, y = ss_lines_offset[i], 
                          label = lyrics_pasted[i], inherit.aes = FALSE,
                          size = 2.5, #alpha = 0.2, fontface = 'italic',
                          colour = clr_b_charcoal, hjust = 0.5)
}

p  

fname <- file.path(plot_dir, 'railway_steps_and_stages_v2.pdf')
ggsave(fname, width = 8.5, height = 20, units = "cm", device = 'pdf')


# types of reconciliACTIONs (coloured by stage and step) ----

# seed for for jitter to mix actions from different stages/steps
set.seed(4)

# tibble of different types of reconciliACTIONs (organised by metric/segment) 
types_of_actions <- actions_data |>
  # collapse all newsletter subscribers into one category
  mutate(
    segment = case_when(
      segment == 'Change in Mailable Newsletter subscribers' ~ 'Change in Newsletter subscribers',
      TRUE ~ segment
    )
  ) |>
  group_by(steps_and_stage_num, steps, stage, metric, segment) |>
  summarise(n_actions = sum(count_of_participants)) |>
  unite('metric_label',c('steps', 'metric', 'segment', 'n_actions'), remove = FALSE, sep = ' - ') |>
  # add jitter to steps and stage number
   mutate(
     steps_and_stage_num_jittered = steps_and_stage_num + rnorm(length(stage), 0, 1),
     group = 1,
     # radius for circles (area will be proportional to number of actions)
     r = sqrt((n_actions+1)/pi)
     )
types_of_actions$id <- 1:nrow(types_of_actions)

# used tutorial to make beeswarm with size variable: 
# https://aryntoombs.github.io/tutorials/beeswarm.html

# start with basic beeswarm 
beeswarm_without_size <- ggplot(
  data = types_of_actions, 
  mapping = aes(y=steps_and_stage_num_jittered*10, x=group)) + # x10 because need to increase spacing to prevent final version from being circular
  geom_beeswarm(size = 1, cex = 3)

oldbee_chart_data <- ggplot_build(beeswarm_without_size)
newbee_frame <- tibble(
  x = oldbee_chart_data$data[[1]]$x,
  y = oldbee_chart_data$data[[1]]$y,
  r = types_of_actions$r
)

# use beeswarm data in circle packing layout functions
newbee_repel <- circleRepelLayout(newbee_frame, wrap=FALSE)
newbee_repel_out <- circleLayoutVertices(newbee_repel$layout, 
                                         xysizecols = 1:3, sizetype = 'radius',
                                         npoints = 150)

# add data about each action to layout tibble (for circle colours)
id_data <- types_of_actions |>
  ungroup() |>
  select(c('steps_and_stage_num','metric_label','id','steps','n_actions'))
newbee_repel_out <- left_join(newbee_repel_out,
                              id_data,
                              by = 'id', multiple = 'all')

# label top two of each step
newbee_text <- newbee_repel_out |>
  group_by(metric_label, steps, steps_and_stage_num) |>
  summarise(x = mean(x), y = mean(y), n_actions = mean(n_actions)) |>
  group_by(steps) |>
  arrange(steps, desc(n_actions)) |>
  top_n(2)

# plot
ggplot(
  newbee_repel_out, 
  aes(x, y, group = id, fill = factor(steps_and_stage_num))) +
  geom_polygon() +
  coord_equal() +
  scale_fill_manual(values = ss_clr) +
  scale_y_reverse() +
  scale_x_continuous(expand = c(2, 2)) +
  theme_void() +
  # labels
  geom_text(
    data = newbee_text, 
    aes(x = x, y = y, label = metric_label), 
    inherit.aes = FALSE, size = 2, hjust = 0) +
  theme(legend.position = 'none')
  
fname <- file.path(plot_dir, 'beeswarm_actions.pdf')
ggsave(fname, width = 30, height = 30, units = "cm", device = 'pdf')
