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
								tiles.sort(function(a,b) {
									var t1 = a.PreferredSortIndex__c === b.PreferredSortIndex__c, t2 = a.PreferredSortIndex__c < b.PreferredSortIndex__c;
									return t1 ? 0: ( t2 ? -1 : 1);
								});
								component.set("v.tiles", tiles);
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
		displayError: function(errorCode, component, event, helper){
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

		/**
		 * Handle a swap request
		 */
		handleSwapEvent : function(component, event, helper){
			var params = JSON.parse(JSON.stringify(event.getParams()))
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

			for (var i = 0; i < tiles.length; i++ ){
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
		}
})