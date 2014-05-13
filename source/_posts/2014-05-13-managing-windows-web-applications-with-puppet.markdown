---
layout: post
title: "Managing Windows Web Applications with Puppet"
date: 2014-05-13 15:25:16 +0100
comments: true
author: pstack
categories: [puppet, powershell, configuration management, devops]
---
As part of our move towards a configuration management tool, we really wanted to start automating as much of our infrastructure as possible. This included our application configuration stack. IIS management is pretty easy with PowerShell. It would look something like this

    Import-Module WebAdministration
    New-WebSite -Name "DemoSite" -Port 80 -IP * -PhysicalPath "c:\inetpub\wwwroot" -ApplicationPool "MyAppPool"

This would of course set up a website called 'DemoSite' running on port 80 on the local machine. The cmdlets that come with PowerShell make this pretty easy. This is great if it is a one-off job to set up a site. We run our websites from a number of webservers, therefore, it would be silly to have to RDP into each webserver and run a script on it. This is why tools like Puppet, Chef, Ansible etc. exist. We needed a configuration management tool to do this work for us. It has a number of benefits:

* Orchestration
* Idepotency
* Makes sure that each server is configured in 'exactly' the same way as no human intervention is needed
* Developers can help the operations team by creating the scripts needed. This is great for collaboration between teams

On investigating how we would do this with Puppet, we noticed that there were not many other people managing their site in this way. Therefore, we would have to turn our PowerShell scripts into Puppet modules to manage our system. 

We have since created a Puppet module to manage IIS module. To manage IIS with Puppet, we can now write the following code:

    iis::manage_site { 'DemoSite:
       site_path     => 'c:\inetpub\wwwroot',
       port          => '80',
       ip_address    => '*',
       app_pool      => 'MyAppPool'
    }

This would produce **exactly** the same results as the code from above. But it has 1 difference. There are checks in the code behind this module that will mean the code will only execute when it is needed, i.e. when the site_path isn't correct or the app_pool isn't correct. This is idempotency. The script can be run again and again and again....

To create an application binding, we used to do this in PowerShell:

    Import-Module WebAdministration
    New-WebBinding -Name 'DemoSite' -Port '8080' -IPAddress '*'

This would set up an extra binding on port 8080 for the site, DemoSite. We replaced this code with our puppet equivalent:

    iis::manage_binding { 'DemoSite-8080':
      site_name   => 'DemoSite',
      protocol    => 'http',
      port        => '8080',
      ip_address  => '*',
    }

To create a virtual application, we would write the PowerShell:

    Import-Module WebAdministration
    New-WebApplication -Name 'VirtualApp' -Site 'DemoSite' -PhysicalPath 'c:\inetpub\wwwroot\MyVirtualApp' -ApplicationPool 'MyAppPool'

This will create a VirtualApp folder on the DemoSite, use the same application pool and then set the path of the folder. I can do the same thing in Puppet as follows:

    iis::manage_virtual_application {'VirtualApp':
      site_name   => 'DemoSite',
      site_path   => 'C:\inetpub\wwwroot\MyVirtualApplication',
      app_pool    => 'MyAppPool'
     }  

We can therefore, chain a manifest together that does all this for us in 1 go. It would look as follows:

    class mywebsite {
      iis::manage_app_pool {'MyAppPool':
        enable_32_bit           => true,
        managed_runtime_version => 'v4.0',
      } ->

      iis::manage_site {'DemoSite':
        site_path   => 'C:\inetpub\wwwroot',
        port        => '80',
        ip_address  => '*',
        app_pool    => 'MyAppPool'
      } ->

      iis::manage_virtual_application {'VirtualApp':
        site_name  => 'DemoSite',
        site_path  => 'C:\inetpub\wwwroot\MyVirtualApp',
        app_pool   => 'MyAppPool'
      } -> 

      iis::manage_binding {'DemoSite-8080':
        site_name  => 'DemoSite',
        protocol   => 'http',
        port       => '8080',
        ip_address => '*'
      }
    }

The module does more than just these tasks and I could give more and more examples of what we wrote, but you can find more about our IIS module on the [github repo](http://github.com/opentable/puppet-iis). If you want to use the module, then you can install it using the Puppet Module tool via the [Puppet forge](http://forge.puppetlabs.com/opentable/iis).

We love to hear feedback on things that the module should support. We like Pull Requests even more :)
