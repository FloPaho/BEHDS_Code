  # Code
{  # packages, directory & folder creation
{
  # install packages if needed and open them in the library
    {# Install and load packages
      if (!requireNamespace("dplyr", quietly = TRUE)) {
      install.packages("dplyr")
      }
      library(dplyr)
      
      if (!requireNamespace("readr", quietly = TRUE)) {
        install.packages("readr")
      }
      library(readr)
      
      
      if (!requireNamespace("knitr", quietly = TRUE)) {
        install.packages("knitr")
      }
      if (!requireNamespace("kableExtra", quietly = TRUE)) {
        install.packages("kableExtra")
      }
      
      if (!requireNamespace("DT", quietly = TRUE)) {
        install.packages("DT")
      }
      
      if (!requireNamespace("quarto", quietly = TRUE)) {
        install.packages("quarto")
      }
      library(quarto)
      
    # Install and load readxl
      if (!requireNamespace("readxl", quietly = TRUE)) {
      install.packages("readxl")
    }
      library(readxl)}
  
    # Define file paths
    { pbids <- file.path(path, "bids")
      pathdata <- file.path(path, "rawdata", proj)
      ppdata <- file.path(path, "projectdata", proj)
      pq <- file.path(path, "resources")
      pscr <- file.path(path, "code")
      pquarto = file.path(path,"code", "Quarto")}
  
  # creating the folder structure
    { # create the bids-folder
      setwd(path)
      if (!dir.exists("bids")) dir.create("bids")
      setwd(pbids)
      
      # create the project-folder
      if (dir.exists(proj)) {
        unlink(proj, recursive = TRUE)
      }
      
      dir.create(proj)
      pproj = file.path(path,"bids", proj, fsep="/")
      setwd(pproj)
      
      # create subfolders rawdata, sourcedata and 
      if (!dir.exists("rawdata")) dir.create("rawdata")
      prawdata = file.path(path,"bids", proj, "rawdata", fsep="/")
      
      if (!dir.exists("sourcedata")) dir.create("sourcedata")
      psourcedata = file.path(path,"bids", proj, "sourcedata", fsep="/")
      
      if (!dir.exists("derivatives")) dir.create("derivatives")
      pderivatives = file.path(path,"bids", proj, "derivatives", fsep="/")
      setwd(prawdata)
      
    }
  }
  
  #load project info  
{      setwd(ppdata)
      info = read_excel(paste0(proj, "_info.xlsx"))[-1, ]
      
      #define the variables from info
          Q=info[["Q"]][!is.na(info[["Q"]])]
          projdes=info[["projdes"]][!is.na(info[["projdes"]])]
          auth=info[["auth"]][!is.na(info[["auth"]])]
          ack=info[["ack"]][!is.na(info[["ack"]])]
          htack=info[["htack"]][!is.na(info[["htack"]])]
          fund=info[["fund"]][!is.na(info[["fund"]])]
          eth=info[["eth"]][!is.na(info[["eth"]])]
          ref=info[["ref"]][!is.na(info[["ref"]])]
          bidsversion=info[["bidsversion"]][!is.na(info[["bidsversion"]])]
          license=info[["license"]][!is.na(info[["license"]])]
          datadoi=info[["datadoi"]][!is.na(info[["datadoi"]])]
          readme=info[["readme"]][!is.na(info[["readme"]])]
          authors = auth
}
           
  # creating the json files
{
    for (Qb in Q)
  {
      
        
      # Generate the questionnaire file name based on the current questionnaire
          qname <- paste0(Qb, ".xlsx")
        
      # Check if the questionnaire file exists in ppdata
          if (file.exists(file.path(ppdata, qname))) {   
                  setwd(ppdata)
            
          } else if (file.exists(file.path(pq, qname))) {
            
                # Check if the file exists in pq if not found in ppdata
                  setwd(pq)
          } else {
            
                stop(paste("Data for the questionnaire", Qb, "does not exist"))
          }
      
      # Source the json.R file
          source(file.path(path, "code", "json.R"))
      
          
    }
      
  }

  
  # open the data
{     # Set the working directory to the project data folder
          setwd(pathdata)
  
      # List all files in the project data folder
          datalist <- list.files()
          
      # Set the working directory to the demographic information folder
          setwd(ppdata)
  
      # Generate the name of the project data file
          projdata <- paste0(proj, ".xlsx")
  
      # Check if the project data file exists
          if (!file.exists(projdata)){
          stop(paste("Data file", projdata, "not found in project data folder."))
          }
      
      # Read the Excel file, skipping the first row  to open projectdata
          tryCatch({part <-read_excel(projdata)
          }, error = function(e) {
            stop(paste("Please close the file", projdata))
          })
          part = part[-1,]
          
      # Creating empty demographic file   
          part_empty = data.frame(matrix(ncol = 1+length(na.omit(part$Itemname)), nrow = 0))
          colnames(part_empty) = c("participant_id" ,na.omit(part$Itemname))
  
      # Create a regular expression pattern for each questionnaire in Q
          Qs <-  paste0("(^|[^A-Za-z])", Q, "(?:_?-?[?\\d+\\[?\\d*\\]?)([^A-Za-z]|$)")
} 
  
  
  # creating folder structure for each participant and filling it with existing data
{     # Initialize a vector to store unique session values
          unique_ses_values <- c()
  
    # Loop over all files
  for (x in 1:length(datalist)) {
        
      # Set the working directory to the project data folder
          setwd(pathdata)
        
      # Read the data from the Excel file
    tryCatch({
      if (tolower(tools::file_ext(datalist[[x]])) == "xlsx" || tolower(tools::file_ext(datalist[[x]])) == "xls") {
        Data <- readxl::read_excel(datalist[[x]])
      } else if (tolower(tools::file_ext(datalist[[x]])) == "csv") {
        Data <- read.csv(datalist[[x]])
      } else {
        stop("Unsupported file format")
      }
    }, error = function(e) {
      stop(paste("Please close the file", datalist[[x]]))
    })
    
          char_cols <- sapply(Data, is.character)    
          Data[char_cols] <- lapply(Data[char_cols], function(x) gsub("[\r\n]", "", x))
    
    
          colnames(Data)[1] = "participant_id"
        
      # Format participant_id if it's integer
        if (is.numeric(Data$participant_id)) {
          Data$participant_id = sprintf("%03d", Data$participant_id)
          }
          Data <- Data %>%
            mutate(participant_id = gsub("[-_]", "", participant_id),
                   participant_id = gsub("[^a-zA-Z0-9 ]", "", participant_id))
          Data$participant_id = paste("sub-", Data$participant_id, sep = "")
          Data$participant_id = iconv(Data$participant_id, to = "ASCII//TRANSLIT")
     
      
      # number of different sessions  
          if ("ses" %in% colnames(Data)) {
          unique_ses_values <- union(unique_ses_values, unique(Data$ses))
          }   
          Max <- length(unique_ses_values)
          if(0%in%unique_ses_values){Max=Max-1}
      
      # Define variable names
          Names = c("participant_id", "session_id")
          
          if (NA %in% unique_ses_values) {
            stop(paste0("There is the name of the session missing for at least one row in ", datalist[[x]],". Please check if there is the data in column ses is colmplete!"))
          }
          
          
      
                # Loop over questionnaires
           for (z in 1:length(Q)) {
        
                    Qz = Q[z]
                    Qsz = Qs[z]
                    names=Names
      
                # Set the working directory to the questionnaires folder
                    setwd(pq)
                    var = paste0(Qz, ".xlsx")
                    if (file.exists(file.path(ppdata, var))) {   
                      setwd(ppdata)
                      
                    } else if (file.exists(file.path(pq, var))) {
                      
                      # Check if the file exists in pq if not found in ppdata
                      setwd(pq)
                    } else {
                      
                      stop(paste("Data for the questionnaire", Qb, "does not exist"))
                    }
                    
                    itemnames = read_excel(var)[-1, ]
      
                # Create a data frame for inverted items
                    data_inv = itemnames
                    itemnames = select(itemnames, Itemname)
                    itemnames = itemnames$Itemname[!is.na(itemnames$Itemname)]
        
                # Combine variable names and item names
                    names = c(names, itemnames)
        
              
                # Select relevant columns
                    if (!("ses" %in% colnames(Data))) {
                    print(paste("File", datalist[[x]], "does not have the column ses. Please include it."))
                    } else {
                    data <- select(Data, 1:2, matches(Qsz), -matches("(Time|time)"))
                      
                    if (ncol(data)>2) {
                    colnames(data) = names
                    
                    
            
                    # Loop for inverted items
                        for (a in 1:nrow(data_inv)) {
                                if (!is.na(data_inv$inverted[a])) {
                                if (is.na(data_inv$alternativescale[a])) {
                                inv_data = data_inv$levels
                                } else {
                                patt = paste0("levels",data_inv$alternativescale[a])
                                inv_data = data_inv[, grep(patt, names(data), value = TRUE)]
                                }
                                inv_data = na.omit(inv_data)
                                inv_data = as.numeric(inv_data)
                                inv_data_rev = rev(inv_data)
                                wanted_col = data_inv$Itemname[a]
                                
                                # Initialize a list to store the indices of matches
                                matches_indices <- list()
                                
                                # Loop through each element of inv_data and identify the indices of matches
                                for (i in seq_along(inv_data)) {
                                  matches_indices[[i]] <- which(data[[wanted_col]] == inv_data[i])
                                }
                                
                                # Loop through each index set in matches_indices
                                for (i in seq_along(matches_indices)) {
                                  # Get the indices of matches for the current element of inv_data
                                  current_indices <- matches_indices[[i]]
                                  
                                  # Replace values in wanted_col using the current_indices
                                  data[[wanted_col]][current_indices] <- inv_data_rev[i]
                                }
                                 
                                
                                
                                }
                        }
            
                   
                    
                    # Loop for each row in the file
                    for (y in 1:nrow(data)) {
                          subid = toString(data[y, 1])
                          ses = data[y, "session_id"]
                          sesid = paste0("ses-", ses)
                      
                          setwd(prawdata)
                      
                      # Create participant directory
                          ifelse(!dir.exists(subid), dir.create(subid), "Folder exists already")
                          setwd(file.path(path, "bids", proj, "rawdata", subid))
                      
                      
                      
                      # Select relevant data
                          subdata = data[y, ,drop = FALSE]
                          subdata[] = lapply(subdata, as.character)
                          subdata_control <- subdata[, -which(names(subdata) %in% c("participant_id", "session_id"))]
                        
                      # Write TSV file
                          if(apply(is.na(subdata_control), 1, all)==FALSE){
                          
                          # Create session directory
                          ifelse(!dir.exists(sesid), dir.create(sesid), "Folder exists already")
                          setwd(file.path(path, "bids", proj, "rawdata", subid, sesid))
                      
                          # Create behavioral directory
                          ifelse(!dir.exists("beh"), dir.create("beh"), "Folder exists already")
                          setwd(file.path(path, "bids", proj, "rawdata", subid, sesid, "beh"))
                          
                          file = paste0(subid, "_", sesid, "_task-", tolower(Qz), "_beh.tsv")
                          write_tsv(subdata, file = file, na = "n/a")}
                    }
                        }}
            }
                 

    # Generating participants.tsv
      
            for (c in 1:nrow(Data)) {
                  
                  # Select relevant data columns for demographics.tsv
                      pdata= select(Data,1, matches(paste0("^(", paste(na.omit(part$Itemname), collapse = "|"), ")$")))
                      pdata= pdata[c,]
                      
                  # Extract participant_id
                      participant_id = pdata$participant_id
                      
                  # Remove participant_id from pdata
                      pdata = pdata[, -1]
                      
                  # Add the data to the appropriate columns in part_empty
                      part_empty[participant_id, names(pdata)] = pdata
                  }
                  
                  
          }
        
            # Convert row names of part_empty to participant_id
                part_empty$participant_id = rownames(part_empty)
                rownames(part_empty) = NULL
        
            #Labeling sex
                if (!is.na(part[which(part$Itemname == "sex"),"alternativescale"])) {
                  part_empty$sex = factor(part_empty$sex,
                                  labels = na.omit(part[[paste0("leveldescription",part[which(part$Itemname == "sex"),"alternativescale"])]]),
                                  levels = as.numeric(na.omit(part[[paste0("levels",part[which(part$Itemname == "sex"),"alternativescale"])]])))
                } else {
                  part_empty$sex = factor(part_empty$sex, labels = na.omit(part$leveldescription),levels = na.omit(part$levels))
                }
              
                    
            # writing demographics.tsv
                setwd(prawdata)
                write_tsv(part_empty, file = "participants.tsv",na = "n/a")
            }
      

  
  # participants.json generieren
{     setwd(pscr)
      source("jsondemographics.R")
}

  # Generate dataset_description.json
{
      dataset_description = '{
    "Name": "PROJECTDESCRIPTION",
    "BIDSVersion": "BIDSVERSION",
    "License": "LICENSE",
    "Authors": [
      AUTHORS
    ],
    "Acknowledgements": "ACKNOWLEDGMENTS",
    "HowToAcknowledge": "HOWTOACKNOWLEDGE",
    "Funding": [
      "FUNDING"
    ],
    "EthicsApprovals": [
      "ETHICSAPPROVALS"
    ],
    "ReferencesAndLinks": [
      REFERENCESANDLINKS
    ],
    "DatasetDOI": "DATASETDOI"
  }'
  
      # Combine authors with commas and newline characters
          auth = paste0('"', auth, '"', collapse = ',\n')
  
      # Create a named vector of values with checks for empty character vectors
          values <- c(
              "PROJECTDESCRIPTION" = ifelse(length(projdes) == 0, "", projdes),
    "BIDSVERSION" = ifelse(length(bidsversion) == 0, "", bidsversion),
    "LICENSE" = ifelse(length(license) == 0, "", license),
    "AUTHORS" = ifelse(length(auth) == 0, "", auth),
    "ACKNOWLEDGMENTS" = ifelse(length(ack) == 0, "", ack),
    "HOWTOACKNOWLEDGE" = ifelse(length(htack) == 0, "", htack),
    "FUNDING" = ifelse(length(fund) == 0, "", fund),
    "ETHICSAPPROVALS" = ifelse(length(eth) == 0, "", eth),
    "REFERENCESANDLINKS" = ifelse(length(ref) == 0, "", ref),
    "DATASETDOI" = ifelse(length(datadoi) == 0, "", datadoi)
  )
          
      # Replace placeholders with actual values
          for (key in names(values)) {
              dataset_description <- gsub(key, values[key], dataset_description)
          }    
    
      # Set working directory to the raw data folder
          setwd(prawdata)
    
      # Write dataset_description.json file
          write(dataset_description, file = "dataset_description.json",
          ncolumns = if(is.character(df)) 1 else 5,
          append = FALSE, sep = "\n")
  }


  # Write  README file
{
      write(
      readme,
      file = "README",
      ncolumns = if (is.character(readme)) 1 else 5,
      append = FALSE,
      sep = " ")
}


#copy projectdata and rawdata into sourcedata
setwd(psourcedata)
dir.create("projectdata") 
dir.create("rawdata")
file.copy(from = pathdata, to = file.path(psourcedata, "rawdata"), recursive = TRUE, overwrite = TRUE)
file.copy(from = ppdata, to = file.path(psourcedata, "projectdata"), recursive = TRUE, overwrite = TRUE)
  
# combine data
setwd(pscr)
source("Script combine.R")

#render the quarto file
projname = paste0(proj, ".html")
if(length(authors)>1){authors = paste(paste(head(authors, -1), collapse = ", "),"&", tail(authors, 1))}
date = info$year[1]
setwd(pquarto)
quarto_render(
  input = "quarto_info.qmd",
  output_file = projname,
  execute_params = list(proj = proj, authors = authors, date = date)
)
file.rename(from = file.path(pquarto, projname), 
          to = file.path(pderivatives, projname))

#rm(list = setdiff(ls(), c("output","output_filtered", "output_raw")))
}
