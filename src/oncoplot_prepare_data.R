#library(tidyr)
#source("src/for_new_repo_9_23_25/prepare_variant_data.R")

#### Prepare variant level data for oncoplot ####

if ("Case ID" %in% colnames(ptc_df_onco) && !"Case_id" %in% colnames(ptc_df_onco)) {
  colnames(ptc_df_onco)[colnames(ptc_df_onco) == "Case ID"] <- "Case_id"
}

if ("User Classification" %in% colnames(ptc_df_onco) && !"User_Classification" %in% colnames(ptc_df_onco)) {
  colnames(ptc_df_onco)[colnames(ptc_df_onco) == "User Classification"] <- "User_Classification"
}

if ("Germline_Class" %in% colnames(ptc_df_onco) && !"User_Classification" %in% colnames(ptc_df_onco)) {
  colnames(ptc_df_onco)[colnames(ptc_df_onco) == "Germline_Class"] <- "User_Classification"
}

### Check duplication in rows
ptc_df_onco[duplicated(ptc_df_onco[,c("Genes","Type","Case_id","Phenotype")]),]

### Duplicate the dataframe 
ptc_df_rmVUS <- ptc_df_onco

### Preview column value counts
table(ptc_df_rmVUS$Phenotype)
table(ptc_df_rmVUS$Type)
table(ptc_df_rmVUS$User_Classification)

### Combine type,germline class, and phenotype to new column
### This is the unique row value in oncoplot
ptc_df_rmVUS$alt <- paste(ptc_df_rmVUS$Type,
                          ptc_df_rmVUS$User_Classification,
                          ptc_df_rmVUS$Phenotype,
                          sep = ";")

table(ptc_df_rmVUS$alt)

### Check duplication based on new id
ptc_df_rmVUS[duplicated(ptc_df_rmVUS[,c("Genes","alt","Case_id")]),]

dim(ptc_df_rmVUS)

### Subset dataframe for required columns and check if duplication persist 
ptc_df_rmVUS_alt <- ptc_df_rmVUS[,c("Genes","Case_id","alt")]


ptc_df_rmVUS_alt[duplicated(ptc_df_rmVUS[,c("Genes","Case_id")]),]

ptc_df_rmVUS_alt_wide <- pivot_wider(ptc_df_rmVUS_alt, 
                                     names_from = Case_id, 
                                     values_from = alt,
                                     names_prefix = "P_",
                                     values_fill = NA,
                                     values_fn = function(x) paste(unique(x), collapse = ";"))


unique(ptc_df_rmVUS$Case_id)
dim(ptc_df_rmVUS)

ptc_df_onco_ready <- ptc_df_rmVUS_alt_wide
ptc_df_onco_ready[is.na(ptc_df_onco_ready)] = ""
ptc_df_onco_ready = as.matrix(ptc_df_onco_ready)
rownames(ptc_df_onco_ready) = ptc_df_onco_ready[, 1]
ptc_df_onco_ready = ptc_df_onco_ready[, -1]

gene_order <- unique(ptc_df_rmVUS_alt$Genes[order(ptc_df_rmVUS_alt$Case_id)])
ptc_df_onco_ready <- ptc_df_onco_ready[
  c(gene_order[gene_order %in% rownames(ptc_df_onco_ready)],
    setdiff(rownames(ptc_df_onco_ready), gene_order)),
  ,
  drop = FALSE
]

dim(ptc_df_onco_ready)
