---
layout: post
title: "Statistics for Monitoring: Load Testing (Tuning)"
tags: monitoring statistics
---

Usually there is a goal for a load testing. It could be stated as "system should be able to handle X concurrently working users with latencies not higher than Y and zero errors on hardware not larger than Z". "Premature optimization is the root of all evil" principle usually leads to a system not being able to handle even X/10 users when development of most important features finishes. In that case load testing transforms into iterative tuning process when you apply load to the system, find bottlenecks, optimize, rinse and repeat.

There are some important points to be aware of. First of them is a transient response.

![transient response]({{ site.url }}/img/aspm/request-rate-restart.png)

It's a request rate on a system which was restarted. It was noisy but relatively stable in the left part then it dropped to zero when the system was down then something strange happened: requests started to arrive in waves. Later it returned back to the same noisy behaviour.

In practice transient response means that you need to wait until system metrics become stable after you apply load to the system.

Second point is a sampling rate of metrics measurements.