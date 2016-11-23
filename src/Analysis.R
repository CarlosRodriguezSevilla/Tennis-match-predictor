
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
LoadTrainingAndTesting_csv$data_source <- factor(
  x = LoadTrainingAndTesting_csv$data_source, 
  levels = sort(unique(LoadTrainingAndTesting_csv$data_source), dec=T))

hues <- seq(15, 375, length = 4)
cols <- hcl(h = hues, l = 65, c = 100)[1:3]

default_mar <- par("mar")

png(filename = "out/LTT.png", width=800)
ggplot(LoadTrainingAndTesting_csv, aes(x=data_source, y=end_time, fill=data_source)) + 
  geom_boxplot() +
  scale_x_discrete(name ="Data source") + 
  scale_y_discrete(name ="Seconds") + 
  theme(legend.title = element_text(size = 20),
        legend.text  = element_text(size = 25))
dev.off()

png(filename = "out/r_csv.png")
par(mar=default_mar + c(4,0,0,0))
barplot(height = sapply(X = r_csv, FUN = mean), 
        main = "R",
        ylab = "seconds",
        ylim = c(0,30),
        col = cols[1],
        las    = 2)
dev.off()

png(filename = "out/mongodb_csv.png")
par(mar=default_mar + c(4,0,0,0))
barplot(height = sapply(X = mongodb_csv, FUN = mean), 
        main = "MongoDB",
        ylab = "seconds",
        ylim = c(0,30),
        col = cols[3],
        las    = 2)
dev.off()

png(filename = "out/postgresql_csv.png")
par(mar=default_mar + c(4,0,0,0))
barplot(height = sapply(X = postgresql_csv, FUN = mean), 
        main = "PostgreSQL",
        ylab = "seconds",
        ylim = c(0,30),
        col = cols[2],
        las    = 2)
dev.off()

mean_data <- data.frame(R=sapply(X = r_csv,          FUN = mean))
mean_data$MongoDB    <-   sapply(X = mongodb_csv,    FUN = mean)
mean_data$PostgreSQL <-   sapply(X = postgresql_csv, FUN = mean)
mean_data$Mark_time  <- rownames(mean_data)
rownames(mean_data)  <- NULL

mean_data=reshape2::melt(mean_data, id.vars="Mark_time", variable.name="data_source")
mean_data$value       <- round( x = mean_data$value, 2)
mean_data$Mark_time   <- factor(x = mean_data$Mark_time, levels = unique(mean_data$Mark_time))
mean_data$data_source <- factor(
  x = mean_data$data_source, 
  levels = sort(unique(as.character(mean_data$data_source)), dec=T))
mean_data

png(filename = "out/mean_data.png")
ggplot(mean_data, aes(x = Mark_time, y = value, fill = data_source)) + 
  geom_bar(stat="identity",position="dodge")+
  xlab(NULL)+ylab("Seconds")
dev.off()
