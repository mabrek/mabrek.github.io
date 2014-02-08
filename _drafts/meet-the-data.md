---
layout: post
title: Meet the Data
---

![Great Wall of Graphs]({{ site.url }}/img/aspm/great-wall.png)

Here's the way typical performance metrics look like. CPU utilization, used memory, network io, disk io, etc. plotted as a time series. There will be no labels on axes because horizontal line is always time and vertical line is value of some metric. There are cases when it helps to know what kind of metric we are analyzing but in general it doesn't matter for statistical purposes. Usually you get bunch data when all you know about metrics is their name and only human can guess meaning of a particular metric.

This style of visualization (TODO link to R slide) when black dots are individual data points and red curve is an averaged over some period value will be used for graphs. It allows to quickly see both data distribution (shown by darkness of dot cloud) and its trend.

There are several interesting things on the picture above. One service crached and was restarted which led to spikes on some graphs and drops on others. Another service is leaking memory which looks like nice linear trend upwards.

Humans are good at pattern recognition so they can spot trends and changes on graphs. The problem is that it doesn't scale well. If you install metrics gathering agent (like collectd TODO link) on your server it'll produce hundreds metrics. If you have dozen of servers it'll produce thousands metrics which is impossible for human to review periodically.

Statistical tools can spot some trends and recognize some patterns too. With their help human can handle more data by looking only at interesting graphs.