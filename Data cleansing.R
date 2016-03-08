
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)

# Load config file with root path, etc
source("Config.R")

# Load every filename of datasets
filenames <- list.files(paste0(path, "/tennis_atp-master"), 
                        pattern="atp_matches_201", 
                        full.names=TRUE
)

# Bind all datasets to create a sigle one
for (i in 1:length(filenames))
{
  dataset <- read.csv(filenames[i])
  
  # Remove matches with non-ranked players
  dataset <- dataset[-which(is.na(dataset$winner_rank)),]
  dataset <- dataset[-which(is.na(dataset$loser_rank)),]
  
  # The winner was the one with the highest ranking?
  dataset$w_is_better_ranked <- dataset$winner_rank < dataset$loser_rank
  dataset$w_is_better_ranked <- as.factor(dataset$w_is_better_ranked)
  
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


set.seed(2)
randomIndex <- sample(x = nrow(matches)
                      , size = nrow(matches)/2
)

# Randomize the position of the winner columns to avoid having them always in the first place.
for(i in randomIndex){
  
  winner_cols <- matches[i,8:17]
  loser_cols  <- matches[i,18:27]
  
  matches[i,8:17]  <- loser_cols
  matches[i,18:27] <- winner_cols
  
}
rm(i, winner_cols, loser_cols, randomIndex)

# Rename column names
colnames(matches) <- gsub("winner", "first_player", colnames(matches))
colnames(matches) <- gsub("loser", "second_player", colnames(matches))

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


# Data frame including only those matches where the winner was not the better ranked
# matches_w_not_b_ranked <- matches[matches$w_is_better_ranked == FALSE,]

matches <- matches[c(
  "surface",               "draw_size",                  "tourney_level",           "match_num",
  "first_player_seed",     "first_player_entry",         "first_player_hand",       "first_player_ht",
  "first_player_age",      "first_player_rank_points",   "second_player_seed",      "second_player_entry",
  "second_player_hand",    "second_player_ht",           "second_player_age",       "second_player_rank_points",  
  "best_of",               "round",                      "w_is_better_ranked"
)]

save(matches, file=paste0(path, "/Matches-clean.RData"))
