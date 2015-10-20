---
layout: post
title:  "Prototyping Long Term Time Series Storage with Kafka and Parquet"
---

_Another attempt to find better storage for time series data, this time it looks quite promising_

After struggling with keeping disk IOPS sane when ingesting hi-resolution performance data I ended up putting whisper (TODO) files into tmpfs (TODO) and shortening data retention to just one day because my load tests usually last not more than several hours. Then I export data into R and do analysis. Large scale projects like Gorilla and Atlas do the same. They store recent data in RAM only and then dump it to slow long term storage.

Trying to keep realtime monitoring and historical data in the same database results in write amplification when small chunks of latest data are continuously being merged and rewritten to achieve more efficient long term storage.

Whisper format (TODO) is quite good in terms of storage (12 bytes per datapoint). It's columnar because it saves each metric in its own file. It has redundant data because it saves a timestamp with each value and many values from different metrics share the same timestamp. There is no compression. I need something that is not worse than whisper.

To achieve space efficiency data needs to be written in large chunks so I needed something to buffer data until it reaches final destination. The way Kafka(TODO) works with streaming writes and read offsets made me think that it could be exploited for storing data until it's picked up by periodical job. That job would start periodically, read all the data available from the last read offset, store it, and sleep until the next cycle.
