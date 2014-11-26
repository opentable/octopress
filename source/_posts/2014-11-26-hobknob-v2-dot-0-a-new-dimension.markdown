---
layout: post
title: "Hobknob v2.0: A new dimension"
date: 2014-11-26 10:11:37 +0000
comments: true
author: criddle
categories:  [Hobknob]
---

Sometimes there is the requirement for more granularity when toggling a feature switch.
Version 2.0 of [Hobknob](https://github.com/opentable/hobknob) hopes to address this with feature categories.

### TL;DR.
Hobknob now allows you define categories of features that have multiple toggles per feature.

For example, you can define the 'Domain Features' category which allows you to toggle a feature OFF in `your-website.com`, but ON in `your-website.co.uk`.

![Domain Features](/images/posts/hobknob-domain-features.png)

## Categories

Feature categories are configured with a few pieces of information. For example:

```json
{
  "categories": [
    {
      "id": 0,
      "name": "Simple Features",
      "description": "Use when you want your feature to be either on or off"
    },
    {
      "id": 1,
      "name": "Domain Features",
      "description": "Use when you want your features to be toggled separately for different domains",
      "values": ["com", "couk", "de", "commx", "jp", "ca"]
    },
    {
      "id": 2,
      "name": "Locale Features",
      "description": "Use when you want your features to be toggled separately for different locales",
      "values": ["en-GB", "en-US", "fr-CA", "de-DE", "ja-JP", "es-MX"]
    }
  ]
}
```
Notice that each category (except the simple feature category) provides an array of accepted toggle values.

All non-simple feature toggles will have the key `application-name/feature-name/toggle-name`.
For example, `main-website/show-user-section/com`.

Simple features will continue to have the key `application-name/feature-name`.

## Setting Toggles

Both simple and non-simple features are added via the application view (which is accessed via the left-hand navigation menu). Simple features are automatically set to false, this value can be changed in the feature view (by clicking the feature name).

A newly added non-simple feature will be initialised with no toggles values. You can add a toggle by clicking the Add Toggle button in the feature view, and choosing which toggle to add. 

![Adding a toggle](/images/posts/hobknob-adding-toggle.png)

New toggles are initially set to OFF. The toggle can be switched in the usual way by clicking the toggle button. You should also see an audit of the change in the panel below.

## Getting Toggles

All of the Hobknob [clients](https://github.com/opentable/hobknob#hobknob-clients) now support getting non-simple features toggles. The only requirement is to pass the name of the toggle, so for example in node:

```javascript
var nonSimpleFeatureInCom = hobknobClient.getOrDefault('feature-name', 'com', false);
```

It is highly reccommended that you use the get or default methods when accessing non-simple features. Getting a toggle that does not exist for a non-simple feature could be a likely scenario, since you might want to only set a feature for a few toggles explicitly (e.g. com and couk) and then use the default value for the rest (e.g. jp and de).

The behaviour for simple features has not changed, and is backwards compatible in all client libraries.

```javascript
var simpleFeature = hobknobClient.getOrDefault('simple-feature', true);
```
