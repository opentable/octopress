---
layout: post
title: "Upgrading Puppet with Puppet"
date: 2014-04-07 13:23
comments: true
author: lbennett
categories: [puppet, maintenance, windows]
---

As part of one of our recent [ForgeFriday](http://tech.toptable.co.uk/blog/2014/04/04/forgefriday-our-commitment-to-the-puppet-forge/) efforts we released a new module puppetversion with the purpose of managing the installation and upgrade of puppet in a platform agnostic way.


This should be a very straightforward task to complete because this is one of the core resources that puppet manages - the upgrading of packages. With that in mind, putting `package { ‘puppet’: ensure => $version }` in one of our base profiles would be all that was needed but alas it was not. In this blog I want to take you through the history, the bugs, the platforms and the edge-cases that make performing an in-place upgrade of puppet a more complex task that it ought to be.

##Debian
Like many, Ubuntu is our Debian derivative of choice for much of our newer production infrastructure. Debian, has the apt package management system and PuppetLabs provide the required deb packages as well as hosting their own apt repository to point our systems to. The main point of package management systems is it that they take care of the dependency hell and the awkward upgrade paths all from within the confines of the package itself, and that is what happens with the PuppetLabs packages - great. 

The problem that we had in some of our systems was that they had been built without the PuppetLabs apt repository. This means that they picked up a slightly older version of the puppet packages from the main Ubuntu distribution repositories and didn’t have access to the newer versions of the puppet packages. Ok, so we solved that with the following code:

      exec { 'rm_duplicate_puppet_source':
        path    => '/usr/local/bin:/bin:/usr/bin',
        command => 'sed -i \'s:deb\ http\:\/\/apt.puppetlabs.com\/ precise main::\' /etc/apt/sources.list',
        onlyif  => 'grep \'deb http://apt.puppetlabs.com/ precise main\' /etc/apt/sources.list',
      }

      apt::source { 'puppetlabs':
        location    => 'http://apt.puppetlabs.com',
        repos       => 'main dependencies',
        key         => '4BD6EC30',
        key_content => template('puppetversion/puppetlabs.gpg'),
        require     => Exec['rm_duplicate_puppet_source']
      }

We're making use of the [puppetlabs/apt](http://forge.puppetlabs.com/puppetlabs/apt) module here. This removes the old reference and adding in the new apt source. Then we just add the package and ensure the version and we’re upgrading. Perfect.

##RedHat
Same problem different OS family - this time we had some older CentOS machines that needed fixing. Thankfully there is also a module [stahnma/puppetlabs_yum](http://forge.puppetlabs.com/stahnma/puppetlabs_yum) for the yum repositories. Add that in, add the package resource and start upgrading. Phew! This seems like it’s getting easier.

##Windows
Many of you will be following the work of OpenTable closely because of our work with puppet on windows. We have a pretty large windows infrastructure, with a wide range of client and server versions deployed ranging from 2012 R2 all the way back to the historic times of 2003. Windows also has it’s own package format, the msi, and PuppetLabs also provides all versions of puppet packaged as msi files. 

This is where it gets a little tricky. The big problem we had was that the windows provider, prior to 3.4.0 was not versionable ([issues/21133](http://projects.puppetlabs.com/issues/21133)) that means that `package { ‘puppet’: ensure => installed }` would work but `package { ‘puppet’: ensure => $version }` would not - the exact thing we were trying to do! The only way to resolve that problem is to uninstall and reinstall the package with the correct version.

Now there are a lot of problems with the uninstall/reinstall approach. Firstly we had to script the process because windows only allows one installer to run at any one time meaning that you had to wait for the uninstall to finish before that subsequent install takes place. Secondly we have to deal with puppet runs and make sure that when the upgrade script runs that we wait for any active puppet runs to complete before trying to uninstall puppet. Next we have to trigger our script using a scheduled task.

Our experience with scheduled tasks has been painful. We attempted using the [scheduled_task](http://docs.puppetlabs.com/references/latest/type.html#scheduledtask) resource type but soon realised that this wasn’t going to work for us. The resource type is good if you want to create a task to run at a fixed point in time but there is no way to provide a relative time e.g. “in the next 5 mins from now”. Also on occasion the task would not run or would silently fail - this was almost certainly due to another puppet issue we discovered ([PUP-1368](https://tickets.puppetlabs.com/browse/PUP-1368)). Without being able to use the scheduled task resource we were again back in the land of Powershell using a script to create the scheduled task that would call our upgrade script. 

So if you're keeping up we now have something like this:

Puppet -> calls script to create scheduled task -> scheduled task calls upgrade script -> upgrade script upgrade puppet and triggers next Puppet run -> Puppet

Nice little cycle there, but it works.

One final issue worth mentioning is that for Windows 2003 servers you’ll need to actually have Powershell installed. Luckily, we also have a module for that [dcharleston/powershell](http://forge.puppetlabs.com/dcharleston/powershell)

##Summary
Well we’ve discussed some of the pain points, and we’ve discussed them in detail with PuppetLabs themselves. The advice here is to upgrade to puppet 3.4.3 as soon as you can as many of these issues are resolved in that version. For those of you not on that version yet then we have you covered with our puppetversion module.
