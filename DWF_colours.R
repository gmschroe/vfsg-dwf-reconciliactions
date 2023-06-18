# colours for DWF vis

#c('#ede6c6', '#dccfaa', '#cbb990', '#bba376', '#ac8d5e', '#9d7747', '#8e6131')

#c('#f5ddad', '#e3c796','#d2b281', '#c19d6c', '#b08957', '#9f7544', '#8e6131')

#c('#c5d5d4', '#b2c4c5', '#9fb4b6', '#8da4a8', '#7b949a', '#6a848c', '#5a747f')

#c('#c6d3d4', '#afbfc2', '#98abb0', '#82979f', '#6e838e', '#5b707e', '#495d6e')

#c('#dce9e9', '#c1d9da', '#a7cacb' ,'#8cbabd', '#70abaf', '#529ba2', '#2e8c95')

#c('#efe4c4', '#decea9', '#cdb78f', '#bda176', '#ad8c5e', '#9e7647', '#8e6131')

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