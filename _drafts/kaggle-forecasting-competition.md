---
layout: post
title:  "My Solution (top 10%) for Kaggle Rossman Store Sales Forecasting Competition"
---

_It's the first time I tried participating in machine learning competition and my result turned out to be quite good: [66th from 3303](https://www.kaggle.com/mabrek/results). I used R and an average of two models: glmnet and xgboost with a lot of feature engineering_

The goal of the [competition](https://www.kaggle.com/c/rossmann-store-sales) was to predict 6 weeks of daily sales in 1115 stores located in different parts of Germany based on 2.5 years of historical daily sales.

The first thing I tried after importing data was to convert it into multivariate regular time series and run [SVD]({{ site.url }}/blog/multivariate-svd-pca/). It showed that the majority of stores don't have upwards or downwards trends, seasonal variation is present but mostly as Christmas effect, Sunday is non-working day, and there is a strange cycle with 2 weeks length, which turned out to be an effect of running promo action every other week. There were group of stores that don't close on Sunday in summer, some stores had strong yearly pattern, some stores had sales continuously growing (or decreasing) in time, group of stores had half year data missing. I selected several stores as examples from different groups.

In the beginning my idea was to check how good can single explanatory model be. There were two simple benchmark models ([median](https://www.kaggle.com/shearerp/rossmann-store-sales/interactive-sales-visualization), [geometric mean](https://www.kaggle.com/shearerp/rossmann-store-sales/store-dayofweek-promo-0-13952)) on forum which I used as a starting point.

To validate model quality I implemented time-based cross-validation as described in [Forecasting: principles and practice](https://www.otexts.org/fpp/2/5)

Visualization helped a lot in identifying features and sources of errors.

TODO view_sales image

I tried [forecast::tbats](http://www.inside-r.org/packages/cran/forecast/docs/tbats) (separate models per each store) but results were quite bad. Influence of non-seasonal factors was big but [tbats can't](http://robjhyndman.com/hyndsight/tbats-with-regressors/) [use regressors] (http://robjhyndman.com/hyndsight/dailydata/). [ARIMA](http://www.inside-r.org/packages/cran/forecast/docs/auto.arima) model can use regressors but for long-term forecasts it decays to [constant or linear trend](https://www.otexts.org/fpp/8/5). So I continued to evaluate different kinds of linear models. As more and more feature were added simple linear model started to get worse so I switched to (glmnet)[http://www.inside-r.org/packages/cran/glmnet/docs/glmnet] which is able to use subset of features.

