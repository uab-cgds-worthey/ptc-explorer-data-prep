library(ComplexHeatmap)
library(RColorBrewer)

alter_fun = list(
  background = function(x, y, w, h)
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(fill = "#CCCCCC", col = NA)),
  # red rectangles
  P = function(x, y, w, h)
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(fill = "#CD1076", col = NA)),
  
  LP = function(x, y, w, h) {
    grid.polygon(
      unit.c(x - 0.4 * w, x - 0.4 * w, x + 0.4 * w),
      unit.c(y - 0.4 * h, y + 0.4 * h, y - 0.4 * h),
      gp = gpar(fill = "#E9967A", col = "white")
    )
  },
  
  VUS = function(x, y, w, h) {
    grid.polygon(
      unit.c(x + 0.4 * w, x - 0.4 * w, x - 0.4 * w),
      unit.c(y + 0.4 * h, y + 0.4 * h, y - 0.4 * h),
      gp = gpar(fill = "#808000", col = "white")
    )
  },
  
  # VUS = function(x, y, w, h){
  # # define the coordinates of the top-left rectangle
  # grid.polygon(
  #   unit.c(x - (0.9*w)/2, x, x, x - (0.9*w)/2),
  #   unit.c(y, y, y + (0.9*h)/2, y + (0.9*h)/2),
  #   gp = gpar(fill = "#808000", col = NA)
  # )},
  
  # VUS = function(x, y, w, h)
  #   grid.rect(x, y, w*0.9, h*0.9, gp = gpar(fill = "#808000", col = NA)),
  
  LB = function(x, y, w, h)
    grid.rect(x, y - 0.4 * h, w * 0.9, h * 0.1, gp = gpar(
      fill = "lightgreen", col = NA
    )),
  
  # dots
  INS = function(x, y, w, h)
    grid.points(x, y, pch = 16),
  
  # SNV = function(x, y, w, h)
  #   grid.segments(x - w*0.4, y - h*0.4, x + w*0.4, y + h*0.4, gp = gpar(lwd = 2)),
  SNV = function(x, y, w, h)
    grid.segments(x - w * 0.4, y, x + w * 0.4, y, gp = gpar(lwd = 2)),
  
  SUB = function(x, y, w, h)
    grid.segments(x, y - h * 0.4, x, y + h * 0.4, gp = gpar(lwd = 2)),
  
  # crossed lines
  DEL = function(x, y, w, h) {
    grid.segments(x - w * 0.4, y - h * 0.4, x + w * 0.4, y + h * 0.4, gp = gpar(lwd = 2))
    grid.segments(x + w * 0.4, y - h * 0.4, x - w * 0.4, y + h * 0.4, gp = gpar(lwd = 2))
  },
  Normal = function(x, y, w, h)
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(
      fill = NA,
      lwd = 2,
      col = "blue"
    )),
  Tumor = function(x, y, w, h)
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(
      fill = NA
      #lwd = 2,
      # , col = "darkgreen"
    ))
)
test_alter_fun(alter_fun)
dev.off()
