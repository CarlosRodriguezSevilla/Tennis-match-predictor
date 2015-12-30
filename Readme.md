Let's start by reading how the pros do it.

- How Your Tennis Stats Get Made
http://fivethirtyeight.com/datalab/how-your-tennis-stats-get-made/

- Djokovic And Federer Are Vying To Be The Greatest Of All Time
http://fivethirtyeight.com/features/djokovic-and-federer-are-vying-to-be-the-greatest-of-all-time/

- A Statistical Appreciation Of Li Na
http://fivethirtyeight.com/datalab/a-statistical-appreciation-of-li-na/

- Can Roger Federer Finally Win A Davis Cup?
http://fivethirtyeight.com/datalab/can-roger-federer-finally-win-a-davis-cup/

- Late 20s Are The New Early 20s For Tennis Breakthroughs
http://fivethirtyeight.com/datalab/late-20s-is-the-new-early-20s-for-tennis-breakthroughs/


Cool datasets

- Jeff Sackmann
https://github.com/JeffSackmann
[Tennis Rankings, Results, and Stats]

- tennisabstract
http://www.tennisabstract.com/
[Match by match stats]

- Tennis-Data
http://www.tennis-data.co.uk/data.php
[Results and fixed odds betting data]

First steps
- Remove insignificant columns from the predictors dataframe (names, ids, etc)
- Add more columns (relative effectiveness as server and returner, days since previous match of each player, etc)
- Redirect the resulting outputs (graphics, tables, ...) to some specific folder

Next steps
- EDA, graphs, etc.
- Use a decision tree learning algorithm to obtain a human interpretable hypothesise.
- Principal Component Analysis: convert a set of observations of possibly correlated variables into a set of values of linearly 
  uncorrelated variables called principal components.
- Calculate the most significant features, that are likely to have a causal effect on the outcome of the match.

Future problems
- How to code result if there is no home and away. Duplicate rows?
http://stats.stackexchange.com/questions/11800/how-should-we-convert-sports-results-data-to-perform-a-valid-logistical-regressi
[What if I code it as '1==the highest rated player wins' and '0==otherwise'?]
