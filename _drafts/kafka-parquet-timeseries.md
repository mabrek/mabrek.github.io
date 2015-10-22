---
layout: post
title:  "Prototyping Long Term Time Series Storage with Kafka and Parquet"
---

_Another attempt to find better storage for time series data, this time it looks quite promising_

After struggling with keeping disk IOPS sane while ingesting hi-resolution performance data I ended up putting whisper (TODO) files into tmpfs (TODO) and shortening data retention to just one day because my load tests usually don't last more than several hours. Then I export data into R and do analysis. Large scale projects like Gorilla(TODO) and Atlas(TODO) do similar things. They store recent data in RAM and then dump it to slow long term storage.

Whisper format (TODO) is relatively good in terms of storage (12 bytes per datapoint). It's columnar because it saves each metric in its own file. It has redundant data because it saves a timestamp with each value and many values from different metrics share the same timestamp. There is no compression. I need something which is better than whisper.

Gorilla paper inspired me to look into column storage formats with efficient encoding for repeated data. I've decided to try Parquet (TODO). Unfortunately floating point compression is not there yet https://github.com/Parquet/parquet-mr/issues/306 (as a side note ORCFile TODO also doesn't have it https://issues.apache.org/jira/browse/ORC-15) but my values are 'double'.

To achieve space efficiency data needs to be written in large chunks so I needed something to buffer data until it reaches final destination. The way Kafka(TODO) works with streaming writes and read offsets made me think that it's a good fit for storing data until it's picked up by periodical job. That job would start, read all the data available from the last read offset, compress and store it, and sleep until the next cycle.

Most of my data uses graphite line format (TODO) which is quite verbose.

    metric value timestamp

Metric names and timestamps are repeating. Metrics are sent periodically at the same time so their lines share single timestamp. The same set of metrics is being sent each time. Only value changes over time but for many metrics are not changing a lot which makes it a good target for dictionary or delta encoding (TODO).

### Feeding graphite data into Kafka

I've set up single node Kafka as described in [manual](http://kafka.apache.org/documentation.html#quickstart)

Feeding graphite data into Kafka turned out to be one-liner with nc (TODO) and kafkacat(TODO):

    nc -4l localhost 2003 | kafkacat -P -b localhost -t metrics -K ' '

Metric name is used as message key in kafka and 'value timestamp' is a payload.

Then I've started collectd (TODO) with graphite reporter (TODO) pointing to localhost and reporting interval of 1 second. After several hours I've got 1.8 Gb queue in kafka.

Dumpling the data back into text format is a one-liner too:

    kafka-console-consumer.sh  --zookeeper localhost:2181 --topic metrics \
    --from-beginning --property print.key=true

Text file had size of 1.4Gb which means kafka has some overhead for storing uncompressed data. There are ~ 19000000 lines in the file.

### Fetching data from Kafka

I needed to handle read offsets manually so I chose SimpleConsumer. It's API turned out to be quite confusing and not that simple. It doesn't talk to Zookeeper (TODO) and allows to specify offsets. Handling all corner cases requires lots of [code](https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+SimpleConsumer+Example) but simple prototype turned out to be quite short in Scala:

    val consumer = new SimpleConsumer("localhost", 9092, 5000,
        BlockingChannel.UseDefaultBufferSize, name)
    val fetchRequest = new FetchRequestBuilder().clientId(name)
        .addFetch(topic, partition, offset, fetchSize).build()
    val fetchResponse = consumer.fetch(fetchRequest)
    val messages = fetchResponse.messageSet(topic, partition)
    

### Saving data into Parquet

[Parquet](https://parquet.apache.org/) API documentation doesn't seem to be published anywhere. Javadoc for [org.apache.parquet.schema.Types](https://github.com/apache/parquet-mr/blob/master/parquet-column/src/main/java/org/apache/parquet/schema/Types.java#L30) contains several schema examples. Writing local files from standalone application is not described anywhere but the module `parquet-benchmarks` contains class [org.apache.parquet.benchmarks.DataGenerator](https://github.com/apache/parquet-mr/blob/master/parquet-benchmarks/src/main/java/org/apache/parquet/benchmarks/DataGenerator.java#L68) which writes several variants of local files. Writing files depends on Hadoop classes so you'll need it as a project dependency (there's an [issue](https://github.com/Parquet/parquet-mr/issues/305) for that)

I decided to use 'wide' schema when each metric has its own column (to make use of delta encoding etc.):

    val types = mutable.Set[Type]()
    ...
    // for each message collect unique keys as types
    types += Types.optional(DOUBLE).named(key)
    ...
    val schema = new MessageType("GraphiteLine",
        (types + Types.required(INT64).named("timestamp")).toList) 

Boilerplate to create ParquetWriter object:

    val configuration = new Configuration
    GroupWriteSupport.setSchema(schema, configuration)
    val gf = new SimpleGroupFactory(schema)
    val outFile = new Path("data-file.parquet")
    val writer = new ParquetWriter[Group](outFile, 
        new GroupWriteSupport, UNCOMPRESSED, DEFAULT_BLOCK_SIZE, 
        DEFAULT_PAGE_SIZE, 512, true, false, PARQUET_2_0, 
        configuration)

For each unique timestamp a row (called group in Parquet) is added which contains values for all metrics (columns) at that time:

    for (timestamp <- timestamps) {
        val group = gf.newGroup().append("timestamp", timestamp)
            for ((metric, column) <- columns) {
                column.get(timestamp).foreach(group.append(metric, _))
            }
        writer.write(group)
    }
    writer.close()

### Effect of compression

Enabling gzip compression in Parquet reduced file size 3 times compared to uncompressed. The result took 12Mb for 19000000 input lines. Storing the same data in whisper format would take at least 230Mb (actually more because it reserves space for each metric for whole retention interval).

I tried enabling Snappy compression for Kafka publisher:

    kafkacat -P -b localhost -t metricz -K ' ' -z snappy < metrics.txt

and got ~ 500Mb queue size for 1.4Gb original data.

The result looks quite good: temporal buffer in Kafka needs 1/3 size of original data  and long term storage takes ~ 0.6 bytes per datapoint (while whisper takes 12 bytes).


### Open questions

Can Parquet handle very wide schema with 100k columns and more?

Is it possible to merge schema which has a change in column type from int to double?

How to get data from Parquet into R? ([issue](https://github.com/Parquet/parquet-format/issues/72))

### Source code

