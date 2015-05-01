---
layout: post
title: "Performance testing our Search API"
date: 2014-03-19 15:53
comments: true
author: ametcalfe
categories: [Benchmarks, API, REST, Performance]
---


It was midnight on the Friday before Christmas, my seven-week old child was tucked up asleep and I was pretty chilled. All was calm and it was time for bed. Two minutes later I had a phone call, followed by a series of Nagios email alerts, and a need to put my work hat on quickly. The search API was having trouble; as the manager of the team who developed it, I was not looking forward to this. We were having a real slowdown at one of our busiest times of the year &ndash; this was going to be fun.

Once the dust settled and we were back up and running we realised we needed to do a better job of performance testing and actually solve any performance issues. We _had_ done some performance testing but clearly not the right kind.

What had gone wrong?
---
We were indexing our data too frequently, and under load it started to take a long time. We created a race condition where multiple indexing operations started happening. As each operation assumed the previous one had either failed or finished a vicious circle occurred making the situation worse and worse.

The simple fix was just to index the data less often or not at all if another operation was running, however we wanted to get to the bottom of why we slowed down under load which exposed this race condition, improve that speed and understand what is the maximum load the system can take.

Getting a benchmark
---
In order to know if we were actually making improvements we needed to be able to recreate load and see the impact. In order to do this and truly appreciate how it was going we needed to use our live environment &ndash; the only environment I felt we could truly understand. My next post will explain why we felt this was the best environment for the job.

With search and availability it is actually quite hard to use response times as a benchmark and the name of this exercise was really to cope with greater load. Response times are still nice to improve though so we were tracking them, but not using them as our main benchmark.

Some perspective on our problem domain
---
We do not have a large index, in the tens of thousands of restaurants rather than millions of tweets for example. We have to merge in table availability (the fantastic thing about the OpenTable system) to the more static restaurant information. We also have large page sizes, needing to get up to 2,500 results out of one Elastic Search request. This proved to be relevant.

We also have an autocomplete search endpoint served out of the same infrastructure. That was not heavy in terms of resource usage but we still noted it slowed down when peak load was happening.

Initial ideas to investigate
---
We brainstormed a few things to investigate and assess as potential performance improvements. As we were still relatively new to Elastic Search (ES), a lot of these were related to the configuration of ES itself.

* Improved sharding strategy (we were using the default)
* Check we were [filtering before querying](http://elasticsearch-users.115913.n3.nabble.com/Elasticsearch-Filter-And-Query-td4027675.html)
* Check the [sorting was efficient](http://elasticsearch-users.115913.n3.nabble.com/Performance-of-term-query-with-sorting-td4032901.html)
* [Optimise the index](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-optimize.html) as part of the indexing process
* [Slow log](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-optimize.html) checking
* Check how we were using the [source](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/mapping-source-field.html) in the index
* Warm-up the index after it is built
* Gzip between API boxes and ES
* Check connection pool is a singleton, internal detail
* Delete old indexes more rigorously (we have a new index each release)
* Check [garbage collection](http://grokbase.com/t/gg/elasticsearch/13bezebw1p/garbage-collector-issues) on ES boxes
* Check [swappiness](https://groups.google.com/forum/#!topic/logstash-users/gfTTbRABk1M) settings on ES boxes
* Split different search types to different hardware

Now, we learned, we were a bit stupid.
---
Once we worked through a few things, our main findings showed that we had made some rookie errors.

We had a sharding policy that is great for large indexes but we only needed one shard replicated on each ES server in the cluster. Changing that helped reduce the load across servers as each server could do our queries entirely.

Through Elastic HQ ([the useful plugin to ES](http://www.elastichq.org/)) we got the rather crude red boxes for various metrics on the diagnostics page. The two that stood out were high Garbage Collection and disk swaps. The main thing causing this was that we were using OpenJDK instead of the Oracle JVM. If you are using OpenJDK, change it now! The swappiness setting was less impactful but resolved some of the issues caused by the frequent writing to disk.

Now we increased scale well, until we moved our bottleneck from our Elastic Search cluster to our API boxes.

And some things are limits of the technology
---
Now the API boxes were the problem we realised that basically serialisation and deserialisation is the bottleneck. The number of boxes can be scaled out (more servers) or serialisation removed. Also your programming language can be the limiting factor here. So we are now looking around at the best language as an option for speeding things up.

So what now
---
We have tweaked the ES set-up and scaled out our API servers and our benchmark improved (the amount of traffic can we serve). We have a roadmap for how to take more and more traffic but the response time is probably as fast as we can go if we keep the same methodology. As a result we are actually looking at using Elastic Search a lot less than we originally planned. We need to take serialisation out of the game where possible, using in-memory filtering seems a candidate again.

That's it for Elastic Search?
---
Not at all, we love it. We are definitely still going to use for autocomplete, free-text search and also other indexing we want to do with future feature plans we have.

It was our fault we made some stupid errors with it, but our architecture and technology decisions just prevent us using it for our one, currently most important, use case, right now.

Also solving serialisation issues creatively might mean we can use ES again.

Summary
---
Get performance testing into your deployment pipeline, consider testing in production and expect the worst. The worst being that you might have got something stupid wrong and it is only exposed when you really don't want it to be.