# generative art for #dosomething tracking template ----

rm(list = ls())
library(tidyverse)

source('art_functions.R') # art functions

# example rectangles ---

# make rectangle
rect_h <- 1
rect_w <- 5

rect_small_border_h <- 0.1
rect_small_border_w <- 0.1
rect_small_h <- rect_h - rect_small_border_h * 2
rect_small_w <- rect_w - rect_small_border_w * 2

rect <- make_rail_rectangle(h = rect_h, w = rect_w)
rect_small <- make_rail_rectangle(
  h = rect_small_h, 
  w = rect_small_w,
  x_shift = (rect_w - rect_small_w)/2,
  y_shift = (rect_h - rect_small_h)/2
)

ggplot() +
  geom_polygon(data = rect, mapping = aes(x, y), 
               colour = "black", fill = NA, show.legend = FALSE) + 
  geom_polygon(data =rect_small, mapping = aes(x, y), 
               colour = 'red', fill = NA, show.legend = FALSE) +
  coord_equal() + 
  theme_void() 

# watercolour rectangles (slow to run!) ---

n_step <- 5
rect_seeds <- c(0, 13, 10, 60, 61)

all_steps_dat <- tibble()
all_steps_dat_small <- tibble()

step_gap <- -2

clrs_step <- c('#8f79a8',
'#826b9c',
'#765d90',
'#694f84',
'#5d4178')

for (i in 1:n_step) {
  # large rectangle
  rect_l <- transpose(make_rail_rectangle(h = rect_h, w = rect_w, y_shift = i * rect_h * step_gap))
  
  # small rectangle
  rect_small_l <- transpose(make_rail_rectangle(
    h = rect_small_h, 
    w = rect_small_w,
    x_shift = (rect_w - rect_small_w)/2,
    y_shift = (i * rect_h * step_gap) + (rect_h - rect_small_h)/2 
  ))
  
  # generate large rectangle data 
  dat <- rect_l |>
    grow_polygon_l(
      iterations = 100, 
      noise = .15, 
      seed = rect_seeds[i]
    ) |> 
    smudged_rail(seed = 1, n = 20, noise1 = 2) 
    #grow_multipolygon_l(n = 50, iterations = 250, noise = 0.25, seed = 0, noise_type = 'normal')
  dat <- dat |> 
    mutate(step_num = i)
  all_steps_dat <- bind_rows(all_steps_dat, dat)
  
  # generate small rectangle data
  dat_small <- rect_small_l |>
    grow_polygon_l(
      iterations = 100, 
      noise = .15, 
      seed = rect_seeds[i]
    ) |> 
    smudged_rail(seed = 2, n = 2, noise1 = 2, n_base = 4)
    #grow_multipolygon_l(n = 25, iterations = 250, noise = 0.25, seed = 0, noise_type = 'normal')
  dat_small <- dat_small |> 
    mutate(step_num = i)
  all_steps_dat_small <- bind_rows(all_steps_dat_small, dat_small)
}

n_id <- max(as.numeric(all_steps_dat$id))
all_steps_dat <- all_steps_dat |>
  mutate(id = as.numeric(id) + n_id * (step_num) - 1)

# ----

ggplot(all_steps_dat, aes(x, y, group = id, fill = factor(step_num))) +
  geom_polygon(alpha = 0.07, show.legend = FALSE) + 
  theme_void() + 
  scale_fill_manual(values = clrs_step) +
  coord_equal() +
  geom_polygon(data = all_steps_dat_small,
               aes(x, y, group = id),
               alpha = 0.07, fill = 'white', inherit.aes = FALSE
    ) +
  scale_y_continuous(limits = c(-1 * n_step * (abs(step_gap) + rect_h), 1)) +
  scale_x_continuous(limits = c(-1, rect_w + 1))

plot_dir <- 'r_plot_exports'
fname <- file.path(plot_dir, paste0('do_something_steps', '.pdf'))
ggsave(fname, width = 8.5, height = 20, units = "cm", device = 'pdf')

