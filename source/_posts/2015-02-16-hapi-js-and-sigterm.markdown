---
layout: post
title: "Hapi.js and SIGTERM"
date: 2015-02-16 10:32:42 +0000
comments: true
author: aroyle
categories: [hapijs, microservices, sigterm]
---
When we first stood up our hapi.js apis, we wrote init scripts to start/stop them. Stopping the server, was simply a case of sending SIGKILL (causing the app to immediately exit).

Whilst this is fine for most cases, if we want our apps to be good linux citizens, then they should terminate gracefully. Hapi.js has the handy `server.stop(...)` command (see docs [here](http://hapijs.com/api#serverstopoptions-callback)) which will terminate the server gracefully. It will cause the server to respond to new connections with a 503 (server unavailable), and wait for existing connections to terminate (up to some specified timeout), before stopping the server and allowing the node.js process to exit. Perfect.

This makes our graceful shutdown code really simple:

```javascript
process.on('SIGTERM', function(){
  server.stop({ timeout: 5 * 1000}, function(){
    process.exit(0);
  });
});
```

When we see a SIGTERM, call `server.stop()`, then once the server has stopped, call `process.exit(0)`. Easy peasy.

__Throw a spanner in the works__

Whilst `server.stop()` is really useful, it has the problem that it immediately prevents the server from responding to new requests. In our case, that isn't particularly desirable. We use service-discovery, which means that the graceful termination of our app should run like this:

- SIGTERM
- Unannounce from Service-Discovery
- `server.stop(...)`
- `process.exit(0)`

Ideally we want the unannounce to happen before the server starts rejecting connections, in order to reduce the likelihood that clients will hit a server that is shutting down.

__Plugins to the rescue!__

Thanks to hapi.js's awesome plugin interface ([shameless self promotion](http://t.co/GDw44SETfS)), we can do some magic to make the above possible.

I created a really simple plugin called [hapi-shutdown](https://www.npmjs.com/package/hapi-shutdown) which will handle SIGTERM and then run triggers before calling `server.stop(...)`.

The idea is that it allows us to run the 'unannounce' step, before `server.stop(...)` is called.

__How to use hapi-shutdown__

```javascript
server.register([
  {
    plugin: require('hapi-shutdown'),
    options: {
      serverSpindownTime: 5000 // the timeout passed to server.stop(...)
    }
  }],
  function(err){
    server.start(function(){
 
      server.plugins['hapi-shutdown'].register({
        taskname: 'do stuff',
        task: function(done){ 
          console.log('doing stuff before server.stop is called'); 
          done(); 
        },
        timeout: 2000 // time to wait before forcibly returning
      })
    });
  });
```
 
The plugin exposes a `.register()` function which allows you to register your shutdown tasks. The tasks are named (to prevent multiple registrations), and each task must call the `done()` function. The `timeout` parameter is provided so that a task which never completes won't block the shutdown of the server.
 
 Neat, huh?
 
 __Hooking up unnanounce using hapi-shutdown__
 
We now have a place to register our 'unannounce' task. Our service-discovery code is wrapped in another plugin, which means we can use `server.dependency(...)`.
 
```javascript
// inside the plugin's register function

server.dependency('hapi-shutdown', function(_, cb){
  var err = server.plugins['hapi-shutdown'].register({
    taskname: 'discovery-unannounce',
    task: function(done){
      discovery.unannounce(function(){
        done();
      });
    },
    timeout: 10 * 1000
  });
 
  cb(err);
});
```

`server.dependency(...)` allows us to specify that this plugin relies on another plugin (or list of plugins). If the dependent plugin is not registered before the server starts, then an exception is thrown.

Handily, `server.dependency(...)` also takes a callback function, which is invoked after all the dependencies have been registered, which means that you don't need to worry about ordering inside your `server.register(...)` code.

This allows our unannounce code to be decoupled from the actual business of shutting down the server.
