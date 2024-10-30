#Demografische Daten definieren und anschließend Spalten auswählen
    variablename = c("participant_id", "session_id")
    variabledescription = c("Unique participant identifier", "Session identifier")

#Anfang und Ende
    alpha='{'
    omega='}'

#FragebögeN
    file="task-NAME_beh.json"  
    file=gsub("NAME", Qb, file)
    file = tolower(file)
  
  #Daten öffnen
  jdata = read_excel(qname)
  jdata = jdata[-1,]
  setwd(prawdata)
  
  #Anfang schreiben
      write(alpha, file = file,
        ncolumns = if(is.character(df)) 1 else 5,
        append = FALSE, sep = "\n")
  
  # Writing Metadata of the Questionnaire   
      meta = paste0('"TaskName": "', Qb, '",')
      write(meta, file = file,
            ncolumns = if(is.character(df)) 1 else 5,
            append = TRUE, sep = "\n")
      
  #Demografische Daten
  #Schleife für Text für DEMO
  for (g in 1:2) {
    
    #Demotext definieren  
    Demotext='
"VARNAME": {
  "Description": "VARDES"
     },
'  
    #Zeilenauswahl
    Varname=variablename[g]
    Vardes=variabledescription[g]
    
    #Platzhalter austauschen
    Demotext=gsub("VARNAME", Varname, Demotext)
    Demotext=gsub("VARDES", Vardes, Demotext)
    
    #Umwandeln in String
    Demotext= toString(Demotext)
    
    #File schreiben
    write(Demotext, file = file,
          ncolumns = if(is.character(df)) 1 else 5,
          append = TRUE, sep = "\n")
  }
  
  
  jdata_Items=jdata$Itemname[!is.na(jdata$Itemname)]
  
  
  #Schleife für Item definieren
  for(i in 1:length(jdata_Items)) {
    
    
    
    
    
    #Reihen auswählen
    Itemname=select(jdata,Itemname)
    Itemdescription = paste0(i, ". Item of the Questionnaire ", Qb)
    altskala=select(jdata,alternativescale)
    altskala$alternativescale = as.numeric(altskala$alternativescale)
    altskala[is.na(altskala)] = 1
    Test=select(jdata,levels)
    Leveldescription= select(jdata,leveldescription)
    
    if((altskala[c(i),])!=1){
      Test=select(jdata,paste0("levels",altskala[c(i),]))
      Leveldescription= select(jdata,paste0("leveldescription",altskala[c(i),]))
    }
    
    Test=na.omit(Test)
    Leveldescription= Leveldescription[1:nrow(Test),]
    String=select(jdata,open)
    String[is.na(String)] = "No"
    Unit=select(jdata,unit)
    Unit[is.na(Unit)] = "No"
    
    
    #Zeilenauswahl
    Itemname=Itemname[c(i),]
    
    
    #Text oder Skala
    
    if (String[c(i),]=="No") {
      
      
      
      #Text definieren
      
      if(i==length(jdata_Items)){  
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
      
      #Inverierte Reihe auswählen und leere Kästchen befüllen mit "No"
      Inverted= select(jdata,inverted)
      Inverted[is.na(Inverted)] = "No"
      
      
      #Zeilenauswahl
      inverted=Inverted[c(i),]
      
      #jdataframe für levels definieren
      levels=101:(100+nrow(Test))
      
      
      #Schleife für levels
      for (j in 1:nrow(Test)) {
        
        #Text definieren
        leveltext='"LVL":"DES"'
        
        #invertierte Laufnummer definieren
        invj=nrow(Test)+1-j
        
        #Zeilenauswahl
        
        if (inverted=="No") {
          level=Test[c(j),]
        } else {
          level=Test[c(invj),]
        }
        if(!is.na(Leveldescription[c(j),])) {leveldescription=Leveldescription[c(j),]} else {leveldescription=""}
        
        #Platzhalter im Text austauschen
        leveltext=gsub("LVL", level, leveltext)
        leveltext=gsub("DES", leveldescription, leveltext)
        
        #Laufende Nr in levles definieren
        
        
        lvl=100+j
        #Nr in levels durch leveltext ersetzen
        levels=gsub(lvl, leveltext, levels)
        
      }
      
      #levels in String umwandeln
      levels= toString(levels)
      
      #Ersetzen der Platzhalter im Text mit Variablen
      text=gsub("LEVELS", levels, text)
      
    } else {    
      
      
      if(i==length(jdata_Items)){  
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
    
    
    #Wenn es eine spezielle Einheit gibt, soll diese verwendet werden sonst Leerzeichen  
    if (Unit[c(i),]=="No") {
      Unit=''
    } else {
      Unit=Unit[c(i),]
    }
    
    #Ersetzen der Platzhalter im Text mit Variablen
    text=gsub("ITEMNAME", Itemname, text)
    text=gsub("ITEMDESCRIPTION", Itemdescription, text)
    
    text=gsub("UNIT", Unit, text)
    
    
    
    
    #File schreiben
    write(text, file = file,
          ncolumns = if(is.character(df)) 1 else 5,
          append = TRUE, sep = "\n")
    
    
    
    
    }
    
  
  #Ende schreiben
  write(omega, file = file,
        ncolumns = if(is.character(df)) 1 else 5,
        append = TRUE, sep = "\n")

