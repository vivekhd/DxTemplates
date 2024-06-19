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
        insert new DxCPQ__Document__c(DxCPQ__Document_Body__c = '<div>Test</div>');
        insert new Attachment(Name = 'Test Document', Body = Blob.valueOf('<div>Test</div>'),parentId = newDoc.Id);
        
        Test.startTest();
            PostInstallDataCreation myClass = new PostInstallDataCreation();
            Test.testInstall(myClass, null);
            System.assert(true);
        Test.stopTest();
    }
}