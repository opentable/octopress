---
layout: post
title: "Testing React Components"
date: 2016-01-06 09:00:0 +0100
comments: true
author: ccartlidge
categories: [React, JavaScript, Testing]
---

At OpenTable it’s becoming an increasingly popular trend to use *[React](https://facebook.github.io/react/)*.
One of the reasons for this is the ability for it  to server-side render whilst still
giving us the client side flexibility that we all crave!

We all know to have stable, reliable software you need to have well written tests. Facebook knows this and
provides the handy *[Test Utilities](https://facebook.github.io/react/docs/test-utils.html)* library to make
our lives easier.

Cool — I hear you all say! But what is the best approach to testing React components?

Well unfortunately this is something that is not very well documented and if not approached in
the correct way can lead to brittle tests.

Therefore I have written this blog post to discuss the different approaches we have available to us.

All code used in this post is avaliable on my *[GitHub](https://github.com/chriscartlidge/React-Testing-Blog-Code)*.

##The Basics

To make our lives a lot easier when writing test it's best to use a couple of basic tools. Below is
the absolute minimum required to start testing React components.

- *[Mocha](https://mochajs.org/)* - This is a testing framework that runs in the browser or Node.JS (others are available).
- *[ReactTestUtils](https://facebook.github.io/react/docs/test-utils.html)* - This is the basic testing framework that Facebook provides to go testing with React.

##The Scenario

We have a landing page broken down into 2 separate components:

- Container - The holding container for all sub-components.
- Menu Bar - Contains the site navigation and is always displayed.

![react-comp](/images/posts/react-comp.png)

Each React component is self-contained and should be tested in isolation.

For the purpose of this exercise we will focus on the test for the container component and
making sure that the menu bar is displayed within it.

##Approach 1 (Full DOM):

I like to call this the “Full DOM” approach because you take a component and render it in it’s entirety
including all of its children. The React syntax are transformed and any assertion
you make will be against the rendered HTML elements.

Below is our test scenario written in this approach.

```javascript
import React from 'react/addons';
...
import jsdom from 'jsdom';

global.document = jsdom.jsdom('<!doctype html><html><body></body></html>');
global.window = document.parentWindow;

describe('Container', function () {
  it('Show the menu bar', function () {
    let container = TestUtils.renderIntoDocument(<Container />);

    let result = TestUtils.scryRenderedDOMComponentsWithClass(container,
      'menu-bar-container');

    assert.lengthOf(result, 1);
  });
```
If you run the above test it passes but how does it work?

```javascript
import jsdom from 'jsdom';

global.document = jsdom.jsdom('<!doctype html><html><body></body></html>');
global.window = document.parentWindow;
```
This sets up our DOM which is a requirement of *[TestUtils.renderIntoDocument](https://facebook.github.io/react/docs/test-utils.html#renderintodocument)*.


```javascript
let container = TestUtils.renderIntoDocument(<Container />);
```
*[TestUtils.renderIntoDocument](https://facebook.github.io/react/docs/test-utils.html#renderintodocument)* then takes the React syntax and renders it into the DOM as HTML.
```javascript
let result = TestUtils.scryRenderedDOMComponentsWithClass(container, 'menu-bar-container');
```
We now query the DOM for a unique class that is contained within the menu-bar and get an array of
DOM elements back which we can assert against.

The example above is a common approach but is it necessarily the best way?

From my point of view no, as this approach makes our tests brittle. We are exposing and querying on the inner workings
of the menu-bar and if someone was to refactor it and remove/rename the "menu-bar-container" class then our test would fail.

##Approach 2 (Shallow Rendering):

With the release of React 0.13 Facebook provided the ability to “shallow render” a component.
This allows you to instantiate a component and get the result of its render function, a ReactElement, without a DOM.
It also only renders the component one level deep so you can keep your tests more focused.

```javascript
import React, { addons } from 'react/addons';
import Container from '../../src/Container';
import MenuBar from '../../src/MenuBar';

describe('Container', function () {
  let shallowRenderer = React.addons.TestUtils.createRenderer();

  it('Show the menu bar', function () {
    shallowRenderer.render(<Container/>);
    let result = shallowRenderer.getRenderOutput();

    assert.deepEqual(result.props.children, [
      <MenuBar />
    ]);
  });
});
```

Again like the previous example this passes but how does it work?

```javascript
let shallowRenderer = React.addons.TestUtils.createRenderer();
```
We first create the *[shallowRender](https://facebook.github.io/react/docs/test-utils.html#shallow-rendering)* which handles the rendering of the React components.

```javascript
shallowRenderer.render(<Container/>);
```
Then we pass in the component we have under test to the *[shallowRender](https://facebook.github.io/react/docs/test-utils.html#shallow-rendering)*.

```javascript
let result = shallowRenderer.getRenderOutput();
assert.deepEqual(result.props.children, [<MenuBar/>]);
```

And finally we get the output from the *[shallowRender](https://facebook.github.io/react/docs/test-utils.html#shallow-rendering)* and
assert that the children contain the menu-bar component.

Is this approach any better than the previous? In my option yes and for the following reasons:

- We don't rely on the inner workings of the menu-bar to know if it has been rendered and therefore the markup can be refactored without
any of the
 tests being broken.

- Less dependencies are being used as *[shallowRender](https://facebook.github.io/react/docs/test-utils.html#shallow-rendering)* does not require
a DOM to render into.

- It's a lot easier to see what is being asserted as we are able to use JSX syntax in assertions.

##Conclusion
So is shallow rendering the silver bullet for React testing? Probably not as it still lacking on key feature for me when dealing
with large components and that is the ability to easily query the ReactDOM (libraries like *[enzyme](https://github.com/airbnb/enzyme)*
are working towards improving this). But it is still a lot better than rendering the component out into HTML and coupling your tests
to the inner components of others.

In this blog post we have just scratched the surface of testing with React and I hope it's food for thought when writing your next set of
React tests.