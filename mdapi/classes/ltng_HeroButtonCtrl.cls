/**
 * Controller for the Hero Button component.
 **/
public class ltng_HeroButtonCtrl {
    
    /** default resource URL **/
	public static final String DEFAULT_RESOURCE_URL = '/resource/ltng_TileLauncherHero';

	/** format of a static resource url **/
	public static final String STATIC_RESOURCE_URL_FORMAT = '/resource/{0}/{1}';
	
	/**
	 * Determines the URL for a given static resource.
	 * <p>Not used for now as the shortcut /resource/ + resourceName
	 * 	is expected to remain for the foreseeable future.
	 *  This was included if that is ever not the case.</p>
	 * @param resourceName <String> - Developer/API name of the static resource.
	 **/
	@AuraEnabled
	public static String getResource( String resourceName ){
		String resultURL = DEFAULT_RESOURCE_URL;

		//try {
			resultURL = determineResourceURLs(resourceName);
		//} catch(Exception err){
		//	throw new AuraHandledException('unable to find static resource:' + resourceName);
		//}

		return resultURL;
	}



    /**
     * Gets all the notifications for the current user.
     * @return HeroNotification[]
     **/
    @AuraEnabled
    public static HeroNotification[] getMyHeroNotifications(){
        Id userId = UserInfo.getUserId();
        return getHeroNotifications(userId);
    }

    /**
     * Description for method
     **/
    @AuraEnabled
    public static HeroNotification[] getHeroNotifications(Id userId) {
        HeroNotification[] results;
		HeroNotification notificationResult;
		ltng_HeroNotification__c[] eligibleNotifications;
        Map<String,ltng_HeroNotification__c[]> notificationByResource = new Map<String,ltng_HeroNotification__c[]>();
		Map<String,String> resourceUrlByName = new Map<String,String>();
        Set<String> allResourceApiNames;
        String resourceAddress;
        
        //try {
            //-- determine the current list of Hero Notifications
            DateTime now = System.now();

            eligibleNotifications = [
                SELECT Title__c, AlternativeText__c, Description__c, EndDate__c, ExternalId__c, Id, Name, Permission__c, Priority__c, ResourceName__c, StartDate__c
                FROM ltng_HeroNotification__c
                WHERE (StartDate__c = null or StartDate__c <= :now) and (EndDate__c = null or EndDate__c >= :now)
                ORDER BY Priority__c desc nulls last
            ];

			//-- @TODO: filter by permission

            //-- @INVARIANT - we have a list of all the notifications we should consider.
            //System.debug('all eligible notifications'); System.debug(eligibleNotifications);

            //-- determine the notifications resources
            for ( ltng_HeroNotification__c notification : eligibleNotifications ){
                if (!notificationByResource.containsKey(notification.ResourceName__c)){
                    notificationByResource.put(notification.ResourceName__c, new ltng_HeroNotification__c[]{});
                }
                notificationByResource.get(notification.ResourceName__c).add(notification);
            }

            allResourceApiNames = notificationByResource.keySet();

            //-- @INVARIANT - we know all the resources that are used with those notifications
            //-- with the possibility that some may be used multiple times (but with different permissions)
            //System.debug('allResourceApiNames'); System.debug(allResourceApiNames);

            resourceUrlByName = determineResourceURLs(allResourceApiNames);

			//-- @INVARIANT - we know the addresses for all the resources requested.
			//System.debug('resourceUrls by resource name'); System.debug(resourceUrlByName);

			results = new HeroNotification[]{};
			for ( ltng_HeroNotification__c notification2 : eligibleNotifications ){
				notificationResult = new HeroNotification(notification2);
				notificationResult.ResourceAddress = resourceUrlByName.get(notification2.ResourceName__c);
				results.add(notificationResult);
			}

			//-- @INVARIANT - we have a list of all the notifications with the URL they should reference
			//System.debug('final results'); System.debug(results);

        //} catch(Exception err){
        //    throw new AuraHandledException('Exception occurred when processing: getHeroNotifications');
        //}
        
        return(results);
    }

	public class HeroNotification {
		@AuraEnabled
		public String Title;

		@AuraEnabled
		public String Description;

		@AuraEnabled
		public String AlternativeText;

		@AuraEnabled
		public String ResourceAddress;

		public HeroNotification(ltng_HeroNotification__c notification){
			this.Title = notification.Title__c;
			this.Description = notification.Description__c;
			this.AlternativeText = notification.AlternativeText__c;
		}
	}

	//-- Helper Functions

	/**
	 * Convenience method for determining the URL for a single resource.
	 * @param resourceName (String) - API name for a single resource;
	 * @return String - url for that single resource.
	 **/
	public static String determineResourceURLs(String resourceName){
		Set<String> resourceAddresses = new Set<String>();
		resourceAddresses.add(resourceName);
		return determineResourceURLs(resourceAddresses).get(resourceName);
	}

	public static Map<String,String> determineResourceURLs(String[] resourceNames){
		Set<String> resourceAddresses = new Set<String>();
		resourceAddresses.addAll(resourceNames);
		return determineResourceURLs(resourceAddresses);
	}

	/**
	 * Given a list of resource api names, returns the corresponding URL for that resource.
	 * @param resourceNames (String[])
	 * @return Map<String,String> - map of those resource urls indexed by their name.
	 **/
	public static Map<String,String> determineResourceURLs(Set<String> resourceNames){
		Map<String,String> resourceUrlByName = new Map<String,String>();

		String resultURL;
		String timestamp;

		for (StaticResource resource : [
                SELECT Id, Name, SystemModstamp
                FROM StaticResource
                WHERE Name in :resourceNames
		]){
			timestamp = String.valueOf(resource.SystemModstamp.getTime());
			resultURL = String.format(STATIC_RESOURCE_URL_FORMAT,
				new String[]{ timestamp, resource.Name }
			);
			resourceUrlByName.put(resource.Name, resultURL);
		}

		return resourceUrlByName;
	}
}