
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)
library(kernlab)
library(ROCR)

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



# Predict

ypredProb <- predict(object = ksvmModel
                 , test
                 , type="probabilities"
                 )
head(ypredProb)


# Create the "/output" folder if it does not already exists
dir.create('output', showWarnings = F)

# ROC Curve
pred <- prediction(ypredProb[,2], na.omit(test)["w_is_better_ranked"])
perf <- performance(pred, "tpr", "fpr")
png(filename = "output/ROC Curve.png")
plot(perf)
abline(0,1, lty="dotted")
dev.off()


# Clasification
ypred <- predict(object = ksvmModel, test)

# Results
ytest <- na.omit(test)["w_is_better_ranked"]
resultsDF <- data.frame(ypred, ytest)

P  <- nrow( subset ( resultsDF, ypred == 1 ) )
N  <- nrow( subset ( resultsDF, ypred == 0 ) )
TP <- nrow( subset ( resultsDF, ypred == 1 & ytest == 1 ) )
TN <- nrow( subset ( resultsDF, ypred == 0 & ytest == 0 ) )

table(PREDICTION = ypred, TRUTH = ytest$w_is_better_ranked)
