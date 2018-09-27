({
	/** handler for when the link is clicked **/
	handleLinkClicked: function( component, event, helper ){
		//console.log( 'link was clicked' );
		var tile = component.get('v.tile');
		var linkType = tile.Type__c;
		var linkTarget = tile.Target__c;
		helper.followQuickLink( linkType, linkTarget, tile );
	},
	
	init: function( component, event, helper ){
		//console.log( 'tileTile init' );
	},
	
	/** handler if the tile has changed **/
	handleQuickLinkChanged: function( component, event, helper ){
		//console.log( 'tile changed' );
		helper.initQuickLinks( component.get( 'v.tile' ), component, helper );
	}
})