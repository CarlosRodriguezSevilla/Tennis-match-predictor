
path <- "/home/kako/Documentos/Dev/Data challenges/Tennis"
setwd(path)

onMongoDB    <- FALSE
onPostgreSQL <- FALSE

# Both of the above parameters must never be TRUE at the same time. 
# If both onMongoDB and onPostgreSQL parameters are TRUE the execution is halted.
if ( onMongoDB && onPostgreSQL == c(TRUE, TRUE) ){
  stop("Wrong configuration. Parameter setup is not correct.")
}
