---
layout: post
title: Meet the Data
---

![Great Wall of Graphs]({{ site.url }}/img/aspm/great-wall.png)

Here's the way typical performance metrics look like. CPU utilization, used memory, network io, disk io, etc. are plotted as a time series. I'll put no labels on axes because horizontal line is always time and vertical line is a value of some metric. There are cases when it helps to know what kind of metric we are analyzing but in general it doesn't matter for statistical purposes. Sometimes you get bunch data when all you know about metrics is their name and only system developers can shed some light on meaning of particular metric.

This style of visualization (TODO link to R slide) when black dots are individual data points and red curve is an averaged over some period value will be used for graphs. It allows to quickly see both data distribution (shown by darkness of dot cloud) and its trend.

There are several interesting things on the picture above. One service crached and was restarted which led to spikes on some graphs and drops on others. Another service is leaking memory which looks like nice linear trend upwards.

Understanding of a system (OS and application) helps a lot because you know what to look for and where. I used to navigate through hundreds of graphs while investigating production performance issues or load test results. Sometimes you have no idea of what's going on. In that case you have to check random metrics in hope to find something interesting and related to the problem.

Humans are good at pattern recognition so they can spot trends and changes on graphs. The problem is that it doesn't scale well. If you install metrics gathering agent (like collectd TODO link) on your server it'll produce hundreds metrics. If you have dozen servers it'll produce thousands metrics which is impossible for human to review on timely manner.

Faced that problem I noticed that I follow quite simple steps while analyzing data visually. I look for graphs which have some kind of change in their shape when things got broken or I'm looking for similar graphs (e.g. something that has spikes at the same time rate of user visible errors has spikes).

Statistical tools can spot some trends and recognize some patterns too. There is a whole body of knowledge on change point detection and clustering (grouping similar objects).  With their help human can handle more data by looking only at interesting graphs.

When I started learning statistics I found that real computer generated data is quite different from the ideal world of statistical models because of:

* Noise caused by human actions. At any given point in time there is some change happening. System administrators do their job reconfiguring and restarting stuff, cron jobs are running, clients come and go. Sometimes it is a signal (e.g. mistake in reconfiguration which led to broken service) and sometimes it's a noise.
* Outliers. In any given dataset there will be some points that don't make sense at all. They drive averages off their reasonable value and skrew up many algorithms.
* Missing data. Monitoring systems have their own failures, network is not reliable so sometimes you have gaps in you metrics. Many methods simply don't handle gaps and you have to either put some made up values into gaps or use another methods.
* Different sample rates. Some things change quickly so you measure them frequently and some don't. It makes no sense to report disk usage 10 times a second because it's impossible to fill up 2Tb drive in one second but you'll report network traffic quite frequently to find out micro-bursts that overflow buffers of you network switch.
* Counter update frequencies. Virtual memory subsystem in Linux kernel has a configurable statistics update interval which is 1 second by default. You might get strange results if you try to fetch that data more that once a second like some counters will change only once a second and others will return non-zero value once a second.
* Quantization. 