# Set the working directory to rawdata folder
setwd(prawdata) 

# Beginning and End markers for JSON file
alpha <- '{'
omega <- '}'

# Write the beginning marker to the JSON file
write(alpha, file = "participants.json",
      ncolumns = if (is.character(df)) 1 else 5,
      append = FALSE, sep = "\n")

# Extract variable names and descriptions from the 'demographics' DataFrame
variablename = c("participant_id", "session_id")
variabledescription = c("Unique participant identifier", "Session identifier")

# Define a template for each variable in the JSON file  
Demotext='
"VARNAME": {
  "Description": "VARDES"
     },
'  
# Zeilenauswahl
Varname=variablename[1]
Vardes=variabledescription[1]

# Platzhalter austauschen
Demotext=gsub("VARNAME", Varname, Demotext)
Demotext=gsub("VARDES", Vardes, Demotext)

# Umwandeln in String
Demotext= toString(Demotext)

# File schreiben
write(Demotext, file = "participants.json",
      ncolumns = if(is.character(df)) 1 else 5,
      append = TRUE, sep = "\n")

# Schleife für Item definieren
for(i in 1:length(na.omit(part[["Itemname"]]))) {
  # Reihen auswählen
  Itemname=select(part,Itemname)
  Itemdescription=select(part,Itemdescription)
  altskala=select(part,alternativescale)
  altskala$alternativescale = as.numeric(altskala$alternativescale)
  altskala[is.na(altskala)] = 1
  Test=select(part,levels)
  Leveldescription= select(part,leveldescription)
  
  
  if(altskala[c(i),]==2){
    Test=select(part,levels2)
    Leveldescription= select(part,leveldescription2)
  }
  
  if(altskala[c(i),]==3){
    Test=select(part,levels3)
    Leveldescription= select(part,leveldescription3)
  }
  
  if(altskala[c(i),]==4){
    Test=select(part,levels4)
    Leveldescription= select(part,leveldescription4)
  }
  
  Test=na.omit(Test)
  Leveldescription= na.omit(Leveldescription)
  String=select(part,open)
  String[is.na(String)] = "No"
  Unit=select(part,unit)
  Unit[is.na(Unit)] = "No"
  
  
  # Zeilenauswahl
  Itemname=Itemname[c(i),]
  Itemdescription=Itemdescription[c(i),]
  
  
  # Text oder Skala
  
  if (String[c(i),]=="No") {
    
    
    
    # Text definieren
    
    if(i==length(na.omit(part[["Itemname"]]))){  
      text='
"ITEMNAME": { 
  "Description": "ITEMDESCRIPTION",
  "Levels":{
  LEVELS
      }
}
    
    ' }
  else{
    
    
    text='
"ITEMNAME": { 
  "Description": "ITEMDESCRIPTION",
  "Levels":{
  LEVELS
      }
      },
    
    
    ' } 
  
  # Inverierte Reihe auswählen und leere Kästchen befüllen mit "No"
  Inverted= select(part,inverted)
  Inverted[is.na(Inverted)] = "No"
  
  
  # Zeilenauswahl
  inverted=Inverted[c(i),]
  
  # partframe für levels definieren
  levels=101:(100+nrow(Test))
  
  
  # Schleife für levels
  for (j in 1:nrow(Test)) {
    
    # Text definieren
    leveltext='"LVL":"DES"'
    
    # invertierte Laufnummer definieren
    invj=nrow(Test)+1-j
    
    # Zeilenauswahl
    
    if (inverted=="No") {
      level=Test[c(j),]
    } else {
      level=Test[c(invj),]
    }
    if(!is.na(Leveldescription[c(j),])) {leveldescription=Leveldescription[c(j),]} else {leveldescription=""}
    
    # Platzhalter im Text austauschen
    leveltext=gsub("LVL", level, leveltext)
    leveltext=gsub("DES", leveldescription, leveltext)
    
    # Laufende Nr in levles definieren
    
    
    lvl=100+j
    # Nr in levels durch leveltext ersetzen
    levels=gsub(lvl, leveltext, levels)
    
  }
  
  # levels in String umwandeln
  levels= toString(levels)
  
  # Ersetzen der Platzhalter im Text mit Variablen
  text=gsub("LEVELS", levels, text)
  
  } else {    
    
    
    if(i==length(na.omit(part[["Itemname"]]))){  
      text='
"ITEMNAME": { 
  "Description": "ITEMDESCRIPTION",
  "Levels": {
    },
    "Units": "UNIT"}
    
    
    
    ' }
    else{
      text='
"ITEMNAME": { 
  "Description": "ITEMDESCRIPTION",
  "Levels": {
    },
    "Units": "UNIT"},
    
    
    ' } }


# Wenn es eine spezielle Einheit gibt, soll diese verwendet werden sonst Leerzeichen  
if (Unit[c(i),]=="No") {
  Unit=''
} else {
  Unit=Unit[c(i),]
}

# Ersetzen der Platzhalter im Text mit Variablen
text=gsub("ITEMNAME", Itemname, text)
if(is.na(Itemdescription[1,1])){
  text=gsub("ITEMDESCRIPTION", '', text) 
}else{
text=gsub("ITEMDESCRIPTION", Itemdescription, text)
}
text=gsub("UNIT", Unit, text)




# File schreiben
write(text, file = "participants.json",
      ncolumns = if(is.character(df)) 1 else 5,
      append = TRUE, sep = "\n")
}


# Ende schreiben
write(omega, file = "participants.json",
      ncolumns = if(is.character(df)) 1 else 5,
      append = TRUE, sep = "\n")