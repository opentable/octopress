---
layout: post
title: "Linking to your app in Windows 8"
date: 2013-10-21 17:36
comments: true
author: jcatterfeld
categories: OpenTable, Windows8
---

In an effort to raise the visibility of our excellent Windows 8 app we have recently connected [www.opentable.com][1] to the Windows Store.  This was simply a case of adding two lines of meta data to our site. Or it should have been &ndash; there were several gotchas along the way that are worth sharing.

##The code

The meta data that we added to the site are an _application ID_, and what Microsoft have termed the _Package Family name_.  Once you have these, add the following lines of code to your page &lt;head&gt;.


	<meta name="msApplication-ID" content="OpenTable.OpenTable"/> 
	<meta name="msApplication-PackageFamilyName" content="OpenTable.OpenTable_r44en0zefym0a"/>



{% img right /images/posts/get-app-for-this-site.png %}

This will enable the **"Get app for this site"** link when you are viewing your page in the full-screen Metro version of Internet Explorer (i.e. launched from the start screen); the desktop version of IE doesn't have this capability.

There are [three other optional meta values][2] that can also be used to control your link.


##Finding the values

There are at least two ways of finding the values. If you have your application code and Visual Studio 2012 (or later) then the values can be found in the **package.appxmanifest** file &ndash; open this in VS and it automatically launches the manifest designer view.  Select the Packaging tab and the "Package name" is the _ID_, and the _Package family name_ is at the bottom of this screen.

{% img center /images/posts/vs-screenshot.png %}

If you don't have the local code with Visual Studio you can still find out these values by other means.

The **msApplication-PackageFamilyName** can be found in the source code of your online Windows 8 app.  For example, [viewing the source of the OpenTable app][3] shows a Javascript variable `packageFamilyName` embedded in the page head.

	var packageFamilyName = 'OpenTable.OpenTable_r44en0zefym0a';

The **msApplication-ID** is still found in the `package.appxmanifest` file in your Win8 app, but you don't necessarily need to have the local code or Visual Studio.  We were able to access package.appxmanifest in our GitHub repo (it's an XML file) and the msApplication-ID was the same as the **identity name**.  I don't know if the Application ID and the identity name are always the same, but they were for us.

	<Identity Name="OpenTable.OpenTable" Publisher="CN=9C8CE42A-5BD4-4679" Version="1.0.0.1910" /> 


##Gotchas

We tried opening the site in Visual Studio 2012 in Windows 7, but the project containing package.appxmanifest wouldn't open.  We had to open the solution in Windows 8, which finally worked once we'd logged into MSDN and installed the suggested updates.

Also, the content values of the meta data are not case sensitive, but the names msApplication-ID and msApplication-PackageFamilyName are.

Finally, having entered what we knew to be the correct values, clicking the "Get app for this site" link still wouldn't take us to [the OpenTable app in the Windows store][4].  After checking with an American colleague the penny dropped that the OpenTable app is only available in the US and Microsoft have unfortunately not provided any visual feedback to explain this.

Luckily instead of just having to take his word that the new code worked there is a way to change your Windows Store settings and fake your location.  [Have a look at this helpful article][5] and you're all set to have your website and Windows app happily talking to each other.

###Further reading

- [Connect your website to your Windows Store app][6] (Internet Explorer Dev Center)
- [Linking to your apps on the web][7] (MSDN blog)

[1]: http://www.opentable.com
[2]: http://msdn.microsoft.com/en-us/library/ie/hh781489%28v=vs.85%29.aspx#code-snippet-1
[3]: view-source:http://apps.microsoft.com/windows/en-us/app/d7c37fb3-d594-4366-8003-e49c8e953095
[4]: http://apps.microsoft.com/windows/en-us/app/d7c37fb3-d594-4366-8003-e49c8e953095
[5]: http://www.guidingtech.com/20936/change-windows-8-store-region/
[6]: http://msdn.microsoft.com/en-us/library/ie/hh781489%28v=vs.85%29.aspx
[7]: http://blogs.msdn.com/b/windowsstore/archive/2012/02/22/linking-to-your-apps-on-the-web.aspx