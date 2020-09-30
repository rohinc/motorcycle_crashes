library(mltools)
library(data.table)
library(caret)
library(dplyr)
library(tidyverse)
library(readr)
library(stringr)
library(caTools)
#install.packages("mltools")


crash_data <- read_rds("datasets/main.Rds")


crash_data <- crash_data %>% filter(!Crash_Severity %in%  c("Property damage only","Minor injury","Medical treatment")) %>% mutate(crash_sev_bin=factor(ifelse(Crash_Severity=="Fatal",'F','H'))) 
crash_data$Crash_Severity <- as.numeric(crash_data$Crash_Severity)


#unique(crash_data$crash_sev_bin)

response <- crash_data$crash_sev_bin


predictors <- crash_data %>% select(Crash_Speed_Limit)


model_data <- as.data.frame(cbind(response, predictors))
str(model_data)






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


# Fit glm model: model
model <- glm( response~. , family = "binomial", train)

summary(model)

# Predict on test: p
p <- predict(model, test, type = "response")



# If p exceeds threshold of 0.5, H else H: ftl_or_hosp
ftl_or_hosp <- ifelse(p > 0.5, "F", "H")

# Convert to factor: p_class
p_class <- factor(ftl_or_hosp, levels = levels(test[["response"]]))

# Create confusion matrix
confusionMatrix(p_class, test[["response"]])



## Next

#plot ROC curve
colAUC(p, test[["response"]], plotROC = TRUE)



#

myControl <- trainControl(
  method = "cv",
  number = 10,
  summaryFunction = twoClassSummary,
  classProbs = TRUE, # IMPORTANT!
  verboseIter = TRUE
)


# Train glm with custom trainControl: model
model <- train(
  response ~ ., 
  model_data, 
  method = "glm",
  trControl = myControl
)

# Print model to console
model



#Notes
# Look at Step wise selection
# Goodness of the fit test - 
# AIC, BIC, adjR2, F-statistic <- not used to much
# k-Fold Cross validation
# Confusion matrix accuracy 


