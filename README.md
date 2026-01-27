# PTC Explorer Data Preparation

<!-- markdown-link-check-disable -->

[![Perform linting -
Markdown](https://github.com/uab-cgds-worthey/ptc-explorer-data-prep/actions/workflows/linting.yml/badge.svg)](https://github.com/uab-cgds-worthey/ptc-explorer-data-prep/actions/workflows/linting.yml)
<!-- markdown-link-check-enable -->

This repository contains R scripts and data processing pipelines for preparing datasets used in the PTC (Pediatric
Thyroid Cancer) Explorer Shiny application. The project processes variant data, metadata, fusion data, differential gene
expression results, and enrichment analyses to create a comprehensive dataset for pediatric thyroid cancer research
exploration and visualization.

## Requirements

- R (version 4.0 or higher)
- Required R packages (see installation instructions below):
  - **CRAN packages**: tidyr, dplyr, readxl, enrichR, circlize
  - **Bioconductor packages**: ComplexHeatmap, DESeq2
- Input data files in the `data/` directory including:
  - Variant data (Excel format)
  - Metadata files
  - RNA fusion data (CSV format)
  - Differential expression results

## How to install

1. Clone this repository:

    ``` bash
    git clone https://github.com/uab-cgds-worthey/ptc-explorer-data-prep.git
    cd ptc-explorer-data-prep
    ```

2. Open the project in RStudio or your preferred R environment

3. Install required R packages:

    **Install CRAN packages:**

    ``` r
    # CRAN packages
    install.packages(c(
      "tidyr",
      "dplyr", 
      "readxl",
      "enrichR",
      "circlize"
    ))
    ```

    **Install Bioconductor packages:**

    ``` r
    # Install BiocManager if not already installed
    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")

    # Bioconductor packages
    BiocManager::install(c(
      "ComplexHeatmap",
      "DESeq2",
      "limma",
      "forcats"
    ))
    ```

4. Ensure all required data files are present in the `data/` directory

## How to run

The data processing pipeline consists of multiple R scripts that must be executed in a specific order. Navigate to the
`src/` directory and run the following scripts sequentially either manually or
via automated pipeline as described further down:

**Script Execution Order:**

1. **Initialize environment**: `init.R`
2. **Prepare metadata**: `prepare_metadata.R`
3. **Process variant data**: `prepare_variant_data.R`\
4. **Prepare oncoplot data**: `oncoplot_prepare_data.R`
5. **Alternative oncoplot function** (optional): `oncoplot_alt_fun.R`
6. **Generate gene expression boxplots**: `oncoplot_gene_exp_boxplots.R`
7. **Create main oncoplot**: `oncoplot_main.R`
8. **Perform enrichment analysis**: `enrichment_analysis_enrichR.R`
9. **Prepare fusion and DEG tables**: `prepare_fusion_deg_tbl.R`
10. **Aggregate global gene data**: `global_gene_aggregation.R`
11. **Package final data**: `pack_data_for_ptc_explorer.R`

**Complete Pipeline Execution:**

**Option 1: Using the Pipeline Function (Recommended):**

Load and run the complete pipeline with a single function:

``` r
# Load the pipeline function
source("src/run_ptce_data_pipeline.R")

# Run the complete data processing pipeline
run_ptce_data_pipeline()

# Run silently without verbose output
run_ptce_data_pipeline(verbose = FALSE)

# Continue execution even if errors occur
run_ptce_data_pipeline(stop_on_error = FALSE)
```

**Option 2: Manual Script Execution:**

To run the entire data processing pipeline manually, execute the following commands in R from the project root
directory:

``` r
# Complete data processing pipeline - run in sequence
source("src/init.R")
source("src/prepare_metadata.R")
source("src/prepare_variant_data.R")
source("src/oncoplot_prepare_data.R")
# source("src/oncoplot_alt_fun.R")  # Optional - uncomment if needed
source("src/oncoplot_gene_exp_boxplots.R")
source("src/oncoplot_main.R")
source("src/enrichment_analysis_enrichR.R")
source("src/prepare_fusion_deg_tbl.R")
source("src/global_gene_aggregation.R")
source("src/pack_data_for_ptc_explorer.R")

# Pipeline complete - check the out/ directory for results
```

The pipeline will create an output directory with timestamp (`out/MM-DD-YYYY/`) containing processed results and
packaged RDS files ready for ingestion by the PTC Explorer Shiny application.

## Repo's directory structure

The directory structure below shows the nature of files/directories used in this repo.

``` sh
$ tree -a ptc-explorer-data-prep/
ptc-explorer-data-prep
├── CHANGELOG.md                    <- Log of changes made
│
├── CONTRIBUTING.md                 <- Contribution guidelines
│
├── README.md                       <- Project documentation
│
├── data                           <- Raw and processed datasets
│   ├── 2024-12-03_Variants_tumor-normal_TableS3_GK_4app.xlsx
│   ├── 2025-04-01_Variants_tumor-normal_TableS3_rev2_4app.xlsx
│   ├── 2025-04-24_TableS3_rev2_metadata.xlsx
│   ├── dds_after_swap.rds         <- DESeq2 results object
│   ├── PTC_DITTO.csv              <- Pediatric thyroid cancer metadata
│   ├── res_*.csv                  <- Differential expression results
│   └── RNA_fusions.csv            <- RNA fusion data
│
├── docs                           <- Documentation directory
│
├── src                            <- Source code for data processing
│   ├── README.md                  <- Script execution order guide
│   ├── run_ptce_data_pipeline.R   <- Pipeline execution functions
│   ├── init.R                     <- Environment initialization
│   ├── prepare_metadata.R         <- Metadata processing
│   ├── prepare_variant_data.R     <- Variant data processing
│   ├── oncoplot_prepare_data.R    <- Oncoplot data preparation
│   ├── oncoplot_alt_fun.R         <- Alternative oncoplot functions
│   ├── oncoplot_gene_exp_boxplots.R <- Gene expression visualizations
│   ├── oncoplot_main.R            <- Main oncoplot generation
│   ├── enrichment_analysis_enrichR.R <- Pathway enrichment analysis
│   ├── prepare_fusion_deg_tbl.R   <- Fusion and DEG table preparation
│   ├── global_gene_aggregation.R  <- Gene data aggregation
│   └── pack_data_for_ptc_explorer.R <- Final data packaging
│
└── out                            <- Generated output directory (created during execution)
    └── MM-DD-YYYY                 <- Timestamped results directory
```

## Contributing

We welcome contributions! [See the docs for guidelines](./CONTRIBUTING.md).

## Author

Samuel Bharti [:email:](mailto:sbharti@uab.edu) \| Graduate Research Assistant
