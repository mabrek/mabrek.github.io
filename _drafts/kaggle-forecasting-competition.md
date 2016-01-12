---
layout: post
title:  "My Solution (top 10%) for Kaggle Rossman Store Sales Forecasting Competition"
---

It's the first time I tried participating in machine learning competition and my result turned out to be quite good: [66th from 3303](https://www.kaggle.com/mabrek/results).

The goal of the [competition](https://www.kaggle.com/c/rossmann-store-sales) was to predict 6 weeks of daily sales in 1115 stores located in different parts of Germany based on 2.5 years of historical daily sales.

The first thing I tried after initial data import was to convert it into multivariate regular time series and run [SVD]({{ site.url }}/blog/multivariate-svd-pca/). It showed that the majority of stores don't have upwards or downwards trends, seasonal variation is present but mostly as Christmas effect, Sunday is non-working day, and there is a strange cycle with 2 weeks length, which turned out to be an effect of running promo action every other week. There were group of stores that don't close on Sunday in summer, some stores had strong yearly pattern, some stores had sales continuously growing (or decreasing) in time.

