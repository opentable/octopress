---
layout: post
title: "On Strongly Typed Logging"
date: 2015-01-23 13:13:13 +0000
author: mbazydlo
comments: true
categories: [Logs, Kibana, ElasticSearch, Architecture]
---

Logging is a crucial element of monitoring highly available systems. It allows not only to find out about errors but also quickly identify their cause. Logs are often used to generate metrics that help business and engineering make informative decisions on future development directions. 

At OpenTable we have a central logging infrastructure, that means all logs are stored in the same shared database (ElasticSearch for us). And everybody can access any logs they want without having very specialized knowledge (thanks Kibana!).

ElasticSearch, though living in a NoSQL world, is not actually a schema-free database. Sure, you do not need to provide schema to it but instead ES will infer schema for you from documents you send to it. This is very similar to type inference you can find in many programming languages. You do not need to specify type of field, but if you later on try to assign inappropriate value to it you will get an exception.

This trait of our database goes all the way to the root of our logging system design. Let me explain why I say that we have 'strongly typed logs'.

In The Beginning There Was String
---------------------------------

Before centralization we just logged a single message along with its importance. In code it looked something like:
```
logger.ERROR(“Kaboom!”)
```
which resulted in logline on disk having timestamp, severity and message.
```
{2014-10-10T07:33:04Z [ERROR] Kaboom!}
```
That worked pretty well. As time passed we often started making log messages more generic to hold relevant data:
```
logger.INFO(string.Format(“Received {0} from {1}. Status: {2}. Took {3}”, httpMethod, sourceIp, statusCode, durationms));
```

When we decided to centralize logs we moved the same logs from local disk to a central database. Suddenly things that used to live on single server in a file called 'application.log' become part of one huge lump of data. Instead of easing access to logs they were really hard to filter, without even speaking about aggregation, or any simple form of operations to find the source of the problem. ElasticSearch is really good at free text searching, but frankly speaking FTS is never as precise as a good filter.

Then There Was Dictionary Of Strings
------------------------------------

Wherever there is problem there is also a solution. So we changed the way our logging works. We created a custom logger and started sending logs more like documents than single string.
```
customLogger.send(‘info’, new Dictionary<string, string> {
{‘method’, httpMethod.ToString()},
{‘sourceIp’, sourceIp.ToString()},
{‘statusCode’, statusCode.ToString()},
{‘duration’, durationms.ToString()},
{‘requestId’, requestId.ToString()},
{‘service’, ‘myservice’}
{‘message’, string.Format(“Received {0} from {1}. Status: {2}. Took {3}”, httpMethod, sourceIp, statusCode, durationms)}
}
```

**That helped a lot.**

You might wonder why we serialized everything to string? The answer is ElasticSearch mapping as I described above. Mapping, once it is inferred, cannot be changed. So from time to time we used to have conflicts (e.g. one application logging requestId as number, other as guid). Those conflicts were costly - logs were lost - so we simply applied the simplest solution available and serialized everything.

Now filtering was working fine. We were even able to group requests based on a single field and count them. You cannot imagine how useful it is to simply count the different status codes returned by a service. Also you may have noticed we introduced some extra fields like 'service' which helped us group logs coming from a single application. We did the same with hostname etc.

With this easy success our appetite has grown and we wanted to log more. And being lazy programmers we found a way to do it quickly so our logs often included just relevant objects.
```
customLogger.log(‘info’, request)
customLogger.log(‘error’, exception)
```

Our custom logging library did all the serialization for us. This worked really well. Now we were actually logging whole things that mattered without having to worry about serialization at all. What's even better, whenever the object in question changed (e.g. a new field was added to request), it was automagically logged.

However one thing was still missing. We really wanted to see performance of our application in real time or do range queries (e.g. "show me all requests that have 5xx status code"). We also were aware that both ES and Kibana can deliver it but our logging is not yet good enough.

Strongly Typed Logs
-------------------

So we looked at our logging and infrastructure and at what needs to be done to allow different types of fields to live in ElasticSearch. And you can imagine that it was a pretty simple fix; we just started using types. Each log format was assigned its own type. This type was then used by ElasticSearch to put different logs into separate buckets with separate mapping. The type is equivalent in meaning to classes in OO programming. If we take this comparison further then each log entry would be an object in OO programming. ElasticSearch supports searches across multiple types, which is very convenient when you don't know what you are looking for. On the other hand, when you know, you can limit your query to single type and take advantage of fields types.

It was a big application change as we needed to completely change our transport mechanism to LogStash. We started with Gelf and switched to Redis, which allowed us to better control format of our logs. 

We also agreed on a first standard. The standard defined that type will consist of three parts:
```
<serviceName>-<logName>-<version>
```
This ensures that each team can use any logs they want to (thus serviceName). Each log will have its own format (thus logName). But they can also change in the future (thus version). One little word of caution, ES doesn't like dots in type name, so don't use them.

So our logs look now like this:
```
customLogger.log(new RequestLog {
Request = request,
Headers = headers,
Status = status})
```

RequestLog is responsible for providing valid type to the logging library.

With sending serialized objects as logs and assigning each class unique type our logs have become strongly typed.

We are already couple steps further down the path of improving our logs. We standardized some common fields and logtypes. That, however, is a completely different tale. ​
