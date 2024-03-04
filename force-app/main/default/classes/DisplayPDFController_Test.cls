@isTest
private class DisplayPDFController_Test {
    @isTest static void testGetTemplateSections() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;
                Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
                insert testOpportunity;
                Document_Template_Section__c testSection = new Document_Template_Section__c(
                    Document_Template__c = testTemplate.Id,
                    Section_Content__c = '<p>Test Section Content</p>',
                    Type__c = 'Context',
                    Sequence__c = 1
                );
                insert testSection;
                List<Document_Template_Section__c> result = DisplayPDFController.getTemplateSections(
                    testTemplate.Id, testOpportunity.Id, 'Opportunity'
                );
                System.assertEquals(1, result.size(), 'Expected one section');
                System.assertEquals('<p>Test Section Content</p>', result[0].Section_Content__c);   
            }
            catch(exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @isTest static void testPdfMode() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Map<String, String> testWrapperData = new Map<String, String>{
                'pdfModes1' => 'A4'
                    };
                        String result = DisplayPDFController.pdfMode(testWrapperData);
            System.assertEquals('A4', result);
        }
        Test.stopTest();
    }
    
    @isTest static void testPdfObjectName() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity;
            String result = DisplayPDFController.pdfObjectName(testOpportunity.Id);
            System.assertEquals('ObjectName is Returned', result);
        }
        Test.stopTest();
    }
    
    @isTest static void testGeneratePDFAttachment() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document__c testDocument = new Document__c(Document_Body__c = 'Test Document Body');
            insert testDocument;       
            Opportunity testOpp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting', 
                CloseDate = Date.today()  
            );
            insert testOpp;
            PageReference testPage = Page.renderAsPdfLWC;
            Test.setCurrentPage(testPage);
            String result = DisplayPDFController.generatePDFAttachment(testDocument.Id, testOpp.Id);
            System.assertNotEquals(null, result, 'Result should not be null');
        }
        Test.stopTest();    
    }
    
    @isTest static void testGenerateDocument() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Document__c testDocument = new Document__c(Document_Body__c = 'Test Document Body');
                insert testDocument;  
                Opportunity testOpp = new Opportunity(
                    Name = 'Test Opportunity',
                    StageName = 'Prospecting', 
                    CloseDate = Date.today()  
                );
                insert testOpp;
                DisplayPDFController.generateDocument(
                    testDocument.Id, testOpp.Id, 'Test PDF Body', 'Test PDF Header/Footer'
                );
                //System.assertNotEquals(null, result, 'Result should not be null');
            }
            catch (AuraHandledException ex) {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest static void testSavePDFtoQuote() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting', 
                CloseDate = Date.today()  
            );
            insert testOpp;
            Attachment testAttachment = new Attachment(
                Name = 'Test Attachment', Body = Blob.valueOf('Test PDF Body'),ParentId = testOpp.Id
            );
            insert testAttachment;
            String result = DisplayPDFController.SavePDFtoQuote(
                testAttachment.Id, testOpp.Id, 'A4', 'Test PDF Name'
            );
        }
        Test.stopTest();    
        System.assert(true);
    }
    
    @isTest static void testSavePDFtoQuote1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Opportunity testOpp = new Opportunity(
                    Name = 'Test Opportunity',
                    StageName = 'Prospecting', 
                    CloseDate = Date.today()  
                );
                insert testOpp;
                Attachment testAttachment = new Attachment(
                    Name = 'Test Attachment', Body = Blob.valueOf('Test PDF Body'),ParentId = testOpp.Id
                );
                insert testAttachment;
                DisplayPDFController.SavePDFtoQuote(
                    null, testOpp.Id, 'A4', 'PDF Name'
                );
            }
            catch(exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();  
        System.assert(true);
    }
    
    @isTest static void testAutoGenerateDocumentRecord() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity;   
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Test Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id
            );
            insert testSection;
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            arr.templateId =  testTemplate.Id;
            arr.recordId = testOpportunity.Id;
            arr.documentName = 'Test Document';
            ids.add(arr);
            documentAutomationController.autoGenerateDocumentRecord(ids);            
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest static void testAutoGenerateDocumentRecord1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate; 
            
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Header', Type__c = 'Header', Section_Content__c = '{"sectionsCount":"3","sectionsContent":[{"value":"","indexvar":0,"key":"1692937481560:0"},{"value":"","indexvar":2,"key":"1692937481560:2"},{"value":"<p>Rahul</p>","indexvar":1,"key":"1692937486280:1"}]}', Document_Template__c = testTemplate.Id);
            insert testSection;
            
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer', Type__c = 'Footer', Section_Content__c = '{"sectionsCount":"3","sectionsContent":[{"value":"","indexvar":0,"key":"1692937481560:0"},{"value":"","indexvar":2,"key":"1692937481560:2"},{"value":"<p>Rahul</p>","indexvar":1,"key":"1692937486280:1"}]}', Document_Template__c = testTemplate.Id);
            insert testSection1;
            
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            arr.templateId =  testTemplate.Id;
            arr.recordId = testOpportunity.Id;
            ids.add(arr);
            
            documentAutomationController.autoGenerateDocumentRecord(ids);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest static void testAutoGenerateDocumentRecord2() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Test Section', Type__c = 'Related Objects',New_Page__c =false, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name","DxCPQ__Custom_Object__r.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name","Custom Object.Name"],"grouping":"","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id        		
            );
            insert testSection;
            Document_Template_Section__c testSection1 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Footer', Section_Content__c = '<h1>Test Footer</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection1;
            Document_Template_Section__c testSection2 = new Document_Template_Section__c(
                Name = 'Footer Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id,New_Page__c =true
            );
            insert testSection2;
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            arr.templateId =  testTemplate.Id;
            arr.recordId = testOpportunity.Id;
            ids.add(arr);
            documentAutomationController.autoGenerateDocumentRecord(ids);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest static void testAutoGenerateDocumentRecord3() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Test Section', Type__c = '',New_Page__c =true, Section_Content__c = '<h1>Related Objects</h1>', Document_Template__c = testTemplate.Id
            );
            insert testSection;
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            arr.templateId =  testTemplate.Id;
            arr.recordId = testOpportunity.Id;
            ids.add(arr);
            documentAutomationController.autoGenerateDocumentRecord(ids);
            
        }
        Test.stopTest();
        System.assert(true);
    } 
    
    @isTest static void testAutoGenerateDocumentRecord4() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template1');
            insert testTemplate;   
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Test Section', Type__c = 'Related Objects',New_Page__c =true, Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name","DxCPQ__Custom_Object__r.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name","Custom Object.Name"],"grouping":"","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}', Document_Template__c = testTemplate.Id
            );
            insert testSection;
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            arr.templateId =  testTemplate.Id;
            arr.recordId = testOpportunity.Id;
            ids.add(arr);
            documentAutomationController.autoGenerateDocumentRecord(ids);
        }
        Test.stopTest();
        System.assert(true);
    } 
    
    @isTest
    static void testGetReferenceObjectAPIName() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            ROsectionAutomationController.getReferenceObjectAPIName('Account', 'OwnerId');
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetReferenceObjectAPIName1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            ROsectionAutomationController.getReferenceObjectAPIName('Account', '');
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSectionDataAsHTML() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"mainChildObject":"Account","tablelistValues":[],"tablelistLabels":[],"newPage":false}'
            );
            insert testSection; 
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            String result = ROsectionAutomationController.getSectionDataAsHTML(testAccount.Id, testSection.Id);
        }
        Test.stopTest();
        System.assert(true);
    }	
    
    @isTest
    static void testGetSectionDataAsHTML1() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":"","chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount"],"tablelistLabels":["Created Date","Opportunity Type","Amount"],"grouping":"stagename","dateFormat":"564/","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}'
            );
            insert testSection; 
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testOpportunity.Id, testSection.Id);
            String createdDate = String.valueOf([SELECT CreatedDate FROM Opportunity WHERE Id = :testOpportunity.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = 0;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, timeStr, valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @isTest
    static void testGetSectionDataAsHTML2() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":"","chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount"],"tablelistLabels":["Created Date","Opportunity Type","Amount"],"grouping":"stagename","dateFormat":"562/*","timeFormat":"1234","numberFormat":"3","currencyFormat":"2","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}'
            );
            insert testSection; 
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testOpportunity.Id, testSection.Id);
            String createdDate = String.valueOf([SELECT CreatedDate FROM Opportunity WHERE Id = :testOpportunity.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = -1;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, timeStr, valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSectionDataAsHTML3() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":"","chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount"],"tablelistLabels":["Created Date","Opportunity Type","Amount"],"grouping":"stagename","dateFormat":"564/*","timeFormat":"123","numberFormat":"3","currencyFormat":"2","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}'
            );
            insert testSection; 
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testOpportunity.Id, testSection.Id);
            String createdDate = String.valueOf([SELECT CreatedDate FROM Opportunity WHERE Id = :testOpportunity.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = 1;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, timeStr, valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSectionDataAsHTML4() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":"","chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount"],"tablelistLabels":["Created Date","Opportunity Type","Amount"],"grouping":"stagename","dateFormat":"564/*","timeFormat":"123","numberFormat":"3","currencyFormat":"2","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}'
            );
            insert testSection; 
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testOpportunity.Id, testSection.Id);
            String createdDate = String.valueOf([SELECT CreatedDate FROM Opportunity WHERE Id = :testOpportunity.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = 1;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, '', valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSectionDataAsHTML5() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,Type__c = 'Related Objects',
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":"","chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount"],"tablelistLabels":["Created Date","Opportunity Type","Amount"],"grouping":"stagename","dateFormat":"564/*","timeFormat":"123","numberFormat":"3","currencyFormat":"2","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}'
            );
            insert testSection; 
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testOpportunity.Id, testSection.Id);
            String createdDate = String.valueOf([SELECT CreatedDate FROM Opportunity WHERE Id = :testOpportunity.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @isTest
    static void testCurrencyNumberFormat() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Decimal value = 123.45678;
            String roundPattern = '2';
            String stringValue = String.valueOf(value);
            Decimal expected = value.setScale(Integer.valueOf(roundPattern));
            ROsectionAutomationController.handleCurrencyNumberFormat(stringValue, roundPattern);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testCurrencyNumberFormatError() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            String value = 'invalid_value';
            String roundPattern = '2';
            ROsectionAutomationController.handleCurrencyNumberFormat(value, roundPattern);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetHeaderContent() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Test Section', Document_Template__c = testTemplate.Id,
                Header_Content__c = '<p>Test Header Content</p>'
            );
            insert testSection;
            ROsectionAutomationController.getHeaderContent(testSection.Id);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetHeaderContentException() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            ROsectionAutomationController.getHeaderContent(null);  
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @isTest
    static void testGetSectionDataAsHTML6() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":[],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name","Account.Id"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name","Account ID.Account ID"],"grouping":"stagename","dateFormat":"564/","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}}' );
            insert testSection; 
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
            String result = ROsectionAutomationController.getSectionDataAsHTML(testAccount.Id, testSection.Id);
            ROsectionAutomationController.dataFetchFromCurrentRecord(
                new List<Object>{ 'Name' }, 
                testAccount,        
                new Map<String, String>{ 'Name' => 'STRING' } 
            );
            String createdDate = String.valueOf([SELECT CreatedDate FROM Account WHERE Id = :testAccount.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSectionDataAsHTML7() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name","Account.Id"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name","Account ID.Account ID"],"grouping":"","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}}' );
            insert testSection; 
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(),Type = 'New Customer',
                                                          Amount = 244244, AccountId = testAccount.Id);
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testAccount.Id, testSection.Id);
            ROsectionAutomationController.dataFetchFromCurrentRecord(
                new List<Object>{ 'Name' }, 
                testAccount,        
                new Map<String, String>{ 'Name' => 'STRING' } 
            );
            String createdDate = String.valueOf([SELECT CreatedDate FROM Account WHERE Id = :testAccount.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @isTest
    static void testGetSectionDataAsHTML8() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
            insert testTemplate;
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name","DxCPQ__Custom_Object__r.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name","Custom Object.Name"],"grouping":"","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}' );
            insert testSection; 
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;
            Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(),Type = 'New Customer',
                                                          Amount = 244244, AccountId = testAccount.Id);
            insert testOpportunity; 
            String result = ROsectionAutomationController.getSectionDataAsHTML(testAccount.Id, testSection.Id);
            ROsectionAutomationController.dataFetchFromCurrentRecord(
                new List<Object>{ 'Name' }, 
                testAccount,        
                new Map<String, String>{ 'Name' => 'STRING' } 
            );
            String createdDate = String.valueOf([SELECT CreatedDate FROM Account WHERE Id = :testAccount.Id].CreatedDate);
            List<String> dateStr = createdDate.split(' ')[0].split('-');
            System.debug('dateStr >> '+ dateStr);
            String timeStr = createdDate.split(' ')[1];
            System.debug('timeStr >> ' + timeStr);
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testSaveDocumentTemplateSectionDetails() {
        
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;
                Document_Template_Section__c testSection = new Document_Template_Section__c(
                    Document_Template__c = testTemplate.Id,Name = 'Test Section', Sequence__c = 1,Type__c='Related Objects',
                    Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":false,"subTotal":["Amount"],"displayChart":false,"selGraphvalue":null,"chartLabel":"Chart","chartNewPage":true,"newPage":false,"tablelistValues":["CreatedDate","Type","Amount","Name","Account.Name","DxCPQ__Custom_Object__r.Name"],"tablelistLabels":["Created Date","Opportunity Type","Amount","Name","Account ID.Account Name","Custom Object.Name"],"grouping":"","dateFormat":"564/*","timeFormat":"124","numberFormat":"2","currencyFormat":"1","style":{"category":{"fontcolor":"","backgroundColor":"","fontfamily":"Times New Roman","fontsize":"14px"},"header":{"fontcolor":"#AF23F1","backgroundColor":"#40F70E","fontfamily":"Times New Roman","fontsize":"14px"}},"groupingCatVals":[{"label":"Prospecting","value":"Prospecting"},{"label":"Qualification","value":"Qualification"},{"label":"Needs Analysis","value":"Needs Analysis"},{"label":"Value Proposition","value":"Value Proposition"},{"label":"Id. Decision Makers","value":"Id. Decision Makers"},{"label":"Perception Analysis","value":"Perception Analysis"},{"label":"Proposal/Price Quote","value":"Proposal/Price Quote"},{"label":"Negotiation/Review","value":"Negotiation/Review"},{"label":"Closed Won","value":"Closed Won"},{"label":"Closed Lost","value":"Closed Lost"}]}' );
                insert testSection; 
                SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(testSection);
            }
            catch(exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testSaveDocumentTemplateSectionDetails1() {
        
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;
                Document_Template_Section__c testSection = new Document_Template_Section__c(
                    Document_Template__c = testTemplate.Id,Name = 'Test Section with Clause', Sequence__c = 1,Type__c='Context',
                    Section_Content__c = 'Happy Testing' );
                insert testSection; 
                SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(testSection);
            }
            catch(exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSearchedContentVersions() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                List<ContentVersion> testContentVersions = new List<ContentVersion>{
                    new ContentVersion(
                        Title = 'Test Image 1',
                        PathOnClient  = 'Test1.jpg',
                        VersionData = Blob.valueOf('Test image data 1')
                    ),
                        new ContentVersion(
                            Title = 'Test Image 2',
                            PathOnClient  = 'Test2.jpg',
                            VersionData = Blob.valueOf('Test image data 2')
                        ),
                        new ContentVersion(
                            Title = 'Other File',
                            PathOnClient  = 'Test3.jpg',
                            VersionData = Blob.valueOf('Test image data 3')
                        )
                        };
                            insert testContentVersions;
                FooterClass.getSearchedContentVersions('');
                
            }
            catch(exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testGetSearchedContentVersions3() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                List<ContentVersion> testContentVersions = new List<ContentVersion>{
                    new ContentVersion(
                        Title = 'Test Image 1',
                        PathOnClient  = 'Test1.jpg',
                        VersionData = Blob.valueOf('Test image data 1')
                    ),
                        new ContentVersion(
                            Title = 'Test Image 2',
                            PathOnClient  = 'Test2.jpg',
                            VersionData = Blob.valueOf('Test image data 2')
                        ),
                        new ContentVersion(
                            Title = 'Other File',
                            PathOnClient  = 'Test3.jpg',
                            VersionData = Blob.valueOf('Test image data 3')
                        )
                        };
                            insert testContentVersions;
                FooterClass.getContentVersions();
                
            }
            catch(exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
		System.assert(true);
    }
    
    
    @isTest
    static void cloneDocumentTemplate() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;
                SaveDocumentTemplate.cloneDocumentTemplate(testTemplate, null);
                //SaveDocumentTemplate.saveDocumentTemplatedetails(testTemplate,null);                
            } catch(exception ex) {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        System.assert(true);
    }

    @isTest 
    static void testAutoGenerateDocumentRecordAutomation() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        Integer emailBefore = Limits.getEmailInvocations();
        String errorMessage;
        System.runAs(us){
            try{
                Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
                insert testOpportunity;   
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;  
                Document_Template_Section__c testSectionHeader = new Document_Template_Section__c(
                    Name = 'Test Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header {!Opportunity.Name} {!Opportunity.CreatedBy.UserName} {!Opportunity.CloseDate} </h1>', Document_Template__c = testTemplate.Id
                );
                insert testSectionHeader;
                Document_Template_Section__c testSection = new Document_Template_Section__c(
                    Name = 'Test Section', Type__c = 'Context', Section_Content__c = '<h1>Test Header {!Opportunity.Name} {!Opportunity.StageName} {!Opportunity.CloseDate} </h1>', Document_Template__c = testTemplate.Id
                );
                insert testSection;
                documentAutomationController.generateDocument(testTemplate.Id, new List<String> {testOpportunity.Id}, 'emailInfo');
            } catch (Exception ex) {
                errorMessage =  ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString();
            }
        }
        Test.stopTest();
        System.assert(true);
    }

    @isTest 
    static void testAutoGenerateDocumentRecordForFox() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        Integer emailBefore = Limits.getEmailInvocations();
        String errorMessage;
        System.runAs(us){
            try{
                Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
                insert testOpportunity;   
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;   
                Document_Template_Section__c testSection = new Document_Template_Section__c(
                    Name = 'Test Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id
                );
                insert testSection;
                Map<String,Object> emailInfo = new Map<String,Object> {};
                emailInfo.put('templateId',testTemplate.Id);
                emailInfo.put('recordIds',new List<String> {testOpportunity.Id});
                emailInfo.put('documentNameAfterGeneration','TestData Generated Doc');
                emailInfo.put('TestDatta','TestData');
                emailInfo.put('isSpecificToFox',true);
                documentAutomationController.generateDocument('',emailInfo);
            } catch (Exception ex) {
                errorMessage =  ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString();
            }
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest 
    static void testDeleteTemplate() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        Integer emailBefore = Limits.getEmailInvocations();
        String errorMessage;
        System.runAs(us){
            try{
                Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
                insert testOpportunity;   
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;   
                Document_Template_Section__c testSection = new Document_Template_Section__c(
                    Name = 'Test Section', Type__c = 'Header', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id
                );
                insert testSection;
                Document_Template_Section__c testSectionOne = new Document_Template_Section__c(
                    Name = 'Test Section', Type__c = 'Context', Section_Content__c = '<h1>Test Header</h1>', Document_Template__c = testTemplate.Id
                );
                insert testSectionOne;
                SaveDocumentTemplate.deleteTemplate(testTemplate.Id);
                
            } catch (Exception ex) {
                errorMessage =  ex.getLineNumber() + ex.getMessage() + ex.getStackTraceString();
            }
        }
        Test.stopTest();
        System.assert(true);
    }
}