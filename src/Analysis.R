
rm(list=ls()) # Clear workspace
args=(commandArgs(trailingOnly = TRUE))

if(length(args)>0){
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  } 
}

setwd(path)


# Read data

r_csv          <- read.table(
  file = "out/R/ExtractionAndTransformation-R.csv", 
  header = T, 
  sep = ",")

mongodb_csv    <- read.table(
  file = "out/MongoDB/ExtractionAndTransformation-MongoDB.csv", 
  header = T, 
  sep = ",")

postgresql_csv <- read.table(
  file = "out/PostgreSQL/ExtractionAndTransformation-PostgreSQL.csv", 
  header = T, 
  sep = ",")

LoadTrainingAndTesting_csv <- read.table(
  file = "out/LoadTrainingAndTesting/LoadTrainingAndTesting.csv",
  header = T, 
  sep = ",")


plot(
  formula = LoadTrainingAndTesting_csv$end_time~LoadTrainingAndTesting_csv$data_source,
  xlab=NULL, 
  ylab = "seconds",
  las=2)



barplot(height = sapply(X = r_csv, FUN = mean), 
        las    = 2, 
        ylab = "seconds", 
        col = "light blue", 
        main = "R")

barplot(height = sapply(X = mongodb_csv, FUN = mean), 
        las    = 2, 
        ylab = "seconds", 
        col = "light blue", 
        main = "MongoDB")

barplot(height = sapply(X = postgresql_csv, FUN = mean), 
        las    = 2, 
        ylab = "seconds", 
        col = "light blue", 
        main = "PostgreSQL")

mean_data <- data.frame(R=sapply(X = r_csv,          FUN = mean))
mean_data$MongoDB    <-   sapply(X = mongodb_csv,    FUN = mean)
mean_data$PostgreSQL <-   sapply(X = postgresql_csv, FUN = mean)
mean_data$Mark_time  <- rownames(mean_data)
rownames(mean_data)  <- NULL

mean_data=reshape2::melt(mean_data, id.vars="Mark_time", variable.name="data_source")
mean_data$value     <- round( x = mean_data$value, 2)
mean_data$Mark_time <- factor(x = mean_data$Mark_time, levels = unique(mean_data$Mark_time))
mean_data

ggplot(mean_data, aes(x = Mark_time, y = value, fill = data_source)) + 
  geom_bar(stat="identity",position="dodge")+
  xlab(NULL)+ylab("Seconds")
