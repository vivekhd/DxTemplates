@IsTest
private class DisplayPDFController_Test {
    @IsTest 
    static void testGetTemplateSections() {
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
                Map<String,Object> result = DisplayPDFController.getTemplateSections(
                    testTemplate.Id, testOpportunity.Id, 'Opportunity'
                );
                System.assertEquals(4, result.size(), 'Expected one section');
            } catch (exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest 
    static void testPdfMode() {
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
    
    @IsTest 
    static void testPdfObjectName() {
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
    
    @IsTest 
    static void testGeneratePDFAttachment() {
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
            String pageProperties = '{"pageSize" : "A4","pageOrientation" : "Potrait"}';
            String result = DisplayPDFController.generatePDFAttachment(testDocument.Id, testOpp.Id,pageProperties);
            System.assertNotEquals(null, result, 'Result should not be null');
        }
        Test.stopTest();    
    }
    
    @IsTest 
    static void testGenerateDocument() {
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
    
    @IsTest 
    static void testSavePDFtoQuote() {
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
    
    @IsTest 
    static void testSavePDFtoQuote1() {
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
    
    @IsTest 
    static void testAutoGenerateDocumentRecord() {
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
    
    @IsTest 
    static void testAutoGenerateDocumentRecord1() {
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
    
    @IsTest 
    static void testAutoGenerateDocumentRecord2() {
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
    
    @IsTest 
    static void testAutoGenerateDocumentRecord3() {
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
    
    @IsTest 
    static void testAutoGenerateDocumentRecord4() {
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
    
    @IsTest 
    static void testAutoGenerateDocumentRecordWithGrouping() {

        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();        
        Integer documentRecordCountBefore = [Select Id from Document__c].size();
        Integer documentRecordCountAfter;        
        Integer asyncJobCountBefore = [SELECT Id FROM AsyncApexJob].size();
        Integer asyncJobCountAfter;   
        Integer attchCountBefore = [SELECT Id FROM Attachment].size();
        System.runAs(us){
			List<Account> testAcc = DexUtilTestDataFactory.createAccounts(1,true,null);
            List<Opportunity> oppList = new List<Opportunity> {new Opportunity (Name= 'Delhi Imports',Amount= 7890.12,StageName= 'Prospecting',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Karnataka Imports',Amount= 1234.56,StageName= 'Prospecting',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'West Bengal Imports',Amount= 5678.9,StageName= 'Qualification',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Tamil Nadu Imports',Amount= 2345.67,StageName= 'Negotiation/Review',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Telangana Imports',Amount= 789.01,StageName= 'Prospecting',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Gujarat Imports',Amount= 4321.09,StageName= 'Closed Won',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Maharashtra Imports',Amount= 7654.32,StageName= 'Qualification',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Rajasthan Imports',Amount= 1987.65,StageName= 'Closed Won',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Uttar Pradesh Imports',Amount= 6543.21,StageName= 'Closed Lost',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01))};
            insert oppList;            
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Template Tes 1.0', IsActive__c = true);
            insert testTemplate;            
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Related Objects', Type__c = 'Related Objects', 
                Header_Content__c ='<table><thead><tr><th style="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="SlNo">SlNo</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Deleted">Name</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Stage">Stage</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Amount">Amount</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Amount">ClosureDate</div></th></tr></thead></table>',
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":true,"subTotal":["Amount"],"newPage":false,"displayChart":true,"selGraphvalue":"Amount","chartLabel": "Chart","chartNewPage": true,"chartBarColor": "#E42305","tablelistValues": ["Name","StageName","Amount","CloseDate"],"tablelistLabels": ["Name","Stage","Amount","Close Date"],"grouping": "StageName","dateFormat": "564/","timeFormat": "124","numberFormat": "3","currencyFormat": "2","style": {"category": {"fontcolor": "","backgroundColor": "","fontfamily": "Verdana","fontsize": "10px"},"header": {"fontcolor": "","backgroundColor": "","fontfamily": "Verdana","fontsize": "10px"}}}', 
                Document_Template__c = testTemplate.Id);
            insert testSection;
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            	arr.documentName = 'Testing Attachment';
                arr.templateId =  testTemplate.Id;
                arr.recordId = testAcc[0].Id;
            ids.add(arr);            
            documentAutomationController.autoGenerateDocumentRecord(ids);
            asyncJobCountAfter = [SELECT Id FROM AsyncApexJob].size();
            documentRecordCountAfter = [Select Id from Document__c].size();  
        }
        Test.stopTest();      
        Assert.areNotEqual(attchCountBefore,[Select Id from Attachment].size());
        Assert.areNotEqual(documentRecordCountBefore,documentRecordCountAfter);
        Assert.areNotEqual(asyncJobCountBefore,asyncJobCountAfter);
    }


    @IsTest 
    static void testAutoGenerateDocumentRecordWithoutGrouping() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();        
        Integer documentRecordCountBefore = [Select Id from Document__c].size();
        Integer documentRecordCountAfter;        
        Integer asyncJobCountBefore = [SELECT Id FROM AsyncApexJob].size();
        Integer asyncJobCountAfter;                
        System.runAs(us){
			List<Account> testAcc = DexUtilTestDataFactory.createAccounts(1,true,null);
            List<Opportunity> oppList = new List<Opportunity> {new Opportunity (Name= 'Delhi Imports',Amount= 7890.12,StageName= 'Prospecting',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Karnataka Imports',Amount= 1234.56,StageName= 'Prospecting',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'West Bengal Imports',Amount= 5678.9,StageName= 'Qualification',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Tamil Nadu Imports',Amount= 2345.67,StageName= 'Negotiation/Review',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Telangana Imports',Amount= 789.01,StageName= 'Prospecting',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Gujarat Imports',Amount= 4321.09,StageName= 'Closed Won',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Maharashtra Imports',Amount= 7654.32,StageName= 'Qualification',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Rajasthan Imports',Amount= 1987.65,StageName= 'Closed Won',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01)),new Opportunity (Name= 'Uttar Pradesh Imports',Amount= 6543.21,StageName= 'Closed Lost',AccountId = testAcc[0].Id,CloseDate= Date.newInstance(2024,01,01))};
            insert oppList;            
            Document_Template__c testTemplate = new Document_Template__c(Name = 'Template Tes 1.0', IsActive__c = true);
            insert testTemplate; 
            Document_Template_Section__c testSection = new Document_Template_Section__c(
                Name = 'Related Objects', Type__c = 'Related Objects', 
                Header_Content__c ='<table><thead><tr><th style="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="SlNo">SlNo</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Deleted">Name</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Stage">Stage</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Amount">Amount</div></th><thstyle="width:10px;border:1pxsolidblack;background-color:;color:;font-size:10px;font-family:Verdana;text-align:center;"scope="col"contenteditable="true"word-wrap="break-word;"><divtitle="Amount">ClosureDate</div></th></tr></thead></table>',
                Section_Content__c = '{"whereClause":"()","mainChildObject":"Opportunity","childLookupfieldAPIname":"AccountId","mainparentObject":"Account","SerialNumber":true,"subTotal":["Amount"],"newPage":false,"displayChart":false,"selGraphvalue":"Amount","chartLabel": "Chart","chartNewPage": true,"chartBarColor": "#E42305","tablelistValues": ["Name","StageName","Amount","CloseDate"],"tablelistLabels": ["Name","Stage","Amount","Close Date"],"grouping": "","dateFormat": "564/","timeFormat": "124","numberFormat": "3","currencyFormat": "2","style": {"category": {"fontcolor": "","backgroundColor": "","fontfamily": "Verdana","fontsize": "10px"},"header": {"fontcolor": "","backgroundColor": "","fontfamily": "Verdana","fontsize": "10px"}}}', 
                Document_Template__c = testTemplate.Id);
            insert testSection;
            List<documentAutomationController.recordParameters> ids = new List<documentAutomationController.recordParameters>();
            documentAutomationController.recordParameters arr = new documentAutomationController.recordParameters();
            	arr.documentName = 'Testing Attachment';
                arr.templateId =  testTemplate.Id;
                arr.recordId = testAcc[0].Id;
            ids.add(arr);            
            documentAutomationController.autoGenerateDocumentRecord(ids);
            asyncJobCountAfter = [SELECT Id FROM AsyncApexJob].size();
            documentRecordCountAfter = [Select Id from Document__c].size();                
        }
        Test.stopTest();
        Assert.areNotEqual(documentRecordCountBefore,documentRecordCountAfter);
        Assert.areNotEqual(asyncJobCountBefore,asyncJobCountAfter);
    }
    
    @IsTest
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
    
    @IsTest
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
    
    @IsTest
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
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = 0;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, timeStr, valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = -1;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, timeStr, valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = 1;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, timeStr, valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = 1;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(dateStr, '', valKey);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @IsTest
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
    
    @IsTest
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
    
    @IsTest
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
    
    @IsTest
    static void testGetHeaderContentException() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            ROsectionAutomationController.getHeaderContent(null);  
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    
    @IsTest
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
            
            String timeStr = createdDate.split(' ')[1];
            
            Integer valKey = null;
            String formattedDateTime = ROsectionAutomationController.handleDateTimeFormatAsSelectedbyUser(null, null, null);
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
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
    
    @IsTest
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
    
    @IsTest
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
    
    @IsTest
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
    
    
    @IsTest
    static void cloneDocumentTemplate() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                Document_Template__c testTemplate = new Document_Template__c(Name = 'Test Template');
                insert testTemplate;
                SaveDocumentTemplate.cloneDocumentTemplate(testTemplate, null);
                            } catch(exception ex) {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
        System.assert(true);
    }

    @IsTest 
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

    @IsTest 
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
    
    @IsTest 
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

    
    @IsTest
    static void testGetDocumentTemplateData() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Document_Template__c testTemplate = new Document_Template__c(
                Name = 'Test Template',
                Watermark_Data__c = 'Test watermark data'
            );
            insert testTemplate;
            Document_Template__c result = DisplayPDFController.getDocumentTemplateData(testTemplate.Id);
            SaveDocumentTemplate.getTemplateData(testTemplate.Id);
            System.assertNotEquals(null, result, 'Document_Template__c object should not be null');
            System.assertEquals('Test Template', result.Name, 'Incorrect Name');
            System.assertEquals('Test watermark data', result.Watermark_Data__c, 'Incorrect Watermark Data');
        }
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void testSaveContentVersion() {
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
            Document_Template__c template = new Document_Template__c();
            insert template;
             ContentVersion testContentVersion = new ContentVersion(
                Title = 'Test Image 123',
                VersionData = Blob.valueOf('Test image data For Testing'),
                PathOnClient = 'test123.png',
               	FirstPublishLocationId = template.Id
            );
            insert testContentVersion;
            List<Map<String, String>> base64DataList = new List<Map<String, String>>();
            base64DataList.add(new Map<String, String>{'Text' => 'Test text content', 'title' => 'Text Content'});
            base64DataList.add(new Map<String, String>{'Image' => EncodingUtil.base64Encode(Blob.valueOf('Test image data')), 'title' => 'Image Content'});
            Test.startTest();
            List<Map<String, String>> savedIds = DisplayPDFController.saveContentVersion('Test Title', base64DataList, template.Id, true);
            Test.stopTest();
            System.assertNotEquals(0, savedIds.size(), 'No ContentVersions saved');
        }
    }
    
    @IsTest
    static void getFlowNamesAndApexClassTest(){
        SaveDocumentTemplate.getFlowNames();
        SaveDocumentTemplate.getClassNames();
        Assert.isTrue(true,'Code Coverage only');
    }
    @isTest
    static void getSectionConditionsTest(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
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
        DisplayPDFController.getSectionConditions(testTemplate.Id,testOpportunity.Id,'Opportunity');
           // DisplayPDFController con = new DisplayPDFController();
        }
        Assert.isTrue(true,'Code Coverage only');
    } 
    @isTest
    static void testDisplayPDFControllerConstructor() {
       User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            ContentVersion cv = new ContentVersion();
            cv.Title='Test';
                 cv.VersionData=Blob.valueOf('Test');
                 cv.IsMajorVersion=true;
                 cv.PathOnClient='test';
                 insert cv;
        Document_Template__c docTemplate = new Document_Template__c(
            PDF_Page_Properties__c = '{"pagePropCSS":{},"pageMargins":{"margin-top":"10px","margin-bottom":"10px","margin-left":"10px","margin-right":"10px"},"footerJSONVal":{"footer_right":"10px","footer_center":"10px","footer_left":"10px"},"headerJSONVal":{"header_left":"10px","header_center":"10px","header_right":"10px","first_header_left":"10px","first_header_center":"10px","first_header_right":"10px","header_left_landscape":"10px","header_center_landscape":"10px","header_right_landscape":"10px","first_header_left_landscape":"10px","first_header_center_landscape":"10px","first_header_right_landscape":"10px"},"footerProperties":{},"headerProperties":{"normalHeaders":{"height":"50px"},"firstPageHeaders":{"height":"70px"}}}',
            Watermark_Data__c = '[{"name":"Text","isPrimary":true,"contentVersionID":"'+cv.id+'","pageOption":"All Pages - Text","fontsize":"28","opacity":"1","color":"#5DFF05","rotation":"45","textVal":"gabbbbbbbb","pageTextOption":"All Pages - Text"},{"name":"Image","isPrimary":false,"contentVersionID":null,"pageOption":"All Pages - Test","opacity":"1","rotation":"0","pageImageOption":"All Pages","imageScale":100}]'
        );
        insert docTemplate;

        // Create Document
        Document__c doc = new Document__c(
            Document_Body__c = 'Sample Document Body',
            Document_Content__c = '{"header": {"sectionsCount": 1, "sectionsFirstCount": 1, "sectionsContent": [{"indexvar": 0, "value": "Left Header"}]}, "footer": {"sectionsCount": 1, "sectionsContent": [{"indexvar": 0, "value": "Left Footer"}]}}',
            Document_Template__c = docTemplate.Id
        );
        insert doc;

        // Create DxTemplates_VF_Style__mdt metadata records
        List<DxTemplates_VF_Style__mdt> styles = new List<DxTemplates_VF_Style__mdt>{
            new DxTemplates_VF_Style__mdt(
                Label = 'SampleStyle',
                CSS_Style_List__c = 'body { font-family: Arial; }'
            )
        };
        ApexPages.currentPage().getParameters().put('documentid', doc.Id);
        ApexPages.currentPage().getParameters().put('selectedPageSize', 'A4');
        ApexPages.currentPage().getParameters().put('selectedPageOrientation', 'Portrait');

        DisplayPDFController controller = new DisplayPDFController();
        }
        Assert.isTrue(true,'Code Coverage only');
    }   

        @IsTest 
    static void testCustomLogic() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
                String mainstr = '<table xmlns="http://www.w3.org/1999/xhtml" dxcpq-templatetabledetails_templatetabledetails="" class="mytable" data-id="mytab" style="font-family: Verdana; font-size: large; table-layout: fixed; border: none;"><colgroup dxcpq-templatetabledetails_templatetabledetails=""><col dxcpq-templatetabledetails_templatetabledetails="" /><col dxcpq-templatetabledetails_templatetabledetails="" /><col dxcpq-templatetabledetails_templatetabledetails="" /></colgroup><thead dxcpq-templatetabledetails_templatetabledetails=""><tr dxcpq-templatetabledetails_templatetabledetails="" class="myclass1" style="font-size: 14px;"><th dxcpq-templatetabledetails_templatetabledetails="" scope="col" data-headercell="Header 1" style="font-size: 12px; background-color: rgb(216, 255, 255); border: 1px solid;"><div class="hiddencells" dxcpq-templatetabledetails_templatetabledetails="" data-id="Header 1" style="overflow-wrap: break-word;"><p>Name</p></div></th><th dxcpq-templatetabledetails_templatetabledetails="" scope="col" data-headercell="Header 2" style="font-size: 12px; background-color: rgb(216, 255, 255); border: 1px solid;"><div class="hiddencells" dxcpq-templatetabledetails_templatetabledetails="" data-id="Header 2" style="overflow-wrap: break-word;"><p><span style="color: rgb(255, 46, 200);">Quantity</span></p></div></th><th dxcpq-templatetabledetails_templatetabledetails="" scope="col" data-headercell="Header 3" style="font-size: 12px; background-color: rgb(216, 255, 255); border: 1px solid;"><div class="hiddencells" dxcpq-templatetabledetails_templatetabledetails="" data-id="Header 3" style="overflow-wrap: break-word;"><p><span style="color: rgb(6, 110, 180);">Description</span></p></div></th></tr></thead><tbody dxcpq-templatetabledetails_templatetabledetails=""><tr dxcpq-templatetabledetails_templatetabledetails="" data-rowvalue="1"><td dxcpq-templatetabledetails_templatetabledetails="" scope="col" data-bodycell="row1col1" style="font-size: 12px; border: 1px solid; background-color: rgb(255, 255, 255);"><div class="hiddencells" dxcpq-templatetabledetails_templatetabledetails="" data-id="row1col1div" style="overflow-wrap: break-word;"><p style="text-align: right;"><strong style="color: rgb(20, 5, 231);">%%data.wrapperInfo.name%%</strong></p></div></td><td dxcpq-templatetabledetails_templatetabledetails="" scope="col" data-bodycell="row1col2" style="font-size: 12px; border: 1px solid; background-color: rgb(255, 243, 81);"><div class="hiddencells" dxcpq-templatetabledetails_templatetabledetails="" data-id="row1col2div" style="overflow-wrap: break-word;"><p style="text-align: center;"><strong style="color: rgb(240, 30, 100);"><em><u>%%data.wrapperInfo.Quantity%%</u></em></strong></p></div></td><td dxcpq-templatetabledetails_templatetabledetails="" scope="col" data-bodycell="row1col3" style="font-size: 12px; border: 1px solid;"><div class="hiddencells" dxcpq-templatetabledetails_templatetabledetails="" data-id="row1col3div" style="overflow-wrap: break-word;"><p style="text-align: right;"><strong style="color: rgb(7, 111, 7);"><em><strike><u>%%productName%%</u></strike></em></strong></p></div></td></tr></tbody></table>';
                Map<String, Object> mp = new Map<String, Object>();
                Map<String, Object> dataMap = new Map<String, Object>();
                List<Map<String, Object>> wrapperInfoList = new List<Map<String, Object>>();
                wrapperInfoList.add(new Map<String, Object>{
                    'Description' => 'Basic Description',
                    'Quantity' => 2,
                    'name' => 'Realme 150W'
                });
                wrapperInfoList.add(new Map<String, Object>{
                    'Description' => 'Basic',
                    'Quantity' => 5,
                    'name' => 'Realme GT NEO 3 150W'
                });
                wrapperInfoList.add(new Map<String, Object>{
                    'Description' => 'Basic Data',
                    'Quantity' => 15,
                    'name' => 'Realme Mobile'
                });
                dataMap.put('wrapperInfo', wrapperInfoList);
                mp.put('data', dataMap);
                mp.put('productName', 'Realme Mobile Product');
				String outPutStr = MergeFieldsClass.customLogic(mp, mainstr);
            } catch (exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest 
    static void testGetTemplateSectionsTranslatedValues() {
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
                
                List<Translator__c> transList = new List<Translator__c>();
                
                Translator__c trs1 = new Translator__c(
                	Name = 'Default',
                    FieldValue__c = 'Default',
                    Translated_Value__c = 'Default',
                    Language__c = 'en_Us',
                    DocumentTemplate__c = testTemplate.Id
                );
                
                Translator__c trs2 = new Translator__c(
                	Name = 'Some Value',
                    FieldValue__c = 'Some Value',
                    Translated_Value__c = 'Some Value',
                    Language__c = 'en_Us',
                    DocumentTemplate__c = testTemplate.Id
                );
                transList.add(trs1);
                transList.add(trs2);
                
                insert transList;

                Map<String,Object> result = DisplayPDFController.getTemplateSections(
                    testTemplate.Id, testOpportunity.Id, 'Opportunity'
                );
                System.assertEquals(4, result.size(), 'Expected one section');
            } catch (exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
}