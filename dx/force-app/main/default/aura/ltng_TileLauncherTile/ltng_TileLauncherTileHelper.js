({
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