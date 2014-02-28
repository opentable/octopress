---
layout: post
title: "Benchmarking APIs - why it’s important, and how"
date: 2014-02-28 09:00
comments: true
author: mfigus
categories: [Benchmarks, SOA, Node.js, API, REST, Performance, Continuous delivery] 
---

Since I joined OpenTable I’ve been experimenting with performance monitoring, specifically on web services. One of the projects my team is responsible for is a REST API that provides UI elements for HTML5 applications, shaped as HTML snippets and static resources. Our consumers are websites deployed in multiple parts of the world, so our service needs to be fast and reliable.

The why
-------
A couple of weeks after joining the company I decided, as part of my [innovation time][6], to rebuild the core of a .NET WebApi project in node.js in order to have a working prototype that could do exactly the same job as the original one, and could help me to observe how the two applications could react with similar volumes of traffic. After managing to make the two apis run on two clean VMs with the same configuration, I wrote a little node.js script to start performing some requests and test the response times. After seeing the results I thought that something was going wrong:

```sh
.NET/route1 x 9.16 ops/sec ±12.71% (17 runs sampled)
nodeJS/route1 x 106 ops/sec ±1.19% (180 runs sampled)
======================================
Fastest is nodeJS/route1
 
.NET/route2 x 10.70 ops/sec ±8.54% (19 runs sampled)
nodeJS/route2 x 118 ops/sec ±1.22% (175 runs sampled)
======================================
Fastest is nodeJS/route2
 
======================================
Fastest Service is nodeJS
```

After trying to microbenchmark different layers of the software, I found the problem. On the .NET side I was reading a file synchronously, for every request; the file system’s library used with the node.js app, instead, was automatically caching the reads as default. After setting up a basic caching mechanism in the .NET app and running my script again the node.js API was only 1.4 times faster. After finding and solving that issue I thought how badly the application could have handled concurrency when deployed in production, even if it was heavily unit tested, the specs were well defined, and it was built using all the best techniques we all love.

As developers we rely on technologies that, with a minimum effort, can guarantee some pretty decent results in terms of performance. Modern web frameworks handle concurrency and thread management without requiring much plumbing code. Sophisticated and relatively cheap cloud services help us monitor our applications, providing dashboards, reports and alerting systems. Deploying on the cloud we can run our services and even auto-scale them depending on how much power we need. Even with this tools we must still own the responsibility of writing good quality code, testing it properly, and deploying fast possible in order to optimise the delivery process of our products. 

But what about performance? I mean, what about the relationship between the code we write every day, and the way we impact overall performance? Are we sure that we are not deploying to production something that is degrading our services’ performance?

The how
-------
Talking about the ‘why’ could be relatively easy, but the ‘how’ is a controversial topic. In my experience there are three important steps to any dish. First, we need the right tools to manipulate the ingredients. I tried many different tools but I couldn't find a good fit for all my benchmarking requirements. It always makes sense to start with something to get you going but after a while it is important to find what’s the best for you, your team, and your project.

Then, you start cooking: personally, the number of things I’ve learned by just starting to benchmark some services is incredible. Nevertheless, as with every time we talk about metrics, it is key to know what is important about the data we are analysing, recognise the false positives/negatives and be aware of vanity metrics that could emphasize something irrelevant, or, more importantly, hide something significant.

The last step is simple: react and persist. If you discover something relevant, you can do something to improve the quality of your software.  With the right tools you can write some benchmark tests to target different layers of your software and execute them each and every time you contribute to that repository.  Doing this helps you keep your system performance under control which is really valuable. 

The how, for me
---------------
When I found that little bug in the application (and it wasn’t actually a bug in the way we usually define them, as it wasn’t breaking any test or any software’s feature), I decided to spend some time to make my benchmark script better, in order to support different HTTP verbs, HTTPS, and a few things I needed to test all the routes of the API in a easy way. The goal was to wrap my little script as a [grunt.js][1] module, (we use Teamcity as a CI platform and we already use grunt to run various tasks during our release process). I wanted to run this benchmarks externally to avoid interfering with the performance of the application, and to have a configuration-based simple-to-use tool.

So after some refactoring I started working on [api-benchmark][2] and its grunt wrapper [grunt-api-benchmark][3], in order to make performance testing part of our continuous delivery process. A couple of days later my team was using it to run benchmark tests on our pre-prod environments against our APIs, running some hundreds of requests on each route every time we made a single commit to Github. What I managed to do was to break the build if response times were not good enough (stopping the production deployment), and producing a tiny report with some graphs, in order to have something useful to observe and eventually collect. Now, a couple of months later, a lot of functionality has been added and other teams are using it with success. 

In case of RESTful services, it is possible to make series of requests to test response times, find peaks and classify errors; it is possible to perform concurrent calls to see how many parallel requests your service can handle (when deployed in single boxes, or when load balanced and globalised); and every time grunt runs everything is saved and plotted to readable and shareable graphs, so the knowledge can be shared between people that belong to different backgrounds.

{% img center /images/posts/api_benchmark.png %}

A lot of other features are still under development, including support for SOAP services and historical analysis (compare results from previous benchmarks and create historical graphs to represent the evolution of your software).

