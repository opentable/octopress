---
layout: post
title: "Quick look at RethinkDB"
date: 2013-09-23 16:16
comments: true
author: aroyle
categories: [NoSQL, MongoDB, RethinkDB] 
---

Someone in the office mentioned [RethinkDb][1] and I was impressed by the rhetoric on the site, so I decided to spend a couple of hours spiking one of our existing nodejs apps with RethinkDb. The app currently uses MongoDb so inevitably I'm comparing the two.

Things I liked:
==

__Nodejs Driver__

The api on the nodejs driver is pretty nice, it makes a concerted effort to reduce "pyramid code" by allowing you to build your query by method-chaining and then call a `.run()` extension to execute the query.

```

r.db('Comics')
 .table('Superheroes')
 .getAll('Marvel', {index: 'universe'})
 .filter({ hasSidekick: true })
 .run(connection, function(err, cursor){
    cursor.toArray(function(err, items){
        callback(items);
    });
 });

```

__Interface__
The management interface is very good, incredibly friendly, and has guided access to things like sharding and replication settings (as well as the usual array of other things to tinker with).

__Sharding, Replication and Clustering__

It's all there, up front in the web UI, written in plain English and with friendly guides to help. The health and performance monitoring is available up-front in clear and concise graphics.

__Writes are non-locking operations__

A major bugbear for us with mongoDb is that writes require a database-level lock. RethinkDb allows block-level locks for write operations, and furthermore, reads can still proceed while write locks are in effect. [MVCC ftw!][2]

Things I didn't like:
==

__Cannot query on unindexed fields__

Meaning ad-hoc queries can be a pain-in-the-arse, especially if you have a large data set.


__Performance__

RethinkDb readily admit that their current release (v1.9.0) has taken a performance hit after implementing their clustering layer. They are hopeful that they can bring the performance back in the next few versions. My very simple, somewhat unscientific testing found it to be about 5 times slower than mongo, for a simple document read (20ms vs 120ms).

__Joins__

Don't get me wrong, it's a nice feature, it just makes me feel dirty to do joins on a document database.

Conclusion
==

RethinkDb is a good looking database. It's feature-full and dead simple to use. Would I use it in production? Not yet. The performance issues are still a sticking point for me, but I have no doubt that once these are fixed RethinkDb will be a big contender.


[1]: http://www.rethinkdb.com
[2]: http://en.wikipedia.org/wiki/Multiversion_concurrency_control
