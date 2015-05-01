---
layout: post
title: "Interacting with ElasticSearch using Hubot"
date: 2014-11-08 11:32:42 +0100
comments: true
author: pstack
categories: [Hubot, ElasticSearch, Chatops]
---
At OpenTable, we use a few [ElasticSearch]() clusters. Our aim was to be able to interact with our ElasticSearch clusters via [HipChat](http://www.hipchat.com) so that we could troubleshoot easily and without having to log into our VPN. We already use [Hubot](http://hubot.github.com) as part of our systems workflow, so it made sense to be able to interact with ElasticSearch with it. 

### Setting a cluster alias

When a pager wakes me at 3am, I really do not want to have to try and type the cluster URL into my mobile hipchat client. So the first thing that was added to the script was the ability to give a cluster an alias.

```
elasticsearch add alias my-test-alias http://my-cluster.com:9200
```

![add-alias](/images/posts/elasticsearch-add-alias.png)

This allows us to use that alias for all commands going forward. Please note that you can remove and query aliases as well:


```
elasticsearch show aliases
```

![show-alias](/images/posts/elasticsearch-show-aliases.png)

```
elasticsearch clear alias my-test-alias
```

![clear-alias](/images/posts/elasticsearch-clear-alias.png)

### Using the ElasticSearch Cat API

A lot of what we do with ElasticSearch can be done via the [cat](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat.html) API. This has proved extremely useful to get node status, cluster health and index status. 

#### Cat Health
As documented [here](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-health.html#cat-health)

```
elasticsearch cluster health my-test-alias
```

#### Cat Nodes
As documented [here](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-nodes.html)

```
elasticsearch cat nodes my-test-alias
``` 

#### Cat Indices 
As documented [here](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-indices.html)

```
elasticsearch cat indexes my-test-alias
```

#### Cat Allocation
As documented [here]()

```
elasticsearch cat allocation my-test-alias
```

### Getting the Cluster Settings

Sometimes when we are rebalancing shards or recycling nodes, we want to be able to control the cluster settings. By using the cluster settings API, can have some insight into the settings currently set on the cluster:

```
elasticsearch cluster settings my-test-alias
```
More information about the cluster settings API can be found [here](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-update-settings.html#cluster-settings)

### Getting the Settings for an Index

Should we want to start to understand the actual settings that are attributed to an index, we can use the Cat Indices settings API. More information can be found [here](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/indices-get-settings.html)

```
elasticsearch index settings my-test-alias my-index-name-2014-11-07
```

### Clearing the cluster Cache

The last piece of the puzzle we are able to do, is to clear the cache of the ElasticSearch cluster. This can be done as follows:

```
hubot elasticsearch clear cache my-test-alias
```

### Where can I find the code?

The code is available on [github](https://github.com/stack72/hubot-elasticsearch) or also as an [NPM package](https://www.npmjs.org/package/hubot-elasticsearch). Please feel free to send PRs or create issues on our repository. All feedback is useful.


