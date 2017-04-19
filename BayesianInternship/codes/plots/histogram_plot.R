# Plots the distribution of Time to Open
# To run first change the path of the file stored in variable file_path

library(data.table)
library(ggplot2)
library(scales)

file_path <- "/home/fatigue_internship/data/LB/OSPG_LB-20150227.csv" 

DT <- fread(file_path)

setnames(DT, old = c("OPEN DATE", "SEND DATE"), new = c("OPENDATE", "SENDDATE"))

DT2 <- DT[OPENED > 0, .(diff = as.numeric(difftime(strptime(OPENDATE, "%Y-%m-%dT%H:%M:%SZ"), strptime(SENDDATE, "%Y-%m-%dT%H:%M:%SZ"), units="hours")), open = as.integer(OPENED > 0), OPENDATE, SENDDATE)]

DT2[1:10]

ggplot(DT2, aes(x = diff)) + geom_histogram(binwidth = 0.5) + theme_bw() + xlab("Diff in hours") + ylab("Number of mails") + xlim(0, 200) + labs(title="Elapsed time (in hours) between the time mail was sent and opened")

# ggplot(DT2, aes(x = diff)) + geom_histogram(breaks=seq(0, 10, by=0.5)) + xlim(c(0, 10)) + xlab("Difference in minutes")




