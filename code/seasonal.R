library(xts)
library(ggplot2)

weekly.traffic <- as.xts(read.zoo(
  "data/uslfo-week.csv",
  tz="GMT",
  format = "%Y-%m-%dT%H:%M:%S",
  header = TRUE,
  sep = ",",
  quote = "\"",
  dec = ".",
  fill = TRUE,
  comment.char = ""))[,1]

# original data has interval 42min which makes non-integer number of samples in a day
# resample it to 640s interval with linear approximation
idx <- first(index(weekly.traffic)) + (1 : (7 * 135)) * 640
weekly.traffic <- na.approx(merge.xts(xts(order.by=idx), weekly.traffic))[idx,]

plot(decompose(ts(weekly.traffic, frequency=135)))

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

w.t.dm <- decompose.median(weekly.traffic, 135)
dev.new()
autoplot(merge.xts(weekly.traffic, w.t.dm$trend, w.t.dm$seasonal, weekly.traffic - w.t.dm$trend - w.t.dm$seasonal)) + facet_grid(Series ~ . , scales = "free_y")
