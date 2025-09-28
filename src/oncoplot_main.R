library(ComplexHeatmap)
library(RColorBrewer)

##### Require #####
#ptc_meta_summary ; dataframe
#ptc_df_onco_ready: dataframe
#anno_oncoprint_barplot : function

##### Output directory #####
# output_dir = paste0(getwd(),"/out/9-24-25/")

alter_fun_custom = list(
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
  LB = function(x, y, w, h)
    grid.rect(x, y - 0.4 * h, w * 0.9, h * 0.1, gp = gpar(
      fill = "lightgreen", col = NA
    )),
  # dots
  INS = function(x, y, w, h)
    grid.points(x, y, pch = 16),
  SNV = function(x, y, w, h)
    grid.segments(x - w * 0.4, y, x + w * 0.4, y, gp = gpar(lwd = 2)),
  SUB = function(x, y, w, h)
    grid.segments(x, y - h * 0.4, x, y + h * 0.4, gp = gpar(lwd = 2)),
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
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(fill = NA))
)

# test_alter_fun(alter_fun)
# dev.off()

##### Define colors #####

# Metadata colors for columns
meta_col_top <- list(
  Subtypes = c(
    "FA" = "#E31A1C",
    "FTC" = "#FDBF6F",
    "NIFTP" = "#FF7F00",
    "PTC" = "#CAB2D6",
    "PTCplusTHY" = "#6A3D9A",
    "THY" = "#FFFF99"
  )
)

meta_col_bottom = list(
  Sex = c("F" = "salmon", "M" = "steelblue1"),
  Age_at_diagnosis = circlize::colorRamp2(c(
    min(ptc_meta_summary$Age_at_diagnosis, na.rm = TRUE),
    max(ptc_meta_summary$Age_at_diagnosis, na.rm = TRUE)
  ), c("white", "darkmagenta")),
  Batch = c(
    "1" = "cyan",
    "2" = "magenta",
    "3" = "darkgreen"
  ),
  Pathology_Subtype = c(
    "NA" = "black",
    "PTC conventional variant" = "#9E9AC8",
    "PTC conventional variant and papillary microcarcinoma" = "#807DBA",
    "PTC diffuse sclerosing variant" = "#6A51A3",
    "PTC follicular variant" = "#3F007D",
    "PTC oncocytic variant" =  "#54278F",
    "FTC minimally invasive" = "#FD8D3C"
  ),
  Nodule1_FNA_Result = c(
    "NA" = "black",
    "Undertermined" = "#EFD5DF",
    "Benign" = "#DFACBF",
    "Follicular_lesion_or_neoplasm" = "#CF829F",
    "Malignant" =  "#BF597F",
    "Suspicious_for_malignancy" =  "#B03060"
  ),
  Autoimmune_Thyroiditis = c(
    "NA" = "black",
    "Yes" = "red",
    "No" = "mistyrose"
  ),
  History_of_Radiation_to_Neck = c(
    "NA" = "black",
    "Yes" = "red",
    "No" = "mistyrose"
  ),
  History_of_Previous_Cancer = c(
    "NA" = "black",
    "Yes" = "red",
    "No" = "mistyrose"
  ),
  Received_RAI = c(
    "NA" = "black",
    "Yes" = "red",
    "No" = "mistyrose"
  ),
  Additional_Surgery = c(
    "NA" = "black",
    "Yes" = "red",
    "No" = "mistyrose"
  ),
  Race = c(
    "NA" = "black",
    "White_Caucasian" = "moccasin",
    "Black_or_African_American" = "saddlebrown",
    "Asian" = "rosybrown"
  ),
  TI_RADS_Score = c(
    "NA" = "black",
    "2" = "lightpink",
    "3" = "hotpink",
    "4" = "deeppink",
    "5" = "darkmagenta"
  ),
  Type_of_Thyroid_Surgery = c(
    "NA" = "black",
    "Subtotal thyroidectomy" =  "#62A881",
    "Hemi thyroidectomy" = "#CAE2D5" ,
    "Hemi thyroidectomy and Isthmusectomy" = "#96C4AB",
    "Total thyroidectomy" = "#2E8B57"
  ),
  Primary_Tumor = c(
    "NA" = "black",
    "0" = "white",
    "T1b" = "mediumturquoise",
    "T2" = "darkturquoise",
    "T3" = "darkcyan",
    "T4a" = "darkslategray"
  ),
  Lymph_Nodes = c(
    "NA" = "black",
    "0" = "white",
    "N0" = "#EDE0C2",
    "N1a" = "#DBC285" ,
    "N1b" = "#C9A448",
    "NX" = "#B8860B"
  ),
  Distant_Metastases = c(
    "NA" = "black",
    "0" = "white",
    "M0" = "#D29494",
    "M1" = "#BB5F5F",
    "MX" = "#A52A2A"
  ),
  Largest_Nodule_Dimension = circlize::colorRamp2(c(
    min(ptc_meta_summary$Largest_Nodule_Dimension, na.rm = TRUE),
    max(ptc_meta_summary$Largest_Nodule_Dimension, na.rm = TRUE)
  ), c("white", "#D9691E")),
  ATA_Pediatric_Risk_Level = c(
    "NA" = "black",
    "High risk" = "#FF0000",
    "Intermediate risk" = "#FF8C00",
    "Low risk" = "#3CB371"
  )
)

