---
layout: post
title: "Hobknob v1.0: Now with authorization"
date: 2014-10-22 14:00:31 +0100
comments: true
author: criddle
categories:  [Hobknob]
---
We are pleased to announce the version 1.0 release of [Hobknob](https://github.com/opentable/hobknob), our open-source feature toggle management system. With it comes a few additions and several improvements. 

This post will expand on some of the changes, in particular, authorisation via access control lists.

For an introduction to Hobknob, see our previous post: [Introducing Hobknob: Feature toggling with etcd](http://tech.opentable.co.uk/blog/2014/09/04/introducing-hobknob-feature-toggling-with-etcd/).

Authorisation with ACLs
---
A much requested feature was the ability to control who can add/update/delete toggles on an application by application basis. We achieve this via the use if an Access Control List for each application. Users that are part of the ACL for an application are known as application owners.

![Hobknob Owner List](/images/posts/hobknob-owners.png)

Application owners can (for an owned application):

- Add toggles
- Set the value of a toggle
- Delete toggles
- Add additional owners
- Remove owners

Everyone can:

- Add an application
- See toggles
- See application owners
- See the audit trail for a toggle

When a user creates an new application, they are automatically added as an owner for that application.
The user can then add other application owners by clicking the 'Add user' button in the Owners panel and entering the users email address.

**Note:** this feature is only available when authentication is enabled. If Hobknob is not configured to require authentication, everyone has owner permissions to all applications. See the [readme](https://github.com/opentable/hobknob#configuring-authentication) for more information on how to configure authentication.

Deleting Toggles
---
Feature toggles can now be deleted. This ability is available on the toggle view (get there by clicking a toggle name in the application view).

![Hobknob Toggle Delete](/images/posts/hobknob-delete.png)

You'll notice the delete toggle button in the Danger Zone panel (we didn't steal that idea from Github, honest). You'll need to confirm the delete by clicking the delete button a second time.

**Warning:** Deleting a toggle will perform a 'hard' delete, that is, the key is deleted in etcd. The audit will persist however, and can be accessed via this route: `/#!/applications/app-name/toggle-name`. You are also allowed to re-add a toggle, and the audit will be appended to an existing audit for that toggle name.

**Note:** If authentication is enabled, you must be an application owner to delete a toggle.

Makeover
---
Gone is the 'Add Toggle' modal dialog from the previous version. This is replaced by two separate inline forms.

Applications are now added by clicking 'Add' in the sidebar.

![Hobknob New Application](/images/posts/hobknob-newapplication.png)

Toggles are added by clicking 'New Toggle' in the Toggles panel for an application.

![Hobknob New Toggle](/images/posts/hobknob-newtoggle-v2.png)

