---
layout: post
title: "PuppetConf 2014 - Part 1"
date: 2014-10-06 11:47:57 +0100
comments: true
categories: puppet, puppetconf2014, conferences
---

![The start of PuppetConf 2014](/images/posts/puppetconf2014.jpg)

It has been one week since our attendance at this years PuppetConf and we have just now caught up on all the great talk that were
given and the projects demonstrated over the 3 day period. Here a our summary of the event (split into 3 parts), hopefully you will
find as much inspiration in the content as we have.

## Day 0 - Contributor Summit
For the first time this years Puppet Contributor Summit was held the day prior to the conference itself and I think this was a great idea.
Most of the Puppetlabs staff and many of the high profile community members were in town for PuppetConf anyway so it made sense. There was
roughly 60-70 people in attendance both senior contributors and people new to the community so it was a great mix that led to some
fantastic discussions.

The day itself had two tracks: a module track for forge modules and a core track for people contributing to puppet and factor.

Those of you who have seen our [forge module page](http://forge.puppetlabs.com/opentable) will understand why we chose to stay in the module track.
Although I heard there were many great discussions to be had account Puppet 4 in the core track.

Each track was split into three sections: a brief introduction from the track lead Ryan Coleman ([@ryanycoleman](https://twitter.com/ryanycoleman)),
followed by some lighting talks and then several hours of hacking and open discussions.

### Lightning Talks:
Here is a quick overview of the lightening talks from the module track:


#### Puppet Analytics (Spencer Krum [@nibalizer](https://twitter.com/nibalizer))
Spencer gave a quick demonstration of his latest project [puppet-analytics](http://puppet-analytics.org/). This problem that this tool was aiming to
solve was that at the present time the are no good analytics for the forge modules. The number of downloads listed for each module is very inaccurate
and can be easily inflated by (for example) an automated CI process. The point of this web app and it’s corresponding client
[puppet-analytics-client](https://github.com/nibalizer/puppet-analytics-client) was to be built into an existing tool chain and for end users to report
which modules and versions they were using. It also has the added benefit that we could also get stats for teams using private forges.

Ryan also commented that PuppetLabs has some metrics it uses for it’s own modules that can be found here:
[http://forge-module-metrics.herokuapp.com/](http://forge-module-metrics.herokuapp.com/)


#### Puppet Community (Daniele Sluijters [@daenney](https://twitter.com/daenney))
Discussion of the shared namespace for community modules: [puppet-community](http://puppet-community.github.io/). This talk was about a community project
to keep modules in a shared namespace so that everyone can work on them independent of company ownership. There are limitations right now with with
regards to the forge e.g. no shared accounts and no easy migration path to move modules between namespaces but working with Ryan on that.

This is how the boxen project works and it seems to work pretty well.


#### Beaker Testing Windows Environments (Liam Bennett [@liamjbennett](https://twitter.com/liamjbennett)) - me!!
My talk on hacking beaker to work better for testing windows environments.

Demos and PRs. Discussed more in some of our earlier posts: [Testing Puppet with Beaker pt.2 - The Windows story](http://tech.opentable.co.uk/blog/2014/09/01/testing-puppet-with-beaker-pt-dot-2-the-windows-story/)
and [Testing Puppet with Beaker pt.3 - Testing Roles](http://tech.opentable.co.uk/blog/2014/09/01/testing-puppet-with-beaker-pt-dot-3-testing-roles/)


#### Module Anti-Patterns (Peter Souter [@petems](https://twitter.com/petems)) - [Slides](http://www.slideshare.net/petems/puppet-module-anti-patterns)

Some interesting patterns here that are still quite preverlant in the modules found on the forge. Hopefully improved tooling and the new Puppet Approved
program will help here.


#### Puppetlabs ModuleSync tool (Colleen Murphy [@cmurphy](https://twitter.com/cmurphy))
A demonstration of the the tool [puppetlabs-modulesync](https://github.com/puppetlabs/modulesync) which aims to take out some of the pain of managing common
static build files across a number of modules (e.g. a common Rakefile or .travis.yml which the same across almost all modules)

Having used this on a number of our modules now I can say that this in extremely useful and I don’t know how we managed without it. A key use case for us was
adding support for puppet 3.7 into our test matrix of our travis.yml file. 1 line change - 1 command - 18 modules updated.


#### Strict Variables (Tomas Doran [@bobtfish](https://twitter.com/bobtfish))
Tomas has one very good point to make here: enable [strict_variables](https://docs.puppetlabs.com/references/latest/configuration.html#strictvariables). Many
languages have a strict option and Puppet’s makes sure to check for those unknown variable references. The latest version of the
[puppetlabs_spec_helper](https://github.com/puppetlabs/puppetlabs_spec_helper) supports adding this setting with an environment variable so that you can now
add this into your testing matrix.

We have enabled this on our open source modules and it did indeed surfice a few bugs so go and do it now.


#### Puppet Documentation Linting (Peter Souter [@petems](https://twitter.com/petems))
While we have very good linking for our puppet manifests themselves thanks to the [puppet-lint](http://puppet-lint.com/) project. We still do not have any
coverage for our documentation of those manifests. That is where Peter’s [puppet-doc-lint](https://github.com/petems/puppet-doc-lint) project comes in and aims
to lint each of you manifests for correct rdoc documentation.

This only supports puppet 3.4.3 right now but it is a useful tool and demonstrations something functional in an area that is missing from the current crop of
community tooling. This is going to become more useful as we want to have good documentation for Puppet Approved status.

It is also worth noting that PuppetLabs themselves have been doing some work in this area with
[puppet-strings](https://github.com/puppetlabs/puppetlabs-strings/). This projects works on puppet 3.6 + and support yard doc but is roughly the same idea.


#### Quick Survey (Michael Stahnke [@stahnma](https://twitter.com/stahnma))
Michael here decided to use the opportunity of having everyone in the room to ask a few questions regarding the state of puppet use and the platforms it’s
deployed on. Not too many surprises here: Debian (mostly ubuntu 12) and RedHat (mostly centos 6) dominate with a small grouping of other platforms like AIX and
Solaris in toe. Some poor individuals still have ubuntu 8 and 10 in production but I won’t name name’s because we have all been in that position before. No
mention of windows but then I did bring that up in my own talk so I think that was covered already.

### Hacking and Discussions

The second part of the day was the hacking and discussions part. This was more un-conference style with variables tables put together to discuss various topics,
try and resolves issues or hack on projects. There were four main areas that I noticed: module testing, windows, docker, forge improvements (apologies if I
missed your topic/table).

#### Module Testing
This was probably the most common topic and several tables were set up around this idea but a huge range of things were discussed. Some people wanted to know
about how to get up and running with beaker tests using vagrant+vagrant cloud, some wanted to discuss specific platform issues (windows, docker, solaris), other
 wanted to discuss how best to scale out the tests once you have them.

There was some discussion based around the tools like puppet-doc-lint that were demonstrated during the lightning talks and it’s good to see these missing
aspects of the testing tool chain getting some light.

It’s nice to think that we have moved to this stage now where we have all the tools to support a full development tool chain for puppet and that most of the
discussion was around improving and maturing what we have.


#### Docker
Docker is one of those tools that can be considered the latest hotness so it’s no surprise that it gained some interest here also. Many people wanted to see it
in use and demonstrated and to discuss it’s use either from the point of view of being able to test with it or test against it.

I see this topic getting a lot more coverage in the future as more and more teams move into this space.


#### Windows
Led by myself, Drew and Travis Fields ([@tefields](https://twitter.com/tefields)) the two aims for this discussion were to gather input/feedback from people using
the existing windows modules and to try and discover areas in the windows ecosystem that were not currently managed (either well or at all) by Puppet.

We go some fantastic feedback we got regarding our OpenTable modules - thank you to everyone who was there any everyone else who reached out about that.

We also managed to start to populate a list of things that need some work. You can contribute to that list
[here](https://docs.google.com/document/d/1bwgTo4D7lL8REA1s-IIKlfMrvY434Xn0cyZ7b1X-TwQ)

There was also some discussion of using MCollective on Windows. This has been a little painful in the past (I should blog about this in the future) but it will
be getting a little more love going forward. Generally PuppetLabs is very aware of the orchestration space and will be looking into solving this problem with
it’s tools going forward.

#### Forge Improvements
Given that this was the Module track it was obvious that at some point we would all want to discuss improvement that we would want to see in the puppet forge. Ryan
led the table here and there was lots of be said by all.

A couple of interesting documents emerged that you might be interested in:

 * [Suggestions for the Puppet Approved module criteria](https://docs.google.com/document/d/1N8U_8UnIGFHC1Q6aTyLgx1d6wvvjuyTT1EO-OYSIu3k)
 * [Forge Improvements](https://docs.google.com/document/d/1gwoM8xHnWaRQ3Jqce0oursI_ts5BWnHEUVXRQuIh6Yk)

There was also some discussion of how best to pull stats out from the forge. Many people either scrape the API, use the API to take a dump of the whole of the forge
but none of these approaches are best for either the user or for the forge site itself. PuppetLabs uses various approaches to this internally depending on the use
case. Such use cases include: "who is using my module?" or "who is using the bit of code?". There should be improvements to the forge to make answering these sorts
of questions a little easier in the future.

## Summary
The contributor summit was personally one of the most useful days of the conference. Being able to see the lastest tooling and discuss the latest problems is always
very useful to module authors like ourselves. Hopefully you'll find this summary as useful as we do.

Next up Day 1 - PuppetConf proper..
