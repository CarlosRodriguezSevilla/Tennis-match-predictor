
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
svmModel <- ksvm(w_is_tallest~.,
                 data=train,
                 type="C-svc",
                 # Classifier
                 kernel="rbfdot",
                 # Radial Basis kernel function "Gaussian"
                 kpar = "automatic",
                 prob.model = TRUE)

adaModel <- ada(w_is_tallest~.,
                data=train,
                type="real")

rfsModel <- randomForest(w_is_tallest~.,
                        data=train,
                        na.action=na.omit)

# Predicted values (logical)
ypredSVM <- predict(object = svmModel, test)
ypredADA <- predict(object = adaModel, na.omit(test))
ypredRFS <- predict(object = rfsModel, na.omit(test))

# Predicted values (probabilities)
ypredProbSVM <- predict(object = svmModel, na.omit(test), type="prob")
ypredProbADA <- predict(object = adaModel, na.omit(test), type="prob")
ypredProbRFS <- predict(object = rfsModel, na.omit(test), type="prob")

# Prediction objects
predSVM <- prediction(ypredProbSVM[,2], na.omit(test)["w_is_tallest"])
predADA <- prediction(ypredProbADA[,2], na.omit(test)["w_is_tallest"])
predRFS <- prediction(ypredProbRFS[,2], na.omit(test)["w_is_tallest"])


# Results

# Create the "/output" folder if it does not already exists
dir.create('output', showWarnings = F)

plotModel(
  name        = "SVM", 
  prediction  = predSVM,
  ypred       = ypredSVM, 
  ypredProb   = ypredProbSVM, 
  ytest       = na.omit(test)[["w_is_tallest"]]
  )

plotModel(
  name        = "AdaBoost", 
  prediction  = predADA,
  ypred       = ypredADA, 
  ypredProb   = ypredProbADA, 
  ytest       = na.omit(test)[["w_is_tallest"]]
)

plotModel(
  name        = "Random Forest", 
  prediction  = predRFS,
  ypred       = ypredRFS, 
  ypredProb   = ypredProbRFS, 
  ytest       = na.omit(test)[["w_is_tallest"]]
)