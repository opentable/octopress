---
layout: post
title: "Managing Windows Features with Puppet"
date: 2014-05-15 16:12:38 +0100
comments: true
author: pstack
categories: [Configuration Management, DevOps, PowerShell, Puppet, Windows, WindowsFeature]
---
Back in June 2013, I wrote about [Windows Feature Management with PowerShell](). We have since released a Puppet module that will do this for us. We originally wrote PowerShell:

    Import-Module ServerManager
    Add-WindowsFeature Web-Asp-Net

The Puppet module now wraps this code as follows:

    windowsfeature { 'Web-Asp-Net': }

The declaration windowsfeature is a specific Puppet type called a [define](). In developer terms, this is the equivalent of a helper method that can be reused. We can also make sure that Windows Features are *not* installed on the server as follows:

    windowsfeature { 'Telnet-Server': 
      ensure => absent 
    }

In the backing code for the module, we do a check before we install / uninstall any windows features. This means that we will only make the changes we really need to. This ensures idempotency of the script. By using this class, we can build up a list of what features a server should have enabled / installed on it. As example manifest would look as follows:

    class my_windows_features {
      windowsfeature { 'Web-Asp-Net': }
      windowsfeature { 'Web-Net-Ext': }
      windowsfeature { 'Web-ISAPI-Ext': }
      windowsfeature { 'Web-ISAPI-Filter': }
      windowsfeature { 'Web-Mgmt-Tools': }
      windowsfeature { 'Web-Mgmt-Console': }
      windowsfeature { 'Telnet-Server': ensure => absent }
    }

The server will have it's shipping list of Windows Features checked every 30 minutes by Puppet. We are sure that any changes encountered during that time will be applied as expected.  You can find more about our WindowsFeature module on the [github repo](http://github.com/opentable/puppet-windowsfeature). If you want to use the module, then you can install it using the Puppet Module tool via the [Puppet Forge](http://forge.puppetlabs.com/opentable/windowsfeature)
