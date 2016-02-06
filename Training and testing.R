
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)

library(kernlab)
library(ada)

library(ROCR)
library(gplots)


# Load config file with root path, etc
source("Config.R")

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
ksvmModel <- ksvm(
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



# Predict
ypredProbSVM <- predict(object = ksvmModel
                 , test
                 , type="probabilities"
                 )
head(ypredProbSVM)

ypredProbADA <- predict(object = adaModel
                        , test
                        , type="prob"
                )
head(ypredProbADA)


# ROC Curve
predSVM <- prediction(ypredProbSVM[,2], na.omit(test)["w_is_better_ranked"])
perfSVM <- performance(predSVM, "tpr", "fpr")

predADA <- prediction(ypredProbADA[,2], test["w_is_better_ranked"])
perfADA <- performance(predADA, "tpr", "fpr")

# Clasification
ypredSVM <- predict(object = ksvmModel, test)

ypredADA <- predict(object = adaModel, test)

# Results
ytest <- na.omit(test)["w_is_better_ranked"]
resultsDF <- data.frame(ypredSVM, ytest)

P  <- nrow( subset ( resultsDF, ypredSVM == 1 ) )
N  <- nrow( subset ( resultsDF, ypredSVM == 0 ) )
TP <- nrow( subset ( resultsDF, ypredSVM == 1 & ytest == 1 ) )
TN <- nrow( subset ( resultsDF, ypredSVM == 0 & ytest == 0 ) )

SVMTable <- table(PREDICTION = ypredSVM, TRUTH = ytest$w_is_better_ranked)


ytest <- test["w_is_better_ranked"]
resultsDF <- data.frame(ypredADA, ytest)

P  <- nrow( subset ( resultsDF, ypredADA == 1 ) )
N  <- nrow( subset ( resultsDF, ypredADA == 0 ) )
TP <- nrow( subset ( resultsDF, ypredADA == 1 & ytest == 1 ) )
TN <- nrow( subset ( resultsDF, ypredADA == 0 & ytest == 0 ) )

ADATable <- table(PREDICTION = ypredADA, TRUTH = ytest$w_is_better_ranked)


# Create the "/output" folder if it does not already exists
dir.create('output', showWarnings = F)

# Plot
plotModel(name="SVM", performance=perfSVM, table = SVMTable)
plotModel(name="ADA", performance=perfADA, table = ADATable)

