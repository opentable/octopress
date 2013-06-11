---
layout: post
title: "nLocalGeoCoder"
date: 2013-06-07 11:59
comments: true
author: rhopton
categories: [OSS, .Net, C#, Ruby, collaboration]
---

## History ##

With OpenTable having engineering teams spread across multiple offices it's important for us to maintain open email dialogue about new products us or our teams have created, new tools we've discovered or problem solving approaches that have helped us achieve our goals.  Recently in one of these emails Aish introduced the team to a new open source ruby implementation of reverse geocode lookup for latitude and longitude he'd written called [local-geocoder](https://github.com/aishfenton/local-geocoder).  With an interest in understanding how this worked, to learn a bit of ruby, to make this project accessible to .net developers and just to see how long it would take I decided to port it to C# and .net.

## How reverse geocoding works ##

Latitude and longitude geographical coordinates are great but 37.819548,-122.479046 doesn't really mean much to me. Knowing this is in the San Francisco bay area is much more useful interpretation.

That's where reverse geocoding comes in.  Normally geocoding tries to locate geographical coordinates from other data like postal (zip) codes or street level addresses.  Reverse geocoding does the opposite and can, given enough lookup data, be very precise.

There are a number of online reverse geocoding providers, like Google, who can perform this for you however there are normally usage limits or costs for using them.  To add to this the latency of these service can slow your logic down.  Wouldn't it be nice if this could be done locally at high speed and in memory.

## Using nLocalGeocoder ##

It's really easy to use, just new up a Geocoder and you're off...

    var geocoder = new Geocoder();
    var result = geocoder.ReverseGeocode(-122.479046M, 37.819548M);

The result variable now holds an instance of the Result struct.  This type has the following properties:-

* Country *- Id and Name of the country*

and for USA only (because that's all the data in our [GeoJSON](http://www.geojson.org) data)

* AdministrativeArea1 *- Id and Name of the state*
* AdministrativeArea2 *- Id and Name of the county*

The code is available for all to use and is available on our [github repo](https://github.com/opentable/nLocalGeocoder)

It's as simple as that really!
