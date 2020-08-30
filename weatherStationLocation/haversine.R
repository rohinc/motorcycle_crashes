
#
# function to calculate the great-circle distance between two points uisng  ‘haversine’ formula 
# – that is, the shortest distance over the earth’s surface
# distance returned is in metres
# based on: https://www.movable-type.co.uk/scripts/latlong.html

haversine <- function(lat1, lon1, lat2, lon2) {
  R = 6371000 #metres
  phi1 = lat1 * pi / 180   #in radians
  phi2 = lat2 * pi / 180  #in radians
  deltaPhi = (lat2-lat1) * pi/180
  deltaLamda = (lon2-lon1) * pi/180
  
  a = sin(deltaPhi/2) * sin(deltaPhi/2) +
    cos(phi1) * cos(phi2) *
    sin(deltaLamda/2) * sin(deltaLamda/2)
  c = 2 * atan2(sqrt(a), sqrt(1-a))
  
   return(R * c) # in metres
}

testHaversine <- function(){
   # should be aobut 3.574km
   print(haversine(-27.51511, 153.0306, -27.5, 153))
}
