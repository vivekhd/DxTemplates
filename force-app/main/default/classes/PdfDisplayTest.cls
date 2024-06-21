@IsTest
public class PdfDisplayTest {
    
    @IsTest
    public static void testGetObjectDetails() {
        List<Account> acc = DexUtilTestDataFactory.createAccounts(1, true, null);          
        PdfDisplay.ObjectDetails result = PdfDisplay.getObjectDetails(acc[0].id);  
        System.assertEquals('Account', result.objectName, 'Expected');
        System.assertEquals('Account', result.objectLabel, 'Expected');
        System.assertEquals(acc[0].Name, result.recordName, 'As per test data');
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