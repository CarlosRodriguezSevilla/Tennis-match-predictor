
rm(list=ls()) # Clear workspace
args=(commandArgs(trailingOnly = TRUE))

if(length(args)>0){
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  } 
}

setwd(path)

library(ggplot2)
library(reshape2)

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

hues <- seq(15, 375, length = 4)
cols <- hcl(h = hues, l = 65, c = 100)[1:3]

default_mar <- par("mar")


png(filename = "out/mean_data_ltt.png", width=800)
mean_data_ltt=reshape2::melt(LoadTrainingAndTesting_csv, id.vars="data_source", variable.name="interval")
mean_data_ltt[is.na(mean_data_ltt$value), "value"] <- 0
mean_data_ltt$data_source <- factor(
  x = mean_data_ltt$data_source, 
  levels = sort(unique(as.character(mean_data_ltt$data_source)), dec=T))
ggplot(data = mean_data_ltt, 
       aes(x = interval, y = value, fill = data_source)) + 
  geom_bar(stat="identity",position="dodge")+
  xlab(NULL)+ylab("Seconds")
dev.off()


png(filename = "out/r_csv.png", width = 800)
par(mar = default_mar + c(4,0,0,0))
barplot(height = sapply(X = r_csv, FUN = mean), 
        main = "R",
        ylab = "seconds",
        ylim = c(0,20),
        col = cols[1],
        las    = 2,
        border = NA)
par(mar = default_mar)
dev.off()

png(filename = "out/mongodb_csv.png", width = 800)
par(mar = default_mar + c(4,0,0,0))
barplot(height = sapply(X = mongodb_csv, FUN = mean), 
        main = "MongoDB",
        ylab = "seconds",
        ylim = c(0,20),
        col = cols[3],
        las    = 2,
        border = NA)
par(mar = default_mar)
dev.off()

png(filename = "out/postgresql_csv.png", width = 800)
par(mar = default_mar + c(4,0,0,0))
barplot(height = sapply(X = postgresql_csv, FUN = mean), 
        main = "PostgreSQL",
        ylab = "seconds",
        ylim = c(0,20),
        col = cols[2],
        las    = 2,
        border = NA)
par(mar = default_mar)
dev.off()

mean_data_et <- data.frame(R=sapply(X = r_csv,          FUN = mean))
mean_data_et$MongoDB    <-   sapply(X = mongodb_csv,    FUN = mean)
mean_data_et$PostgreSQL <-   sapply(X = postgresql_csv, FUN = mean)
mean_data_et$Mark_time  <- rownames(mean_data_et)
rownames(mean_data_et)  <- NULL

mean_data_et=reshape2::melt(mean_data_et, id.vars="Mark_time", variable.name="data_source")
mean_data_et$value       <- round( x = mean_data_et$value, 2)
mean_data_et$Mark_time   <- factor(x = mean_data_et$Mark_time, levels = unique(mean_data_et$Mark_time))
mean_data_et$data_source <- factor(
  x = mean_data_et$data_source, 
  levels = sort(unique(as.character(mean_data_et$data_source)), dec=T))

png(filename = "out/mean_data_et.png", width = 800)
ggplot(mean_data_et, aes(x = Mark_time, y = value, fill = data_source)) + 
  geom_bar(stat="identity",position="dodge")+
  xlab(NULL)+ylab("Seconds")
dev.off()
