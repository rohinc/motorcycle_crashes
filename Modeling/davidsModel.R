setupPackage <- function( packageName, loud=FALSE ) {
  if (!require(packageName, character.only=TRUE)) {
    install.packages(packageName, verbose = loud, dependencies = TRUE)
  } 
  library(packageName, character.only=TRUE, verbose = loud)
}

setupPackage("tidyverse")
setupPackage("mltools")
setupPackage("data.table")
setupPackage("caret")
setupPackage("caTools")
setupPackage("gmodels")
setupPackage("fastDummies")
setupPackage("magrittr")
setupPackage("MASS")
setupPackage("ROSE")
#Grab the data
crash_data <- read_rds("datasets/main.Rds")
crash_data <- crash_data %>% filter(!Crash_Severity %in%  c("Property damage only","Minor injury","Medical treatment")) %>% mutate(crash_sev_bin=factor(ifelse(Crash_Severity=="Fatal",'F','H')))
crash_data_60 <- crash_data %>% filter(Crash_Speed_Limit == "60 km/h")
crash_data_dummies <- fastDummies::dummy_cols(crash_data_60,select_columns=c("Crash_Roadway_Feature","Crash_Nature"))
# or drop the the first so we get k-1 dummies, either way the predictors will nee to be adjusted for the dropped dummy
#crash_data_dummies <- fastDummies::dummy_cols(crash_data_60,select_columns=c("Crash_Roadway_Feature","Crash_Nature"),remove_first_dummy = TRUE)
predictor <- crash_data_dummies %>% dplyr::select (
  `Crash_Roadway_Feature_Bridge/Causeway`
  ,`Crash_Roadway_Feature_Forestry/National Park Road`
  ,`Crash_Roadway_Feature_Intersection - 5+ way`
  ,`Crash_Roadway_Feature_Intersection - Cross`
  ,`Crash_Roadway_Feature_Intersection - Interchange`
  ,`Crash_Roadway_Feature_Intersection - Multiple Road`
  ,`Crash_Roadway_Feature_Intersection - Roundabout`
  ,`Crash_Roadway_Feature_Intersection - T-Junction`
  ,`Crash_Roadway_Feature_Intersection - Y-Junction`
  ,`Crash_Roadway_Feature_Median Opening`
  ,`Crash_Roadway_Feature_Merge Lane`
  ,`Crash_Roadway_Feature_No Roadway Feature`
  ,`Crash_Roadway_Feature_Railway Crossing`
  ,`Crash_Nature_Collision - miscellaneous`
  ,`Crash_Nature_Fall from vehicle`
  ,`Crash_Nature_Head-on`
  ,`Crash_Nature_Hit animal`
  ,`Crash_Nature_Hit object`
  ,`Crash_Nature_Hit parked vehicle`
  ,`Crash_Nature_Hit pedestrian`
  ,`Crash_Nature_Non-collision - miscellaneous`
  ,Crash_Nature_Overturned
  ,`Crash_Nature_Rear-end`
  ,Crash_Nature_Sideswipe
  ,`Crash_Nature_Struck by external load`
  ,Crash_Roadway_Feature_Bikeway
  ,Crash_Nature_Angle
)
# There must be an easier way to conver them all to factors :(
predictor$`Crash_Roadway_Feature_Bridge/Causeway`             	<-	factor(	 predictor$`Crash_Roadway_Feature_Bridge/Causeway`             	)
predictor$`Crash_Roadway_Feature_Forestry/National Park Road` 	<-	factor(	 predictor$`Crash_Roadway_Feature_Forestry/National Park Road` 	)
predictor$`Crash_Roadway_Feature_Intersection - 5+ way`       	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - 5+ way`       	)
predictor$`Crash_Roadway_Feature_Intersection - Cross`        	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - Cross`        	)
predictor$`Crash_Roadway_Feature_Intersection - Interchange`  	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - Interchange`  	)
predictor$`Crash_Roadway_Feature_Intersection - Multiple Road`	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - Multiple Road`	)
predictor$`Crash_Roadway_Feature_Intersection - Roundabout`   	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - Roundabout`   	)
predictor$`Crash_Roadway_Feature_Intersection - T-Junction`   	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - T-Junction`   	)
predictor$`Crash_Roadway_Feature_Intersection - Y-Junction`   	<-	factor(	 predictor$`Crash_Roadway_Feature_Intersection - Y-Junction`   	)
predictor$`Crash_Roadway_Feature_Median Opening`              	<-	factor(	 predictor$`Crash_Roadway_Feature_Median Opening`              	)
predictor$`Crash_Roadway_Feature_Merge Lane`                  	<-	factor(	 predictor$`Crash_Roadway_Feature_Merge Lane`                  	)
predictor$`Crash_Roadway_Feature_No Roadway Feature`          	<-	factor(	 predictor$`Crash_Roadway_Feature_No Roadway Feature`          	)
predictor$`Crash_Roadway_Feature_Railway Crossing`            	<-	factor(	 predictor$`Crash_Roadway_Feature_Railway Crossing`            	)
predictor$`Crash_Nature_Collision - miscellaneous`            	<-	factor(	 predictor$`Crash_Nature_Collision - miscellaneous`            	)
predictor$`Crash_Nature_Fall from vehicle`                    	<-	factor(	 predictor$`Crash_Nature_Fall from vehicle`                    	)
predictor$`Crash_Nature_Head-on`                              	<-	factor(	 predictor$`Crash_Nature_Head-on`                              	)
predictor$`Crash_Nature_Hit animal`                           	<-	factor(	 predictor$`Crash_Nature_Hit animal`                           	)
predictor$`Crash_Nature_Hit object`                           	<-	factor(	 predictor$`Crash_Nature_Hit object`                           	)
predictor$`Crash_Nature_Hit parked vehicle`                   	<-	factor(	 predictor$`Crash_Nature_Hit parked vehicle`                   	)
predictor$`Crash_Nature_Hit pedestrian`                       	<-	factor(	 predictor$`Crash_Nature_Hit pedestrian`                       	)
predictor$`Crash_Nature_Non-collision - miscellaneous`        	<-	factor(	 predictor$`Crash_Nature_Non-collision - miscellaneous`        	)
predictor$Crash_Nature_Overturned                             	<-	factor(	 predictor$Crash_Nature_Overturned                             	)
predictor$`Crash_Nature_Rear-end`                             	<-	factor(	 predictor$`Crash_Nature_Rear-end`                             	)
predictor$Crash_Nature_Sideswipe                              	<-	factor(	 predictor$Crash_Nature_Sideswipe                              	)
predictor$`Crash_Nature_Struck by external load`	<-	factor(	 predictor$`Crash_Nature_Struck by external load`	)
predictor$Crash_Roadway_Feature_Bikeway     <- factor(predictor$Crash_Roadway_Feature_Bikeway)
predictor$Crash_Nature_Angle                <- factor(predictor$Crash_Nature_Angle)

