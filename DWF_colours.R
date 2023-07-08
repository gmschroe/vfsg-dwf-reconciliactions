# colours for DWF vis

# colours for each stage ----
# pulled from Secret Path palette (https://www.youtube.com/watch?v=yGd764YU9yc)

#clr_stage1 <- c('#c6d3d4', '#a3b5b9', '#82979f', '#647986', '#495d6e')
clr_stage1 <- c('#c1d4e8', '#a0b4cd', '#8194b3', '#647699', '#49587f')
clr_stage2 <- c('#dce9e9', '#b4d1d2', '#8cbabd', '#62a3a8', '#2e8c95')
clr_stage3 <- c('#efe4c4', '#d5c39c', '#bda176', '#a58152', '#8e6131')

# all stages, all colours
clr_stages_full <- list(clr_stage1, clr_stage2, clr_stage3)

# main colours for each stage (light, medium, and dark)
idx <- 5
clr_stages_dark <- c(clr_stage1[idx], clr_stage2[idx], clr_stage3[idx])
idx <- 3
clr_stages_med <- c(clr_stage1[idx], clr_stage2[idx], clr_stage3[idx])
idx <- 1
clr_stages_light <- c(clr_stage1[idx], clr_stage2[idx], clr_stage3[idx])
rm(list = c('idx'))


# brand colours ----
clr_b_purple <- c('#4F2874')
clr_b_charcoal <- c('#3A3939')
clr_b_light_purple <- c('#D4CEDC')
clr_b_light_grey <- c('#E5E5E5')
clr_c_white <- c('#FFFFFF')

#steps as brand colours
clr_steps_purple <- c(
  '#d4cedc',
  '#b1a3c2',
  '#8f79a8',
  '#6f508e',
  '#4f2874'
)

clr_grey_shades <- c(
  '#e5e5e5',
  '#cacaca',
  '#b0b0b0',
  '#979696',
  '#7e7e7e',
  '#676666',
  '#504f4f',
  '#3a3939'
)