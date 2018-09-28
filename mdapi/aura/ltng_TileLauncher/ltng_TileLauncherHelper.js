({
	/**
	 * performs a server side call
	 * @param exampleRecordId (Id)
	 **/
	loadTiles : function(component, helper) {
		var action = component.get('c.getMyLinks');
		//action.setParams({ recordId: recordId });
		
		action.setCallback(this, function(response){
			var state = response.getState();
			if( state === 'SUCCESS' ){
				// console.info('action success');
				var tiles = response.getReturnValue();
				tiles.sort(function(a, b) {
					var t1 = a.PreferredSortIndex__c === b.PreferredSortIndex__c, t2 = a.PreferredSortIndex__c < b.PreferredSortIndex__c;
					if (t1){
						return 0;
					} else if (t2) {
						return -1;
					} else {
						return 1;
					}
					//return t1 ? 0: ( t2 ? -1 : 1);
				});
				component.set("v.tiles", tiles);

				helper.loadLauncherFormats(component, helper);
			} else {
				// console.error('Error occurred from Action');
				
				//-- https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
				var errors = response.getError();
				helper.handleCallError(component, helper, state, errors);
			}
		});
		//-- optionally set storable, abortable, background flags here
		$A.enqueueAction(action);
	},

	/**
	 * Loads the launcher formats
	 */
	loadLauncherFormats : function(component, helper){
		var action = component.get('c.getLauncherFormats');
		//action.setParams({ recordId: recordId });
		
		action.setCallback(this, function(response){
				var state = response.getState();
				if( state === 'SUCCESS' ){
						//console.info('action success');
						var results = response.getReturnValue();
						component.set('v.launcherFormats', results);
				} else {
						//console.error('Error occurred from Action');
						
						//-- https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
						var errors = response.getError();
						helper.handleCallError(component, helper, state, errors);
				}
		});
		//-- optionally set storable, abortable, background flags here
		$A.enqueueAction(action);
	},
	
	/**
	 * Handles the collection of errors into something acceptable for the end user.
	 * @param errors (Object[]) - collection of errors from a server side call.
	 */
	handleCallError : function(component, helper, state, errors){
		//-- https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
		var errorMessages = [];
		if( errors && Array.isArray(errors) && errors.length > 0 ){
			errors.forEach(function(error){
				errorMessages.push(error.message);
			});
		}
		
		if( state === 'ERROR' ){
			helper.displayError('Error', 'Action error');
		} else {
			helper.displayError('Unknown Response', 'Action failure');
		}
		
		// console.error(errorMessages);
	},
	
	/**
	 * Displays an error
	 * @param errorTitle (String)
	 * @param errorMsg (String)
	 **/
	displayError: function(errorCode){ // , component, event, helper
			var errorTitle = 'Error';
			var errorMsg = 'An error occurred: ' + errorCode + '. Please contact your System Administrator';
			
			//-- send a toast message
			var resultsToast = $A.get('e.force:showToast');
			resultsToast.setParams({
					'title': errorTitle,
					'message': errorMsg
			});
			resultsToast.fire();
	},
	
	/**
	 * Handles when the save has completed
	 **/
	/*
	handleSaveCompleted : function(component, event, helper) {
			//-- send a toast message
			var resultsToast = $A.get('e.force:showToast');
			resultsToast.setParams({
					'title': 'Saved',
					'message': 'The record was saved'
			});
			resultsToast.fire();
			
			//-- refresh the standard detail
			$A.get('e.force:refreshView').fire();
			
			//-- close the dialog
			$A.get("e.force:closeQuickAction").fire();
	},
	*/

	/**
	 * Handle a swap request
	 */
	handleSwapEvent : function(component, event){ // , helper
		//var params = JSON.parse(JSON.stringify(event.getParams()));
		var tiles = component.get("v.tiles");
		var tile;
		var sourceTileId = event.getParam('sourceTile');
		var sourceTileIndex;
		var sourceTile;
		var targetTileId = event.getParam('targetTile');
		var targetTileIndex;
		var targetTile;

		if (sourceTileId === targetTileId) {
			//-- ignore
			return;
		}

		//-- we want the index and want this to be fast
		//-- so we aren't using findTileById here
		for (var i = 0; i < tiles.length; i = i+1){
			tile = tiles[i];
			if (tile.Id === sourceTileId) {
				sourceTileIndex = i;
				sourceTile = tile;
			} else if (tile.Id === targetTileId) {
				targetTileIndex = i;
				targetTile = tile;
			}
		}

		tiles[sourceTileIndex] = targetTile;
		tiles[targetTileIndex] = sourceTile;

		component.set('v.tiles', tiles);
	},
	
	/**
	 * Finds a tile by the tile id
	 * @param tileId
	 * @return {Object} - the tile
	 */
	findTileById : function(component, helper, tileId){
		var result = null;
		var tiles = component.get('v.tiles');
		var tile;
		if (tiles) {
			for (var i = 0; i < tiles.length; i = i+1) {
				tile = tiles[i];
				if (tile.Id === tileId) {
					result = tile;
					break;
					//return tile;
				}
			}
		}

		return result;
	},

	/**
	 * handles when a tile is clicked (not dragged)
	 * @param tileId (String)
	 * @param targetURL (String)
	 */
	handleClickEvent : function( component, event, helper ) {
		// console.log('clickEvent');
		
		var tileId = event.getParam('targetTile');
		var tile = helper.findTileById(component, helper, tileId);
		var linkType = tile.Type__c;
		var targetURL = tile.Target__c;

		var navigationParameters = helper.getNavigationParameters(component, helper, linkType, targetURL);

		var navEvt;
		if (navigationParameters){
			component.find("navService").navigate(navigationParameters);
		} else {
			navEvt = $A.get('e.force:navigateToURL' );
			navEvt.setParams({ 'url': targetURL });
			navEvt.fire();
		}

		/*
		var navEvt;
		if( linkType === 'Visualforce' ){
				navEvt = $A.get('e.force:navigateToURL');
				navEvt.setParams({ 'url': '/apex/' + targetURL });
				navEvt.fire();
		} else if( linkType === 'Record' ){
				navEvt = $A.get('e.force:navigateToSObject');
				navEvt.setParams({ 'recordId':targetURL, 'slideDevName':'detail' });
				navEvt.fire();
		} else {
				navEvt = $A.get('e.force:navigateToURL' );
				navEvt.setParams({ 'url': targetURL });
				navEvt.fire();
		}
		*/
	},

	getNavigationParameters : function(component, helper, linkType, targetURL){
		var result = null;
		var launcherFormats = component.get('v.launcherFormats');
		var launcherFormat;

		var pattern;
		var matches;
		var templateToken;
		var token;

		//-- if linkType === 'URL' - short circuit
		if (linkType === 'URL') {
			return null;
		}

		//-- evaluate ES6 support at ZB
		for (var formatIndex = 0; formatIndex < launcherFormats.length; formatIndex = formatIndex+1) {
			launcherFormat = launcherFormats[formatIndex];

			try {
				//-- @TODO: include catches in case the template is bad
				result = launcherFormat.Navigation_Object_Format__c;
				pattern = new RegExp(launcherFormat.URL_Format__c, "i");

				matches = targetURL.match(pattern);

				if (matches) {
					for (var matchIndex = 1; matchIndex < matches.length; matchIndex = matchIndex + 1){
						templateToken = new RegExp("\<\%=_" + matchIndex + "\%>", "ig");
						token = matches[matchIndex];
						result = result.replace(templateToken, token);
					}
					return JSON.parse(result);
				} else {
					//console.log('no match. next!');
				}
			} catch(err){
				helper.displayError('Error with format:' + launcherFormat.Id);
			}
		}
		
		return null;
	}
})