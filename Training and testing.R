
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)
library(kernlab)
library(ROCR)

# Load config file with root path, etc
source("Config.R")

load(paste0(path, "/Matches-clean.RData"))


# Sampling
set.seed(48)
trainIndex <- sample(x = nrow(matches.pred_and_resp)
                     , size = nrow(matches.pred_and_resp)*0.7
                     )

train <- matches.pred_and_resp[trainIndex,]
test  <- matches.pred_and_resp[-trainIndex,]

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
