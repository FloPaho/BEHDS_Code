library(here)
library(tidyverse)
#options(repos = c(CRAN = "https://cran.r-project.org"))
# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if at least one argument is provided
if (length(args) == 0) {
  stop("No arguments provided. Usage: behds.R Projectname", call. = FALSE)
}

# Set the variable with the first argument
proj <- args[1]
print(paste("The provided variable is:", proj))

# Print the base directory according to `here()`
cat(sprintf("Base directory: '%s'\n", here()))

# Detailed check for directories
project_data_path <- here("projectdata")
raw_data_path <- here("rawdata", proj)

cat(sprintf("Checking directories at: '%s' and '%s'\n", project_data_path, raw_data_path))

# Check if the directories exist
if (!dir.exists(project_data_path) || !dir.exists(raw_data_path)) {
  cat(sprintf("The subfolders for Project '%s' don't exist. \n", proj))
  cat("You have to provide a subfolder of your project within projectdata and rawdata \n")
  cat("Found in projectdata: \n")
  print(list.dirs(here("projectdata"), recursive = FALSE))
  cat("Found in rawdata: \n")
  print(list.dirs(here("rawdata"), recursive = FALSE))
} else {
  cat(sprintf("The subfolders for project '%s' seem to be in place.\n", proj))
  setwd(here("code"))
  source("Code.R")
  }