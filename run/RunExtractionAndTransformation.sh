#!/bin/bash

# On exit silently kill all running subprocesses 
trap "exec 3>&2; exec 2> /dev/null; pkill -P $$; exec 2>&3" EXIT

if ([[ "$#" -ge 2 ]] && [[ "$#" -le 3 ]] && [[ "$1" == "-source" ]]); then
  data_sources=(R PostgreSQL MongoDB)
  data_source=$2
  if ! [[ ${data_sources[*]} =~ (^|[[:space:]])$data_source($|[[:space:]]) ]]; then
    echo "Argument error"; exit 0
  fi
fi

# Path
path="$(dirname "$PWD")"
args="--args path='/home/kako/Dev/Data_challenges/Tennis/' data_source='$2'"

echo "Running Tennis Match Predictor"

echo -e "[$(date +%H:%M)]" "\t* Extraction and Transformation"

if [[ "$data_source" == "R" ]]  || [[ "$data_source" == "" ]]; then
  # R CMD BATCH ../src/ExtractionAndTransformation-R.R ../out/R/ExtractionAndTransformation-R.Rout
  ( 
    if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-R.R ../out/R/ExtractionAndTransformation-R.Rout ; then
      echo -e "[$(date +%H:%M)]" "\t\t- R done"
    else
      echo -e "[$(date +%H:%M)]" "\t\t- R FAILED"
    fi 
  ) & 
fi

if [[ "$data_source" == "PostgreSQL" ]]  || [[ "$data_source" == "" ]]; then
  # R CMD BATCH ../src/ExtractionAndTransformation-PostgreSQL.R ../out/R/ExtractionAndTransformation-PostgreSQL.Rout
  ( 
    if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-PostgreSQL.R ../out/PostgreSQL/ExtractionAndTransformation-PostgreSQL.Rout ; then 
      echo -e "[$(date +%H:%M)]" "\t\t- PostgreSQL done"
    else
      echo -e "[$(date +%H:%M)]" "\t\t- PostgreSQL FAILED"
    fi 
  ) & 
fi  

if [[ "$data_source" == "MongoDB" ]]  || [[ "$data_source" == "" ]]; then
  # R CMD BATCH ../src/ExtractionAndTransformation-MongoDB.R ../out/R/ExtractionAndTransformation-MongoDB.Rout
  ( 
    if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-MongoDB.R ../out/MongoDB/ExtractionAndTransformation-MongoDB.Rout ; then 
      echo -e "[$(date +%H:%M)]" "\t\t- MongoDB done"
    else
      echo -e "[$(date +%H:%M)]" "\t\t- MongoDB FAILED"
    fi 
  ) &
fi

wait


echo "DONE"
