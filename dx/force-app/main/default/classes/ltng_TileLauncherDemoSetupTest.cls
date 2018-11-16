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
private class ltng_TileLauncherDemoSetupTest {
    
    class TestSettings {
        
        //-- instance values
        String AdminAlias = 'Admin';
        User adminUser;
        
        public TestSettings(){
            //-- global setup here
        }
        
        public void setupA(){
            //-- specific setup here
        }

        public User createAdminWithoutPermissionSet(){
            adminUser = ltng_TileLauncherObjFactory.createAdminUser(AdminAlias);
            return adminUser;
        }

        public User createAdminUser(){
            adminUser = ltng_TileLauncherObjFactory.setupAdmin(AdminAlias);
            return adminUser;
        }
        
        public void finalize(){
            
        }
    }

    //-- test test methods here
    static testMethod void runSetupAWithoutException() {
        try {
            TestSettings ts = new TestSettings();
            ts.setupA();
            ts.finalize();
        } catch( Exception err ){
            System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }

    static testMethod void testObjectFactory() {
        try {
            TestSettings ts = new TestSettings();
            ts.createAdminUser();
            ts.finalize();
        } catch( Exception err ){
            System.assert( false, 'Exception must not be thrown:' + err.getMessage() );
        }
    }

    static testMethod void runSetupInfoListsSteps(){
        TestSettings ts = new TestSettings();
        User adminUser = ts.createAdminWithoutPermissionSet();

        System.runAs(adminUser){
            ts.finalize();

            //-- run the Demo Setup
            ltng_TileLauncherDemoSetupCtrl.SetupStep[] setupSteps;
            ltng_TileLauncherDemoSetupCtrl.SetupStep setupStep;

            setupSteps = ltng_TileLauncherDemoSetupCtrl.runSetup(true);

            System.assert(setupSteps != null, 'running setup should return steps');
        }
    }

    static testMethod void runSetupLoadsData(){
        TestSettings ts = new TestSettings();
        User adminUser = ts.createAdminWithoutPermissionSet();

        //-- permission set assignment will happen in the future anyway
        //-- so code coverage won't include it.

        System.runAs(adminUser){
            ts.finalize();
            
            //-- run the Demo Setup
            ltng_TileLauncherDemoSetupCtrl.SetupStep[] setupSteps;
            ltng_TileLauncherDemoSetupCtrl.SetupStep setupStep;
            
            setupSteps = ltng_TileLauncherDemoSetupCtrl.runSetup(false);

            System.assert(setupSteps != null, 'running setup should return steps');
        }
    }
    
    //-- test functionality here
    
    
}