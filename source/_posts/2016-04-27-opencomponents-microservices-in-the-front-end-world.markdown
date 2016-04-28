---
layout: post
title: "OpenComponents - microservices in the front-end world"
date: 2016-04-27 10:10:00 +0000
comments: true
author: mfigus
categories: [SOA, Microsites, Microservices, OpenComponents, OC] 
---

Many engineers work every day on opentable.com from our offices located in Europe, America, and Asia, pushing changes to production multiple times a day. Usually, this is very hard to achieve, in fact it took years for us to get to this point. [I described in a previous article][1] how we dismantled our monolith in favour of a Microsites architecture. Since the publication of that blog post we have been working on something I believe to be quite unique, called **OpenComponents**.

### Another front-end framework?

OpenComponents is a system to facilitate code sharing, reduce dependencies, and easily approach new features and experiments from the back-end to the front-end. To achieve this, it is based on the concept of using services as interfaces - enabling pages to render partial content that is located, executed and deployed independently.

OpenComponents is not *another SPA JS framework*; it is a set of conventions, patterns and tools to develop and quickly deploy fragments of front-end. In this perspective, it plays nicely with any existing architecture and framework in terms of front-end and back-end. Its purpose is to **serve as delivery mechanism for a more modularised end-result in the front-end**.

OC is been in production for more than a year at OpenTable and it is [fully open-sourced][2].

## Overview

OpenComponents involves two parts:

* The **consumers** are web pages that need fragments of HTML for rendering partial contents. Sometimes they need some content during server-side rendering, somethings when executing code in the browser.
* The **components** are small units of isomorphic code mainly consisting of HTML, Javascript and CSS. They can optionally contain some logic, allowing a server-side Node.js closure to compose a model that is used to render the view. When rendered they are pieces of HTML, ready to be injected in any web page.

The framework consists of three parts:

* The **cli** allows developers to create, develop, test, and publish components.
* The **library** is where the components are stored after the publishing. When components depend on static resources (such as images, CSS files, etc.) these are stored, during packaging and publishing, in a publicly-exposed part of the library that serves as a CDN.
* The **registry** is a REST API that is used to consume components. It is the entity that handles the traffic between the library and the consumers.

In the following example, you can see how a web page looks like when including both a server-side rendered component (*header*) and client-side (still) unrendered component (*advert*):

```html
<!DOCTYPE html>
  ...
  <oc-component href="//oc-registry.com/header/1.X.X" data-rendered="true">
    <a href="/">
      <img src="//cdn.com/oc/header/1.2.3/img/logo.png" />
    </a>
  </oc-component>
  ...
  <p>page content</p>
  <oc-component href="//oc-registry.com/advert/~1.3.5/?type=bottom">
  </oc-component>
  ...
  <script src="//oc-registry/oc-client/client.js"></script>
```

### Getting started

The only prerequisite for creating a component is Node.js:

```sh
$ npm install -g oc
$ mkdir components && cd components
$ oc init my-component
```

Components are folders containing the following files:

<table style="margin-bottom:16px;">
    <tr>
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">File</th>
        <th style="font-weight:bold;padding:5px 10px;border-bottom:1px solid #ccc;">Description</th>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">package.json</td>
        <td style="padding:5px 10px;font-weight: inherit;">A common <a href="https://docs.npmjs.com/files/package.json" target="_blank">node's package.json</a>. An "oc" property contains some additional configuration.</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">view.html</td>
        <td style="padding:5px 10px;font-weight: inherit;">The view containing the markup. Currently Handlebars and Jade view engines are supported. It can contain some CSS under the &lt;style&gt; tag and client-side Javascript under the &lt;script&gt; tag.</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">server.js (optional)</td>
        <td style="padding:5px 10px;font-weight: inherit;">If the component has some logic, including consuming services, this is the entity that will produce the view-model to compile the view.</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">static files (optional)</td>
        <td style="padding:5px 10px;font-weight: inherit;">Images, Javascript, and files that will be referenced in the HTML markup.</td>
    </tr>
    <tr>
        <td style="padding:5px 10px;font-weight:bold;">*</td>
        <td style="padding:5px 10px;font-weight: inherit;">Any other files that will be useful for the development such as tests, docs, etc.</td>
    </tr>
</table>

## Editing, debugging, testing

To start a local test registry using a components' folder as a library with a watcher:
```sh
$ oc dev . 3030
```

To see how the component looks like when consuming it:
```sh
$ oc preview http://localhost:3030/hello-world
```

As soon as you make changes on the component, you will be able to refresh this page and see how it looks. This an example for a component that handles some minimal logic:

{% raw %}
```
<!-- view.html -->
<div>Hello {{ name }}</div>
```
{% endraw %}

```js
// server.js
module.exports.data = function(context, callback){
  callback(null, {
    name: context.params.name || 'John Doe'
  });
};
```

To test this component, we can curl `http://localhost:3030/my-component/?name=Jack`.

### Publishing to a registry

You will need an online registry connected to a library. A component with the same name and version cannot already exist on that registry.

```sh
# just once we create a link between the current folder and a registry endpoint
$ oc registry add http://my-components-registry.mydomain.com

# then, ship it
$ oc publish my-component/
```

Now, it should be available at `http://my-components-registry.mydomain.com/my-component`.

## Consuming components

From a consumer's perspective, a component is an HTML fragment. You can render components just on the client-side, just on the server-side, or use the client-side rendering as failover strategy for when the server-side rendering fails (for example because the registry is not responding quickly or it is down).

