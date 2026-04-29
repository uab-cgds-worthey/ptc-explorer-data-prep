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
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(fill = "#D9D9D9", col = NA)),
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
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(fill = NA)),
  Lesion = function(x, y, w, h)
    grid.rect(x, y, w * 0.9, h * 0.9, gp = gpar(
      fill = NA,
      lwd = 2,
      col = "#C96A1B"
    ))
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
    "PTC conventional variant\nand papillary microcarcinoma" = "#807DBA",
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
    "Hemi thyroidectomy\nand Isthmusectomy" = "#96C4AB",
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

colnames(ptc_df_onco_ready) <- gsub("P_", "", colnames(ptc_df_onco_ready))

ptc_meta_summary <- as.data.frame(ptc_meta_summary)
rownames(ptc_meta_summary) <- as.character(ptc_meta_summary$Participant_id)

meta_idx <- match(colnames(ptc_df_onco_ready), rownames(ptc_meta_summary))
if (any(is.na(meta_idx))) {
  missing_meta_ids <- colnames(ptc_df_onco_ready)[is.na(meta_idx)]
  stop(
    "Missing metadata rows for participant IDs: ",
    paste(missing_meta_ids, collapse = ", ")
  )
}

ptc_meta_summary <- ptc_meta_summary[meta_idx, , drop = FALSE]
rownames(ptc_meta_summary) <- colnames(ptc_df_onco_ready)

##### Top annotation ####
ptc_meta_summary$Subtypes <- factor(ptc_meta_summary$Subtypes,
                                    levels = c(
                                      "THY",
                                      "PTC",
                                      "PTCplusTHY",
                                      "FTC",
                                      "NIFTP",
                                      "FA"))
top_df <- ptc_meta_summary[, "Subtypes"]
top_df <- data.frame(
  Subtypes = ptc_meta_summary$Subtypes,
  row.names = colnames(ptc_df_onco_ready),
  stringsAsFactors = FALSE
)

# helper to create display-only labels (do not alter underlying metadata)
clean_labels <- function(x) gsub("_", " ", x)

top_ann <- HeatmapAnnotation(
  df = top_df,
  col = meta_col_top,
  annotation_name_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
  annotation_name_side = "right",
  annotation_height = unit(0.15, "in"),
  show_annotation_name = TRUE,
  show_legend = FALSE,
  simple_anno_size_adjust = TRUE,
  annotation_label = clean_labels(colnames(top_df))
)

##### Test Top Annotation #####
#draw(top_ann)
#dev.off()


##### Bottom Annotation #####
bottom_df <- as.data.frame(ptc_meta_summary[, -c(1, 4)])
bottom_df <- bottom_df[colnames(ptc_df_onco_ready), , drop = FALSE]
rownames(bottom_df) <- colnames(ptc_df_onco_ready)
bottom_df$Pathology_Subtype <- gsub("_", " ", bottom_df$Pathology_Subtype)
bottom_df$Type_of_Thyroid_Surgery <- gsub("_", " ", bottom_df$Type_of_Thyroid_Surgery)
bottom_df$Pathology_Subtype <- gsub(
  "PTC conventional variant and papillary microcarcinoma",
  "PTC conventional variant\nand papillary microcarcinoma",
  bottom_df$Pathology_Subtype,
  fixed = TRUE
)
bottom_df$Type_of_Thyroid_Surgery <- gsub(
  "Hemi thyroidectomy and Isthmusectomy",
  "Hemi thyroidectomy\nand Isthmusectomy",
  bottom_df$Type_of_Thyroid_Surgery,
  fixed = TRUE
)

## Build display-only legend labels for bottom annotations (preserve metadata keys)
## For each bottom annotation, provide explicit legend `at` (keys) and cleaned `labels` (display-only)
default_legend_params_bottom <- list(
  direction = "horizontal",
  title_gp = gpar(fontsize = font_label_ann + 1, fontface = "bold"),
  labels_gp = gpar(fontsize = font_label_ann),
  legend_width = unit(2, "cm"),
  word_wrap = TRUE
)

## For each bottom annotation build a full legend param list that keeps mapping keys (`at`)
## but displays cleaned labels (no underscores). This ensures legend *values* show nicely.
legend_drop_values_bottom <- list(
  Primary_Tumor = "0",
  Lymph_Nodes = "0",
  Distant_Metastases = "0"
)

