({
	init: function(component, event, helper){
		//console.log( 'tileTile init' );
		helper.initTile(component, helper);
	},

	/** handler for when the link is clicked **/
	handleLinkClicked: function( component, event, helper ){
		helper.noop();
		event.preventDefault();

		// console.log('link was clicked');
		// helper.followTileLink( linkType, linkTarget, tile );

		var currentTile = component.get("v.tile");
		var targetURL = currentTile.Target__c;

		//var currentTileObj = JSON.parse(JSON.stringify(currentTile));

		var tileEvent = component.getEvent("tileEvent");
		tileEvent.setParams({
			targetTile: currentTile.Id,
			messageType: 'click',
			payload: targetURL
		});
		tileEvent.fire();
	},
	
	handleSearchChanged : function(component, event, helper){
		//console.log("search changed");
		var search = component.get('v.search');
		var tile = component.get('v.tile');
		component.set("v.matchesSearch", helper.doesSearchMatch(tile, search));
	},
	
	/** handler if the tile has changed **/
	handleTileChanged: function( component, event, helper ){
		//console.log( 'tile changed' );
		helper.initTile( component, helper );
	},

	handleOnDragStart : function(component, event){ // , helper
		//event.preventDefault();
		//console.log('dragStart:' + component.getGlobalId());
		var tile = component.get('v.tile');
		event.dataTransfer.setData('text', JSON.stringify(tile));
		event.dataTransfer.dropEffect = "move";

		component.set("v.isGrabbed", true);
	},

	handleOnDragEnd : function(component){ // , event, helper
		//event.preventDefault();
		//console.log('dragEnd:' + component.getGlobalId());
		component.set("v.isGrabbed", false);
	},

	handleOnDragOver : function(component, event){ // , helper
		//-- required for drop to work successfully
		//-- see here for more
		//-- https://hackernoon.com/drag-drop-for-lightning-components-27230745a2eb

		event.preventDefault();
		//console.log('dragOver:' + component.getGlobalId());
	},

	handleOnDrop : function(component, event){ // , helper
		event.preventDefault();
		//console.log('ondrop:' + component.getGlobalId());

		var sourceTile = JSON.parse(event.dataTransfer.getData('text'));
		var currentTile = component.get("v.tile");

		//var currentTileObj = JSON.parse(JSON.stringify(currentTile));

		var tileEvent = component.getEvent("tileEvent");
		tileEvent.setParams({
			sourceTile: sourceTile.Id,
			targetTile: currentTile.Id,
			messageType: 'swap'
		});
		tileEvent.fire();
	}
})