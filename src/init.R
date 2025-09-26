##### Load Libaries ######
library(tidyr)
library(dplyr)

##### Define paths ######
output_dir = paste0(getwd(),"/out/",
                    format.Date(Sys.Date(), "%m-%d-%Y"),
                    "/")

if(!output_dir) dir.create(output_dir)
##### Load shared datasets #####