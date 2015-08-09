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

Here's what the result of [SVD (Singular Value Decomposition)](https://en.wikipedia.org/wiki/Singular_value_decomposition) looks like (left-singular vectors):

TODO first 10 series from U

It has extracted the most common table hill shape to the first place.

In time series context SVD decomposes original set of series into set of uncorrelated (TODO check) base series (left-singular vectors), set of singular values, and a matrix of weights (loadings). 

If all original series were centered (mean subtracted) and had the same unit (say CPU usage) then

Left singular vectors is a sorted by energy set of series that can be used to reconstruct the original set with limited number of them. The more base series you take the closer (in sense of squared error) you get to the original.

Closely related [PCA (Principal Component Analysis)](https://en.wikipedia.org/wiki/Principal_component_analysis) produces set of principal components (which are base series from SVD multiplied by singular values) and the same loadings from SVD. Here the first 2 original series selected by maximum absolute loading per each component.

TODO top original series by their loadings



    fast 
    selects the most common shapes but distorts them due to outliers and sometimes mixes two common shapes together
    component ordering is understandable (first component is a load applied)
    it's unclear how to scale data
        center/unit variance sensible to outliers
        median/mad sensible to zero mad (data which is mostly constant with a few spikes)
    correlation matrix (but it's slower) is better for PCA of data with different dimensions
multidimensional scaling
    metric mds: cmdscale() is fast and produces usable results, doesn't care about duplicates
    non-metric mds: MASS:isoMDS gives identical results to cmdscale, complains about duplicates
tsne() is slow O(n^2) but results are usable too, it finds more groups in data
ICA
    extracts spikes
    different algorithms produce similar results
    non-spike signals are hard to interpret
    sometimes it splits one non-spike signal into two
    no ordering (importance?)
