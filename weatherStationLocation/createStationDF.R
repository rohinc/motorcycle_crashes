# This script will read in a station.xlsx file and create a dataframe from it 
# with just QLD data. This dataframe will then be written to a qldStations.rds file
# so that it can be read in via other scripts using readRDS()

# Weather station data obtained from:
# Bureau of Meteorology (2014) Bureau of Meteorology weather stations - All Australia. 
# Bioregional Assessment Source Dataset. Viewed 29 September 2017, 
# http://data.bioregionalassessments.gov.au/dataset/5aa692ee-513b-425c-8c9d-b2a858724c25.


setupPackage <- function( packageName, loud=FALSE ) {
  if (!require(packageName, character.only=TRUE)) {
    install.packages(packageName, verbose = loud)
  } 
  library(packageName, character.only=TRUE, verbose = loud)
}


setupPackage("tidyverse")

# readin the xlsx file (note: expected that header and tail lines will already have been removed)
stationsDF <- readxl::read_excel("weatherStationLocation/stations.xlsx")

# remove spaces and other special characers from column names
names(stationsDF)<-str_replace_all(names(stationsDF), c(" " = "_" , "," = "", "\\(" = "" , "\\)" = ""))

# get just the Qld data
qldStations <- filter(stationsDF, STA == 'QLD' & (End == '..' | End >= '2010'))

saveRDS(qldStations, "weatherStationLocation/qldStations.rds")
