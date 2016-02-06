
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)
library(kernlab)
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



# Predict

ypredProb <- predict(object = ksvmModel
                 , test
                 , type="probabilities"
                 )
head(ypredProb)


# ROC Curve
pred <- prediction(ypredProb[,2], na.omit(test)["w_is_better_ranked"])
perf <- performance(pred, "tpr", "fpr")

# Clasification
ypred <- predict(object = ksvmModel, test)

# Results
ytest <- na.omit(test)["w_is_better_ranked"]
resultsDF <- data.frame(ypred, ytest)

P  <- nrow( subset ( resultsDF, ypred == 1 ) )
N  <- nrow( subset ( resultsDF, ypred == 0 ) )
TP <- nrow( subset ( resultsDF, ypred == 1 & ytest == 1 ) )
TN <- nrow( subset ( resultsDF, ypred == 0 & ytest == 0 ) )

SVMTable <- table(PREDICTION = ypred, TRUTH = ytest$w_is_better_ranked)

# Create the "/output" folder if it does not already exists
dir.create('output', showWarnings = F)

# Plot
png(filename = "output/ROC Curve.png", width = 768, height = 1024)
par(mfrow=c(2, 1), mai=c(0.8,2,2,2)) # mai = c(bottom, left, top, right) 
plot(perf, main = "SVM", cex.main = 2.5, cex.lab=1.5)
abline(0,1, lty="dotted")
textplot(SVMTable, halign = "center", cex = 1.5)
dev.off()
