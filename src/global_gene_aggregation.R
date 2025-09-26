######## Prepare gene list
# gene_names <- rownames(assay(vsd_after_swap))
# gene_names_group1 <- rownames(assay(vsd_group1))
# 
# 
# old.res.T_vs_N <- read.csv("data/res_t_vs_n.csv")
# 
# str(old.res.T_vs_N)
str(as.data.frame(res.T_vs_N))
# res.PTC_vs_FTC <- read.csv("data/res_PTC_vs_FTC.csv")

# sig_df <- sig_df[!is.na(sig_df$padj), ]
# 
# sig_df$pvalue <- signif(sig_df$pvalue, digits = 3)
# sig_df$padj <- signif(sig_df$padj, digits = 3)
# 
# sig_df$log2FoldChange <- round(sig_df$log2FoldChange, digits = 3)

# which(res.T_vs_N$Ensembl_ID != tumor_normal_dge_latest$Ensembl_ID)
#

clean_sig_df <- function(sig_df, custom_subset = FALSE) {
  
  sig_df <- sig_df[!is.na(sig_df$padj), ]
  sig_df$pvalue <- signif(sig_df$pvalue, digits = 3)
  sig_df$padj <- signif(sig_df$padj, digits = 3)
  # sig_df$pvalue <- formatC(sig_df$pvalue, format = "e", digits = 3)
  # sig_df$padj <- formatC(sig_df$padj, format = "e", digits = 3)
  sig_df$log2FoldChange <- round(sig_df$log2FoldChange, digits = 3)
  
  if(custom_subset){
    sig_df <- sig_df[, c(
      "Gene ID",
      "gene_name",
      "Ensembl_ID",
      "log2FoldChange",
      "pvalue",
      "padj",
      "Type of Gene",
      "Synonyms"
    )]
    colnames(sig_df)[1] <- "gene_id"
  }
  
  return(sig_df)
  
}

all(sort(tumor_normal_dge_latest$gene_name) == sort(res.T_vs_N$gene_name))
all(sort(tumor_normal_dge_latest$`Gene ID`) == sort(res.T_vs_N$gene_id))
# tumor_normal_dge_latest <- tumor_normal_dge_latest[order(gene_name), ]
# res.T_vs_N <- res.T_vs_N[order(gene_name), ]

# tumor_normal_dge_latest$`Gene ID` <- sapply(tumor_normal_dge_latest$gene_name,
#                                             function(x){
#                                               y <- res.T_vs_N[res.T_vs_N$gene_name == x, "gene_id"]
#                                             })
# ptc_ftc_dge_latest$`Gene ID` <- sapply(ptc_ftc_dge_latest$gene_name,
#                                             function(x){
#                                               y <- res.PTC_vs_FTC[res.PTC_vs_FTC$gene_name == x, "gene_id"]
#                                             })


sum(duplicated(tumor_normal_dge_latest$`Gene ID`))

all(res.T_vs_N$gene_name == tumor_normal_dge_latest$gene_name)

res.T_vs_N <- tumor_normal_dge_latest
res.PTC_vs_FTC <- ptc_ftc_dge_latest

res.T_vs_N <- clean_sig_df(res.T_vs_N,
                           custom_subset = T)
res.PTC_vs_FTC <- clean_sig_df(res.PTC_vs_FTC, 
                               custom_subset = T)


colnames(res.T_vs_N)
colnames(res.PTC_vs_FTC)


dim(res.T_vs_N)
dim(res.PTC_vs_FTC)

genes_deg_t_vs_n <- res.T_vs_N$gene_name
genes_deg_ptc_vs_ftc <- res.PTC_vs_FTC$gene_name

length(genes_deg_t_vs_n)
length(genes_deg_ptc_vs_ftc)

genes_deg <- c(genes_deg_t_vs_n, genes_deg_ptc_vs_ftc)

length(genes_deg)
sum(duplicated(genes_deg))


##### Fusions

#rna_fusion_df <- read.csv("data/RNA_fusions.csv")
rna_fusion_df <- fusion_tabl_latest
rna_fusion_df$Participant_id <- as.factor(rna_fusion_df$Participant_id)

gene_a <- unlist(strsplit(rna_fusion_df$Gene_Fusion[6], "--"))[2]
gene_a

rna_fusion_df$geneA <- sapply(rna_fusion_df$Gene_Fusion, function(x){
  unlist(strsplit(x, "--"))[1]
})

rna_fusion_df$geneB <- sapply(rna_fusion_df$Gene_Fusion, function(x){
  unlist(strsplit(x, "--"))[2]
})


write.csv(rna_fusion_df,
          paste0(output_dir,"RNA_fusions_updated_",
                 Sys.Date(),
                 ".csv"),
                 row.names = FALSE)

genes_rna_fusion <- unlist(strsplit(rna_fusion_df$Gene_Fusion, "--"))
length(genes_rna_fusion)

genes_rna_fusion <- genes_rna_fusion[!duplicated(genes_rna_fusion)]
length(genes_rna_fusion)

any(duplicated(genes_rna_fusion))


####### Variant genes 


genes_variants <- ptc_df_onco$Genes
length(genes_variants)


######### Combine all gene lists 

all_genes_comb <- c(genes_deg,genes_rna_fusion,genes_variants)

sum(duplicated(all_genes_comb))

all_genes_comb <- all_genes_comb[!duplicated(all_genes_comb)]

sum(duplicated(all_genes_comb))

length(all_genes_comb)












