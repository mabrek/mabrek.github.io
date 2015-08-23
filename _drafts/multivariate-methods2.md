---
layout: post
title:  "Exploring Performance Monitoring Data with Multivariate Tools: MDS and t-SNE"
---

### Multidimensional Scaling

    metric mds: cmdscale() is fast and produces usable results, doesn't care about duplicates
    non-metric mds: MASS:isoMDS gives identical results to cmdscale, complains about duplicates

The nice thing about non-metric MDS is that it can handle any type of time series (dis)similarity measures (https://en.wikipedia.org/wiki/Time_series#Measures) not restricted to euclidean distance.

### t-SNE

tsne() is slow O(n^2) but results are usable too, it finds more groups in data
