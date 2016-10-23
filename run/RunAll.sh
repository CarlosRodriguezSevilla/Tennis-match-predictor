#!/bin/bash

# On exit silently kill all running subprocesses 
trap "exec 3>&2; exec 2> /dev/null; pkill -P $$; exec 2>&3" EXIT

# Path
path="$(dirname "$PWD")"
args="--args path='/home/kako/Dev/Data_challenges/Tennis/'"

echo "Running Tennis Match Predictor"


# R CMD BATCH ../src/ExtractionAndTransformation-R.R ../out/R/ExtractionAndTransformation-R.Rout
( 
  if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-R.R ../out/R/ExtractionAndTransformation-R.Rout ; then
    echo "R done"
  else
    echo "R FAILED"
  fi 
) & 

# R CMD BATCH ../src/ExtractionAndTransformation-PostgreSQL.R ../out/R/ExtractionAndTransformation-PostgreSQL.Rout
( 
  if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-PostgreSQL.R ../out/PostgreSQL/ExtractionAndTransformation-PostgreSQL.Rout ; then 
    echo "PostgreSQL done"
  else
    echo "PostgreSQL FAILED"
  fi 
) & 

# R CMD BATCH ../src/ExtractionAndTransformation-MongoDB.R ../out/R/ExtractionAndTransformation-MongoDB.Rout
( 
  if R CMD BATCH "${args}" ../src/ExtractionAndTransformation-MongoDB.R ../out/MongoDB/ExtractionAndTransformation-MongoDB.Rout ; then 
    echo "MongoDB done"
  else
    echo "MongoDB FAILED"
  fi 
) &

wait
echo "DONE"