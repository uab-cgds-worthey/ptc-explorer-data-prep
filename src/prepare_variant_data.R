####### Latest Variant Table from BOX #######
ptc_df_main = readxl::read_excel(
  "data/2025-04-01_Variants_tumor-normal_TableS3_rev2_4app.xlsx",
  sheet = "TableS3_rev2")

dim(ptc_df_main)

colnames(ptc_df_main)
sel_cols_onco <- c("Participant_id",
                   "Phenotype",
                   "Type",
                   "Genes",
                   "Variant",
                   "Germline_Class",
                   "Allelic balance",
                   "Chromosome",
                   "Position")

ptc_df_onco <- ptc_df_main[,sel_cols_onco]

#### Check and remove any duplicated row ####
ptc_df_onco[duplicated(ptc_df_onco),]
ptc_df_onco <- ptc_df_onco[!duplicated(ptc_df_onco),]

table(ptc_df_onco$Phenotype)
table(ptc_df_onco$Type)
table(ptc_df_onco$Germline_Class)

#ptc_df_onco$Phenotype <- ifelse(ptc_df_onco$Phenotype == "Normal","N","T")

### Trim Variant type values to 3 characters
ptc_df_onco$Type <- toupper(substr(ptc_df_onco$Type, 1, 3))

### Abbreviate Germline Class values 
ptc_df_onco$Germline_Class <-
  sapply(ptc_df_onco$Germline_Class, function(x){
    if(x == "Likely benign"){
      y <- "LB"
    }else if(x == "Benign"){
      y <- "B"
    }else if(x == "Likely pathogenic"){
      y <- "LP"
    }else if(x == "Pathogenic"){
      y <- "P"
    }else {
      y <- "VUS"
    }
    return(y)
  })

### Cleanup gene values
ptc_df_onco$Genes <- sapply(ptc_df_onco$Genes, function(x) strsplit(x, ",")[[1]][1])

### Tabular view with value count of modified columns 
table(ptc_df_onco$Phenotype)
table(ptc_df_onco$Type)
table(ptc_df_onco$Germline_Class)

### Dimensions of subset dataset
dim(ptc_df_onco)

### Save a csv file 
file_name <- paste0(output_dir,
                    "ptc_df_onco",
                    "_",
                    format(Sys.time(), "%b_%e_%Y"),
                    ".csv"
)

write.csv(ptc_df_onco, file_name)

###### Add ditto scores to latest table from previously generated DITTO file #######

ptc_df_ditto <- read.csv("data/PTC_DITTO.csv")
colnames(ptc_df_ditto)
sel_cols_onco_ditto <- c("Participant_id",
                         "Phenotype",
                         "Type",
                         "Genes",
                         "Variant",
                         "Germline_Class",
                         "Allelic.balance",
                         "chrom",
                         "pos",  
                         "ref_base",
                         "alt_base",
                         "DITTO"
)

ptc_df_onco_ditto <- ptc_df_ditto[,sel_cols_onco_ditto]
ptc_df_onco_ditto[duplicated(ptc_df_onco_ditto),]
ptc_df_onco_ditto <- ptc_df_onco_ditto[!duplicated(ptc_df_onco_ditto),]
ptc_ditto_only_scores <- ptc_df_onco_ditto[,c("Participant_id",
                                              "Variant",
                                              "DITTO")]


ptc_df_variants <- ptc_df_onco

ptc_df_variants$DITTO <- sapply(1:nrow(ptc_df_onco), function(x){
  
  participant_temp_id <- ptc_df_onco$Participant_id[x]
  variant_temp_id <- ptc_df_onco$Variant[x]
  
  ditto_score <- ptc_ditto_only_scores$DITTO[ptc_ditto_only_scores$Participant_id == participant_temp_id & ptc_ditto_only_scores$Variant == variant_temp_id]
  
  ditto_score <- ifelse(is.null(ditto_score), NA, ditto_score)
  print(paste(x,participant_temp_id, variant_temp_id, ditto_score, sep = "_"))
  return(ditto_score)
  
}, USE.NAMES = FALSE)


colnames(ptc_df_variants)
colnames(ptc_df_variants) <- c("Participant ID","Phenotype",
                                 "Variant Type", "Gene", 
                                 "Variant", "Germline Class",
                                 "Allelic Balance", "Chromosome",
                                 "Position", "DITTO Score")
ptc_df_variants[,"DITTO Score"] <- round(ptc_df_variants[,"DITTO Score"], 4)

rm(ptc_ditto_only_scores)
rm(ptc_df_onco_ditto)
rm(ptc_df_ditto)
