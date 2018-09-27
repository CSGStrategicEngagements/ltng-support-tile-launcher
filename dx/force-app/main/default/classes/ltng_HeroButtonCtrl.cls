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

		try {
			StaticResource resource = [SELECT Id, SystemModstamp
				FROM StaticResource
				WHERE Name = :resourceName
				LIMIT 1];
			String timestamp = String.valueOf(resource.SystemModstamp.getTime());
			resultURL = String.format(STATIC_RESOURCE_URL_FORMAT,
				new String[]{ timestamp, resourceName }
			);
		} catch(Exception err){
			throw new AuraHandledException('unable to find static resource:' + resourceName);
		}

		return resultURL;
	}
}