
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)

# Load config file with root path, etc
source("Config.R")

# Load every filename of datasets
filenames <- list.files(paste0(path, "/tennis_atp-master"), 
                        pattern="atp_matches_[0-9]{4}", 
                        full.names=TRUE
)

# Bind all datasets to create a sigle one
for (i in 1:length(filenames))
{
  dataset <- read.csv(filenames[i])
  
  # Remove matches with non-ranked players
  # dataset <- dataset[-which(is.na(dataset$winner_rank)),]
  # dataset <- dataset[-which(is.na(dataset$loser_rank)),]
  
  # Remove the matches that doesn't have the height variable computed
  if(length(which(is.na(dataset$winner_ht)))>0){
    dataset <- dataset[-which(is.na(dataset$winner_ht)),] 
  }
  
  if(length(which(is.na(dataset$loser_ht)))>0){
    dataset <- dataset[-which(is.na(dataset$loser_ht)),]
  }
  
  # Was the winner the tallest player?
  dataset$w_is_tallest <- dataset$winner_ht < dataset$loser_ht
  dataset$w_is_tallest <- as.factor(dataset$w_is_tallest)
  
  dataset$tourney_date <- as.Date(as.character(dataset$tourney_date),format="%Y%m%d")
  
  if(!exists("matches"))
  {
    matches <- dataset
  }
  else
  {
    matches <- rbind(matches, dataset)
  }
  
}
rm(i, filenames, dataset)


# Convert names to characters.
# Were they left as factors, troubles would arise due to new levels
matches$winner_name <- as.character(matches$winner_name)
matches$loser_name <- as.character(matches$loser_name)


# Rename column names
colnames(matches) <- gsub("winner", "first_player", colnames(matches))
colnames(matches) <- gsub("loser", "second_player", colnames(matches))


# Replicate every single row swapping winner columns for loser columns. 

# Save winner and loser columns into variables
winner_cols <- matches[,8:17]
loser_cols  <- matches[,18:27]

# Create new dataframe for inverted results
matchesInverted <- matches

# Invert results
matchesInverted[,8:17]  <- loser_cols
matchesInverted[,18:27] <- winner_cols
rm(loser_cols, winner_cols)

# Intersect the rows of the previous dataset with the ones of the inverted one.
# The row as it came will appear first. The inverted will be just below.
n <- nrow(matches)
matches <- rbind(matches, matchesInverted)
matches <- matches[kronecker(1:n, c(0, n), "+"), ]
rm(matchesInverted, n)


# Convert to factor where needed
matches$draw_size          <- as.factor(matches$draw_size)
matches$first_player_id    <- as.factor(matches$first_player_id)  # Even though it won't be added to the model
matches$second_player_id   <- as.factor(matches$second_player_id) # Even though it won't be added to the model
matches$first_player_seed  <- as.factor(matches$first_player_seed)
matches$second_player_seed <- as.factor(matches$second_player_seed)
matches$best_of            <- as.factor(matches$best_of)

# Difference in height
matches$diff_ht <- matches$first_player_ht - matches$second_player_ht

# Difference in age
matches$diff_age <- matches$first_player_age - matches$second_player_age

# Difference in rank points
matches$diff_rank_points <- matches$first_player_rank_points - matches$second_player_rank_points


matches <- matches[c(
  "surface",               "draw_size",                  "tourney_level",           "match_num",
  "first_player_seed",     "first_player_entry",         "first_player_hand",       "first_player_ht",
  "first_player_age",      "first_player_rank_points",   "second_player_seed",      "second_player_entry",
  "second_player_hand",    "second_player_ht",           "second_player_age",       "second_player_rank_points",  
  "best_of",               "round",                      "w_is_tallest"
)]

save(matches, file=paste0(path, "/Matches-clean.RData"))
