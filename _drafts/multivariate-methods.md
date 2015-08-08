---
layout: post
title:  "Exploring Performance Metrics with Multivariate Statistics"
---

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
