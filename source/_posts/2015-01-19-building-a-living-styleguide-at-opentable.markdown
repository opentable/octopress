---
layout: post
title: "Building a living styleguide at OpenTable"
date: 2015-01-19 17:00:00 +0000
comments: true
author: jcatterfeld
categories: [UI, Design, OpenTable, CSS, Styleguide]
---

If you're reading this you've probably built yourself a website.  A site - large or small - that's thrown together or crafted over many months.  And if you have, you’ve probably kept all your CSS class names in your head, or at least been able to go straight to the relevant stylesheets to retrieve them.

Well OpenTable is unsurprisingly built by many engineering teams across multiple continents, and was completely redesigned last year.  And as soon as you have more than a handful of people working on your front-end you will quickly find a well-intentioned developer causing one or both of these problems:

- Well-intentioned developer adds a new submission form but, like the design Philistine he is, his buttons are <span style="font-family:verdana;font-size:18px;color:#E40000;">18px Verdana #E40000</span>, not the correct <span style="font-family:arial;font-size:16px;color:#DA3743;">16px Arial #DA3743</span>
- Your good old developer knows which font size and colour it should be, but bungs a duplicate class into a random stylesheet (or worse still, inline)

Despite these risks, a single front-end dev (or a team of them) cannot check every new piece of code or they will quickly become a bottleneck.

### You need some guidelines

Offline designers regularly create ‘brand guidelines’ or ‘design standards' to document the precise way their brand or product should be recreated when outside of their control.  Online, such guidelines are similarly invaluable for maintaining brand and code consistency with multiple engineers and designers, but it is blindingly obvious that a printed or ‘static’ set of guidelines is completely unsuitable for a constantly changing website.

Step forward a ‘living’ styleguide.

A living styleguide gives a visual representation of a site’s UI elements using **the exact same code** as on the website, in most cases via the live CSS.  A living styleguide may also provide reusable CSS and HTML code examples and they are not just for engineers new to the code; I frequently use ours at OpenTable and I wrote the stylesheets in the first place (I can’t be expected to remember everything).

Providing reusable code improves collaboration, consistency and standards, and reduces design and development time - but like most documentation it is essential your guide is always up-to-date and trustworthy.  So if a living styleguide is (theoretically) always up-to-date, how did we build ours?

## How we built our styleguide

Living styleguides are not new (although they were [one of the trends of 2014](http://sideproject.io/an-exhaustive-look-at-the-year-in-web-design/#styleguides)) and as such many frameworks have been built over the years.  We chose to use [Kalei](http://kaleistyleguide.com/) by [Thomas Davis](https://github.com/thomasdavis) - I forget the exact reasons why but it was probably the easiest at the time to set up and customise.

Generating a Kalei styleguide is as simple as adding comments to your stylesheet; Kalei uses a variety of frameworks, including [Backbone.js](http://backbonejs.org/), [JSCSSP](http://www.glazman.org/JSCSSP/) and [Marked](https://github.com/chjj/marked) to convert these comments into HTML mark-up, generate a list of your individual stylesheets as navigation and present these as a single page web app.

For example in your `buttons.css` file it is as simple as adding the following comments:

	/*!
	# Primary buttons
	Primary buttons are only used when there is an exceedingly distinct and clear call-to-action.
	```
	<a href="#" class="button">Button</a>
	<a href="#" class="button secondary">Button secondary</a>
	<a href="#" class="button success">Button success</a>
	<a href="#" class="button alert">Button alert</a>
	```
	*/

Which, by using the CSS in the file itself, Kalei would visually render like so:

![styleguide-buttons-screenshot](/images/posts/styleguide-buttons-screenshot.png)

### Customising Kalei

Kalei works well out-of-the-box but we had to make a few customisations.  These were mostly cosmetic changes, but a fundamental changes was to **add support for Sass**.  For this we wrote a Grunt task imaginatively called `grunt styleguide` in which we combined _Clean_, _Copy_, _Scss_ and _Replace_ tasks.  Unsatisfactorily it took a little while to set up and involved a number of steps, but below is simplification of the process.

1. Clean all CSS files from the styleguide, excluding Kalei specific stylesheets
1. Copy our partial scss files into a temporary folder and rename them to remove the underscore (partial scss files begin with an underscore are are [not compiled by default](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#partials))
1. Compile the scss files into CSS in the styleguide directory
1. Copy across dependent fonts and images, using _Replace_ to update the relative paths
1. Delete the temporary directory

This task is run as a deployment step and can be run locally when developing the guide.

Other that a few small UI tweaks we made one significant changes to the look and feel.  By default the navigation lists stylesheets using their full file name, e.g. **breadcrumbs.css** and **buttons.css**.  Using a regex function in the `menu.js` file and `text-transform: capitalize` in the Kalei stylesheet we modify the navigation to display the more attractive headings **Breadcrumbs** and **Buttons**.

View our styleguide at <a href="http://www.opentable.com/styleguide" target="_blank">opentable.com/styleguide</a>.

## What's next?

Our living styleguide is intended to be an organic resource that we will grow and refine into an integral part of our software development.  We have many ideas for how we want to develop the guide - at the very least it is currently incomplete insomuch as we have not documented every one of our stylesheets.

There is also a fundamental weakness to this type of styleguide, which is duplication of code.  Whilst we use the exact same CSS as our live site, we are copying and pasting mark-up into these files and this content can go out of date without deliberate upkeep.  At OpenTable we have a _site resource service_ which serves HTML snippets to different internal microsites so one option could be to use this service to integrate these snippets into the styleguide.  We may also investigate a solution using [web components](http://webcomponents.org/) as cross-browser support is not a concern.

We are also interested to see whether it would be useful to run UI tests against the styleguide. We have used [pDiff](http://pdiff.sourceforge.net/) in the past for visual regression on specific microsites, but the styleguide could be an opportunity to catch accidental, global UI changes.  We are going to look at running [BackstopJS](https://garris.github.io/BackstopJS/) against each section of the guide to see if this increases its usefulness.

Finally, as one of the developers who created the styleguide I want it to be widely adopted across OpenTable. I want designers and engineers to contribute to the code and use it for their day-to-day designing and developing, and I want product owners and marketing folks to use it when creating promotional material and A/B tests.  My ultimate goal is for it to be an integral tool enabling everyone to work faster, avoid duplication and maintain a consistent brand identity.

## Read more

- View an online directory [of styleguide articles and examples](http://styleguides.io/)
<!-- - Join us - [apply for our senior front-end engineer role at OpenTable, London.](https://hire.jobvite.com/Jobvite/Job.aspx?b=nlsWXpwA&j=oXeiYfwb) -->
