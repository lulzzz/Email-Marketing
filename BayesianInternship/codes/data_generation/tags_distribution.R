# Generates the distribution of image tags

library(data.table)

# Folder to csv files containing image tags
folder_path <- "/home/fatigue_internship/output_statistics/image_tags/"

file_list <- list.files(folder_path)

DT <- NULL

for(i in 1:length(file_list)){
  print(file_list[i])
  
  temp <- fread(paste(folder_path, file_list[i], sep=""), header=FALSE)
  
  DT[[i]] <- temp
}

DT_temp <- rbindlist(DT)

DT_temp1 <- DT_temp[V3 %in% camps]

## Remove duplicate tags per campaign id
DT <- DT_temp1[,.(count=.N), by = list(V3, V6)]


## Now we have all the data. Time now to plot
# ggplot(DT, aes(x = as.factor(V6))) + geom_histogram() + theme_bw() + xlab("Image Tag") + ylab("Number of campaigns") + labs(title="Distribution of image tags")

gplot <- ggplot(DT, aes(x = as.factor(V6), y = ..count../200)) + theme_bw() + geom_bar(width=0.5) + xlab("Image Tags") + ylab("Percentage of campaigns") + coord_flip()

filename <- "/home/fatigue_internship/output_statistics/Plots/Data_stats/image_tags_distr.png"

png(file = filename, width = 3000, height = 1500)
print(gplot)
dev.off()
