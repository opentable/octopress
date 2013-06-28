---
layout: post
title: "Windows Feature Management with PowerShell"
date: 2013-06-14 20:31
comments: true
author: pstack

categories: [powershell, automation, devops]
---
In late 2012, our development team started to move towards our systems being much more automated. Long gone are the days of developers creating runbooks in Word and giving them to our operations team to use to set up our production servers. 

When building our webservers on Windows, in order to install / activate Windows features, this was the general set of instructions that was needed to be followed:

* Click Start Button
* Click on Control Panel
* Click on Programs
* Click on Turn Windows features on or off

This would present a screen as follows:

![image](../images/posts/windowsfeature.PNG)

You would need to find the correct features to enable and check the box, press OK and then wait for the features to be installed. 

When Microsoft introduced Windows Server 2008 and PowerShell 2.0, they also introducted the module 'ServerManager'. This is a module that allows us to interact, with PowerShell, Windows Features using a range of cmdlets:

* Get-WindowsFeature
* Add-WindowsFeature
* Remove-WindowsFeature

This meant that instead of creating runbooks in Word, our developers could create automation scripts that would take a base Windows Server 2008 server and enable all the Windows Features needed to run our applications. This allowed our operations team to move much faster in configuring our servers. 

To turn on the ASP.NET Application Development features in Windows, we would run the following script from PowerShell:

	Import-Module ServerManager
	Add-WindowsFeature Web-Asp-Net
	
By knowing what Windows Features we needed to install on our servers, we were able to create the following script:


	function enable_net_3_5_features()
	{
    	Add-WindowsFeature NET-HTTP-Activation
    	Add-WindowsFeature NET-Win-CFAC
    	Add-WindowsFeature NET-Non-HTTP-Activ
    	Add-WindowsFeature AS-MSMQ-Activation
	}

	function enable_iis_common_http_features()
	{
	    Add-WindowsFeature Web-Static-Content
	    Add-WindowsFeature Web-Http-Errors
	    Add-WindowsFeature Web-Default-Doc
	}

	function enable_iis_application_development_features()
	{
	    Add-WindowsFeature Web-Asp-Net
	    Add-WindowsFeature Web-Net-Ext
	    Add-WindowsFeature Web-ISAPI-Ext
	    Add-WindowsFeature Web-ISAPI-Filter
	}

	function enable_iis_health_and_diagnostics_features()
	{
	    Add-WindowsFeature Web-Http-Logging
	    Add-WindowsFeature Web-Request-Monitor
	}
	
	function enable_iis_security_features()
	{
	    Add-WindowsFeature Web-Filtering
	}
	
	function enable_iis_performance_features()
	{
	    Add-WindowsFeature Web-Stat-Compression
	    Add-WindowsFeature Web-Dyn-Compression
	}
	
	function enable_iis_management_tools()
	{
	    Add-WindowsFeature Web-Mgmt-Tools
	    Add-WindowsFeature Web-Mgmt-Console
	}
	
	
	Write-Host('Starting Application Server Setup')
	
	Import-Module ServerManager
	enable_net_3_5_features
	enable_iis_common_http_features
	enable_iis_application_development_features
	enable_iis_health_and_diagnostics_features
	enable_iis_security_features
	enable_iis_performance_features
	enable_iis_management_tools	
	
	Write-Host('Application Server Setup complete')

Running the script, meant that we could enable features much faster than we could enable them via the GUI. Notice how we have grouped how we enable Windows Features into the same groupings found in the 'Turn Windows features on or off' menu. For a full list of the names of the features that can be turned on or off, please refer to this [technet article](http://technet.microsoft.com/en-us/library/cc732757.aspx)

You can download a [gist](https://gist.github.com/opentable-devops/5886831) of this script if you want to use it. Please note that the license that this script is available under can be read from our [github repository](https://github.com/opentable/licensing/blob/master/LICENSE). We hope that the script helps you as much as it helped us.
