---
layout: post
title: "Proxying Services With Hapi.js"
date: 2014-11-26 11:32:42 +0100
comments: true
author: aroyle
categories: [hapijs, microservices, proxy]
---
I've raved in the past about how awesome [hapi.js](http://hapijs.com) is, but I'm going to talk about just a specific case today.

We started off with just a couple of hapi.js apis. This was at a time when standing up new infrastructure was still a bit painful, so inevitably those apis ended up having more functionality in them than they should have. Now it's easy for us to get infrastructure, so we want to do more of it.

Our goal is to have lots of small(er) apis that just look after one specific piece (skillfully avoiding using the buzzword 'microservices').

When you want to split out functionality from one api to another, it can be a pain, especially if you have a lot of consumers who aren't particularly fast-moving or communicative. Or maybe you don't know all your consumers up front.

You've got a couple of options here:

* Maintain the functionality in two places and slowly migrate consumers across

* Use a proxy or routing layer in-front of the api to rewrite or redirect requests

* Write code in your api to proxy requests to a different server

The first two options are pretty icky, and frankly the third isn't all that great either. It all depends on you having the right framework. Do you see where I'm going here?

### Enter Hapi.js

Hapi.js has the concept of a 'proxy' handler, which can transparently proxy requests to a different server.

```javascript
server.route([
  {
    method: 'GET',
    path: '/foo',
    handler: {
      proxy: {
        host: 'my-other-service.mydomain.com',
        port: 80,
        protocol: 'http',
        passThrough: true,
        xforward: true
      }
    }
  }
]);
```

And boom, you're done. You can now safely delete *all* of that code from your api and move it. The *only* thing you need to have kicking about is that proxy handler code.

The `passthrough` setting specifies whether or not to preserve headers on the original request, and `xforward` tells hapi to add (or append) an 'x-forwarded-for' header to the request.

The proxy handler is really powerful. It can rewrite the request (using `mapUri`), pass local-state (from the hapi instance) along, reject unauthorised requests, you can even hook into the response and monkey about with it if you want (using `onResponse`).

For full details, see the [proxy section](http://hapijs.com/api/v7.5.2#route-options) of the route options.
