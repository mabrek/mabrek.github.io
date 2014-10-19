library(xts)
library(ggplot2)

weekly.traffic <- as.xts(read.zoo("data/uslfo-week.csv", tz="GMT", format = "%Y-%m-%dT%H:%M:%S", header = TRUE, sep = ",", quote = "\"", dec = ".", fill = TRUE, comment.char = ""))[,1]
