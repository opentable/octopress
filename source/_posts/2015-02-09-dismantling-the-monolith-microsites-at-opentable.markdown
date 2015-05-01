---
layout: post
title: "Dismantling the monolith - Microsites at Opentable"
date: 2015-02-09 09:43:03 +0000
comments: true
author: mfigus
categories: [SOA, Microsites, Microservices, Monolith, OpenComponents] 
---

A couple of years ago we started to break-up the code-base behind our consumer site [opentable.com][1], to smaller units of code, in order to improve our productivity. New teams were created with the goal of splitting up the logic that was powering the back-end and then bring to life new small services. Then, we started working on what we call *Microsites*.

### Microsites

A microsite is a very small set of web-pages, or even a single one, that takes care of handling a very specific part of the system's domain logic. Examples are the *Search Results* page or the *Restaurant's Profile* page. Every microsite is an independently deployable unit of code, so it is easier to test, to deploy, and in consequence more resilient. Microsites are then all connected by a front-door service that handles the routing.

### Not a free ride

When we deployed some microsites to production we immediately discovered a lot of pros:

* Bi-weekly deployments of the monolith became hundreds of deployments every week.
* Not anymore a shared codebase for hundreds of engineers. Pull requests accepted, merged, and often deployed on the same day.
* Teams experimenting and reiterating faster: product was happy.
* *Diversity* on tech stacks: teams were finally able to pick their own favourite web-stack, as soon as they were capable of deploying their code and taking care of it in terms of reliability and performance.
* Robustness: when something was wrong with a microsite, everything else was fine.

On the other hand, we soon realised that we introduced new problems on the system:

* Duplication: teams started duplicating a lot of code, specifically front-end components such as the header, the footer, etc.
* Coordination: when we needed to change something on the header, for example, we were expecting to see the change live in different time frames, resulting in inconsistencies.
* Performance: every microsite was hosting its own duplicated css, javascript libraries, and static resources; resulting as a big disadvantage for the end-user in terms of performance.

### SRS - aka Site Resources Service

To solve some of these problems we created a REST api to serve html snippets, that soon we started to call *components*. Main characteristics of the system are:

* We have components for shared parts of the website such as the header, the footer, and the adverts. When a change has to go live, we apply the change, we deploy, and we see the change live everywhere.
* Output is in HTML format, so the integration is possible if the microsite is either a .NET MVC site or a node.js app.
* We have components for the core CSS and the JS common libraries, so that all the microsites use the same resources and the browser can cache them making the navigation smooth.
* The service takes care of hosting all the static resources in a separate CDN, so microsites don't have to host that resources.

This is an example of a request to the *core* css component:
```sh
curl http://srs-sc.otenv.com/v1/com-2014/resource-includes/css

{
  "href": "http://srs-sc.otenv.com/v1/com-2014/resource-includes/css",
  "html": "<link rel=\"stylesheet\" href=\"//na-srs.opentable.com/content/static-1.0.1388.0/css-new-min/app.css\" /><!--[if lte IE 8]><link rel=\"stylesheet\" href=\"//na-srs.opentable.com/content/static-1.0.1388.0/css-new-min/app_ie8.css\" /> <![endif]-->",
  "type":"css"
}
```

The downside of this approach is that there is a strict dependency with SRS for each microsite. On every request, a call to SRS has to be made, so **we had to work hard to guarantee reliability and good performance**.

Conclusions
-----------
When we tried the microsite approach we “traded” some of our code problems with some new cultural problems. We became more agile and we were working in a new different way, with the downside of having the **need to more effectively coordinate more people**. The consequence is that the **way we were approaching the code** evolved over time.

One year later, with the front-end (almost completely) living on micro-sites, and with the help of SRS, we are experimenting more effective ways to be resilient and robust, with the specific goal to allow teams to create their own components and share them with other teams in order to be independent, and use them to easily approach to A/B experiments. 

In the next post I'll write about [OpenComponents][2], an experimental framework we just open-sourced that is trying to address some of this needs.


[1]: http://www.opentable.com
[2]: https://github.com/opentable/oc