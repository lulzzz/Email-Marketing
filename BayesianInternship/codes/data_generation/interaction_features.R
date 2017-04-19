library(data.table)

# file_path_non_zero_rids is the path to the text file that contains all the file names that are valid (i.e. those that contain non-zero recipient ids)
file_path_non_zero_rids <- "/home/fatigue_internship/output_statistics/data_info/output_LB.txt"
file_list <- readLines(con=file_path_non_zero_rids)



# END_DATE_FOR_DATA is the end date for covariate period and START_DATE_FOR_DATA is the start date.
# covariate period is the period over which the covariates have been computed
# modelling window is used to generate rows as sliding window. Read on to understand it better!
END_DATE_FOR_DATA = strptime("09-03-2015", "%d-%m-%Y")
START_DATE_FOR_DATA = strptime("07-03-2015", "%d-%m-%Y")
MODELLING_WINDOW = 3


# So for instance if the start date in 01/03 and end date is 30/03 with
# modelling window as 15, then the entries will be of the following form:
# 1. Covariates computed from 1 to 30 March - Prediction on 1 April 
# 2. Covariates computed from 2 March to 1 April - Prediction on 2 April 
# and so on till Covariates computed from 15 March to 14 April - Prediction on 15 April


full_data <- NULL

for(i in 1:10){
#for(i in 1:length(file_list)){
  
  # folder_path contains the path to the folder containing all the csv files
  folder_path <- "/home/fatigue_internship/data/LB/"
  
  DT <- fread(paste(folder_path, file_list[i], sep=""), drop=38:136)     # Drop the Department columns for now
  
  print(paste(file_list[i], "-----------------------------------------------------------"))
  
  setnames(DT, old = c("CLIENT CODE", "CAMPAIGN CODE", "CAMPAIGN DESCRIPTION", "CONTACT DATE", "SEND DATE", "SEND STATUS", "OPEN DATE", "CLICK DATE", "UNSUBSCRIBE DATE", "RECIPIENT ID", "USER COMPLAIN", "USER COMPLAIN DATE", "ORDER DATE", "TOTAL ORDERS VALUE"), new = c("CLIENTCODE", "CAMPAIGNCODE", "CAMPAIGNDESCRIPTION", "CONTACTDATE", "SENDDATE", "SENDSTATUS", "OPENDATE", "CLICKDATE", "UNSUBSCRIBEDATE", "RECIPIENTID", "USERCOMPLAIN", "USERCOMPLAINDATE", "ORDERDATE", "TOTALORDERSVALUE"))
  
  DT[, CONTACTDATE := strptime(CONTACTDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  DT[, SENDDATE := strptime(SENDDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  DT[, OPENDATE := strptime(OPENDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  DT[, CLICKDATE := strptime(CLICKDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  DT[, UNSUBSCRIBEDATE := strptime(UNSUBSCRIBEDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  DT[, USERCOMPLAINDATE := strptime(USERCOMPLAINDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  DT[, ORDERDATE := strptime(ORDERDATE, format="%Y-%m-%dT%H:%M:%SZ")]
  
  #print(str(DT))
  print(paste("Before: ", nrow(DT)))
  
  DT <- DT[as.integer(SENDSTATUS) == 1 & as.integer(RECIPIENTID) != 0]    #SENDSTATUS = 2 means temporary failure (see https://wiki.corp.adobe.com/pages/viewpage.action?pageId=981323381 for details)
  
  print(paste("After: ", nrow(DT)))
  
  full_data[[i]] <- DT
  
}

rm(DT)
full_data <- rbindlist(full_data)

temp_data <- NULL

for(j in 0:MODELLING_WINDOW){
  
  ## Get all the rows of data within the sliding covariate period
  
  print(j)
  
  all_data <- full_data[CONTACTDATE >= strptime(as.character(as.Date(START_DATE_FOR_DATA) + j), "%Y-%m-%d") & CONTACTDATE <= strptime(as.character(as.Date(END_DATE_FOR_DATA) + j), "%Y-%m-%d")]
  
  ## First we create covariate rows ##
  print("Now creating covariate rows")
  covariate_rows <- setnames(all_data[as.integer(SENDSTATUS) == 1, max(SENDDATE), by = (RECIPIENTID)], c("RECIPIENTID", "SENDDATE"))
  covariate_rows$Flag <- 1
  #setkey(all_data, "RECIPIENTID", "SENDDATE")
  #setkey(covariate_rows, "RECIPIENTID", "MAXSENDDATE")
  all_data <- merge(all_data, covariate_rows, all = TRUE)
  print("Done creating covariate rows")
  
  
  ## Time now to create covariates ##
  ## Number of mails sent ##
  print("--------------------------------------Creating covariate: Number of mails sent---------------------------")
  sent <- setnames(all_data[, length(SENDSTATUS[as.integer(SENDSTATUS) == 1]), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTSENT"))
  sent$Flag <- 1
  all_data <- merge(all_data, sent, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating mails sent------------------------------------------")
  
  
  ## Number of mails opened ##
  print("--------------------------------------Creating covariate: Number of mails opened---------------------------")
  open <- setnames(all_data[, length(OPENED[as.integer(OPENED) > 0]), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTOPENED"))
  open$Flag <- 1
  all_data <- merge(all_data, open, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating mails opened------------------------------------------")
  
  
  
  
  ## Number of mails clicked ##
  print("--------------------------------------Creating covariate: Number of mails clicked---------------------------")
  click <- setnames(all_data[, length(CLICKED[as.integer(CLICKED) > 0]), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTCLICKED"))
  click$Flag <- 1
  all_data <- merge(all_data, click, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating mails clicked------------------------------------------")
  
  
  
  
  ## Number of mails unsubscribed ##
  print("--------------------------------------Creating covariate: Number of mails unsubscribed---------------------------")
  unsubscribed <- setnames(all_data[, length(UNSUBSCRIBE[as.integer(UNSUBSCRIBE) > 0]), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTUNSUBSCRIBED"))
  unsubscribed$Flag <- 1
  all_data <- merge(all_data, unsubscribed, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating mails unsubscribed------------------------------------------")
  
  
  
  ## Number of complains ##
  print("--------------------------------------Creating covariate: Number of complains---------------------------")
  complains <- setnames(all_data[, length(USERCOMPLAIN[as.integer(USERCOMPLAIN) > 0]), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTCOMPLAINS"))
  complains$Flag <- 1
  all_data <- merge(all_data, complains, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating complaints------------------------------------------")
  
  
  
  
  ## Number of orders ##
  print("--------------------------------------Creating covariate: Number of orders---------------------------")
  orders <- setnames(all_data[, sum(as.integer(ORDER)), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTORDERS"))
  orders$Flag <- 1
  all_data <- merge(all_data, orders, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating orders------------------------------------------")
  
  
  ## Total amount of purchase ##
  print("--------------------------------------Creating covariate: Total amount of purchase---------------------------")
  orders <- setnames(all_data[, sum(as.numeric(TOTALORDERSVALUE)), by = "RECIPIENTID"], c("RECIPIENTID", "COUNTORDERVALUE"))
  orders$Flag <- 1
  all_data <- merge(all_data, orders, by = c("RECIPIENTID", "Flag"), all = TRUE)
  print("---------------------------------------Done creating amount of purchase------------------------------------------")
  
  print(paste("Before:", nrow(all_data)))
  
  all_data <- all_data[Flag==1]
  
  print(paste("After:", nrow(all_data)))
  
  
  temp_data[[j+1]] <- all_data
  
  
}

rm(all_data)
temp_data <- rbindlist(temp_data)

output_file_path <- "/home/fatigue_internship/output_statistics/all_data/training_data.csv"

print("Now writing---------------------")

write.csv(temp_data, file = output_file_path)

print("-------------Done-----------------")
