({
	init: function(component, event, helper){
		//console.log( 'tileTile init' );
		helper.initTile(component, helper);
	},

	unhelpfulError : function(component, event, helper){
		component.set('v.something','something');
	},

	findThisError : function(component, event, helper){
		somethingUndefined = "some value";
	},

	/** handler for when the link is clicked **/
	handleLinkClicked: function( component, event, helper ){
		helper.noop();

		event.preventDefault();

		// console.log('link was clicked');
		// helper.followTileLink( linkType, linkTarget, tile );

		var currentTile = component.get("v.tile");
		var targetURL = currentTile.Target__c;
		var editMode = component.get("v.editMode");
		var tileEvent;

		//var currentTileObj = JSON.parse(JSON.stringify(currentTile));

		if (editMode) {
			//-- move the tile up one
			tileEvent = component.getEvent("tileEvent");
			tileEvent.setParams({
				targetTile: currentTile.Id,
				messageType: 'moveUp'
			});
			tileEvent.fire();
		} else {
			//-- fire the url
			tileEvent = component.getEvent("tileEvent");
			tileEvent.setParams({
				targetTile: currentTile.Id,
				messageType: 'click',
				payload: targetURL
			});
			tileEvent.fire();
		}
	},

	/**
	 * Handle that the search changed
	 */
	handleSearchChanged : function(component, event, helper){
		//console.log("search changed");
		var search = component.get('v.search');
		var tile = component.get('v.tile');
		component.set("v.matchesSearch", helper.doesSearchMatch(tile, search));
	},
	
	/** handler if the tile has changed **/
	handleTileChanged: function( component, event, helper ){
		//console.log( 'tile changed' );
		helper.initTile(component, helper);
	}

	/*
	handleMoveUp : function(component, event, helper){
		helper.noop();

		var resultsToast = $A.get('e.force:showToast');
		resultsToast.setParams({
				'title': 'moving up',
				'message': 'moving up'
		});
		resultsToast.fire();
	},

	handleMoveDown : function(component, event, helper){
		var resultsToast = $A.get('e.force:showToast');
		resultsToast.setParams({
				'title': 'moving Down',
				'message': 'moving Down'
		});
		resultsToast.fire();
	}
	*/
})
