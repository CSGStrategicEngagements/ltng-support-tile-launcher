({
	/**
	 * @param linkType (String) - type of quicklink
	 * @param linkTarget (String) - target address
	 * @param tile (ltng_TileLauncherEntry__c) - current tile - if needed
	 **/
	followTileLink : function( linkType, linkTarget ) { // , tile
		var navEvt;
		if( linkType === 'Visualforce' ){
				navEvt = $A.get('e.force:navigateToURL');
				navEvt.setParams({ 'url': '/apex/' + linkTarget });
				navEvt.fire();
		} else if( linkType === 'Record' ){
				navEvt = $A.get('e.force:navigateToSObject');
				navEvt.setParams({ 'recordId':linkTarget, 'slideDevName':'detail' });
				navEvt.fire();
		} else {
				navEvt = $A.get('e.force:navigateToURL' );
				navEvt.setParams({ 'url': linkTarget });
				navEvt.fire();
		}
	},

	/**
	 * Determines if the search matches
	 * @param tile (Object)
	 * @param search (String)
	 * @return (Boolean)
	 */
	doesSearchMatch : function(tile, search){
		var tileName = tile.Name;
		if (!search || !tileName) {
			return(true);
		} else {
			var tileNameUp = tileName.toUpperCase();
			var searchUp = search.toUpperCase();
			return tileNameUp.toUpperCase().indexOf(searchUp) > -1;
		}
	},

	/**
	 * Initializes the component if the quickLinks have changed
	 * @param tile (ltng_TileLauncherEntry__c)
	 * @param component
	 * @param helper
	 **/
	initTile: function(){ //  quickLink, component, helper
			//console.log( 'quickLinks have changed' );
	}
})