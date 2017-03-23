
rm(list=ls()) # Clear workspace
args=(commandArgs(trailingOnly = TRUE))

if(!interactive()){
  if(length(args)>0){
    for(i in 1:length(args)){
      eval(parse(text=args[[i]]))
    } 
  }
} else{
  data_source <- sample(x = c("R", "MongoDB", "PostgreSQL"), size = 1)
}

setwd(path)
timing_results <- list(data_source=data_source)
init_time <- Sys.time()


library(RPostgreSQL)
library(mongolite)

library(dplyr)
library(tidyr)

library(kernlab)
library(ada)
library(randomForest)

library(ROCR)
library(gplots)
library(knitr)

source(file = "src/AuxiliarFunctions.R")

timing_results$load_libraries <- get_timing(Sys.time(), init_time)


# LOAD

switch(data_source,
       
       "MongoDB"={
         # Create connection to the cleaned matches collection
         con <- mongo(
           collection = "matches_clean", 
           db = "tennis", 
           url = "mongodb://localhost",
           verbose = TRUE
         )
         
         # Check data availability
         if(con$count() == 0){
           stop("No data available.") 
         }
         
         # Fetch all the matches
         matches <- con$find()
         
         # Close the connection
         rm(con)
         
         message("Dataset is loaded from MongoDB")
       },
       
       "PostgreSQL"={
         pw <- { "tennispredictor" }
         
         # Loads the PostgreSQL driver
         drv <- dbDriver("PostgreSQL")
         
         # Creates a connection to the PostgreSQL database
         con <- dbConnect(
           drv = drv, 
           dbname = "tennis",
           host = "localhost", 
           port = 5432,
           user = "tennispredictor", 
           password = pw
         )
         rm(pw) # removes the password
         
         # Fetch all the matches
         matches <- dbGetQuery(con, "SELECT * from matches_clean")
         
         # Close the connection
         lapply(X = dbListConnections(drv = drv), FUN = dbDisconnect)
         dbUnloadDriver(drv)
         
         message("Dataset is loaded from PostgreSQL")
         
       },
       
       "R"={
         load(file = "rda/Matches-clean.RData")
         message("Dataset is loaded from RData")
       },
       
       stop(paste0("Illegal argument 'source': ", source, 
                   ". \nNot one of 'PostgreSQL', 'MongoDB' or 'R'."))
)

timing_results$extraction_done <- get_timing(Sys.time(), init_time)

# Convert to factor where needed
to_factors <- c("surface", "draw_size", "tourney_level", "best_of", 
                "round", "w_is_fp", "first_player_entry", 
                "second_player_entry", "first_player_hand", 
                "second_player_hand", "first_player_seed", 
                "second_player_seed")

for(column in to_factors){
  matches[,column] <- as.factor(matches[,column])
}



# Sampling
set.seed(2)
trainIndex <- sample(x = nrow(matches)
                     , size = nrow(matches)*0.7
)

train <- matches[trainIndex,]
test  <- matches[-trainIndex,]
rm(matches)

rm(trainIndex)

timing_results$sampling <- get_timing(Sys.time(), init_time)

# TRAINING

svmModel <- ksvm(w_is_fp~.,
                 data=train,
                 type="C-svc",
                 # Classifier
                 kernel="rbfdot",
                 # Radial Basis kernel function "Gaussian"
                 kpar = "automatic",
                 prob.model = TRUE)

timing_results$svm_training <- get_timing(Sys.time(), init_time)

adaModel <- ada(w_is_fp~.,
                data=train,
                type="real")

timing_results$ada_training <- get_timing(Sys.time(), init_time)

rfsModel <- randomForest(w_is_fp~.,
                         data=train,
                         na.action=na.omit)

timing_results$rfs_training <- get_timing(Sys.time(), init_time)

# TESTING

# Testing SVM
# Predicted values (logical)
ypredSVM <- predict(object = svmModel, test) 

# Predicted values (probabilities)
ypredProbSVM <- predict(object = svmModel, na.omit(test), type="prob")

# Prediction objects
predSVM <- prediction(ypredProbSVM[,2], na.omit(test)["w_is_fp"])

timing_results$svm_testing <- get_timing(Sys.time(), init_time)


# Testing ADA
# Predicted values (logical)
ypredADA <- predict(object = adaModel, na.omit(test))

# Predicted values (probabilities)
ypredProbADA <- predict(object = adaModel, na.omit(test), type="prob")

# Prediction objects
predADA <- prediction(ypredProbADA[,2], na.omit(test)["w_is_fp"])

timing_results$ada_testing <- get_timing(Sys.time(), init_time)


# Testing RFS
# Predicted values (logical)
ypredRFS <- predict(object = rfsModel, na.omit(test))

# Predicted values (probabilities)
ypredProbRFS <- predict(object = rfsModel, na.omit(test), type="prob")

# Prediction objects
predRFS <- prediction(ypredProbRFS[,2], na.omit(test)["w_is_fp"])

timing_results$rfs_testing <- get_timing(Sys.time(), init_time)


# Save and delete the models
save(svmModel, adaModel, rfsModel, file="rda/Models.RData")
rm(svmModel, adaModel, rfsModel)


# Results
plotModel(
  name        = "SVM", 
  data_source = data_source,
  prediction  = predSVM,
  ypred       = ypredSVM, 
  ypredProb   = ypredProbSVM, 
  ytest       = na.omit(test)[["w_is_fp"]]
)

plotModel(
  name        = "AdaBoost", 
  data_source = data_source,
  prediction  = predADA,
  ypred       = ypredADA, 
  ypredProb   = ypredProbADA, 
  ytest       = na.omit(test)[["w_is_fp"]]
)

plotModel(
  name        = "RandomForest", 
  data_source = data_source,
  prediction  = predRFS,
  ypred       = ypredRFS, 
  ypredProb   = ypredProbRFS, 
  ytest       = na.omit(test)[["w_is_fp"]]
)

write_results(results = timing_results, path = path, data_source = "LoadTrainingAndTesting")

timing_results$reporting <- get_timing(Sys.time(), init_time)
