---
layout: post
title:  "Exploring Performance Monitoring Data with Multivariate Tools: MDS and t-SNE"
---

The same data was used here as in previous post about [SVD and PCA]({{site.url}}/blog/multivariate-svd-pca/)

[MDS](https://en.wikipedia.org/wiki/Multidimensional_scaling) and [t-SNE](https://en.wikipedia.org/wiki/T-distributed_stochastic_neighbor_embedding) allow to explore data visually. They represent each time series as a point in 2-dimensional space which is easy to draw. When original time series are similar to each other the corresponding points will be close.

While SVD and PCA are extracing common shapes MDS and t-SNE ...

### Multidimensional Scaling (MDS)

![mds embeddings]({{ site.url }}/img/multivariate/mds-embeddings.png)

![mds examples]({{ site.url }}/img/multivariate/mds-examples.png)

    metric mds: cmdscale() is fast and produces usable results, doesn't care about duplicates
    non-metric mds: MASS:isoMDS gives identical results to cmdscale, complains about duplicates

The nice thing about non-metric MDS is that it can handle any type of time series (dis)similarity measures (https://en.wikipedia.org/wiki/Time_series#Measures) not restricted to euclidean distance.

### t-SNE

![tsne embeddings]({{ site.url }}/img/multivariate/tsne-embeddings.png)

![tsne examples]({{ site.url }}/img/multivariate/tsne-examples.png)

tsne() is slow O(n^2) but results are usable too, it finds more groups in data
