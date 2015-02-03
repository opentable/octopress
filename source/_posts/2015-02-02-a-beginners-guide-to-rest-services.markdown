---
layout: post
title: "A Beginner's guide to REST services"
date: 2015-02-02 11:53:25 +0000
author: fmaffei
comments: true
categories: [Architecture, Engineering, REST, API, Theory]
---

## Why this post? ##

As a junior, I always find it easier to just sit and write code than actually stop to think about the theoretical basis that lie under the applications I work on. **REST**  is one of those terms I heard a lot about, so I decided to try to sum up what it means and how it affects the choices we make everyday as software engineers.

## Introduction to REST ##

REST stands for Representational State Transfer, and it can be defined as an architectural style used to build Web Services that are lightweight, maintainable, and scalable. A service that is designed by REST principles can be called a **RESTful service**.

It has been described first in 2000 by Roy Fielding, in a [dissertation](http://www.ics.uci.edu/~fielding/pubs/webarch_icse2000.pdf) called "Architectural Styles and the Design of Network-based Software Architectures". The basic idea was to describe the interactions between the components of a distributed system, putting constraints on them and emphasizing the importance of an uniform interface, that is abstracted from the single components.

REST is often applied to the design and development of web services, which is the scenario I'll try to address in this post.

The purpose of a web service can be summed up as follows: it exposes **resources** to a **client** so that it can have access to them (examples of typical resources include pictures, video files, web pages and business data).

Common features of a service that is built in a REST style are:

- Representations
- Messages
- URIs
- Uniform Interface
- Statelessness
- Links between resources
- Caching

## Representations - what are they? ##

REST style does not put a constraint into the way resources are represented, as long as their format is understandable by the client.

Good examples of data formats in which a resource could be returned from a service are [**JSON**](http://www.json.org/) (JavaScript Object Notation, which nowadays is the coolest one) and [**XML**](http://www.w3.org/XML/) (Extensible Markup Language, used for more complex data structures). Say for instance a REST service has to expose the data related to a song, with its attributes. A way of doing it in JSON could be:

```json
{
    "ID": 1,
    "title": "(You gotta) Fight for your right (To party)",
    "artist": "Beastie Boys",
    "album": "Licensed To Ill",
    "year": 1986,
    "genre": "Hip-Hop"
}
```

Easy, huh?

Anyway, a service can represent a resource in a number of ways at the same time, leaving the client to choose which one is better suited for its needs. The important thing is that there is agreement on what format to send/expect.

The format that the client needs will be part of the **request** sent by the client.

The resource will be eventually sent by the service as part of what we call a **response**.

It has to be kept in mind that a resource should be completely described by the representation, since this is the only information the client will have. It has to be exaustive, but without exposing classified or useless information about the entity at the same time.

## Messages A.K.A. client and service chatting ##

Q: So, how exactly do client and service exchange requests and responses?

A: They send messages.

In fact, to be more specific, the client will send an **HTTP request** to the service, specifying the following details:

- The **method** that is called on the resource. It can correspond to a *GET*, a *POST*, a *PUT*, a *DELETE*, an *OPTIONS* or a *HEAD* operation.
- The **URI** of the request. It identifies what is the resource on which the client wants to use the method. More on that later. For now let's say it is the only way the client knows how to call the needed resource.
- The **HTTP version**, which is usually [*HTTP/1.1*](http://tools.ietf.org/html/rfc2616).
- The **request headers**, which are the additional information passed, with the request, to the service. These fields are basically request modifiers, similar to the parameters sent to a programming language method, and they depend on the type of request sent. More on that later.
- The **request body**: is the actual content of a message. In a RESTful service, it’s where the representation of resources sit. A body will not be present in a GET request, for instance, since it is a request to retrieve a resource rather than to create one, whereas a POST request will most likely have one.

The request will then generate an **HTTP response** to the client, that will contain the following elements:

- The **HTTP version**, same as above.
- The **response code**: which is a three-digit status code sent back to the client. Can be of the **1xx** format (informational), **2xx** (success), **3xx** (redirect), **4xx** (client error), **5xx** (server error).
- The **response header**, which contains metadata and settings related to the message.
- The **response body**: contains the representation (if the request was successful).

## URIs, home of the resources ##

A requirement of REST is that each resource has to correspond to an [URI](http://en.wikipedia.org/wiki/Uniform_resource_identifier) address, which unsurprisingly stands for Uniform Resource Identifier. Having URIs associated to resources is key, because they are the addresses on which the client is allowed to perform the operations on the resources. It is important to stress that according to REST an URI should describe a resource, but never the operation performed on it.

The addresses are usually constructed hierarchically, to allow readability. A typical resource URL could be written as: `http://serviceName/resourceName/resourceID`

Basic guidelines to build well-structured URIs are:

- Resources should be named with plural nouns, no verbs, using conventions throughout the whole service.
- Query URIs `http://serviceName/resourceName?id=resourceID` should be used only when really necessary. They are not deprecated by REST style, but they are less readable than the normal URIs, and are ignored by search engines. On the upside, they allow the client to send parameters to the service, to refine the request for a specific subset of resources, or resources in a specific format.

## Uniform interface, various operations ##

Ok, so now that a client knows where a resource is reachable, how is it going to handle the resource? What are the operations that it can perform?

HTTP provides a set of methods that allow the client to perform standard operations on the service:

<table style="margin-bottom:16px;">
    <tr>
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">Method</th>
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">Operation performed</th> 
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">Quality</th>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">GET</td>
        <td style="padding:5px 10px;">Read a resource</td> 
        <td style="padding:5px 10px;">Safe</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">POST</td>
        <td style="padding:5px 10px;">Insert a new resource, or update an existing one</td> 
        <td style="padding:5px 10px;">Not idempotent</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">PUT</td>
        <td style="padding:5px 10px;">Insert a new resource, or update an existing one</td> 
        <td style="padding:5px 10px;">Idempotent (see below)</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">DELETE</td>
        <td style="padding:5px 10px;">Delete a resource</td> 
        <td style="padding:5px 10px;">Idempotent</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">OPTIONS</td>
        <td style="padding:5px 10px;">List allowed operations on a resource</td> 
        <td style="padding:5px 10px;">Safe</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">HEAD</td>
        <td style="padding:5px 10px;">Return only the response header, no body</td> 
        <td style="padding:5px 10px;">Safe</td>
    </tr>
</table>

The key difference between *POST* and *PUT* is that no matter how many times a *PUT* operation is performed, the result will be the same (this is what *idempotent* means), whereas with a *POST* operation a resource will be added or updated multiple times.

Another difference is that a client that sends a *PUT* request always need to know the exact URI to operate on, I.E. assigning a name or an ID to a resource. If the client is not able to do so, it has no choice but to use a POST request.

Finally, if the resource already exists, *POST* and *PUT* will update it in an identical fashion.

These operations, according to REST, should be available to the client as hyperlinks to the above described URIs, and that is how the client/service interface is constrained to be *uniform*.

## Statelessness of the client side ##

A RESTful service does not maintain the application state client-side. This only allows the client to perform requests that are resource specific, and does not allow the client to perform operations that assume prior knowledge of past requests. The client only knows what to do based on the ability to read the hypertext it receives, knowing its media type.

This leads me to mention an important constraint of REST, that was also [enforced by Fielding](http://roy.gbiv.com/untangled/2008/rest-apis-must-be-hypertext-driven) after publishing his dissertation: hyperlinks within hypertext are the only way for the client to make state transitions and perform operations on resources. This constraint is also known as **HATEOAS** (Hypermedia As The Engine Of Application State).

## Links between resources ##

In the case of a resource that contains a list of resources, REST suggests to include links to the single resources on the representation, to keep it compact and avoid redundant data.

## Caching to optimize time and efficiency ##

Allows to store responses and return them if the same request is performed again. It has to be handled carefully to avoid returning stale results. The headers that allow us to perform controls over caching are:

<table style="margin-bottom:16px;">
    <tr>
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">Header</th>
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">Application</th>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">Date</td>
        <td style="padding:5px 10px;">Finding out when this representation was generated</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">Last Modified</td>
        <td style="padding:5px 10px;">Date and time when the server modified the representation</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">Cache-Control</td>
        <td style="padding:5px 10px;">HTTP 1.1 header used to control caching, can contain directives</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">Expires</td>
        <td style="padding:5px 10px;">Expiration date (supports HTTP 1.0)</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">Age</td>
        <td style="padding:5px 10px;">Duration since the resource was fetched from server</td>
    </tr>
</table>

Cache-Control values can be tweaked to control if a cached result is still valid or stale. For example, the *max-age* value indicates for how many seconds from the moment expressed by the Date header a cached result will be valid.

## Conclusion ##

REST is a language-agnostic style that abstracts over components and allows to build scalable, reusable and relatively lightweight web services. Thinking about it, it seems that REST is very close to an accurate description of the characteristics that made the World Wide Web so popular.

That of course is encouraging developers from all over the world to comply to these very basic ideas, owned by no one but at the same time used by everyone. Fascinating!