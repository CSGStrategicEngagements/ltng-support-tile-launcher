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
		
		//-- determine all quicklinks and sort them by the permission required to see them.
		ltng_TileLauncherEntry__c[] allTiles = [ select id, name, Description__c, ExternalId__c, IconGroup__c, IconName__c, Type__c, Target__c, Permission__c, PreferredSortIndex__c, LastModifiedDate
			from ltng_TileLauncherEntry__c
			order by PreferredSortIndex__c NULLS LAST, name
		];
		
		for( ltng_TileLauncherEntry__c tile : allTiles ){
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
}