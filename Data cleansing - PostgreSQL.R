# Let's try to mimic the operations currently coded in the 'Data cleansing.R' file, with PostgreSQL this time

rm(list=ls()) # Clear workspace

library(RPostgreSQL)
library(dplyr)
library(tidyr)

source("Config.R") # Load config file with root path, etc


# Load every filename of datasets
filenames <- list.files(paste0(path, "/tennis_atp-master"), 
                        pattern="atp_matches_[0-9]{4}", 
                        full.names=TRUE
)

pw <- {
  "tennispredictor"
}

# Loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

# Creates a connection to the postgres database
con <- dbConnect(
  drv, dbname = "tennis",
  host = "localhost", port = 5432,
  user = "tennispredictor", password = pw
)
rm(pw) # removes the password

# Delete matches table if it already exists
if ( dbExistsTable(con, "matches") ){
  dbRemoveTable(con, "matches")
}

# Specifies the details of the table before creating it
sql_command <- "CREATE TABLE matches
(
  tourney_id varchar(12),
  tourney_name varchar(50),
  surface varchar(10),
  draw_size smallint,
  tourney_level varchar(2),
  tourney_date date,
  match_num smallint,
  winner_id integer,
  winner_seed smallint,
  winner_entry varchar(2),
  winner_name varchar(30),
  winner_hand varchar(2),
  winner_ht smallint,
  winner_ioc char(3),
  winner_age numeric(4,2),
  winner_rank smallint,
  winner_rank_points smallint,
  loser_id integer,
  loser_seed smallint,
  loser_entry varchar(2),
  loser_name varchar(30),
  loser_hand varchar(2),
  loser_ht smallint,
  loser_ioc char(3),
  loser_age numeric(4,2),
  loser_rank smallint,
  loser_rank_points smallint,
  score varchar(50),
  best_of smallint,
  round varchar(4),
  minutes smallint,  
  w_ace smallint,
  w_df smallint,
  w_svpt smallint,
  w_1stIn smallint,
  w_1stWon smallint, 
  w_2ndWon smallint,
  w_SvGms smallint,
  w_bpSaved smallint,
  w_bpFaced smallint,
  l_ace smallint,
  l_df smallint,   
  l_svpt smallint,
  l_1stIn smallint,
  l_1stWon smallint,
  l_2ndWon smallint,
  l_SvGms smallint,
  l_bpSaved smallint,
  l_bpFaced smallint, 

  w_is_tallest boolean
)

WITH (
  OIDS=FALSE
);

ALTER TABLE matches OWNER TO tennispredictor;
"

# Sends the command and creates the table
dbGetQuery(con, sql_command)
rm(sql_command)

# Add csvs to the matches table
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
  
  # con$insert(dataset)
  dbWriteTable(
    con, "matches", 
    value = dataset, 
    append = TRUE, 
    row.names = FALSE
  )
}
rm(i, filenames, dataset)

matches <- dbGetQuery(con, "SELECT * from matches")

# Convert names to characters. Not necessary here. Already characters
# Were they left as factors, troubles would arise due to new levels
# matches$winner_name <- as.character(matches$winner_name)
# matches$loser_name <- as.character(matches$loser_name)

# Replicate every single row swapping winner columns for loser columns. 
# Rename column names
colnames(matches) <- gsub("winner", "first_player", colnames(matches))
colnames(matches) <- gsub("loser", "second_player", colnames(matches))

# Save winner and loser columns into variables
winner_cols <- matches[, grep("first_player", colnames(matches))]
loser_cols  <- matches[, grep("second_player", colnames(matches))]

# Duplicate dataframe for inverted results
matchesInverted <- matches

# Invert results
for (name_second in colnames(loser_cols)){
  name_first <- gsub("second_player", "first_player", name_second)
  matchesInverted[,name_first] <- loser_cols[,name_second]
}

for (name_first in colnames(winner_cols)){
  name_second <- gsub("first_player", "second_player", name_first)
  matchesInverted[,name_second] <- winner_cols[,name_first]
}

rm(loser_cols, winner_cols, name_first, name_second)

# Intersect the rows of the previous dataset with the ones of the inverted one.
# The row as it came will appear first. The duplicated and inverted will be just below.
n <- nrow(matches)
matches <- rbind(matches, matchesInverted)
matches <- matches[kronecker(1:n, c(0, n), "+"), ]
rm(matchesInverted, n)


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
matches$first_player_id     <- as.factor(matches$first_player_id)  # Even though it won't be added to the model
matches$second_player_id    <- as.factor(matches$second_player_id) # Even though it won't be added to the model
matches$first_player_seed   <- as.factor(matches$first_player_seed)
matches$second_player_seed  <- as.factor(matches$second_player_seed)

# Format date. Not necessary here. Already in the right date format
# matches$tourney_date <- as.Date(as.character(matches$tourney_date),format="%Y%m%d")

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
  "surface",               "draw_size",                  "tourney_level",           "match_num",
  "first_player_seed",     "first_player_entry",         "first_player_hand",       "first_player_ht",
  "first_player_age",      "first_player_rank_points",   "second_player_seed",      "second_player_entry",
  "second_player_hand",    "second_player_ht",           "second_player_age",       "second_player_rank_points",  
  "best_of",               "round",                      "w_is_tallest"
)]

save(matches, file=paste0(path, "/Matches-clean(PostgreSQL).RData"))

# Close the connection
dbDisconnect(con)
dbUnloadDriver(drv)
