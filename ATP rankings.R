
library(dplyr)

# Load config file with root path, etc
source("Config.R")

# ATP rankings current 
rankings_current <- read.csv(paste0(path, "/tennis_atp-master/atp_rankings_current.csv"), header = FALSE)
colnames(rankings_current) <- c("ranking_date", "ranking", "player_id", "ranking_points")

# Dates as dates
rankings_current$ranking_date <- as.Date(as.character(rankings_current$ranking_date),format="%Y%m%d")

str(rankings_current)


# ATP Players
players <- read.csv(paste0(path, "/tennis_atp-master/atp_players.csv"), header = FALSE)
colnames(players) <- c("player_id", "first_name", "last_name", "hand", "birth_date", "country_code")

# Dates as dates
players$birth_date <- as.Date(as.character(players$birth_date),format="%Y%m%d")

str(players)




# Caution: player_id repeated cases in rankings_current

# Paste and save full name to the players dataframe
players$full_name <- paste(players$first_name, players$last_name, sep=" ")
head(players)

# Remove all duplicated cases
players <- players[-which(duplicated(players$player_id)),]
head(players)

# Add full name to current ranking
rankings_current$full_name <- left_join(
  rankings_current, 
  players,
  by="player_id"
  )[,"full_name"]

head(rankings_current)

# Create the "/tennis_atp-master/modified" folder if it does not already exists
dir.create(
  file.path(
    paste0(path, "/tennis_atp-master"), 
    'modified'
    )
  )

write.csv(
  rankings_current, 
  paste0(path, "/tennis_atp-master/modified/rankings_current.csv"),
  row.names=FALSE
  )

write.csv(
  players, 
  paste0(path, "/tennis_atp-master/modified/players.csv"),
  row.names=FALSE
  )




