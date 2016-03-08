
rm(list=ls(all = TRUE)) # Clear workspace

library(dplyr)
library(tidyr)

library(kernlab)
library(ada)
library(randomForest)

library(ROCR)
library(gplots)

source("Config.R") # Load config file with root path, etc
source("Auxiliar functions.R")

load(paste0(path, "/Matches-clean.RData"))


# Sampling
set.seed(2)
trainIndex <- sample(x = nrow(matches)
                     , size = nrow(matches)*0.7
                     )

train <- matches[trainIndex,]
test  <- matches[-trainIndex,]

rm(trainIndex)


# Modeling
svmModel <- ksvm(
  w_is_better_ranked~.,
  data=train,
  type="C-svc",
  # Classifier
  kernel="rbfdot",
  # Radial Basis kernel function "Gaussian"
  kpar = "automatic",
  prob.model = TRUE
)

adaModel <- ada(
  w_is_better_ranked~.,
  data=train,
  type="real")

rfsModel <- randomForest(w_is_better_ranked~.,
                        data=train,
                        na.action=na.omit)



# Predictor columns
ypredProbSVM <- predict(object = svmModel, test, type="probabilities")
ypredProbADA <- predict(object = adaModel, na.omit(test), type="prob")
ypredProbRFS <- predict(object = rfsModel, na.omit(test), type="prob")

# Prediction objects
predSVM <- prediction(ypredProbSVM[,2], na.omit(test)["w_is_better_ranked"])
predADA <- prediction(ypredProbADA[,2], na.omit(test)["w_is_better_ranked"])
predRFS <- prediction(ypredProbRFS[,2], na.omit(test)["w_is_better_ranked"])


# Results

# Create the "/output" folder if it does not already exists
dir.create('output', showWarnings = F)

plotModel(
  name = "SVM", 
  prediction = predSVM,
  model = svmModel, 
  ytest = na.omit(test)["w_is_better_ranked"]
  )

plotModel(
  name = "ADA", 
  prediction = predADA,
  model = adaModel, 
  ytest = test["w_is_better_ranked"]
)

plotModel(
  name = "RFS", 
  prediction = predRFS,
  model = rfsModel, 
  ytest = test["w_is_better_ranked"]
)