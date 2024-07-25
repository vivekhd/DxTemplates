@isTest
private class LanguageTranslatorBatchTest {
    
    @isTest
    static void testLanguageTranslatorBatch() {
        // Setup test data
        // Create a sample document template
        DxCPQ__Document_Template__c docTemplate1 = new DxCPQ__Document_Template__c(Name = 'Test Template 1');
        insert docTemplate1;
        
        DxCPQ__Document_Template__c docTemplate2 = new DxCPQ__Document_Template__c(Name = 'Test Template 2');
        insert docTemplate2;
        
        // Create a sample document template section
        DxCPQ__Document_Template_Section__c docTemplateSection = new DxCPQ__Document_Template_Section__c(
            Name = 'Test Section', 
            DxCPQ__Document_Template__c = docTemplate1.Id
        );
        insert docTemplateSection;
        
        List<String> testStrings = new List<String>{
            'Hello, world!',
            'How are you?'
        };
        String testLanguage = 'es'; // Spanish
        String testTemplateId = docTemplate1.Id; // Example ID

        // Mock the LanguageTranslatorClass.translateText method
        Test.startTest();
        // Setup the mock response
        String mockResponse = '{"translations":[{"translatedText":"¡Hola, mundo!"}]}';
        LanguageTranslatorClassMock mockTranslator = new LanguageTranslatorClassMock(mockResponse);
        Test.setMock(HttpCalloutMock.class, mockTranslator);

        // Execute the batch
        LanguageTranslatorBatch batch = new LanguageTranslatorBatch(testStrings, testLanguage, testTemplateId);
        Database.executeBatch(batch);

        Test.stopTest();
        
        // Verify results
        List<DxCPQ__Translator__c> translatedRecords = [SELECT Name, DxCPQ__Translated_Value__c, DxCPQ__Language__c, DxCPQ__DocumentTemplate__c FROM DxCPQ__Translator__c];
        DxCPQ__Translator__c record = translatedRecords[0];     
        System.assertEquals('Hello, world!', record.Name, 'The Name should match the input string.');
        System.assertEquals('¡Hola, mundo!', record.DxCPQ__Translated_Value__c, 'The translated value should be as expected.');
        System.assertEquals(testLanguage, record.DxCPQ__Language__c, 'The language should match the input language.');
        System.assertEquals(testTemplateId, record.DxCPQ__DocumentTemplate__c, 'The template ID should match the input template ID.');
    }
    
    private class LanguageTranslatorClassMock implements HttpCalloutMock {
        private String mockResponse;
        
        public LanguageTranslatorClassMock(String response) {
            mockResponse = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
}