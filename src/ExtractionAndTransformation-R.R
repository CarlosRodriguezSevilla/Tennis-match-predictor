

args=(commandArgs(trailingOnly = TRUE))

if(length(args)>0){
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  } 
}

setwd(path)
rm(list=ls()) # Clear workspace

library(dplyr)
library(tidyr)

# source(file = "src/Config.R") # Load config file with root path, etc


# EXTRACTION

# Load every filename of datasets
filenames <- list.files("dat",
                        pattern="atp_matches_[0-9]{4}", 
                        full.names=TRUE
)

matches <- data.frame()

# Bind all datasets to create a sigle one
for (i in 1:length(filenames))
{
  dataset <- read.csv(filenames[i])
  
  # Was the winner the tallest player? (response variable)
  dataset$w_is_tallest <- dataset$winner_ht > dataset$loser_ht
  dataset$w_is_tallest <- as.factor(dataset$w_is_tallest)
  
  # Remove the rows where the response variable is NA.
  if(length(which(is.na(dataset$w_is_tallest)))>0){
    dataset <- dataset[-which(is.na(dataset$w_is_tallest)),]
  }
  
  if(!exists("matches"))
  {
    matches <- dataset
  } else
  {
    matches <- rbind(matches, dataset)
  }
  
}
rm(i, filenames, dataset)


# TRANSFORMATION    

# Extract the year of the game from the 'tourney_date' field
matches$tourney_date  <- as.Date(as.character(matches$tourney_date),format="%Y%m%d")
matches$tourney_year  <- as.numeric(format(matches$tourney_date,'%Y'))
matches$tourney_month <- as.numeric(format(matches$tourney_date,'%m'))

# Convert names to characters.
# Were they left as factors, troubles would arise due to new levels
matches$winner_name <- as.character(matches$winner_name)
matches$loser_name <- as.character(matches$loser_name)

# Replicate every single row swapping winner columns for loser columns. 
# Rename column names
colnames(matches) <- gsub("winner", "first_player", colnames(matches))
colnames(matches) <- gsub("loser", "second_player", colnames(matches))

# Save winner and loser columns into variables
winner_cols <- matches[, grep("first_player", colnames(matches))]
loser_cols  <- matches[, grep("second_player", colnames(matches))]

# Duplicate dataframe for swapped results
matchesInverted <- matches

# Swap winner and loser columns
for (name_second in colnames(loser_cols)){
  name_first <- gsub("second_player", "first_player", name_second)
  matchesInverted[,name_first] <- loser_cols[,name_second]
}

for (name_first in colnames(winner_cols)){
  name_second <- gsub("first_player", "second_player", name_first)
  matchesInverted[,name_second] <- winner_cols[,name_first]
}

rm(loser_cols, winner_cols, name_first, name_second)

# Intersect the rows of the previous dataset with the ones of the swapped one.
# The row as it came will appear first. The duplicated and swapped will be just below.
n <- nrow(matches)
matches <- rbind(matches, matchesInverted)
matches <- matches[kronecker(1:n, c(0, n), "+"), ]
rm(matchesInverted, n)

# Difference in height
matches$diff_ht <- matches$first_player_ht - matches$second_player_ht

# Difference in age
matches$diff_age <- matches$first_player_age - matches$second_player_age

# Difference in rank points
matches$diff_rank_points <- matches$first_player_rank_points - matches$second_player_rank_points

# Remove the rows with non-ranked players
if(length(which(is.na(matches$diff_rank_points)))>0){
  matches <- matches[-which(is.na(matches$diff_rank_points)),]
}

matches <- matches[c(
  "surface",               "tourney_year",               "tourney_level",           "match_num",
  "first_player_seed",     "first_player_entry",         "first_player_hand",       "first_player_ht",
  "first_player_age",      "first_player_rank_points",   "second_player_seed",      "second_player_entry",
  "second_player_hand",    "second_player_ht",           "second_player_age",       "second_player_rank_points",  
  "best_of",               "round",                      "draw_size",               "w_is_tallest"
)]

save(matches, file="rda/Matches-clean.RData")

