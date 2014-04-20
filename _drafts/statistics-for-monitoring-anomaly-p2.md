---
layout: post
title:  "Statistics for Monitoring: Anomaly Detection (Part 2)"
tags: monitoring statistics anomaly
---

_Anomaly detection methods based on autocorrelation and non-parametric 2 sample tests._

Control-charts based methods mentioned in [Part 1]({{ site.url }}/blog/statistics-for-monitoring-anomaly-p1/) don't work for data with relatively stable mean (changes fall withing [three-sigma](http://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule) range):

![stable mean]({{ site.url }}/img/aspm/stable-mean.png)

Both graphs clearly show different behaviour at different time intervals but changes in mean value (painted red) are quite small to be noticed by control-charts.

Another bad example is something like request latency or size:

![request size daily]({{ site.url }}/img/aspm/ks-subject.png)

This weird graph shows maximum request size (black dots) measured over 10 seconds intervals during a day. Red line is an average over 3 minutes intervals. There are some spikes in average value but there is also a strange dot cloud in top-right part which stands for heavy requests appearing in that time of day.

Not every anomaly is a failure.