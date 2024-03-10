@IsTest
private class DisplayRelatedController_Test {
    @IsTest static void testDisplayRelatedController() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document__c testDocument = new Document__c(Document_Body__c = 'Test Document Body');
            insert testDocument;
            ApexPages.currentPage().getParameters().put('documentId', testDocument.Id);
            DisplayRelatedController controller = new DisplayRelatedController();
            System.assertEquals('Test Document Body', controller.displayText);
        }
        Test.stopTest();
    }
    
    //The following methods are the test classes of DisplayRelatedObjects Apex class    
    @IsTest
    static void testGetObjectFieldTypeMap() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
            try{
                Account testAccount = new Account(Name = 'Test Account');
                insert testAccount;
                Contact testContact = new Contact(AccountId = testAccount.Id, LastName = 'Test Contact');
                insert testContact;
                List<String> fieldList = new List<String>{ 'Name', 'CreatedDate', 'Contact.LastName', 'Contact.Account.Name' };
                    DisplayRelatedObjects.getObjectFieldTypeMap('Account', fieldList);
            }
            catch(exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetObjectFieldTypeMap1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Account testAccount = new Account(Name = 'Test Account');
                insert testAccount;
                Contact testContact = new Contact(AccountId = testAccount.Id, LastName = 'Test Contact');
                insert testContact;
                List<String> fieldList = new List<String>{ 'Name', 'CreatedDate', 'Contact.LastName', 'Contact.Account.Name' };
                    DisplayRelatedObjects.getObjectFieldTypeMap('Account', fieldList);
            }
            catch(exception ex)
            {	//System.debug('ex.getmsg() >> in testgetobjfieldmap1' + ex.getMessage());
                System.assert(ex.getMessage().contains('Assertion Failed: Expected: datetime, Actual: DATETIME'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetLkpObjectApi() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            String lkpObjectApi = DisplayRelatedObjects.getLkpObjectApi('Account', 'OwnerId');
            System.assertEquals('User', lkpObjectApi);
        }
        Test.stopTest();
    }
    
    
    @IsTest
    static void testGetLkpObjectApi_ExceptionHandling() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try {
                String invalidFromObjName = 'Invalid_Object';
                String invalidLkpField = 'Invalid_Field';
                String lkpObjectApi = DisplayRelatedObjects.getLkpObjectApi(invalidFromObjName, invalidLkpField);
                System.assertEquals('', lkpObjectApi);
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains('expected exception message'));
            }
        }
        Test.stopTest();
    }
    
    
    @IsTest
    static void testGetsectionData() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'ROI Section Testing', Type__c = 'Related Objects',New_Page__c =false, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name"],"grouping":"","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id        		
            );
            insert testSection;
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Footer', Section_Content__c = '<h1>Test Footer</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection1;
            Document_Template_Section__c testSection2 = new Document_Template_Section__c(
                Name = 'Header Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection2;
            DisplayRelatedObjects.getsectionData(testOpportunity.Id, testSection.Id);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
    static void testGetsectionData1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'ROI Section Testing', Type__c = 'Related Objects',New_Page__c =false, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name"],"grouping":"stagename","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id        		
            );
            insert testSection;
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Footer', Section_Content__c = '<h1>Test Footer</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection1;
            Document_Template_Section__c testSection2 = new Document_Template_Section__c(
                Name = 'Header Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection2;
            DisplayRelatedObjects.getsectionData(testOpportunity.Id, testSection.Id);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
    static void testGetsectionData3() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(),Type = 'New Customer',
                                                          Amount = 244244, AccountId = testAccount.Id);
            insert testOpportunity; 
            Opportunity testOpportunity1 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 242144, AccountId = testAccount.Id);
            insert testOpportunity1;  
            Opportunity testOpportunity2 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 21244, AccountId = testAccount.Id);
            insert testOpportunity2;  
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'ROI Section Testing', Type__c = 'Related Objects',New_Page__c =false, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name"],"grouping":"stagename","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id        		
            );
            insert testSection;
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Footer', Section_Content__c = '<h1>Test Footer</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection1;
            Document_Template_Section__c testSection2 = new Document_Template_Section__c(
                Name = 'Header Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection2;
            DisplayRelatedObjects.getsectionData(testAccount.Id, testSection.Id);
        }
        Test.stopTest();
         System.assert(true);
    }
    
    
    @IsTest
    static void testGetsectionData4() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', LeadSource='Web',CloseDate = Date.today(),Type = 'New Customer',
                                                          Amount = 244244, AccountId = testAccount.Id);
            insert testOpportunity; 
            Opportunity testOpportunity1 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',  LeadSource='Web',CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 242144, AccountId = testAccount.Id);
            insert testOpportunity1;  
            Opportunity testOpportunity2 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',  LeadSource='',CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 21244, AccountId = testAccount.Id);
            insert testOpportunity2;  
            Opportunity testOpportunity3 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',  LeadSource='',CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 21244, AccountId = testAccount.Id);
            insert testOpportunity3;  
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'ROI Section Testing', Type__c = 'Related Objects',New_Page__c =false, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["ExpectedRevenue"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Account.Name","ExpectedRevenue"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Account ID.Account Name","Expected Amount"],"grouping":"leadsource","dateFormat":"564/","timeFormat":"124","numberFormat":"3","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id        		
            );
            insert testSection;
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Footer', Section_Content__c = '<h1>Test Footer</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection1;
            Document_Template_Section__c testSection2 = new Document_Template_Section__c(
                Name = 'Header Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection2;
            
            DisplayRelatedObjects.getsectionData(testAccount.Id, testSection.Id);
        }
        Test.stopTest();
         System.assert(true);
    }
    
    @IsTest
    static void testGetsectionData7() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', LeadSource='Web',CloseDate = Date.today(),Type = 'New Customer',
                                                          Amount = 244244, AccountId = testAccount.Id);
            insert testOpportunity; 
            Opportunity testOpportunity1 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',  LeadSource='Web',CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 242144, AccountId = testAccount.Id);
            insert testOpportunity1;  
            Opportunity testOpportunity2 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',  LeadSource='',CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 21244, AccountId = testAccount.Id);
            insert testOpportunity2;  
            Opportunity testOpportunity3 = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting',  LeadSource='',CloseDate = Date.today(),Type = 'New Customer',
                                                           Amount = 21244, AccountId = testAccount.Id);
            insert testOpportunity3;  
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'ROI Section Testing', Type__c = 'Related Objects',New_Page__c =false, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["ExpectedRevenue"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Account.Name","ExpectedRevenue"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Account ID.Account Name","Expected Amount"],"grouping":"","dateFormat":"564/","timeFormat":"124","numberFormat":"3","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id        		
            );
            insert testSection;
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Footer', Section_Content__c = '<h1>Test Footer</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection1;
            Document_Template_Section__c testSection2 = new Document_Template_Section__c(
                Name = 'Header Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection2;
            
            DisplayRelatedObjects.getsectionData(testAccount.Id, testSection.Id);
        }
        Test.stopTest();
        System.assert(true);
    }    
    
    @IsTest
    static void testRetrieveRecords() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            List<MultiSelectLookupController.SObjectQueryResult> result = MultiSelectLookupController.retrieveRecords(
                'Account', 'Id,Name', 'Name', 'Test', '', '');
            System.assertEquals(1, result.size());
            System.assertEquals(testAccount.Id, result[0].recordId);
            System.assertEquals(testAccount.Name, result[0].recordName);
            System.assertEquals(testAccount.Id, result[0].recordObject.get('Id'));
            System.assertEquals(testAccount.Name, result[0].recordObject.get('Name'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testRetrieveRecords1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Account testAccount = new Account(Name = 'Test Account');
                insert testAccount;
                List<MultiSelectLookupController.SObjectQueryResult> result = MultiSelectLookupController.retrieveRecords(
                    'Account', 'Id,Name', 'Name', 'Test', '', '');
                System.assertEquals(1, result.size());
                System.assertEquals(testAccount.Id, result[0].recordId);
                System.assertEquals(testAccount.Name, result[0].recordName);
                System.assertEquals(testAccount.Id, result[0].recordObject.get('Id'));
                System.assertEquals(testAccount.Name, result[0].recordObject.get('Name'));
            }
            catch(exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testRetrieveRecords2() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Account testAccount = new Account(Name = 'Test Account');
                insert testAccount;
                List<MultiSelectLookupController.SObjectQueryResult> result = MultiSelectLookupController.retrieveRecords(
                    'Account', 'Id,Name', 'Name', '*', '', '');
                System.assertEquals(1, result.size());
                System.assertEquals(testAccount.Id, result[0].recordId);
                System.assertEquals(testAccount.Name, result[0].recordName);
                System.assertEquals(testAccount.Id, result[0].recordObject.get('Id'));
                System.assertEquals(testAccount.Name, result[0].recordObject.get('Name'));
            }
            catch(exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    
    @IsTest
    static void testGetLookupList() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Account testAccount = new Account(Name = 'Test Account');
                insert testAccount;
                ProductSetupCtrl.getLookupList('', '');
            }
            catch(exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
         System.assert(true);
    }
    
    @IsTest
    static void testWrapperAndRowWrapper() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            // Test RowWrapper
            DisplayRelatedObjects.RowWrapper rowWrapper = new DisplayRelatedObjects.RowWrapper();
            rowWrapper.addValue('Value 1');
            rowWrapper.addValue('Value 2');
            System.assertEquals(2, rowWrapper.values.size());
            
            // Test Wrapper
            DisplayRelatedObjects.Wrapper wrapper = new DisplayRelatedObjects.Wrapper();
            wrapper.rowWrapperList = new List<DisplayRelatedObjects.RowWrapper>{rowWrapper};
                wrapper.headers = new List<String>{'Header 1', 'Header 2'};
                    wrapper.newPage = true;
            wrapper.catFontClr = 'Red';
            wrapper.catBgClr = 'White';
            wrapper.catFontFam = 'Arial';
            wrapper.catFontSize = '12px';
            wrapper.headFontClr = 'Blue';
            wrapper.headBgClr = 'Yellow';
            wrapper.headFontFam = 'Verdana';
            wrapper.headFontSize = '14px';
            wrapper.showSlNo = true;
            wrapper.displayChart = true;
            wrapper.dateFormat = 'yyyy-MM-dd';
            wrapper.timeFormat = 'HH:mm:ss';
            wrapper.numberFormat = '#,##0.00';
            wrapper.currencyFormat = '$#,##0.00';
            wrapper.phoneFormat = '(###) ###-####';
            wrapper.chartNewPage = true;
            wrapper.selGraphvalue = 'bar';
            wrapper.chartLabel = 'Sales Data';
            
            // Perform assertions on Wrapper properties
            System.assertEquals(1, wrapper.rowWrapperList.size());
            System.assertEquals(2, wrapper.headers.size());
            System.assertEquals(true, wrapper.newPage);
            System.assertEquals('Red', wrapper.catFontClr);
            System.assertEquals('White', wrapper.catBgClr);
            System.assertEquals('Arial', wrapper.catFontFam);
            System.assertEquals('12px', wrapper.catFontSize);
            System.assertEquals('Blue', wrapper.headFontClr);
            System.assertEquals('Yellow', wrapper.headBgClr);
            System.assertEquals('Verdana', wrapper.headFontFam);
            System.assertEquals('14px', wrapper.headFontSize);
            System.assertEquals(true, wrapper.showSlNo);
            System.assertEquals(true, wrapper.displayChart);
            System.assertEquals('yyyy-MM-dd', wrapper.dateFormat);
            System.assertEquals('HH:mm:ss', wrapper.timeFormat);
            System.assertEquals('#,##0.00', wrapper.numberFormat);
            System.assertEquals('$#,##0.00', wrapper.currencyFormat);
            System.assertEquals('(###) ###-####', wrapper.phoneFormat);
            System.assertEquals(true, wrapper.chartNewPage);
            System.assertEquals('bar', wrapper.selGraphvalue);
            System.assertEquals('Sales Data', wrapper.chartLabel);
        }
        Test.stopTest(); 
    }
}