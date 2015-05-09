---
layout: post
title:  "Spark vs. Cyanite Timeseries data"
---

_Unsuccessful attempt to scale metrics processing by switching from Graphite/R to Spark/Cassandra/Cyanite_

My typical workflow is to run load tests until the system hits some limit or observe production failure, extract data from whisper files produced by carbon, import data into R and then run a battery of statistical tests and visual explorations on data to find the root cause of the problem and fix it.

There is a strong need to use hi-resolution data in load tests (because systems fail really fast under load) but the tools I use are not really good at ingesting and processing data with granularity finer than 10 seconds.
It's been a long time since I first tried to escape 'graphite world' but all attempts failed so far and here I'll tell about another attempt.

Graphite world (carbon-relay, carbon, graphite-web) has a lot of issues (TODO) and is moving slowly (TODO). Feeding metrics with 1s resolution to carbon might be feasible for one hosts but doesn't work at practical scale. This could be done but needs more hardware than monitored hosts.

R has a great amount of timeseries related libraries (TODO cran task) but it runs on a single core and is limited by available memory on a box. There are packages that allow R to fork several computation processes and move data between them but it's still limited to single box and memory management often becomes an issue.

Cassandra is said to be good at timeseries data. Spark is said to be fast at distributed data processing and there is spark-cassandra connector.