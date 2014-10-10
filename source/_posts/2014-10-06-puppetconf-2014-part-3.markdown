---
layout: post
title: "PuppetConf 2014 - Part 3"
date: 2014-10-06 13:43:36 +0100
comments: true
author: lbennett
categories: puppet, puppetconf2014, conferences
---

## Day 2

This is our summary of PuppetConf 2014. In our [previous post](http://tech.opentable.co.uk/blog/2014/10/06/puppetconf-2014-part-2/) we gave an overview of the first day of the conference. This post will provide an
overview of the final day.

There were even more inspiring keynotes and lots more talks which have given us plenty of ideas to go home and think about.


### Key Notes

#### Animating the Puppet: Creating a Culture of Puppet Adoption - Dan Spurling ([@spurling](https://twitter.com/spurling)), Getty Images - [Slides](http://www.slideshare.net/PuppetLabs/keynote-animating-the-puppet-creating-a-culture-of-puppet-adoption-puppetconf-2014)

<div style="float:right;margin:0 10px 10px 10px;width:50%">
  <img src="/images/posts/puppetconf-dan.jpg">
</div>


Dan Spuring, VP of Tech Services at Getty came out of the gate with a strong message. His [GSD](http://www.urbandictionary.com/define.php?term=GSD) t-shirt
giving you a clear understanding of who he is. His talk about creating a culture of Puppet adoption at his company was a great story of how challenging it
can be to move various business units with projects of various ages to a configuration-management (with Puppet) ethos.

I think it is good to hear that they are rolling cm out into that huge backlog of legacy infrastructure that we all try to pretend isn’t there.
How do you make it integrate into existing processes? How do you sell the DevOps message at the same time as introducing a tool like Puppet into the mix as
part of that message? Dan gave some thoughts on this and it was good to hear some of that from someone who appears to be on the other side of that challenge.

One of the analogies that he used I that found quite useful was that undertaking a project like this is like moving a boulder. It requires an executive sponsor to
get the thing moving at all and then it requires everyone pulling in the same direction if it’s ever doing to get anywhere.

The big take-away was that you need to puppetize right away - that you can’t wait for the right environment or conditions to start doing it, you just need
start now and demonstrate it. This echo’s the Continuous Delivery ideal of "if it hurts, then do it more often".


#### Decentralize Your Infrastructure - Alan Green, Sony Computer Entertainment America - [Slides](http://www.slideshare.net/PuppetLabs/keynote-decentralize-your-infrastructure-alan-green-sony-computer-entertainment-america)

<div style="float:right;margin:0 10px 10px 10px;width:50%">
  <img src="/images/posts/puppetconf-alan.jpg">
</div>

Alan’s talk posed an interesting argument: decentralise and let your developers choose the tools and services that they want - just make it easy for them to
do so. This obviously flies in the face of conventional sysadmin wisdom of trying to centralise, standardise and control everything but for an organisation the
size of scale of SCEA this is just never going to work. Sony has many different studios, each has their own special requirements and tooling that they need to
try and support.

The story of the interaction with these studios is a great classic sysadmin story that is worth repeating. It starts with something we have all heard before "I
need to X right now because it’s preventing me from releasing this game on time”. The reaction here is to either say Yes and risk burning out your people getting
it done or No risk your career if the release date gets pushed. As a sysadmin you're on the back-foot at this point - you pretty much have to do whatever it takes.
If you decentralize your infrastructure you get to turn the tables "No I don’t have tool X but we do have tool Y and Z that will meet your needs". This gives
the engineers/managers the choice to make rather than you - they can go out on their own and implement their first choice tool and it will take a bit longer or
they can have something supported by the team right now. Alan also made a interesting call-back to Kate Matsudaira’s keynote of the previous day when he said that
it’s all about honesty and trust. Be truthful with your engineers about what you are capable of achieving or not.

This is the sort of thing we do here at OpenTable and it’s been working very well. You need to design puppet to be as flexible as possible and to support those
teams that need support in their puppet implementations. Having a diverse set of tools is not a bad thing - especially when you are dealing with creative people -
it keeps them creative and you can push that creativity back into the product. You're also decentralising control, giving teams the ability to move their
infrastructure as fast as they need to move the product - meaning that your business is going to move faster get meet it’s ROI (because managers care about that
sort of thing)


#### Q&A with Luke Kanies

<div style="float:right;margin:0 10px 10px 10px;width:50%">
  <img src="/images/posts/puppetconf-luke-2.jpg">
</div>

The last "keynote" of the conference brought Luke back to the stage for a Q&A with the audience. Allowing people to text in questions live led to some amusement
and once the silly questions were out of the way ( what is your favourite book?, what is your favourite animal? ) we got down to some of the big questions that
people really wanted answers to.

**Q**: What is the roadmap for Puppet Apps?<br/>
**A**: I would be surprised if we release more than one per quarter, I’d rather put out four than 20, with five releases for each app. We are a small company,
and we have to try not to get overextended to the point where we can’t evolve the apps. They have to be evolved to be successful.

This seems fair, they is a lot of work involved in putting together something that is polished and tested and ready for market.


**Q**: What is the future of Open Source Puppet?<br/>
**A**: My goal is to keep the two products complementary, and to understand each is used for different reasons .. We’re trying to change how the market works
and thinks and this is done better with software that’s absolutely everywhere.


He probably gets asked this all the time. The more features that are poured into Enterprise it would be easy to think that the OSS efforts are diminishing and
that there is even motivation for them to close-source. My conversations with various parties suggest that this is far from the case and I think that open source
puppet community will continue to be vibrant for a long time yet.


**Q**: Where does Puppet fit into environments that don’t require convergence, where instead of adjusting the container you just re-provision?<br/>
**A**: Containers are a result of 10 to 15 years of investment in virtualization, so it’s easy to switch from the virtualization world to the containers world —
but a container can’t do everything.


This is a very pragmatic argument and he’s right. Containers are a very exciting space right now and there is no doubt that it will be a big part of the future
but the community and tooling needs to mature and there is also going to be a very long tail of “traditional” virtualisation technologies around for a very
long time yet.


**Q**: Are there any plan to integration remote orchestration into Puppet?<br/>
**A**: It’s an area we are investing heavily in, and I’m personally investing heavily in. … I’m a big fan of small independent tools that do one job and do it
correctly, rather than big huge tools that do a lot. I want to make our orchestration better, not by adding to Puppet, but by adding tools. I don’t want to add
more functionality to Puppet, but add functionality to the Puppet ecosystem.

MCollective has been in the puppet eco-system for a while now. It’s going to be getting a lot more attention over the next year so I am very excited to see how
this evolves.

### Tech Talks

#### Continuous Integration for Infrastructure as Code - Gareth Rushgrove, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/continuouslytestinginfrastructure)

Arguable one of the most interesting talks of the conference. This talk took the idea of infrastructure TDD to the next level. What would it be like to be able
to test common expectations of your infrastructure (monitoring, backups, machines in each region, budget limitations). There are lots of built-in assumptions
that we make about of infrastructure and a lot of business decisions that have been difficult to codify. This talk raising the challenge of providing a complete
API for your infrastructure and then testing against it.

* usual tools (serverspec, wrecker)
    - for containers
    - TDD
* Policy Driven development
* Infrastructure as an API
* common expectations (budget etc)
* clojure
* can you generate serverspec tests from PuppetDB data??? - yes!
* rake test::role::web_server
* [serverspec-puppetdb](https://github.com/garethr/serverspec-puppetdb)
* rspec outputter - monitoring - using it as a bridge

#### Experiences from Running Masterless Puppet - Erik Dalén, Spotify - [Slides](http://www.slideshare.net/PuppetLabs/puppetconf-2014-1)

Erik (this years MVP) always has a lot of interesting insights about Puppet from scaling out the infrastructure at Spotify and this talk is no exception.
This talk explains their decision to go masterless and the challenges in doing so. It seems that they have put in a lot of work in writing services to manage
things like hiera data and managing secrets. It is great to see how this approach scales, one can only hope that future work by PuppetLabs with the Apps project
improves this as option for most people.

* scaling workflow rather than puppet masters
* complex modules dependencies make it easy to break things
* r10k is still a fixed environment (upgrade apache and progress at the same time)
* they use their own tool for secret management

#### Getting Started with Puppet on Windows - Josh Cooper, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/puppetconf2014-gettingstartedwindowsfinal140925174855phpapp01)

This was a basic introduction to Puppet on windows. It covers what is possible and the many edge cases that you might run into. It was also the time to
re-announce the recent support for 64-bit puppet on windows. Thanks to Josh we also got a shout-out for the work we have done with our
[forge modules](forge.puppetlabs.com/opentable)

* Basic intro
* powershell, registry_key
* installing - mention of 64-bit
* puppet resource
* supported modules
* community modules (inc OT)
* geppetto vs VS
* problems
    - quotes
    - case sensitivity
    - UAC


#### Test Driven Development with Puppet - Gareth Rushgrove, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/tddforpuppet-39598529)

This is Gareth’s basic introduction to TDD with Puppet. It covers the latest tooling and how to build yourself a recent CI pipeline for your modules so that
they are forge-ready. Useful for anyone who is new to the space or who hasn’t released any modules yet.

* TDD
* [rspec-puppet](http://rspec-puppet.com/)
* [puppet-lint](http://puppet-lint.com/)
* [guard](https://github.com/guard/guard-rspec)
* [puppet-syntax](https://github.com/gds-operations/puppet-syntax)
* [beaker](https://github.com/puppetlabs/beaker) (vagrant + serverspec)
* [travis](https://travis-ci.org/)
* [puppet module skeleton](https://github.com/garethr/puppet-module-skeleton)

#### Using Docker with Puppet - James Turnbull, Kickstarter - [Slides](http://www.slideshare.net/PuppetLabs/using-docker-with-puppet-puppetconf-2014)

James gave a good introduction to Docker. Showing off the things that Docker is good at and also detailing some of the things that it isn’t.
He also showed how and when to use Puppet in this environment. For anyone moving from a  traditional set-up to a Docker based one then this talk is a must.

* what is docker
* dockerfile
* dockerhub
* what it does
* what it doesn’t
    - low-level
    - resource dependencies
    - what runs, when
* don’t install puppet inside your containers
* puppet apply

#### Tools and Virtualization to Manage our Operations at Puppet Labs - Cody Herriges, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/tools-and-virtualization-to-manage-our-operations-at-puppet-labs-puppetconf-2014)

Cody, is a member of the PuppetLabs operations team and wow they seriously have their work cut out for them. They have to manage pretty much every network,
vm technology and cloud platform available. This gives some of the challenges in doing that and some of the tools they have built to help them in
achieving that.

* all the VM technologies
* all the cloud platforms
* all the network providers
* automation
* monitoring (ELK)
* vmpooler ([https://github.com/puppetlabs/vmpooler](https://github.com/puppetlabs/vmpooler))

### Other Talks

* The Switch as a Server - Leslie Carr, Cumulus Networks - [Slides](http://www.slideshare.net/PuppetLabs/the-switch-as-a-server-puppetconf-2014)
* Intro to Using MCollective - Devon Peters, Jive Software - [Slides](http://www.slideshare.net/PuppetLabs/intro-to-using-mcollective-puppetconf-2014)
* How Puppet Enables the Use of Lightweight Virtualized Containers - Jeff McCune, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/how-puppet-enables-the-use-of-lightweight-virtualized-containers-jeff-mc-cune-puppet-labs)
* Server Locality Using Razor and LLDP - Jonas Rosland, EMC - [Slides](http://www.slideshare.net/PuppetLabs/server-locality-withrazorandlldp)
* Node Classifier Fundamentals - Dan Lidral-Porter, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/node-classifier-fundamentals-dan-lidralporter-puppet-lab)
* What's Next for Puppet Enterprise - Lindsey Smith, Puppet Labs & Susannah Axelrod, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/whats-next-for-puppet-enterprise-and-beyond)
* The DevOps Field Guide to Cognitive Biases (2nd Edition) - Lindsay Holmwood, Bulletproof Networks
* Delegated Configuration with Multiple Hiera Databases - Robert Terhaar, Atlantic Dynamic - [Slides](http://www.slideshare.net/PuppetLabs/rob-terhaar-puppetconf2014)
* Understanding OpenStack Deployments - Chris Hoge, OpenStack Foundation - [Slides](http://www.slideshare.net/PuppetLabs/understanding-openstack-deployments-puppetconf-2014)
* Implementing Puppet at a South American Government Agency, Challenges and Solutions - Pablo Wright, Edrans - [Slides](http://www.slideshare.net/PuppetLabs/implementing-puppet-at-a-south-american-government-agency-challenges-and-solutions-pablo-wright-edrans)
* Infrastructure as Software - Dustin J. Mitchell, Mozilla, Inc. - [Slides](http://www.slideshare.net/PuppetLabs/infrastructure-as-software-dustin-j-mitchell-mozilla-inc?)
* Dev to Delivery with Puppet - Sam Bashton, Bashton Ltd. - [Slides](http://www.slideshare.net/PuppetLabs/dev-to-delivery-with-puppet-sam-bashton-bashton-ltd)
* Get Puppet Enterprise into Your Company - Iko Saadhoff, KPN
* The Puppet Master on the JVM - Chris Price, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/the-puppet-master-on-the-jvm-puppetconf-2014)
* The Grand Puppet Sub-Systems Tour - Nicholas Fagerlund, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/the-grand-puppet-subsystems-tour-nicholas-fagerlund-puppet-labs)
* Building Community: One Puppet Module at a Time - Diane Mueller, Red Hat & Diego Castro, Getup Cloud
* Puppet for Everybody! - Federated and Hierarchical Puppet Enterprise - Chris Bowles, University of Texas at Austin - [Slides](http://www.slideshare.net/PuppetLabs/puppet-for-everybody-federated-and-hierarchical-puppet-enterprise-puppetconf-2014)
* Puppetizing Multitier Architecture - Reid Vandewiele, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/puppetizing-multitier-architecture-puppetconf-2014)
* The Evolving Design Patterns of Puppet Enterprise - Jonathan Spinks, Sourced Group & John Painter, Sourced Group - [Slides](http://www.slideshare.net/PuppetLabs/the-evolving-design-patterns-of-puppet-enterprise-jonathan-spinks-sourced-group-john-painter-sourced-group)
* From Development to Testing to Deployment with Puppet Enterprise and Microsoft Azure - Ross Gardler, Microsoft Open Technologies, Inc. - [Slides](http://www.slideshare.net/PuppetLabs/from-development-to-testing-to-deployment-with-puppet-enterprise-and-microsoft-azure-ross-gardler-microsoft-open-technologies-inc)
* Exploring the Final Frontier of Data Center Orchestration: Network Elements - Jason Pfeifer, Cisco - [Slides](http://www.slideshare.net/PuppetLabs/puppetconf-cisco)
* An In-Depth Introduction to the Puppet Enterprise Console - Ruth Linehan, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/an-indepth-introduction-to-the-puppet-enterprise-console-ruth-linehan-puppet-labs)
* Packaging Software, Puppet Labs Style - Melissa Stone, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/packaging-software-puppet-labs-style-puppetconf-2014)
* Orchestrated Functional Testing with Puppet-spec and Mspectator - Raphaël Pinson, Camptocamp - [Slides](http://www.slideshare.net/PuppetLabs/puppetconf-mspectator-talk)
* Fully Automate Application Delivery with Puppet and F5 - Colin Walker, F5 - [Slides](http://www.slideshare.net/PuppetLabs/i-control-rest-presentation-for-puppet)
* Managing the File and Exposing the API - Christopher Webber, Chef Software
* Case Study: Developing a Vblock Systems Based Private Cloud Platform with Puppet and VMware vCloud Suite - Peng Liu & Paul Harb, VCE - [Slides](http://www.slideshare.net/VCE_Computing/puppet-confvce-preso20140925)
* Got Logs? Get Answers with Elasticsearch ELK - Jordan Sissel, Elasticsearch - [Slides](http://www.slideshare.net/PuppetLabs/got-logs-get-answers-with-elasticsearch-elk-puppetconf-2014)
* Managing Network Security Monitoring at Large Scale with Puppet - Michael Pananen & Chris Nyhuis, Vigilant Technology Services - [Slides](http://www.slideshare.net/PuppetLabs/managing-network-security-monitoring-at-large-scale-with-puppet-puppetconf-2014)
* Building and Testing from Scratch a Puppet Environment with Docker - Carla Souza, Reliant - [Slides](http://www.slideshare.net/PuppetLabs/puppet-conf2014)

### Other Interesting Links

* [http://blog.superk.org/2014/09/puppet-conf-2014-review.html](http://blog.superk.org/2014/09/puppet-conf-2014-review.html)
* [http://www.olindata.com/blog/2014/09/first-impressions-new-cfacter](http://www.olindata.com/blog/2014/09/first-impressions-new-cfacter)
* [http://cwebber.net/blog/2014/09/26/i-am-not-a-coder/](http://cwebber.net/blog/2014/09/26/i-am-not-a-coder/)
* [http://www.slideshare.net/PuppetLabs/tag/puppetconf-2014](http://www.slideshare.net/PuppetLabs/tag/puppetconf-2014)
* [http://puppetlabs.com/blog/puppetconf-2014-day-1-tips-treats-and-tweets](http://puppetlabs.com/blog/puppetconf-2014-day-1-tips-treats-and-tweets)
* [http://puppetlabs.com/blog/puppetconf-2014-day-2-luke-q-and-a-devops-containers-and-more](http://puppetlabs.com/blog/puppetconf-2014-day-2-luke-q-and-a-devops-containers-and-more)
* [http://puppetlabs.com/blog/puppetconf-2014-day-1-tips-treats-and-tweets](http://puppetlabs.com/blog/puppetconf-2014-day-1-tips-treats-and-tweets)
* [http://puppetlabs.com/blog/puppet-conf-2014-wrap-up](http://puppetlabs.com/blog/puppet-conf-2014-wrap-up)
* [https://forge.puppetlabs.com/approved/criteria](https://forge.puppetlabs.com/approved/criteria)
* [http://puppetlabs.com/blog/puppet-server-bringing-soa-to-a-puppet-master-near-you](http://puppetlabs.com/blog/puppet-server-bringing-soa-to-a-puppet-master-near-you)
* [https://github.com/puppetlabs/puppetlabs-strings/](https://github.com/puppetlabs/puppetlabs-strings/)
* [http://bitergia.dev.puppetlabs.com/browser/](http://bitergia.dev.puppetlabs.com/browser/)
* [https://www.flickr.com/photos/pleia2/sets/72157648049231891/](https://www.flickr.com/photos/pleia2/sets/72157648049231891)
* [http://theshipshow.com/2014/10/the-pulse-of-puppetconf-2014/](http://theshipshow.com/2014/10/the-pulse-of-puppetconf-2014/)
* [http://www.theregister.co.uk/2014/09/23/puppetconf_2014_keynote/](http://www.theregister.co.uk/2014/09/23/puppetconf_2014_keynote/)
* [http://www.infoq.com/news/2014/09/puppet-approved-modules](http://www.infoq.com/news/2014/09/puppet-approved-modules)
* [https://github.com/ferventcoder/puppet-chocolatey-presentation](https://github.com/ferventcoder/puppet-chocolatey-presentation)
