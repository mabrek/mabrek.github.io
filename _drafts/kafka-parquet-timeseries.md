---
layout: post
title:  "Prototyping Long Term Time Series Storage with Kafka and Parquet"
---

_Another attempt to find better storage for time series data, this time it looks quite promising_

After struggling with keeping disk IOPS sane when ingesting hi-resolution performance data I ended up putting whisper (TODO) files into tmpfs (TODO) and shortening data retention to just one day because my load tests usually don't last more than several hours. Then I export data into R and do analysis. Large scale projects like Gorilla and Atlas do the same. They store recent data in RAM only and then dump it to slow long term storage.

(TODO delete)Trying to keep realtime monitoring and historical data in the same database results in write amplification when small chunks of latest data are continuously being merged and rewritten to achieve more efficient long term storage.

Whisper format (TODO) is quite good in terms of storage (12 bytes per datapoint). It's columnar because it saves each metric in its own file. It has redundant data because it saves a timestamp with each value and many values from different metrics share the same timestamp. There is no compression. I need something that is not worse than whisper.

To achieve space efficiency data needs to be written in large chunks so I needed something to buffer data until it reaches final destination. The way Kafka(TODO) works with streaming writes and read offsets made me think that it's a good fit for storing data until it's picked up by periodical job. That job would start, read all the data available from the last read offset, compress and store it, and sleep until the next cycle.

Most of my data uses graphite line format (TODO) which is quite verbose. Metric names and timestamps are repeating. Metrics are sent periodically at the same time so their lines share single timestamp. The same set of metrics is being sent each time. Only value changes over time but for many metrics are not changing a lot which makes it a good target for dictionary or delta encoding (TODO).

I've set up single node Kafka as described in http://kafka.apache.org/documentation.html#quickstart

Feeding graphite data into Kafka turned out to be one-liner with kafkacat(TODO):

    nc -4l localhost 2003 | kafkacat -P -b localhost -t metrics -K ' '

Metric name (the first field before space which is cut by -K option) is used as message key in kafka and 'value timestamp' is a payload.

Then I've started collectd (TODO) with graphite reporter (TODO) pointing to localhost and reporting interval of 1 second. After several hours I've got 1.8 Gb queue in kafka.

Dumpling the data back into text format is a one-liner too:

    kafka-console-consumer.sh  --zookeeper localhost:2181 --topic metrics --from-beginning --property print.key=true

Text file had size of 1.4Gb which means that kafka has some overhead for storing data.
