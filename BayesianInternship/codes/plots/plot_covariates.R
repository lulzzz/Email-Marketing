# Code to generate descriptive stats of demographic features

library(data.table)
library(ggplot2)
library(scales)

# Path to file containing the entire data. Note that this file is different from the feature vector file.
file_path <- "/home/fatigue_internship/output_statistics/features_revised_1/covariates_data_excluding_content_revised.csv"

all_data <- fread(file_path, na.strings=c("NA", "", " ", "NULL"))

all_data[, OPENRATE := (OPENEDCOUNT/as.numeric(SENTCOUNT))]

DT <- all_data[OPENEDCOUNT > 0, .(CLICKRATE = (CLICKEDCOUNT/as.numeric(OPENEDCOUNT)), SENTCOUNT, OPENEDCOUNT, CLICKEDCOUNT, RECIPIENTID)]

temp <- all_data[OPENEDCOUNT > 0]

setnames(all_data, old=c("AMAZON EBAY BUYER"), new=c("AMAZONEBAYBUYER"))

setnames(temp, old=c("AMAZON EBAY BUYER"), new=c("AMAZONEBAYBUYER"))

#ggplot(all_data, aes(x = as.numeric(ORDERCOUNT))) + geom_histogram(binwidth = 1) + theme_bw() + xlab("Fraction of opened mails clicked") + ylab("Number of recipients") + labs(title="Distribution of click percentage (excluding 0)") + xlim(0, 50) #+ ylim(0, 75000)

# Distribution of AMAZON EBAY BUYER demographic
ggplot(all_data, aes(x = as.factor(AMAZONEBAYBUYER), y = ..count../sum(..count..))) + theme_bw() + geom_bar(width=0.5) + geom_text(stat='count', aes(y=..count../sum(..count..), label = scales::percent((..count..)/sum(..count..))), vjust=1.6, color="white", size=2.5) + xlab("Amazon Ebay Buyer") + ylab("Percentage of recipients") + scale_y_discrete(limits=seq(0, 1, 0.1))# + scale_x_discrete(limits=seq(0, 12, 1), labels=c("NA", "JAN", "FEB", "MAR", "APR", 'MAY', 'JUN', 'JUL', 'AUG', 'SEPT', 'OCT', 'NOV', 'DEC'))

# ggplot(all_data, aes(x = as.factor(GENDER), y = OPENRATE)) + geom_boxplot(outlier.color = "blue", outlier.shape = "cross") + theme_bw() + xlab("Gender") + ylab("Percentage of sent mails opened")

# Box Plot of distribution of AMAZON EBAY BUYER against OPEN RATE 
ggplot(temp, aes(x = as.factor(AMAZONEBAYBUYER), y = OPENRATE)) + geom_boxplot(outlier.color = "blue", outlier.shape = "cross") + theme_bw() + xlab("Amazon Ebay Buyer") + ylab("Percentage of sent mails opened") #+ scale_x_discrete(labels=c("NA", "JAN", "OCT", "NOV", "DEC", "FEB", "MAR", "APR", "MAY", "JUN", 'JUL', 'AUG', 'SEPT')) #+ scale_x_discrete(labels=c('<15k', '15k-25k', '25k-35k', '35k-50k', '50k-75k', '75k-100k', '100k-120k', '120k-149k', '150k-plus', 'NA'))#+ scale_x_discrete(labels=c('NA', '0-17', '18-35', '36-49', '50-64', '65-plus'))


# Similarly by changing the x in the above two ggplot lines, plots for other demographic features can be obtained
