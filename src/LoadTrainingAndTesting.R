
rm(list=ls()) # Clear workspace
args=(commandArgs(trailingOnly = TRUE))

if(length(args)>0){
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  } 
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
         dbDisconnect(con)
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


# Convert to factor where needed
matches$surface             <- as.factor(matches$surface)
matches$draw_size           <- as.factor(matches$draw_size)
matches$tourney_level       <- as.factor(matches$tourney_level)
matches$best_of             <- as.factor(matches$best_of)
matches$round               <- as.factor(matches$round)
matches$w_is_tallest        <- as.factor(matches$w_is_tallest)

matches$first_player_entry  <- as.factor(matches$first_player_entry)
matches$second_player_entry <- as.factor(matches$second_player_entry)
matches$first_player_hand   <- as.factor(matches$first_player_hand)
matches$second_player_hand  <- as.factor(matches$second_player_hand)
matches$first_player_seed   <- as.factor(matches$first_player_seed)
matches$second_player_seed  <- as.factor(matches$second_player_seed)


# Sampling
set.seed(2)
trainIndex <- sample(x = nrow(matches)
                     , size = nrow(matches)*0.7
)

train <- matches[trainIndex,]
test  <- matches[-trainIndex,]
rm(matches)

rm(trainIndex)


# TRAINING

svmModel <- ksvm(w_is_tallest~.,
                 data=train,
                 type="C-svc",
                 # Classifier
                 kernel="rbfdot",
                 # Radial Basis kernel function "Gaussian"
                 kpar = "automatic",
                 prob.model = TRUE)

adaModel <- ada(w_is_tallest~.,
                data=train,
                type="real")

rfsModel <- randomForest(w_is_tallest~.,
                         data=train,
                         na.action=na.omit)

# TESTING

# Predicted values (logical)
ypredSVM <- predict(object = svmModel, test)
ypredADA <- predict(object = adaModel, na.omit(test))
ypredRFS <- predict(object = rfsModel, na.omit(test))

# Predicted values (probabilities)
ypredProbSVM <- predict(object = svmModel, na.omit(test), type="prob")
ypredProbADA <- predict(object = adaModel, na.omit(test), type="prob")
ypredProbRFS <- predict(object = rfsModel, na.omit(test), type="prob")

# Prediction objects
predSVM <- prediction(ypredProbSVM[,2], na.omit(test)["w_is_tallest"])
predADA <- prediction(ypredProbADA[,2], na.omit(test)["w_is_tallest"])
predRFS <- prediction(ypredProbRFS[,2], na.omit(test)["w_is_tallest"])


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
  ytest       = na.omit(test)[["w_is_tallest"]]
)

plotModel(
  name        = "AdaBoost", 
  data_source = data_source,
  prediction  = predADA,
  ypred       = ypredADA, 
  ypredProb   = ypredProbADA, 
  ytest       = na.omit(test)[["w_is_tallest"]]
)

plotModel(
  name        = "Random Forest", 
  data_source = data_source,
  prediction  = predRFS,
  ypred       = ypredRFS, 
  ypredProb   = ypredProbRFS, 
  ytest       = na.omit(test)[["w_is_tallest"]]
)

timing_results$end_time <- get_timing(Sys.time(), init_time)
write_results(results = timing_results, path = path, data_source = "LoadTrainingAndTesting")