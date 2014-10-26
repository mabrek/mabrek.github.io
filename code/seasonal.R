library(xts)
library(ggplot2)

decompose.median <- function(m, period) {
  trend <- rollapply(m, width = period, fill = NA, align = "center",
                     FUN = median, na.rm = TRUE)
  season <- m - trend
  figure <- numeric(period)
  l <- length(m)
  index <- seq.int(1, l, by = period) - 1
  for (i in 1:period) figure[i] <- median(season[index + i], na.rm = TRUE)
  seasonal=xts(rep(figure, l %/% period + 1)[seq_len(l)], order.by = index(m))
  list(observed = m,
       trend = trend,
       seasonal = seasonal,
       remainder = m - trend - seasonal)
}

pageviews <- as.xts(read.zoo(
  "data/35days.csv",
  tz = "GMT",
  colClasses = c("NULL", "character", "numeric"),
  format = "%Y-%m-%d %H:%M:%S",
  header = FALSE,
  sep = ",",
  dec = ".",
  drop = TRUE))

pageviews.decomposed = decompose(ts(na.approx(pageviews), frequency= 7 * 24 * 60))
plot(pageviews.decomposed)

pageviews.broken = pageviews
pageviews.broken["2014-10-07 15:00 GMT/2014-10-07 17:00 GMT"] <- 0
dev.new()
plot(decompose(ts(na.approx(pageviews.broken), frequency= 7 * 24 * 60)))


dm.b = decompose.median(pageviews.broken, 7*24*60)
dev.new()
p <- autoplot(do.call(merge.xts, dm.b))  + facet_grid(Series ~ ., scales = "free_y")
print(p)
