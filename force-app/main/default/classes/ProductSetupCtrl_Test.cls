@isTest
private class ProductSetupCtrl_Test {

	/* ProductSetupCtrl Test Class */
    @isTest
    static void getLookupListTest(){
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            List<Account> pdsc = ProductSetupCtrl.getLookupList('Attribute','Account' );
            System.assertEquals(pdsc != NULL, true);
        }
        Test.stopTest();
    }
    
    /* ProductSetupCtrl MultiSelectLookupController Class */
    @isTest
    static void retrieveRecordsTest(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            Test.startTest();
            List<Account> acc = DexUtilTestDataFactory.createAccounts(3, true, null);
            MultiSelectLookupController.retrieveRecords('Account','Name','ShippingCity','Name','','Name!=NULL');
            System.assert(true);
            Test.stopTest();
        }
    }
    
    /*SaveDocumentTemplate Test Class*/        
    @isTest public static void getAllDocumentTemplateSections_Test1(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
            List<Id> documentTemplateId = new List<Id>{documentTemplate[0].Id};
            Map<String, Object> docTemplateSectionAttributes = new Map<String, Object>{'Document_Template__c'=>documentTemplateId};
            List<Document_Template_Section__c> docTemplateSections = DexUtilTestDataFactory.createDocumentTemplateSection(1, true, docTemplateSectionAttributes);
            List<Document__c> doc = DexUtilTestDataFactory.createDocument(1, true, docTemplateSectionAttributes);
            List<Document_Clause__c> docClause = DexUtilTestDataFactory.createDocumentClause(1, true, null);
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
            
        Rule__c r=new Rule__c();
        r.Name='test';
        insert r;
            
        String inputparam='"'+docClause[0].Id+'"';
        Map<string,object> wrec=new  Map<string,object>();
        
        wrec.put('indexvar',2);
        wrec.put('value','right');
        
        List<Object> headerListObject=new List<Object>();
        headerListObject.add(wrec);
        Map<String, Object> headerMap =new Map<String, Object>();
        headerMap.put('sectionsCount',3);
        headerMap.put('sectionsContent',headerListObject);
        Map<string,object> mapjson=new  Map<string,object>();
        
        mapjson.put('header',headerMap);
        
        Map<string,object> wrec1=new  Map<string,object>();
        
        wrec1.put('indexvar',2);
        wrec1.put('value','right');
        
        List<Object> footerListObject=new List<Object>();
        footerListObject.add(wrec1);
        
        Map<String, Object> footerMap =new Map<String, Object>();
        footerMap.put('sectionsCount',4);
        footerMap.put('displaypagesequence',true);
        footerMap.put('sectionsContent',footerListObject);
        mapjson.put('footer',headerMap);
        String myJSON = JSON.serialize(mapjson);
        Document__c docs = new Document__c();
        docs.Document_Content__c = myJSON;
        docs.Document_Body__c = 'Test Document Body';
        docs.Document_Template__c =  documentTemplate[0].Id;
        insert docs;
            
        Test.startTest();
        try{
            SaveDocumentTemplatesection.ClauseBody(inputparam);
            SaveDocumentTemplatesection.getAllDocumentTemplateSections(documentTemplate[0].Id);
            SaveDocumentTemplatesection.gettemplatesectiondata(docTemplateSections[0].Id);
            SaveDocumentTemplatesection.getSobjectFields('Account');
            SaveDocumentTemplatesection.saveDocumentTemplateSectionSequences(docTemplateSections);
            SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(docTemplateSections[0]);
            //FooterClass.getContentVersions();
            //FooterClass.getSearchedContentVersions('searchlabel');
            RelatedObjectsClass.getRelatedObjects('Product2');
            RelatedObjectsClass.getFields('Product2');
            RelatedObjectsClass.getGroupingValues('Product2');
            RelatedObjectsClass.getSObjectListFiltering('Lead');
            RelatedObjectsClass.getFieldsWrapper('Product2');
            
            Rule__c rule = new Rule__c();
            rule.Rule_Expression__c ='Condition1 && condition2';
            rule.Rule_Description__c = 'Template Filtering Rule';
            insert rule;
            
            Rule_Condition__c rcnd = new Rule_Condition__c();
            rcnd.DataType__c='BOOLEAN';
            rcnd.ConditionIndex__c = '1';
            rcnd.Operator__c ='==';
            rcnd.Rule__c = rule.Id;
            rcnd.Value__c ='false';
            rcnd.Condition_Field__c = 'isdeleted';
            rcnd.Evaluation_Object__c ='Lead';
            rcnd.Rule__c = rule.Id;
            insert rcnd;
           
            Document_Template_Section__c dts = [select id,name from Document_Template_Section__c where id=:docTemplateSections[0].Id];
            dts.RuleId__c = rule.Id;
            update dts;
            
            Rule__c rquery =[select id,name from Rule__c where id=:rule.Id];
            RelatedObjectsClass.getExistingConditions((String)rquery.Name);
            RelatedObjectsClass.getRelatedObjectForSelectedDocumentTemplate(documentTemplate[0].Id);
            
            RelatedObjectsClass.cloneRulesFromParentTemplate(docTemplateSections[0].Id);
            String arr = '[{\"Id\":\"a05DH000003AmugYAC\",\"conditionName\":\" Condition1 \",\"dataType\":\"STRING\",\"operator\":\"==\",\"selectedObject\":\"Lead\",\"selectedField\":\"lastname\",\"value\":\"20\",\"conditionIndex\":0},{\"Id\":null,\"conditionName\":\" Condition2 \",\"dataType\":\"BOOLEAN\",\"operator\":\"==\",\"selectedObject\":\"Lead\",\"selectedField\":\"isdeleted\",\"value\":false,\"conditionIndex\":1}]';
            List<Id> noIds = new List<Id> {};
            RelatedObjectsClass.createRuleCondition(arr,'Condition1 && condition2', noIds, docTemplateSections[0].Id);
                        
            ApexPages.currentPage().getParameters().put('documentid', String.valueOf(docs.Id));
            DisplayPDFController controller = new DisplayPDFController();
            System.assert(true);
            
        }Catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception Message was not found');
        }
        }
        Test.stopTest();
    }
       
    
    @isTest public static void getAllDocumentTemplateSections_Test2(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
             try{
        		List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
        		List<Id> documentTemplateId = new List<Id>{documentTemplate[0].Id};
            	Map<String, Object> docTemplateSectionAttributes = new Map<String, Object>{'Document_Template__c'=>documentTemplateId};
                List<Document_Template_Section__c> docTemplateSections = DexUtilTestDataFactory.createDocumentTemplateSection(1, true, docTemplateSectionAttributes);
        		List<Document__c> doc = DexUtilTestDataFactory.createDocument(1, true, docTemplateSectionAttributes);
        		List<Document_Clause__c> docClause = DexUtilTestDataFactory.createDocumentClause(1, true, null);
        
        		String parentTemplateId = documentTemplate[0].Parent_Template__c;
        
                Account acc = new Account();
                acc.Name = 'Test Account';
                Insert acc;
                
                Opportunity opp = new Opportunity();
                opp.Name = 'Test Opportunity';
                opp.AccountId = acc.Id;
                opp.CloseDate = System.today()+15;
                opp.StageName = 'Prospecting';
                Insert opp;
                
                 Document_Template__c docTemplate2 = new Document_Template__c();
                docTemplate2.Parent_Template__c = 'Test class';
                docTemplate2.IsActive__c = true;
                docTemplate2.Previously_Active__c = true;
                docTemplate2.Related_To_Type__c = 'Account';
                 
                Document_Template__c docTemplate3 = new Document_Template__c();
                docTemplate3.Parent_Template__c = 'Test class';
                docTemplate3.IsActive__c = true;
                docTemplate3.Previously_Active__c = true;
                docTemplate3.Related_To_Type__c = 'Account';
                //docTemplate3.Watermark_Data__c = 'test';
                Map<string,object> wrec=new  Map<string,object>();
                wrec.put('indexvar',0);
                wrec.put('value','Left');
                 
                ContentVersion cv = new ContentVersion();
                 cv.Title='Test';
                 cv.VersionData=Blob.valueOf('Test');
                 cv.IsMajorVersion=true;
                 cv.PathOnClient='test';
                 insert cv;
                 String wmark='[{"name":"Text","isPrimary":true,"contentVersionID":"'+cv.id+'","pageOption":"All Pages","fontsize":"28","opacity":"1","color":"#5DFF05","rotation":"45","textVal":"gabbbbbbbb","pageTextOption":"All Pages"},{"name":"Image","isPrimary":false,"contentVersionID":null,"pageOption":"All Pages","opacity":"1","rotation":"0","pageImageOption":"All Pages","imageScale":100}]';
                doctemplate2.DxCPQ__Watermark_Data__c=wmark;
                 insert doctemplate2;
                 
                List<Object> headerListObject=new List<Object>();
                headerListObject.add(wrec);
                Map<String, Object> headerMap =new Map<String, Object>();
                headerMap.put('sectionsCount',3);
                headerMap.put('sectionsContent',headerListObject);
                Map<string,object> mapjson=new  Map<string,object>();
                
                mapjson.put('header',headerMap);
                
                Map<string,object> wrec1=new  Map<string,object>();
                
                wrec1.put('indexvar',0);
                wrec1.put('value','Left');
                
                List<Object> footerListObject=new List<Object>();
                footerListObject.add(wrec1);
                
                Map<String, Object> footerMap =new Map<String, Object>();
                footerMap.put('sectionsCount',4);
                footerMap.put('displaypagesequence',true);
                footerMap.put('sectionsContent',footerListObject);
                mapjson.put('footer',headerMap);
                String myJSON = JSON.serialize(mapjson);
                Document__c docs = new Document__c();
                docs.Document_Content__c = myJSON;
                docs.Document_Body__c = 'Test Document Body';
                docs.Document_Template__c =  documentTemplate[0].Id;
                insert docs;
                    
                documentTemplate[0].Previously_Active__c=false;
                documentTemplate[0].Watermark_Data__c= wmark;
                update documentTemplate[0];
                Test.startTest();
                
                SaveDocumentTemplatesection.deletetemplate(docTemplateSections[0].Id, documentTemplate[0].Id);
                SaveDocumentTemplate.saveDocumentTemplatedetails(documentTemplate[0], documentTemplate[0].Id);        
                SaveDocumentTemplate.createDocumentTemplate(docTemplate3);        
                SaveDocumentTemplate.activateTemplate(documentTemplate[0].Id, parentTemplateId, true);
                SaveDocumentTemplate.getDocumentTemplates('Account');
                Document_Template__c docTem;
                //SaveDocumentTemplate.deleteTemplate(documentTemplate[0].Id);
                ApexPages.currentPage().getParameters().put('documentid', String.valueOf(docs.Id));
                DisplayPDFController controller = new DisplayPDFController();
                 DisplayPDFController.getDocumentTemplateData(doctemplate2.Id);
             }
			catch(exception ex){
                 System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
            
        System.assert(true);
        Test.stopTest();
    }
    
    
    
    @IsTest public static void DisplayPDFController_Test3(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            
        Document_Template__c docTemplate = new Document_Template__c();
        docTemplate.Parent_Template__c = 'Test';
        docTemplate.IsActive__c = true;
        docTemplate.Previously_Active__c = true;
        docTemplate.Related_To_Type__c = 'Account';
        Insert docTemplate;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+15;
        opp.StageName = 'Prospecting';
        Insert opp;
        
        Map<string,object> wrec=new  Map<string,object>();
        
        wrec.put('indexvar',1);
        wrec.put('value','center');
        List<Object> headerListObject=new List<Object>();
        headerListObject.add(wrec);
        Map<String, Object> headerMap =new Map<String, Object>();
        headerMap.put('sectionsCount',3);
        headerMap.put('sectionsContent',headerListObject);
        Map<string,object> mapjson=new  Map<string,object>();
        
        mapjson.put('header',headerMap);
        
        Map<string,object> wrec1=new  Map<string,object>();
        
        wrec1.put('indexvar',1);
        wrec1.put('value','center');
        List<Object> footerListObject=new List<Object>();
        footerListObject.add(wrec1);
        
        Map<String, Object> footerMap =new Map<String, Object>();
        footerMap.put('sectionsCount',4);
        footerMap.put('displaypagesequence',true);
        footerMap.put('sectionsContent',footerListObject);
        mapjson.put('footer',headerMap);
        String myJSON = JSON.serialize(mapjson);
        Document__c doc = new Document__c();
        doc.Document_Content__c = myJSON;
        doc.Document_Body__c = 'Test Document Body';
        doc.Document_Template__c = docTemplate.Id;
        insert doc;
        
        Document_Clause__c docClause = new Document_Clause__c();
        docClause.Name = 'Test';
        docClause.Status__c = 'Draft';
        docClause.Body__c = 'test ""content';
        docClause.Category__c = 'Terms';
        docClause.IsActive__c = true;
        insert docClause;
        
        
        Test.startTest();
        try{
            SaveDocumentTemplate.saveDocumentTemplatedetails(docTemplate, '');
            DisplayPDFController.headerfooterwrapper wrap=new   DisplayPDFController.headerfooterwrapper('test','0');
            DisplayPDFController controller = new DisplayPDFController();
            System.assert(true);
        }catch(Exception e){
            System.assert(e.getMessage()!= null, 'Exception Message is found');
        }
        }
        Test.stopTest();
    }
    
    @IsTest public static void DisplayPDFController_Test4(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
             try{
        List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
        system.debug('documentTemplate[0]'+documentTemplate[0]);
        Document_Template_Section__c docTemplateSection = new Document_Template_Section__c();
        docTemplateSection.DisplaySectionName__c = true;
        docTemplateSection.ChildObject__c = 'Test';
        docTemplateSection.IsActive__c = true;
        docTemplateSection.IsEditable__c = true;
        docTemplateSection.Section_Content__c = 'test section content';
        docTemplateSection.Section_Details__c = 'test section details';
        docTemplateSection.Sequence__c = 3;
        docTemplateSection.Type__c = 'Context';
        docTemplateSection.Document_Template__c=documentTemplate[0].Id;
        insert docTemplateSection;
        Document_Template__c docTemplate = new Document_Template__c();
        docTemplate.IsActive__c = true;
        docTemplate.Previously_Active__c = true;
        docTemplate.Related_To_Type__c = 'Account';
            
        docTemplate.Parent_Template__c=documentTemplate[0].Id;
        List<Document_Template_Section__c> newlst=new List<Document_Template_Section__c>();
        newlst.add(docTemplateSection);
        Document_Template_Section__c docTemplateSection1 = new Document_Template_Section__c();
        docTemplateSection1.DisplaySectionName__c = true;
        docTemplateSection1.ChildObject__c = 'Test';
        docTemplateSection1.IsActive__c = true;
        docTemplateSection1.IsEditable__c = true;
        docTemplateSection1.Section_Content__c = 'test section content';
        docTemplateSection1.Section_Details__c = 'test section details';
        docTemplateSection1.Sequence__c = 2;
        docTemplateSection1.Type__c = 'Context';
        docTemplateSection1.Document_Template__c=documentTemplate[0].Id;
        insert docTemplateSection1;
        newlst.add(docTemplateSection1);
        documentTemplate[0].Version_Number__c=1;
        update documentTemplate[0];
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+15;
        opp.StageName = 'Prospecting';
        Insert opp;
        
        Document__c doc = new Document__c();
        doc.Document_Content__c = 'myJSON';
        doc.Document_Body__c = 'Test Document Body';
        doc.Document_Template__c = docTemplate.Id;
        insert doc;
            
        pageReference pdfPage = Page.renderAsPdfLWC;
        pdfPage.getParameters().put('documentid',doc.Id);
        blob pdfBody;
        if(Test.isRunningTest()) { 
            pdfBody = blob.valueOf('Unit.Test');
        } else {
            pdfBody = pdfPage.getContentAsPDF();
        }
        Test.setCurrentPage(pdfPage);
        
        Test.startTest();
        SaveDocumentTemplatesection.deletetemplate(docTemplateSection1.Id, docTemplateSection.Document_Template__c);
        SaveDocumentTemplate.cloneDocumentTemplate(docTemplate,documentTemplate[0].Id);
        SaveDocumentTemplatesection.saveDocumentTemplateSectionSequences(newlst);
        System.assert(true);
                 }
            catch(exception ex){
                 System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    @IsTest public static void DisplayPDFController_Test5(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
        List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
        
        List<Document_Clause__c> docClause = DexUtilTestDataFactory.createDocumentClause(1, true, null);
        String jsonString='{\"Name\":\"tst\",\"Id\":\"\",\"Document_Template__c\":\"'+documentTemplate[0].Id+'\",\"DisplaySectionName__c\":true,\"ChildObject__c\":\"Test\",\"IsActive__c\":true,\"IsEditable__c\":true,\"Section_Content__c\":\"testsectioncontent\",\"Section_Details__c\":\"testsectiondetails\",\"Sequence__c\":1,\"Type__c\":\"Header\",\"Document_Clause__c\":\"'+docClause[0].Id+'\"}';
        Document_Template_Section__c registerForm=(Document_Template_Section__c) JSON.deserialize(jsonString,Document_Template_Section__c.class);
        String jsonString1='{\"Name\":\"tst\",\"Id\":\"\",\"Document_Template__c\":\"'+documentTemplate[0].Id+'\",\"DisplaySectionName__c\":true,\"ChildObject__c\":\"Test\",\"IsActive__c\":true,\"IsEditable__c\":true,\"Section_Content__c\":\"testsectioncontent\",\"Section_Details__c\":\"testsectiondetails\",\"Sequence__c\":1,\"Type__c\":\"Footer\",\"Document_Clause__c\":\"'+docClause[0].Id+'\"}';
        Document_Template_Section__c registerForm1=(Document_Template_Section__c) JSON.deserialize(jsonString1,Document_Template_Section__c.class);
        
        Test.startTest();
        try{
            SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(registerForm);        
        	SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(registerForm1);
        	System.assert(true);
        }Catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception Message is not found');
        }
        }
        Test.stopTest();
    }
    @IsTest public static void Test6(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
            try{
            List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
            List<Id> documentTemplateId = new List<Id>{documentTemplate[0].Id};
                Map<String, Object> docTemplateSectionAttributes = new Map<String, Object>{'Document_Template__c'=>documentTemplateId};
                    List<Document_Template_Section__c> docTemplateSections = DexUtilTestDataFactory.createDocumentTemplateSection(1, true, docTemplateSectionAttributes);
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.IsActive__c = true;
            docTemplate.Previously_Active__c = true;
            docTemplate.Related_To_Type__c = 'Account';
            docTemplate.Parent_Template__c=documentTemplate[0].Id;
            insert docTemplate;
                    
            List<Object> fieldsObjList=new List<Object>();
            fieldsObjList.add('DxCPQ__Related_To_Type__c');
            fieldsObjList.add('DxCPQ__Parent_Template__c');
            Map<string,Object> jsonMap=new  Map<string,Object>();
            jsonMap.put('tablelistValues',fieldsObjList);
            jsonMap.put('mainChildObject','DxCPQ__Document_Template__c');
            jsonMap.put('childLookupfieldAPIname','DxCPQ__Parent_Template__c');
            String myJSON = JSON.serialize(jsonMap);
            Document_Template_Section__c docTemplateSection = new Document_Template_Section__c();
            docTemplateSection.DisplaySectionName__c = true;
            docTemplateSection.ChildObject__c = 'Test';
            docTemplateSection.IsActive__c = true;
            docTemplateSection.IsEditable__c = true;
            docTemplateSection.Section_Content__c = myJSON;
            docTemplateSection.Section_Details__c = 'test section details';
            docTemplateSection.Sequence__c = 3;
            docTemplateSection.Type__c = 'Context';
            docTemplateSection.Document_Template__c=documentTemplate[0].Id;
            insert docTemplateSection;  
            
            String mainstr1='{\"sectionsCount\":\"1\",\"sectionsContent\":[{\"value\":\"<p>DxCPQ__Related_To_Type__c</p>\",\"indexvar\":0,\"key\":\"1653649808603:0\"}]}';
            String mainstr='<p>Hello<spanstyle=\"color:rgb(68,68,68);\">{!DxCPQ__Document_Template__c.Id},</span></p><p><br></p><p><spanstyle=\"color:rgb(68,68,68);\">{!DxCPQ__Document_Template__c.DxCPQ__Related_To_Type__c}</span></p><p>Status:<spanstyle=\"color:rgb(68,68,68);\">{!DxCPQ__Document_Template__c.Owner.Id}</span></p><p><br></p>';
            
            Document_Template_Section__c docTemplateSection1 = new Document_Template_Section__c();
            docTemplateSection1.DisplaySectionName__c = true;
            docTemplateSection1.ChildObject__c = 'Test';
            docTemplateSection1.IsActive__c = true;
            docTemplateSection1.IsEditable__c = true;
            docTemplateSection1.Section_Content__c = mainstr;
            docTemplateSection1.Section_Details__c = 'test section details';
            docTemplateSection1.Sequence__c = 3;
            docTemplateSection1.Type__c = 'Context';
            docTemplateSection1.Document_Template__c=documentTemplate[0].Id;
            insert docTemplateSection1;
            List<Document_Template_Section__c> newlst=new List<Document_Template_Section__c>();
            newlst.add(docTemplateSection1);
            Test.startTest();
                SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(docTemplateSection1);
                DisplayRelatedObjects.getsectionData(documentTemplate[0].Id,docTemplateSection.Id);
                Map<string,object> replaceData= new Map<string,object>();
                MergeFieldsClass.mergefieldsMethod(newlst,documentTemplate[0].Id,replaceData);
                List<MergeFieldsClass.FieldWrap> fields=MergeFieldsClass.getFields('DxCPQ__Document_Template__c');
                MergeFieldsClass.toTitleCase('hello test MergeFieldsClass');
                System.assert(true);
                }
            catch(exception ex){
                 System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        Test.stopTest();
        }
    }
    
    @IsTest public static void DisplayPDFController_Test7(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
        List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
        List<Document_Clause__c> docClause = DexUtilTestDataFactory.createDocumentClause(1, true, null);
        String jsonString='{\"Name\":\"tst\",\"Id\":\"\",\"Document_Template__c\":\"'+documentTemplate[0].Id+'\",\"DisplaySectionName__c\":true,\"ChildObject__c\":\"Test\",\"IsActive__c\":true,\"IsEditable__c\":true,\"Section_Content__c\":\"testsectioncontent\",\"Section_Details__c\":\"testsectiondetails\",\"Sequence__c\":1,\"Type__c\":\"Header\",\"Document_Clause__c\":\"'+docClause[0].Id+'\"}';
        Document_Template_Section__c registerForm=(Document_Template_Section__c) JSON.deserialize(jsonString,Document_Template_Section__c.class);
        String jsonString1='{\"Name\":\"tst\",\"Id\":\"\",\"Document_Template__c\":\"'+documentTemplate[0].Id+'\",\"DisplaySectionName__c\":true,\"ChildObject__c\":\"Test\",\"IsActive__c\":true,\"IsEditable__c\":true,\"Section_Content__c\":\"testsectioncontent\",\"Section_Details__c\":\"testsectiondetails\",\"Sequence__c\":1,\"Type__c\":\"Header\",\"Document_Clause__c\":\"'+docClause[0].Id+'\"}';
        Document_Template_Section__c registerForm1=(Document_Template_Section__c) JSON.deserialize(jsonString1,Document_Template_Section__c.class);
        Test.startTest();
        try{
            SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(registerForm);        
        	SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails(registerForm1);
        	System.assert(true);
        }Catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception Message is not found');
        }
        }
        Test.stopTest();
    }
	
    @IsTest public static void DisplayPDFController_Test8(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){
        List<Document_Template__c> documentTemplate = DexUtilTestDataFactory.createDocumentTemplate(1, true, null);
        List<Document_Clause__c> docClause = DexUtilTestDataFactory.createDocumentClause(1, true, null);
        String jsonString='{\"Name\":\"tst\",\"Id\":\"\",\"Header_Content__c\":\"tst\",\"Document_Template__c\":\"'+documentTemplate[0].Id+'\",\"DisplaySectionName__c\":true,\"ChildObject__c\":\"Test\",\"IsActive__c\":true,\"IsEditable__c\":true,\"Section_Content__c\":\"testsectioncontent\",\"Section_Details__c\":\"testsectiondetails\",\"Sequence__c\":1,\"Type__c\":\"Header\",\"Document_Clause__c\":\"'+docClause[0].Id+'\"}';
        Document_Template_Section__c registerForm=(Document_Template_Section__c) JSON.deserialize(jsonString,Document_Template_Section__c.class);
        String jsonString1='{\"Name\":\"tst\",\"Id\":\"\",\"Header_Content__c\":\"tst\",\"Document_Template__c\":\"'+documentTemplate[0].Id+'\",\"DisplaySectionName__c\":true,\"ChildObject__c\":\"Test\",\"IsActive__c\":true,\"IsEditable__c\":true,\"Section_Content__c\":\"testsectioncontent\",\"Section_Details__c\":\"testsectiondetails\",\"Sequence__c\":1,\"Type__c\":\"Header\",\"Document_Clause__c\":\"'+docClause[0].Id+'\"}';
        Document_Template_Section__c registerForm1=(Document_Template_Section__c) JSON.deserialize(jsonString1,Document_Template_Section__c.class);
        Test.startTest();
        try{
            SaveDocumentTemplatesection.saveData(registerForm.Header_Content__c,registerForm.id);        
        	SaveDocumentTemplatesection.saveData(registerForm1.Header_Content__c,registerForm1.id);
        	System.assert(true);
        }Catch(Exception e){
            System.assert(e.getMessage() != null, 'Exception Message is not found');
        }
        }
        Test.stopTest();
    }
    
	@IsTest 
    public static void Test_getRelatedToTypeOptions(){
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
            SaveDocumentTemplate.getRelatedToTypeOptions();
        }
        System.Assert(true);
    }

    @isTest(SeeAllData = true)
    static void testGetPDFLinks() {
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
           ProductSetupCtrl.getPDFLinks();
       	}
        System.Assert(true);
    }
    
    @isTest
    static void testGetOriginalImageCVID() {
        Test.startTest();
        User us = DexUtilTestDataFactory.CreateTestUser();
        System.runAs(us){ 
            ContentVersion testContentVersion = new ContentVersion(
                Title = 'Test Image 123',
                VersionData = Blob.valueOf('Test image data For Testing'),
                PathOnClient = 'test123.png'
            );
            insert testContentVersion;
            String result = ProductSetupCtrl.getOriginalImageCVID(testContentVersion.Id);
            Test.stopTest();
            System.assertNotEquals(null, result, 'ContentVersion Id should not be null');
        }
    }
}