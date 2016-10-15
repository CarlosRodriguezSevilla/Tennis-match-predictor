Under development!

# Tennis Match Predictor
Let's try to predict whether if the winner of a given tennis match is the tallest of the two players.

## Variables
**surface**: Factor w/ 5 levels "Carpet","Clay",..: 2 2 2 2 2 2 2 2 2 2 ...  
**draw_size**: Factor w/ 11 levels "4","8","9","16",..: 6 6 6 6 6 6 6 6 6 6 ...  
**tourney_level**: Factor w/ 6 levels "A","D","F","G",..: 1 1 1 1 1 1 1 1 1 1 ...  
**match_num** : int  1 2 3 4 5 6 7 8 9 10 ...  
**first_player_seed**: Factor w/ 35 levels "1","2","3","4",..: NA NA NA NA NA NA NA 5 NA NA ...  
**first_player_entry**: Factor w/ 5 levels "","LL","Q","WC",..: 1 4 1 1 1 1 1 1 1 1 ...  
**first_player_hand**: Factor w/ 4 levels "","L","R","U": 3 3 3 2 3 2 3 3 3 3 ...  
**first_player_ht**: int  185 173 185 183 175 190 178 178 180 188 ...  
**first_player_age**: num  27.2 23.8 20.9 30 29.4 ...  
**first_player_rank_points**: int  351 280 380 371 357 381 322 516 404 315 ...  
**second_player_seed**: Factor w/ 35 levels "1","2","3","4",..: 1 NA NA 8 4 NA NA NA 6 NA ...  
**second_player_entry**: Factor w/ 6 levels "","LL","Q","WC",..: 1 3 1 1 1 1 1 1 1 1 ...  
**second_player_hand**: Factor w/ 4 levels "L","R","U","": 2 2 2 2 2 2 2 2 2 2 ...  
**second_player_ht**: int  180 183 183 196 185 185 190 180 183 193 ...  
**second_player_age**: num  24 19.8 27 23.3 30.1 ...  
**second_player_rank_points**: int  762 76 293 408 543 429 356 430 464 342 ...  
**best_of**: Factor w/ 2 levels "3","5": 1 1 1 1 1 1 1 1 1 1 ...  
**round**: Factor w/ 9 levels "BR","F","QF",..: 6 6 6 6 6 6 6 6 6 6 ...  
**w_is_tallest**: Factor w/ 2 levels "FALSE","TRUE": NA NA NA NA NA NA 2 2 NA NA ...

## Learning Models
**Support vector machine**  https://en.wikipedia.org/wiki/Support_vector_machine  
**AdaBoost** https://en.wikipedia.org/wiki/AdaBoost  
**Random Forest** https://en.wikipedia.org/wiki/Random_forest  

## Results 
![alt tag](https://raw.githubusercontent.com/CarlosRodriguezSevilla/Tennis-match-predictor/master/out/R/SVM.png)

## Next steps
- Scale data
- Reshape factor columns with too many levels to fit the models
- Add more columns (relative effectiveness as server and returner, days since previous match of each player, maybe bio variables like height, etc)
- Balance ratio of positives and negatives in response variable for the training data set.

## Future steps
- EDA, graphs, etc.
- Use a decision tree learning algorithm to obtain a human interpretable hypotheses.
- Principal Component Analysis: convert a set of observations of possibly correlated variables into a set of values of linearly uncorrelated variables called principal components.
- Lasso (least absolute shrinkage and selection operator).
- Calculate the most significant features that are likely to have a causal effect on the outcome of the match.

## Datasets
- Jeff Sackmann. [Tennis Rankings, Results, and Stats](https://github.com/JeffSackmann)

## Bibliography
- Nordhausen, K. (2014), An Introduction to Statistical Learning—with Applications in R by Gareth James, Daniela Witten, Trevor Hastie & Robert Tibshirani. International Statistical Review, 82: 156–157. doi: 10.1111/insr.12051_19

