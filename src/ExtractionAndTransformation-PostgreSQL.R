
rm(list=ls()) # Clear workspace
args=(commandArgs(trailingOnly = TRUE))

if(length(args)>0){
  for(i in 1:length(args)){
    eval(parse(text=args[[i]]))
  } 
}

setwd(path)
timing_results <- list()

init_time <- Sys.time()

library(RPostgreSQL)
library(dplyr)
library(tidyr)

source(file = "src/AuxiliarFunctions.R")

timing_results$loaded_libraries <- get_timing(Sys.time(), init_time)

# EXTRACTION

# Load every filename of datasets
filenames <- list.files("dat", 
                        pattern="atp_matches_[0-9]{4}", 
                        full.names=TRUE
)

pw <- { "tennispredictor"}

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

# Delete matches table if it already exists
if ( dbExistsTable(con, "matches_raw") ){
  dbRemoveTable(con, "matches_raw")
}

# Specifies the details of the table before creating it
sql_command <- "CREATE TABLE matches_raw
(
  tourney_id varchar(12),         tourney_name varchar(50),         surface varchar(10),
  draw_size smallint,             tourney_level varchar(2),         tourney_date date,
  match_num smallint,             winner_id integer,                winner_seed smallint,
  winner_entry varchar(2),        winner_name varchar(30),          winner_hand varchar(2),
  winner_ht smallint,             winner_ioc char(3),               winner_age numeric(4,2),
  winner_rank smallint,           winner_rank_points smallint,      loser_id integer,
  loser_seed smallint,            loser_entry varchar(2),           loser_name varchar(30),
  loser_hand varchar(2),          loser_ht smallint,                loser_ioc char(3),
  loser_age numeric(4,2),         loser_rank smallint,              loser_rank_points smallint,
  score varchar(50),              best_of smallint,                 round varchar(4),
  minutes smallint,               w_ace smallint,                   w_df smallint,
  w_svpt smallint,                w_1stIn smallint,                 w_1stWon smallint,
  w_2ndWon smallint,              w_SvGms smallint,                 w_bpSaved smallint,
  w_bpFaced smallint,             l_ace smallint,                   l_df smallint,   
  l_svpt smallint,                l_1stIn smallint,                 l_1stWon smallint,
  l_2ndWon smallint,              l_SvGms smallint,                 l_bpSaved smallint,
  l_bpFaced smallint,             w_is_tallest boolean
)

WITH (
  OIDS=FALSE
);

ALTER TABLE matches_raw OWNER TO tennispredictor;
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
  
  # Insert raw data
  dbWriteTable(
    con, "matches_raw", 
    value = dataset, 
    append = TRUE, 
    row.names = FALSE
  )
}
rm(i, filenames, dataset)

# Fetch all the matches
matches <- dbGetQuery(con, "SELECT * from matches_raw")

timing_results$extraction_done <- get_timing(Sys.time(), init_time)

# TRANSFORMATION

# Extract the year of the game from the 'tourney_date' field
matches$tourney_date  <- as.Date(as.character(matches$tourney_date),format="%Y-%m-%d")
matches$tourney_year  <- as.numeric(format(matches$tourney_date,'%Y'))
matches$tourney_month <- as.numeric(format(matches$tourney_date,'%m'))

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

# Delete clean matches table if it already exists
if ( dbExistsTable(con, "matches_clean") ){
  dbRemoveTable(con, "matches_clean")
}

sql_command <- "CREATE TABLE matches_clean
(
surface varchar(10),                tourney_year smallint,          tourney_level varchar(2),
match_num smallint,                 first_player_seed smallint,     first_player_entry varchar(2),      
first_player_hand varchar(2),       first_player_ht smallint,       first_player_age numeric(4,2),      
first_player_rank_points smallint,  second_player_seed smallint,    second_player_entry varchar(2),
second_player_hand varchar(2),      second_player_ht smallint,      second_player_age numeric(4,2),       
second_player_rank_points smallint, best_of smallint,               round varchar(4),                      
draw_size smallint,                 w_is_tallest boolean
)

WITH (
OIDS=FALSE
);

ALTER TABLE matches_clean OWNER TO tennispredictor;
"

# Sends the command and creates the table
dbGetQuery(con, sql_command)
rm(sql_command)

# Insert the cleaned data
dbWriteTable(
  con, "matches_clean", 
  value = matches, 
  append = TRUE, 
  row.names = FALSE
)
rm(matches)

# Close the connection
dbDisconnect(con)
dbUnloadDriver(drv)
