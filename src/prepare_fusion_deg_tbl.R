# Latest data processing - 2/1/2025
library(readxl)
fusion_tabl_latest <- read_excel("data/Additional-file-1.xlsx", 
                                 sheet = "TableS5",
                                 skip = 2)


colnames(fusion_tabl_latest)
fusion_tabl_latest[1,]

colnames(fusion_tabl_latest)[6:10]
fusion_tabl_latest[1, 6:10]

new_col_names <- paste0(fusion_tabl_latest[1, 6:10], "_", "tool")
new_col_names

colnames(fusion_tabl_latest)[6:10] <- new_col_names

colnames(fusion_tabl_latest)
fusion_tabl_latest[1,]

fusion_tabl_latest <- fusion_tabl_latest[-1,]
fusion_tabl_latest

fusion_tabl_latest$Gene_Fusion <- gsub("--", "::", fusion_tabl_latest$Gene_Fusion)

################ DEG

ptc_ftc_dge_latest <- read_excel("data/Additional-file-1.xlsx", 
                                 sheet = "TableS8",
                                 skip = 2)
tumor_normal_dge_latest <- read_excel("data/Additional-file-1.xlsx", 
                                      sheet = "TableS6",
                                      skip = 2)

################ Candidate genes

candidate_genes_latest <- read_excel("data/Additional-file-1.xlsx", 
                                     sheet = "Table S9",
                                     skip = 2)


candidate_genes_latest <- candidate_genes_latest$gene_name




