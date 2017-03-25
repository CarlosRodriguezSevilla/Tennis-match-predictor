#!/bin/bash

# Arguments:
#  -source [R, PostgreSQL, MongoDB]
#  -times  [n]

# On exit silently kill all running subprocesses 
trap "exec 3>&2; exec 2> /dev/null; pkill -P $$; exec 2>&3" EXIT

if ([[ "$#" -ge 2 ]] && [[ "$#" -le 4 ]] && [[ "$1" == "-source" ]]); then

  data_sources=(R PostgreSQL MongoDB)
  data_source=$2
  
  if ! [[ ${data_sources[*]} =~ (^|[[:space:]])$data_source($|[[:space:]]) ]]; then
    echo "Argument error"; exit 0
  fi
  
  if ([[ "$3" == "-times" ]] && [[ "$4" =~ ^-?[0-9]+$ ]]); then
    times=$4
  else
    times=1
  fi
  
else
  echo "Argument error"; exit 0
fi


# Path
path="$(dirname "$PWD")"
args="--args path='/home/kako/Dev/Data_challenges/Tennis/' data_source='$data_source'"

echo "Running Tennis Match Predictor"

for ((n = 1; n <= $times; n++)); do

  echo -e "\n[$(date +%H:%M)]" "\t[$n of $times]"

  echo -e "[$(date +%H:%M)]" "\t* Extraction and Transformation"
  
  if [ "$data_source" == "R" ] ; then
    # R CMD BATCH ../src/ExtractionAndTransformation-R.R ../out/R/ExtractionAndTransformation-R.Rout
    ( 
      if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-R.R ../out/R/ExtractionAndTransformation-R.Rout ; then
        echo -e "[$(date +%H:%M)]" "\t\t- R done"
      else
        echo -e "[$(date +%H:%M)]" "\t\t- R FAILED"
      fi 
    ) & 
  
  elif [ "$data_source" == "PostgreSQL" ] ; then
    # R CMD BATCH ../src/ExtractionAndTransformation-PostgreSQL.R ../out/R/ExtractionAndTransformation-PostgreSQL.Rout
    ( 
      if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-PostgreSQL.R ../out/PostgreSQL/ExtractionAndTransformation-PostgreSQL.Rout ; then 
        echo -e "[$(date +%H:%M)]" "\t\t- PostgreSQL done"
      else
        echo -e "[$(date +%H:%M)]" "\t\t- PostgreSQL FAILED"
      fi 
    ) & 
  
  elif [ "$data_source" == "MongoDB" ] ; then
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
  
  
  echo -e "[$(date +%H:%M)]" "\t* Load, Training and Testing"
  # R CMD BATCH ../src/LoadTrainingAndTesting.R ../out/LoadTrainingAndTesting.Rout
  ( 
    if R CMD BATCH "${args}" ../src/LoadTrainingAndTesting.R ../out/LoadTrainingAndTesting/LoadTrainingAndTesting.Rout ; then 
      echo -e "[$(date +%H:%M)]" "\t\t- Load, Training and Testing done"
    else
      echo -e "[$(date +%H:%M)]" "\t\t- Load, Training and Testing FAILED"
    fi 
  )

done

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