#### Font label size #####
font_label_ann <- 7.5

##### Top annotation ####
top_df <- ptc_meta_summary[, "Subtypes"]

top_ann <- HeatmapAnnotation(
  df = top_df,
  col = meta_col_top,
  annotation_legend_param = list(
    title_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
    labels_gp = gpar(fontsize = font_label_ann)
  ),
  annotation_name_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
  annotation_name_side = "right",
  # annotation_height = unit(10, "mm"),
  annotation_height = unit(0.15, "in"),
  show_annotation_name = TRUE,
  show_legend = FALSE,
  #gp = gpar(size = 15),
  simple_anno_size_adjust = TRUE,
  annotation_label = colnames(top_df)
)

##### Test Top Annotation #####
#draw(top_ann)
#dev.off()


##### Bottom Annotation #####
bottom_df <- as.data.frame(ptc_meta_summary[, -c(1, 4)])
bottom_df$Pathology_Subtype <- gsub("_", " ", bottom_df$Pathology_Subtype)
bottom_df$Type_of_Thyroid_Surgery <- gsub("_", " ", bottom_df$Type_of_Thyroid_Surgery)

bottom_ann <- HeatmapAnnotation(
  df = bottom_df,
  col = meta_col_bottom,
  annotation_legend_param = list(
    direction = "horizontal",
    title_gp = gpar(fontsize = font_label_ann +
                      1, fontface = "bold"),
    labels_gp = gpar(fontsize = font_label_ann),
    legend_width  = unit(2, "cm"),
    word_wrap = TRUE
  ),
  annotation_name_gp = gpar(fontsize = font_label_ann +
                              1, fontface = "bold"),
  #annotation_label = gpar(fontsize = 8),
  annotation_name_side = "right",
  #height = unit(2, "mm"),
  annotation_height = unit(3.5, "in"),
  # annotation_height = unit(0.1, "mm"),
  show_annotation_name = TRUE,
  show_legend = TRUE,
  #gp = gpar(size = 15),
  # gap = unit(1, "points"),
  na_col = "black",
  simple_anno_size_adjust = TRUE,
  annotation_label = colnames(bottom_df)
)

##### Test Bottom Annotation #####
#draw(bottom_ann)
#dev.off()

colnames(ptc_df_onco_ready) <- gsub("P_", "", colnames(ptc_df_onco_ready))
######### Start png media. Choose from pdf, png, svg, etc. #####
file_name <- paste0(output_dir,
                    "oncoplot",
                    "_",
                    format(Sys.time(), "%b_%e_%Y"),
                    ".png")

png(
  file_name,
  width = 10.5,
  height = 24,
  units = "in",
  res = 400
  #pointsize = 12, #bg = "white"
)


