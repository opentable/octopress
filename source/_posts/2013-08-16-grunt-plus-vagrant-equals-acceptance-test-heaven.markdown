---
layout: post
title: "Grunt + Vagrant = Acceptance Test Heaven"
date: 2013-08-16 15:32
comments: true
author: aroyle
categories: [Grunt, Vagrant, Acceptance tests, Automation]
---
My continued love affair with Grunt reached a new high the other day, when I combined [Vagrant][2] with my [Grunt deployment tasks][1] and test runners.

I'm not going to bang on about how great Vagrant is, because better people than me have already soliloquised at length on that subject. Let's just take it as writ that __Vagrant is awesome__. 

The objective is simple, we want to have a virtualised environment to run our acceptance tests against, that we can create and provision on demand, to ensure that our acceptance tests only deal with functional-correctness, not data- or environment-correctness.

I created a set of Grunt tasks which were able to do the following:

- Spin up an provision a Vagrant instance
- Deploy the project code	
- Start the server
- Run the acceptance tests
- Tear it all down

All from a single command: `grunt acceptance`

The price of this magic? About ten lines of Bash script, a six line Vagrantfile and some Grunt glue.

## Diving in ##

Assuming you've got Vagrant installed, you can create a Vagrantfile in the root of your project, which looks like this:

	Vagrant.configure("2") do |config|
    	config.vm.box = "Ubuntu precise 64 VMWare"
    	config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
    	config.vm.network :forwarded_port, guest: 3000, host: 3000
    	config.vm.provision :shell, :path => "setup/bootstrap.sh"
	end

Notice the last line 'config.vm.provision', this tells Vagrant that there is a shell script at setup/bootstrap.sh which is going to provision your vm. You can provision the box with Puppet, Chef or a variety of other tools, but for the purposes of this simple testing machine, I'm happy to use a shell script.

Let's have a look at the bootstrap file:

	apt-get update -y -q
	apt-get install build-essential mongodb -y -q

	cp /vagrant/tests/acceptance-tests/mongodb.conf /etc/mongodb.conf
	service mongodb restart

	wget --quiet http://nodejs.org/dist/v0.10.15/node-v0.10.15-linux-x64.tar.gz

	tar -zxf node-v0.10.15-linux-x64.tar.gz

	mv node-v0.10.15-linux-x64/ /opt/node/
	ln -s /opt/node/bin/node /usr/bin/node
	ln -s /opt/node/bin/npm /usr/bin/npm

After booting the VM, Vagrant will run this script, which will can do anything you need it to. All the commands run as root, so there's very little restriction as to what you can achieve.

We're installing Node.js (downloading the binaries manually because the version of Node in the Ubuntu repository is really old), and MongoDB (which our app depends on).

Note this line: `cp /vagrant/tests/acceptance-tests/mongodb.conf /etc/mongodb.conf` which installs a custom config for MongoDB. 

By default, Vagrant will mount a share in /vagrant to the current directory (i.e. the directory on the host machine from which you executed `vagrant up`), you can map additional folders by adding `config.vm.synced_folder "path/on/host", "/path/on/guest"` to your Vagrantfile.

Now that we've got our Vagrant config sorted, we can hook this into Grunt, using a bit of glue code.

	var shell = require('shelljs');

	grunt.registerTask('vagrant-up', function(){
    	shell.exec('vagrant up');
	});

	grunt.registerTask('vagrant-destroy', function(){
    	shell.exec('vagrant destroy -f');
	});

So now that we've got our machine provisioned and booted, we can use Grunt to [deploy our code and start our service][1].

Assuming that we've got all that going on, we can move on to the next step, getting Grunt to deploy the code to the Vagrant box.

What I'm going to do here is hook the deployment step into the 'vagrant-up' task.

	grunt.registerTask('vagrant-up', function(){
    	shell.exec('vagrant up');
    	grunt.option('config', 'vagrant');
    	grunt.task.run('deploy');
	});

The reason for this is so that `grunt vagrant-up` will spin me up a provisioned box *and* install the code.

You'll notice that I set the 'config' option inside the task, this option is required by the deploy task. I could specify it on the command line, but this is just friendlier and makes for a cleaner syntax of the command.

Now, when we run `grunt acceptance`, it'll do the following:

- Spin up the Vagrant box
- Deploy the code
- Tear it down again

The only step remaining is to run our acceptance tests. For our app, we're using mocha, you can use anything so long as you've got a Grunt task to drop in.

	var shell = require('shelljs');

	grunt.initConfig({
    	...
    	mochaTest: {
        	options: {
            	reporter: 'spec'
        	},
        	AcceptanceTests:{
            	src: ['tests/acceptance-tests/**/*.js']
        	}
    	}
	});

	grunt.registerTask('deploy', [
    	'sshexec:stop',
    	'sshexec:make-release-dir',
    	'sshexec:update-symlinks',
    	'sftp:deploy',
    	'sshexec:npm-update',
    	'sshexec:set-config',
    	'sshexec:start'
	]);

	grunt.registerTask('vagrant-up', function(){
   		shell.exec('vagrant up');
   		grunt.option('config', 'vagrant');
   		grunt.task.run('deploy');
	});

	grunt.registerTask('vagrant-test', [ 'mochaTest:AcceptanceTests' ]);

	grunt.registerTask('vagrant-destroy', function(){
    	shell.exec('vagrant destroy -f');
	});

	grunt.registerTask('acceptance', [
    	'vagrant-up',
    	'vagrant-test',
    	'vagrant-destroy'
	]);

Ta-Da! Wasn't that painless?

The key part here is that everything is now in source control. So whenever someone checks out the project, it takes precisely ___one___ command to get the project going. No more time wasted configuring your dev machine to be able to run this, or that. 

The machine is brand-new every time, with its own spangly MongoDB instance ready for use.

What's that I hear you whine? "_My application depends on shared data, I can't use an empty database_". Not true. If you need it, set it up or mock it out. The acceptance tests should set-up and tear-down all their own data, if you rely on shared data sources for acceptance tests then you're going to have a painful time. Script it once and it'll forever be your friend. It's time to enter the dynamic era, no more false failures on your CI build because a shared datasource is missing and/or has been changed.

What's more you can now run `grunt acceptance` from anywhere and ___know___ that it'll be the same. No more environment pains!

[1]: http://tech.opentable.co.uk/blog/2013/08/08/grunt-your-deployments-too/
[2]: http://www.vagrantup.com