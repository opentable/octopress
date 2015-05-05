---
layout: post
title: "Puppet-Community"
date: 2015-05-01 14:27:55 +0100
comments: true
author: lbennett
categories: [Puppet, puppet-community]
---

Puppet is an important tool to us at OpenTable, we couldn’t operate as efficiently without it but puppet is more than a tool or a vendor, it is a community of people trying to help
each other operate increasing complex and sophisticated infrastructures.

The puppet community and the open source efforts that drive that community have always been important to us which is why we want to take a step further in our efforts and introduce
you to the "puppet-community" project.

##What is puppet-community
Puppet-community is a github organisation of like-minded individuals from across the wider puppet ecosystem and from a diverse set of companies. It’s principle aims are to allow the
community to synchronise it’s efforts and to provide a github organisation and puppet forge namespace not affiliated with any company.

It’s wider aims are to provide a place for module and tool authors to share their code and the burden of maintaining it.

I would like to say that this was our idea, as it’s an excellent one, but actually all credit goes to it’s founders: [Igor Galić](https://github.com/igalic), 
[Daniele Sluijters](https://github.com/daenney) and [Spencer Krum](https://github.com/nibalizer)

##Why communities matter
So why all the fuss about this? Why does it even matter where your code lives?

Well these are the some questions that I asked myself when I first heard about this project at PuppetConf 2014. The answer is that is really does matter and it’s a pattern that is 
developing elsewhere (see: [packer-community](https://github.com/packer-community), [terraform-community-modules](https://github.com/terraform-community-modules), 
[cloudfoundry-community](https://github.com/cloudfoundry-community)) to deal with the problems you’ll face with a large amount of open source code.

Stepping back slightly, if you look at open source then are three types: product-based (think open-core), corporate/individual sponsored,  and community-driven.

The first is common for businesses (like PuppetLabs) who’s product is a open source product. They make great efforts to build a community, fix bugs and accept changes. They make 
their money through extras (add-ons and/or professional services). They control what they will/won’t accept and are driven by the need to build that community as well as support 
those big paying customers who pay the bills - it’s a tough balancing act.

The second is what you probably mean when you think about open source. It’s a individual or company that dumps some code they have been working on to github and that’s it - they own 
it, they control it, it they don't like your changes they don’t even have to give a reason. They can also choose to close or delete the project whenever they want or more likely they 
will just let it sit on github and move onto the next thing.

The third is the community approach. Create a github organisation, move your projects and add some new people in there with commit access. This is a different approach because it means 
that you don’t own it any more, you don’t have that tight control over the codebase because there are other people with other opinions that you have to take into account. It also means 
that on long weeks when you're on-call or on holiday that there is someone else to pick up the slack and merge those pull requests for you. It has massive benefits if you can keep that 
ego in check.

##Why we’re moving our modules there
So why is OpenTable moving it’s modules there? It is because we care about the community (particularly those using puppet on windows) and want to make sure there is good long term 
support for the modules that we authored. OpenTable isn’t a company that authors puppet modules, it is a company that seats diners in restaurants so from time to time we are going 
to work on other things.

By being part of the community there will be other people who can help discuss and diagnose bugs, merge pull requests and generally help with any problems that arise when using 
the modules we created.

Sometimes when writing a module it’s not about being the best, sometimes it’s just about being first - we got a bit lucky. What that means though is that we need to recognise that there
are plenty of people out there in the community that have better knowledge than us about a tool or application and might be better suited to guide the project forward - heck we might 
even learn from them in the process.

So let’s lose our egos, loosen that grip and let those modules be free ...

##What that means for you
Ok, so let’s get practical for a second. What’s happening here? What our support of puppet-community means is that our code has moved into a new organisation 
([github.com/puppet-community](https://github.com/puppet-community)) and our modules have been re-released under the community namespace on the forge 
([forge.puppetlabs.com/puppet](https://forge.puppetlabs.com/puppet)). So if you are using our modules then you should go and have a look on the forge and update to the latest versions. 
We will continue to provide lots of support to these modules but so will lots of others (including some PuppetLabs employees) so expect the quality of the modules to also start increasing.

If you have any thoughts or questions about this you can reach out to me personally on twitter: [@liamjbennett](twitter.com/liamjbennett) or via email at: [liamjbennett@gmail.com](mailto:liamjbennett@gmail.com)
