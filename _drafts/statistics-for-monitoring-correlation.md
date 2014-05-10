---
layout: post
title:  "Statistics for Monitoring: Correlation and Clustering"
tags: monitoring statistics
---

_Finding metrics with similar behaviour and analyzing internal system dependencies._

There are a lot of situations when you see a sudden change in one metric (e.g. increased latency or error rate) and you need to find what caused it. It could be solved by applying prior knowledge about dependencies in the system but there are still a lot of unknowns especially in case of poorly documented legacy applications. It would be great to have a tool that given a metric will produce list of other metrics it depends on based on time series data.

There are some papers (["Causality and graphical models in time series analysis"](http://galton.uchicago.edu/~eichler/hsss.pdf)) suggesting that it's possible to infer dependencies from time series data but I haven't done any experiments with it yet (R package [`vars`](http://cran.r-project.org/web/packages/vars/vignettes/vars.pdf) might be useful).

For practical purposes it's often enough to find metrics that have similarly shaped graphs. Changes in computer systems are quite fast (seconds or milliseconds) to propagate between components making it impossible to find out what changed first with typical polling intervals (10s, 60s) so it looks like dependent metrics are moving at the same time.

There are several methods for finding similar time series:

 * correlation ([Pearson](http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient), [Spearman](http://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient))
 * [Euclidean distance](http://en.wikipedia.org/wiki/Euclidean_distance)
 * [dynamic time warping (DTW)](http://en.wikipedia.org/wiki/Dynamic_time_warping)
 * [discrete Fourier transform (DFT)](http://en.wikipedia.org/wiki/Discrete_Fourier_transform)
 * [discrete wavelet transform (DWT)](http://en.wikipedia.org/wiki/Discrete_wavelet_transform)

Actually there are much more of them targeted at different use cases and the list above contains only most popular. The good news is that performance monitoring data is quite small in comparison with ECG and EEG data. It gives a hope that more effective methods from medical field will be used for performance monitoring too.

First two are quite simple to understand and fast in runtime. [Pearson correlation coefficient](http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient) has a simple [relation](http://www.analytictech.com/mb876/handouts/distance_and_correlation.htm) to [Euclidean distance](http://en.wikipedia.org/wiki/Euclidean_distance) for normalized data. Absolute value of correlation coefficient allows to find mirrored graphs (like disk used vs. disk free space).

[Dynamic time warping](http://en.wikipedia.org/wiki/Dynamic_time_warping) has a nice property to find slightly misaligned in time graphs but its R implementation was too slow to be useful when I tried it.

My experiments with DFT failed because computer-generated metrics rarely have sparse representation in frequency domain. Their spectra are wide and contain a lot of frequencies. There is not so many periodical things going on in online request processing (maybe cron jobs). There are periodical daily/weekly/yearly changes but the typical need to compare graphs is limited by short ranges (hours or even minutes).

DWT looks promising because Haar wavelet's shape is very similar to typical steps usually found in performance metrics but I haven't tried it yet.

Sometimes production system misbehaves but you have no idea where to start from because known dependencies and similar graphs for usual suspects (metrics like error rate) lead nowhere. Going through all metrics and watching all graphs works for small systems (up to several hunreds metrics) but doesn't work when there are thousands metrics. While trying to do that I noticed that many graphs are almost the same making it unnecesary to get through all of them.

[Clustering](http://en.wikipedia.org/wiki/Cluster_analysis) allows to group similar metrics and reduce amount of data to analyze. It makes possible to take only single representative from each group of similar metrics. I used [Partitioning Around Medoids](http://en.wikipedia.org/wiki/Partitioning_Around_Medoids) clustering algorithm and absolute value of correlation coefficient as a distance function.

![cluster centers (medoids)]({{ site.url }}/img/aspm/medoids.png)

These 4 graphs were taken from a set of cluster representatives. 

Contents of a cluster represented by the top right one:

![sample cluster contents]({{ site.url }}/img/aspm/cluster19.png)

There are 2 quite similar graphs on top (actually there were more omitted from illustration) but it contains some noisy graphs (bottom) which doesn't look really similar to others. Clustering algorithm used requires exact number of clusters to be set upfront which leads to the result above because it has to assign graphs which are not similar to anything to some clusters.

![sample cluster contents]({{ site.url }}/img/aspm/cluster17.png)

This is another cluster with different contents. Top right graph looks like periodical [exponential charge](http://hades.mech.northwestern.edu/index.php/RC_and_RL_Exponential_Responses) while others are more like  [sawtooth wave](http://en.wikipedia.org/wiki/Sawtooth_wave) or [triangle wave](http://en.wikipedia.org/wiki/Triangle_wave). Relation between those graphs is clealy non-linear.

[Spearman's rank correlation coefficient](http://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) was used to create these clusters because it allows to catch non-linear relationships between metrics. It's more computationally difficult than Pearson but produces better results because there are a lot of non-linear relationships in computer-generated data.

    non-euclidean (ultrametric) space
    many small clusters
    local clustering around events
    false positives
        cron jobs (log rotation)
        human actions (restarts, reconfigurations)
        cache expirations
        …