How it works & how to use it
----------------------------
The way it works is simple. A configuration file contains the list of all the routes of the API. For each route it is possible to set different parameters such as headers, methods, expected status code, and expected response times. Other options that can be set such as the minimum number of samples, the maximum time for collecting the results, the number of concurrent requests, etc. It should be something like:

```json
{
  "service": {
    "My api": "http://localhost:3007/api/"
  },
  "endpoints": {
    "simpleRoute": "v1/getJson",
    "postRoute": {
      "route": "v1/postJson",
      "method": "post",
      "data": {
        "test": true,
        "someData": "someStrings"
      },
      "expectedStatusCode": 200
    },
    "deleteRoute": {
      "route": "v1/deleteMe?test=true",
      "method": "delete",
      "maxMean": 0.06,
      "maxSingleMean": 0.003
    }
  },
  "options": {
    "minSamples": 1000,
    "runMode": "parallel",
    "maxConcurrentRequests": 20,
    "debug": true,
    "stopOnError": false
  }
}
```

Then it is possible to include the script in a project that is written in any language and runs on any platform. The only requirement is to [install node.js][4] on that machine. If the project doesn’t have a package.json file in the root of your project, it’s as easy as doing:

```sh
$ npm init
```

Once this is complete, include and install grunt-api-benchmark as a dependency (if you are not on Windows, you may want to sudo it depending on how you’ve installed node.js):

```sh
$ npm install grunt-api-benchmark --save-dev
```

The last thing to do is to create a task inside your Gruntfile.js. Create one if you already don’t have one, and then add the ‘api_benchmark’ task in order to have something like this:

```js
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    api_benchmark: {
      myApi: {
        options: {
          output: 'output_folder'
        },
        files: {
          'report.html': 'config.json',
          'export.json': 'config.json'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-api-benchmark');
  grunt.registerTask('benchmark', ['api_benchmark']);
};
```

Where “generated” is the output folder, “config.json” is your configuration file, and “report.html” (or “export.json”) is the output’s filename. To run it just:

```sh
$ grunt benchmark
```

If you use TravisCI, TeamCity, or any other CI platform, all you’ll have to do is to make it run after being sure the dependencies are resolved:

```sh
$ npm install
```

Let’s benchmark - some lessons learned
--------------------------------------

I think this is the most important part of the whole process, however I don’t think there are any general rules that are applicable for every context. I believe that after testing and stressing your system you will find out what matters to you and to your business. Nevertheless, I want to share some of the lessons I’ve learned.

First, set-up everything correctly.

* Benchmarks need to run always on the same machine, same agent, and same configuration to be reliable and comparable.
* The network should be tested to be sure there aren’t any particular limits that would affect the benchmarks. It should be tested each time before running any benchmarks and could include things like bandwidth, host name correctness, and OS limitations.
* Don’t run the tests from the same machine that hosts the application. Run it from the outside, and if you deploy in different regions, keep that in mind when you look at the results.

When you benchmark, remember that stress and performance are two different things.

* You should test both to learn about performance but also your limits, in order to have an idea on how to scale your application or how to fix it when necessary.
* 10 seconds is not enough. 1 minute is nice, 5 is better.
* One route is not enough. Testing all the routes allow us to see the difference between different response lengths.
* Sometimes your application needs a warm-up, especially if you test it after a deployment. Set up a script to do that or set a proper time-out to be sure you are retrieving some valuable numbers back.
* Don't benchmark the live production environment. Your results are affected by too many variables. If possible, set-up a staging environment with exactly the same configuration to run benchmarks.

If necessary, adapt your API to be more testable through some very basic design patterns.

* Performance could depend on synchronous calls to third-party APIs or databases. Ideally routes should have an optional parameter to mock external dependencies so we should test that as well.
* Ensure that changes to data or the operating environment are not persisted after the benchmarks complete. This is important to ensure no side effects on subsequent runs and will allow you to  benchmark production boxes if needed (after the deployment and obviously before directing any traffic to them).

Last but not least, let’s analyse the data

* Averages are not enough, peaks are important, investigate them.
* When something unexpected happens, try to reproduce it in order to fix it. 
* If wildly different numbers come up every time you run the tests, your API is depending on too many unpredictable events. Try to fix it. Try to run benchmarks locally and microbenchmark your software until you find the element that is causing the unpredictability. Then, fix it or find a way to mock it if you have no other option.
* Numbers should be readable and shareable by everyone. Find a tool that dashboards your results and easily allow you to share that data.

‘benchmarking’ != ‘monitoring’;
-------------------------------
Benchmarking doesn’t equal and doesn’t replace monitoring. Once you start having an extensive knowledge about your system’s performance, you can find useful and easy to establish correlations between your benchmarks and your monitoring metrics. Depending on the scale of your system, it could be something very important.

Conclusions
-----------
I believe that take care about performances is our responsibility, as developers. We can and should do more, and I hope this subject will gain more interest. In the meanwhile, if [api-benchmark][2] sounds interesting for you and you are interested in trying it or contributing (it is totally open-source), don’t hesitate to [get in touch with me][5].


[1]: http://www.gruntjs.com
[2]: https://github.com/matteofigus/api-benchmark
[3]: https://github.com/matteofigus/grunt-api-benchmark
[4]: http://www.nodejs.org
[5]: http://www.twitter.com/matteofigus
[6]: http://tech.toptable.co.uk/blog/2014/02/06/20-percent-time/