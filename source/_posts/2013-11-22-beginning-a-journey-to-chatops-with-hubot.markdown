---
layout: post
title: "Beginning a journey to chatops with Hubot"
date: 2013-11-22 09:34
comments: true
author: rtomlinson
categories: [Hubot, Hipchat, Chatops]
---

{% img center /images/posts/hubot_pug_me.png %}
 
As a part of our 30% time a few of our team, [@ajroyle](https://twitter.com/ajroyle), [@stack72](https://twitter.com/stack72) and I ([@ryantomlinson](https://twitter.com/ryantomlinson)) decided to get together and look at [Hubot](http://hubot.github.com/) with [Hipchat](https://www.hipchat.com/) integration. There are several weird and wonderful scripts that ship with Hubot (see above) but the core concept of driving tooling via chat is one that we see value in.

##What is Chatops?

[Chatops](https://speakerdeck.com/jnewland/chatops-at-github) is a term coined by Github to describe their growing culture of “putting tools in the middle of the conversation”. But what does that exactly mean?

To move fast and maintain stability it’s important to have a culture of automation, measurement and sharing ([CAMS](http://www.opscode.com/blog/2010/07/16/what-devops-means-to-me/)). Tooling plays a key role in doing so and as your devops toolkit grows with the team there is an inherent learning and maintenance overhead. [Github](http://github.com/) made a move to centralise the conversation by driving everything they do into chat. By building tools and executing commands in a chat room that can be automated by a bot, communication doesn’t become an afterthought to operational processes but is core to how you operate. If I want to deploy code, I type a command into chat. If I want to take a server offline, I type a command into chat. If I want to merge a git pull request into master, I type in a command into chat, and so on. Communication is baked in.

##What is Hubot?

Hubot is a chat bot that sits in your chat room, listens for commands and executes them. It was written by Github in Coffeescript on Node.js and comes with a host of [prewritten scripts](https://github.com/github/hubot-scripts/tree/master/src/scripts) to get started with. Hubot also comes with a range of adaptors that allow it to plug-in to chat servers such as Campfire, IRC and Hipchat. We chose the latter.

##How do you get started?

I won’t re-write the readme because the getting started section [here](https://github.com/github/hubot/tree/master/docs) says it all. Using the node package manager it’s so easy to get up and running with [Hubot](https://github.com/blog/968-say-hello-to-hubot). So many other people have documented this process that I won’t attempt to rewrite their [good](http://net.tutsplus.com/tutorials/javascript-ajax/writing-hubot-plugins-with-coffeescript/) [posts](https://github.com/blog/968-say-hello-to-hubot).

##How we want to use it and our first scripts
Although the core scripts that shipped with Hubot are helpful…

{% img center /images/posts/hubot_beer_me.png %}

…we started to focus on commands that would be most useful to how we work at [OpenTable](http://www.opentable.co.uk/) and the tools and technologies that we employ. Specifically we got together and decided the following would be a useful starting point:

* Triggering TeamCity builds to ship to production
* Displaying the status of a JIRA ticket, adding comments and changing their status
* Checking London Underground tube lines for delays via Transport for London API
* Querying the status of our APIs (internal and external)
* Query ElasticSearch node and health cluster

Within no time we had some useful scripts written:

{% img center /images/posts/hubot_tube_status.png %}

{% img center /images/posts/hubot_jira.png %}

{% img center /images/posts/hubot_teamcity.png %} 

Immediately as we were developing these scripts we realised the potential of what else we could automate into Hubot and we will continue to do so. Some of which are:

* Github interaction
* AWS interaction to see host health
* Teamcity integration to trigger builds
* Nagios interaction to trigger status checks
* More JIRA integration to comment on tickets
* Kibana integration to create dashboard URLs
* AppDynamics interaction to query response times etc. (and more)

Driving operations in chat has huge benefits for us. Collaboration, deployment and automation of common tasks can be done from anywhere, in the office (UK or US) or remotely for those that work from home. Hipchat has mobile support and their mobile apps are great. We hope it will improve on-call visibility, triaging of issues and resolving them without the need for VPN.

## Resources

* Chatops: Augmented reality for Ops (Video) by Mark Imbriaco - [http://www.youtube.com/watch?v=pCVvYCjvoZI](http://www.youtube.com/watch?v=pCVvYCjvoZI)
* ChatOps at Github by Jesse Newland - [http://www.youtube.com/watch?v=NST3u-GjjFw](http://www.youtube.com/watch?v=NST3u-GjjFw)

