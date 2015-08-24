---
layout: post
title:  "Exploring Performance Monitoring Data with Multivariate Tools: MDS and t-SNE"
---

This time I'm going to introduce tools that allow to explore data visually. They represent each time series as a point in 2-dimensional space. When original time series are similar the corresponding points will be close to each other.

The same data was used here as in previous post about [SVD and PCA]({{site.url}}/blog/multivariate-svd-pca/)


[Multidimensional Scaling (MDS)](https://en.wikipedia.org/wiki/Multidimensional_scaling) produces this kind of image:

![mds embeddings]({{ site.url }}/img/multivariate/mds-embeddings.png)

![mds examples]({{ site.url }}/img/multivariate/mds-examples.png)

It has put hill shaped series (1 - 5) together in the left corner of dot cloud which seems to be the most dense one. Different kinds of spikes landed on the upper corner (7 - 10). Series with strong increasing or decreasing trend landed on the right corner (13, 14) and step-like changes on the bottom (15, 16).

This image was generated using classical (metric) multidimensional scaling using [cmdscale](http://www.inside-r.org/r-doc/stats/cmdscale) function from R and distance matrix calculated as `1 - abs(cor(a, b))` for each pair of time series. [Metric](https://en.wikipedia.org/wiki/Metric_%28mathematics%29) here corresponds to the set of properties of distance function required by the algorithm.

Not all [time series (dis)similarity measures](https://en.wikipedia.org/wiki/Time_series#Measures) have these properties. There are non-metric variants of multitimensional scaling like [isoMDS](http://www.inside-r.org/r-doc/MASS/isoMDS). It is much slower than metric MDS and in my case its results were visually indistinguishable from the results produced by cmdscale on the same matrix.

### t-SNE

[t-SNE](https://en.wikipedia.org/wiki/T-distributed_stochastic_neighbor_embedding)

![tsne embeddings]({{ site.url }}/img/multivariate/tsne-embeddings.png)

![tsne examples]({{ site.url }}/img/multivariate/tsne-examples.png)

tsne() is slow O(n^2) but results are usable too, it finds more groups in data
