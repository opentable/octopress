---
layout: post
title: "Introducing Hobknob: Feature toggling with etcd"
date: 2014-09-04 20:09:52 +0100
comments: true
author: rtomlinson
categories: [Hobknob]
---
The ability to dynamically turn features on/off in software without the need to redeploy code is extremely beneficial. Whether you are trialing a new feature or using branch by abstraction to avoid creating feature branches, the use of feature toggles can aid continuous delivery and provide a mechanism to reduce mean time to resolution when an issue occurs.

With a relatively large engineering department with multiple teams spread across the US and UK the need to manage feature toggles has evolved to the point whereby individual teams have developed their own implementations. Most of these are simple config files.

We decided to unify this effort by providing a central place to store feature toggles, provide a dashboard to be able to turn these toggles on/off and provide language specific clients to integrate into our software components.

The results of this was [Hobknob](https://github.com/opentable/hobknob).

## Why etcd?

We made the decision to use [etcd](https://github.com/coreos/etcd). Etcd is "a highly-available key value store for shared configuration" ([https://github.com/coreos/etcd#etcd](https://github.com/coreos/etcd#etcd)). It provides a HTTP API to store and retrieve data. This is what makes it perfect for a feature toggling solution used by multiple components. It means that we didn't have to write an intermediate API on top of a data store for consumers.

So, for example, to store a feature toggle in etcd:

```
curl -L http://127.0.0.1:4001/v2/keys/v1/toggles/restaurant-api/testtoggle -XPUT -d value="true"
```

To retrieve a feature toggle:

```
curl -L http://127.0.0.1:4001/v2/keys/v1/toggles/restaurant-api/testtoggle
```

## The Hobknob Clients

To aid adoption we created, and open sourced, several hobknob clients in multiple languages:

- NodeJs (NPM) - [https://github.com/opentable/hobknob-client-nodejs](https://github.com/opentable/hobknob-client-nodejs)
- .NET (Nuget) - [https://github.com/opentable/hobknob-client-net](https://github.com/opentable/hobknob-client-net)
- Go - [https://github.com/opentable/hobknob-client-go](https://github.com/opentable/hobknob-client-go)
- Java (Maven) - [https://github.com/opentable/hobknob-client-java](https://github.com/opentable/hobknob-client-java)

The clients all store a configurable in-memory cache that is periodically updated on a polling interval. They are all read-only and updates only occur on the dashboard where they can be audited.

We decided to create a simple [demo application](https://github.com/opentable/hobknob-demo) to show off how easy it is to use Hobknob in your applications. In order to try the demo you will need to start up Hobknob (see instructions below). The demo app uses the NodeJS client which is as simple as:

```
var client = new Client("hobknob-demo", {
  etcdHost: etcdHost,
  etcdPort: etcdPort,
  cacheIntervalMs: 5000
});
```

In the route definition it uses the client to request the toggle named *show-first-and-last-name-input* and passes the toggle value through to the view:

```
var result = hobknobClient.getOrDefault('show-first-and-last-name-input', true);
res.render('server', {
       			page: 'server',
        		useTwoFieldNameInput: value
      		});
```

The view then uses the value to decide whether to display one or two textboxes on the page:

```
if useTwoFieldNameInput
  input.form-control.demo-input-small(type='text', placeholder='First name', name='firstname')
  input.form-control.demo-input-small(type='text', placeholder='Last name', name='lastname')
else
  input.form-control.demo-input-large(type='text', placeholder='Full name', name='fullname')
```

## The Hobknob Dashboard

Hobknob is a NodeJS/AngularJS app. If you want to play with Hobknob the simplest way to get started is to use Vagrant. If you don't have it installed then get it from [http://www.vagrantup.com/](http://www.vagrantup.com/).

```
git clone https://github.com/opentable/hobknob
cd hobknob
vagrant up
```

You should now be able to open the dashboard on http://127.0.0.1:3006

![Hobknob dashboard](https://github.com/opentable/hobknob/raw/master/screenshots/dashboard.png)

All actions in the dashboard are audited. So when you create or update a toggle by turning it on/off an audit is written for that toggle. Clicking on a toggle in the dashboard takes you to the audit view:

![Hobknob audit](https://github.com/opentable/hobknob/raw/master/screenshots/audit.png)

### Authentication

By default Hobknob ships with authentication disabled. As a result all auditing will be recorded as "Anonymous". Currently, we only support Google OAuth. To enable this follow the instructions [here](https://github.com/opentable/hobknob/blob/master/README.md#configuring-authentication)

### Session Storage

By default Hobknob ships using in-memory session storage. You don't want to use this when you have a load balanced infrastructure. Hobknob supports both redis and etcd itself as a session store. To use either of these simply npm install the relevent connect middleware ([connect-redis](https://github.com/visionmedia/connect-redis) or [connect-etcd](https://github.com/opentable/connect-etcd)). To learn more follow the instructions [here](https://github.com/opentable/hobknob/blob/master/README.md#configuring-session)



