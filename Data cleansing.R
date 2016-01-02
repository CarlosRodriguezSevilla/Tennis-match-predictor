
library(dplyr)
library(tidyr)

# Load config file with root path, etc
source("Config.R")

filenames <- list.files(paste0(path, "/tennis_atp-master"), 
                        pattern="atp_matches_201", 
                        full.names=TRUE
                        )

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

# matches$draw_size <- as.factor(matches$draw_size)


set.seed(47)
randomIndex <- sample(x = nrow(matches)
                      , size = nrow(matches)/2
)

for(i in randomIndex){
  
  winner_cols <- matches[i,8:17]
  loser_cols  <- matches[i,18:27]
  
  matches[i,8:17]  <- loser_cols
  matches[i,18:27] <- winner_cols
  
}
rm(i, winner_cols, loser_cols, randomIndex)

colnames(matches) <- gsub("winner", "first_player", colnames(matches))
colnames(matches) <- gsub("loser", "second_player", colnames(matches))



save(matches, file=paste0(path, "/Matches-clean.RData"))
