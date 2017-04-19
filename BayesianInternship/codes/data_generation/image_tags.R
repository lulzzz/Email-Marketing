# Code that generates image tags

library(xml2)
library(httr)
library(stringr)

## Path to folder containing HTML files
folder_path <- "/home/fatigue_internship/data/HTML_files/BH/tmp/"

## Path to output csv file
write_file_path <- "/home/fatigue_internship/data/image_tags_BH.csv"

file.create(write_file_path)

file_list <- list.files(path = folder_path, pattern = ".*\\.html")

for(i in seq(from=1, to=length(file_list), by=1)){
  
  print(file_list[i])
  list_tags <- list()
  img_links <- list()
  url_links <- list()
  idx <- 1
  
  src_html <- read_html(paste(folder_path, file_list[i], sep = ""))
  image_nodes <- xml_find_all(src_html, "//img")
  
  if(length(image_nodes) == 0) next
  
  for(j in seq(from=1, to=length(image_nodes), by=1)){
    
    #The analysis is to be done only for jpg images
    img_link <- xml_attrs(image_nodes[j])[[1]]["src"]
    img_url_components <- parse_url(img_link)
    
    #print(img_url_components$path)
    
    if(grepl(".jpg", img_url_components$path) == FALSE) next;
    
    parent_node <- xml_parent(image_nodes[j])
    
    url_link <- xml_attrs(parent_node)[[1]]["href"]
    url_components <- parse_url(url_link)
    #print(url_components$path)
    
    if(grepl(tolower("Home"), tolower(url_components$path)) == TRUE){
      
      list_tags[[idx]] <- str_sub(url_components$path, 6, -6)
      img_links[[idx]] <- img_link
      url_links[[idx]] <- url_link
      idx <- idx+1
    }
    
  }
  
  if(length(list_tags) == 0) next
  
  #Time to write to csv
  
  brand_name <- strsplit(file_list[i], split=" - ")[[1]][1]
  campaign_id <- strsplit(file_list[i], split=" - ")[[1]][2]
    
  for(j in 1:length(list_tags)){
    print(list_tags[[j]])
    write.table(x=list(brand_name, campaign_id, img_links[[j]], url_links[[j]], list_tags[[j]]), file=write_file_path, append=TRUE, sep=",", col.names=FALSE)
  }
  
}

