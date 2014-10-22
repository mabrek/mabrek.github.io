library(xts)
library(ggplot2)

# original data has interval 42min which makes non-integer number of samples in a day
# resample it to 640s interval with linear approximation
resample640 <- function(m) {
  idx <- first(index(m)) + (1 : (7 * 135)) * 640
  na.approx(merge.xts(xts(order.by=idx), m))[idx,]
}

uslfo.traffic <- resample640(as.xts(read.zoo(
  "data/uslfo-week.csv",
  tz="GMT",
  format = "%Y-%m-%dT%H:%M:%S",
  header = TRUE,
  sep = ",",
  dec = "."))[,1])

plot(decompose(ts(uslfo.traffic, frequency=135)))

eqiad.traffic <- resample640(as.xts(read.zoo(
  "data/eqiad-week.csv",
  tz="GMT",
  format = "%Y-%m-%dT%H:%M:%S",
  header = TRUE,
  sep = ",",
  dec = "."))[,1])

dev.new()
plot(decompose(ts(eqiad.traffic, frequency=135)))

lvs.eqiad.traffic <- resample640(as.xts(read.zoo(
  "data/lvs-eqiad-week.csv",
  tz="GMT",
  format = "%Y-%m-%dT%H:%M:%S",
  header = TRUE,
  sep = ",",
  dec = "."))[,1])

dev.new()
plot(decompose(ts(lvs.eqiad.traffic, frequency=135)))


decompose.median <- function(m, period) {
  half.window <- period %/% 2
  median.window <- half.window * 2 +1
  l <- nrow(m)
  trend <- runmed(coredata(m), median.window, endrule="keep")
  trend[1:half.window] <- NA
  trend[(l - half.window):l] <- NA
  season <- coredata(m) - trend
  figure <- numeric(period)
  l <- length(m)
  index <- seq.int(1, l, by = period) - 1
  for (i in 1:period) figure[i] <- median(season[index + i], na.rm = TRUE)
  list(seasonal=rep(figure, l %/% period + 1)[seq_len(l)],
       trend=trend)
}

dev.new()
l.e.t.dm <- decompose.median(lvs.eqiad.traffic, 135)
autoplot(merge.xts(lvs.eqiad.traffic, l.e.t.dm$trend, l.e.t.dm$seasonal, lvs.eqiad.traffic - l.e.t.dm$trend - l.e.t.dm$seasonal)) + facet_grid(Series ~ . , scales = "free_y")
