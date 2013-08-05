---
layout: post
title: "Managing Windows Certificates with PowerShell"
date: 2013-07-08 18:51
comments: true
author: pstack
categories: [PowerShell, automation, devops]
---
Managing certificates on Windows is *really* painful. There is no easy way to do it. The general way to install a certificate to a Windows Server 2008 machine is as follows:

* Open the Certificates snap-in for a user, computer, or service.
* In the console tree, click the logical store where you want to import the certificate.
* On the Action menu, point to All Tasks, and then click Import to start the Certificate Import Wizard.
* Type the file name containing the certificate to be imported. 
* If you want to specify where the certificate is stored, select Place all certificates in the following store, click Browse, and choose the certificate store to use. OR
* If the certificate should be automatically placed in a certificate store based on the type of certificate, click Automatically select the certificate store based on the type of certificate.

The first time I ran this process, I felt as though this was just wrong to not be able to automate. The goal of our team is to automate everything we are currently doing manually. PowerShell is a better option for this import process as it allows you to write code to do it. As we all know, code is better for a number of reasons, I won't go into the infrastructure as code argument in this post (but it is coming soon….). Using PowerShell, I can write a simple function as follows:

	function Import-PfxCertificate($certName, $CertLocaton, $certRootStore, $certStore) {    
	     $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2    
  
         $pfxPass = convertto-securestring $CertPassword -asplaintext -force

         $certPath = $CertLocaton + "\" + $certName   
         $pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet")    
  
         $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)    
         $store.open("MaxAllowed")    
         $store.add($pfx)    
         $store.close()    
    }
This makes certificate management easier. To manage certificates in this way, I just need to invoke a script similar to this:

    .\import-certificate.ps1 -CertificateName "mycert.pfx" -CertLocation "c:\ssl\mycerts"
    
Much simpler! You can download a [gist](https://gist.github.com/opentable-devops/5951108) of this script should you wish to use it. Please note that the license that this script is available under can be read from our [github repository](https://github.com/opentable/licensing/blob/master/LICENSE). 