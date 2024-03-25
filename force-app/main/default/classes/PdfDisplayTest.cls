@IsTest
public class PdfDisplayTest {
    @IsTest
    public static void testGetObjectDetails() {
        Test.startTest();
        List<Account> acc = DexUtilTestDataFactory.createAccounts(1, true, null);          
        PdfDisplay.ObjectDetails result = PdfDisplay.getObjectDetails(acc[0].id);       
        System.assertEquals('Account', result.objectName);
        System.assertEquals('Account', result.objectLabel);      
        Test.stopTest();
    }
    
    @isTest
    static void testGetBaseURL() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
           System.assertEquals(PdfDisplay.getDomainUrl(), URL.getOrgDomainUrl().toExternalForm(), 'Both must be same.');
       	}
        Test.stopTest();
    }
}