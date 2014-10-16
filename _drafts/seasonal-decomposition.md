---
layout: post
title:  "Handling Seasonal Data"
tags: monitoring statistics seasonal
---

_Describes simple method for taking the seasonal changes out of data_

Roughly speaking most of anomaly detection methods for time series expect data to be flat (not changing over time) and they find out when it stops being flat. But real data that comes from a system monitoring is not flat. People use the system during business hours and sleep at night so system usage metrics are higher during a daytime. Weekends usually have lower usage metrics (if it's not an entertainment application). That difference between daytime and nightime (and weekend vs. middle of the week) needs to be removed somehow before applying anomaly detection algorithm.

[Holt-Winters](http://en.wikipedia.org/wiki/Exponential_smoothing#Triple_exponential_smoothing) is popular for such data but it puts more weight into last observations so if you had major holiday or outage last week it'll expect the same dip next week leading to false positive.

There are several methods described at [chapter 6 Time series decomposition](https://www.otexts.org/fpp/6) of [Forecasting: principles and practice](https://www.otexts.org/fpp) that allow to split time series into seasonal and non-seasonal components.

I needed to deal with several thousands metrics so I started with the most simple and fast [Classical decomposition](https://www.otexts.org/fpp/6/3). Results were mostly OK but outliers in data affected extracted seasonal component. It happens because the method uses moving average to get trend component and then averages values for the same time during several seasons (like average between 10AM value for all observed Mondays).

(Moving) average is not robust in presence of outliers so I decided to try median instead.



Cycles vs. seasons.

current 10s don't have to be the same as 10s exactly one week ago. But current hour has to be similar to the same hour week ago (if there is no major holidays).


It leaves trend in place.