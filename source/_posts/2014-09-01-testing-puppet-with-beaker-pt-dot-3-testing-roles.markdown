---
layout: post
title: "Testing Puppet with Beaker pt.3 - Testing Roles"
date: 2014-09-01 13:09:05 +0100
comments: true
categories: [Puppet, Acceptance tests, Beaker, Vagrant]
---

In the first two parts of this blog series we have focusing on testing puppet *modules* with beaker. As an open source contributor there is always
a large test matrix so this makes absolute sense. But what about the other large use-case for beaker - what about our day-to-day internal code base?
Not all of this is modules, in fact a large portion of it is other puppet code - roles, profiles, facts, hiera data etc. All of this needs testing
as well.

In this blog post I will be showing how we have started using beaker to test our puppet roles and profiles for both Linux and Windows.


## Master-vs-Masterless
Prior to this post all our beaker testing has been master-less i.e. using using puppet agent apply. This is perfectly adequate for most use cases when
testing modules in isolation but doesn't always work when testing an internal code base (unless you are masterless there as well then please skip to the next section).

At OpenTable we do use a central puppet master to compile our catalogs. So when testing our puppet roles we wanted to make sure that we were also testing
with a master-agent configuration. It is worth mentioning here that if (like us) you are testing windows agents then you are going to need to test with master-agent
approach due to the lack of a windows master.

Testing the master-agent configuration means configuring multi-node sets in beaker. There are not many examples of this but the principle is very much
the same as the single-node nodeset. Here is an example:

    HOSTS:
      ubuntu-server-12042-x64-master:
        roles:
          - master
        platform: ubuntu-12.04-amd64
        box: ubuntu-server-12042-x64-vbox4210-nocm
        box_url: http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210-nocm.box
        hypervisor: vagrant
        ip: '10.255.33.135'
      win-2008R2-std:
        roles:
          - default
          - agent
        platform: windows-server-amd64
        box: opentable/win-2008r2-standard-amd64-nocm
        box_version: = 1.0.0
        box_check_update: false
        hypervisor: vagrant
        user: vagrant
        ip: '10.255.33.129'
        communicator: bitvise
    CONFIG:
      log_level: verbose
      type: git

In this example you will see that we are specifying different 'roles' for each host in the nodeset. What a role is in in this context is a tag for that node that allows
us to reference it directly later when running commands on the host. To avoid any further confusion, from this point onwards if I am referring to the role defined in the
nodeset file I will call it the 'nodeset role' otherwise I am referring the the puppet role provided in the manifest. There are a couple of build-in nodeset roles that
Beaker already knows about: master, agent and default. The first two are pretty self explanatory but the last nodeset role - default - is the location where the tests
themselves run. In you don't specify the 'default' nodeset role on any of your host definitions then the tests will run on the first host that you specified in in the
nodeset file (which in the case of the example above would be wrong).

You may have a more complicated configuration that you wish to test and this allows you to specify arbitrary tags which can be very useful.

We can now use these nodeset roles to configure our master and agent.

In parts [[1]](http://tech.opentable.co.uk/blog/2014/04/04/testing-puppet-with-beaker/) and [[2]](http://tech.opentable.co.uk/blog/2014/09/01/testing-puppet-with-beaker-pt-dot-2-the-windows-story) of this series we saw what a basic spec_acceptence file looks like. So let's start with that:

    require 'beaker-rspec/spec_helper'
    require 'beaker-rspec/helpers/serverspec'
    require 'winrm'

    hosts.each do |host|

      if host['platform'] =~ /windows/
        include Serverspec::Helper::Windows
        include Serverspec::Helper::WinRM
      end

      version = ENV['PUPPET_VERSION'] || '3.5.1'
      install_puppet(:version => version)

      if host['roles'].include?('master')

        ... # Install a master

      else

        ... # Install an agent

      end
    end

    RSpec.configure do |c|

      c.before :suite do

        hosts.each do |host|
          c.host = host

          if host['platform'] =~ /windows/
            endpoint = "http://127.0.0.1:5985/wsman"
            c.winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => 'vagrant', :pass => 'vagrant', :basic_auth_only => true)
            c.winrm.set_timeout 300
          end
        end
      end
    end

We can see here how we use the host['roles'] in order to select the appropriate code-path for configurting each nodeset role. Now let's
move onto how we configure each of those nodeset roles.

## Configuring the master
There are a lot of things that go into building a puppetmaster:
 - puppetmaster packages
 - hiera backends
 - gems for addditional dependencies (eyaml + puppetdbquery)
 - downloading external modules

Now let's step through our new spec_acceptence file that supports this multi-node environment:

