---
layout: post
title:  "Statistics for Monitoring: Anomaly Detection (Part 1)"
tags: monitoring statistics anomaly
---

_Introduces control charts based methods for production anomaly detection._

Let's start with anomaly example which we've already seen in [Data Properties]({{ site.url }}/blog/statistics-for-monitoring-data-properties/):

![bimodal spike]({{ site.url }}/img/aspm/bimodal-spike.png)

It's a number of closed tcp sockets per second. One system crashed and a lot of clients got disconnected which resulted in large spike on the graph.

The graph has an interesting feature on zoomed in version:

![bimodal spike zoomed]({{ site.url }}/img/aspm/bimodal-spike-zoom.png)

Counter was read faster than it was updated which lead to value 0 between every 2 normal values.

![bimodal spike histogram]({{ site.url }}/img/aspm/bimodal-spike-histogram.png)

Histogram of the data shows large amount of zeroes (bar on the left), bell shaped distribution of 'normal' values (left middle), and anomalously large values from the spike (right side).

The simplest way to find that spike is to calculate [moving average](http://en.wikipedia.org/wiki/Moving_average), moving [standard deviation](http://en.wikipedia.org/wiki/Standard_deviation), and apply [three-sigma rule](http://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule). It's also known as [Shewhart control chart](http://en.wikipedia.org/wiki/Control_chart)

![moving average with spike]({{ site.url }}/img/aspm/ma-spike.png)

Black dots are data points, red is moving average, blue is three-sigma range around moving average. Values that fall off the range are considered anomalous.

There are several problems visible on the graph. It's not possible to calculate ranges until there is enough data to fill calculation window. Bottom blue line is below 0 which doesn't make sense because socket close frequency can't go below 0. It's caused by non-Gaussian distribution of data. Moving average and three-sigma range doesn't return to normal values until spike leaves the window.

[Exponentially-weighted moving average](http://en.wikipedia.org/wiki/EWMA_chart) is based on the similar principle but it produces ranges from the beginning and recovers from anomalies faster:

![exponentially-weighted moving average]({{ site.url }}/img/aspm/ewma-spike.png)

These methods are good at finding outliers (spikes and drops) in data with distribution close to [Gaussian](http://en.wikipedia.org/wiki/Gaussian_distribution) or [Poisson](http://en.wikipedia.org/wiki/Poisson_distribution) and flat trend (no growth or decline over time and no seasonal changes).
