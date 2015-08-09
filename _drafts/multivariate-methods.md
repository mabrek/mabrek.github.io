---
layout: post
title:  "Exploring Performance Metrics with Multivariate Statistics"
---

Most methods that were presented here so far are dealing with a single time series (performance metric) at a time. Now I'd like to make a quick overview of methods which allow to glance over a whole collection of time series at once.

Data used here is a result of a load test of an application which consists of several components: http server, messaging server, database. The load applied to the http server looks like this (number of identical clients connected and sending requests):

TODO: jmeter threads graph

The idea behind the table hill shape of the load is that the upwards slope shows when the system breaks (how it scales), flat top shows how stable (if it didn't break on upwards slope) it is, and the downwards slope shows how it recovers.

The service didn't do very well this time. Here is a plot of request rate vs. error rate and latency.

TODO total http request rate vs. error rate and latency on jmeter side

At least it recovered without any negative consequences and continued to serve requests at a lower rate.


### SVD and PCA

Here's what the result of [SVD (Singular Value Decomposition)](https://en.wikipedia.org/wiki/Singular_value_decomposition) looks like (left-singular vectors sorted by decreasing singular values):

TODO first 10 series from U

In time series context SVD decomposes original set of series into set of uncorrelated base series (left-singular vectors), set of singular values, and a matrix of weights (loadings). These matrices could be used to reconstruct the original set of series but the nice feature is that you can take only several base series corresponding to the top singular values to get quite good (in terms of squared error) result.

When the data is centered (mean subtracted) and scaled (divided by standard deviation) before applying SVD then top (by singular values) base series represents the most common shapes in the data with some caveats. Sometimes it can mix several common shapes into one base series. Outliers distort extracted base series due to the scaling used and the least-squares nature of the decomposition (which amplifies outliers).

In this case the first extracted is the table hill shape of the load applied because most metrics follow that pattern. The second is TODO ... There are some spikes and drops visible on several base series which corresponds to errors and latency spikes during the test.

Closely related [PCA (Principal Component Analysis)](https://en.wikipedia.org/wiki/Principal_component_analysis) produces set of principal components (which are base series from SVD scaled by singular values) and the same loadings from SVD. Here the first 2 original series selected by maximum absolute loading per each component.

TODO top original series by their loadings

It selects original series which have largest contribution from top components (base series). Usually it just selects series similar to the component by shape.

Original data is required to run SVD and you'll get both base series and loadings. For PCA you can use correlation matrix of original data and you'll get only loadings in that case.

These methods are quite fast and produce meaningful results: extract most common shapes and group original series by these shapes.

They are sensitive to outliers and the usual way of scaling data (by standard deviation) doesn't make a lot of sence for long tailed distributions which are quite common in performance monitoring data. It might be a good thing for exploratory data analysis because if you see some spikes or step-like changes in first base series it definitely means some abrupt changes at that time in system being monitored.

I've tried to center data by subtracting median and scale by MAD (TODO median absolute deviation) but discovered that zero MAD is quite common when the data is mostly constant with a few spikes.

### Multidimensional Scaling

    metric mds: cmdscale() is fast and produces usable results, doesn't care about duplicates
    non-metric mds: MASS:isoMDS gives identical results to cmdscale, complains about duplicates
tsne() is slow O(n^2) but results are usable too, it finds more groups in data

### ICA

    extracts spikes
    different algorithms produce similar results
    non-spike signals are hard to interpret
    sometimes it splits one non-spike signal into two
    no ordering (importance?)
