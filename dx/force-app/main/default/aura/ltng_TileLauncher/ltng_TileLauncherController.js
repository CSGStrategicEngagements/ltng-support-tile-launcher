({
	/** initializes the component **/
	init: function(component, event, helper) {
		console.log( 'quickLinks was initialized - placebreakpoint to learn more.' );
		helper.loadTiles( component, helper );
	},

	/** handles if a link is clicked **/
	handleLinkClicked: function( component, event, helper ){
		//console.log( 'link was clicked' );
	}
})