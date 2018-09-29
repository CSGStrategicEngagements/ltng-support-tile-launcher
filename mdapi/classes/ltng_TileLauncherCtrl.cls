/**
 * Server side controller for the Tile Launcher
 **/
public with sharing class ltng_TileLauncherCtrl {

	/**
	 *  Determines the list of Tiles available to the user.
	 *  @return (ltng_TileLauncherEntry__c)
	 **/
	@AuraEnabled
	public static ltng_TileLauncherEntry__c[] getMyLinks(){
		ltng_TileLauncherEntry__c[] results = new ltng_TileLauncherEntry__c[]{};
		
		return( getLinks( UserInfo.getUserId() ));
	}
	
	/**
	 *  Determines the list of Tiles available to a specific person.
	 *  @param userId (Id)
	 *  @return (ltng_TileLauncherEntry__c[])
	 **/
	public static ltng_TileLauncherEntry__c[] getLinks( Id userId ){
		ltng_TileLauncherEntry__c[] results = new ltng_TileLauncherEntry__c[]{};
		
		//-- @TODO: add try catch in after completed
		//try {
		
		//-- set of all custom permissions to check for
		Set<String> allTilePermissions = new Set<String>();
		//-- map of all quicklinks grouped by custom permission developer name
		Map<String,ltng_TileLauncherEntry__c[]> tilesByPermission = new Map<String,ltng_TileLauncherEntry__c[]>();
		//-- ids of all the permission sets that contain those custom permissions
		//-- translation of all custom permissions developer names into their ids
		Map<Id,String> customPermissions = new Map<Id,String>();
		//-- collection of all custom permissions requested with the list of permission sets that contain them.
		Map<Id,String[]> permissionSetPermissions = new Map<Id,String[]>();
		//-- collection of all the user specific preferences
		Map<Id,Decimal> tileSortPreferenceMap = new Map<Id,Decimal>();

		//-- determine the user sort preferences
		for( ltng_TileLauncherEntryPreference__c tilePreference : [
			SELECT Id, TileLauncherEntry__c, PreferredSortIndex__c
			FROM ltng_TileLauncherEntryPreference__c
			WHERE User__c = :userId
		]){
			tileSortPreferenceMap.put(tilePreference.TileLauncherEntry__c, tilePreference.PreferredSortIndex__c);
		}
		
		//-- determine all quicklinks and sort them by the permission required to see them.
		ltng_TileLauncherEntry__c[] allTiles = [ select id, name, Description__c, ExternalId__c, IconGroup__c, IconName__c, Type__c, Target__c, Permission__c, PreferredSortIndex__c, LastModifiedDate
			from ltng_TileLauncherEntry__c
			order by PreferredSortIndex__c NULLS LAST, name
		];
		
		for( ltng_TileLauncherEntry__c tile : allTiles ){

			//-- update the sort order
			if( tileSortPreferenceMap.containsKey(tile.Id) ){
				tile.PreferredSortIndex__c = tileSortPreferenceMap.get(tile.Id);
			}

			if( String.isEmpty( tile.Permission__c )){
				results.add( tile );
			} else {
				if( !tilesByPermission.containsKey( tile.Permission__c )){
					tilesByPermission.put( tile.Permission__c, new ltng_TileLauncherEntry__c[]{} );
				}
				tilesByPermission.get( tile.Permission__c ).add( tile );
			}
		}
		
		//-- @INVARIANT: all quicklinks have been recieved, and are now grouped by custom permission developer name within a map.
		allTilePermissions = tilesByPermission.keySet();
		//System.debug( 'allTilePermissions:' + allTilePermissions );
		
		//-- create a translation for all custom permission DeveloperNames to their IDs
		for( CustomPermission perm: [
			SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName in :allTilePermissions
		]){
			customPermissions.put( perm.Id, perm.DeveloperName );
		}
		
		//System.debug( 'customPermissionsMap:' + customPermissions );
		//-- collect all permission sets by custom permission developer name
		String permissionName;
		for( SetupEntityAccess access: [
			SELECT SetupEntityId, ParentId FROM SetupEntityAccess WHERE SetupEntityId in (
				SELECT Id FROM CustomPermission WHERE DeveloperName in :allTilePermissions
			)
		]){
			if( !permissionSetPermissions.containsKey( access.ParentId )){
				permissionSetPermissions.put( access.ParentId, new String[]{} );
			}
			permissionName = customPermissions.get( access.SetupEntityId );
			permissionSetPermissions.get( access.ParentId ).add( permissionName );
		}
		
		//-- @INVARIANT: we now have a list of all permissionSets with the custom permissions that they contain.
		//System.debug( 'permissionSetPermissions:' + permissionSetPermissions );
		
		//-- determine all the custom permissions that the user has
		Set<String> userCustomPermissions = new Set<String>();
		for( PermissionSetAssignment assignment: [
			SELECT PermissionSetId FROM PermissionSetAssignment where AssigneeId = :userId
		]){
			//System.debug( 'permissionSet[' + assignment.PermissionSetId + ']:' + permissionSetPermissions.get( assignment.PermissionSetId ) );
			if( permissionSetPermissions.containsKey( assignment.PermissionSetId )){
				userCustomPermissions.addAll( permissionSetPermissions.get( assignment.PermissionSetId ) );
			}
		}
		
		//-- @INVARIANT - we now know all the custom permissions that the user belongs to.
		//System.debug( 'userCustomPermissions:' + userCustomPermissions );
		
		for( String userCustomPermission : userCustomPermissions ){
			results.addAll( tilesByPermission.get( userCustomPermission ));
		}
		
		//System.debug( 'results:' + results );
		
		//} catch( Exception err ){}
		
		return( results );
	}

	/**
	 * Save all the user order settings
	 * <p>Either we can save them all in one swoop, like this,
	 *  or we can save them peicemeal as they happen.</p>
	 * <p>There was concern with how much api usage it would consume
	 *  (and how noisy it would be)
	 *  so all in one swoop was chosen.</p>
	 * <p>But there is lingering concern with how many preferences
	 *  would need to be saved / especially with a larger set of tiles.</p>
	 * @param ltng_TileLauncherEntryPreference__c[]
	 * return {boolean}
	 **/
	@AuraEnabled
	public static ltng_TileLauncherEntryPreference__c[] saveTilePreferences(String tilePreferencesJSON) {

		System.debug('tilePreferencesJSON'); System.debug(tilePreferencesJSON);
		/*
		There is a known issue on this, where we cannot accept an array of SObjects.
		https://success.salesforce.com/issues_view?id=a1p3A000000EAbLQAW&title=passing-an-apex-custom-object-parameter-type-from-an-aura-component-to-an-apex-controller-throws-an-error

		Currently the parser says that this will not work:
		[{"PreferredSortIndex__c":4,"TileLauncherEntry__c":"a005B000001wgzYQAQ"},
		{"PreferredSortIndex__c":5,"TileLauncherEntry__c":"a005B000001wgzcQAA"}];
		but adding in an ID WILL work
		[{"Id":"a015B0000076jDYQAY","PreferredSortIndex__c":4,"TileLauncherEntry__c":"a005B000001wgzYQAQ"},
		{"Id":"a015B0000076jCuQAI","PreferredSortIndex__c":5,"TileLauncherEntry__c":"a005B000001wgzcQAA"}]

		Unfortunately, it cannot be any valid Id,
		but that the shortId must be valid - and the IDs must be unique.
		so this WOULD work:
		[{"Id":"a01000000000000001","PreferredSortIndex__c":4,"TileLauncherEntry__c":"a005B000001wgzYQAQ"},
		{"Id":"a01000000000000001","PreferredSortIndex__c":5,"TileLauncherEntry__c":"a005B000001wgzcQAA"}]
		This doesn't make that easy if we are upserting records, as we would have to generate the ID
		and then clear it out prior to saving.  This isn't always allowed.

		SO THE CURRENT KLUDGE is that we need to store it in JSON and then deserialize it here.

		We do this through the TilePreferenceCollection and TilePreference classes below...
		*/

		TilePreferenceCollection tilePreferences = ((TilePreferenceCollection)System.JSON.deserialize(tilePreferencesJSON, TilePreferenceCollection.class));

		Id currentUserId = UserInfo.getUserId();
		System.debug('userId:' + currentUserId);
		System.debug('tilePreferences'); System.debug(tilePreferences);
		System.debug('tilePreferences.length:' + tilePreferences.records.size());

		ltng_TileLauncherEntryPreference__c[] recordsToUpdate = new ltng_TileLauncherEntryPreference__c[]{};
		ltng_TileLauncherEntryPreference__c newPreference;
		
		for(TilePreference tilePreference : tilePreferences.records){
			newPreference = new ltng_TileLauncherEntryPreference__c(
				TileLauncherEntry__c = tilePreference.tileLauncherEntryId,
				PreferredSortIndex__c = Decimal.valueOf(tilePreference.preferredSortIndex),
				User__c = currentUserId,
				UniqueId__c = currentUserId + '-' + tilePreference.tileLauncherEntryId
			);

			recordsToUpdate.add(newPreference);
		}

		System.debug(recordsToUpdate);

		Schema.SObjectField uniqueIdField = ltng_TileLauncherEntryPreference__c.UniqueId__c.getDescribe().getSObjectField();
		
		//try {
			Database.upsert(recordsToUpdate, uniqueIdField, true);
		//} catch(Exception err){
		//	throw new AuraHandledException('Exception occurred when processing: saveTilePreferences');
		//}
		
		return(recordsToUpdate);
	}

	public class TilePreferenceCollection {
		@AuraEnabled
		public TilePreference[] records {get;set;}
	}

	public class TilePreference {
		@AuraEnabled
		public string tileLauncherEntryId {get;set;}

		@AuraEnabled
		public double preferredSortIndex {get;set;}
	}
	

	/**
	 * Determines the tile launcher formats.
	 * @return ltng_TileLauncherNavigationFormat__mdt[] - collection of tile launcher navigation formats.
	 **/
	 @AuraEnabled
	 public static ltng_TileLauncherNavigationFormat__mdt[] getLauncherFormats() {
		ltng_TileLauncherNavigationFormat__mdt[] results;

		//-- @TODO: review only retrieving formats that match an object format
		//-- but this is cleaner and expected to be fairly small in number.
		try {
			results = [
				SELECT id, DeveloperName, Navigation_Type__c, Navigation_Object_Format__c, URL_Format__c, Priority__c
				FROM ltng_TileLauncherNavigationFormat__mdt
				ORDER BY Navigation_Type__c, Priority__c desc
			];		 
		} catch(Exception err){
			throw new AuraHandledException('Exception occurred when processing: getLauncherFormats');
		}

		return(results);
	 }
}