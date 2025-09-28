# Run Complete PTC Explorer Data Preparation Pipeline
# This function executes all scripts in the correct order as specified in README.md

run_ptce_data_pipeline <- function(verbose = TRUE, stop_on_error = TRUE) {
  
  # List of scripts in execution order
  scripts <- c(
    "src/init.R",
    "src/prepare_metadata.R", 
    "src/prepare_variant_data.R",
    "src/oncoplot_prepare_data.R",
    # "src/oncoplot_alt_fun.R",  # Optional - commented out by default
    "src/oncoplot_gene_exp_boxplots.R",
    "src/oncoplot_main.R",
    "src/enrichment_analysis_enrichR.R",
    "src/prepare_fusion_deg_tbl.R",
    "src/global_gene_aggregation.R",
    "src/pack_data_for_ptc_explorer.R"
  )
  
  # Record start time
  start_time <- Sys.time()
  
  if (verbose) {
    cat("===============================================\n")
    cat("PTC Explorer Data Preparation Pipeline\n")
    cat("===============================================\n")
    cat("Start time:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n\n")
  }
  
  # Execute each script
  for (i in seq_along(scripts)) {
    script <- scripts[i]
    
    if (verbose) {
      cat(sprintf("Step %d/%d: Running %s\n", i, length(scripts), basename(script)))
    }
    
    # Check if script exists
    if (!file.exists(script)) {
      error_msg <- paste("Script not found:", script)
      if (stop_on_error) {
        stop(error_msg)
      } else {
        warning(error_msg)
        next
      }
    }
    
    # Execute script with error handling
    tryCatch({
      source(script)
      if (verbose) {
        cat("  ✓ Completed successfully\n\n")
      }
    }, error = function(e) {
      error_msg <- paste("Error in", basename(script), ":", e$message)
      if (stop_on_error) {
        stop(error_msg)
      } else {
        warning(error_msg)
        if (verbose) {
          cat("  ✗ Failed with error:", e$message, "\n\n")
        }
      }
    })
  }
  
  # Record end time and duration
  end_time <- Sys.time()
  duration <- end_time - start_time
  
  if (verbose) {
    cat("===============================================\n")
    cat("Pipeline completed!\n")
    cat("End time:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
    cat("Total duration:", round(duration, 2), attr(duration, "units"), "\n")
    cat("===============================================\n")
    
    # Check for output files
    if (exists("output_dir")) {
      cat("\nOutput files saved to:", output_dir, "\n")
      if (dir.exists(output_dir)) {
        output_files <- list.files(output_dir, full.names = FALSE)
        if (length(output_files) > 0) {
          cat("Generated files:\n")
          for (file in output_files) {
            cat("  -", file, "\n")
          }
        }
      }
    }
  }
  
  return(invisible(list(
    start_time = start_time,
    end_time = end_time,
    duration = duration,
    scripts_executed = scripts
  )))
}

# Print usage instructions when script is sourced
cat("PTCE Data Pipeline Functions Loaded!\n")
cat("Usage:\n")
cat("  run_ptce_data_pipeline()           # Run complete data processing pipeline\n")
cat("\nOptions:\n")
cat("  verbose = FALSE               # Run silently\n")
cat("  stop_on_error = FALSE         # Continue on errors\n")
cat("\nExample:\n")
cat("  source('src/run_ptce_data_pipeline.R')\n")
cat("  run_ptce_data_pipeline()\n")