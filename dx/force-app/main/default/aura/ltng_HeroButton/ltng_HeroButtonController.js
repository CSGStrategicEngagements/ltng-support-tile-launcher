({
	init : function(component, event, helper) {
		//console.log('hero button initialized');

		helper.initialize(component, helper);

		var resourceName = component.get('v.resourceName');
		helper.locateResource(component, helper, resourceName);
	},

	handleClick : function(component, event, helper){
		helper.handleClick(component, helper);
	}
})