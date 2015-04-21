---
layout: post
title:  "Detecting Service Flapping and Load Oscillations"
---

There was a strange situation when users were experiencing slow page loads with periodical 5xx errors but the backend service looked OK with average cpu utilization about 50%. Usually it happens when some other service required to process the request is too slow but it was not the case. Sampling profiler attached to the backend showed nothing interesting in call stacks and time distribution between calls to other services was typical. The interesting thing was found on thread activity graph produced by the profiler. All the threads were busy doing something for 2 seconds and then idle for another 2 seconds like no requests were coming for 2 seconds out of 4. Load balancer logs showed that it was sending all the load to half of the cluster then declaring it down and switching to another half back and forth. Half of the cluster was unable to process all the load resulting in timeouts which was interpreted as being down by load balancer.

