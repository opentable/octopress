---
layout: post
title: "Using Vagrant to work with ElasticSearch on your local machine"
date: 2013-08-05 08:45
comments: true
author: pstack
categories: [Vagrant, ElasticSearch, DevOps]
---
Recently, I have started to work a lot more with [Vagrant](http://www.vagrantup.com/) as a tool for creating a standard development environment across my team. This essentially means that regardless what the developers' machine is set up or running as, they can still reproduce the same environment as their colleagues just by entering a command. 

Configuration managgement is something we have had to embrace to help us maintain an ever changing world of technologies. The hardest thing is knowing what we actually have to build in these environments. We use Vagrant to help us understand this. The simple flow is as follows:

* Developer starts a new project
* Developer creates a Vagrantfile to spin up a local VM
* Vagrantfile gets iterated on as the development process goes forward

Once the developer understands what they need to actually run their software, we would then go about creating an environment to which this software will actually be deployed for end-to-end testing. I won't go any further into the details of our Vagrant flow in this post, if you want to read more about how to get started with Vagrant, then I would suggest reading [Vagrant Up and Running](http://shop.oreilly.com/product/0636920026358.do) by [Mitchell Hashimoto](https://twitter.com/mitchellh).

Vagrant and ElasticSearch
--

Whilst reviewing a book on [ElasticSearch](http://www.elasticsearch.org/), I noticed how simple the instructions were to get up and running with ElasticSearch. Please note, that there are already lots of Puppet modules for configuring ElasticSearch on [Puppetlabs Forge](http://forge.puppetlabs.com/modules?q=elasticsearch). This post only talks about how I was able to quickly spin up some local instances. I didn't want to manually do this, so I decided to use Vagrant (and Puppet) to take care of it for me. The instructions can be summarised as follows:

* Download and install the JavaSDK
* Download the specific ElasticSearch package
* Install ElasticSearch
* Download and install curl (to be able to interact with ElasticSearch)
* Make sure the service is started

I hate doing this manually. Luckily, with the correct script, I am able to automate all of this as follows:

    Vagrant.configure("2") do |config|
        config.vm.box = "Ubuntu precise 64 VMWare"
        config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
        config.vm.network :forwarded_port, guest: 9200, host: 9200
        config.vm.provision :puppet do |puppet|
            puppet.module_path = '../setup/modules'
            puppet.manifests_path = '../setup/manifests'
            puppet.manifest_file = 'default.pp'
            puppet.options = '--verbose --debug'
        end
    end
    
Essentially, this script says to create a clone of a VM from a predefined box, forward port 9200 on the vm to 9200 on my local machine and then provision the server using Puppet. The Puppet script works as follows:

    exec { "apt-get-update":
        command => "/usr/bin/apt-get update",
    }

    package {'curl':
        provider => apt,
        ensure   => latest,
        require  => Exec['apt-get-update']
    }

    class {'elasticsearch':
        version => '0.90.0',
        require => Exec['apt-get-update'],
    }
    
This defines that the command apt-get-update gets applied (due to both the class and the package requiring it) and then will install curl and ElasticSearch in no particular order. Once the script runs, I will be able to open a browser on my local machine, go to http://localhost:9200 and see the newly provisioned ElasticSearch node. The result of the JSON was something similar to this:

    {
	    "ok" : true,
	    "status" : 200,
	    "name" : "Gibborim",
	    "version" : {
		    "number" : "0.90.0",
		    "snapshot_build" : false,
	    },
	    "tagline" : "You Know, for Search"
    }
    
By entering the URL, '**http://localhost:9200/_cluster/health?pretty**', you can see the state of the ElasticSearch cluster. It should show something like this:

	{
  		"cluster_name" : "elasticsearch",
  		"status" : "yellow",
  		"timed_out" : false,
  		"number_of_nodes" : 1,              
  		"number_of_data_nodes" : 1,         
  		"active_primary_shards" : 5,        
  		"active_shards" : 5,                
  		"relocating_shards" : 0,            
  		"initializing_shards" : 0,          
  		"unassigned_shards" : 5             
	}

I wanted to be able to provision multiple nodes and then let them create a cluster. I was able to take the existing Vagrantfile and then using the multi-environment features of Vagrant. This created a new Vagrantfile as follows:

    Vagrant::Config.run do |config|
        config.vm.box = "Ubuntu precise 64 VMWare"
        config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"

        config.vm.define "es1" do |es1|
            es1.vm.network :hostonly, "192.168.1.10"
            es1.vm.provision :puppet do |puppet|
                puppet.module_path = '../setup/modules'
                puppet.manifests_path = '../setup/manifests'
                puppet.manifest_file = 'default.pp'
                puppet.options = '--verbose --debug'
            end
    	end

    	config.vm.define "es2" do |es2|
        	es2.vm.network :hostonly, "192.168.1.11"
        	es2.vm.provision :puppet do |puppet|
            	puppet.module_path = '../setup/modules'
            	puppet.manifests_path = '../setup/manifests'
            	puppet.manifest_file = 'default.pp'
            	puppet.options = '--verbose --debug'
        	end
    	end

    	config.vm.define "es3" do |es3|
        	es3.vm.network :hostonly, "192.168.1.12"
        	es3.vm.provision :puppet do |puppet|
            	puppet.module_path = '../setup/modules'
            	puppet.manifests_path = '../setup/manifests'
            	puppet.manifest_file = 'default.pp'
            	puppet.options = '--verbose --debug'
        	end
    	end
	end
	
This effectively tells Vagrant to create three instances of ElasticSearch using the Puppet configuration (as above). Each ElasticSearch node is given its own IP. Thanks to ElasticSearch using Multicast and Unicast discovery, it is able to find other nodes on the network and create a cluster. By running a similar url as before, '**http://192.168.1.10:9200/_cluster/health?pretty**', we can now see that the cluster looks as follows:

	{
  		"cluster_name" : "elasticsearch",
  		"status" : "green",
  		"timed_out" : false,
  		"number_of_nodes" : 3,              
  		"number_of_data_nodes" : 3,         
  		"active_primary_shards" : 5,        
  		"active_shards" : 15,                
  		"relocating_shards" : 0,            
  		"initializing_shards" : 0,          
  		"unassigned_shards" : 0             
	}
	
Using this method, we can continue to spin up as many instances as we need to replicate different scenarios or testing conditions. Vagrant has made this very easy to do. If you want a copy of the Vagrantfiles and Puppet modules to try this yourself, then you can find them on my [github repository](https://github.com/stack72/vagrant-examples/tree/master/elasticsearch). The scripts are available under the [MIT](http://opensource.org/licenses/MIT). 