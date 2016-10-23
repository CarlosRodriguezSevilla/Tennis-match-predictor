#!/bin/bash

# On exit silently kill all running subprocesses 
trap "exec 3>&2; exec 2> /dev/null; pkill -P $$; exec 2>&3" EXIT

# Path
path="$(dirname "$PWD")"
args="--args path='/home/kako/Dev/Data_challenges/Tennis/'"

echo "Running Tennis Match Predictor, Load Training and Testing"

# R CMD BATCH ../src/LoadTrainingAndTesting.R ../out/LoadTrainingAndTesting.Rout
( 
  if R CMD BATCH "${args}" ../src/LoadTrainingAndTesting.R ../out/LoadTrainingAndTesting.Rout ; then 
    echo -e "\tLoad, Training and Testing done"
  else
    echo -e "\tLoad, Training and Testing FAILED"
  fi 
)

echo "DONE"