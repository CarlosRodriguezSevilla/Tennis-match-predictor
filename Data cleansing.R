
library(dplyr)
library(tidyr)

# Load config file with root path, etc
source("Config.R")

# filenames <- list.files("temp", pattern="*.csv", full.names=TRUE)
# ldf <- lapply(filenames, read.csv)


# ATP tour-level main draw matches 2015
matches_2015 <- read.csv(paste0(path, "/tennis_atp-master/atp_matches_2015.csv"))

# Remove matches with non-ranked players
matches_2015 <- matches_2015[-which(is.na(matches_2015$winner_rank)),]
matches_2015 <- matches_2015[-which(is.na(matches_2015$loser_rank)),]

# The winner was the one with the highest ranking?
matches_2015$w_is_better_ranked <- matches_2015$winner_rank < matches_2015$loser_rank
matches_2015$w_is_better_ranked <- as.factor(matches_2015$w_is_better_ranked)

matches_2015$tourney_date <- as.Date(as.character(matches_2015$tourney_date),format="%Y%m%d")





set.seed(47)
randomIndex <- sample(x = nrow(matches_2015)
                      , size = nrow(matches_2015)/2
)

for(i in randomIndex){
  
  winner_cols <- matches_2015[i,8:17]
  loser_cols  <- matches_2015[i,18:27]
  
  matches_2015[i,8:17]  <- loser_cols
  matches_2015[i,18:27] <- winner_cols
  
}
rm(i, winner_cols, loser_cols, randomIndex)

colnames(matches_2015) <- gsub("winner", "1st_player", colnames(matches_2015))
colnames(matches_2015) <- gsub("loser", "2nd_player", colnames(matches_2015))




matches <- matches_2015
rm(matches_2015)

save.image(paste0(path, "/Matches-clean.RData"))
