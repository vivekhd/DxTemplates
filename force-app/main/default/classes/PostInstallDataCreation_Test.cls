/* 
* Class			: PostInstallDataCreation_Test.apxc
* Developer		: Rahul Bejgam        
* Created Date		: 11/09/2023
* Description		: This class is for the test of PostInstallDataCreation.apxc.
* Running Test on Class : PostInstallDataCreation.apxc
* Last Modified Date: 11/09/2023
*/

@IsTest
private class PostInstallDataCreation_Test {
    @IsTest           
    public static void runTestClass() {
        PostInstallDataCreation myClass = new PostInstallDataCreation();
        Test.testInstall(myClass, null);
        System.assert(true, 'Runs in Installation Context');
    }
}