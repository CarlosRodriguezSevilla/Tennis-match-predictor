
# http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html

rm(list=ls(all = TRUE)) # Clear workspace

library(glmnet)

source("Config.R") # Load config file with root path, etc

load(paste0(path, "/Matches-clean.RData"))

y <- as.numeric(as.logical(matches$w_is_better_ranked))
x <- matches[, !names(matches) %in% c("w_is_better_ranked")] 


x <- sparse.model.matrix( w_is_better_ranked ~ ., matches)[,-1]

# Cross-validation fit
fit <- cv.glmnet(as.matrix(x),y)


for(variable in names(x))
{
  lapply(x[["surface"]], is.na)
}