###Deploying the codebase
Stage one is getting our puppet codebase onto the master, which includes all the files, internal modules and anything else we need to get the master up and
running. We do this like follows:

    files = [ 'environments','facts','hiera','roles', 'profiles', 'keys', 'app_modules', 'auth.conf','autosign.conf',
              'fileserver.conf', 'Gemfile','hiera.yaml','Puppetfile'
            ]

    files.each do |file|
      scp_to master, File.expand_path(File.join(File.dirname(__FILE__), '..', file)), "/etc/puppet/#{file}"
    end

    # scp dist modules folder (this excludes stuff like spec and test folders)
    dist_modules = Dir["#{dist_modules_root}/*/"].map { |a| File.basename(a) }
    dist_modules.each do |module_name|
      dist_module_dir = "#{dist_modules_root}/#{module_name}"
      copy_module_to(master, :source => dist_module_dir, :module_name => module_name)
    end

Here we are selecting all the files that we want and calling the scp_to method which will scp any file or directory to the host of choice, in this case our
master.

###The puppetmaster:

    ...

    on master, "apt-get install -y rubygems git"
    on master, "apt-get install -y puppet-common=#{version}-1puppetlabs1 puppetmaster-common=#{version}-1puppetlabs1 puppetmaster=#{version}-1puppetlabs1 "
    on master, "echo '*' > /etc/puppet/autosign.conf"

    ...

So we have already installed puppet at a previous stage in our script. At this point we are performing all the steps required to install the
puppetmaster: git, rubygems (if on an older distro) and the puppetmaster packages. We also making sure that we auto-signing if configured to
save us some pain later on. This step should really be configured as another beaker method that we can just call but for now it is still manual.
It is at this point that we have first introduced the "on master" this does what you think it might, it executes the command you pass it onto
the host with the nodeset role on 'master'.

###Set the puppet.conf file:

    ...

    config = {
      'main' => {
        'server'   => master_name,
        'certname' => master_name,
        'logdir'   => '/var/log/puppet',
        'vardir'   => '/var/lib/puppet',
        'ssldir'   => '/var/lib/puppet/ssl',
        'rundir'   => '/var/run/puppet'
      },
      'agent' => {
        'environment' => 'vagrant'
      }
    }

    configure_puppet(master, config)

    ...

Here we are configuring out puppet.conf file, making sure that it includes any customization we might need. This uses a configure_puppet method
that we have added to beaker to allow us to do this customization and in this case it is taking the hash to modify the puppet.conf file on the master
host.

###Install the required ruby gems:

    ...

    on master, "gem install bundler"
    on master, "gem install hiera-eyaml"
    on master, "cd /etc/puppet && bundle install --without development"

    ...

The average production-ready puppetmaster also requires a number of gems to function such as hiera-eyaml, deep_merge any many others
depending upon what backends and other custom puppet extensions you have implemented. Here we are installing all our dependencies from
the Gemfile we have already put onto the host.

###Installing modules:

    ...

    on master, "cd /etc/puppet && bundle exec librarian-puppet install"

    ...

The last major step is installing any external modules you have. You may be using librarian-puppet or r10k to do this. In our case it
is the former so we go ahead and make sure that our modules directory is full of all the modules we require.

###Networking:

    ...

    master_name = "#{master}.test.local"
    on master, "echo '10.255.33.135   #{master_name}' >> /etc/hosts"
    on master, "hostname #{master_name}"
    on master, "/etc/init.d/puppetmaster restart"

    ...

This last step is a small hack that you will probably require if you are running on vagrant. It just configures the host file to make
sure that it's hostname if configured correctly from certificate signing to work as expected. This might not be required in your
environment and I would try it without first but it's worth noting anyway.

## Configuring the agent
So if you've got to this point well done - most of the hard work is done. Configuring the agent(s) is pretty straightforward in comparison
to a puppetmaster and some of the steps are similiar:

