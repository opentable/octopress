---
layout: post
title: "Supporting IE8 in the OpenTable redesign"
date: 2014-12-08 21:14:57 +0000
comments: true
author: jcatterfeld
categories: [CSS, Sass, Design, "Internet Explorer", OpenTable, Grunt]
---

We're really [proud to have released](http://blog.opentable.com/2014/opentables-website-re-designed-re-architected-re-imagined/) last week our redesigned [OpenTable](http://www.opentable.co.uk) site, the culmination of months of hard work from many talented people here in London and in San Francisco.

However despite killing off our old site and its 2004 design, 2.8% of our visitors could have been crying into their keyboard as a far worse opentable.co.uk filled their screen.

That version of OpenTable was our new responsive site viewed in Internet Explorer 8.

![Our redesign before we optimised for IE8](/images/posts/redesign-ie8.png)

The fundamental issue is that IE8 doesn't support media queries so the age-old browser would try to stretch our _mobile-first_ responsive design as wide as it could go - not great across a 27" Thunderbolt.

To solve the problem we first tried the [Respond.js](https://github.com/scottjehl/Respond) polyfill but this didn't work as we'd hoped.  The main issue appeared to be that because we serve our CSS and JS on a separate sub-domain we fell foul of the browser's cross-domain security.  We followed the Respond.js instructions to solve this but having no luck we looked for alternatives.

## Legacssy

Further Googling lead us to [Legacssy](https://github.com/robinpokorny/grunt-legacssy). With this Grunt task we could create a IE8-only stylesheet and not have to serve extra JS and cross-domain proxy files to all visitors.

Our existing process is to create our core CSS with an `app.scss` file and [grunt-sass](https://github.com/sindresorhus/grunt-sass).  Our additional step was to create an `app_ie8.scss` file, parse it with `grunt-sass` like before, but then also run it through Legacssy.

### Our app.scss file

	@import 'normalize';

	@import 'components/global';

	@import
	  'components/icons',
	  'components/buttons',
	  'components/calendar',
	  'components/forms',
	  'components/pagination',
	  'components/star-rating';

	@import
	  'partials/footer',
	  'partials/header',
	  'partials/location-picker';

### And our app_ie8.scss file

	@import ‘app';
	@import 'browsers/_ie8.scss';


This process left us with a duplicate of the main site CSS that would be IE8 friendly - and as you can see we are also able to merge in an IE8 specific stylesheet with further overrides.  All we now needed to was serve this inside conditional comments after the main stylesheet, and CSS specificity would ensure our IE rules overwrite the media queries.


```
<!--[if lte IE 8]>
<link rel="stylesheet" href="//eu-srs.opentable.com/content/static/css/app_ie8.css" />
<![endif]—>
```

## Drawbacks

We are very happy with this solution as it generates the IE8 fixes as part of our automated build with no extra effort.  The only obvious negative is for the IE8 visitors who will effectively be downloading the same stylesheet twice, but if they are routinely browsing the web with IE8 this could be the least of their worries.

## Conclusion

We're really proud of our new site; we're still ironing out some kinks but we hope that it's good enough for those of you who visit us with Internet Explorer 8 (probably through no fault of your own).

For the record, here a couple of other issues we found which may help other intrepid developers with their IE debugging in 2015 and beyond.

### Other IE8 issues

* The other unsupported CSS values were rem units and RGBA colours.  After running Legacssy we used [pixrem.js](https://github.com/robwierzbowski/grunt-pixrem) to replace rems with pixels and a custom task to replace RGBA values with their HEX equivalents.
* IE11's F12 developer tools don't render identically to native IE8. We used Microsoft's excellent [modern.ie](http://www.modern.ie) site to download virtual machines with Windows 7 and IE8.
* We only tested on Windows 7 as this makes up 66% of our IE8 visitors. The remainder are on different operating systems which collectively only make up 0.95% of our total visitors; this is below our threshold for support.