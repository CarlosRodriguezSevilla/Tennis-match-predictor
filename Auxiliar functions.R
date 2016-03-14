

plotModel <- function(name, prediction, ypred, ypredProb, ytest){
  
  # Classification
  performance <- performance(prediction, "tpr", "fpr")
  tableModel <- table(PREDICTION = ypred, TRUTH = ytest)
  
  # Plot
  png(filename = paste0("output/", name, ".png"), width = 768, height = 1024)
  par(mfrow=c(2,2), mai=c(1.5,1,2.25,1)) # mai = c(bottom, left, top, right) 
  
  plot(performance, main = name, cex.main = 2.5, cex.lab=1.5)
  abline(0,1, lty="dotted")
  
  textplot(tableModel, cex = 1.5)
  title(ylab="Prediction", xlab="Truth", main = "Confusion Matrix", outer = FALSE)
  
  DF <- data.frame(ytest     = as.numeric(as.logical(ytest)), 
                   ypred     = as.numeric(as.logical(ypred)), 
                   ypredProb = ypredProb[,2]
  )
  
  DFytestTRUE  <- DF[DF$ytest == 1,]
  DFytestFALSE <- DF[DF$ytest == 0,]
  
  
  
  probVectorTrue <- NULL
  count <- 1
  for(p in seq(0.1,1,by = 0.05)){    
    probVectorTrue[count] <- length(DFytestTRUE$ypredProb[DFytestTRUE$ypredProb >= (p-0.05) & DFytestTRUE$ypredProb <= p ])
    count <- count +1
  }

  names(probVectorTrue) <- seq(0.1,1,by = 0.05)  
  barplot(probVectorTrue, las=2, main ="Predicted value when 'real value' == 1")
  
  
  
  
  probVectorFalse <- NULL
  count <- 1
  for(p in seq(0.1,1,by = 0.05)){    
    probVectorFalse[count] <- length(DFytestFALSE$ypredProb[DFytestFALSE$ypredProb >= (p-0.05) & DFytestFALSE$ypredProb <= p ])
    count <- count +1
  }
  
  names(probVectorFalse) <- seq(0.1,1,by = 0.05)
  barplot(probVectorFalse, las=2, main ="Predicted value when 'real value' == 0")
  
  dev.off()
}