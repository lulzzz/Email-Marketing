# Generates list of all files which are valid (have non-zero recipient ids)

brand_list = c("BO", "JL", "KS", "LB", "OS", "RD")

for (j in brand_list){
  folder_path = paste("/home/fatigue_internship/data/", j, sep="")
  print(folder_path)
  
  file_list <- list.files(path=folder_path, pattern = ".*\\.csv$")
  library(data.table)
  
  file.create(paste("/home/fatigue_internship/data/output_", j, ".txt", sep=""))
  
  for (i in file_list){
    path <- paste(folder_path, "/", i, sep="")
    print(path)
    DT <- fread(path)
    unique_recipientIds <- unique(DT$"RECIPIENT ID")
    if(length(unique_recipientIds) > 1){
      write(i,file=paste("/home/fatigue_internship/data/output_", j, ".txt", sep=""),append=TRUE)
    }
  }
}









