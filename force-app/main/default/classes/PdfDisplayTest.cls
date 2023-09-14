@isTest
public class PdfDisplayTest {
    @isTest
    public static void testGetObjectDetails() {
       
        List<Account> acc = DexUtilTestDataFactory.createAccounts(1, true, null);          
        PdfDisplay.ObjectDetails result = PdfDisplay.getObjectDetails(acc[0].id);       
        System.assertEquals('Account', result.objectName);
        System.assertEquals('Account', result.objectLabel);      
    }
    
    @IsTest
    public static void testGetDomainUrl() {
       Test.startTest();
       String domainURL = PdfDisplay.getDomainUrl();
       Test.stopTest(); 
       System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm(), domainUrl);
    }
}