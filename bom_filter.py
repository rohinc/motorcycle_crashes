#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np

master = pd.read_csv("data/master_weather.csv")


# In[3]:


master.head()
stations = list(master['Bureau of Meteorology station number'].unique())
len(stations)


# In[ ]:


#filter out 2001 onwards data
subset_of_master = master[(master.Year >= 2001)]
subset_of_master.head()
subset_of_master.to_csv("daily_rainfall.csv", sep=',', encoding='utf-8')


# In[27]:


g = subset_of_master.groupby(['Bureau of Meteorology station number','Year', 'Month'])
monthly_sum = g.aggregate({"Rainfall amount (millimetres)":np.sum})
type(monthly_sum)


# In[29]:


# monthly_sum.pivot(index='Bureau of Meteorology station number', columns='Year', 
#                   values=['Month', 'Rainfall amount (millimetres)'])
                                                                                       
monthly_sum.to_csv("monthly_sum.csv", sep=',', encoding='utf-8')



# In[33]:


monthly = pd.read_csv("monthly_sum.csv")
monthly = list(monthly['Bureau of Meteorology station number'].unique())
len(monthly)


# In[36]:


#read station list
weather_stat = pd.read_csv("station_list.csv")
weather_stat = weather_stat.rename(columns={"STA":"state"})

#filter for only QLD stations
qld_stations = weather_stat[(weather_stat.state == 'QLD')]

#filter on active stations
qld_active = qld_stations[(qld_stations.End == '..')]
qld_active_stations = list(qld_active['Site'].unique())

#filter on stations which have ended during or after 2001
qld_inactive = qld_stations[(qld_stations.End >= '2001')]

#concat the two DFs for a total list of weather stations
frames = [qld_active, qld_inactive]
qld_master = pd.concat(frames)

#extract Site IDs only
qld_master_stations = list(qld_master['Site'].unique())

len(qld_master_stations)


# In[ ]:




