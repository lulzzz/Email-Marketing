# Plots distribution of Time of day when mail was sent
# To run first change the path of file stored in variable file_path

library(data.table)
library(ggplot2)
library(scales)

file_path <- "/home/fatigue_internship/data/WW/OSPG_LB-20150326.csv" 

DT <- fread(file_path)

setnames(DT, old = c("OPEN DATE", "SEND DATE", "CLICK DATE"), new = c("OPENDATE", "SENDDATE", "CLICKDATE"))

DT2 <- DT[, .(deliveryDate = as.POSIXct(strftime(strptime(SENDDATE, "%Y-%m-%dT%H:%M:%SZ"), format="%H:%M:%S"), format="%H:%M:%S"), SENDDATE)]

DT2[1:10]

ggplot(DT2, aes(x = deliveryDate)) + geom_histogram(binwidth=1000) + labs(title="Time of day when mail was sent") + labs(x="Time", y="Number of mails sent") + scale_x_datetime(labels = date_format("%H:%M:%S"), date_breaks="4 hours") + theme_bw()
