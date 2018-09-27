({
	/** handler for when the link is clicked **/
	handleLinkClicked: function( component, event, helper ){
		event.preventDefault();

		//console.log( 'link was clicked' );
		var tile = component.get('v.tile');
		var linkType = tile.Type__c;
		var linkTarget = tile.Target__c;
		helper.followTileLink( linkType, linkTarget, tile );
	},
	
	init: function( component){ // , event, helper
		//console.log( 'tileTile init' );
		component.set("v.matchesSearch", true);
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
		helper.initTile( component.get( 'v.tile' ), component, helper );
	},

	handleOnDrag : function(){ // component, event, helper
		//console.log('ondrag:' + component.getGlobalId());
	},

	handleOnDragEnd : function(component){ // , event, helper
		//event.preventDefault();
		//console.log('dragEnd:' + component.getGlobalId());
		component.set("v.isGrabbed", false);
	},

	handleOnDragEnter : function(){ // component, event, helper
		//event.preventDefault();
		//console.log('dragEnter:' + component.getGlobalId());
	},

	handleOnDragExit : function(){ // component, event, helper
		//event.preventDefault();
		//console.log('dragExit:' + component.getGlobalId());
	},

	handleOnDragLeave : function(){ // component, event, helper
		//event.preventDefault();
		//console.log('dragleave:' + component.getGlobalId());
	},

	handleOnDragOver : function(component, event){ // , helper
		event.preventDefault();
		//console.log('dragOver:' + component.getGlobalId());
	},

	handleOnDragStart : function(component, event){ // , helper
		//event.preventDefault();
		//console.log('dragStart:' + component.getGlobalId());
		var tile = component.get('v.tile');
		event.dataTransfer.setData('text', JSON.stringify(tile));

		component.set("v.isGrabbed", true);
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