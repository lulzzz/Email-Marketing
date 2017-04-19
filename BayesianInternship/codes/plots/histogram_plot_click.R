# Plots the distribution of Time to Click
# To run first change the path of the file stored in variable file_path

library(data.table)
library(ggplot2)

file_path <- "/home/fatigue_internship/data/WW/OSPG_LB-20150326.csv" 

DT <- fread(file_path)
# str(DT)

setnames(DT, old = c("OPEN DATE", "CLICK DATE"), new = c("OPENDATE", "CLICKDATE"))

DT2 <- DT[OPENED > 0 & CLICKED > 0, .(diff = as.numeric(difftime(strptime(CLICKDATE, "%Y-%m-%dT%H:%M:%SZ"), strptime(OPENDATE, "%Y-%m-%dT%H:%M:%SZ"), units="mins")), open = as.integer(OPENED > 0), open_date = OPENDATE)]

dim(DT2)
DT2[1:10]

#ggplot(DT2, aes(x = diff)) + geom_histogram(breaks=seq(0, 2.5, by=0.01)) + xlim(c(0, 2.5)) + xlab("Difference in minutes")

ggplot(DT2, aes(x = diff)) + geom_histogram(binwidth = 0.05) + theme_bw() + xlab("Diff in minutes") + xlim(c(0, 7.5)) + labs(title="Elapsed time (in mins) between the time mail was opened and clicked")