per_ann_bottom <- lapply(names(meta_col_bottom), function(ann_name) {
  v <- meta_col_bottom[[ann_name]]
  params <- default_legend_params_bottom
  if (is.function(v)) {
    return(NULL)
  }
  legend_keys <- names(v)
  legend_keys <- legend_keys[!is.na(legend_keys) & legend_keys != "NA"]
  drop_values <- legend_drop_values_bottom[[ann_name]]
  if (!is.null(drop_values)) {
    legend_keys <- setdiff(legend_keys, drop_values)
  }
  params$at <- legend_keys
  params$labels <- clean_labels(legend_keys)
  params
})
names(per_ann_bottom) <- names(meta_col_bottom)
annotation_legend_param_bottom <- per_ann_bottom[!sapply(per_ann_bottom, is.null)]

bottom_ann <- HeatmapAnnotation(
  df = bottom_df,
  col = meta_col_bottom,
  annotation_legend_param = annotation_legend_param_bottom,
  annotation_name_gp = gpar(fontsize = font_label_ann + 1, fontface = "bold"),
  annotation_name_side = "right",
  annotation_height = unit(3.5, "in"),
  show_annotation_name = TRUE,
  show_legend = TRUE,
  na_col = "black",
  simple_anno_size_adjust = TRUE,
  annotation_label = clean_labels(colnames(bottom_df))
)

##### Test Bottom Annotation #####
#draw(bottom_ann)
#dev.off()

######### Start png media. Choose from pdf, png, svg, etc. #####
file_name <- paste0(output_dir,
                    "oncoplot",
                    "_",
                    format(Sys.time(), "%b_%e_%Y"),
                    ".png")

png(
  file_name,
  width = 12,
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
      "Normal",
      "Lesion"
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
      "Normal",
      "Lesion"
    ),
    # , "Likely Benign"
    title_gp = gpar(fontsize = font_label_ann +
                      1, fontface = "bold"),
    labels_gp = gpar(fontsize = font_label_ann) # , "#C9A448"
  ),
  #alter_fun_is_vectorized = FALSE,
  column_order = rownames(ptc_meta_summary)[order(ptc_meta_summary$Subtypes)],
  column_split = factor(
    ptc_meta_summary$Subtypes,
    levels = c(
      "THY",
      "PTC",
      "PTCplusTHY",
      "FTC",
      "NIFTP",
      "FA")
  ),
  column_title_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
  column_names_gp = gpar(fontsize = font_label_ann +
                           1, fontface = "bold"),
  row_names_gp = gpar(fontsize = font_label_ann +
                        1, fontface = "bold"),
  right_annotation = c(
    rowAnnotation(row_barplot = anno_oncoprint_barplot()),
    rowAnnotation(
      boxplot = anno_multiple_boxplot,
      width = unit(4, "cm"),
      show_annotation_name = FALSE
    ),
    gap = unit(2, "mm")
  ),
  bottom_annotation = bottom_ann,
  top_annotation = c(top_ann, HeatmapAnnotation(cbar = anno_oncoprint_barplot()))
)

##### Create Oncoprint Legend for metadata ####
lgd = Legend(
  labels = c("Tumor", "Normal"),
  title = "Gene Expression\n(Boxplot, log2\nnormalized counts + 1)",
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
        "Normal",
        "Lesion"
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
        "Normal",
        "Lesion"
      ),
      # , "Likely Benign"
      title_gp = gpar(fontsize = font_label_ann +
                        1, fontface = "bold"),
      labels_gp = gpar(fontsize = font_label_ann) # , "#C9A448"
    ),
    alter_fun_is_vectorized = FALSE,
    column_order = rownames(ptc_meta_summary)[order(ptc_meta_summary$Subtypes)],
    column_split = factor(
      ptc_meta_summary$Subtypes,
      levels = c(
        "THY",
        "PTC",
        "PTCplusTHY",
        "FTC",
        "NIFTP",
        "FA")
    ),
    column_title_gp = gpar(fontsize = font_label_ann, fontface = "bold"),
    column_names_gp = gpar(fontsize = font_label_ann +
                             1, fontface = "bold"),
    row_names_gp = gpar(fontsize = font_label_ann +
                          1, fontface = "bold"),
    right_annotation = c(
      rowAnnotation(row_barplot = anno_oncoprint_barplot()),
      rowAnnotation(
        boxplot = anno_multiple_boxplot,
        width = unit(4, "cm"),
        show_annotation_name = FALSE
      ),
      gap = unit(2, "mm")
    ),
    bottom_annotation = bottom_ann,
    top_annotation = c(top_ann, HeatmapAnnotation(cbar = anno_oncoprint_barplot()))
  ),
  lgd = lgd,
  version = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
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
