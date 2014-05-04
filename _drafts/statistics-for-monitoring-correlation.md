---
layout: post
title:  "Statistics for Monitoring: Correlation"
tags: monitoring statistics
---

_Finding metrics with similar behaviour and analyzing internal system dependencies._

There are a lot of situations when you see a sudden change in one production metric (say, increased latency or error rate) and you need to find what caused it. Many cases could be solved by applying prior knowledge about dependencies in the system but there are still a lot of unknowns. It would be great to have a tool that given a metric will produce list of other metrics that influence it based on data.

There are some papers (["Causality and graphical models in time series analysis"](http://galton.uchicago.edu/~eichler/hsss.pdf)) suggesting that it's possible to infer dependencies from time series data but I haven't found ready to use tool for that.

For practical purposes it's often enough to find metrics that have similarly shaped graphs. Changes in computer systems are quite fast (seconds or milliseconds) to propagate between components making it impossible to find out what changed first with typical polling interval (10s, 60s). It looks like several metrics moving at the same time in that case.

There are several methods for finding similar time series:

 * correlation ([Pearson](http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient), [Spearman](http://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient))
 * [Euclidean distance](http://en.wikipedia.org/wiki/Euclidean_distance)
 * [dynamic time warping (DTW)](http://en.wikipedia.org/wiki/Dynamic_time_warping)
 * [discrete Fourier transform (DFT)](http://en.wikipedia.org/wiki/Discrete_Fourier_transform)
 * [discrete wavelet transform (DWT)](http://en.wikipedia.org/wiki/Discrete_wavelet_transform)

First two are quite simple to understand and fast. [Pearson correlation coefficient](http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient) has a simple [relation](http://www.analytictech.com/mb876/handouts/distance_and_correlation.htm) to [Euclidean distance](http://en.wikipedia.org/wiki/Euclidean_distance) for normalized data. Absolute value of correlation coefficient allows to find mirrored graphs (like disk used vs. disk free space).

[Dynamic time warping](http://en.wikipedia.org/wiki/Dynamic_time_warping) has a nice property to find slightly misaligned in time graphs but its implementation in R was quite slow when I was experimenting with it.

