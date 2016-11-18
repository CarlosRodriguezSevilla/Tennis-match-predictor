

get_timing <- function(end_time, init_time){
  return(as.numeric(difftime(end_time, init_time), units="secs"))
}

write_results <- function(results, data_source){
  
}

plotModel <- function(name, prediction, ypred, ypredProb, ytest){
  
  switch (data_source,
          "MongoDB" = {
            resultsPath <- "MongoDB/"
          },
          "PostgreSQL" = {
            resultsPath <- "PostgreSQL/"
          },
          "R" = {
            resultsPath <- "R/"
          }
  )
  
  # Create the results folder if it does not already exists
  dir.create(paste0('out/', resultsPath), showWarnings = F)
  
  # Classification
  performance <- performance(prediction, "tpr", "fpr")
  tableModel  <- table(PREDICTION = ypred, TRUTH = ytest)
  accuracy    <- ( tableModel[1,1] + tableModel[2,2] ) / length(ytest)
  accuracy    <- round(accuracy, 2)
  
  # Plot
  png(filename = paste0("out/", resultsPath, name, ".png"), width = 768, height = 1024)
  # par(mfrow=c(2,2), mai=c(1.5,1,2.25,1)) # mai = c(bottom, left, top, right) 
  layout(matrix(c(1,2,3,4,5,5), 3, 2, byrow = TRUE))
  
  # ROC Curve
  par(mai=c(0.5, 1.5, 1, 0.42)) # mai = c(bottom, left, top, right) 
  plot(performance, main = name, cex.main = 2.5, cex.lab=1.5)
  abline(0,1, lty="dotted")
  
  # Back to default margins
  par(mai=c(1.02,0.82,0.82,0.42)) # mai = c(bottom, left, top, right) 
  
  # Confusion Matrix
  textplot(
    kable(
      list(tableModel, 
           paste0("Accuracy: ",accuracy)), 
      format = "pandoc"),
    cex=2.25
  )
  
  # Barplots
  DF <- data.frame(ytest     = as.numeric(as.logical(ytest)), 
                   ypred     = as.numeric(as.logical(ypred)), 
                   ypredProb = ypredProb[,2]
  )
  
  # Real value == 1
  DFPlot <- data.frame()
  count <- 1
  for(p in seq(0.05,1,by = 0.05)){
    DFPlot[count, "Predicted 1"] <- nrow(DF[DF$ypred == 1 & DF$ytest == 1 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    DFPlot[count, "Predicted 0"] <- nrow(DF[DF$ypred == 0 & DF$ytest == 1 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    count <- count+1
  }
  
  DFPlot <- t(DFPlot)
  colnames(DFPlot) <- seq(0.05,1,by = 0.05)
  barplot(DFPlot, 
          col= c("#33ff66","#ff3333"), 
          main = "Real value == 1", 
          xlab = "Predicted probability",
          ylab = "Number of observations"
  )
  legend("topright", 
         inset = c(0, 0), 
         legend = rownames(DFPlot), 
         cex = 1.5, 
         fill=c("#33ff66","#ff3333")
  )
  
  
  
  # Real value == 0
  DFPlot <- data.frame()
  count <- 1
  for(p in seq(0.05,1,by = 0.05)){
    DFPlot[count, "Predicted 1"] <- nrow(DF[DF$ypred == 1 & DF$ytest == 0 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    DFPlot[count, "Predicted 0"] <- nrow(DF[DF$ypred == 0 & DF$ytest == 0 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    count <- count+1
  }
  
  DFPlot <- t(DFPlot)
  colnames(DFPlot) <- seq(0.05,1,by = 0.05)
  barplot(DFPlot,
          col= c("#ff3333","#33ff66"), 
          main = "Real value == 0", 
          xlab = "Predicted probability",
          ylab = "Number of observations"
  )
  legend("topright", 
         inset = c(0, 0), 
         legend = rownames(DFPlot), 
         cex = 1.5, 
         fill=c("#ff3333","#33ff66")
  )
  
  
  
  # Hits vs Mistakes
  DFPlot <- data.frame()
  Occurrences <- vector() 
  count <- 1
  for(p in seq(0.05,1,by = 0.05)){
    DFPlot[count, "Hits"] <- nrow(DF[DF$ypred == 1 & DF$ytest == 1 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    DFPlot[count, "Hits"] <- DFPlot[count, "Hits"] + nrow(DF[DF$ypred == 0 & DF$ytest == 0 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    
    DFPlot[count, "Mistakes"] <- nrow(DF[DF$ypred == 0 & DF$ytest == 1 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    DFPlot[count, "Mistakes"] <- DFPlot[count, "Mistakes"] + nrow(DF[DF$ypred == 1 & DF$ytest == 0 & DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,])
    
    # To percentage
    Total <- DFPlot[count, "Hits"] + DFPlot[count, "Mistakes"] 
    DFPlot[count, "Hits"]     <- DFPlot[count, "Hits"]     / Total
    DFPlot[count, "Mistakes"] <- DFPlot[count, "Mistakes"] / Total
    
    Occurrences[count] <- ( nrow(DF[DF$ypredProb >= (p-0.05) & DF$ypredProb <= p ,]) / nrow(DF) ) * 100 
    Occurrences[count] <- round(Occurrences[count], digits = 1)
    
    count <- count+1
  }
  
  DFPlot <- t(DFPlot)
  colnames(DFPlot) <- seq(0.05,1,by = 0.05)
  bp <- barplot(DFPlot, 
                col= c("#33ff66","#ff3333"), 
                main = "Hits vs Mistakes (Percentage)", 
                xlab = "Predicted probability",
                ylab = "Percentage",
                ylim = c(0,1.1)
  )
  text(x = bp, y = 1.02, label=Occurrences, pos = 3, las=2)
  # legend("bottomright", 
  #        inset = c(0.07, 0.25), 
  #        legend = rownames(DFPlot), 
  #        cex = 2, 
  #        fill=c("#33ff66","#ff3333")
  #        )
  
  dev.off()
}

