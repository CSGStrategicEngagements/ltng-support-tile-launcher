({
		/**
		 * performs a server side call
		 **/
		getHeroNotifications : function(component, helper) {
				var action = component.get('c.getMyHeroNotifications');
				action.setStorable();
				
				action.setCallback(this, function(response){
						var state = response.getState();
						if( state === 'SUCCESS' ){
								//console.info('action success');
								var results = response.getReturnValue();
								component.set('v.heroNotifications', results);
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
		 * Called when the lightning data service loads records.
		 **/
		handleRecordLoaded : function(component, event, helper) {
				var currentStatus = component.get('v.ticketRecord.Status__c');
				var updatedStatus = helper.updateStatus( currentStatus );
				
				//-- perform the update
				component.set('v.ticketRecord.Status__c', updatedStatus);
				
				//-- more can be found here:
				//-- https://trailhead.salesforce.com/modules/lightning_data_service/units/lightning_data_service_manipulate_records
				
				component.find("forceRecord").saveRecord(function(saveResult){
						if( saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT' ){
								helper.handleSaveCompleted(component, event, helper);
						} else if( saveResult.state === 'INCOMPLETE' ){
								console.error('User is offline, device doesnt support drafts');
								helper.displayError('Incomplete', component, event, helper);
						} else if( saveResult.state === 'ERROR' ){
								console.error('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
								helper.displayError('Error', component, event, helper);
						} else {
								console.error('Unknown problem, state:' + saveResult.state + ', error:' + JSON.stringify(saveResult.error));
								helper.displayError('Unknown Error', component, event, helper);
						}
				});
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
			
			console.error(errorMessages);
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
		}
})