path <- 'C:/Users/ss0088/data/' #Create the working directory, Make sure the working directory folder has no other files.
setwd(path)

auto_install <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, 'Package'])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE, repos = 'http://cran.us.r-project.org')
  sapply(pkg, require, character.only = TRUE)
}

packages <- c('stringr', 'R.utils')
auto_install(packages)

#Set up for loop
state <- c('QLD1','NSW1', 'VIC1', 'TAS1', 'SA1')
year <- 1998:2017
mon <- 1:12
mon <- stringr::str_pad(mon, 2, pad = "0")

# Run Loop for all state, for years and for month
for(i in year){
  for(j in mon){
    for(k in state){
      tryCatch({

      download.file(paste('https://www.aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_',i, j, '_',k, '.csv', sep=''),
                    destfile = paste("PRICE_AND_DEMAND_", i, j, '_', k, '.csv', sep=""), mode="wb")

      }, error=function(e){})

    }
  }
}

#Updater for year 2017, as 
for(j in mon){
    for(k in state){
      tryCatch({
        
        download.file(paste('https://www.aemo.com.au/aemo/data/nem/priceanddemand/PRICE_AND_DEMAND_',2017, j, '_',k, '.csv', sep=''),
                      destfile = paste("PRICE_AND_DEMAND_", 2017, j, '_', k, '.csv', sep=""), mode="wb")
        
      }, error=function(e){})
      
    }
}

# Delete the 0kb files
lapply(Filter(function(x) countLines(x)==0, list.files(pattern='.csv')), unlink) #it uses R.utils package

# Load all the csv files and rbind them
fileList <- list.files(path=path, pattern=".csv")
df <- lapply(fileList, read.csv)
df <- do.call(rbind.data.frame, df)
colnames(df) <- tolower(colnames(df))

library(reshape2)
names(df)
price <- dcast(df, settlementdate ~ region, value.var="rrp")
demand <- dcast(df, settlementdate ~ region, value.var="totaldemand")


setwd('..')
getwd()
write.csv(price, 'price.csv')
write.csv(price, 'demand.csv')
