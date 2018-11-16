/**
 *  Class that generates objects for use in UnitTests.
 *  @author Paul Roth <proth@salesforce.com>
 *  
 *  <p>Please note that there are three methods of generating test objects:
 *  * Option A - Common parameters are passed to generate the object:
 *  		ex: ltng_TileLauncherObjFactory.createAccount( 'AccountName' )
 *  * Option B - Parameters are passed as a multi-map and are assigned as needed.
 *  		ex: ltng_TileLauncherObjFactory( new Map<String,Object>{
 *  			'Name': 'AccountName'
 *  		} );
 *  * Object C - Classes specific to building a specific object, so methods are chained.
 *  		ex: new AccountBuilder( 'AccountName' )
 *  			.withAddress( '1000 Illinois St', 'Chicago', 'IL', '60108' )
 *  			.withShipping( '999 Auroa Rd.', 'Aurora', 'IL', '60000' )
 *  			.build();
 *  This class will employ Options A and B. Option C will be held separately.
**/
@isTest
public with sharing class ltng_TileLauncherObjFactory {
    
    //#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
    //-- Unique Maker Functionality
    /**
     * Unique identifier used to ensure the uniqueness within a test
     **/
    private static Integer UUID = 0;
    
    /**
     * Determines a unique value within a testing session
     * @return (Integer)
     **/
    public static Integer getUUID(){ return( ++UUID); }
    
    /**
     * Creates a unique string (such as a name)
     * @param str (String)
     * @return (String)
     **/
    public static String makeUnique( String str ){
        return( '' + str + getUUID() );
    }
    
    //#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
    //-- public constants
    
    //-- list of profiles we care about
    public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String PROFILE_STANDARD_USER = 'Standard User';
    
    /** List of Profile IDs indexed by DeveloperName. **/
    public static Map<String,Id> PROFILE_IDS;
    
    //-- list of permission sets.
    public static final String PERM_SET_TILELAUNCHER_ADMIN = 'TileLauncherDemoAdmin';
    public static final String PERM_SET_TILELAUNCHER_USER = 'TileLauncherDemoParticipant';
    public static Map<String,Id> PERMISSION_SET_IDS;
    
    public static final Map<String,Object> EMPTY_MAP;
    
    public static String USER_ALIAS_ADMIN = '_Admin';
    public static String USER_ALIAS_QL_ADMIN = '_QLAdmin';
    public static String USER_ALIAS_STD = '_StdUser';
    
    public static Map<String,User> userAliasMap = new Map<String,User>();
    
    //-- static initializer
    static {
        EMPTY_MAP = new Map<String,Object>();
        
        String[] PROFILE_NAMES = new String[]{
            PROFILE_SYSTEM_ADMINISTRATOR,
            PROFILE_STANDARD_USER
        };
        
        PROFILE_IDS = new Map<String,Id>();
        for( Profile myProfile : [
            select id, name
            from Profile
            where name in :PROFILE_NAMES
        ]){
            PROFILE_IDS.put(myProfile.name,myProfile.id);
        }
        
        String[] PERMISSION_SET_NAMES = new String[]{
            PERM_SET_TILELAUNCHER_ADMIN,
            PERM_SET_TILELAUNCHER_USER
        };
        
        PERMISSION_SET_IDS = new Map<String,Id>();

        for( PermissionSet permSet : [
            select id, name
            from PermissionSet
            where name in :PERMISSION_SET_NAMES
        ]){
            PERMISSION_SET_IDS.put( permSet.name, permSet.id );
        }
    }
    
    //#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
    //-- user creation methods
    /**
     *  Creates a test user.
     *  Specialized user creation should extend this method.
     *  @param String alias
     *  @param profileId Id
     *  @return User
    **/
    public static User createUser( String alias, Id profileId ){
        String uniqueAlias = ltng_TileLauncherObjFactory.makeUnique( alias );
        String email = '' + alias + '@unit.test.com';
        
        User newUser = new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            FirstName = 'JohnDoe',
            LanguageLocaleKey = 'en_US',
            LastName = 'TEST_' + alias,
            LocaleSIDKey = 'en_US',
            ProfileId = profileId,
            TimezoneSIDKey = 'America/Los_Angeles',
            Username = email
        );
        
        userAliasMap.put(alias,newUser);
        
        return( newUser );
    }
    
    /**
     *  Creates a set of permission set assignments.
     *  @param userId (Id)
     *  @param permissionSets (Id[]) - set of ids of permissionSets to assign
     *  @return PermissionSetAssignment[] - list of permissionSetAssignments
    **/
    public static PermissionSetAssignment[] createPermissionSetAssignments( Id userId, Id[] permissionSets ){
        PermissionSetAssignment[] results = new PermissionSetAssignment[]{};
        for( Id permissionSetId : permissionSets ){
            results.add( new PermissionSetAssignment(
                AssigneeId = userId, PermissionSetId = permissionSetId
            ));
        }
        return( results );
    }

    /**
     *  Creates a set of group members.
     *  @param userId (Id)
     *  @param groups (Id[]) - set of ids of groups to assign
     *  @return GroupMember[] - list of GroupMembers
    **/
    public static GroupMember[] createGroupMemberships( Id userId, Id[] groups ){
        GroupMember[] results = new GroupMember[]{};
        for( Id groupId : groups ){
            results.add( new GroupMember(
                    GroupId = groupId, UserOrGroupId = userId
            ));
        }
        return( results );
    }

    public static User createAdminUser( String alias ){
        Id profileId = PROFILE_IDS.get( PROFILE_SYSTEM_ADMINISTRATOR );
        User adminUser = createUser( alias, profileId );
        insert adminUser;

        return( adminUser );
    }
    
    public static User createStandardUser( String alias ){
        Id profileId = PROFILE_IDS.get( PROFILE_STANDARD_USER );
        User stdUser = createUser( alias, profileId );
        insert stdUser;

        return( stdUser );
    }
    
    /**
     *  Creates an admin and assigns the appropriate permissions
     *  <p>So this can be used within test run-as statements</p>
     *  <p>Please note: the user has ALREADY been created and does not need to be inserted in this case.</p>
     *  @param String alias
     *  @return User that is of type Internal User with the TileLauncher Admin Permission Set.
    **/
    public static User setupAdmin( String alias ){
        User adminUser = createAdminUser(alias);
        
        Id[] permissionSetIds = new Id[]{
            PERMISSION_SET_IDS.get( PERM_SET_TILELAUNCHER_ADMIN )
        };
        PermissionSetAssignment[] permSets = ltng_TileLauncherObjFactory.createPermissionSetAssignments(
            adminUser.Id, permissionSetIds
        );
        insert permSets;
        
        
        return( adminUser );
    }

    /**
     * Creates a participant with the appropriate permissions
     * @param alias (String)
     * @return User - that is of type standard user with the TileLauncher Participant permissions.
     **/
    public static User setupUser( String alias ){
        User participant = createStandardUser(alias);

        Id[] permissionSetIds = new Id[]{
            PERMISSION_SET_IDS.get( PERM_SET_TILELAUNCHER_USER )
        };
        PermissionSetAssignment[] permSets = ltng_TileLauncherObjFactory.createPermissionSetAssignments(
            participant.Id, permissionSetIds
        );
        insert permSets;

        return participant;
    }
    
    /**
     *  Determines a list of users by Alias.
     *  @param aliases (String[]) - list of aliases to retrive.
     *  @return Map<String,User> - users by their alias.
     **/
    public static Map<String,User> refreshUsersByAlias( String[] aliases ){
        
        //userAliasMap.clear();
        
        for( User u : [
            SELECT id, name, alias
            FROM user
            WHERE alias in :aliases
        ]){
            userAliasMap.put(u.alias, u);
        }
        
        return(userAliasMap);
    }
    
    //#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
    //-- Custom Settings
    
    

    //#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
    //-- SObject Creation
    
    /**
     * Creates an account record
     * @param Name (String)
     * @param ExternalId (String)
     **/
    public static Account createAccount( String Name, String externalId){
        if( String.isEmpty( ExternalId )){
            ExternalId = Name;
        }
        Account results = new Account(
            Name = Name
            //ExternalId__c = ExternalId
        );
        return( results );
    }
    
    //#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
    //-- Initializers
    
    public static void prepStandardCustomSettings(){
        //-- create any custom settings
    }
    
    
    /**
     * Initializes common custom settings to allow tests to proceed.
     * 
     * This includes:
     *  # integration user
     *  # Environment Ids
     *  #...
     * @return Map<String,Object> - information about the objects created.
     **/
    public static void prepStandardUsers(){
        //Map<Id,Object>() results = new Map<Id,Object>();

        //-- @TODO: currently this is a map because it is not expected that these are going to be needed at all.
        //-- if it is needed on a regular basis, perhaps this should be separated out to another class / internal class for results.
        if( !userAliasMap.containsKey(USER_ALIAS_ADMIN)){
            
            createAdminUser(USER_ALIAS_ADMIN);
            
            createStandardUser(USER_ALIAS_STD);

            setupAdmin(USER_ALIAS_QL_ADMIN);
        }
        
        return;
    }
}