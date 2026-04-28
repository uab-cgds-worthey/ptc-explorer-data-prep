
#source("init.R")

ptc_df_tableS2 = readxl::read_excel(
  "data/2026-04-27_Additional-file-1.xlsx",
  sheet = "TableS2")

first_non_missing <- function(x) {
  x_chr <- trimws(as.character(x))
  x_chr[x_chr %in% c("", "NA", "N/A")] <- NA_character_
  idx <- which(!is.na(x_chr))
  if (length(idx) == 0) {
    return(NA_character_)
  }
  x_chr[idx[1]]
}

ptc_df_meta_direct <- ptc_df_tableS2 %>%
  transmute(
    Participant_id = Case_id,
    Record_id = row_number(),
    Age_at_diagnosis = Age_at_diagnosis,
    Sex = Sex,
    Phenotype_Subtype = Pathology,
    Pathology_Subtype = Pathology_Subtype,
    Nodule1_FNA_Result = Nodule1_FNA_Result,
    Autoimmune_Thyroiditis = Autoimmune_Thyroiditis,
    History_of_Radiation_to_Neck = History_of_Radiation_to_Neck,
    History_of_Previous_Cancer = Histor_of_Previous_Cancer,
    Received_RAI = `Did_Patient_Receive_RAI?`,
    Additional_Surgery = Additional_Surgery,
    Batch = Batch_number,
    Race = `Race/Ethnicity`,
    TI_RADS_Score = TI_RADS_Score,
    Type_of_Thyroid_Surgery = Type_of_Thyroid_Surgery,
    Primary_Tumor = Primary_Tumor,
    Lymph_Nodes = Lymph_Nodes,
    Distant_Metastases = Distant_Metastases,
    Largest_Nodule_Dimension = `Largest_Nodule_Dimension_in_Final_Pathology_(mm)`,
    Molecular_Testing = Molecular_Testing,
    Tumor_percentage = Tumor_Percentage_based_on_LW_id_and_pheno,
    ATA_Pediatric_Risk_Level = ATA_Pediatric_Risk_Level,
    Phenotype_Source = Phenotype
  ) %>%
  mutate(
    Phenotype_Source = as.character(Phenotype_Source),
    .phenotype_priority = case_when(
      Phenotype_Source == "Normal" ~ 1L,
      Phenotype_Source == "Lesion" ~ 2L,
      Phenotype_Source == "Tumor" ~ 3L,
      TRUE ~ 4L
    )
  ) %>%
  arrange(Participant_id, .phenotype_priority) %>%
  group_by(Participant_id) %>%
  summarise(
    across(
      c(
        Record_id, Age_at_diagnosis, Sex, Phenotype_Subtype, Pathology_Subtype,
        Nodule1_FNA_Result, Autoimmune_Thyroiditis, History_of_Radiation_to_Neck,
        History_of_Previous_Cancer, Received_RAI, Additional_Surgery, Batch, Race,
        TI_RADS_Score, Type_of_Thyroid_Surgery, Primary_Tumor, Lymph_Nodes,
        Distant_Metastases, Largest_Nodule_Dimension, Molecular_Testing,
        Tumor_percentage, ATA_Pediatric_Risk_Level
      ),
      first_non_missing
    ),
    .groups = "drop"
  )

str(ptc_df_meta_direct)
colnames(ptc_df_meta_direct)
dim(ptc_df_meta_direct)

ptc_df_meta_direct[, c(4:14, 16:19, 21, 23)]
sum(ptc_df_meta_direct[, c(15, 20, 22)] == "NA")

ptc_df_meta_direct <- ptc_df_meta_direct %>%
  mutate(across(all_of(c(4:14, 16:19, 21, 23)), as.factor))

ptc_df_meta_direct <- ptc_df_meta_direct %>%
  mutate(across(all_of(c(15, 20, 22)), as.numeric))

colnames(ptc_df_meta_direct)

###### Prepare data for oncopplot
ptc_meta_summary <- ptc_df_meta_direct[, c(1, 3:20, 23)]
dim(ptc_meta_summary)

colnames(ptc_meta_summary)
colnames(ptc_meta_summary)[colnames(ptc_meta_summary) == "Phenotype_Subtype"] <- "Subtypes"

ptc_meta_summary <- ptc_meta_summary %>%
  mutate(
    Subtypes = case_when(
      Subtypes == "PTC, T" ~ "PTCplusTHY",
      Subtypes == "T" ~ "THY",
      TRUE ~ as.character(Subtypes)
    ),
    Pathology_Subtype = case_when(
      Pathology_Subtype == "PTC - conventional variant" ~ "PTC_conventional_variant",
      Pathology_Subtype == "PTC - conventional variant,PTC - papillary microcarcinoma" ~ "PTC_conventional_variant_and_papillary_microcarcinoma",
      Pathology_Subtype == "PTC - diffuse sclerosing variant" ~ "PTC_diffuse_sclerosing_variant",
      Pathology_Subtype == "PTC - follicular variant" ~ "PTC_follicular_variant",
      Pathology_Subtype == "PTC - oncocytic variant" ~ "PTC_oncocytic_variant",
      Pathology_Subtype == "FTC - minimally invasive (WHO 217)" ~ "FTC_minimally_invasive",
      TRUE ~ as.character(Pathology_Subtype)
    ),
    Nodule1_FNA_Result = case_when(
      Nodule1_FNA_Result == "Atypia of undetermined significance or follicular lesion of undetermined significance" ~ "Undertermined",
      Nodule1_FNA_Result == "Atypia_or_follicular_lesion_of_undetermined_significance" ~ "Undertermined",
      Nodule1_FNA_Result == "Follicular lesion or neoplasm" ~ "Follicular_lesion_or_neoplasm",
      Nodule1_FNA_Result == "Suspicious for malignancy" ~ "Suspicious_for_malignancy",
      TRUE ~ as.character(Nodule1_FNA_Result)
    ),
    Type_of_Thyroid_Surgery = case_when(
      Type_of_Thyroid_Surgery == "Hemi-thyroidectomy (lobectomy)" ~ "Hemi_thyroidectomy",
      Type_of_Thyroid_Surgery == "Hemi-thyroidectomy (lobectomy),Isthmusectomy" ~ "Hemi_thyroidectomy_and_Isthmusectomy",
      Type_of_Thyroid_Surgery == "Subtotal thyroidectomy" ~ "Subtotal_thyroidectomy",
      Type_of_Thyroid_Surgery == "Total thyroidectomy" ~ "Total_thyroidectomy",
      TRUE ~ as.character(Type_of_Thyroid_Surgery)
    ),
    Race = case_when(
      Race %in% c("Black / African American", "Black/African American") ~ "Black_or_African_American",
      Race == "White Caucasian" ~ "White_Caucasian",
      TRUE ~ as.character(Race)
    )
  )

table(ptc_meta_summary$Nodule1_FNA_Result)
sum(is.na(ptc_meta_summary$Nodule1_FNA_Result))

ptc_meta_summary <- ptc_meta_summary %>%
  mutate(
    Age_at_diagnosis = suppressWarnings(as.numeric(Age_at_diagnosis)),
    TI_RADS_Score = suppressWarnings(as.numeric(TI_RADS_Score)),
    Largest_Nodule_Dimension = suppressWarnings(as.numeric(Largest_Nodule_Dimension))
  )

ptc_meta_summary$Nodule1_FNA_Result[is.na(ptc_meta_summary$Nodule1_FNA_Result)] <- "NA"

ptc_meta_summary$Nodule1_FNA_Result <- as.factor(
  ptc_meta_summary$Nodule1_FNA_Result
)

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