### Set the puppet.conf file:

    if host['roles'].include?('master')
      ...
    else
      agent = host
      master = only_host_with_role(hosts, 'master')
      agent_name = agent.to_s.downcase
      master_fqdn = "#{master}.test.local"
      agent_fqdn = "#{agent_name}.test.local"

      if agent['platform'] =~ /windows/
        config = {
          'main' => {
            'server'   => master_fqdn,
            'certname' => agent_name,
            'logdir'   => 'C:\\ProgramData\\PuppetLabs\\puppet\\var\\log',
            'vardir'   => 'C:\\ProgramData\\PuppetLabs\\puppet\\var\\lib',
            'ssldir'   => 'C:\\ProgramData\\PuppetLabs\\puppet\\var\\lib\\ssl',
            'rundir'   => 'C:\\ProgramData\\PuppetLabs\\puppet\\var\\run'
          },
          'agent' => {
            'environment' => 'vagrant'
          }
        }
      else
        config = {
          'main' => {
            'server'   => master_fqdn,
            'certname' => agent_fqdn,
            'logdir'   => '/var/log/puppet',
            'vardir'   => '/var/lib/puppet',
            'ssldir'   => '/var/lib/puppet/ssl',
            'rundir'   => '/var/run/puppet'
          },
          'agent' => {
            'environment' => 'vagrant'
          }
        }
      end
      ...

      configure_puppet(agent, config)
    end

    ...

Again here we are again using the configure_puppet method, this time change the puppe.conf file on the agent.

As you can see we are catering for both windows and linux hosts here. We are also making sure that the certname
and server are defined properly and match what we set-up for the master so that auto-signing works correctly.

## Testing the Role
At this point we have now does all our prerequisites and we can spin up two machines to test against - 1 master and
1 agent. But when we are testing a role what is it that we actually want to test and why is this not covered in
earlier less-expensive puppet-rspec unit tests?

Well there are 3 key things that we wanted to test:
1. Idempotence <br/> This is pretty straight forward to test. Beaker provides a method run_agent_on that will run the puppet agent on a
  given host. This means we can test idempotency like this:

       run_agent_on(agent, :catch_failures => true)
       expect(run_agent_on(agent, :catch_failures => true).exit_code).to be_zero

2. Interaction of multiple modules and profiles <br/> This is the big motivator - we want to test that and make sure that the combinations
of profiles that we are applying work together and do not either break the catalog or operate in a non-idempotent way. We are also gaining
the ability to test that updates in modules (many of which are external from the puppet forge) do not break our roles in any way.

3. Postivie/Negative testing - do we clean up after ourselves if we remove something. <br/> This is not something that is often considered
very often, particularly in a world where machines are torn down and re-build so often but there still exists a use-case where this is not
always possible and we want to make sure that our roles and manifests are not littering our machines unnecessarily.

Below is a full example of one of our linux profiles:

    require 'spec_helper_acceptance'

    describe 'linux_base_profile', :if => fact('osfamily').eql?('Debian') do
      context 'linux base profile' do
        it 'should should run successfully' do

          agent = only_host_with_role(hosts, 'agent')
          master = only_host_with_role(hosts, 'master')

          pp = "node \"#{agent}\" { include profiles::linux::base }"
          on master, "echo '#{pp}' >> /etc/puppet/manifests/site.pp"

          run_agent_on(agent, :catch_failures => true)
          expect(run_agent_on(agent, :catch_failures => true).exit_code).to be_zero
        end

        context 'installation of ops tools' do

          describe package('sysstat') do
            it { should be_installed }
          end

          describe package('iotop') do
            it { should be_installed }
          end

          describe package('ngrep') do
            it { should be_installed }
          end

          describe package('lsof') do
            it { should be_installed }
          end

          describe package('unzip') do
            it { should be_installed }
          end
        end

        context 'managing puppet version' do

          describe file('/etc/apt/sources.list.d/puppetlabs.list') do
            it { should be_file }
            it { should be_owned_by 'root' }
            it { should be_mode 644 }
          end

          describe package('puppet') do
            it { should be_installed.by('apt').with_version('3.6.1-1puppetlabs1') }
          end
        end

        context 'manage sshd configuration' do

          describe process("sshd") do
            it { should be_running }
          end

          describe port(22) do
            it { should be_listening }
          end

          describe file('/etc/ssh/sshd_config') do
            its(:content) { should match /PermitRootLogin no/ }
            its(:content) { should match /PasswordAuthentication yes/ }
            its(:content) { should match /UseDNS no/ }
          end
        end
      end
    end

We have a lot of roles and profiles that we would like to test. As you might imagine this could get quite verbose and repetitive pretty quickly. We are currently building
up [shared_contexts](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-context) for each of our profiles which we can
then wrap up into roles to easily reflect our roles/profiles structure in the main codebase.

## Summary
We are just at the very beginning of this journey with Beaker. As well as testing all our modules we are looking to scale our to test the roles and profiles in our whole
code base. These examples here are how we are doing it at the moment for our mixed-platform environment. We will continue to expand upon it and build it into our pipeline.
At this moment we are looking to expand beyond vagrant and run these against AWS instances but perhaps that is for the next post ...

As usual for any questions or comments then please reach out to me on twitter [@liamjbennett](https://twitter.com/liamjbennett)
