---
layout: post
title:  "Exploring Performance Monitoring Time Series with Multivariate Statistics"
---

Most methods that were presented here so far are dealing with a single time series (performance metric) at a time. Now I'd like to make a quick overview of methods which allow to glance over a whole collection of time series at once.

Data used here is a result of a load test of an application which consists of several components: http server, messaging server, database. That application uses 5 hosts and number of system metrics + application metrics is about 3300 after filtering. Think of it as a number of graphs to get through while exploring results of the test. The load applied to the http server looks like this (number of identical clients connected and sending requests):

![connected clients]({{ site.url }}/img/multivariate/jmeter-threads.png)

The idea behind the table hill shape of the load is that the upwards slope shows when the system breaks (how it scales), flat top shows how stable it is (if it didn't break on upwards slope), and the downwards slope shows how it recovers.

The service didn't do very well this time. Here is a plot of successful and error response rates:

![request and error rates]({{ site.url }}/img/multivariate/request-error-rates.png)

And response latencies:

![latencies]({{ site.url }}/img/multivariate/latencies.png)

Error rate is not zero and 99th percentile of responce latency has spikes close to allowed by SLA maximum. At least it recovered and continued to serve requests at a lower rate.


### SVD and PCA

Here's what the result of [SVD (Singular Value Decomposition)](https://en.wikipedia.org/wiki/Singular_value_decomposition) looks like (left-singular vectors sorted by decreasing singular values):

![svd left singular]({{ site.url }}/img/multivariate/svd-u.png)

In time series context SVD decomposes original set of series into set of uncorrelated base series (left-singular vectors), set of singular values, and a matrix of weights (right-singular vectors). These matrices could be used to reconstruct the original set of series. The nice feature is that you can take only several base series corresponding to the top singular values to get quite good (in terms of squared error) result.

![singular values sorted by decreasing value]({{ site.url }}/img/multivariate/svd-d.png)

Looks like about first 6 singular values (sorted by decreasing value) contribute most and the rest is a background noise.

When the data is centered (mean subtracted) and scaled (divided by standard deviation) before applying SVD then the top (by singular values) base series represents the most common shapes in the data with some caveats. Sometimes it can change sign (flip shape vertically) or mix several common shapes into one. Outliers distort extracted base series due to the scaling used and the least-squares nature of the decomposition (which amplifies outliers).

In this case the first extracted is slightly skewed table hill shape of the load applied because most metrics follow that pattern. There are some spikes and drops visible on several base series which corresponds to errors and latency spikes during the test.

Closely related [PCA (Principal Component Analysis)](https://en.wikipedia.org/wiki/Principal_component_analysis) produces set of principal components (which are base series from SVD scaled by singular values) and the same weights (loadings) from SVD. Here the first 2 original series selected by maximum absolute loading per each principal component.

![top original by right singular vectors]({{ site.url }}/img/multivariate/svd-v.png)

It selects original series which have largest contribution from top components (base series). Usually it just selects series similar to the component by shape.

Original data is required to run SVD and you'll get both base series and loadings. For PCA you can use correlation matrix of original data and you'll get only loadings in that case.

These methods are quite fast and produce meaningful results: extract most common shapes and group original series by these shapes.

They are sensitive to outliers. The usual way of scaling data (by standard deviation) doesn't make a lot of sence for long tailed distributions which are quite common in performance monitoring data. It might be a good thing for exploratory data analysis because if you see some spikes or step-like changes in several first base series it definitely means some abrupt changes at that time in system being monitored.

I've tried to center data by subtracting median and scale by MAD (TODO median absolute deviation) but discovered that zero MAD is quite common when data is mostly constant with a few spikes.

What SVD is good for: if you have a lots of data, slow anomaly detection algorithm and interested mostly in the time when anomaly happens then running the algorithm on several first base series (principal components) might be much faster than running it on original data.

### ICA

    extracts spikes
    different algorithms produce similar results
    non-spike signals are hard to interpret
    sometimes it splits one non-spike signal into two
    no ordering (importance?)

### Multidimensional Scaling

    metric mds: cmdscale() is fast and produces usable results, doesn't care about duplicates
    non-metric mds: MASS:isoMDS gives identical results to cmdscale, complains about duplicates

The nice thing about non-metric MDS is that it can handle any type of time series (dis)similarity measures (https://en.wikipedia.org/wiki/Time_series#Measures) not restricted to euclidean distance.

### T-SNE

tsne() is slow O(n^2) but results are usable too, it finds more groups in data
