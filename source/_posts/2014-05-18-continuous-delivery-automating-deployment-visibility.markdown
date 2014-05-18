---
layout: post
title: "Continuous Delivery: Automating Deployment Visibility"
date: 2014-05-14 19:08:13 +0100
comments: true
author: rtomlinson
categories: [Continuous Delivery, Hubot, Hipchat, Chatops]
---

In our continued effort to drive towards a service oriented architecture each of our teams are continuously improving their deployment processes. At Opentable we operate and see value in small team sizes, typically between 3 and 5 members per team. Each team has ownership for a particular part of the system. This works really well and gives teams a sense of autonomy and ownership. As with all organizations though it's important that we're not siloed and that there is visibility between teams. Recently our team has focussed on automating as much as possible, putting as much into chat as we can and improving our logging/metrics.

The image below shows at a high level what our teams current continuous delivery pipeline looks like and this post will attempt to summarise some recent changes that have allowed us to automate visibility.

{% img /images/posts/release-pipeline.png 900 350 'image' 'images' %}


##Kicking off a deployment

I wrote previously that we started [using chatops](http://tech.opentable.co.uk/blog/2013/11/22/beginning-a-journey-to-chatops-with-hubot/) to increase visibility operationally. Hubot is central to this and we wrote a small script to kick off deployments within [Hipchat](https://www.hipchat.com/)

{% img /images/posts/hubot-deploy-restaurant.png 350 350 'image' 'images' %}

We have two seperate environments which requires us to have 2 TeamCity instances to separate production and non-production deployments. Artifacts from our non-production instance are stored in [Artifactory](http://www.jfrog.com/home/v_artifactory_opensource_overview) and our production deployment makes an API call to non-production TeamCity to ask for the last successfully pinned build. Pinning a build only occurs when we're happy that the build is ready to be shipped (passing unit and acceptance tests). The above Hubot command will pin the non-production build, given that the build succeeded, and add a build to the queue in production. 

To configure Hubot to do this we wrote a command to setup aliases providing the build id of the build to pin (non-production) and the build id of the build to kick off (production).

{% img /images/posts/hubot-deploy-alias.png 350 350 'image' 'images' %}

##Deployment visibility

Our production deployments must be auditable and it's important that we know what went out with each release and keep a log of this for our Risk Management team. We do this by creating a ticket in [JIRA](https://www.atlassian.com/software/jira), internally known as a CCB, and this gives us a central store of all deployments by all teams. 

In the past these tickets were manually created for each release. We soon realised that this was something we could automate. To do so we created a new "deployment-info" endpoint for our service. This simply contains the SHA of the last commit released along with a time stamp. The first step of our production deploy is to query this endpoint and then using the Github API to get all the commits since that last SHA. These commits are then logged to JIRA to create a CCB ticket using the JIRA API. Each of these steps are automated from TeamCity using grunt tasks to which we open sourced:

- [https://github.com/opentable/grunt-ccb](https://github.com/opentable/grunt-ccb)
- [https://github.com/opentable/grunt-github-manifest](https://github.com/opentable/grunt-github-manifest)
- [https://github.com/opentable/grunt-package-github](https://github.com/opentable/grunt-package-github)

##Build Notifications to Kibana

Once we have a CCB we fire a start and end event from TeamCity containing the build number to Redis which is then piped into [Logstash](http://logstash.net/). An event is sent before and after deploying the code to all nodes. This is hugely beneficial because it allows us to plot releases against our graphs in [Kibana](http://www.elasticsearch.org/overview/kibana/). Kibana recently added a new feature called Markers. Essentially these are tags that display at the bottom of a graph.

{% img /images/posts/kibana-tags.png 350 350 'image' 'images' %}

We open sourced this grunt module too - [https://github.com/opentable/grunt-deployment-logger](https://github.com/opentable/grunt-deployment-logger)

This has already proved incredibly useful for the team and has allowed us to visually correlate issues or changes in KPI's to releases. The following image shows how these look over several graphs.

{% img /images/posts/kibana-dashboard.png 900 900 'image' 'images' %}

##Hipchat build complete notification

{% img /images/posts/hubot-notification.png 350 200 'image' 'images' %}

Once the build pipeline has completed we send a notification to our teams room in Hipchat (as a final step in TeamCity) to inform the team that the release has completed. It's great to see a deployment start and end in chat. Having a central log of key operations in our team means that we don't have to go and find information when it's baked into chat.


##Conclusion

We've come along way with improving our pipeline and automating visibility. Our team is made up of 4 members; 3 in the office and 1 remote. The ultimate goal is to improve speed of deployment and visibility of events not just within the team but for everyone who is interested. Equally we want to continue to open source by default, allowing us to share our process with teams inside and outside of our organization. We can release code anywhere in the world and the process is completely centralised in chat. We want to continue to move fast and fix faster.
