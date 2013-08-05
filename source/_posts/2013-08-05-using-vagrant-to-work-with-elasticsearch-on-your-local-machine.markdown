---
layout: post
title: "Using Vagrant to work with ElasticSearch on your local machine"
date: 2013-08-05 08:45
comments: true
author: pstack
categories: [Vagrant, ElasticSearch, Puppet, DevOps]
---
Recently, I have started to work a lot more with [Vagrant]() as a tool for creating a standard development environment across my team. This essentially means that regardless what the developers' machine is setup or running as, they can still reproduce the same environment as their colleagues just by entering a command. 

Configuration managgement is something we have had to embrace to help us maintain an ever changing world of technologies. The hardest thing is knowing what we actually have to build in these environments. We use Vagrant to help us understand this. The simple flow is as follows:

* Developer starts a new project
* Developer creates a Vagrantfile to spin up a local VM
* Vagrantfile gets iterated on as the development process goes forward
* 