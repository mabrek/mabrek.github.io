---
layout: post
title:  "Prototyping Long Term Time Series Storage with Kafka and Parquet"
---

_Another attempt to find better storage for time series data, this time it looks quite promising_

After struggling with keeping disk IOPS sane when ingesting hi-resolution performance data I ended up putting whisper (TODO) files into tmpfs (TODO) and shortening data retention to just one day (because my load tests usually last not more than several hours). Large scale projects like Gorilla and Atlas do the same. They store short-term data in RAM and then dump it into slow long term storage.

Trying to keep realtime monitoring and historical data in the same database results in significant write amplification when small chunks of latest data are continuously being merged and rewritten to achieve more efficient long term storage.

To achieve space efficiency data needs to be written in large chunks so I needed something to buffer data until it reaches final destination. The way Kafka(TODO) works with streaming writes and read offsets made me think that it could be exploited for storing data until it's picked up by periodical job which just peeks the complete buffer compresses it and then sleeps until the next cycle.