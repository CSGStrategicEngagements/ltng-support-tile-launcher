({
	/**
	 * Initialize the components
	 */
	initialize : function(component){ // , helper
		var resourceAddress = /resource/ + component.get('v.resourceName');
		component.set('v.resourceAddress', resourceAddress);
	},

	/**
	 * Handles the user clicking on the hero button.
	 */
	handleClick : function(component) { // , helper
		var targetAddress = component.get('v.targetAddress');
		//console.log('hero clicked');

		var navigateEvent = $A.get('e.force:navigateToURL');
		navigateEvent.setParams({
			'url': targetAddress
		});
		navigateEvent.fire();
	},

	/**
	 * Locates the address for the static resource given by a name.
	 * @param resourceName {string} - developer name of the resource
	 */
	locateResource : function(component, helper, resourceName){
		var action = component.get('c.getResource');
		action.setStorable();
		action.setParams({ resourceName: resourceName });
		
		action.setCallback(this, function(response){
			var state = response.getState();
			if( state === 'SUCCESS' ){
				//console.info('action success');
				var results = response.getReturnValue();
				component.set('v.resourceAddress', results);
			} else {
				//console.error('Error occurred from Action');
				
				//-- https://developer.salesforce.com/blogs/2017/09/error-handling-best-practices-lightning-apex.html
				var errors = response.getError();
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
				
				//console.error(errorMessages);
			}
		});
		//-- optionally seet storable, abortable, background flags here
		$A.enqueueAction(action);
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
	}
})