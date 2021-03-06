---
layout: post
title:  "More on Outlier Detection"
tags: monitoring statistics outliers
---

_Several features of outlier detection in real world performance monitoring data._

Outlier score is useless. It could be defined as number of [standard deviations](http://en.wikipedia.org/wiki/Standard_deviation) from the [sample mean](http://en.wikipedia.org/wiki/Mean) to the value in question (or number of [IQRs](http://en.wikipedia.org/wiki/Interquartile_range) from [median](http://en.wikipedia.org/wiki/Median) depending on method used).  Due to extremely long tails of data distribution there would be outliers with scores 10 and 1000 but it doesn't mean that one of them is 100 times worse than another. The only thing that seems to matter here is if the value is an outlier or not.

[Mean](http://en.wikipedia.org/wiki/Mean) and [standard deviation](http://en.wikipedia.org/wiki/Standard_deviation) values are misleading for non-gaussian distributions which are typical in performance monitoring data. [Median](http://en.wikipedia.org/wiki/Median) and [IQR](http://en.wikipedia.org/wiki/Interquartile_range) (or [interdecile range](http://en.wikipedia.org/wiki/Interdecile_range)) are more robust estimates for [center](http://en.wikipedia.org/wiki/Central_tendency) and [dispersion](http://en.wikipedia.org/wiki/Statistical_dispersion) of data.

[IQR](http://en.wikipedia.org/wiki/Interquartile_range) or [interdecile range](http://en.wikipedia.org/wiki/Interdecile_range) could be 0 for a flat metric with rare spikes. It makes methods based on these values useless.

Many metrics have small number of unique values which skews calculation of quantilles (breaks [IQR-based methods](http://www.edgarstat.com/tukeys_outliers_help.cfm)) and produces steep steps in [empirical CDF](http://en.wikipedia.org/wiki/Empirical_distribution_function) (breaks [KS-test](http://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test)).

Asymmetric distribution (typical for latency data) suggests using asymmetric ranges around median but it's often impossible to calculate range on one side because there is only one value there (e.g. mostly constant metric with rare positive spikes).

We can't ignore outliers when reasoning about overall system performance. Imagine a single threaded service that has typical request latency about 1ms and one in 1000 requests takes 1s (outlier) to complete. If we drop the outlier (maybe because of [Coordinated Omission](http://www.azulsystems.com/sites/default/files/images/HowNotToMeasureLatency_LLSummit_NYC_12Nov2013.pdf)) then the service seems to be capable of serving 1000 rps. In reality that service works for one second and then gets stuck for another second resulting in total performance less than 500 rps.

There are several events which are outliers from practical point of view but outlier detection methods don't handle them well (though they are quite simple to detect):

* Metric appeared. Some libraries might start reporting metric only after application provides value for the first time. For rare events (like errors) it means that event's counter will be undefined until the event happens for the first time.

* Metric disappeared. It might mean that metric was removed with latest update of application or that there was no single appearance for some rare event within observation window.

* Constant changed. Observation window contains only equal values and the last obtained one is not equal to previously seen values.
