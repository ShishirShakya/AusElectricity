# # R Script to Download the Historical Data of Aggregated Price and Demand of National Electricity Market of Australia
# # This R script will download all the historical half-hourly data of aggregated price and demand of all the states of national electricity market of Australia from the Australian Energy Market Operator website and saves into two separate csv file. The data starts from 2:00 AM of 7th of December, 1998 for New South Wales (abbreviated as NSW), Victoria (VIC), Queensland (QLD), South Australia. The data for Tasmania (TAS) starts from 2:00 PM of 15th of May, 2005.
# 
# This script has a digital object identifier, please cite as:
# 
# Shishir Shakya. (2017, August 27). R Script to Download the Historical Data of Aggregated Price and Demand of National Electricity Market of Australia. Zenodo. http://doi.org/10.5281/zenodo.851555
# 
# To export as BibTeX, CSL, DataCite, Dublin Core, JSON, MARCXML and Mendeley, click the link [here](https://zenodo.org/record/851555/export/hx#.WaMC0z6GNaR).

rm(list = ls())
dev.off(dev.list()["RStudioGD"])

auto_install <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, 'Package'])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE, repos = 'http://cran.us.r-project.org')
  sapply(pkg, require, character.only = TRUE)
}

packages <- c('stringr', 'R.utils', 'rstudioapi', 'reshape2')
auto_install(packages)


path <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(path)

dir.create("rawdata")


#Set up for loop
state <- c('QLD1','NSW1', 'VIC1', 'TAS1', 'SA1')
year <- 1998:2019
mon <- 1:12
mon <- stringr::str_pad(mon, 2, pad = "0")

# Run Loop for all state, for years and for month
for(i in year){
  for(j in mon){
    for(k in state){
      tryCatch({
        
        download.file(paste('https://www.aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_',i, j, '_',k, '.csv', sep=''),
                      destfile = paste("rawdata/PRICE_AND_DEMAND_", i, j, '_', k, '.csv', sep=""), mode="wb")
        
      }, error=function(e){})
      
    }
  }
}

# #Update for year 2017, as 
# for(j in mon){
#   for(k in state){
#     tryCatch({
#       
#       download.file(paste('https://www.aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_',2017, j, '_',k, '.csv', sep=''),
#                     destfile = paste("PRICE_AND_DEMAND_", 2017, j, '_', k, '.csv', sep=""), mode="wb")
#       
#     }, error=function(e){})
#     
#   }
# }

# Delete the 0kb files
lapply(Filter(function(x) countLines(x)==0, list.files(pattern='.csv')), unlink) #it uses R.utils package

# Load all the csv files and rbind them
fileList <- list.files(path=path, pattern=".csv")
df <- lapply(fileList, read.csv)
df <- do.call(rbind.data.frame, df)
colnames(df) <- tolower(colnames(df))


names(df)
price <- dcast(df, settlementdate ~ region, value.var="rrp")
demand <- dcast(df, settlementdate ~ region, value.var="totaldemand")

write.csv(price, 'price.csv')
write.csv(price, 'demand.csv')
