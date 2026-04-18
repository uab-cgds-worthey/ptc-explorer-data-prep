####### Latest Variant Table from BOX #######
ptc_df_main = readxl::read_excel(
  "data/2026-04-18_Additional-file-1.xlsx",
  sheet = "TableS3")

dim(ptc_df_main)

colnames(ptc_df_main)
# Resolve key input columns to support the latest table naming
normalize_colnames <- function(x) {
  gsub("[^a-z0-9]", "", tolower(x))
}

input_colnames <- colnames(ptc_df_main)
input_colnames_clean <- normalize_colnames(input_colnames)

resolve_input_col <- function(normalized_candidates) {
  match_idx <- which(input_colnames_clean %in% normalized_candidates)
  if (length(match_idx) == 0) {
    return(NA_character_)
  }
  input_colnames[match_idx[1]]
}

case_col <- resolve_input_col(c("caseid", "participantid"))
germline_col <- resolve_input_col(c("userclassification", "germlineclass"))

if (anyNA(c(case_col, germline_col))) {
  stop(
    "Required ID/classification columns were not found in variant input table. ",
    "Expected one of: case_id/participant_id and user classification/germline class."
  )
}

sel_cols_onco <- c(case_col,
                   "Phenotype",
                   "Type",
                   "Genes",
                   "Variant",
                   germline_col,
                   "Allelic balance",
                   "Chromosome",
                   "Position")

ptc_df_onco <- ptc_df_main[,sel_cols_onco]
colnames(ptc_df_onco)[colnames(ptc_df_onco) == case_col] <- "Case_id"
colnames(ptc_df_onco)[colnames(ptc_df_onco) == germline_col] <- "User_Classification"

#### Check and remove any duplicated row ####
ptc_df_onco[duplicated(ptc_df_onco),]
ptc_df_onco <- ptc_df_onco[!duplicated(ptc_df_onco),]

table(ptc_df_onco$Phenotype)
table(ptc_df_onco$Type)
table(ptc_df_onco$User_Classification)

#ptc_df_onco$Phenotype <- ifelse(ptc_df_onco$Phenotype == "Normal","N","T")

### Trim Variant type values to 3 characters
ptc_df_onco$Type <- toupper(substr(ptc_df_onco$Type, 1, 3))

### Abbreviate Germline Class values 
ptc_df_onco$User_Classification <-
  sapply(ptc_df_onco$User_Classification, function(x){
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
table(ptc_df_onco$User_Classification)

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
ditto_colnames <- colnames(ptc_df_ditto)
ditto_colnames_clean <- normalize_colnames(ditto_colnames)

resolve_ditto_col <- function(normalized_candidates) {
  match_idx <- which(ditto_colnames_clean %in% normalized_candidates)
  if (length(match_idx) == 0) {
    return(NA_character_)
  }
  ditto_colnames[match_idx[1]]
}

ditto_participant_col <- resolve_ditto_col(c("participantid", "caseid"))
ditto_variant_col <- resolve_ditto_col(c("variant"))
ditto_score_col <- resolve_ditto_col(c("ditto"))

if (anyNA(c(ditto_participant_col, ditto_variant_col, ditto_score_col))) {
  stop(
    "Required join columns were not found in DITTO table. ",
    "Expected participant/case ID, variant, and DITTO score columns."
  )
}

ptc_df_onco_ditto <- ptc_df_ditto[, c(ditto_participant_col, ditto_variant_col, ditto_score_col)]
colnames(ptc_df_onco_ditto) <- c("Participant_id", "Variant", "DITTO")
ptc_df_onco_ditto[duplicated(ptc_df_onco_ditto),]
ptc_df_onco_ditto <- ptc_df_onco_ditto[!duplicated(ptc_df_onco_ditto),]
ptc_ditto_only_scores <- ptc_df_onco_ditto[,c("Participant_id",
                                              "Variant",
                                              "DITTO")]


ptc_df_variants <- ptc_df_onco

ptc_df_variants$DITTO <- sapply(seq_len(nrow(ptc_df_onco)), function(x){
  
  case_temp_id <- ptc_df_onco$Case_id[x]
  variant_temp_id <- ptc_df_onco$Variant[x]
  
  ditto_score <- ptc_ditto_only_scores$DITTO[ptc_ditto_only_scores$Participant_id == case_temp_id & ptc_ditto_only_scores$Variant == variant_temp_id]
  
  ditto_score <- ifelse(is.null(ditto_score), NA, ditto_score)
  print(paste(x,case_temp_id, variant_temp_id, ditto_score, sep = "_"))
  return(ditto_score)
  
}, USE.NAMES = FALSE)


colnames(ptc_df_variants)
colnames(ptc_df_variants) <- c("Case_id","Phenotype",
                               "Variant Type", "Gene", 
                               "Variant", "User_Classification",
                               "Allelic Balance", "Chromosome",
                               "Position", "DITTO Score")
ptc_df_variants[,"DITTO Score"] <- round(ptc_df_variants[,"DITTO Score"], 4)

rm(ptc_ditto_only_scores)
rm(ptc_df_onco_ditto)
rm(ptc_df_ditto)
