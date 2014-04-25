---
layout: post
title: "MapReduce in MongoDB"
date: 2013-08-07 10:40
comments: true
author: rhopton
categories: [MapReduce, MongoDB, JavaScript, Innovation]
---
One of the first things I took on when joining OpenTable was building a new endpoint in our reviews API to aggregate and summarise restaurant review data. Thankfully, at the time, all the data I needed was cached in memory so building the response object was a simple set of linq queries over the cached reviews.

## The problem ##

Over time the number of reviews grow, and grow, and grow!  In fact it is inevitable that, in time, it will reach a point where caching all this data in memory would be madness.  One option to mitigate this would be to limit the cache to a fixed date range but this won't work in this instance because the summary logic supports custom date ranges.  Another option would be to pull the data from the persistence store each and every time it's required however this would seriously impact load on the infrastructure and degrade performance of the API.

We like to be proactive at OpenTable, so during innovation time (yes! we get time to innovate on our development) I looked at finding an alternate solution that would meet the requirements of the logic and wouldn't drastically increase load or degrade performance.

## The solution ##

MongoDB supports [MapReduce][1] which allows processing large volumes of data (Map), running arbitrary logic to summarise (Reduce) and producing some results.  In MongoDB the MapReduce functionality uses JavaScript functions to perform the map and reduce steps and the syntax is relatively simple to understand:-

    db.largeDataset.mapReduce(mapFunction, 
                              reduceFunction, 
                              { out: "summary" }

In the above example the largeDataset collection is mapped using the predefined mapFunction, the results are passed to the reduceFunction and the reduced data is finally stored in the summary collection. On top of this you can specify queries as well as a finalize function to "tweak" the reduce results.

Because map, reduce & finalize are functions that only operate on their inputs the workload can be parallelized although the final results would be stored in one location.

#### Map ####

The key purpose of the map function is to take the complex documents and produce a structure conducive to summarising whilst at the same time defining the granularity of the results using grouping.

For example if you wanted to get the number of reviews by restaurant then you'd group by the restaurant's unique identifier meaning that the reduce function would produce a single result for each restaurant:-

    var mapFunction = function() {
                        emit(this.RestaurantId, 1);
                      };

This function, called on each review, maps the review to the value 1 and groups by the RestaurantId.  The value 1 was chosen because, as you will see in the continuation of this example below, it's the easiest way to calculate the count of reviews per restaurant.

#### Reduce ####

The key purpose of the reduce function is to take a batch of mapped values for a given group and return a single result.  All values emited from the map function are passed to the reduce function although since the batch size is decided by MongoDB there may be multiple calls to reduce.  In fact given a sufficiently large source dataset the reduce function will be passed results from previous reduce function calls as well.  For example if there were 250 mapped results in a group and batches of 100 were reduced by each call then four calls would be needed, three to reduce the initial 250 results and a final call to reduce these results into the final value for the group.

To continue the example from above:-

    var reduceFunction = function(group, values) {
                           return Array.sum(values);
                         };

The results from this function would be stored in the collection defined in the mapReduce call with an _id and value.  The _id property is populated with the group id and the value property will contain the final reduce result for that group.

## Getting Started in C# ##

The following are a list of projects/resources to look at if you want to implement Mongo MapReduce in your scenario with emphasis on C#:-

- [Mongo Map-Reduce Examples][2] is a useful primer document.
- [Mongo Cookbook][3] has a number of "real world" examples of MapReduce 
- [Mongo C# driver][4] has some logic to perform MapReduce however it is only a thin layer over the underlying syntax and uses JavaScript functions passed as strings.  
- [Fluent-Mongo][5] provides a linq syntax over simple map reduce functions.  Interestingly it can perform multiple calculations on a set of data although at present it doesn't support more complex logic.
-  [K.Scott Allen][8] has written two articles on MapReduce, [A Simple MapReduce...][6] and [A Simpler MapReduce...][7]

[1]: http://en.wikipedia.org/wiki/MapReduce
[2]: http://docs.mongodb.org/manual/tutorial/map-reduce-examples
[3]: http://cookbook.mongodb.org
[4]: http://docs.mongodb.org/ecosystem/drivers/csharp
[5]: http://github.com/craiggwilson/fluent-mongo/wiki/Map-Reduce
[6]: http://odetocode.com/blogs/scott/archive/2012/03/19/a-simple-mapreduce-with-mongodb-and-c.aspx
[7]: http://odetocode.com/blogs/scott/archive/2012/03/29/a-simpler-mapreduce-with-mongodb-and-c.aspx
[8]: http://twitter.com/odetocode
