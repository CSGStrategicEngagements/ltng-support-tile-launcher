({
	/**
	 * Initialize the component
	 */
	initialize : function(component, helper) {
		var supportDragAndDrop = helper.shouldAllowDragAndDrop(component, helper);

		component.set("v.supportDragAndDrop", supportDragAndDrop);

		component.set('v.editMode', false);
		component.set('v.isSaving', false);
		helper.resetTouchedItems(component, helper);
	},

	/**
	 * performs a server side call
	 * @param exampleRecordId (Id)
	 **/
	loadTiles : function(component, helper) {
		var action = component.get('c.getMyLinks');
		action.setStorable();
		//action.setParams({ recordId: recordId });
		
		action.setCallback(this, function(response){
			var state = response.getState();
			if( state === 'SUCCESS' ){
				// console.info('action success');
				var tiles = response.getReturnValue();

				tiles = helper.sortTiles(component, helper, tiles);
				tiles = helper.markSupportedTileFormFactors(component, helper, tiles);
				
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
		action.setStorable();
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
	 * Handle a swap request
	 */
	handleSwapEvent : function(component, event, helper){
		//var params = JSON.parse(JSON.stringify(event.getParams()));
		var tiles = component.get("v.tiles");
		var sourceTileId = event.getParam('sourceTile');
		var targetTileId = event.getParam('targetTile');

		if (sourceTileId === targetTileId) {
			//-- ignore
			return;
		}

		var sourceTileIndex = helper.findTilePosition(component, helper, sourceTileId);
		var sourceTile = helper.findTileAtPosition(component, helper, sourceTileIndex);
		var targetTileIndex = helper.findTilePosition(component, helper, targetTileId);
		var targetTile = helper.findTileAtPosition(component, helper, targetTileIndex);

		tiles[sourceTileIndex] = targetTile;
		tiles[targetTileIndex] = sourceTile;

		helper.markItemAsTouched(component, event, sourceTile);
		helper.markItemAsTouched(component, event, targetTile);

		component.set('v.tiles', tiles);
	},

	/**
	 * Finds a tile index by the tile id.
	 * @param tileId {string}
	 * @return {integer} - the index of the tile (or -1 if not found)
	 */
	findTilePosition : function(component, helper, tileId){
		var result = null;
		var tiles = component.get('v.tiles');
		var tile;
		if (tiles) {
			for (var i = 0; i < tiles.length; i = i+1) {
				tile = tiles[i];
				if (tile.Id === tileId) {
					result = i;
					break;
				}
			}
		}

		if (result === null) {
			helper.displayError('Unable to find tile');
		}

		return result;
	},

	/**
	 * Finds a tile at a given position
	 */
	findTileAtPosition : function(component, helper, tilePosition){
		var tiles = component.get('v.tiles');

		if (tilePosition < 0 || tilePosition >= tiles.length){
			return null;
		} else {
			return tiles[tilePosition];
		}
	},

	/**
	 * Convenience method for finding a tile.
	 * @param tileId {string}
	 * @return {Object} - the tile (or null if not found)
	 */
	findTile : function(component, helper, tileId){
		return helper.findTileAtPosition(component, helper,
			helper.findTilePosition(component, helper, tileId)
		);
	},

	/**
	 * handles when a tile is clicked (not dragged)
	 * @param tileId (String)
	 * @param targetURL (String)
	 */
	handleClickEvent : function( component, event, helper ) {
		// console.log('clickEvent');
		
		var tileId = event.getParam('targetTile');
		var tile = helper.findTile(component, helper, tileId);

		if (!tile) {
			// console.log('unable to find tile'); //-- assumed handled in findTile methods
			return;
		}

		var linkType = tile.Type__c;
		var targetURL = tile.Target__c;

		var navigationParameters = helper.getNavigationParameters(component, helper, linkType, targetURL);

		var navEvt;
        var isLightningOut = component.get('v.uiTheme') === 'Theme3';
		if (navigationParameters && !isLightningOut){
            component.find("navService").navigate(navigationParameters);
		} else {
			navEvt = $A.get('e.force:navigateToURL' );
			navEvt.setParams({ 'url': targetURL });
			navEvt.fire();
		}
	},

	/**
	 * Handles when a tile says 'move me up one'
	 * <p>Sent while in edit mode</p>
	 */
	handleMoveUpEvent : function(component, event, helper){
		var tileId = event.getParam('targetTile');
		var currentTileIndex = helper.findTilePosition(component, helper, tileId);
		var currentTile;
		var previousTileIndex;
		var previousTile;

		if (currentTileIndex === 0) {
			//-- can't go up any further
			return;
		}

		currentTile = helper.findTileAtPosition(component, helper, currentTileIndex);
		previousTileIndex = currentTileIndex-1;
		previousTile = helper.findTileAtPosition(component, helper, previousTileIndex);
		
		var tiles = component.get('v.tiles');

		tiles[previousTileIndex] = currentTile;
		tiles[currentTileIndex] = previousTile;

		helper.markItemAsTouched(component, event, currentTile);
		helper.markItemAsTouched(component, event, previousTile);

		component.set('v.tiles', tiles);
	},

	/**
	 * Toggle edit mode
	 */
	toggleEditMode : function(component, helper){
		helper.noop();

		//helper.checkGettingPreferences(component, helper); //-- works
		//helper.checkSendingPreferences(component, helper); //-- works
		//helper.storeTilePreferences(component, helper);

		var currentlyEditing = component.get('v.editMode');

		if (currentlyEditing === true) {
			helper.storeTilePreferences(component, helper);
		} else {
			helper.resetTouchedItems(component, helper);
			component.set("v.editMode", !currentlyEditing);
		}
	},

	/**
	 * Mark a tile as 'touched' (for editing)
	 * @param component
	 * @param helper
	 * @param tileId
	 */
	markItemAsTouched : function(component, helper, tile){
		/*
		Ultimately it would be preferred that we could set a transient variable
		onto the tile to indicate it was touched.
		It is unclear if / when this value would no longer be accessible.
		**/

		tile.isModified = true;
	},

	/**
	 * Resets the list of items touched
	 */
	resetTouchedItems : function(component, helper){
		helper.noop();
		var allTiles = component.get('v.tiles');
		for (var i = 0; i < allTiles.length; i = i+1) {
			allTiles[i].isModified = false;
		}
	},

	/**
	 * Determines the list of tiles that were touched
	 */
	serializeTilePreferences : function(component, helper){
		helper.noop();

		var results = [];
		//var allModifiedTiles = [];
		
		var allTiles = component.get('v.tiles');
		var tile;
		var tilePreference;

		for (var i = 0; i < allTiles.length; i = i+1) {
			tile = allTiles[i];

			//-- for now, serialize all of them
			//-- as allowing piecemeal saves does not work in all cases
			//-- @TODO: revisit.

			//if (tile.isModified) {
				//allModifiedTiles.push(tile);

				tilePreference = {
					tileLauncherEntryId: tile.Id,
					preferredSortIndex: i
				};
				results.push(tilePreference);
			//}
		}

		//-- compare allModifiedTilesA with allModifiedTiles
		//console.log('allModifiedTiles');console.log(allModifiedTiles);

		return results;
	},

	/**
	 * Attempt to save the touched items
	 **/
	storeTilePreferences : function(component, helper) {
		var action = component.get('c.saveTilePreferences');

		//-- get the list of tiles stored
		var tilePreferences = helper.serializeTilePreferences(component, helper);
		var preferenceCollection = {records:tilePreferences};
		var tilePreferencesJSON = JSON.stringify(preferenceCollection);

		action.setParams({ "tilePreferencesJSON": tilePreferencesJSON });

		component.set('v.isSaving', true);
		
		action.setCallback(this, function(response){
			//-- stop the saving spinner regardless, so the user can fix it.
			component.set('v.isSaving', false);

			var state = response.getState();
			if( state === 'SUCCESS' ){
				//console.info('action success');

				var results = response.getReturnValue();
				console.log('all returned preferences:' + results);

				//-- end the edit mode
				component.set('v.editMode', false);
			} else {
				console.error('Error occurred from Action');
				
				//-- https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
				var errors = response.getError();
				console.error(JSON.parse(JSON.stringify(errors)));

				helper.handleCallError(component, helper, state, errors);
			}
		});
		//-- optionally set storable, abortable, background flags here
		$A.enqueueAction(action);
	},

	/**
	 * Determine if the user is currently using mobile.
	 *
	 * <p>Note we can either detect by device / form factor
	 * https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/expr_browser_value_provider.htm
	 * or we can detect by experience / theme:
	 * https://developer.salesforce.com/blogs/isv/2016/04/introducing-ui-theme-detection-for-lightning-experience.html
	 * </p>
	 * @see https://developer.salesforce.com/blogs/isv/2016/04/introducing-ui-theme-detection-for-lightning-experience.html
	 */
	shouldAllowDragAndDrop : function(component, helper) {
		helper.noop();
		
	  var formFactor = $A.get("$Browser.formFactor");
	  var usingDesktop = formFactor === "DESKTOP";
 
	  //-- only allow drag and drop if using desktop (for now)
	  return usingDesktop;
  },


	//-----------------------------------
	//-- UTILITY METHODS
	//-----------------------------------

	noop : function(){},

	sortTiles : function(component, helper, tiles){
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
		return tiles;
	},

	markSupportedTileFormFactors : function(component, helper, tiles){
		var tile;
		var currentFormFactor = $A.get('$Browser.formFactor');
		var isIOS = $A.get('$Browser.isIOS') || $A.get('$Browser.isIPhone');
		var isAndroid = $A.get('$Browser.isAndroid');
		var isWindowsPhone = $A.get('$Browser.isWindowsPhone');
		var formFactorPattern;

		if (isIOS) {
			currentFormFactor='(IOS|' + currentFormFactor + ')';
		} else if (isAndroid) {
			currentFormFactor='(ANDROID|' + currentFormFactor + ')';
		} else if (isWindowsPhone) {
			currentFormFactor='(WINDOWS|' + currentFormFactor + ')';
		}

		formFactorPattern = new RegExp(currentFormFactor,'i');

		if(tiles){
			for (var i = 0; i < tiles.length; i=i+1) {
				tile = tiles[i];
				tile.isFormFactorSupported = true;
				if (!tile.SupportedFormFactors__c || !formFactorPattern) {
					//-- allow it
				} else if (!tile.SupportedFormFactors__c.match(formFactorPattern)){
					tile.isFormFactorSupported = false;
				}
			}
		}

		return tiles;
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
	 * Get the parameters to use for Lightning:Navigation / pageReference
	 * @see https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation.htm
	 * @see https://developer.salesforce.com/docs/component-library/bundle/lightning:navigation/documentation
	 */
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