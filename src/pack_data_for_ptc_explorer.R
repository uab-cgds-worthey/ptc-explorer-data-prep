# Pack datasets in 1 or multiple rds for app ingestion.


######## From metadata_direct.R; preprocess_var.R, gene_agg.R
meta_data_app <- ptc_meta_summary
variant_data_app <- ptc_df_variants
rna_fusion_app <- rna_fusion_df
meta_fact_cols_app <- meta_factor_columns
meta_num_cols_app <- meta_numeric_columns

###### DEG lists (significant)
deg_sig_t_n_app <- as.data.frame(res.T_vs_N)
deg_sig_ptc_ftc_app <- as.data.frame(res.PTC_vs_FTC)

###### Enrichment analysis results from gprofiler.R and enrich.R
# t_vs_n_gprofiler <- gostres.T_vs_N
# ptc_vs_ftc_gprofiler <- gostres.PTC_vs_FTC
t_vs_n_enrichr <- t_vs_n_enrichr_res
ptc_vs_ftc_enrichr <- ptc_vs_ftc_enrichr_res
enrichr_db_app <- enrichr_dbs
######### All genes from gene_agg.R

all_genes_comb <- sort(all_genes_comb)
candidate_genes_latest <- sort(candidate_genes_latest)

######## Pack all data into a RDS obj
app_data_pack <- list("meta" = meta_data_app,
                      "variant" = variant_data_app,
                      "fusion" = rna_fusion_app,
                      "meta_fact_col" = meta_fact_cols_app,
                      "meta_num_col" = meta_num_cols_app,
                      "t_vs_n" = deg_sig_t_n_app,
                      "ptc_vs_ftc" = deg_sig_ptc_ftc_app,
                      # "t_vs_n_gp" = t_vs_n_gprofiler,
                      # "ptc_vs_ftc_gp" = ptc_vs_ftc_gprofiler,
                      "t_vs_n_er" = t_vs_n_enrichr_res,
                      "ptc_vs_ftc_er" = ptc_vs_ftc_enrichr,
                      "enrichr_dbs" = enrichr_db_app,
                      "all_genes" = all_genes_comb,
                      "candidate_gens" = candidate_genes_latest)


saveRDS(app_data_pack,
        paste0(output_dir,
               "app_data_pack_",
               Sys.Date(),
               ".rds"))




