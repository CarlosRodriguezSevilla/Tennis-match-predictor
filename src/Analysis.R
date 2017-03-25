
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


png(filename = "out/mean_data_l.png", width=800)
mean_data_l=reshape2::melt(data          = LoadTrainingAndTesting_csv, 
                             id.vars       = "data_source", 
                             variable.name = "interval", 
                             measure.vars  = 2:4)
mean_data_l[is.na(mean_data_l$value), "value"] <- 0
mean_data_l$data_source <- factor(
  x = mean_data_l$data_source, 
  levels = sort(unique(as.character(mean_data_l$data_source)), dec=T))
ggplot(data = mean_data_l, 
       aes(x = interval, y = value, fill = data_source)) + 
  stat_summary(fun.y="mean", position=position_dodge(), geom="bar") + 
  xlab(NULL)+ylab("Seconds")
dev.off()

png(filename = "out/mean_data_tt.png", width=800)
mean_data_tt=reshape2::melt(data          = LoadTrainingAndTesting_csv, 
                             id.vars       = "data_source", 
                             variable.name = "interval", 
                             measure.vars  = 5:length(LoadTrainingAndTesting_csv))
mean_data_tt[is.na(mean_data_tt$value), "value"] <- 0
mean_data_tt$data_source <- factor(
  x = mean_data_tt$data_source, 
  levels = sort(unique(as.character(mean_data_tt$data_source)), dec=T))
ggplot(data = mean_data_tt, 
       aes(x = interval, y = value, fill = data_source)) + 
  stat_summary(fun.y="mean", position=position_dodge(), geom="bar") + 
  xlab(NULL)+ylab("Seconds")
dev.off()


ylim_group <- c(0, max(c(apply(X = r_csv,          FUN = mean, MARGIN = 2), 
                         apply(X = mongodb_csv,    FUN = mean, MARGIN = 2), 
                         apply(X = postgresql_csv, FUN = mean, MARGIN = 2))))

png(filename = "out/r_csv.png", width = 800)
par(mar = default_mar + c(4,0,0,0))
barplot(height = sapply(X = r_csv, FUN = mean), 
        main = "R",
        ylab = "seconds",
        ylim = ylim_group,
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
        ylim = ylim_group,
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
        ylim = ylim_group,
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
  stat_summary(fun.y="mean", position=position_dodge(), geom="bar") + 
  xlab(NULL)+ylab("Seconds")
dev.off()
