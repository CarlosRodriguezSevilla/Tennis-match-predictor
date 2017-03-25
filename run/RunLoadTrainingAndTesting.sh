#!/bin/bash

# On exit silently kill all running subprocesses 
trap "exec 3>&2; exec 2> /dev/null; pkill -P $$; exec 2>&3" EXIT

if [[ "$#" -eq 2 ]] && [[ "$1" == "-source" ]]; then
  data_sources=(R PostgreSQL MongoDB)
  data_source=$2
  if ! [[ ${data_sources[*]} =~ (^|[[:space:]])$data_source($|[[:space:]]) ]]; then
    echo "Argument error"; exit 0
  fi
else
  echo "Argument error"; exit 0
fi

# Path
path="$(dirname "$PWD")"
args="--args path='/home/kako/Dev/Data_challenges/Tennis/' data_source='$data_source'"

echo "Running Tennis Match Predictor, Load Training and Testing"

# R CMD BATCH ../src/LoadTrainingAndTesting.R ../out/LoadTrainingAndTesting.Rout
( 
  if R CMD BATCH "${args}" ../src/LoadTrainingAndTesting.R ../out/LoadTrainingAndTesting/LoadTrainingAndTesting.Rout ; then 
    echo -e "[$(date +%H:%M)]" "\t\t- Load, Training and Testing done"
  else
    echo -e "[$(date +%H:%M)]" "\t\t- Load, Training and Testing FAILED"
  fi 
)

echo "DONE"
