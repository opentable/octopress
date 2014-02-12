---
layout: post
title: "The adoption of Configuration Management"
date: 2014-02-10 13:46
comments: true
author: pstack
categories: [devops, configuration management, puppet] 
---

Of years gone by, we were a traditional IT company. We had teams of developers and operations. They rarely mixed. Around 9 months ago, we started to really try and get these teams working together. We introduced a configuration management tool, [Puppet](http://puppetlabs.com/puppet/what-is-puppet), into our eco system. 

Configuration management is one of the steps of continuous delivery that developers often forget. They feel that systems are magically created for them to deploy their application to. I used to believe this. When I was focused on developing software, I never gave any thought as to the work our operations team had to do to keep the train on the track. So give some respect to your operations teams! We started a repository and started to experiment by configuring some of our applications using Puppet. 

This was a major step for both sets of teams. The developers started being in charge of the configuration of their application. This meant that their application would guarantee to be configured the same in our CI environment as it was in production. We, as developers, would be more confident of our applications working as expected. 

To contribute to the project, as an engineer, you need to:

* fork the project
* make the changes you require
* test the changes in a vagrant environment (already created with a windows and linux system)
* send a PR (pull request)

We have just merged our #874 pull request. The stats of the repository look as follows:

{% img center /images/posts/puppet-adoption.png %}

Our puppet repository has had contributions by over 40% of our engineering / operations teams. We use puppet to manage our application servers, DHCP servers, provisioning systems and even our MS Sql Server continuous integration infrastructure. The adoption has been fantastic. We started by running our internal QA infrastructure and then scaled it out to our production infrastructure. We now manage 548 nodes (a combination of internal and production) via Puppet. 

Using a project called [Gource](www.fullybaked.co.uk/articles/getting-gource-running-on-osx), one of our engineering leads, [Ryan Tomlinson](http://twitter.com/ryantomlinson), created a video of the repository vizualization. It's just over 2 minutes long and shows the activity the repository has taken.

{% vimeo 86201508 %}

Each branch in the tree relates to a directory inside our repository. Green zaps are additions, orange are updates and red deletions. The important thing to take from the video is the evolution of the repository, the amount of changes and the number of people pushing those changes.

I'm very happy with our configuration management adoption. We are by no means at a point where everyone does it, but we are working towards that. I would like our contributors to rise to over 75% of our engineering / operations team by the end of 2014. Let's see how that goes....
