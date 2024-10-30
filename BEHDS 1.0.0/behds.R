#enter the Project name                                                                                    Script by Florian Pahovnikar
proj="Example"


















































if (!requireNamespace("rstudioapi", quietly = TRUE)) {
  install.packages("dplyr")
}
path=dirname(rstudioapi::getSourceEditorContext()$path)
setwd(file.path(path,"code"))
source("Code.R")

