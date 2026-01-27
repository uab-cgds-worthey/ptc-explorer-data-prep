#library(tidyr)
#source("src/for_new_repo_9_23_25/prepare_variant_data.R")

#### Prepare variant level data for oncoplot ####

### Check duplication in rows
ptc_df_onco[duplicated(ptc_df_onco[,c("Genes","Type","Participant_id","Phenotype")]),]

### Duplicate the dataframe 
ptc_df_rmVUS <- ptc_df_onco

### Preview column value counts
table(ptc_df_rmVUS$Phenotype)
table(ptc_df_rmVUS$Type)
table(ptc_df_rmVUS$Germline_Class)

### Combine type,germline class, and phenotype to new column
### This is the unique row value in oncoplot
ptc_df_rmVUS$alt <- paste(ptc_df_rmVUS$Type,
                          ptc_df_rmVUS$Germline_Class,
                          ptc_df_rmVUS$Phenotype,
                          sep = ";")

table(ptc_df_rmVUS$alt)

### Check duplication based on new id
ptc_df_rmVUS[duplicated(ptc_df_rmVUS[,c("Genes","alt","Participant_id")]),]

dim(ptc_df_rmVUS)

### Subset dataframe for required columns and check if duplication persist 
ptc_df_rmVUS_alt <- ptc_df_rmVUS[,c("Genes","Participant_id","alt")]


ptc_df_rmVUS_alt[duplicated(ptc_df_rmVUS[,c("Genes","Participant_id")]),]

ptc_df_rmVUS_alt_wide <- pivot_wider(ptc_df_rmVUS_alt, 
                                     names_from = Participant_id, 
                                     values_from = alt,
                                     names_prefix = "P_",
                                     values_fill = NA)


ptc_df_rmVUS_alt_wide <- apply(ptc_df_rmVUS_alt_wide, c(1, 2), function(x) {
  if (is.list(x)) {
    # Join list elements with ";"
    paste(unlist(x), collapse = ";")
  } else {
    as.character(x)  # Just convert to character if not a list
  }
})


unique(ptc_df_rmVUS$Participant_id)
dim(ptc_df_rmVUS)

ptc_df_onco_ready <- ptc_df_rmVUS_alt_wide
ptc_df_onco_ready[is.na(ptc_df_onco_ready)] = ""
ptc_df_onco_ready = as.matrix(ptc_df_onco_ready)
rownames(ptc_df_onco_ready) = ptc_df_onco_ready[, 1]
ptc_df_onco_ready = ptc_df_onco_ready[, -1]

dim(ptc_df_onco_ready)
