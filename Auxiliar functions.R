

plotModel <- function(name, prediction, model, ytest){
  
  # Classification
  ypred <- predict(object = model, test)
  resultsDF <- data.frame(ypred, ytest)
  performance <- performance(prediction, "tpr", "fpr")
  
  tableModel <- table(PREDICTION = ypred, TRUTH = ytest$w_is_older)
  
  png(filename = paste0("output/", name, ".png"), width = 768, height = 1024)
  par(mfrow=c(2, 1), mai=c(0.8,2,2,2)) # mai = c(bottom, left, top, right) 
  plot(performance, main = name, cex.main = 2.5, cex.lab=1.5)
  abline(0,1, lty="dotted")
  textplot(tableModel, halign = "center", cex = 1.5)
  dev.off()
}