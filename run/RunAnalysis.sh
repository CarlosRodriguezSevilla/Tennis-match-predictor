#!/bin/bash

# On exit silently kill all running subprocesses 
trap "exec 3>&2; exec 2> /dev/null; pkill -P $$; exec 2>&3" EXIT

# Path
path="$(dirname "$PWD")"
args="--args path='/home/kako/Dev/Data_challenges/Tennis/'"

echo "Running Tennis Match Predictor"

echo -e "[$(date +%H:%M)]" "\t* Visual analysis reports"
# R CMD BATCH ../src/Analysis.R ../out/Analysis/Analysis.Rout
( 
if R CMD BATCH "${args}" ../src/Analysis.R ../out/Analysis/Analysis.Rout ; then 
echo -e "[$(date +%H:%M)]" "\t\t- Visual analysis reports done"
else
  echo -e "[$(date +%H:%M)]" "\t\t- Visual analysis reports FAILED"
fi 
)


echo "DONE"
