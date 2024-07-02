#enter the Project name                                                                                    Script by Florian Pahovnikar
proj="Example"

path=dirname(rstudioapi::getSourceEditorContext()$path)
setwd(file.path(path,"code"))
source("Code.R")

