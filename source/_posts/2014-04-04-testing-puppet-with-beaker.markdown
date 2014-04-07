---
layout: post
title: "Testing Puppet with Beaker"
date: 2014-04-04 17:30
comments: true
author: lbennett
categories: [Puppet, Acceptance tests, Beaker, Vagrant]
---

One afternoon I got asked to write a new Puppet module to manage local users on our Linux boxes. Not a contrived example but a real-world need as we begin to move our infrastructure from Windows to Linux. Managing users is one of those tasks that is at the core of the Puppet ecosystem and I thought this would be pretty easy as I had done this sort of thing many times before. What added to the complexity was that we needed to support Ubuntu, Centos and FreeBSD machines that we had in our stack and we wanted to make it something that was open source and on the Forge - so lots of testing was required.

This was not the first module that I had written for the Forge but it was the first that I had written since PuppetLabs had introduced their new acceptance testing framework [Beaker](https://github.com/puppetlabs/beaker) and so I wanted to spend some time getting the module working with this new tool.

## Beaker ##

The purpose of Beaker is to allow you to write acceptance tests for your modules, that is to write some manifests that use your module and test them out on a virtual machine. Some of you may remember [rspec-system-puppet](https://github.com/puppetlabs/rspec-system-puppet) was previously used to accomplish this, well PuppetLabs has since deprecated that in favour of Beaker but the premise is very much the same.

Using rspec-puppet for unit testing your manifests really only goes so far. If you're just using the standard Puppet resources then it pretty safe to assume that it does what it says on the tin (I mean PuppetLabs really test their stuff!) but as soon as you start doing things that are a little more complex, using exec statements, custom facts, custom functions or targeting multiple operating systems then you're really going to want to make sure that once the catalogs compile that they are doing what they are meant to be doing and this is where your acceptance test suite will come in.

With Beaker you can spin up a virtual machine, install modules, apply a manifest and then test what really happened.

Beaker works with many different hypervisor technologies but most people will be using [Vagrant](http://www.vagrantup.com/) so that is what I will cover here.

### Configuring Beaker ###

The first thing in configuring your existing project to use Beaker is to add “beaker” and “beaker_rspec” to you Gemfile. You're then going to want to create a new spec_helper file called spec_helper_acceptence.rb that should look something like this:

    require 'beaker-rspec/spec_helper'
    require 'beaker-rspec/helpers/serverspec'

    hosts.each do |host|
      install_puppet
    end

    UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

    RSpec.configure do |c|
      proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

      c.formatter = :documentation

      # Configure all nodes in nodeset
      c.before :suite do
        puppet_module_install(:source => proj_root, :module_name => 'homes')
        hosts.each do |host|
          on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
          on host, puppet('module', 'install', 'opentable-altlib'), { :acceptable_exit_codes => [0,1] }
        end
      end
    end

This contains quite a bit of new setup that you won’t have seen before. Beaker contains lots of useful helper methods for doing all the things that you're going to want to do when running Puppet against a virtual machine; install Puppet (so your boxes don’t have to have it pre-baked), installing local modules and installing modules from the Forge. We also specify the platforms that we don’t support - we’ll make use of this later.

The next step is to define some machines that we want to set against. Beaker calls these nodesets because while in most cases you’ll only want to test one host machine at a time, Beaker does support testing multi-node configurations for more complex scenarios. Looking at the homes project your directory structure will look something like this:

    puppet-homes
      manifests
      spec
        acceptance
          nodesets
            centos-64-x64.yml
            default.yml
            ubuntu-server-12042-x64.yml
          homes_spec.rb 
        defines
        fixtures
        spec_helper.rb
        spec_helper_acceptance.rb
      tests 

A nodeset is simply a yaml file that specifies the box name, where it downloads it from, its platform and the hypervisor you are using. A example from the homes module below:

    HOSTS:
      ubuntu-server-12042-x64:
      roles:
        - master
      platform: ubuntu-12.04-amd64
      box : ubuntu-server-12042-x64-vbox4210-nocm
      box_url : http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210-nocm.box
      hypervisor : vagrant
    CONFIG:
      log_level: verbose
      type: git

More detail about how to configure these yaml files can be found on the Beaker wiki, [Creating A Test Environment](https://github.com/puppetlabs/beaker/wiki/Creating-A-Test-Environment)

In the above example I am using Vagrant boxes provided by PuppetLabs but there are a few other sources to discover already pre-built boxes:

 * [http://puppet-vagrant-boxes.puppetlabs.com/](http://puppet-vagrant-boxes.puppetlabs.com/)
 * [http://www.vagrantbox.es/](http://www.vagrantbox.es/)
 * [https://vagrantcloud.com](https://vagrantcloud.com)


### Writing tests in Beaker ###

So now that we have our environment set up let’s look at actually writing some tests. Here is an example from the homes project:

    require ‘spec_helper_acceptance'
    
    describe 'homes defintion', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
    
      context 'valid user parameter’ do
    
        it 'should work with no errors’ do
          pp = <<-EOS
            $myuser = {
            'testuser' => { 'shell' => '/bin/bash' }
          }
          
          homes { 'testuser':
            user => $myuser
          }
          EOS
     
          apply_manifest(pp, :catch_failures => true)
          expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
       end

       describe user('testuser') do
         it { should exist }
       end

       describe file('/home/testuser') do
         it { should be_directory }
       end
     end

    end

In this case we are writing a test to make sure that when our module runs, it creates the user and its home directory as it expects. Using the UNSUPPORTED_PLATFORMS that we defined earlier we can also skip groups of tests if they are not supported on the current node.

The idea here is that we define a manifest (using Heredoc - but please don’t make them too long!) and then we want to apply that manifest to the node. Beaker provides a nice helper methods that: apply_manifest. In our case we run it once, which will cause the changes and then we run it a second time with the scope of a test to check for idempotency. We can then make use of Beaker’s resource based helpers to actually test the functionality on the node itself. Their many helper methods will allow you to do almost everything that you need to do, either for setup purposes or for actually testing the node:

* [The-Beaker-DSL-API](https://github.com/puppetlabs/beaker/wiki/The-Beaker-DSL-API)
* [beaker/dsl/helpers.rb](https://github.com/puppetlabs/beaker/blob/master/lib/beaker/dsl/helpers.rb)

It’s actually worth noting that Beaker makes heavy use of [serverspec](https://github.com/serverspec/serverspec) which you should go and take a look at.

## Summary ##

So now you know a little about testing Beaker with Puppet go forth and test all your modules against everything that you expect your users to be running it on.