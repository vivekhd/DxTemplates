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
    
    @IsTest
    public static void testGetDomainUrl() {
        Test.startTest();
        String domainURL = PdfDisplay.getDomainUrl();
        Test.stopTest();
        System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm(),domainUrl,'Error: Assertion Failed');
    }
}