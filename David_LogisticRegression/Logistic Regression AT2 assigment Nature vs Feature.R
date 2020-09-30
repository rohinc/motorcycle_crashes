library(mltools)
library(data.table)
library(caret)
library(dplyr)
library(tidyverse)
library(readr)
library(stringr)
library(caTools)
library(gmodels)
library(ROSE)
library(DescTools)
#install.packages("mltools")

#all variables




crash_data <- read_rds("datasets/main.Rds")
crash_data <- crash_data %>% filter(!Crash_Severity %in%  c("Property damage only","Minor injury","Medical treatment")) %>% mutate(crash_sev_bin=factor(ifelse(Crash_Severity=="Fatal",'F','H'))) 
#crash_data$Crash_Severity <- as.numeric(crash_data$Crash_Severity)


##60km

crash_data_60 <- crash_data %>% filter(Crash_Speed_Limit == "60 km/h")


crash_data_60 <-  crash_data_60 %>% dplyr::select("Crash_Roadway_Feature","Crash_Nature","crash_sev_bin")

model_data <- crash_data_60 %>% dplyr::select(crash_sev_bin,Crash_Nature,Crash_Roadway_Feature)




model_data$crash_sev_bin       <- factor(model_data$crash_sev_bin)
model_data$Crash_Nature         <- factor(model_data$Crash_Nature)
model_data$Crash_Roadway_Feature <- factor(model_data$Crash_Roadway_Feature)





#filter chi squared value
model_data <- model_data %>% filter(Crash_Roadway_Feature %in% c('Intersection - Cross','Intersection - Roundabout','No Roadway Feature'),Crash_Nature %in% c('Fall from vehicle','Head-on','Hit object','Rear-end','Sideswipe','Angle'))

# Get the number of observations
n_obs <- nrow(model_data)

# Shuffle row indices: permuted_rows
permuted_rows <- sample(n_obs)

# Randomly order data: Sonar
model_shuffled <- model_data[permuted_rows, ]

# Identify row to split on: split
split <- round(n_obs * 0.7)

# Create train
train <- model_shuffled[1:split, ]

# Create test
test <- model_shuffled[(split + 1):n_obs, ]

#treat imbalances
data_rose <- ROSE(crash_sev_bin~.,data=train)$data



#Fit a models






model_rose <- glm(crash_sev_bin~Crash_Nature+Crash_Roadway_Feature,data=data_rose, family = "binomial")

model_no_oversample <- glm(crash_sev_bin~Crash_Nature+Crash_Roadway_Feature,data=train, family = "binomial")

summary(model_no_oversample)
summary(model_rose)

#model.back <- drop1(model,test="Chisq")

#model.back


#For model_rose


##test model_rose


# Predict on test: p
p <- predict(model_rose, test, type = "response")



# If p exceeds threshold of 0.5, H else H: ftl_or_hosp
ftl_or_hosp <- ifelse(p > 0.5, "F", "H")

# Convert to factor: p_class
p_class <- factor(ftl_or_hosp, levels = levels(test[["crash_sev_bin"]]))

# Create confusion matrix
confusionMatrix(p_class, test[["crash_sev_bin"]])


colAUC(p, test[["crash_sev_bin"]], plotROC = TRUE)




myControl <- trainControl(
  method = "cv",
  number = 10,
  summaryFunction = twoClassSummary,
  classProbs = TRUE, # IMPORTANT!
  verboseIter = TRUE
)


# Train glm with custom trainControl: model
model_rose_cross <- train(
  crash_sev_bin ~ ., 
  data_rose, 
  method = "glm",
  trControl = myControl
)

# Print model to console
model_rose_cross




# Test model_no_oversample


# Predict on test: p
p <- predict(model_no_oversample, test, type = "response")



# If p exceeds threshold of 0.5, H else H: ftl_or_hosp
ftl_or_hosp <- ifelse(p > 0.5, "F", "H")

# Convert to factor: p_class
p_class <- factor(ftl_or_hosp, levels = levels(test[["crash_sev_bin"]]))

# Create confusion matrix
confusionMatrix(p_class, test[["crash_sev_bin"]])


colAUC(p, test[["crash_sev_bin"]], plotROC = TRUE)





myControl <- trainControl(
  method = "cv",
  number = 10,
  summaryFunction = twoClassSummary,
  classProbs = TRUE, # IMPORTANT!
  verboseIter = TRUE
)


# Train glm with custom trainControl: model
model_no_oversample_cross <- train(
  crash_sev_bin ~ ., 
  train, 
  method = "glm",
  trControl = myControl
)

# Print model to console
model_no_oversample_cross


## Comparing models
#model_Chi_Predictors_Edited
#model_Chi_Predictors
#model

# not sure if these apply to oversample vs not oversample.

anova(model_rose,model_no_oversample , test ="Chisq")
library(lmtest)
lrtest(model_rose, model_no_oversample)
