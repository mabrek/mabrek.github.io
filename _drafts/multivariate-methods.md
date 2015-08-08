---
layout: post
title:  "Exploring Performance Metrics with Multivariate Statistics"
---

Most methods that were presented here so far are dealing with a single time series (performance metric) at a time. Now I'd like to make a quick overview of methods which allow to glance over a whole collection of time series at once.

The data used as an example is a result of a load test of an application which consists of several components: http server, messaging server, database. The load applied to the http server looks like this (number of clients connected and sending requests):

TODO: jmeter threads graph

The idea behind the table hill shape of the load is that on the upwards slope we can see when the system breaks (how it scales), flat top shows how stable (if it didn't break on upwards slope) it is, and the downwards slope shows how it recovers and releases resources back.

The service didn't do very well this time, here is a plot of request rate vs. error rate.

TODO image


common table hill shape
pca and svd
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
