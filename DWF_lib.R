# Functions for analysing and visualising DWF reconciliACTIONs data

# load and clean reconcilACTIONs data from excel file at actions_path
load_reconciliactions <- function(actions_path) {
  
  # load excel file
  actions_data <- read_xlsx(actions_data_path, sheet = 1) |>
    # clean names
    clean_names() |>
    rename(
      states = associated_future_states_numbered_seperated_by,
      steps_states_weight = steps_x_future_state_weight) |>
    # factors
    mutate(
      steps = factor(steps, levels = c('Following', 'Endorsing', 'Contributing', 'Owning', 'Leading')),
      department = factor(department),
      quarter_year = factor(quarter_year),
      metric = factor(metric),
      segment = factor(segment),
      source = factor(source)
    ) |>
    # add stage (based on states) 
    mutate(
      stage = ceiling(states/2),
    ) |>
    # alternate quarter labels
    mutate(
      quarter_labels = str_replace(quarter_year, 'FY 21/22', 'Y1'),
      quarter_labels = str_replace(quarter_labels, 'FY 22/23', 'Y2')
    ) |>
    # map steps onto numbers for easy reference; add steps and stage number
    mutate(steps_number = 
             case_when(
               steps == 'Following' ~ 1,
               steps == 'Endorsing' ~ 2,
               steps == 'Contributing' ~ 3,
               steps == 'Owning' ~ 4, 
               steps == 'Leading' ~ 5
             ),
           steps_and_stage_num = steps_number + (5 * (stage - 1))
    ) |>
    # separate quarter and year columns
    separate(quarter_labels, sep = ' ', remove = FALSE, into = c('year','quarter'))


  # cleaning 
  # segment: Confrences --> Conferences
  # segment: Maliable --> Mailable (part of string)
  # only include financial years 21/22 and 22/23 
  # (only two observations for 23/24, so will focus on first two complete financial years)
  
  actions_data <- actions_data |>
    mutate(segment = 
             case_when(
               
               # segment: Confrences --> Conferences
               segment %in% c('Confrences', 'Conferences') ~ 'Conferences',
               
               # segment: Maliable --> Mailable (part of string)
               segment == 'Change in Maliable Newsletter subscribers' ~
                 'Change in Mailable Newsletter subscribers',
               
               TRUE ~ segment
             )
    ) |>
    # remove FY 23/24 data
    filter(quarter_year != 'FY 23/24 Q1')
  
  return(actions_data)
}

# minimal theme for line and bar charts
dwf_line_theme_minimal <- function(path_clrs) {
  source(path_clrs)
  
  theme_minimal() +
    theme(
      panel.grid.major.x = element_blank(), 
      panel.grid.minor.y = element_blank(),
      panel.grid.major.y = element_line(colour = clr_grey_shades[6]),
      axis.ticks.x = element_line(colour = clr_grey_shades[6]),
      legend.position = 'none',
      text = element_text(colour = clr_grey_shades[6]),
      axis.text = element_text(colour = clr_grey_shades[6], size = 10),
      panel.grid = element_blank(),
      panel.background = element_blank()
    )
}

# plot steps (bar graph)
plot_dwf_steps <- function(actions_data, path_clrs) {
  
  # get colours
  source(path_clrs)
  
  # group actions by steps
  steps_data <- actions_data |>
    group_by(quarter_labels, steps_number) |>
    summarise(
      n_actions = sum(count_of_participants),
      n_actions_weighted = sum(total_participants_by_weight)
    )
  
  # list of step numbers
  steps_num <- unique(actions_data$steps_number)
  n_steps <- length(steps_num)
  
  # plot each steps data individually (more control over individual plots) ----
  p <- list()
  for (plot_step in 1:n_steps) {
    p[[plot_step]] <- ggplot(
      steps_data |> filter(steps_number == plot_step), 
      aes(x = quarter_labels, y = n_actions)) +
      geom_col(colour = NA, fill = clr_steps_purple[plot_step]) +
      dwf_line_theme_minimal(path_clrs) +
      labs(x = '', y = 'reconciliACTIONS') 
    
    p[[plot_step]] <- expand_y_breaks(p[[plot_step]])
  }
  
  return(p)
}

# plot stages (bar graph)
plot_dwf_stage <- function(actions_data, path_clrs) {
  
  # get colours
  source(path_clrs)
  
  # group actions by stages
  stage_data <- actions_data |>
    group_by(quarter_labels, stage) |>
    summarise(
      n_actions = sum(count_of_participants)
    ) 
  
  # list of stage numbers
  stage_num <- unique(actions_data$stage)
  n_stage <- length(stage_num)
  
  # plot each stages data individually (more control over individual plots) ----
  p <- list()
  for (plot_stage in 1:n_stage) {
    p[[plot_stage]] <- ggplot(
      stage_data |> filter(stage == plot_stage), 
      aes(x = quarter_labels, y = n_actions)) +
      geom_col(colour = NA, fill = clr_stages_med[plot_stage]) +
      dwf_line_theme_minimal(path_clrs) +
      labs(x = '', y = 'reconciliACTIONS') 
    
    p[[plot_stage]] <- expand_y_breaks(p[[plot_stage]], y_buff = 1.02)
  }
  
  return(p)
}

# scale y axis based on y breaks
expand_y_breaks <- function(p, y_min = 0, y_buff = 1.05) {
  # get max y
  max_y = max(layer_data(p)$y, na.rm=TRUE) * y_buff
  
  # get breaks interval
  p_breaks <- as.numeric(na.omit(layer_scales(p)$y$break_positions()))
  breaks_step <- p_breaks[2] - p_breaks[1]
  
  # last break
  max_break <- ceiling((max_y/breaks_step)*breaks_step)
  
  # change breaks
  p <- p + scale_y_continuous(breaks = seq(0, max_break + breaks_step, by = breaks_step)) +
    expand_limits(y = c(y_min, max_break + breaks_step))
  return(p)
}
