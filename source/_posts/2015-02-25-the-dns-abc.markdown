---
layout: post
title: "The DNS ABC"
date: 2015-02-24 18:00
author: fmaffei
comments: true
categories: [Engineering, DNS, Theory]
---

## Introduction to DNS ##

Before joining OpenTable I was looking for a software engineer job and I've done my fair share of interviews. A question that has popped out a lot, and when I say a lot I mean *always*, is:

*Could you tell me what happens when I type an URL in a web browser on my computer and press enter?*

Of course the possible answers could range from "MMMHHH, wellll, I'm not sure where to start..." to a whole book on computer networks.

After a number of attempts to answer briefly and correctly, I've concluded that mentioning **DNS** can make a reasonable start.

Let's think about it. When we type the address of the resource we want to browse, we use the alphabet, right? With letters and names easily readable and retainable by a human being.

But a machine needs an **IP address** to recognize another machine connected to a network. An IP address is numerical, for example 192.168.0.1. Less readable, it seems.

And here is where DNS comes to play. DNS stands for **Domain Name System**, and that represents exactly what it is: a system that translates **domain names** (e.g *www.opentable.co.uk*), into IP addresses. I think of it as a phone book. It is queried with a domain name and, after a lookup, returns an IP.

How does the magic happen? Let's look into it.

## The ABC ##

### Some definitions ###

So we can define a domain name as a string composed by one or more parts, called **labels**, concatenated and delimited by dots with a **hierarchical** logic.

In the case of www.opentable.co.uk, for instance, we have four labels:

- *uk* is the **top-level** domain. This should sound familiar. Famous top-level domains are also *.net*, *.org*, *.uk*, *.it*, *.gov*, etc.

- *co* is the **second level** domain, which in this case specifies the commercial nature of the company.

- Hierarchy goes from right to left, so then we can say that *opentable* is a **subdomain** of *co*. And so on.

- A name that can be associated to a specific machine connected to a network with an IP address is called **hostname**. Let's say it's the leftmost label in the domain name.

### Questions that pop out at this point ###

Q: So all the host names reachable via a specific domain have a specific IP address! There must be BILLIONS of them. How do we make sure everyone is unique?

A: There are entities that have the authority to assign and register names under one or more top-level domain, called **registrars**. The registered name then becomes part of a central database known as the *whois database*.

Q: Now, how do we retrieve this infamous IP address by just knowing a domain name? Who can **resolve** this request?

A: Well, the domain name is resolved into an IP address by querying **authoritative name servers**. These machines are the endpoints of a database that can map domain names to IPs. The authoritative name servers of the top level domain are also called [**root level servers**](https://www.iana.org/domains/root/servers).

Q: OK, but wait a second. How in the heavens does my machine know the address of the name server to query? I thought I just entered an address in the browser!

A: Every client machine has a default **DNS resolver**, which is responsible of initiating the sequence of queries that will ultimately lead to the resolution.
It is very important to note that the system's DNS setting can be also overridden by the [**Internet Service Provider**](http://www.ispreview.co.uk/list.shtml) (ISP) settings, so the DNS lookup process can be very OS-specific and ISP-specific. This would deserve a whole post apart.

 
### How to resolve an address (ideally) ###

Resolving an address via DNS is also called **lookup**, and it is a recursive process. Now that we know the purpose of DNS, and the concepts involved in the process, we can dig a little deeper into its basic mechanism, which is roughly:

1. The resolver has knowledge of the addresses of root name servers, from where the search can start.

2. The root name server will return a name server which is authoritative for the top-level domain.

3. This server will give the address of the name server authoritative for the second level domain.

4. If the hostname is resolved, an IP address is returned. Otherwise step 3) is repeated for all the labels of the domain name in sequence, until a result is reached.

I made a diagram that shows that.

<img src="http://federicomaffei.github.io/public/images/dnsbasic.jpg" class="center-image"></img>

### Real life problems ###

The mechanism explained above is great, but if applied in real life application, it will lead to a bottleneck. Every lookup would involve root servers and authoritative servers, which would be hit by gazillions of queries every day, putting a huge burden on the system since the start.

To solve this, of course a [**caching**](http://blog.catchpoint.com/2014/07/15/world-dns-cache-king/) system comes to help. Yes, DNS allows and encourages caching. This way another class of DNS servers comes into play, the **recursive name servers**. They can perform recursive lookups and cache results, returning them when queried even if they don't have the authority to generate the results themselves.

Caching recursive DNS server are usually managed by Internet Service Providers, and are able to resolve addresses without waiting for the "authorities". This means that a query will rarely have to hit the root name servers, since there is a very high likelihood that the hostname/IP request is already cached by one of the delegated DNS servers that are called by recursion.

We could say that in reality a root server will be hit as a last resort to track down an authoritative server for a given domain.

The amount of time for which a lookup result is stored on a server is called [**time-to-live (TTL)**](http://en.wikipedia.org/wiki/Time_to_live) and can vary with the configuration.

One side effect of the heavy caching that involves the DNS is that when a new domain is registered, or there is a change in any domain-related settings, there will be a time lag for the propagation of it to all the cached results.

It is noteworthy that cached DNS results from your browsing could be stored in your router, or somewhere within you browser memory as well. These IP addresses seem to be everywhere these days!

## Conclusion ##

I barely scratched the surface of the Domain Name System topic, and that alone took a good day of research and writing.

So I decided to avoid making this post too long, so that beginners that are going to find it will profit, and be encouraged to research on these key concepts. This will allow me to decide which part of DNS is worth more digging, and maybe write a sequel. Stay tuned!