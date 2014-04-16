---
layout: post
title: "Internationalisation in a RESTful world"
date: 2014-04-02 14:11
comments: true
author: aroyle
categories: [i18n, Internationalisation, REST, http, API]
---

I18n is often a painful afterthought when serving content from a http-api. It can be taken for granted and tacked on using nasty query string values. But thankfully HTTP provides us with a solid gold opportunity. If you can look past the mire of content negotiation you can see the nuggets that lie inside.

The accept-language header is used by most browsers and allows websites to serve content in a language that the user can (hopefully) understand. When we expose content from an api (in most of our use cases, at least), this content eventually ends up in front of a human (in some shape or form). Having our service-service communication serve localised resources can be invaluable because it frees the clients from having to think about i18n of the resources being served from our api.

It is a simple part of the HTTP specification and is widely used and supported.

```
GET /product/123
Accept-Language: en-US
```

The accept-language header is specifically designed to allow the server to provide a representation of the resource which approximates something the client can understand.

The really useful bit comes from the quality value. 

```
GET /product/123
Accept-Language: en-US,en;q=0.8
```

This header asks the service to provide en-US, and if it's unavailable then fall back to __any__ english representation. The quality value (`q=0.8`) is a decimal value between 0 and 1 which indicates order of preference when specifying multiple languages. The server should pick the __first__ available match. If there are multiple matches with the same quality value, then the server can pick any. If the client wants to specify some fierce preferences then they can crank out something like this:

```
GET /product/123
Accept-Language: fr-CA,fr-FR;q=0.8,fr;q=0.6,en-US;q=0.4,en;q=0.2,*;q=0.1
```

If you decipher this it's pretty simple, you can see the quality headers giving the order in which the languages are preferred. What it does is give the client fantastic flexibility. For service-service communication you might have a use-case which will _never_ serve a representation that doesn't match the request, or you might need to _always_ provide some representation (i.e. for cases where some content is always better than none).

The accept-language header gives you that flexibility. In my opinon, if your http-api's are serving content that _can_ be internationalised, the server should always support this type of behaviour because it can shift the control from the server to the client. It allows the server's behaviour to be incredibly explicit and the clients get all that lovely flexibility.

__What happens when there is no matching representation?__

Well, the specification is (intentionally) vague. In other words, it is up to the server to decide. I myself always prefer to be explicit. Thankfully the HTTP specification provides for just such an eventuality.

[HTTP 406 Not Acceptable][1] *"The resource identified by the request is only capable of generating response entities which have content characteristics not acceptable according to the accept headers sent in the request."*

The 406 response _should_ contain a list of characteristics which the resource does support. In this case, a list of available languages. The specification does allow the server to automatically select a representation to return, however in my opinion, the server should be explicit, rather than implicit.

If the client has a use case where it _always_ requires some sort of response (i.e. where any content is better than no content), then the client can append a wildcard to the end of the accept-language header, which will instruct the server to fall back to *any* language, in the event that there are none matching.

__Parsing the Accept-Language header__

I wrote a little npm module to help us in [parsing the accept-language header][2]. Once you get past the (somewhat hairy) regex, it's a simple little bit of code. (Disclaimer, I'm not a regex god, so there are a couple of little bugs in it).

Parsing an accept-language string such as `en-US,en;q=0.8` gives an object looking like this:

```
[
  {
    code: "en",
    region: "GB",
    quality: 1.0
  },
  {
    code: "en",
    region: undefined,
    quality: 0.8
  }
];
```

Output is always sorted in quality order from highest -> lowest. as per the http spec, omitting the quality value implies 1.0.

We can pass this around our application and use it to select the representation which best matches the client's request.

__Using it__

We use [hapi.js][3] for some of our api's (and I'm very much in love), we use this module in a pre-requisite handler in our route:

```
var alparser = require('accept-language-parser');
server.route({
  method: "GET",
  path: "/v5/restaurants/{id}",
  config: {
    pre: [
      {
        method: function(req, next){
          next(alparser.parse(req.raw.req.headers["accept-language"] || ""));
        },
        assign: "language",
        mode: "parallel"
      }
    ],
    handler: function(req, reply){
        ...
    }
  }
});
```

For those of you that don't know, the prerequisites run before the handler, and assign their values to the request object. You can now get hold of the parsed language object here:

```
req.pre.language
```

__Content-Negotiation is hard__

Yes, it is. But suck it up. In my opinion the benefits outweigh the costs. Besides, the Accept-Language header is part of the HTTP specification and is well understood. If you have doubts, start small, and always try to be _explicit_ rather than implicit.

__Gotchas__

Caching (both client-side and intermediate) can be picky. By default, most caches won't respect the header content (i.e. the resource is cached by url only). You can get around this by using vary-headers:

```
GET /product/123
Accept-Language: en-GB,en;q=0.8
Vary: Accept-Language
```

This instructs the cache that the response will vary with the value of Accept-Language, so when this changes it should be cached as a separate resource. Vary headers __should__ be applied by the client to the request, however the server can apply them to the response if necessary.

[1]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
[2]: https://github.com/andyroyle/accept-language-parser
[3]: http://hapijs.com
