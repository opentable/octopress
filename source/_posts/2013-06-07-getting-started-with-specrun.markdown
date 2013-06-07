---
layout: post
title: "Getting Started With SpecRun"
date: 2013-06-07 11:33
comments: true
author: Mark Barrett
categories: [specrun, acceptance tests, automation, CI]
---
## First some background ##

We recently switched from writing automated acceptance from Cucumber to SpecFlow... this is no slight on Cucumber it's just that had a lot of C# developers who wanted to get closer to writing acceptance tests. Worth adding that SpecFlow has also come a long way as a .Net port of Cucumber and is pretty much like for like now.

## Why should I bother with SpecRun? ##

Initially we ran our entire unit, integration and acceptance tests via nUnit. Pretty much industry standard but we felt nUnit wasn't really a good tool to run acceptance tests - yes it'll do the job but we were looking for better performance, quicker failure feedback and more comprehensive reporting. If you want details on SpecRun vs. nUnit Gasper has a [great blog post](http://gasparnagy.com/2011/09/specrun-because-integration-tests-are-not-unit-tests/).

<salespitch>SpecRun itself is free to use although there is a random delay when running acceptance locally, setting up SpecRun on a CI environment is totally free and does not include the same delay. Definitely worth trying out and you can purchase a licence later if you like what it offers.</salespitch>

## Installing SpecRun ##

If you are already using SpecFlow with nUnit the migration to SpecRun is really simple - [this video](http://www.youtube.com/watch?v=c2ge90BWeI0) shows you how to setup the test runner but I found myself having to watch it too many times. This post is an attempt at recording the steps should we roll out SpecRun for another project.  

I'm assuming you're running Visual Studio and are familiar with Nuget packages. I'll break it down so I don't miss anything:

1.	In VS, select your Acceptance test project and get the Nuget package down for SpecRun: `install-package SpecRun`.
2.	You'll notice Nuget automatically adds configuration to your app.config so it's safe to remove the nUnit provider setting (this is to enable you to pick and choose your test runner but we prefer to only use SpecRun).
3.	Open the Default.srprofile file and we normally delete any commented settings here.
4.	Still inside Default.srprofile add the properties for projectName and projectId. The projectName is what you see in VS the projectId can be found by opening the acceptance .proj file and taking the projectGuid.
5.	Setup the execution properties - this really depends on what you want to get out of running the tool - what retry count you want, whether to run on multiple threads, etc. Here are the values we normally use:

`<Execution retryFor="None" stopAfterFailures="100" testThreadCount="1" testSchedulingMode="Sequential" apartmentState="STA"/>`

6.	We did tweak the SpecRun .cmd file used to run acceptance via command line - [copy this file](https://dl.dropboxusercontent.com/u/8835075/runacceptance.cmd) to your project root, you may need to tweak some names and paths.

Once you've gone through those steps you should be able to browse to your project root, type **runacceptance.cmd tag_to_run** and it'll run your acceptance tests tagged **@tag_to_run**  (NOTE: you don't need to specify the @ symbol).