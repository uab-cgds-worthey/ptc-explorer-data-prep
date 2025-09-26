library(DESeq2)
library(limma)
library(ggplot2)
library(forcats)
library(ggrepel)

###### Read DEGs
dds_after_swap <- readRDS("data/dds_after_swap.rds")
res_aff_vs_unaff <- read.csv("data/res_aff_vs_unaff_genename.csv")

nrow(res_aff_vs_unaff)
oncoplot_genes <- unique(ptc_df_rmVUS$Genes)

res_aff_vs_unaff_oncoplot <- res_aff_vs_unaff[res_aff_vs_unaff$gene_name %in% oncoplot_genes,]

res_aff_vs_unaff_oncoplot_NOT <- oncoplot_genes[!oncoplot_genes %in% res_aff_vs_unaff_oncoplot$gene_name]

norm_counts <- counts(dds_after_swap, normalized=TRUE)
colnames(norm_counts)[1]
rownames(norm_counts)[1]
res_aff_vs_unaff_oncoplot$Ensembl_ID
norm_counts_oncoplot <- norm_counts[res_aff_vs_unaff_oncoplot$Ensembl_ID,]

all(res_aff_vs_unaff_oncoplot$Ensembl_ID == rownames(norm_counts_oncoplot))
rownames(norm_counts_oncoplot) <- res_aff_vs_unaff_oncoplot$gene_name

dim(norm_counts_oncoplot)
res_aff_vs_unaff_oncoplot_NOT

noExp_gene_matrix <- matrix(data = 0, nrow = length(res_aff_vs_unaff_oncoplot_NOT),
                            ncol = ncol(norm_counts_oncoplot))
rownames(noExp_gene_matrix) <- res_aff_vs_unaff_oncoplot_NOT
colnames(noExp_gene_matrix) <- colnames(norm_counts_oncoplot)
noExp_gene_matrix

#### Bind Exp genes and non-exp gene matrices

norm_counts_oncoplot_comb <- rbind(norm_counts_oncoplot, noExp_gene_matrix)
norm_counts_oncoplot_comb <- norm_counts_oncoplot_comb[rownames(ptc_df_onco_ready),]


# Read sample metadata for tumor vs normal split
meta_norm_counts <- as.data.frame(colData(dds_after_swap))
samples_tumor <- rownames(meta_norm_counts[meta_norm_counts$Phenotype == "Tumor",])
samples_normal <- rownames(meta_norm_counts[meta_norm_counts$Phenotype == "Normal",])

norm_counts_tumor_matrix <- norm_counts_oncoplot_comb[, samples_tumor]
norm_counts_normal_matrix <- norm_counts_oncoplot_comb[, samples_normal]

# #### Boxplot for tumor and normal 
# m1 = norm_counts_tumor_matrix
# m2 = norm_counts_normal_matrix

m1 = log2(norm_counts_tumor_matrix+1)
m2 = log2(norm_counts_normal_matrix+1) 

dim(m1)
rg = range(c(m1, m2))
rg
rg[1] = rg[1] - (rg[2] - rg[1])* 0.02
rg[2] = rg[2] + (rg[2] - rg[1])* 0.02

dev.off()

anno_multiple_boxplot = function(index) {
  nr = length(index)
  pushViewport(viewport(xscale = rg, yscale = c(0.5, nr + 0.5)))
  for(i in seq_along(index)) {
    grid.rect(y = nr-i+1, height = 1, default.units = "native")
    grid.boxplot(m1[ index[i], ], pos = nr-i+1 + 0.2, box_width = 0.3, 
                 gp = gpar(fill = "grey40"), direction = "horizontal",
                 pch = 16)
    grid.boxplot(m2[ index[i], ], pos = nr-i+1 - 0.2, box_width = 0.3, 
                 gp = gpar(fill = "grey90"), direction = "horizontal",
                 pch = 16)
  }
  grid.xaxis(main = FALSE, gp = gpar(fontsize = font_label_ann))
  popViewport()
}

##### Test Boxplot function #### 
# ht_list = Heatmap(m1, name = "m1") + Heatmap(m2, name = "m2")
# ht_list = ht_list + rowAnnotation(boxplot = anno_multiple_boxplot, width = unit(4, "cm"), 
#                                   show_annotation_name = FALSE)
# lgd = Legend(labels = c("m1", "m2"), title = "boxplots",
#              legend_gp = gpar(fill = c("red", "green")))
# draw(ht_list, padding = unit(c(20, 2, 2, 2), "mm"), heatmap_legend_list = list(lgd))
