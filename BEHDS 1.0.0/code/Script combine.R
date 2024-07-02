# Set your working directory to the project folder
{
setwd(prawdata)
Ql = tolower(Q)
}

#get demographic data
{
  combined_dem = read.delim("participants.tsv", header = TRUE, sep = "\t",na.strings = "n/a", check.names = FALSE)  # Assuming TSV files are tab-separated
  assign("demographics", combined_dem)
}


for (q in Ql) {
  
  # Generate a list of files matching the pattern
  tsv_files <- list.files(pattern = (paste0(q, "_beh.tsv$")), recursive = TRUE, full.names = TRUE)
  if(length(tsv_files)>0){
  
  # Initialize an empty list to store data frames
  data_frames = list()
  
  # Read data from each TSV file and store it in the list
  for (file in tsv_files) {
    data = read.delim(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE, na.strings = "n/a", check.names = FALSE)
    #if more than one session than put the session as suffix
    if (Max>1) {
      
      # Extract folder name from the file path
      folder_name = basename(dirname(dirname(file)))
      
      # Modify column names (starting from the third column)
      colnames(data)[3:ncol(data)] = paste0(colnames(data)[3:ncol(data)], "_", folder_name)
      
    }
    
      data_frames[[file]] = data
  }
  # Combine all data frames into one large data frame
  
  for (session in unique_ses_values) {
    pattern = "ses-X"
    pattern = gsub("X",session,pattern) 
    filtered_dataframes <- data_frames[sapply(names(data_frames), function(df_name) grepl(pattern, trimws(df_name)))]
    combined_data = do.call(rbind, filtered_dataframes)
    pattern2 = "ses_X"
    pattern2 = gsub("X",session,pattern2) 
    assign(pattern2, combined_data)
  }
  
  data_comb = data.frame()
  
  

  for (w in unique_ses_values) {
  
  pattern2 = "ses_X"
  pattern2 = gsub("X",w,pattern2)
  data_to_merge = get(pattern2)
  
  
  if(nrow(data_comb)==0){
  
  data_comb = rbind(data_to_merge,data_comb)
  
  } else {
  if(!is.null(data_to_merge)){
  data_comb = merge(data_comb, data_to_merge, by = "participant_id", all = TRUE)  
  }
  }
  data_comb =  select(data_comb,-matches("session_id"))
  assign(q, data_comb)}
  }  
}

for (t in 1:length(Ql)) {

  if (exists(Ql[t])) {
    merge_data <- get(Ql[t])
 

if(t==1){
 output =  merge(demographics, merge_data , by = "participant_id", all = TRUE) 
 } else{
output =  merge(output, merge_data , by = "participant_id", all = TRUE)

 }
  
 }

}

# creating output_raw
output_raw = output

#crating output_filtered
output_filtered = output_raw[,1:ncol(demographics)]

# Loop through the elements of Q
for (d in 1:length(Q)) {
  if (exists(Ql[d])) {
  Qd = Q[d]
  
  # Construct the file name based on Qd
  var = "VAR.xlsx"
  var = gsub("VAR", Qd, var)
  
  
  if (file.exists(file.path(ppdata, var))) {   
    setwd(ppdata)
    
  } else if (file.exists(file.path(pq, var))) {
    
    # Check if the file exists in pq if not found in ppdata
    setwd(pq)
  } else {
    
    stop(paste("Data for the questionnaire", Qd, "does not exist"))
  }
  
  
  # Read data from Excel file
  data_quest = read_excel(var)
  data_quest = data_quest[-1,]  # Remove the first row
  if(0%in%unique_ses_values){unique_ses_valuesb=unique_ses_values[unique_ses_values != 0]}else{unique_ses_valuesb=unique_ses_values}

  # Check if subscalescore is not NA
  if (!is.na(data_quest[1,"subscalescore"])) {
    
    for (f in unique_ses_valuesb) {
      text_ses = paste0("_ses-", f)
      
      
      #get the name of all subscales
      dif_sub = na.omit(unique(data_quest[!grepl("\\|", data_quest[["subscale"]]), "subscale"]))
      dif_sub = unlist(dif_sub)
      
      for (g in 1:length(dif_sub)) {
        
      #choose the Items that match the subscale
      items = data_quest[grepl(dif_sub[g], data_quest[["subscale"]]), "Itemname"]
      items = unlist(items)
      
      # Add session suffix if Max is greater than 1
      if (Max > 1) {
        items = paste0(items, text_ses)
      }
      
      # Calculate subscalescore based on conditions
      if (data_quest[1,"subscalescore"] == "sum") {
        subscalescore = round(rowSums(output[, items]),2)
      } else if (data_quest[1,"subscalescore"] == "mean") {
        subscalescore = round(rowMeans(output[, items]),2)
      } else {
        print("subscalescore is only programmed for sum and mean. Please contact Florian Pahovnikar")
      }
      
      # Create column name for subscalescore
      name_subscalescore = ifelse(Max > 1, paste(Qd, "subscale" , dif_sub[g], text_ses, sep="_"), paste(Qd, "subscale", dif_sub[g], sep="_"))
      
      subscalescore = data.frame(subscalescore)
      colnames(subscalescore) = name_subscalescore
      
      # Add subscalescore to the output data frame
      output = cbind(output, subscalescore)
      
      # Add subscalescore to the output_filtered data frame
      output_filtered = cbind(output_filtered, subscalescore)
    }}
  }
  
  if (!is.na(data_quest[1,"totalscore"])) {
    for (e in unique_ses_valuesb) {
      text_ses = paste0("_ses-", e)
      items <- na.omit(data_quest$Itemname)
      
      # Add session suffix if Max is greater than 1
      if (Max > 1) {
        items = paste0(items, text_ses)
      }
      
      # Calculate totalscore based on conditions
      if (data_quest[1,"totalscore"] == "sum") {
        totalscore = round(rowSums(output[, items]),2)
      } else if (data_quest[1,"totalscore"] == "mean") {
        totalscore = round(rowMeans(output[, items]),2)
      } else {
        print("Totalscore is only programmed for sum and mean. Please contact Florian Pahovnikar")
      }
      
      # Create column name for totalscore
      name_totalscore = ifelse(Max > 1, paste(Qd, "_", data_quest[1,"totalscore"], text_ses, sep=""), paste(Qd, "_", data_quest[1,"totalscore"], sep=""))
      
      totalscore = data.frame(totalscore)
      colnames(totalscore) = name_totalscore
      
      # Add totalscore to the output data frame
      output = cbind(output, totalscore)
      
      # Add totalscore to the output_filtered data frame
      output_filtered = cbind(output_filtered, totalscore)
    }
  }

  #check if subscalescore and totalscore are NA
  if (is.na(data_quest[1,"subscalescore"])&is.na(data_quest[1,"totalscore"])) {
    nosubandnots= select(output, matches(data_quest$Itemname)) 
    output_filtered = cbind(output_filtered, nosubandnots)}
  }
}

#writing the output files
{setwd(pderivatives)
dir.create("data_all_cases")
setwd(file.path(pderivatives, "data_all_cases")) 
file_name = paste(proj, ".csv", sep = "")
write.csv(output,file = file_name, row.names = FALSE, na = "")

file_name = paste(proj, "_raw.csv", sep = "")
write.csv(output_raw,file = file_name, row.names = FALSE, na = "")

file_name = paste(proj, "_filtered.csv", sep = "")
write.csv(output_filtered,file = file_name, row.names = FALSE, na = "")}