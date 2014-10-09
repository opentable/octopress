---
layout: post
title: "PuppetConf 2014 - Part 2"
date: 2014-10-06 12:30:58 +0100
comments: true
author: lbennett
categories: Puppet, puppetconf2014, conferences
---

## Day 1
This is our summary of PuppetConf 2014. In our [previous post](http://tech.opentable.co.uk/blog/2014/10/06/puppetconf-2014-part-1/) we gave an overview of the contributor summit. This post will provide an overview
of the first day of PuppetConf.

As you might expect there were great keynotes with plenty of announcements and too many talks for us to attend. We have provided an outline for all the talks
we did attend and links to those we didn't.


### KeyNotes

#### Nearly a Decade of Puppet: What We’ve Learned and Where We’re Going Next - Luke Kanies, PuppetLabs - [Slides](http://www.slideshare.net/PuppetLabs/luke-kanies-keynote-nearly-a-decade-of-puppet-what-weve-learned-and-where-were-going-next-puppetconf-2014)

<div style="float:right;margin:0 10px 10px 10px;width:50%">
  <img src="/images/posts/puppetconf-luke-1.jpg">
</div>

The big keynote of the event to kick off the first day from the author of Puppet himself. This was obviously going to be a tweet worthy affair full of photos
and big announcements and it did not disappoint.

Native Clients (CFactor + C++ rewrite of agents) are coming in the very near future. This is not only a matter of improving the performance for existing users part
of philosophy of PuppetLabs to become ubiquitous across as many devices and platforms as possible. This is one of those improvements that is really setting up
PuppetLabs for the future.

Puppet Server (a.k.a the Clojure rewrite). This is PuppetLabs big move away from Ruby on onto the JVM. Being on the JVM means they can slowly rewrite the
codebase while also maintaining compatibility thanks to JRuby. They have gained a lot of experience with Clojure thanks to the PuppetDB & TrapKeeper projects and given how
successful that project has been it has helped ease many of the fears people have in moving the JVM. Puppet Server is also a self contained application so there
is no longer any need to worry about the whole apache/passanger yak shave. There was even a demo on the metrics that are now exposed by Puppet Server - yes
you can now plug Puppet into graphite.

There have been plenty of follow-ups on this that you might be interested in reading:

 * [http://www.infoworld.com/article/2687553/devops/puppet-server-drops-ruby-for-clojure.html](http://www.infoworld.com/article/2687553/devops/puppet-server-drops-ruby-for-clojure.html)
 * [http://puppetlabs.com/blog/puppet-server-bringing-soa-to-a-puppet-master-near-you](http://puppetlabs.com/blog/puppet-server-bringing-soa-to-a-puppet-master-near-you)
 * [http://puppetlabs.com/blog/new-era-application-services-puppet-labs](http://puppetlabs.com/blog/new-era-application-services-puppet-labs)
 * [https://github.com/puppetlabs/puppet-server](https://github.com/puppetlabs/puppet-server)
 * [http://www.informationweek.com/cloud/software-as-a-service/puppet-servers-big-revamp/d/d-id/1315934](http://www.informationweek.com/cloud/software-as-a-service/puppet-servers-big-revamp/d/d-id/1315934)

Puppet Apps was the next big announcement. Puppet Apps is actually a fantastic piece of marketing around the idea that they are refactoring to a more micro-services
style approach - splitting up the monolith that is currently the Puppet master into smaller applications that have their own release cadence and can be scaled
separately.

The first announcement from the "Apps" initiative is Puppet Node Manager the new node classifier which will roll out in the Q1 of 2015 as an add-on
to Puppet Enterprise. Given that Puppet has allowed external node classifiers to be written for a long time now (and there are many open source ones out there)
it is good to see PuppetLabs stepping up and trying to own this more and improve the experience.

[http://puppetlabs.com/about/press-releases/puppet-labs-kicks-puppetconf-announcements-major-updates-industrys-most-popular](http://puppetlabs.com/about/press-releases/puppet-labs-kicks-puppetconf-announcements-major-updates-industrys-most-popular)

Another huge announcement (of which we got a preview at the contributors summit) was Puppet Approved Modules. Luke and the rest of PuppetLabs have the huge
idea that 80% of what you're going to want to configure on your systems should be possible with what is available on the forge. Some of the bigger pieces have
been covered by the module engineers at PuppetLabs under the existing Puppet Support Modules program. This has been fantastic in driving for consensus around
configuration making installation of certain products (like apache) easier for people.

The reality is that if PuppetLabs want to achieve its 80% goal they are are not going to be able to do that with the engineers and resources they have
available to them. Nor do they have the expertise to know about all the software out there. This is where the Puppet Approved program comes in. Its aim is to
provide the same standard of quality that you see in the Supported modules but for modules written by the community. It is easy for users of the forge to
be able to pick out high quality, actively maintained modules and know what they are getting. As a user this is very exciting and as a module author, while
there will be plenty of work for me to do, I am glad that the community is moving in this direction.

Speaking of the community, Luke used this opportunity to announce the finalists and the winner of the Most Valued Puppetier (MVP) competition.

Finalists:

 * Daniele Sluijters ([@daenney](https://twitter.com/daenney))
 * Felix Frank
 * Tim Sharp ([@rodjek](https://twitter.com/rodjek))

Winner

 * Erik Dalén ([@erik_dalen]((https://twitter.com/erik_dalen))

The last part of the keynote was talking about some of the wider thoughts as we look to the next ten years of Puppet and what comes next. There is going to be
more focus on the ubiquity of Puppet, on devices more network device partners and solving problems like orchestration. The next ten years is going to be about
taking Puppet beyond the single node. We are already thinking of machines as cattle and not pets - Puppet should also better reflect that change.

I for one am very excited by all this and look forward to seeing what comes out over the next few years.

#### The Phoenix Project: Lessons Learned - Gene Kim, IT Revolution Press - [Slides](http://www.slideshare.net/PuppetLabs/keynote-the-phoenix-project-lessons-learned-puppetconf-2014)

<div style="float:right;margin:0 10px 10px 10px;width:50%">
  <img src="/images/posts/puppetconf-gene.jpg">
</div>

This was a great overview of Gene’s research of DevOps and how that intersects with high performing organisations. There were many interesting results that came
out the the survey that he did in joint co-operation with PuppetLabs many of which he shared during this talk.

I think the one that stands out and often tweeted is the following:

*"High performers have 30x more deployments and 8000x faster lead time, 2x the change success rate and 12x faster recovery"*

Read that again - wow.

This talk as one might expect was all about DevOps, its history, why and how it works. Even if you're fully familiar with the whole culture of DevOps there are
plenty of things to be learnt from this keynote and I look forward to re-watching it when the video lands on YouTube.

#### Trust Me - Kate Matsudaira, Popforms - [Slides](http://www.slideshare.net/PuppetLabs/keynote-trust-me-puppetconf-2014)

<div style="float:right;margin:0 10px 10px 10px;width:50%">
  <img src="/images/posts/puppetconf-kate.jpg">
</div>

Following the theme of culture, Kate’s talk was a refreshing look at the culture of trust within an organisation. Far from being the usual "this is what my
company culture looks like" sort-of talk, this talk had a lot of practical advice. Discussion of how to build relationships, how to raise your profile within
the organisation and how to improve yourself as a manger. "If you use your 1-on-1 to talk about status, you're wasting time. Get to know your boss, solicit
feedback on your performance." - Great advice like this is littered throughout the talk.

She says that trust is like money and that you need to be wise in how you spend that trust. Most organisations are not a meritocracy and we need to stop thinking that they are. Your relationships within the organisation are just as important as the quality of the work that you do.  There needs to be balance between these two things - are your relationships as good as the work that you do?

If you want to improve yourself and advance your career, either as an engineer or as a manager then you should absolutely take the time to listen to this talk.

**Bonus**: the slides rock! (I won’t spoilt it - take a look)


### Track Talks

#### The Puppet Debugging Kit: Building Blocks for Exploration and Problem Solving - Charlie Sharpsteen, Puppet Labs ([@csharpsteen](https://twitter.com/csharpsteen)) - [Slides](http://www.slideshare.net/PuppetLabs/the-puppet-debugging-kit-building-blocks-for-exploration-and-problem-solving-charlie-sharpsteen-puppet-labs)

Interesting tool, has some cross-over with the Beaker testing tool. PDK is more for focused manual testing rather than automated acceptance tests.

 * https://github.com/Sharpie/puppet-debugging-kit
 * vagrant + oscar (https://github.com/adrienthebo/oscar)
 * oscar is a collection of vagrant plugins
 * vagrant-config_builder -> adds role to share vagrant config  (similar to the beaker nodeset file)
 * PDK is a set of oscar roles
 * facter / hiera and Puppet running off GitHub
 * beaker vs oscar - oscar is optimised for manual testing. There is room to share stuff here.

#### Cloudy with a Chance of Fireballs: Provisioning and Certificate Management in Puppet - Eric Sorenson ([@ahpook](https://twitter.com/ahpook)), Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/sorenson-fireballspuppet-conf2014)

 * Apple iCloud uses Puppet + autosign
 * auto sign doesn't work very well for the cloud
 * Amazon IAM can be applied by machines - IAM so instance can read it’s own tags (if it has ec2-client-utils installed)
 * puts instance_id, ami_id and role into /etc/puppet/csr_attriubutes.yaml
 * can validate the metadata in the cert using x509
 * true_node_data = true & immutable_node_data = true
 * closes security hole of setting certname to fact on agent

#### Beaker: Automated, Cloud-Based Acceptance Testing - Alice Nodelman ([@alicenode](https://twitter.com/alicenode)), Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/beaker-automated-cloudbased-acceptance-testing-puppetconf-2014)

Having contributed to this tool, I was a little bias in attending this talk. Still plenty of interesting new things that came up though.
If you haven’t heard of beaker yet you will also be interested in our [previous blog post](http://tech.opentable.co.uk/blog/2014/04/04/testing-puppet-with-beaker/).

 * basic introduction to what beaker is and how to use it.
 * rspec vs test dsl - both are still supported methods of writing tests.
 * junit export - useful when integrating with Jenkins
 * `on host as` - is a feature that is coming soon so that you can run a command on a host with a given user account


#### Puppet Language 4.0 - Henrik Lindberg ([@hel](https://twitter.com/hel)), Puppet Labs  - [Slides](http://www.slideshare.net/PuppetLabs/puppet-language-40-puppetconf-2014)

Lots and lots of interesting information here about the new Puppet 4 syntax and jokes about some of the terrible edge cases of the past. It is good to
know now that with Puppet 4 there is a formal specification for the language so we should no longer see these sorts of weird edge cases of the past.
There are also lots of new features in the language: some to deal with long standing pain points (interation), some to help in the move away from ruby
(Puppet templates) and some to prevent authors themselves writing buggy manifests (the type system). Puppet 4 is going to be an exciting this to use.

 * pain-points / cleanup (specification)
     - numbers are numbers (and not strings)
     - Type references
 * heredoc
 * Puppet templates
 * iteration (each, map, filter, reduce, slice, with)
 * local defaults
 * Type system

#### 7 Puppet Horror Stories in 7 Years - Kris Buytaert ([@KrisBuytaert](https://twitter.com/KrisBuytaert)), Inuits - [Slides](http://www.slideshare.net/KrisBuytaert/7-years-of-puppet-horror-stories)

This was more of an interactive talk, trying to get members of the audience to try and predict what the actual problem was. For more senior Puppetiers
this was a fun talk, reminding us of the challenges many of us have faced. For newer Puppet developers this was likely acting as a good warning and
foreshadowing of things that may arise if your not careful (or are very unlucky).

* SSL
* Full Disk
* Puppet Bugs
* DNS (everything is a DNS problem)


#### Killer R10K Workflow - Phil Zimmerman ([@phil_zimmerman](https://twitter.com/phil_zimmerman)), Time Warner Cable - [Slides](http://www.slideshare.net/PuppetLabs/killer-r10k-39571913)

This was a good introduction to r10k and the reasons you would want to use it. The workflow is pretty straightforward and I think that for anyone managing Puppet at scale this is going to be something to look at.

* some good use cases for r10k
    - upgrading modules
    - not having to wait for all role tests to run
    - deploying everything to all masters (even hiera)
* workflow
    - ci per module
    - release job per module (tags)
    - deploy job per module (cap task to wrap r10k for masters/nodes)

### Other Talks from the Day

* Infrastructure-as-Code with Puppet Enterprise in the Cloud - Evan Scheessele, HP - [Slides](http://www.slideshare.net/PuppetLabs/infrastructure-ascode-with-puppet-enterprise-in-the-cloud-evan-scheessele-hp)
* Getting Started with Puppet - Michael Stahnke, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/getting-started-with-puppet-puppetconf-2014)
* Plan, Deploy & Manage Modern Applications Leveraging vCloud Automation Center and Puppet - Pradnesh Patil, VMware - [Slides](http://www.slideshare.net/PuppetLabs/plan-deploy-manage-modern-applications-leveraging-vcloud-automation-center-and-puppet-puppetconf-2014)
* Writing and Publishing Puppet Modules - Colleen Murphy, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/writing-and-publishing-puppet-modules-colleen-murphy-puppet-labs)
* To the Future! - Goals for Puppet 4 - Andrew Parker, Puppet Labs & Kylo Ginsberg, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/to-the-future-goals-for-puppet-and-facter-1)
* Managing and Scaling Puppet - Miguel Zuniga, Symantec - [Slides](http://www.slideshare.net/PuppetLabs/managing-and-scaling-puppet-puppetconf-2014-39542923)
* What Developers and Operations Can Learn from Design: 6 Ways to Work Better Together - Ashley Hathaway, IBM Watson - [Slides](http://www.slideshare.net/PuppetLabs/what-developers-and-operations-can-learn-from-design-6-ways-to-work-better-together-puppetconf-2014)
* Performance Tuning Your Puppet Infrastructure - Nic Benders, New Relic - [Slides](http://www.slideshare.net/PuppetLabs/performance-tuning-your-puppet-infrastructure-nic-benders-new-relic)
* "Sensu and Sensibility" - The Story of a Journey From #monitoringsucks to #monitoringlove - Tomas Doran, Yelp - [Slides](http://www.slideshare.net/PuppetLabs/130pm-210pm-tomas-doran-track-1-puppetconf2014-sensu)
* DevOps Means Business - Gene Kim, IT Revolution Press & Nicole Forsgren Velasquez, Utah State University - [Slides](http://www.slideshare.net/PuppetLabs/devops-means-business-gene-kim-it-revolution-press-nicole-forsgren-velasquez-utah-state-university)
* Auditing/Security with Puppet - Robert Maury, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/auditingsecurity-with-puppet-puppetconf-2014)
* Absolute Beginners Guide to Puppet Through Types - Igor Galić, Brainsware OG - [Slides](http://www.slideshare.net/PuppetLabs/absolute-beginners-guide-to-puppet-through-types-igor-galic-brainsware-og)
* Plugging Chocolatey into Your Puppet Infrastructure - Rob Reynolds, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/plugging-chocolatey-into-your-puppet-infrastructure-rob-reynolds-puppet-labs)
* PuppetDB: One Year Faster - Deepak Giridharagopal, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/puppetconf-2014)
* The Puppet Community: Current State and Future Plans - Dawn Foster, Puppet Labs & Kara Sowles, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/the-puppet-community-current-state-and-future-plans-dawn-foster-puppet-labs-kara-sowles-puppet-labs)
* Continuous Delivery of Puppet-Based Infrastructure - Sam Kottler, Digital Ocean - [Slides](http://www.slideshare.net/PuppetLabs/continuous-delivery-of-puppetbased-infrastructure-puppetconf-2014)
* The Seven Habits of Highly Effective Puppet Users - David Danzilio, Constant Contact - [Slides](http://www.slideshare.net/PuppetLabs/the-seven-habits-of-highly-effective-puppet-users-puppetconf-2014)
* Fact-Based Monitoring - Alexis Le-Quoc, Datadog - [Slides](http://www.slideshare.net/PuppetLabs/fact-based-monitoring-puppetconf-2014)
* Test-Driven Puppet Development - Nan Liu, Bodeco - [Slides](http://www.slideshare.net/PuppetLabs/testdriven-puppet-development-puppetconf-2014)
* A Practical Guide to Modules - Lauren Rother, Puppet Labs & Morgan Haskel, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/a-practical-guide-to-modules-lauren-rother-puppet-labs-morgan-haskel-puppet-labs)
* Leveraging the PuppetDB API: Puppetboard - Daniele Sluijters, Nedap
* Puppet Availability and Performance at 100K Nodes - John Jawed, eBay/PayPal - [Slides](http://www.slideshare.net/PuppetLabs/puppet-availability-and-performance-at-100k-nodes-puppetconf-2014)
* DevOps and Software Defined Networking - John Willis, Pacific Crest
* Razor, the Provisioning Toolbox - David Lutterkort, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/razor-the-provisioning-toolbox-puppetconf-2014)
* How to Puppetize Google Cloud Platform - Katharina Probst, Google, Matt Bookman, Google & Ryan Coleman, Puppet Labs - [Slides](http://www.slideshare.net/PuppetLabs/how-to-puppetize-google-cloud-platform-katharina-e)
* Continuous Infrastructure: Modern Puppet for the Jenkins Project - R.Tyler Croy, Jenkins - [Slides](http://www.slideshare.net/PuppetLabs/continuous-infrastructure-modern-puppet-for-the-jenkins-project-rtyler-croy-jenkins)
* How to Measure Everything: A Million Metrics Per Second with Minimal Developer Overhead - Jos Boumans, Krux - [Slides](http://www.slideshare.net/PuppetLabs/how-to-measure-everything-a-million-metrics-per-second-with-minimal-developer-overhead-puppetco)
* How to Open Source Your Puppet Configuration - Elizabeth Krumbach Joseph, HP - [Slides](http://www.slideshare.net/PuppetLabs/how-to-open-source-your-puppet-configuration-elizabeth-krumbach-joseph-hp)
* Manageable Puppet Infrastructure - Ger Apeldoorn, Freelance Puppet Consultant - [Slides](http://www.slideshare.net/PuppetLabs/manageable-puppet-infrastructure-ger-apeldoorn-freelance-puppet-consultant)
