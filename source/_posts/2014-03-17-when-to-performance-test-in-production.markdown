---
layout: post
title: "When to performance test in production"
date: 2014-03-17 16:39
author: ametcalfe
comments: true
categories: [Performance, Scaring operations]
---
In my last post about performance testing I wrote about how we decided to do it in production as the ultimate test of success. Performance testing in production is enough to make some operations guys have a panic attack and a few odd looks were dished my way when I raised it on behalf of the team.

Why not have a dedicated environment?
---
If you can have a dedicated environment that you can build to be EXACTLY the same as where you are going to really need the performance (i.e. your production environment most likely but possibly on a client machine) then do it in a dedicated, duplicated environment. Alternatively if there is no way you can use the production environment or your model means that everything will scale exactly like production then a duplicate environment might work.

For us, we had too many dependencies, mocking these out wasn't really satisfactory and frankly, as a business where we are quiet at night, it is easy to use the production environment at these times. We use configuration management and virtual machines, much of what should help build a replica environment, but we also have machines in restaurants around the globe. That is not easy to replicate and not worth the effort.

Even if you can have a duplicated environment should you?
---
We felt in the search team that we just wouldn't uncover a broken server (that can affect performance) or we wouldn't see that we had a problem with interactions with these services (we have now got to serialisation as our bottleneck, maybe we would have missed that).

We just didn't trust that a duplicated environment would actually help us in this case. If you want to test a new idea as a prototype then the duplicate will probably work, even if just at first, we were trying to improve our actual environment.

Is testing in production right?
---
There is no 'right' answer here, plenty of people test in a duplicate environment and then monitor in production. I think this is probably a valid approach and in a lot of use cases this would be fine for us too.

Can you micro-optimise in a huge production system, probably not, so use a scaled down duplicate for that or even a local environment such as one created using Vagrant. Hopefully with enough micro optimisations you will eventually see these in a larger environment.

Is it a free lunch?
---
Testing in production is not a free lunch. Even simple things like system logging will cost as you will be logging to production data centres, probably with backup costs etc. Do you need to code in safeguards? Yes, and you will need to watch this  running from your desk. When you are not watching it will be hard to be sure you will not cause production issues. We can use our regional environment that means we are testing during our day, that region's night, other companies might see you having to work in your timezone's evening, not fun.

Overall
---
Whilst, on the face of it, testing in production seems crazy, with all things considered we found it the easiest, most reliable and frankly most reassuring environment to test in.

