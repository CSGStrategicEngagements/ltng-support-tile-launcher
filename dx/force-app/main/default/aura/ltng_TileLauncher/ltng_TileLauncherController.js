({
	/** initializes the component **/
	init: function(component, event, helper) {
		//console.log( 'quickLinks was initialized - placebreakpoint to learn more.' );
		helper.loadTiles( component, helper );
	},

	handleTileEvent : function(component, event, helper){
		event.preventDefault();
		//console.log('tileEvent captured');

		var messageType = event.getParam('messageType');
		if (messageType === 'swap') {
			helper.handleSwapEvent(component, event, helper);
		} else if (messageType === 'click') {
			helper.handleClickEvent(component, event, helper);
		} else {
			helper.displayError('swap', component, event, helper);
		}
	},

	handleSearchChanged : function(component, event){ // , helper
		//console.log('handleSearchChanged');
		var currentSearch = event.getParam('value');
		component.set("v.currentSearch", currentSearch);
	}
})