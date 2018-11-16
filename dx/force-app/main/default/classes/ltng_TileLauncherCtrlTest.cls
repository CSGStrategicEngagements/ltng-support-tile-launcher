/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ltng_TileLauncherCtrlTest {

    static final String adminOnlyCustomPermission = 'ltng_TileLauncherAdmin';

    public static User createAdminUser(){
        User adminUser = ltng_TileLauncherObjFactory.setupAdmin('admin');
        return adminUser;
    }

    public static User createParticipantUser(){
        User participant = ltng_TileLauncherObjFactory.setupUser('user');
        return participant;
    }
    
    class TestSettings {
        
        //-- instance values
        ltng_TileLauncherEntry__c[] entries;
        ltng_TileLauncherCtrl.TilePreferenceCollection preferenceCollection;
        String preferenceJSON;

        public TestSettings(){
            //-- global setup here
        }

        public void useDemoSetup(){
            ltng_TileLauncherDemoSetupCtrl.createBaseRecords(false);
            this.entries = ltng_TileLauncherCtrl.getMyLinks();
        }

        public void generateTileLauncherPreferences(ltng_TileLauncherEntry__c[] entriesInOrder){
            this.preferenceCollection = new ltng_TileLauncherCtrl.TilePreferenceCollection();
            
            ltng_TileLauncherCtrl.TilePreference preference;
            ltng_TileLauncherCtrl.TilePreference[] preferences =
                new ltng_TileLauncherCtrl.TilePreference[]{};
            
            ltng_TileLauncherEntry__c entry;
            for (Integer i = 0; i < entriesInOrder.size(); i++){
                entry = entriesInOrder[i];
                preference = new ltng_TileLauncherCtrl.TilePreference();
                preference.tileLauncherEntryId = entry.Id;
                preference.preferredSortIndex = i;

                preferences.add(preference);
            }

            this.preferenceCollection.records = preferences;

            //-- store it in JSON so we can send it to an aura enabled method
            this.preferenceJSON = System.JSON.serialize(this.preferenceCollection);
        }

        public void finalize(){
            
        }
    }

    //-- test test methods here
    static testMethod void runDemoSetupWithoutException() {
        try {
            TestSettings ts = new TestSettings();
            ts.useDemoSetup();
            ts.finalize();
        } catch( Exception err ){
            System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }

    static testMethod void runAsAdminUserWithoutException(){
        User adminUser = createAdminUser();
        System.runAs(adminUser){
            System.debug('running as admin user:' + adminUser.Id);
            try {
                TestSettings ts = new TestSettings();
                ts.useDemoSetup();
                ts.finalize();
            } catch( Exception err ){
                System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
            }
        }
    }
    
    static testMethod void testAdminCanSeeAdminOnlyTiles(){
        User adminUser = createAdminUser();
        System.runAs(adminUser){
            System.debug('running as admin user:' + adminUser.Id);
            
            TestSettings ts = new TestSettings();
            ts.useDemoSetup();
            ts.finalize();

            //-- lets test some things
            System.debug('entries found'); System.debug(ts.entries);
            System.assertNotEquals(ts.entries, null, 'There should be tile entries found');
        }
    }
    
    static testMethod void normalUserCannotSeeAdminTiles(){
        User participant = createParticipantUser();
        System.runAs(participant){
            System.debug('running as participant user:' + participant.Id);
            
            TestSettings ts = new TestSettings();
            ts.useDemoSetup();
            ts.finalize();

            //-- lets test some things
            System.debug('entries found'); System.debug(ts.entries);
            System.assertNotEquals(ts.entries, null, 'There should be tile entries found');

            String permission;
            
            for (ltng_TileLauncherEntry__c entry : ts.entries) {
                System.assertNotEquals( entry.Permission__c, adminOnlyCustomPermission, 'Normal users should not have admin only permission: ' + adminOnlyCustomPermission);
            }
        }
    }

    static testMethod void launcherFormatsAreInMetadata(){
        TestSettings ts = new TestSettings();
        ts.useDemoSetup();
        ts.finalize();

        ltng_TileLauncherNavigationFormat__mdt[] formats = ltng_TileLauncherCtrl.getLauncherFormats();

        System.assert(formats != null);
    }

    static testMethod void changingTheOrderThroughJsonPreservesOrder(){
        User adminUser = createAdminUser();
        System.runAs(adminUser){
            System.debug('running as adminUser:' + adminUser.Id);

            TestSettings ts = new TestSettings();
            ts.useDemoSetup();
            ts.finalize();

            //-- create a new order to preserve
            //-- go through this because the apex requires JSON currently
            //-- to send collections to an aura enabled method
            ltng_TileLauncherEntry__c[] entries = ltng_TileLauncherCtrl.getMyLinks();
            ltng_TileLauncherEntry__c entry;
            ltng_TileLauncherEntry__c[] newSortOrder = new ltng_TileLauncherEntry__c[]{};
            Integer newIndex;
            newSortOrder.add(entries[2]);
            newSortOrder.add(entries[1]);
            newSortOrder.add(entries[0]);

            ts.generateTileLauncherPreferences(newSortOrder);
            
            //-- verify they were created correctly
            for (ltng_TileLauncherCtrl.TilePreference preferenceObj : ts.preferenceCollection.records){
                newIndex = Integer.valueOf(preferenceObj.preferredSortIndex);
                entry = newSortOrder[newIndex];
                System.assertEquals(
                    preferenceObj.tileLauncherEntryId, entry.Id,
                    'order of the new sort order needs to match the new preferred index'
                );
            }
            
            System.debug('preferenceJSON');
            System.debug(ts.preferenceJSON);
            System.assert(!String.isEmpty(ts.preferenceJSON));
            System.assertNotEquals(ts.preferenceJSOn.indexOf(newSortOrder[0].Id), -1, 'the new sort preference has to be in there somewhere');

            //-- send the preferences over
            ltng_TileLauncherEntryPreference__c[] resultPreferences = 
                ltng_TileLauncherCtrl.saveTilePreferences(ts.preferenceJSON);

            //-- lets make sure the preferences are correct
            System.assertNotEquals(resultPreferences, null, 'we need to get the preferences back from submission');
            System.assertEquals(resultPreferences.size(), newSortOrder.size(), 'we send x preferences in, we need them coming out');

            for (ltng_TileLauncherEntryPreference__c preference : resultPreferences){
                //-- same as the above, only with the preference records
                newIndex = Integer.valueOf(preference.PreferredSortIndex__c);
                entry = newSortOrder[newIndex];
                System.assertEquals(
                    preference.TileLauncherEntry__c, entry.Id,
                    'order of the created preference needs to match the new preferred index'
                );
            }
        }
    }
}