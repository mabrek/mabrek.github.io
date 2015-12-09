найти машину со свободным диском, где не крутится latency sensitive applications
​
нужное место на диске - это 12 байт на отсчет
​
поставить туда https://github.com/lomik/go-carbon , он будет принимать данные и класть на диск
​
поставить туда https://github.com/brutasse/graphite-api и показать ему в конфиге путь к whisper files, которые откладывает go-carbon
​
поставить http://docs.grafana.org/ и показать ей на http endpoint graphite-api http://docs.grafana.org/datasources/graphite/
​
данные слать в протоколе описанном тут http://graphite.readthedocs.org/en/latest/feeding-carbon.html#the-plaintext-protocol на порт, где слушает go-carbon
​
чтобы системные данные с машин собирать, надо по ним расставить collectd, в нем включить плагин write_graphite и показать на порт, где слушает go-carbon
​
если в java приложениях используется https://github.com/dropwizard/metrics , то там просто включается отправка данных в graphite format, вот пример, как это в cassandra http://www.datastax.com/dev/blog/pluggable-metrics-reporting-in-cassandra-2-0-2
