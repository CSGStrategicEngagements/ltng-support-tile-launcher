({
	/**
	 * @param linkType (String) - type of quicklink
	 * @param linkTarget (String) - target address
	 * @param tile (ltng_TileLauncherEntry__c) - current tile - if needed
	 **/
	followTileLink : function( linkType, linkTarget, tile ) {
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
	 * Initializes the component if the quickLinks have changed
	 * @param tile (ltng_TileLauncherEntry__c)
	 * @param component
	 * @param helper
	 **/
	initTileLinks: function( quickLink, component, helper ){
			//console.log( 'quickLinks have changed' );
	}
})