# Code from Art from Code by Danielle Navarro 
# https://art-from-code.netlify.app/day-1/session-3/
# licensed under a Creative Commons Attribution 4.0 International License:
# https://creativecommons.org/licenses/by/4.0/
# https://github.com/rstudio-conf-2022/art-from-code/blob/main/LICENSE.md

edge_length <- function(x1, y1, x2, y2) {
  sqrt((x1 - x2)^2 + (y1 - y2)^2)
}

edge_noise <- function(size) {
  runif(1, min = -size/2, max = size/2)
}

# added by GMS for gaussian noise option
edge_noise_norm <- function(size) {
  rnorm(1, 0, size)
}

sample_edge_l <- function(polygon) {
  sample(length(polygon), 1, prob = map_dbl(polygon, ~ .x$seg_len))
}

# GMS added noise type option
insert_edge_l <- function(polygon, noise, noise_type = 'uniform') {
  
  ind <- sample_edge_l(polygon)
  len <- polygon[[ind]]$seg_len
  
  last_x <- polygon[[ind]]$x
  last_y <- polygon[[ind]]$y
  
  next_x <- polygon[[ind + 1]]$x
  next_y <- polygon[[ind + 1]]$y
  
  if (noise_type == 'uniform') {
    new_x <- (last_x + next_x) / 2 + edge_noise(len * noise)
    new_y <- (last_y + next_y) / 2 + edge_noise(len * noise)
  } else if (noise_type == 'normal') {
    new_x <- (last_x + next_x) / 2 + edge_noise_norm(len * noise)
    new_y <- (last_y + next_y) / 2 + edge_noise_norm(len * noise)
  }
  new_point <- list(
    x = new_x,
    y = new_y,
    seg_len = edge_length(new_x, new_y, next_x, next_y)
  )
  
  polygon[[ind]]$seg_len <- edge_length(
    last_x, last_y, new_x, new_y
  )
  
  c(
    polygon[1:ind],
    list(new_point),
    polygon[-(1:ind)]
  )
}

# GMS added option to change type of noise
grow_polygon_l <- function(polygon, iterations, noise, 
                           seed = NULL, noise_type = 'uniform') {
  if(!is.null(seed)) set.seed(seed)
  for(i in 1:iterations) polygon <- insert_edge_l(polygon, noise, noise_type)
  return(polygon)
}

grow_multipolygon_l <- function(base_shape, n, seed = NULL, ...) {
  if(!is.null(seed)) set.seed(seed)
  polygons <- list()
  for(i in 1:n) {
    polygons[[i]] <- grow_polygon_l(base_shape, ...) |>
      transpose() |>
      as_tibble() |>
      mutate(across(.fn = unlist))
  }
  polygons <- bind_rows(polygons, .id = "id")
  polygons
}

show_multipolygon <- function(polygon, fill, alpha = .02, ...) {
  ggplot(polygon, aes(x, y, group = id)) +
    geom_polygon(colour = NA, alpha = alpha, fill = fill, ...) + 
    coord_equal() + 
    theme_void()
}

# Code by GMS -----

make_rail_rectangle <- function(h, w, x_shift = 0, y_shift = 0) {
  tibble(
    x = c(0, w, w, 0, 0) + x_shift,
    y = c(0, 0, h, h, 0) + y_shift,
    seg_len = c(w, h, h, w, 0))
}

# adapted from "smudged_hexagon"
# use base shape after grow_polygon_l as input
smudged_rail <- function(
    poly_l, 
    seed, 
    noise1 = 1.75, 
    noise2 = 0.25,
    n_base = 3,
    n = 10
) {
  
  set.seed(seed)
  
  # define intermediate-base-shapes in clusters
  polygons <- list()
  ijk <- 0
  for(i in 1:n_base) {
    base_i <- poly_l |> 
      grow_polygon_l(
        iterations = 50, 
        noise = noise1
      )
    
    for(j in 1:3) {
      base_j <- base_i |> 
        grow_polygon_l(
          iterations = 50, 
          noise = noise1
        )
      
      # grow 10 polygons per intermediate-base
      for(k in 1:n) {
        ijk <- ijk + 1
        polygons[[ijk]] <- base_j |>
          grow_polygon_l(
            iterations = 1000, 
            noise = noise2,
            noise_type = 'normal'
          ) |>
          transpose() |>
          as_tibble() |>
          mutate(across(.fn = unlist))
      }
    }
  }
  
  # return as data frame
  bind_rows(polygons, .id = "id")
}