
library(dplyr)
library(tidyr)
library(kernlab)
library(ROCR)

# Load config file with root path, etc
source("Config.R")

load(paste0(path, "/Matches-clean.RData"))


# Sampling
matches.predictors <- matches[,c(1:30,50)]

trainIndex <- sample(x = nrow(matches.predictors)
                     , size = nrow(matches.predictors)*0.7
                     )

train <- matches.predictors[trainIndex,]
test  <- matches.predictors[-trainIndex,]

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



# Predict

ypredProb <- predict(object = ksvmModel
                 , test
                 , type="probabilities"
                 )
head(ypredProb)


# ROC Curve
pred <- prediction(ypredProb[,2], na.omit(test)["w_is_better_ranked"])
perf <- performance(pred, "tpr", "fpr")
plot(perf)
abline(0,1, lty="dotted")



# Clasification
ypred <- predict(object = ksvmModel, test)

# Results
ytest <- na.omit(test)["w_is_better_ranked"]
resultsDF <- data.frame(ypred, ytest)

P  <- nrow( subset ( resultsDF, ypred == 1 ) )
N  <- nrow( subset ( resultsDF, ypred == 0 ) )
TP <- nrow( subset ( resultsDF, ypred == 1 & ytest == 1 ) )
TN <- nrow( subset ( resultsDF, ypred == 0 & ytest == 0 ) )

table(ypred, ytest$w_is_better_ranked)
