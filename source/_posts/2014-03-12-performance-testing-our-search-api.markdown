---
layout: post
title: "Performance testing our Search API"
date: 2014-03-12 16:44
comments: true
categories: [Benchmarks, API, REST, Performance, Being a numpty]
---

It was midnight on the Friday before Christmas, my 7 week old child was tucked up asleep and I was pretty chilled. All was calm and it was time for bed. 2 minutes later I had a phone call, a series of nagios alerts through emails and a need to get up quickly. The search api was having trouble, as the manager of the team who develop this, I woke up pretty quickly. We were having an outage at one of our busiest times of the year, this was going to be fun.

Once the dust settled and we were back up and running we realised we needed to do a better job of performance testing and actually solve any performance issues. 

What had gone wrong
---
We were indexing our data too frequently, and under load it started to take a long time and we created a race condition where multiple indexing operations started happening and performance started degrading as a result of that and a vicious circle occurred. The simple fix was just to index the data less often, however we wanted to get to the bottom of why we slowed down under load which exposed this race condition and what is the maximum load the system can take.

Getting a benchmark
---
In order to know if we were actually making improvements we needed to be able to recreate load and see the impact. In order to do this and truly appreciate how it was going we needed to use our live environment. It is the only environment I felt we could truy understand. Read why here EXPLANATION OF WHY TESTING IN LIVE AND THE PROBLEMS IT CAUSES LINK

With search and availability it is actually quite hard to use response times as a benchmark and the name of this exercise was really to cope with greater load. Response times are still nice to improve though so we will be tracking it, just not using as our main benchmark.

Some perspective on our problem domain
---
We do not have a large index. In the tens of thousands of restaurants rather than millions of tweets etc. We have to merge in table availability (the fantastic thing about the OpenTable system) to the more static restaurant information. We also have large page sizes, we need to get upto 2,500 results out of one Elastic Search request, this proved to be relevant. 

We also have an autocomplete search endpoint served out of the same infrastructure but that was not heavy in terms of resource usage but we still noted it slowed down when peak load was happening.

Initial ideas to investigate
---
We brainstormed a few things to investigate and assess as potential performance improvements. As we were still relatively new to Elastic Search (ES), a lot of these were related to the configuration of ES itself.
- Improved sharding strategy, we were using the default
- Check we were filtering before querying
- Check the sorting is efficient
- Optimise the index as part of the indexing process
- Slow log checking
- Check how we are using the source in the index
- Warm-up the index after it is built
- Gzip between API boxes and ES
- Check connection pool is a singleton
- Delete old indexes more rigorously
- Check garbage collection on ES boxes
- Check swappiness settings on ES boxes
- Split different search types to different hardware

I have provided links to the steps that need more perspective or were successful. 

Now, we were a bit stupid
---
Once we worked through a few things, our main findings showed that we had done some rookie errors. 

We had a sharding policy that is great for large indexes but we only need one shard and then replicated on each ES server in the cluster. Changing that helped reduce the load across servers as each server could do our 

Through Elastic HQ (the useful plugin to ES LINK TO ES HQ) we got the rather crude red boxes for various metrics. The 2 that stood out where high Garbage Collection and disk swaps. The main thing causing this was that we were using OpenJDK instead of the Oracle JVM, we don't really know why this happened either! The swappiness setting was less impactful but resolved some of the issues caused by the frequent writing to disk. 

Now we increased scale well until we moved our bottleneck. From our Elastic Search cluster, to our api boxes.

And some things are limits of the technology
---
Now the api boxes were the problem we realised that basically serialisation and deserialisation is the bottleneck. The number of boxes can be scaled out (more servers) or serialisation removed. 

So what now
---
We have scaled out and our benchmark improved (amount of the traffic can we serve remember) but the speed is probably as fast as we can go. As a result we are actually looking at using Elastic Search a lot less than we originally planned. We need to take serialisation out of the game, using in memory filtering seems a candidate again.

That's it for Elastic Search?
---
Not at all, we love it. We are definitely still going to use for autocomplete, free text search and also other indexing we want to do with future feature plans we have. We made some stupid errors with it and our architecture just prevents us using it for our one, currently most important, use case, if we grow massively, and let's hope we do, this problem might get too big for an in memory process and then we will back with ES for sure.










