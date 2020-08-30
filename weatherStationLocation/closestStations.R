

setupPackage <- function( packageName, loud=FALSE ) {
  if (!require(packageName, character.only=TRUE)) {
    install.packages(packageName, verbose = loud)
  } 
  library(packageName, character.only=TRUE, verbose = loud)
}

setupPackage("tidyverse")

# get the haversine.R method
source("haversine.R")

# load stations
qldStations <- readRDS("qldStations.rds")

closestStations <- function(latitude, longitude)
{
  tempStations <- qldStations
  tempStations <- mutate(tempStations, distance=haversine(latitude, longitude, Lat, Lon))
  tempStations <- tempStations[order(tempStations$distance),]
  return( tempStations[1:3,] )
  
}

testClosestStations <- function()
{
    stations <- closestStations(-27.51511, 153.0306 )
    print(stations)
}