response <- crash_data_60$crash_sev_bin
#create mode data
model_data <- as.data.frame(cbind(response, predictor))
#format strings
names(model_data)<-str_replace_all(names(model_data), c(" " = "_" , "," = "", "-"="_","/"="","\\+"=""))
#create train and test
# Get the number of observations
n_obs <- nrow(model_data)
# Shuffle row indices: permuted_rows
permuted_rows <- sample(n_obs)
# Randomly order data: Sonar
model_shuffled <- model_data[permuted_rows, ]
# Identify row to split on: split
split <- round(n_obs * 0.6)
# Create train
train <- model_shuffled[1:split, ]
# Create test
test <- model_shuffled[(split + 1):n_obs, ]
# ROSE it
data_rose <- ROSE(response~.,data=train)$data
#sample model
model_ch_sq <- glm( response ~ Crash_Roadway_Feature_Intersection___Cross + 
                      Crash_Roadway_Feature_Intersection___Roundabout  + 
                      Crash_Roadway_Feature_Intersection___T_Junction     +  
                      Crash_Roadway_Feature_No_Roadway_Feature    + 
                      Crash_Nature_Fall_from_vehicle + 
                      Crash_Nature_Head_on  + 
                      Crash_Nature_Hit_object +  
                      Crash_Nature_Rear_end  + 
                      Crash_Nature_Sideswipe, 
                    family = "binomial", data_rose)
summary(model_ch_sq)
# Predict on test: p
p <- predict(model_ch_sq, test, type = "response")
# If p exceeds threshold of 0.5, H else H: ftl_or_hosp
ftl_or_hosp <- ifelse(p > 0.5, "F", "H")
# Convert to factor: p_class
p_class <- factor(ftl_or_hosp, levels = levels(test[["response"]]))
# Create confusion matrix
confusionMatrix(p_class, test[["response"]])
# create ROC plot
colAUC(p, test[["response"]], plotROC = TRUE)
# Cross Validate
myControl <- trainControl(
  method = "cv",
  number = 10,
  summaryFunction = twoClassSummary,
  classProbs = TRUE, # IMPORTANT!
  verboseIter = TRUE
)
# Train glm with custom trainControl: model
model <- train(
  response ~ Crash_Roadway_Feature_Intersection___Cross + Crash_Roadway_Feature_Intersection___Roundabout  + Crash_Roadway_Feature_Intersection___T_Junction     +  Crash_Roadway_Feature_No_Roadway_Feature    + Crash_Nature_Fall_from_vehicle + Crash_Nature_Head_on  + Crash_Nature_Hit_object +  Crash_Nature_Rear_end  + Crash_Nature_Sideswipe,
  data_rose,
  method = "glm",
  trControl = myControl
)

