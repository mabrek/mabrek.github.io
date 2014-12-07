---
layout: post
title:  "More on Outlier Detection"
tags: monitoring statistics outliers
---

Detecting outliers in real world performance monitoring data has several non-obvious properties (?).

Outlier score is useless. It could be defined as number of standard deviations from the sample mean to the value in question (or number of IQRs from median).  Due to extremely long tails of data distribution there would be outliers with scores 10 and 1000 but it doesn't mean that one of them is 100 times worse than another. The only thing that seems to matter here is if the value is an outlier or not.

Mean and standard deviation values are misleading for non-gaussian distributions which are typical in performance monitoring data. Median and IQR (or interdecile range) are more robust estimates for [center](http://en.wikipedia.org/wiki/Central_tendency) and [dispersion](http://en.wikipedia.org/wiki/Statistical_dispersion) of data.

IQR or interdecile range could be 0 for a flat metric with rare spikes. It makes methods based on these values useless.

Many metrics have small number of unique values which skews calculation of quantilles (breaks IQR-based methods) and produces steep steps in CDF (breaks KS-test).

Asymmetric distribution suggests using asymmetric ranges around median but it's often impossible to calculate range on one side because there is only one value there (e.g. mostly constant metric with rare positive spikes).

We can't ignore outliers when reasoning about overall system performance. Imagine a single threaded service that has typical request latency about 1ms and one in 1000 requests takes 1s (outlier) to complete. If we drop the outlier (TODO link to Coordinated Omission) than the service seems to be capable of serving 1000 rps but in reality that service works for 1 second and then gets stuck for another second resulting in total performance less than 500 rps.

There are several events which are clearly outliers from practical point of view but outlier detection methods don't handle them well (though it's quite simple to detect them):

* Metric appeared. Packages like codahale metrics(TODO link) don't report all available metrics if application doesn't provide value for them. For rare events (like errors) it means that event's counter will be undefined until the event happens for the first time.

* Metric disappeared. It migth mean that metric was removed with latest update of application or that there was no single appearance for some rare event within observation window.

* Constant changed. Observation window contains only equal values and the last obtained one is not equal to previously seen.
