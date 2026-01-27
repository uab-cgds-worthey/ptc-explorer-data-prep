
#source("init.R")

ptc_df_meta_direct = readxl::read_excel(
  "data/2024-12-03_Variants_tumor-normal_TableS3_GK_4app.xlsx",
  sheet = "Metadata")

str(ptc_df_meta_direct)
colnames(ptc_df_meta_direct)
dim(ptc_df_meta_direct)

ptc_df_meta_direct[,c(4:14,16:19,21,23)] 
sum(ptc_df_meta_direct[,c(15,20,22)] == "NA")

ptc_df_meta_direct <- ptc_df_meta_direct %>%
  mutate(across(all_of(c(4:14,16:19,21,23)), as.factor))

ptc_df_meta_direct <- ptc_df_meta_direct %>%
  mutate(across(all_of(c(15,20,22)), as.numeric))

colnames(ptc_df_meta_direct)

###### Prepare data for oncopplot
ptc_meta_summary <- ptc_df_meta_direct[,c(1,3:20,23)]
dim(ptc_meta_summary)

colnames(ptc_meta_summary)
colnames(ptc_meta_summary)[4] <- "Subtypes"
unique(ptc_meta_summary$Nodule1_FNA_Result) 

table(ptc_meta_summary$Nodule1_FNA_Result)
sum(is.na(ptc_meta_summary$Nodule1_FNA_Result))

ptc_meta_summary <- ptc_meta_summary %>%
  mutate(Nodule1_FNA_Result = case_when(
    Nodule1_FNA_Result == "Atypia_or_follicular_lesion_of_undetermined_significance" ~ "Undertermined",
    TRUE ~ Nodule1_FNA_Result  # Keep other values unchanged
  ))

table(ptc_meta_summary$Nodule1_FNA_Result)
sum(is.na(ptc_meta_summary$Nodule1_FNA_Result))

ptc_meta_summary$Nodule1_FNA_Result <- as.factor(
  ptc_meta_summary$Nodule1_FNA_Result
)

ptc_meta_summary$Nodule1_FNA_Result[is.na(ptc_meta_summary$Nodule1_FNA_Result)] <- "NA"

str(ptc_meta_summary)
unique(ptc_meta_summary$Nodule1_FNA_Result)


meta_factor_columns <- ptc_meta_summary %>%
  select(where(is.factor)) %>%
  colnames()

meta_numeric_columns <- ptc_meta_summary %>%
  select(where(is.numeric)) %>%
  colnames()

meta_factor_columns
meta_numeric_columns
























