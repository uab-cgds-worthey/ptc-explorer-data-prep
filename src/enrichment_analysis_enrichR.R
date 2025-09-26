library(enrichR)
library(dplyr)

res.T_vs_N <- read.csv("data/res_t_vs_n.csv")
res.PTC_vs_FTC <- read.csv("data/res_PTC_vs_FTC.csv")


enrichr_dbs <- c(
  "WikiPathways_2024_Human",
  "Reactome_Pathways_2024",
  "KEGG_2021_Human"
)

clean_sig_df <- function(sig_df,
                         addRownames = TRUE) {
  if (addRownames) {
    sig_df <- sig_df[!duplicated(sig_df$gene_name), ]
    row.names(sig_df) <- sig_df$gene_name
  }
  return(sig_df)
  
}

clean_enrichR_df <- function(enrichR_df, source_name){
  
  enrichR_df <- enrichR_df[,c(1:4,7:9)]
  enrichR_df[,c(3:4)] <- round(enrichR_df[,c(3:4)], 4)
  enrichR_df[,c(5,6)] <- round(enrichR_df[,c(5,6)], 2)
  colnames(enrichR_df) <- c("Enriched Term", "Overlap", "pVal","adjPval",
                            "OR", "Score", "Genes")
  return(enrichR_df)
}

calculate_enrichr <- function(x, dbs){
  
  selected_db <- dbs
  
  x_up <- rownames(x %>% subset(log2FoldChange > 0))
  x_down <- rownames(x %>% subset(log2FoldChange < 0))
  x_comb <- rownames(x)
  
  enriched_up <- enrichr(x_up,
                         databases = c(selected_db))
  
  enriched_down <- enrichr(x_down,
                           databases = c(selected_db))
  
  enriched_comb <- enrichr(x_comb,
                           databases = c(selected_db))
  
  enriched_up_df <- clean_enrichR_df(enriched_up[[1]], source_name = "up")
  
  enriched_down_df <- clean_enrichR_df(enriched_down[[1]], source_name = "down")
  
  enriched_comb_df <- clean_enrichR_df(enriched_comb[[1]], source_name = "comb")
  
  enrich_res <- list("up_plot" = enriched_up[[1]],
                     "down_plot" = enriched_down[[1]],
                     "comb_plot" = enriched_comb[[1]],
                     "up_df" = enriched_up_df,
                     "down_df" = enriched_down_df,
                     "comb_df" = enriched_comb_df
  )
  
  return(enrich_res)
}

########## t_vs_n enrichr
t_vs_n_enrichr_input <- clean_sig_df(res.T_vs_N)
t_vs_n_enrichr_res <- lapply(enrichr_dbs, function(x) {
  calculate_enrichr(t_vs_n_enrichr_input, x)
})

names(t_vs_n_enrichr_res) <- enrichr_dbs
plotEnrich(t_vs_n_enrichr_res$WikiPathways_2024_Human$down_plot, title = enrichr_dbs[1])

############# ptc_vs_ftc enrichr
ptc_vs_ftc_enrichr_input <- clean_sig_df(res.PTC_vs_FTC)

ptc_vs_ftc_enrichr_res <- lapply(enrichr_dbs, function(x) {
  calculate_enrichr(ptc_vs_ftc_enrichr_input, x)
})

names(ptc_vs_ftc_enrichr_res) <- enrichr_dbs
plotEnrich(ptc_vs_ftc_enrichr_res$WikiPathways_2024_Human$up_plot, title = enrichr_dbs[1])

saveRDS(t_vs_n_enrichr_res, 
        paste0(output_dir,
               "t_vs_n_enrichr_res_",
               Sys.Date(),
               ".rds")
        )

saveRDS(ptc_vs_ftc_enrichr_res,
        paste0(output_dir,
               "ptc_vs_ftc_enrichr_res_",
               Sys.Date(),
               ".rds")
        )











