---
layout: post
title: "Testing Puppet with Beaker pt.2 - The windows story"
date: 2014-09-01 09:43:10 +0100
comments: true
categories: [Puppet, Acceptance tests, Beaker, Vagrant, Windows]
---

In [part-1](http://tech.opentable.co.uk/blog/2014/04/04/testing-puppet-with-beaker/) we discussed our first steps into the world of acceptance testing our puppet manifests.
By using Beaker we able to test managing local users on our Linux boxes. This was a positive experience for us. It allowed us to get to grips with the basics of configuring
beaker to run tests and configuring our node sets to run those tests against. In this post, we will be discussing how we went about getting beaker working with Windows.

As many of your reading this will be aware, OpenTable currently has quite a large windows infrastructure and we are using Puppet extensively to maintain that environment.
We are also moving forward with releasing as many of our modules open source onto the [Puppet Forge](https://forge.puppetlabs.com/opentable) as possible (11 out of 18 of which are windows
exclusive). What this means is that there was no way that we could ignore trying to use Beaker to test our manifests against windows. We knew that we would have to support
many different versions and editions of windows out there in the community as well that the ones we have to support internally.

This was going to be a challenge (configuration management with windows usually is) but we were up for it.

##The Preliminaries
###ServerSpec
The first step was looking at serverspec. Serverspec is a ruby gem that provides extensions to RSpec that allow you to test the actual state of your servers, either locally
or from the outside in via ssh. What we needed to know was did it support windows? The answer was thankfully a resounding "Yes!". All the [resource types](http://serverspec.org/resource_types.html)
that you might want to test including file, service and user are available and supported on windows. There are also a couple of windows specific ones such as iis_website,
windows_feature and windows_registry_key. We even added our own to support [windows_scheduled_task](https://github.com/serverspec/serverspec/pull/403/files). Interestingly
serverspec also supports winrm as an alternative to ssh when you are testing from the outside-in but we will to back into that later. As long as your using serverspec > 1.6
you will have all the windows support you might need.

###Packer
Step two was to build some windows vagrant boxes to test against. The documentation on the [wiki](http://github.com/puppetlabs/beaker/wiki) was (at the time) a bit slim when it came
to building test boxes but we knew we needed cygwin so we went ahead and created the boxes that we needed. All our boxes are created with packer and are open sourced on github:
[github.com/opentable/packer-images](http://github.com/opentable/packer-images). They have also been published to vagrantcloud: [vagrantcloud.com/opentable](http://vagrantcloud.com/opentable)
so you can download pre-built images and get up and running quickly (version 1.x images contain the cygwin installation).

###Beaker
So far, so good. We hit a couple of issues in our initial test runs with beaker: missing module_path, installation using the msi and 32-bit windows support - but these were very
small issues and we were happy to be able to contribute back some changes ([234](https://github.com/puppetlabs/beaker/pull/234),
[235](https://github.com/puppetlabs/beaker/pull/235), [236](https://github.com/puppetlabs/beaker/pull/236)). We were very happy and managed to get out first module tested,
the cross-platform module puppet-puppetversion (github.com/opentable/puppet-puppetversion/) for doing puppet upgrades.

##The First Example
Let's take a more detailed look at those puppetversion tests, how we configured beaker to run and how it changed for the windows support. I am going to asume at this point that
you already have some familiarity with Beaker, if not and this is your first steps into the testing tool then I would suggest going back and read [part-1](http://tech.opentable.co.uk/blog/2014/04/04/testing-puppet-with-beaker/)
of this series which contains a little bit of background to this and some useful resources for getting started.

The first thing that we needed to change for windows was our [spec_accepentance.rb file](https://raw.githubusercontent.com/opentable/puppet-puppetversion/master/spec/spec_helper_acceptance.rb).

Step one was to include the appropriate serverspec helpers. What this does is let serverspec know that we are executing on windows so that underlying resources work correctly. We are also telling
server spec here to communicate using WinRM.

    require 'beaker-rspec/spec_helper'
    require 'beaker-rspec/helpers/serverspec'
    require 'winrm'

    hosts.each do |host|
      case host['platform']
        when /windows/
          include Serverspec::Helper::Windows
          include Serverspec::Helper::WinRM

          version = ENV['PUPPET_VERSION'] || '3.4.3'

          install_puppet(:version => version)

      else
        install_puppet
      end
    end

    ...


The next step is to configure WinRM so that it can connect properly. In our case this meant connecting to vagrant boxes.

    ...

    RSpec.configure do |c|
      ...
      hosts.each do |host|
        c.host = host

        if host['platform'] =~ /windows/
          endpoint = "http://127.0.0.1:5985/wsman"
          c.winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => 'vagrant', :pass => 'vagrant', :basic_auth_only => true)
          c.winrm.set_timeout 300
        end

        ...
      end
    end

    ...

Now let's look at one of the tests themselves.

The first part should look pretty familiar. We use the face('osfamily') helper in beaker to make sure that the test
itself is only ever executed for our windows hosts. We are then running an apply_manifest two times in order to validate
that the manifest is idempotent. The only different here is that we are specifying a custom windows-specific module_path.

    ...
    require 'spec_helper_acceptance'

    describe 'puppetversion', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
      ...

      context 'upgrade on windows', :if => fact('osfamily').eql?('windows') do

      it 'should install the new version' do
        pp = <<-PP
          class { 'puppetversion':
            version => '3.5.1',
            time_delay => 1
          }
        PP

        apply_manifest(pp, :modulepath => 'C:/ProgramData/PuppetLabs/puppet/etc/modules', :catch_failures => true)
        expect(apply_manifest(pp, :modulepath => 'C:/ProgramData/PuppetLabs/puppet/etc/modules', :catch_failures => true).exit_code).to be_zero
      end

The next part is where we actually perform the bulk on the tests. In the case of this module, we are testting
that the scheduled task has run and that puppet has been upgraded to the appropriate version. We are making use
of the windows_scheduled_task resource that we created earlier:

      describe windows_scheduled_task('puppet upgrade task') do
        it { should exist }
      end

      #This will fail if your laptop (and therefor the vagrant vm) is not running on AC power
      describe package('puppet') do
        it {
          sleep(240) #Wait for the task to execute
          should be_installed.with_version('3.5.1')
        }
      end

      describe windows_scheduled_task('puppet upgrade task') do
        it {
          pp = <<-PP
            class { 'puppetversion':
              version => '3.5.1'
            }
          PP

          apply_manifest(pp, :modulepath => 'C:/ProgramData/PuppetLabs/puppet/etc/modules', :catch_failures => true)

          should_not exist
        }
      end
    end

The final part was to configure the nodeset file for the windows box that we wanted to run our test against:

    HOSTS:
      windows-2008R2-serverstandard-x64:
      roles:
        - agent
      platform: windows-server-amd64
      box : opentable/win-2008r2-standard-amd64-nocm
      box_url : opentable/win-2008r2-standard-amd64-nocm
      hypervisor : vagrant
      user: vagrant
    CONFIG:
      log_level: verbose
      type: git

This was working well for us so we continued onto our next module.

The next module we chose to look at was [puppet-windowsfeature](http://github.com/opentable/puppet-windowsfeature).

The test we have implemented in this moudle looks like this:

    require 'spec_helper_acceptance'

    describe 'windowsfeature' do
      context 'windows feature should be installed' do
        it 'should install .net 3.5 feature' do

          pp = <<-PP
            windowsfeature { 'as-net-framework': }
          PP

          apply_manifest(pp, :catch_failures => true)
          expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
        end

        describe windows_feature('as-net-framework') do
          it { should be_installed.by('powershell') }
        end
      end
    end

This module was a little more tricky. Why? Installing
windows features requires elevated permissions. That this meant is that when beaker attempted to ssh into our windows box and our puppet module ran it’s underlying powershell
we were faced with a harsh and non-descriptive **"Access is denied error"**.

##SSH
Not all ssh daemons are created equal. To understand the "Access is denied error" we were seeing and why it happens you need to understand a little bit about how sshd on cygwin
works. You can read all about the details from the cygwin forum archives ([[1]](http://cygwin.com/ml/cygwin/2004-09/msg00087.html),
[[2]](http://cygwin.com/ml/cygwin/2006-06/msg00862.html), [[3]](http://thread.gmane.org/gmane.os.cygwin/128472), [[4]](https://cygwin.com/cygwin-ug-net/ntsec.html#ntsec-nopasswd1))
but TLDR; is that you need to use a username and password rather than private key authentication in order to get reasonable admin permissions.
Having said all that, and having read all the documentation about the issue above we were still facing the same problem so we had to look at alternative options.

There are several paths you can go down and I want to tell you about them here to save you a similar yak shave:

###OpenSSH for Windows
A thinner alternative than having to install the full cygwin stack using OpenSSH for Windows is the same openssh implementation. The issue here however is that it doesn’t
contain some of the unix binaries required for beaker to function. You can work around this if you have Git for Windows installed on your machine by putting it’s bin
directory on your path but overall this doesn’t really solve any of the issues we were looking to solve. We get a lighter footprint on the machine but still the same error
as before

###Bitvise SSH Server
Bitvise SSH Server ([http://www.bitvise.com/ssh-server-download](http://www.bitvise.com/ssh-server-download)) is an alternative ssh implementation (of which there are many
more listed on [wikipedia](http://en.wikipedia.org/wiki/Comparison_of_SSH_servers)). It resolves the permissions issue (it deals with the elevation internally) and has the
benefit that it provides a proper command shell rathe than a emulated bash shell. It also means we don’t have to have any binaries on there that we don’t need - a big plus.
It would mean that we needed to make a few small changes to Beaker in order to replace some of the internal bash command with windows alternatives but this was not a big
task to do and is something we could contribute back.

###WinRM
Could we do away with SSH all together? It eliminates the problem we were facing and also means we don’t have to install anything on our windows boxes - it’s all built in
already. This would be an ideal solution but does all our tooling support it? I’ll discuss this in a little bit more detail later.

###Not use Beaker at all
The nuclear option. If we couldn’t get anything to work we could not use beaker at all, we could try and use test-kitchen (with [test-kitchen-puppet](https://github.com/neillturner/kitchen-puppet))
or some hand-rolled solution. Not the best idea, for us or the community but we though we might have to go down this path at one point. We even added [windows support to
test-kitchen-puppet](https://github.com/liamjbennett/kitchen-puppet/tree/windows_support) as part our diversion in this direction.

##What worked in the end:
So we went down all these avenues and decided that the best option for us was to use Bitvise. It fixed the problem we were facing but it meant that we had some work ahead of us:
1. We had to rebuild all our windows images with bitvise rather than cygwin (vagrantcloud.com/opentable - version 2.x images now have this)
2. We had to make some changes to beaker to support using and standard windows command shell rather than a unix shell:

   - [https://github.com/puppetlabs/beaker/pull/419](https://github.com/puppetlabs/beaker/pull/419) – configure_puppet method
   - [https://github.com/puppetlabs/beaker/pull/419](https://github.com/puppetlabs/beaker/pull/420) – host_entry method
   - [https://github.com/puppetlabs/beaker/pull/419](https://github.com/puppetlabs/beaker/pull/418) – vagrant box_version
   - [https://github.com/puppetlabs/beaker/pull/419](https://github.com/puppetlabs/beaker/pull/424) – bitvise ssh

With it finally working we had something that looked like this:

##Second Example

Well with all the changes we implemented there were actually very few changes that we needed to make to our actual tests code.

No adjustments are needed for our spec_acceptance.rb file.

No adjustments are required for our spec file (show above).

The main change we made was in the nodeset file:

    HOSTS:
      win-2008R2-std:
      roles:
        - default
        - agent
      platform: windows-server-amd64
      box: opentable/win-2008r2-standard-amd64-nocm
      hypervisor: vagrant
      user: vagrant
      ip: '10.255.33.129'
      communicator: bitvise
    CONFIG:
      log_level: verbose
      type: git

The biggest change you will see here is the addition of the 'communicator' option. What this does is to allows to to actively select to use either cygwin or bitvise. This means
that in our case we want to use bitvise ssh as this fixes the error we were seeing and it's the version of ssh now installed on your newer vagrant boxes. Bitvise is the only
supported option at the moment (in our beaker fork) but it is likely that this will soon support winrm as well.

Things to note here:
* The name of the windows host defined in the node set must be the same as the name of the windows hostname - if it is not then when vagrant boots up it will change the hostname
which will put windows into a "restart pending" state.

##The Future and WinRM
Most modern versions of Windows server have WinRM enabled by default but if you are using an older version or you are attempting to test a client then you will need to make sure
that this is enabled on your boxes. This is still the direction that we would like to go long-term as it is the most windows-friendly approach but there are few road blocks in
the way of doing so right now:

1. Packer doesn’t set support winrm as a communication method. This is being actively worked on and you can follow the work here:

    - [https://github.com/mitchellh/packer/issues/451](https://github.com/mitchellh/packer/issues/451)
    - [https://github.com/dylanmei/packer-communicator-winrm](https://github.com/dylanmei/packer-communicator-winrm)

2. Beaker doesn’t yet support winrm as a communication protocol. This is currently being discussed internally after we raised the idea. The work that we have completed for
bitvise support will go some way it allowing other providers, such as wirm going forward and therefore winrm support should be coming in the near future.

##Summary
Using Beaker to test modules for windows has been a long and complicated journey. I have attempted to cover here all the problems that you might run into when trying to do this for yourselves and provide some good examples to get you going. You will soon see this being rolled out to all of the OpenTable open source modules shortly so you will have some complete working examples to reference. We will continue to work with PuppetLabs in improving Beaker (and it’s windows support) in order to make this a easy process for everyone.

For any questions or comments then please reach out to me on twitter [@liamjbennett](https://twitter.com/liamjbennett)
