---
layout: post
title: "Grunt your deployments too"
date: 2013-08-08 15:27
comments: true
categories: 
---
iWe've been using [Grunt][1] as a build tool for our nodejs apps, and it's brilliant. It lints, it configures, it minifies, it tests, it packages, and if you find the right module, it can give you a reach-around too.

As we move towards getting our first node app into production, we were looking at ways to deploy it. First we thought of [Capistrano][2].

___Capistrano___ is a fully featured deployment framework written in ruby and levering rake style tasks. It's extremely powerful and very robust, plus there is a [gem for node deployments][3]. Alas, it was not to be. After half a day of tail chasing and hoop jumping, it occurred to me that there must be an easier way. Capistrano was encouraging me to make my project fit their template, rather than allowing me to configure the deployment to match my project. When I dug down into the Capistrano source, I found that it was just using ssh and sftp to copy files and run remote commands.

___Grunt___ has been great so far, so I started looking at deploying directly through grunt. We would be deploying to Ubuntu server boxes, so the only tools necessary are ssh and sftp.

There are Grunt modules for nearly [everything][4] (linting, minifying, testing, waiting, packaging, shell-exec'ing, tagging, etc.), and rather predictably, sshing (with sftp).

[Grunt-ssh][5] provides tasks for executing remote ssh commands, and for copying files using ssh. Let's dive into some code.

___SSH commands___

This is going to go over some old ground (available on the Grunt-ssh [readme][5]), but we can build up the pretty quick.

This is the basic config for executing ssh commands from your Gruntfile:
```
module.exports = function(grunt) {
  grunt.initConfig({
    sshexec: {
      uptime: {
        command: "uptime",
        options: {
          host: "127.0.0.1",
          port: 22
          username: "myuser",
          password: "mypass"
        }
      }
    }  
  });

  // Load the plugin that provides the "sshexec" task.
  grunt.loadNpmTasks('grunt-ssh');

  // Default task.
  grunt.registerTask('default', ['sshexec:uptime']);

};
```

We've registered a command, which we can invoke with:
```
grunt sshexec:uptime
```

The Grunt-ssh module also provides the ability to specify multiple host configurations (shared between commands), and to select one at runtime:

```
grunt.initConfig({
    sshconfig: {
      qa: {
        host: "my.qa.server",
        port: 22,
        username: "user", 
        password: "password"
      },
      staging: {
        host: "my.staging.server",
        port: 22,
        username: "user",
        password: "password"
      }    
    },
    sshexec: {
      uptime: {
        command: "uptime"
      }
    }  
});
```
So when we invoke the grunt task, we can specify a config:
```
grunt sshexec:uptime --config qa
```
Or we can set it programmatically (inside the Gruntfile)
```
grunt.option('config', 'qa');
```

___SFTP Tasks___

Grunt-ssh allows you to upload files via SFTP:
```
grunt.initConfig({
    sshconfig: {
      qa: {
        host: "my.qa.server",
        port: 22,
        username: "user", 
        password: "password",
        path: "/path/on/server"
      },
      staging: {
        host: "my.staging.server",
        port: 22,
        username: "user",
        password: "password",
        path: "/path/on/server"
      }    
    },
    sshexec: {
      uptime: {
        command: "uptime"
      }
    }
    sftp: {
      deploy: {
        files: {
          "./": "package/**"
        },
        options: {
          srcBasePath: "package/",
          createDirectories: true
        }
      }
    }  
});
```

There are a couple of options here, so let's break it down:
```
files: {
  "./": "package/**"
}
```

This will copy all files from the "package/" folder locally. If you want to specify only certain types of files, you can use grunt's standard [file globbing][6].

```
srcBasePath: "package/"
```
Optionally strip off an initial part of the path (without it, files would upload to "/path/on/server/package/").

___Putting it all together___
We've got all the component parts, now lets put it together (plus a few other cool bits).

_Note: at the time of writing, there is a bug in Grunt-ssh where the sftp task does not use the shared sshconfig, so if you want the fixed code, use [my fork][7] (there is a pull request outstanding)_

This snippet assumes that:

- You can connect to your deployment server using ssh
- You are deploying to /var/www/myapp
- You are using [forever][8] to run your app
- Your application files are copied to ./package/

(but, since we're just using bash commands, this is easily configurable)

```
var dirname = (new Date()).toISOString();

module.exports = function(grunt){
  grunt.initConfig({
    // our shared sshconfig
    sshconfig: {
      qa: {
        host: "my.qa.server",
        port: 22,
        username: "user",
        password: "password",
        path: "/path/on/server"
      },
      staging: {
        host: "my.staging.server",
        port: 22,
        username: "user",
        password: "password",
        path: "/path/on/server"
      },
      production: {
        host: "<%= grunt.option('server') %>",
        port: 22,
        username: "<%= grunt.option('username') %>",
        password: "<%= grunt.option('password') %>",
        path: "/path/on/server"
      }
    },
    // define our ssh commands
    sshexec: {
      start: {
        command: "cd /var/www/myapp/current && forever start -o /var/www/myapp/current/logs/forever.out -e /var/www/myapp/current/logs/forever.err --append app.js"
      },
      stop: {
        command: "forever stop app.js",
        options: {
          ignoreErrors: true
       }
      },
      'make-release-dir': {
        command: "mkdir -m 777 -p /var/www/myapp/releases/" + dirname + "/logs"
      },
      'update-symlinks': {
        command: "rm -rf /var/www/myapp/current && ln -s /var/www/myapp/releases/" + dirname + " /var/www/myapp/current"
      },
      'npm-update': {
        command: "cd /var/www/myapp/current && npm update"
      },
      'set-config': {
        command: "mv -f /var/www/myapp/current/config/<%= grunt.option('config') %>.yml /var/www/myapp/current/config/default.yml"
      }
    },
    // our sftp file copy config
    sftp: {
      deploy: {
        files: {
          "./": "package/**"
        },
        options: {
          srcBasePath: "package/",
          createDirectories: true
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-ssh');
  grunt.registerTask('deploy', [
    'sshexec:stop',
    'sshexec:make-release-dir',
    'sshexec:update-symlinks',
    'sftp:deploy',
    'sshexec:npm-update',
    'sshexec:set-config',
    'sshexec:start'
  ]);
});
```

It should all make sense, the sshexec is just running remote ssh commands (making directories, starting and stopping using forever etc). Let's just re-iterate what this is doing:

1. `sshexec:stop`: stops the app (assumes you're using forever)
2. `sshexec:make-release-dir`: this will create the folder /var/www/myapp/releases/[current-date-time]
3. `sshexec:update-symlinks`: this will create a symlink from /var/www/myapp/current to the release folder we just created (this means that rolling back is just a case of changing the symlink back).
4. `sftp:deploy`: copy the files into place
5. `sshexec:npm-update`: installs any missing node modules
6. `sshexec:set-config`: copy the environment configuration into place
7. `sshexec:start`: start the application using forever, pointing the logs to /var/www/myapp/current/logs/

___Deploying with one command___
```
grunt deploy --config qa
```

Also, if you noticed the _production_ config I specified in that snippet, you'll see that I didn't include any host, username or password configs. The `grunt.option('value')` allows us to access the command line switches, which means we don't have to keep any sensitive passwords in source control; we can specify them on the command line.

```
grunt deploy --config production --server my.production.server --username user --password password
```

There are lots of other solutions to the problem of credentials, but this is by far the simplest. It's worth remembering the Grunt-ssh uses the ssh2 module, so by default it will look to `~/.ssh/` for keys when connecting without a password.

__But wait, there's more__

Basically any task you can think of is scriptable using grunt (and some combination of tools). Extra things that we've added to our deployment process include:

- Removing the application server from the load-balancer before deploying (and pushing it back when the deployment is complete).
- Making a http request to check the health of the service before going live.
- Rollback from a single command

__Oink, Oink .....__

[1]: http://www.gruntjs.com
[2]: http://www.capistranorb.com
[3]: https://github.com/loopj/capistrano-node-deploy
[4]: https://npmjs.org/search?q=grunt
[5]: https://github.com/andrewrjones/grunt-ssh
[6]: https://github.com/gruntjs/grunt/wiki/grunt.file#globbing-patterns
[7]: https://github.com/andyroyle/grunt-ssh
[8]: https://github.com/nodejitsu/forever
