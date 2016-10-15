

rm(list=ls()) # Clear workspace

source("Config.R") # Load config file with root path, etc

load(paste0(path, "/Models.RData"))
test <- read.csv("/modified/atp_matches_2016.csv")

# Read characteristics already available in the datasets, then

# Ask for the non-available characteristics
a <- menu(choices=c(1,2))
match$asd <- a

x <- readLines(con=stdin(),1)
match$xsd <- x


# Predicted values (probabilities)
ypredProbSVM <- predict(object = svmModel, test, type="prob")
ypredProbADA <- predict(object = adaModel, test, type="prob")
ypredProbRFS <- predict(object = rfsModel, test, type="prob")