######### Create Oncoplot ############
ptc_oncoprint <- oncoPrint(
  mat = ptc_df_onco_ready,
  alter_fun = alter_fun_custom,
  col = c(
    P = "#CD1076",
    LP = "#E9967A",
    VUS = "#808000",
    LB = "lightgreen"
  ),
  show_column_names = TRUE,
  show_row_names = TRUE,
  #  height = unit(10, "in"),
  heatmap_legend_param =  list(
    title = "Alterations",
    at = c(
      "P",
      "LP",
      "VUS",
      "LB",
      "INS",
      "SNV",
      "SUB",
      "DEL",
      "Tumor",
      "Normal"
    ),
    # , "LB" These match the names of the mutations defined in alter_fun
    labels = c(
      "Pathogenic",
      "Likely Pathogenic",
      "VUS",
      "Likely Benign",
      "Insertion",
      "SNV",
      "Substitution",
      "Deletion",
      "Tumor",
      "Normal"
    ),
    # , "Likely Benign"
    title_gp = gpar(fontsize = font_label_ann +
                      1, fontface = "bold"),
    labels_gp = gpar(fontsize = font_label_ann) # , "#C9A448"
  ),
  #alter_fun_is_vectorized = FALSE,
  column_order = colnames(ptc_df_onco_ready),
  column_split = factor(
    ptc_meta_summary$Subtypes,
    c("THY", "PTC", "PTCplusTHY", "FTC", "NIFTP", "FA")
  ),
  column_title_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
  column_names_gp = gpar(fontsize = font_label_ann +
                           1, fontface = "bold"),
  row_names_gp = gpar(fontsize = font_label_ann +
                        1, fontface = "bold"),
  right_annotation = c(
    rowAnnotation(row_barplot = anno_oncoprint_barplot())#,
    # rowAnnotation(
    #   boxplot = anno_multiple_boxplot,
    #   width = unit(4, "cm"),
    #   show_annotation_name = FALSE
    # )
  ),
  bottom_annotation = bottom_ann,
  top_annotation = c(top_ann, HeatmapAnnotation(cbar = anno_oncoprint_barplot()))
)

##### Create Oncoprint Legend for metadata ####
lgd = Legend(
  labels = c("Tumor", "Normal"),
  title = "Phenotype",
  legend_gp = gpar(fill = c("grey40", "grey90")),
  title_gp = gpar(fontsize = font_label_ann + 1, fontface = "bold"),
  labels_gp = gpar(fontsize = font_label_ann)
)

###### Combine oncoplot and legend ########
ptc_oncoprint_draw <- draw(
  ptc_oncoprint,
  heatmap_legend_list = lgd,
  merge_legend = TRUE,
  legend_gap = unit(0.75, "cm")
)

##### Print ####
ptc_oncoprint_draw
dev.off()

####### Create oncoprint list object ######

ptc_onco_obj_list <- list(
  mat = ptc_df_onco_ready,
  alter_fun = alter_fun_custom,
  params = list(
    col = c(
      P = "#CD1076",
      LP = "#E9967A",
      VUS = "#808000",
      LB = "lightgreen"
    ),
    show_column_names = TRUE,
    show_row_names = TRUE,
    heatmap_legend_param =  list(
      title = "Alterations",
      at = c(
        "P",
        "LP",
        "VUS",
        "LB",
        "INS",
        "SNV",
        "SUB",
        "DEL",
        "Tumor",
        "Normal"
      ),
      # , "LB" These match the names of the mutations defined in alter_fun
      labels = c(
        "Pathogenic",
        "Likely Pathogenic",
        "VUS",
        "Likely Benign",
        "Insertion",
        "SNV",
        "Substitution",
        "Deletion",
        "Tumor",
        "Normal"
      ),
      # , "Likely Benign"
      title_gp = gpar(fontsize = font_label_ann +
                        1, fontface = "bold"),
      labels_gp = gpar(fontsize = font_label_ann) # , "#C9A448"
    ),
    alter_fun_is_vectorized = FALSE,
    column_order = colnames(ptc_df_onco_ready),
    column_split = factor(
      ptc_meta_summary$Subtypes,
      c("THY", "PTC", "PTCplusTHY", "FTC", "NIFTP", "FA")
    ),
    column_title_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
    column_names_gp = gpar(fontsize = font_label_ann +
                             1, fontface = "bold"),
    row_names_gp = gpar(fontsize = font_label_ann +
                          1, fontface = "bold"),
    right_annotation = c(
      rowAnnotation(row_barplot = anno_oncoprint_barplot())#,
      # rowAnnotation(
      #   boxplot = anno_multiple_boxplot,
      #   width = unit(4, "cm"),
      #   show_annotation_name = FALSE
      # )
    ),
    bottom_annotation = bottom_ann,
    top_annotation = c(top_ann, HeatmapAnnotation(cbar = anno_oncoprint_barplot()))
  ),
  lgd = lgd
)



####### Save Oncoplot Object #######
saveRDS(ptc_onco_obj_list,
        paste0(output_dir, "ptc_onco_obj_list_", Sys.Date(), ".rds"))

######## Test Interactive Shiny component for oncoplot ########
# library(InteractiveComplexHeatmap)
# htShiny(ht,
#         width1 = 1685,
#         height1 = 1800,
#         width2 = 750,
#         height2 = 950)
