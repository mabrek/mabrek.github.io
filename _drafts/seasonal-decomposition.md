---
layout: post
title:  "Handling Seasonal Data"
tags: monitoring statistics seasonal
---

_Describes simple method for taking the seasonal variation out of data_

Roughly speaking most of anomaly detection methods for time series expect data to be flat (not changing over time) and they find out when it stops being flat. But real data that comes from a system monitoring is not flat. People use the system during business hours and sleep at night so system usage metrics are higher during a day. Weekends usually have lower usage metrics (if it's not an entertainment application). That difference between daytime and nightime (and weekend vs. middle of the week) needs to be removed somehow before applying any anomaly detection algorithm.

Cycles vs. seasons.

current 10s don't have to be the same as 10s exactly one week ago. But current hour has to be similar to the same hour week ago (if there is no major holidays).

Exponential smoothing methods (Holt-Winters) put more weight into last observations so if you had major holiday or outage last week it'll expect the same dip next week leading to false positive.
