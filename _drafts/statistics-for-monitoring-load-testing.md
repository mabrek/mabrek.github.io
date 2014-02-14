---
layout: post
title: "Statistics for Monitoring: Load Testing (Tuning)"
tags: monitoring statistics
---

Usually there is a goal for a load testing otherwise why do that. It could be stated as "system should be able to handle X concurrently working users with latencies not higher than Y and zero errors on hardware not larger than Z". "Premature optimization is the root of all evil" principle usually leads to a system not being able to handle even X/10 users when development of most important features are done. In that case load testing transforms into iterative tuning process when you apply load to the system, find bottlenecks, optimize, rinse and repeat.

There are some important points to be aware of. First is a transient response:

![transient response]({{ site.url }}/img/aspm/request-rate-restart.png)

It's a request rate on a system which was restarted. It was noisy but relatively stable in the left part then it dropped to zero when the system was down then something strange happened: requests started arriving in waves. Later it returned back to the same noisy behaviour.

In practice transient response means that you need to wait until system metrics become stable after you apply load to the system.

Second point is a sampling rate of metrics measurements. If interval between measurements is larger than a wave duration on a graph above you won't see any waves. There might be several randomly placed spikes and you might not even notice that there was a restart because the system could stop and start between two measurements.

The higher the sampling rate the better it is for load testing. Failure usually happens within seconds (milliseconds). If you collect system metrics once in 5 minutes you'll get healthy system and at the next moment it's completely broken. Failures often have cascading effect when failure of one component brings down several others. With infrequent measurements you'll not be able to identify which one was first to fail.

Measurement overhead and storage size puts upper limit on a sampling rate. There are not so many opensource monitoring systems which are capable of receiving and storing thousands metrics per second. In practice it's possible to collect metrics with 1 second interval for relatively small systems (several hosts) and with 10 second interval when you have more than 10 machines. I hope that the progress will make that statement obsolete soon.

### Load test example

![connected clients marked]({{ site.url }}/img/aspm/connected-clients-marked.png)
Vertical axis is number of connected clients measured by a system itself and horizontal is time. Clients were connecting to the system in batches with several minutes interval to allow it to stabilize. These steps are quite clear in the left part of the graph. Then something broke and starting more clients didn't result in more clients being connected. Then even already connected clients started to drop off.

![connected clients marked cut]({{ site.url }}/img/aspm/connected-clients-cut.png)

I've cut two adjacent ranges from whole time of the test divided by the point when arrival rate of clients slows down. As we'll see later it's not that important to find that point in time exactly. Now we have two time ranges (good and bad) to compare and the whole set of metrics gathered. Let's find what's broken in the second time range by comparing it to the first.

### Data filtration

Thousands metrics is a lot even for simple algorithms so we need to reduce their number somehow. Closer look reveals that there are a lot of metrics which either don't change at all (allows to throw constant metrics away) or change not a lot.

![low coefficient of variation]({{ site.url }}/img/aspm/low-coefficient-of-variation.png)

These metrics seem to have something going on until we plot them with Y range starting from 0.

![low coefficient of variation with 0]({{ site.url }}/img/aspm/low-coefficient-of-variation-0.png)

Now it's clear that nothing serious happens there. [Coefficient of variation](http://en.wikipedia.org/wiki/Coefficient_of_variation) is small for such metrics which allows to throw them away using simple criteria.

apply system knowledge
    tasks migrated by scheduler
    dependent (disk used/free)
    interface traffic < 10 packets/s
    load average < 0.5
