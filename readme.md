# Puma X Rails Throughput Test

I wanted to understand how Puma and Rails handle concurrent requests. I know that Puma is intended to sit in front of Rails providing thread (or process) level concurrency. But what happens if there are more requests in flight than threads/processes available? Does Puma buffer them, or is Rails able to handle them concurrently à la libuv?

This project is a simple API with a single endpoint: `GET /sleep`. Provide it a single `ms=` querystring and it will sleep for that long before returning 'ok'.

To test this, there is a script `attack.cr` which requires two parameters `--target-throughput` and `--url`. Target throughput defines how many requests you want to be in flight per second. URL defines the url that you want to test.

For our purposes, if we Puma is running with 5 threads:

```
crystal attack.cr --target-throughput=5 --url=http://localhost:3000/sleep?ms=1000
```

And we would expect to see each request returning with a latency of ~1000ms, which we do:

```
request 99 status=200 latency=1006.335446ms
request 100 status=200 latency=1005.961434ms
request 101 status=200 latency=1006.62441ms
request 102 status=200 latency=1007.427183ms
request 103 status=200 latency=1006.416481ms
request 104 status=200 latency=1009.45208ms
request 105 status=200 latency=1004.2891ms
request 106 status=200 latency=1002.917435ms
request 107 status=200 latency=1004.606657ms
request 108 status=200 latency=1006.204412ms
request 109 status=200 latency=1007.134167ms
request 110 status=200 latency=1006.439152ms
```

But what happens if we have 2x more requests than threads:

```
crystal attack.cr --target-throughput=10 --url=http://localhost:3000/sleep?ms=1000
```

Not so good:

```
equest 1 status=200 latency=1084.256459ms
request 2 status=200 latency=1003.922321ms
request 3 status=200 latency=1007.010609ms
request 4 status=200 latency=1006.997384ms
request 5 status=200 latency=1006.848442ms
request 6 status=200 latency=1572.553522ms
request 7 status=200 latency=1488.259955ms
request 8 status=200 latency=1493.056372ms
request 9 status=200 latency=1492.577039ms
request 10 status=200 latency=1492.794815ms
request 11 status=200 latency=2058.5828ms
request 12 status=200 latency=1973.825591ms
request 13 status=200 latency=1979.109512ms
request 14 status=200 latency=1977.648623ms
request 15 status=200 latency=1978.068666ms
request 16 status=200 latency=2544.502687ms
request 17 status=200 latency=2460.307499ms
request 18 status=200 latency=2464.68821ms
request 19 status=200 latency=2464.86035ms
request 20 status=200 latency=2465.058777ms
request 21 status=200 latency=3031.285542ms
request 22 status=200 latency=2947.01984ms
request 23 status=200 latency=2950.920225ms
request 24 status=200 latency=2950.153828ms
request 25 status=200 latency=2950.326412ms
request 26 status=200 latency=3519.205594ms
request 27 status=200 latency=3432.929646ms
request 28 status=200 latency=3437.5964ms
request 29 status=200 latency=3434.916412ms
request 30 status=200 latency=3436.291459ms
```

So it seems like Puma is buffering those requests, and therefore the concurrency is limited to the number of threads/processes available.
