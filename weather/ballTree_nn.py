#!/usr/bin/env python
# coding: utf-8

# In[140]:


#!/usr/bin/env python
# coding: utf-81

import pandas as pd

crash_data = pd.read_csv("locations.csv")

crash_data_id = (crash_data["Crash_Ref_Number"].unique())

crash_data.head()


motorcycle_crashes = crash_data[(crash_data.Count_Unit_Motorcycle_Moped > 0)]
motorcycle_crashes.head()

motorcycle_short = motorcycle_crashes[['Crash_Ref_Number','Crash_Longitude_GDA94', 'Crash_Latitude_GDA94']]
motorcycle_short.head()

motorcycle_short = motorcycle_short.rename(columns={"Crash_Longitude_GDA94":'long', 'Crash_Latitude_GDA94': 'lat','Crash_Ref_Number':'crash_id'})
motorcycle_short.head()

motorcycle_short.shape

weather_stations = pd.read_csv("monthly_sum.csv")

weather_stations.head()

weather_stations = weather_stations.rename(columns={"Bureau of Meteorology station number":"bom_id"})
weather_stations.head()

weather_stations_uniq = weather_stations.drop_duplicates(subset=['bom_id'])
weather_stations_uniq = weather_stations_uniq[['bom_id']]
weather_stations_uniq.head()

stations = pd.read_csv("station_list.csv")
qld_stations = stations[(stations.STA == 'QLD')]
qld_stations = qld_stations[['Site', 'Site name', 'Lat', 'Lon']]
qld_stations.head()

weather_stations_uniq.head()
qld_stations.head()

weather_stations_uniq['bom_id'] = weather_stations_uniq.bom_id.astype(int)
qld_stations['Site'] = qld_stations.Site.astype(int)
#df3 = weather_stations_uniq.merge(qld_stations, on='bom_id', how='inner')
# df3.head()

site_coord = weather_stations_uniq.merge(qld_stations, left_on='bom_id', right_on='Site')
# df4 = df3['bom_id','Site name', 'Site name','Lon']

motorcycle_short.head()

site_coord.head()

motorcycle_short = motorcycle_short.rename(columns = {"long":"lon"})
site_coord = site_coord.rename(columns = {"Lat":"lat", "Lon":"lon"})


# In[141]:


motorcycle_short = motorcycle_short.reset_index(drop=True)
motorcycle_short.head()


# In[177]:


import numpy as np
import pandas as pd
from sklearn.neighbors import KDTree, BallTree
from math import radians


property_coords = motorcycle_short[['lat', 'lon']].to_numpy()
station_coords = site_coord[['lat', 'lon']].to_numpy()
station_coords = station_coords.astype(np.float)

property_rad = np.radians(property_coords)
station_rad = np.radians(station_coords)

# Create BallTree using station coordinates and specify distance metric
tree = BallTree(station_rad, metric = 'haversine')


crash_id_list = []
site_id_list = []
site_name = []
distance_list = []

site_id_list_2 = []
distance_list_2 = []
site_name_2 = []

site_name_3 = []
site_id_list_3 = []
distance_list_3 = []

for i, property in enumerate(property_rad):
    dist, ind = tree.query(property.reshape(1, -1), k=3) # distance to first nearest station
    
    earth_radius = 6371000  # meters
    crash_id_list.append(motorcycle_short['crash_id'][i])
    site_id_list.append(site_coord['bom_id'][ind[0][0]])
    site_name.append(site_coord['Site name'][ind[0][0]])
    distance_list.append(dist[0][0] * earth_radius )
    
    site_id_list_2.append(site_coord['bom_id'][ind[0][1]])
    site_name_2.append(site_coord['Site name'][ind[0][1]])
    distance_list_2.append(dist[0][1] * earth_radius )
    
    site_id_list_3.append(site_coord['bom_id'][ind[0][2]])
    site_name_3.append(site_coord['Site name'][ind[0][2]])
    distance_list_3.append(dist[0][2] * earth_radius )
    

#     print(dist)
#     print(motorcycle_short['crash_id'][i], site_coord['Site name'][ind[0][0]], dist[0][0], sep ='\t')


# In[178]:


print(len(site_id_list), '==', len(distance_list))
print(len(site_id_list_2), '==', len(distance_list_2))
print(len(site_id_list_3), '==', len(distance_list_3))


# In[179]:


df = pd.DataFrame(list(zip(crash_id_list, site_id_list, site_name, distance_list, site_id_list_2, site_name_2, distance_list_2, site_id_list_3, site_name_3, distance_list_3)), 
           columns =['crash_id', 'site_id_1', 'site_name_1', 'distance_1', 'site_id_list_2', 'site_name_2', 'distance_2', 'site_id_list_3','site_name_3', 'distance_3']) 

# df.distance_1 /= 1000
df['distance_1'] = df['distance_1'].round(2)
# df.distance_2 /= 1000
df['distance_2'] = df['distance_2'].round(2)
# df.distance_3 /= 1000
df['distance_3'] = df['distance_3'].round(2)


# In[180]:


df.head()


# In[181]:


df.to_csv('crash_weatherstation.csv', sep=',')


# In[ ]:




