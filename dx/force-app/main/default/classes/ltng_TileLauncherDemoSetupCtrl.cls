/**
 * Controller for the Demo Setup page.
 **/
/*
 * //-- CHANGE
 * //-- ensure the class name matches the name of the Setup page + CTRL
 * //-- ex: ltng_TileLauncherDemoSetupCtrl
 **/
global with sharing class ltng_TileLauncherDemoSetupCtrl {

    //-- static
    
    /** URL patterm for navigating to a permissionSet **/
    global static final String DEFAULT_MISSING_PERMISSION_URL = '/one/one.app#/setup/PermSets/home';
	
	//--	-	-	-	-	-	-	-	-	-	-	-
	//-- START OF LINES TO UPDATE
	//--	-	-	-	-	-	-	-	-	-	-	-
	
	//-- set the values that specific to your project
	
    //-- The Name of your Permission Set
    //--	(e.g.: SELECT Id, Name FROM PermissionSet WHERE Name = 'TileLauncherDemoParticipant')
    //--    ex: LightningSupportDemoParticipant
    //--	We should use Permission Sets for all Demos, instead of modifying Profiles.
    
    /** Developer Name for the Permission Set **/
    global static final String PERMISSION_SET_NAME = 'TileLauncherDemoAdmin';
    
    
    //-- @CHANGE: replace ltng_TileLauncherEntry__c with the SObject Durable Name
    //-- 	of the objects you will create - (if objects are created)
    //--    ex: MyCustomObject__c
    //--    (e.g.:  SELECT DeveloperName, DurableId FROM EntityDefinition WHERE DeveloperName = 'Object API Name')
        
    /**
     * API Name of the Object to create.
     *	(Although not required, it is fairly common to create objects in setup)
     **/
    global static final String CHILD_SOBJECT_NAME  = 'ltng_TileLauncherEntry__c';
    
    //-- @CHANGE: replace YOUR_RECORD_TYPE_NAME with the RecordType Developer Name
    //--	of the objects you will create - (if objects / record types are used)
    //--	ex: 'Master'
    //--	(e.g: SELECT Id, DeveloperName, Name, SObjectType FROM RecordType WHERE SObjectType = 'YOUR_RECORD_TYPE_NAME'
	
    /** Developer Name of the record types to use when creating records
    	(Leave blank if no record types are used)
    **/
    global static final String RT_NAME = '';

    

    /**
     * Method called from the Lightning Component to either:
     * 		Determine the steps that will be run,
     *		Or to run the steps and learn the results from running them.
     * 
     * @return SetupStep[] - list of setup steps ran and the status for each.
     **/
    @AuraEnabled
    global static SetupStep[] runSetup(boolean getInfoOnly){
    	
    	//-- Each method that is called returns a SetupStep instance.
    	
    	//-- if getInfoOnly is `TRUE`, then nothing is executed,
    	//-- and we only get info about the step to be run.
    	
    	//-- if getInfoOnly is `FALSE`, then the step is executed
    	//-- and info about what was run, including results/errors/etc., are returned.
    	
        SetupStep[] results = new SetupStep[]{
            removeAllBaseRecords(getInfoOnly),
            createBaseRecords(getInfoOnly),
            addUserToPermissionSet(getInfoOnly)
            //-- @CHANGE: add in additional steps as desired
        };
        return results;
    }

    //-- actual steps to run

    /**
     * Remove any of the base records that are currently there.
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep removeAllBaseRecords( boolean getInfoOnly){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Remove any existing base objects'
        });

        if(getInfoOnly){
            return step;
        }
        
        SObject[] recordsToDelete = null;
        try {
            recordsToDelete = [
                SELECT Id
                FROM ltng_TileLauncherEntry__c
            ];
            
            delete recordsToDelete;
            
            
            recordsToDelete = [
                SELECT Id
                FROM ltng_HeroNotification__c
            ];
            
            delete recordsToDelete;
        } catch(Exception err){
            step.errMsg = 'Error occurred while attempting to delete all base records';
            step.devErrMsg = err.getMessage();
            //-- do nothing for now.
            System.debug(step.errMsg);
        }
        
        step.markCompleted();
        return(step);
    }

    /**
     * Create the base records.
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    global static SetupStep createBaseRecords( boolean getInfoOnly ){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Create Base Objects',
            'descr' => 'Create the objects that the demos start from'
        });

        if(getInfoOnly){
            return step;
        }
        
        //-- determine the record type Names => Salesforce ID translation map
		Set<String> RECORD_TYPE_NAMES = new Set<String>{RT_NAME};
        
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        try {
        	if( !String.isEmpty(RT_NAME)){
				for( RecordType rt : [
					SELECT Id, DeveloperName, Name, SObjectType
					FROM RecordType
					WHERE SObjectType in :RECORD_TYPE_NAMES
				]){
					recordTypeMap.put(rt.DeveloperName, rt.Id);
				}
			}
        } catch(Exception err){
        	//-- for now, consume the error, as we handle it separately
        }
        
        //-- generate the objects to create by converting the Salesforce CLI:tree:export
        //-- into an apex version.
        
        /*
        It is recommended that you store all queries used for extracting data
        and store them separately from your data (in case you need it again)
        
        data/queries/ltng_TileLauncherEntry__c.txt
        SELECT Example_Value__c FROM ltng_TileLauncherEntry__c
        
        Say that the query you ran gave you this:
        sfdx force:data:tree:export -q queries/ltng_TileLauncherEntry__c.txt -d tree/
        
        { "records": [	{
							"attributes": {
								"type": "ltng_TileLauncherEntry__c"
							},
							"Example_Value__c": 1000
		}	]	}
		
		You can strip out the attributes, and only really care about:
		{ "Example_Value__c": 1000 }
		
		You can then convert it to an SObject like so:
		ltng_TileLauncherEntry__c[] baseRecords = new ltng_TileLauncherEntry__c[]{};
		
		baseRecords.add( new ltng_TileLauncherEntry__c(
			Example_Value__c = 1000
		));
		
		or
		
		baseRecords.add( new ltng_TileLauncherEntry__c(
			Example_Value__c = 1000,
			RecordTypeId = recordTypeMap.get(RT_NAME)
		));
		*/
		
		//-- @CHANGE: implement the records to be created
		//--	(the following is an example set of code)
		
		ltng_TileLauncherEntry__c[] baseRecords = new ltng_TileLauncherEntry__c[]{};
        ltng_TileLauncherEntry__c baseRecord;
        
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'Salesforce Accounts',
            ExternalId__c = 'obj_accounts',
            IconGroup__c = 'standard',
            IconName__c = 'account',
            Name = 'Accounts',
            Target__c = '/lightning/o/Account/home',
            Type__c = 'Object Page'
		));
		
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'Salesforce Opportunities',
            ExternalId__c = 'obj_opportunities',
            IconGroup__c = 'standard',
            IconName__c = 'opportunity',
            Name = 'Opportunities',
            Target__c = '/lightning/o/Opportunity/home',
            Type__c = 'Object Page'
		));
		
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'External System! Your gateway to payments and commisions.',
            ExternalId__c = 'sys_externalSystem',
            IconGroup__c = 'standard',
            IconName__c = 'omni_supervisor',
            Name = 'External System',
            Target__c = 'https://www.google.com',
            Type__c = 'URL'
		));
		
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'Link only available to Admins',
            ExternalId__c = 'admin_link',
            IconGroup__c = 'standard',
            IconName__c = 'custom',
            Name = 'Admin Only Link',
            Target__c = '/lightning/o/ltng_TileLauncherEntry__c/home',
            Permission__c = 'ltng_TileLauncherAdmin',
            Type__c = 'Object Page'
		));
		
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'List of hero images currently in use',
            ExternalId__c = 'obj_heroNotifications',
            IconGroup__c = 'standard',
            IconName__c = 'announcement',
            Name = 'Hero Notifications',
            Target__c = '/lightning/o/ltng_HeroNotification__c/home',
            Permission__c = 'ltng_TileLauncherAdmin',
            Type__c = 'Object Page'
		));
		
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'Directs you to the home page',
            ExternalId__c = 'np_home',
            IconGroup__c = 'standard',
            IconName__c = 'home',
            Name = 'Home',
            Target__c = '/lightning/page/home',
            Permission__c = '',
            Type__c = 'Named Page'
		));
		
		baseRecords.add(new ltng_TileLauncherEntry__c(
            Description__c = 'Navigates you to a Lightning or VF Page',
            ExternalId__c = 'nav_TileLauncher',
            IconGroup__c = 'standard',
            IconName__c = 'apps',
            Name = 'Tile Launcher',
            Target__c = '/lightning/n/ltng_TileLauncher',
            Type__c = 'Navigation Item Page'
		));
		
		ltng_HeroNotification__c[] heroRecordsToCreate = new ltng_HeroNotification__c[]{};
		
		heroRecordsToCreate.add(new ltng_HeroNotification__c(
            Title__c = 'Hero 1',
            AlternativeText__c = 'Hero 1 Alt Text',
            Description__c = 'Description of Hero 1',
            ExternalId__c = 'ex_Hero1',
            Name = 'Example Hero 1',
            Priority__c = 1,
            ResourceName__c = 'ltng_HeroImageExample1'
		));
		
		heroRecordsToCreate.add(new ltng_HeroNotification__c(
            Title__c = 'Hero 2',
            AlternativeText__c = 'Hero 2 Alt Text',
            Description__c = 'Description of Hero 2',
            ExternalId__c = 'ex_Hero2',
            Name = 'Example Hero 2',
            Priority__c = 2,
            ResourceName__c = 'ltng_HeroImageExample2'
		));
		
		heroRecordsToCreate.add(new ltng_HeroNotification__c(
            Title__c = 'Hero 3',
            AlternativeText__c = 'Hero 3 Alt Text',
            Description__c = 'Description of Hero 3',
            ExternalId__c = 'ex_Hero3',
            Name = 'Example Hero 3',
            Priority__c = 3,
            ResourceName__c = 'ltng_HeroImageExample3'
		));
        
        try {
            insert baseRecords;
            insert heroRecordsToCreate;
        } catch( Exception err){
            step.errMsg = 'error occurred while creating base records';
            step.devErrMsg = err.getMessage();
            System.debug(step.errMsg);
        }

        step.markCompleted();
        return(step);
    }
    
    //-- @CHANGE: add in any additional steps
    /**
     * Example step
     * @param getInfoOnly (Boolean) - whether to report what would be done (true) or run the step (false)
     **/
    /*
    global static SetupStep doSomethingElse( boolean getInfoOnly ){
    	//-- @SEE SetupStep below - displayed in lightning component DemoSetupItem.cmp
    	SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Assign current user PermissionSet to see the Demo',
            'descr' => 'PermissionSet: ' + PERMISSION_SET_NAME + '. May take a second to take effect.',
            'reasoning' => 'All access is granted by PermissionSet. Only those with this PermissionSet can see the demo'
        });
    
        if( getInfoOnly ){
        	return(step);
        }
        
        //-- do stuff
        try {
        	//-- do stuff
        } catch(Exception err){
        	step.errMsg = 'Could not do stuff';
        	step.devErrMsg = err.getMessage();
        }
        
        step.markCompleted();
        return(step);
    }
    */
    
    
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    //--    END OF LINES TO UPDATE
    //--    -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    

    
    //--	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-
    
    
    /**
     * Assign the user to the custom permission.
     * <p>Note: actual work must be a future to avoid a MixedDML issue</p>
     **/
    global static SetupStep addUserToPermissionSet( boolean getInfoOnly ){
        SetupStep step = new SetupStep( new Map<String,Object>{
            'title' => 'Assign current user PermissionSet to see the Demo',
            'descr' => 'PermissionSet: ' + PERMISSION_SET_NAME + '. May take a second to take effect.',
            'reasoning' => 'All access is granted by PermissionSet. Only those with this PermissionSet can see the demo'
        });

        if( getInfoOnly ){
            return(step);
        }

        addUserToPermissionSetImpl();

        step.markCompleted();
        return(step);
    }

    
    /**
     * Implementation that actually adds the user to the permission set.
     **/
    @future
    global static void addUserToPermissionSetImpl(){    
        Id userId = UserInfo.getUserId();
        PermissionSetAssignment[] results = null;
        
        try {
            PermissionSet ps = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = :PERMISSION_SET_NAME
                LIMIT 1
            ];

            results = [
                SELECT Id, PermissionSetId, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId
                    AND PermissionSetId = :ps.Id 
                LIMIT 1
            ];
            
            if(results.size() > 0){
                System.debug('User is already assigned to the PermissionSet');
            } else {
                results = new PermissionSetAssignment[]{
                    new PermissionSetAssignment( PermissionSetId = ps.Id, AssigneeId = UserInfo.getUserId() )
                };

                insert results;
            }
        } catch(Exception err){
            //-- do nothing
            System.debug('ERROR - could not assign user to permission set');
            System.debug(err.getMessage());
        }
    }
    
    
    /**
	 * Determine the URL to send people to so they can assign the PermissionSet
	 * the recordTypes needed.
	 * 
	 * <p>Only needed if objects are created and there are Record Types.
	 * 	(As there is a bug where PermissionSet assignments to RecordTypes
	 * 	currently do not deploy correctly in Unlocked Packages
	 * 	- but work fine with Salesforce CLI: force:source:push)
	 * </p>
	**/
    @AuraEnabled
    global static String getMissingPermissionSetRedirection(){
        String results = null;
        String tempStr = null;
        String newResult = null;
        
        try {
            PermissionSet targetPS = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name = :PERMISSION_SET_NAME
                LIMIT 1
            ];

            EntityDefinition targetObject = [
                SELECT DeveloperName, DurableId
                FROM EntityDefinition 
                WHERE DeveloperName = :CHILD_SOBJECT_NAME
            ];

            tempStr = '/' + targetPS.Id + '?s=EntityPermissions&o=' + targetObject.DurableId;
            newResult = '/one/one.app#/setup/PermSets/page?address=' + EncodingUtil.urlEncode(tempStr,'UTF-8');
            
            results = newResult;
        } catch(Exception err){
            results = DEFAULT_MISSING_PERMISSION_URL;
        }

        return results;
    }
    
    
    //--	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-	-
    
    
    /**
     * Internal class that represents an item to be completed.
     **/
    global class SetupStep {
        
    	/** Title of the Step being run. (Should be short) **/
        @AuraEnabled
        global String title;
        
        /** Longer form description of what will be run.
        	(Hidden if not provided)
        **/
        @AuraEnabled
        global String descr;
        
        /** Reasoning of why the step is needed.
        	(Hidden if not provided)
        **/
        @AuraEnabled
        global String reasoning;
        
        /** Additional detail to show the end user after the step.
        	(ex: Link to the object created, etc.)
        **/
        @AuraEnabled
        global String seeMore;
        
        /** Short label to provide back to the user after completing the step. **/
        @AuraEnabled
        global String seeMoreLabel;
        
        //-- properties set after attempt
    	
    	/** Whether the step is complete
    		(typically only set through markComplete())
    	**/
        @AuraEnabled
        global boolean isComplete;
        
        /** End user readible error found when running the step
        	(typically not initialized, only set afterwards)
        **/
        @AuraEnabled
        global String errMsg;
        
        /** Developer level error found when running the step
        	(typically not initialized, only set afterwards)
        **/
        @AuraEnabled
        global String devErrMsg;
        
        /** DateTime when the step completed.
    		(typically only set through markComplete())
    	**/
        @AuraEnabled
        global String completionDate;

        SetupStep( Map<String,Object> props){
            //-- make similar to sObject inline definition
            if( props.containsKey('title')){
                this.title = (String)props.get('title');
            }
            if( props.containsKey('descr')){
                this.descr = (String)props.get('descr');
            }
            if( props.containsKey('reasoning')){
                this.reasoning = (String)props.get('reasoning');
            }
            if( props.containsKey('seeMore')){
                this.seeMore = (String)props.get('seeMore');
            }
            if( props.containsKey('seeMoreLabel')){
                this.seeMoreLabel = (String)props.get('seeMoreLabel');
            }
            
            //-- not likely, but available if desired
			if( props.containsKey('isComplete')){
                this.isComplete = (boolean)props.get('isComplete');
            }
            if( props.containsKey('errMsg')){
                this.errMsg = (String)props.get('errMsg');
            }
            if( props.containsKey('devErrMsg')){
                this.devErrMsg = (String)props.get('devErrMsg');
            }
            if( props.containsKey('completionDate')){
                this.completionDate = (String)props.get('completionDate');
            }
        }
        
        /**
         * Mark the step as completed.
         * @invariant - marked completed with a current completion date.
         **/
        void markCompleted(){
            this.isComplete = true;
            this.completionDate = System.now().format();
        }
    }
}