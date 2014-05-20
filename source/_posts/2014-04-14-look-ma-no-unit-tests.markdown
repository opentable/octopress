---
layout: post
title: "Look ma, no unit tests!"
date: 2014-04-16 17:00
comments: true
author: ssalisbury
categories: [Testing, Engineering, Acceptance tests, Innovation]
---

_**UPDATE:** I've written a [follow-up to this post](/blog/2014/05/19/acceptance-now) with a bit more detail into how we made acceptance-only testing work in practice._

At OpenTable we strive to deliver change as quickly and correctly as possible. To do this effectively we are always looking for [new](/blog/2014/02/28/api-benchmark/) [tools](/blog/2013/08/16/grunt-plus-vagrant-equals-acceptance-test-heaven/) [and](/blog/2014/04/07/upgrading-puppet-with-puppet/) [methods](/blog/2014/02/10/the-adoption-of-configuration-management/) that allow us, the developers, to respond quickly and accurately to changing requirements and environments.

There are a number of practices that we already make use of, helping us to be the most effective team I've ever worked in:

- We operate in small teams who each own _most_ of their own vertical.
- We use continuous delivery to ship code to production within minutes.
- We have a high degree of high-quality test coverage.
- We are getting better and better at monitoring All The Things.
- [We use ChatOps](/blog/2013/11/22/beginning-a-journey-to-chatops-with-hubot/), so communication is central to our work, and keeps remote workers/teams in the loop.

All of the above are truly empowering for the dev team, and are conducive to an amazingly stress-free working environment. However, these practices only address the infrastructure, culture, and ceremony surrounding our work. What if there was something else? Something about the way we write the code itself, that could increase our velocity yet further, without compromising our integrity...

> There are a number of practices that we already make use of, helping us to be the most effective team I've ever worked in... What if there was something else?

Well, on a recent project, we found one such way: *_we decided to delete all of the unit and integration tests_*.

_What?! Are we quite mad?_ You may be thinking... Well, it took me a little time to get used to this idea as well, but read on and you'll see that it was actually the most sane thing we could have possibly done	.

## Survival of the testedest
In the beginning, the project had 100% unit test coverage, there were no external dependencies, and the world was Good.

Soon afterwards, a tall shadow appeared in the glorious unit-tested sunset. External dependencies had arrived. Like good little developers we added integration tests. It hurt, our codebase grew, we had occasional false-failures, but we were travelling the path well trodden. We had evaded the First Menace, and surrounded ourselves with heavy armour, we were safe. Things seemed to be Good.

_Meanwhile..._

We realised that some of the things that would be important to our consumers were still not covered by our tests. Things like actual HTTP responses, serialisation, and the like. These are things that don't always need to be tested explicitly, but since this was a third-party-developer-facing system, we really wanted to be sure that the interface worked exactly as we wanted, HTTP headers, character encoding, date formatting, the lot.

So, playing the role of our consumers, we engineered high-level acceptance tests, behaving byte-for-byte as we expected our customers to do.

Now, with the triple-action protection of three layers of tests, we felt our project was the most minty-fresh piece of haute engineering we had ever laid keyboards on.

We were wrong.

## Tests, tests, tests, duplication.
Up to this point, we had operated in a near-vacuum. That was fine, we had been working quickly to implement a sub-set of an existing and well-used API, so we knew which were the most important features that needed porting. We continued, largely happy with our creation, for some time.

_Then, gazing up from the receding tide of the third trimester were the hungry eyes of the Second Menace. Our users were upon us!_

Our early adopters were great, giving us a lot of helpful feedback and helping us shape the API into a genuinely usable v1. However, responding to this change required a greater degree of flexibility in the code than we had required up to this point. Our triple-chocolate-crunch of pithy tests was starting to really slow us down, and rot our teeth. The main reason for this: duplication.

We had tried from the start to avoid any duplication in our tests, but this was all but impossible to achieve. You just can't test an API call end-to-end in an acceptance-test style, without inadvertently testing all of the underlying logic for that call. Code which was already covered by unit tests, and often integration tests as well. Therefore each move we made came with the burden of updating multiple tests. Often materially very similar tests, but written to test a different layer of the same cake. We were between an immovable monolith and a very heavy boulder&mdash;and had a hoarde of features we still wanted to smash, who were freely bounding over the mountain tops, and out of reach.

It was time to cut ourselves free.

## Ripping off the plaster
The idea that we might not need all these layers of tests was first mooted by fellow OpenTable engineer Arnold Zokas. My initial reaction was one of slight incredulity. Delete all those tests that we've so carefully caressed and cajoled into a thing of beauty?! Strip off the armour?! I wasn't immediately convinced. However, the pain of implementing new features was starting to burn, so I was interested.

> I wasn't immediately convinced.

We talked about it&mdash;what was necessary about the unit tests? What was their real worth? We had to test many of those things from the outside-in anyway, with the acceptance tests, so why test them twice? The logic started to stack up. I was convinced this was the right thing to do.

Take a deep breath. _RIP!_ Aah, there, done.

There was a little bleeding, some gaps in our acceptance tests that had to be filled, some complex set-up logic from the integration tests that had to be ported to work with the acceptance tests. A few days' worth of cleanup and patching in the background, and... tentatively... we were done.

For me at least, this was a bold move. But it shouldn't have seemed so, we knew all of our endpoints were acceptance-tested, including every supported API call. My primary worry was how we were going to nail down the exact cause of bugs with no code-level testing. This turned out to be nowhere near as bad as I expected.

> We knew all of our endpoints were acceptance-tested, including every supported API call.

## What just happened?
I like to visualise this as if we were building [a giant arch](http://en.wikipedia.org/wiki/Gateway_Arch). At first, you build a temporary structure with scaffolding (the unit and integration tests). As time goes on you construct a hardened permanent structure (the software). On top of the software, you layer your [structural integrity monitors](http://en.wikipedia.org/wiki/Structural_health_monitoring) (acceptance tests). Eventually, there is no need for the scaffolding any more; the structure is self-supporting, and future modifications can rely on this&mdash;time to punch out the middle!

_Of course, there are other considerations, like logging, monitoring, and providing sandbox data, which all contributed to making this feasable&mdash;but that's for another post._

## Was it worth it?
Unequivocally, yes. Since making this decision, we have been unhindered by our tests, and they are back to being a much loved part of the project. We have had no problems that would have been caught by unit tests, and we can still do TDD with our acceptance tests. In addition, I think removing the crutch of unit tests may have improved our discipline somewhat: _it keeps us thinking in the context of the end-user at all times, so we never spend time working on a feature that isn't directly useful to our consumers._

> It keeps us thinking in the context of the end-user at all times, so we never spend time working on a feature that isn't directly useful to our consumers.

## YMWMCV
Of course, every project is unique (just like every other project), so _your mileage will most certainly vary._ We were working on a stateless facade over a small but crucial subset of the business&mdash;making reservations. For relatively small, stateless projects, this approach has worked brilliantly. However, when things do go wrong at development time, they could be at any layer in the stack, and you often need to attach a debugger to find out what happened. This is less than ideal, but in our case was a very cost-effective compromise.

The upshot, for me at least, is that you shouldn't be afraid to shirk convention when the project demands it. By really analysing what each part of your project is doing, you can cut the cruft, helping you move faster _without_ breaking stuff.

> By really analysing what each part of your project is doing, you can cut the cruft, helping you move faster _without_ breaking stuff.
