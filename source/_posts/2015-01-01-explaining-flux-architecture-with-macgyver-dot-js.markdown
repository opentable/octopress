---
layout: post
title: "Explaining Flux architecture with macgyver.js"
date: 2015-01-01 15:33:46 +0000
comments: true
author: rtomlinson
categories: [Javascript, Macgyver, Flux]
---


## What is Flux?   

[Flux](https://github.com/facebook/flux) is an application architectural pattern developed by Facebook. It was developed to solve some of the complexities of the MVC pattern when used at scale by favouring a uni-directional approach. It is a pattern and not a technology or framework.

![MVC scale issue](/images/posts/mvc-scale.png)

When applications that use the model-view-controller (MVC) pattern at any scale it becomes difficult to maintain consistent data across multiple views. In particular the case whereby flow between models and views is not uni-directional and may require increasing logic to maintain parity between views when model data is updated. Facebook hit this issue several times and in particular with their unseen count (an incremented value of unseen messages which is updated by several UI chat components). It wasn't until they realised that the MVC pattern accomodated the complexity that they stepped back from the problem and addressed the architecture.

Flux is intentionally unidirectional.

![flux](/images/posts/flux.png)

Key to this architecture is the dispatcher. The dispatcher forms the gatekeeper that all actions must go through. When a view, or views, wish to do something they fire an action which the dispatcher correctly routes via registered callbacks made by the stores. 

Stores are responsible for the data and respond to callbacks from the dispatcher. When data is changed they emit change events that views listen to to notify them that data has changed. The view can then respond accordingly (for example to update/rebind).

This will become more obvious when we go through the macgyver.js example.

## What is macgyver.js?

[Macgyver](https://github.com/stevejhiggs/macgyver) is a project fork of [mullet.io](http://mullet.io/) by [Steve Higgs](https://github.com/stevejhiggs). Mullet is an aggregate stack to get started using Node.js with Facebook's [React](http://facebook.github.io/react/) framework on the client and Walmart's [hapi.js](http://walmartlabs.github.io/hapi/) on the server. 

Steve initially swapped out Grunt for Gulp, updated hapi and React and fixed some issues with the React dev tools. I then added another example to incorporate the Flux architecture, which you can see [here](https://github.com/stevejhiggs/macgyver/tree/master/reactPlusFlux). As React was also developed by Facebook you can begin to see how flux compliments its design and component based model.

## The macgyver.js Flux example

The demo is a very simple quiz. In true Macgyver style he is faced with abnormally unrealistic situations armed with impossibly useless "every-day" items to escape the situation. If you select the correct tool, you proceed to the next situation.

{% img left /images/posts/structure.png 200 %}

Let's start by going through the uni-directional flow above and at the same time look at the code and its structure.

When the game is first loaded the view fires an action to get the next situation. This is then fired off to the dispatcher, as are all actions.

```javascript
receiveSituations: function(data) {
	AppDispatcher.handleViewAction({
   		actionType: MacgyverConstants.RECEIVE_SITUATIONS_DATA,
     		data: data
   	});
},

```

The store registers to listen for events from the dispatcher with a registered callback. It has the job of loading the situation data and emitting an event when this data is changed. In this case the SituationStore.js has the job of setting the current situation for the view to render.

```javascript
AppDispatcher.register(function(payload){
	var action = payload.action;

	switch(action.actionType) {
		case MacgyverConstants.RECEIVE_SITUATIONS_DATA:
			loadSituationsData(action.data);
			break;
		case MacgyverConstants.CHECK_ANSWER:
			checkAnswer(action.data);
			break;
		default:
			return true;
	}

	SituationStore.emitChange();

	return true;
});
```

The React view (in this case Game.jsx) registers an event listener for these changes in the SituationStore using the React "componentDidMount" function. When the situation is received by the component it rebinds to the data by loading the sitution and the possible answers.

```javascript
var Game = React.createClass({

	componentDidMount: function () {
		SituationStore.addChangeListener(this._onChange);
		ToolStore.addChangeListener(this._onChange);
	},
	componentWillUnmount: function() {
		SituationStore.removeChangeListener(this._onChange);
		ToolStore.removeChangeListener(this._onChange);
	},
	render: ...
});
```

When the user selects an answer this fires off another "CHECK_ANSWER" event to the dispatcher. The situation store recieves this event with the answer in the payload and checks whether the answer selected is the correct one. If it is it updates the situation and emits a changes event to which the view receives and rebinds the view to the new situation.

## Conclusion

Flux can be quite difficult to fathom eventhough it is quite a simple architectural pattern. In this small example it does initially feel overly complex and indeed it probably is. The pattern was designed to solve issues that occur at large scale in MVC applications due to the increased amound of bi-directional dependencies between views and models. For smaller applications it could be seen as over-engineered, however I really like the simplicity in the uni-directional flow and the assurance that unit tests are almost always going to mimic the state changes possible in your application because of the guarantee of a simple flow of data.
