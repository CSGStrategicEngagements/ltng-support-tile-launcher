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
private class ltng_HeroButtonCtrlTest {

    static final String exampleResourceName = 'ltng_TileLauncherHero';

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
        ltng_HeroButtonCtrl.HeroNotification[] heroNotifications;
        
        public TestSettings(){
            //-- global setup here
        }

        public void useDemoSetup(){
            ltng_TileLauncherDemoSetupCtrl.createBaseRecords(false);
            heroNotifications = ltng_HeroButtonCtrl.getMyHeroNotifications();
        }
        
        public void finalize(){
            
        }
    }

    //-- test test methods here
    static testMethod void runSetupAWithoutException() {
        try {
            TestSettings ts = new TestSettings();
            ts.useDemoSetup();
            ts.finalize();
        } catch( Exception err ){
            System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }

    static testMethod void adminMustHaveHeroNotificationsFromDemoSetup(){
        User adminUser = createAdminUser();
        System.runAs(adminUser){
            System.debug('running as admin user:' + adminUser.Id);
            try {
                TestSettings ts = new TestSettings();
                ts.useDemoSetup();
                ts.finalize();

                System.assertNotEquals(ts.heroNotifications, null, 'admin should not get null notifications on setup');
                System.assertNotEquals(ts.heroNotifications.size(), 0, 'an admin should have some hero notifications');
            } catch( Exception err ){
                System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
            }
        }
    }

    static testMethod void participantsMustHaveNotificationsFromDemoSetup(){
        User adminUser = createAdminUser();
        System.runAs(adminUser){
            System.debug('running as admin user:' + adminUser.Id);
            try {
                TestSettings ts = new TestSettings();
                ts.useDemoSetup();
                ts.finalize();

                System.assertNotEquals(ts.heroNotifications, null, 'user should not get null notifications');
                system.assertNotEquals(ts.heroNotifications.size(), 0, 'an user should have some hero notifications');
            } catch( Exception err ){
                System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
            }
        }
    }

    static testMethod void staticResourceAddressesShouldBeFound(){
        TestSettings ts = new TestSettings();
        ts.finalize();
        
        try {
            String resourceAddress = ltng_HeroButtonCtrl.getResource(exampleResourceName);
            System.debug('result resource address:' + resourceAddress);

            System.assertNotEquals(resourceAddress, null, 'we should have some kind of address for a resource');
        } catch( Exception err){
            System.assert(false, 'exception must not be thrown when calculating address for resource:' + err.getMessage());
        }
    }
}