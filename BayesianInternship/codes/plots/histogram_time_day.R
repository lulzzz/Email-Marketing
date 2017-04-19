# Plots the distribution of Time of day when mail was opened
# To run first change the path of file in variable file_path

library(data.table)
library(ggplot2)
library(scales)

file_path <- "/home/fatigue_internship/data/WW/OSPG_LB-20150326.csv" 

DT <- fread(file_path)

setnames(DT, old = c("OPEN DATE", "SEND DATE", "CLICK DATE"), new = c("OPENDATE", "SENDDATE", "CLICKDATE"))

DT2 <- DT[OPENED > 0, .(openDate = as.POSIXct(strftime(strptime(OPENDATE, "%Y-%m-%dT%H:%M:%SZ"), format="%H:%M:%S"), format="%H:%M:%S"), open = as.integer(OPENED > 0), OPENDATE)]

DT2[1:10]

ggplot(DT2, aes(x = openDate)) + geom_histogram(binwidth=1200) + labs(title="Time of day when mail was opened") + labs(x="Time", y="Number of mails opened") + scale_x_datetime(labels = date_format("%H:%M:%S"), date_breaks="2 hours") + theme_bw()