You don't need Node.js to consume components on the server-side. The registry can provide rendered components so that you can consume them using any tech stack.

When published, components are immutable and semantic versioned. The registry allows consumers to get any version of the component: the latest patch, or minor version, etc. For instance, `http://registry.com/component` serves the latest version, and `http://registry.com/component/^1.2.5` serves the most recent major version for v1.

### Client-side rendering

To make this happen, a components' registry has to be publicly available.
```html
<!DOCTYPE html>
  ...
  <oc-component href="//my-components-registry.mydomain.com/hello-world/1.X.X"></oc-component>
  ...
  <script src="//my-components-registry.mydomain.com/oc-client/client.js" />
```

### Server-side rendering

You can get rendered components via the registry REST API.
```sh
curl http://my-components-registry.mydomain.com/hello-world

{
  "href": "https://my-components-registry.mydomain.com/hello-world",
  "version": "1.0.0",
  "requestVersion": "",
  "html": "<oc-component href=\"https://my-components-registry.mydomain.com/hello-world\" data-hash=\"cad2a9671257d5033d2abfd739b1660993021d02\" data-name=\"hello-world\" data-rendered=\"true\" data-version=\"1.0.13\">Hello John doe!</oc-component>",
  "type": "oc-component",
  "renderMode": "rendered"
}
```

Nevertheless, for improving caching and response size, when doing browser rendering, or using the `node.js` client or any language capable of executing server-side Javascript the request will look more like:
```sh
 curl http://my-components-registry.mydomain.com/hello-world/~1.0.0 -H Accept:application/vnd.oc.unrendered+json

{
  "href": "https://my-components-registry.mydomain.com/hello-world/~1.0.0",
  "name": "hello-world",
  "version": "1.0.0",
  "requestVersion": "~1.0.0",
  "data": {
    "name": "John doe"
  },
  "template": {
    "src": "https://s3.amazonaws.com/your-s3-bucket/components/hello-world/1.0.0/template.js",
    "type": "handlebars",
    "key": "cad2a9671257d5033d2abfd739b1660993021d02"
  },
  "type": "oc-component",
  "renderMode": "unrendered"
}
```

Making a similar request it is possible to get the compiled view's url + the view-model as data. This is useful for caching the compiled view (taking advantage of components' immutability).

## Setup a registry

The registry is a Node.js Express app that serves the components. It just needs an S3 account to be used as library.

First, create a dir and install OC:
```sh
$ mkdir oc-registry && cd oc-registry
$ npm init
$ npm install oc --save
$ touch index.js
```

This is how `index.js` will look like:

```js
var oc = require('oc');

var configuration = {
  verbosity: 0,
  baseUrl: 'https://my-components-registry.mydomain.com/',
  port: 3000,
  tempDir: './temp/',
  refreshInterval: 600,
  pollingInterval: 5,
  s3: {
    key: 'your-s3-key',
    secret: 'your-s3-secret',
    bucket: 'your-s3-bucket',
    region: 'your-s3-region',
    path: '//s3.amazonaws.com/your-s3-bucket/',
    componentsDir: 'components'
  },
  env: { name: 'production' }
};

var registry = new oc.Registry(configuration);

registry.start(function(err, app){
  if(err){
    console.log('Registry not started: ', err);
    process.exit(1);
  }
});
```

## Conclusions

After more than a year in production, OC is still evolving. These are some of the most powerful features:

* It **enables developers to create and publish components very easily**. None of the operations need any infrastructural work as the framework takes care, when packaging, of making each component *production-ready*.
* It is **framework agnostic**. Microsites written in *C#*, *Node* and *Ruby* consume components on the server-side via the API. In the front-end, it is great for delivering neutral pieces of HTML but works well for Angular components and React views too.
* It enables **granular ownership**. Many teams can own components and they all are discoverable via the same service.
* Isomorphism is good for **performance**. It enables consumers to render things on the server-side when needed (mobile apps, SEO) and defer to the client-side contents that are not required on the first load (third-party widgets, adverts, SPA fragments).
* Isomorphism is good for **robustness**. When something is going bad on the server-side (the registry is erroring or slow) it is possible to use client-side rendering as a fail-over mechanism. The Node.js client does this by default.
* It is a good approach for **experimentation**. People can work closely to the business to create widgets that are capable of both getting data from back-end services and deliver them via rich UIs. We very often had teams that were able to create and instrument tests created via OC in less then 24 hours.
* Semver and auto-generated documentation **enforce clear contracts**. Consumers can pick the version they want and component owners can keep clear what the contract is.
* A more componentised front-end leads to write **more easily destroyable code**. As opposite of writing highly maintainable code, this approach promotes small iterations on very small, easily readable and testable units of code. In this perspective, recreating something from scratch is perfectly acceptable and recommended, as there is almost zero cost for a developer to start a new project and the infrastructure in place makes maintainance and deprecation as easy as a couple of clicks. 

If you wish to try or know more about OpenComponents, visit [OC's github page][2] or have a look at [some component examples][3]. If you would give us some feedback, asks us question, or contribute to the project get in touch via the [gitter chat][4] or via [e-mail][5]. We would love to hear your thoughts about this project.

[1]: http://tech.opentable.co.uk/blog/2015/02/09/dismantling-the-monolith-microsites-at-opentable/
[2]: https://github.com/opentable/oc
[3]: https://github.com/matteofigus/oc-components-examples
[4]: https://gitter.im/opentable/oc
[5]: mailto:oc@opentable.com