/* Class:              DexUtilTestDataFactory
    * Developer:          Abhishek Goel
    * Created Date:       30/1/2020
    * Description:        This generic test is used to create the records for test classes
    * Last Modified Date: 30/1/2020
    * Change Log: 
    */
    @isTest
    public with sharing class DexUtilTestDataFactory {
    /* Method:             createRecords
    * Parameters:         List<SObject> records : List of sobjects(Account, Contact etc..) which has to be created/inserted
    *                      Boolean doInsert: set true to if you want to instert the created record or else false
    *                      Map<String, Object> attributes: takes list of attributes for one or multiple records
    * Return:             List<SObject> : List of sobject which has been created/inserted
    * Created Date:       30/1/2020
    * Description:        This generic method is used to create the record of any Sobject type
    * Last Modified Date: 30/1/2020
    * Change Log: 
    */

    public static Safely safe = new Safely();
    public static List<SObject> createRecords(List<SObject> records, Boolean doInsert, Map<String, Object> attributes){
        try{
            Integer i = 0;
            if(attributes != null){
                for (Integer j =0; j < records.size(); j ++) {
                    SObject record = records[j];
                    for (String key : attributes.keySet()) {
                        Object value = attributes.get(key);
                        if (value instanceof List<Object>) {
                            Object obj = ((List<Object>) value).get(i);
                            if( obj instanceof SObject ){
                                Id sObjectId = ((SObject) obj).Id;
                                record.put( key,sObjectId );
                            }
                            else {
                                record.put(key,obj);
                            }
                        } else {
                            record.put(key, value);
                        }
                    }
                    i++;
                }
            } 
            if (doInsert) {
            Savepoint sp = Database.setSavepoint();
            Database.SaveResult[] srList1 = safe.doinsert(records);
            List<String> errorList = Safely.safeClassExceptionHandlerInsert(srList1);
            if(errorList.size()>0){
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
            }
        } catch(Exception e){
            system.debug('Exception while creating record: '+e.getMessage());
        }
        return records;
    }

    /* Method:             createAccounts
    * Parameters:         Integer numToInsert : Number of account records to be inserted
    *                      Boolean doInsert: set true to if you want to instert the created record or else false
    *                      Map<String, Object> attributes: takes list of attributes for one or multiple records
    * Return:             List<Account> : List of Accoutns which has been created/inserted
    * Created Date:       30/1/2020
    * Description:        This method is used to create or insert account record
    * Last Modified Date: 30/1/2020
    * Change Log: 
    */
    public static List<Account> createAccounts(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Account> accountsToInsert = new List<Account>();
        for(Integer i=0; i< numToInsert; i++){
            Account acc = new Account();
            acc.Name = 'TestAccount' + i;
            acc.website = 'www.test.com';
            accountsToInsert.add(acc);
        }
        return createRecords(accountsToInsert, doInsert, attributes);
    }

    /* Method:             createContacts
    * Parameters:         Integer numToInsert : Number of contact records to be inserted
    *                      Boolean doInsert: set true to if you want to instert the created record or else false
    *                      Map<String, Object> attributes: takes list of attributes for one or multiple records
    * Return:             List<Contact> : List of Contacts which has been created/inserted
    * Created Date:       30/1/2020
    * Description:        This method is used to create or insert contact record
    * Last Modified Date: 30/1/2020
    * Change Log: 
    */
    public static List<Contact> createContacts(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Contact> consToInsert = new List<Contact>();
        for(Integer i=0; i< numToInsert; i++){
            Contact con = new Contact();
            con.LastName = 'TestLastName' + i;
            con.FirstName = 'TestFirstName' + i;
            consToInsert.add(con);
        }
        return createRecords(consToInsert, doInsert, attributes);
    }

    /* Method:            createOpportunities
    * Parameters:         Integer numToInsert : Number of contact records to be inserted
    *                     Boolean doInsert: set true to if you want to instert the created record or else false
    *                     Map<String, Object> attributes: takes list of attributes for one or multiple records
    * Return:             List<Opportunity>
    * Created Date:       30/1/2020
    * Description:        This method is used to create or insert Opportunity record.
    * Last Modified Date: 30/1/2020
    * Change Log: 
    */
    public static List<Opportunity> createOpportunities(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Opportunity> consToInsert = new List<Opportunity>();
        List<String> stages = new List<String>{'Prospecting', 'Qualification', 'Needs Analysis', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost'};
        for(Integer i=0; i< numToInsert; i++){
            Opportunity con = new Opportunity();
            con.Name = 'Opportunity - ' + i;
            con.StageName = stages.get(Integer.valueOf(Math.Random()*stages.size()));
            con.Amount = ((Math.Random())+1)*1270;
            consToInsert.add(con);
        }
        return createRecords(consToInsert, doInsert, attributes);
    }

    public static list<Rule__c> createRule(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule__c> ruleToInsert = new List<Rule__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule__c rl = new Rule__c();
            rl.Name = 'R1' + i;
            rl.Rule_Expression__c = 'C1';
            ruleToInsert.add(rl);
        }
        return createRecords(ruleToInsert, doInsert, attributes);
    }

    public static list<Rule_Condition__c> createRuleCondition(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule_Condition__c> ruleConditionToInsert = new List<Rule_Condition__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule_Condition__c rc = new Rule_Condition__c();
            rc.Name = 'C1' + i;
            rc.Condition_Field__c= 'StageName';
            rc.Value__c = 'Value Proposition';
            rc.Evaluation_Object__c = 'Opportunity';
            ruleConditionToInsert.add(rc);
        }
        return createRecords(ruleConditionToInsert, doInsert, attributes);
    }

    public static List<TransactionLog__c> createTransactionLog(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<TransactionLog__c> TransactionLogToInsert = new List<TransactionLog__c>();
        for(Integer i=0; i< numToInsert; i++){
            TransactionLog__c trn = new TransactionLog__c();
            TransactionLogToInsert.add(trn);
        }
        return createRecords(TransactionLogToInsert, doInsert, attributes);
    }

    /* Method  : createDocumentTemplate
    * To Insert Document Template we are using this method
    */
    public static List<Document_Template__c> createDocumentTemplate(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Document_Template__c> docTemplatesToInsert = New List<Document_Template__c>();
        for(Integer i=0; i< numToInsert; i++){
            Document_Template__c docTemplate = new Document_Template__c();
            docTemplate.Parent_Template__c = 'Test'+i;
                docTemplate.IsActive__c = true;
                docTemplate.Previously_Active__c = true;
                docTemplate.Related_To_Type__c ='Opportunity';                
            docTemplatesToInsert.add(docTemplate);
        }
        return createRecords(docTemplatesToInsert, doInsert, attributes);
    }

    /* Method  : createDocument
        * To Insert Documents we are using this method
        */
    Public static List<Document__c> createDocument(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Document__c> docsToInsert = New List<Document__c>();
        for(Integer i=0; i< numToInsert; i++){
            Document__c doc = new Document__c();
            doc.Document_Content__c = 'Test Content'+i;
                doc.Document_Body__c = 'Test Document Body'+i;
                doc.Object_Id__c = 'test object Id';
            docsToInsert.add(doc);
        }
        return createRecords(docsToInsert, doInsert, attributes);
    }

    /* Method  : createDocumentClause
        * To Insert Document Clause we are using this method
        */

    Public static List<Document_Clause__c> createDocumentClause(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Document_Clause__c> docClauseToInsert = New List<Document_Clause__c>();
        for(Integer i=0; i< numToInsert; i++){
            Document_Clause__c docClause = new Document_Clause__c();
            docClause.Name = 'Test'+i;
            docClause.Status__c = 'Draft';
            docClause.Body__c = 'Test Body'+i;
            docClause.Category__c = 'Terms';
            docClause.IsActive__c = true;
            docClauseToInsert.add(docClause);
        }
        return createRecords(docClauseToInsert, doInsert, attributes);
    }

    /* Method  : createDocumentClause
        * To Insert Document Clause we are using this method
        */
    Public static List<Document_Template_Section__c> createDocumentTemplateSection(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Document_Template_Section__c> docTemplateSectionToInsert = New List<Document_Template_Section__c>();
        for(Integer i=0; i< numToInsert; i++){
            Document_Template_Section__c docTemplateSection = new Document_Template_Section__c();
            docTemplateSection.DisplaySectionName__c = true;
            docTemplateSection.IsActive__c = true;
            docTemplateSection.IsEditable__c = true;
            docTemplateSection.Section_Content__c = 'test section content';
            docTemplateSection.Section_Details__c = 'test section details';
            docTemplateSection.Sequence__c = 1;
            docTemplateSection.Type__c = 'Context';
            docTemplateSectionToInsert.add(docTemplateSection);
        }
        return createRecords(docTemplateSectionToInsert, doInsert, attributes);
    }

    public static User CreateTestUser(){
        List<user> lstuser = new List<User>();
        String uniqueUserName = 'dxcpq' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [select id from profile where name LIKE '%System Administrator%'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = prof.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        lstuser.add(u);
        set<Id> UserId = new set<Id>();
        List<user> retUser = createRecords(lstuser, true, new Map<String, Object>());
        UserId.add(retUser[0].Id);
        AssignPermissionSetToUsers(UserId);
        return retUser[0];
    }

    public static void AssignPermissionSetToUsers (Set<Id> usersId) {
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionstobeassigned = [SELECT Id, Label FROM PermissionSet WHERE Name IN ('Dx_Template_Access')];
        for (User u : [Select Id, Name FROM User Where Id IN : usersId]){
            for(PermissionSet ps : permissionstobeassigned){
                PermissionSetAssignment psa = new PermissionSetAssignment ();
                    psa.PermissionSetId = ps.Id; 
                    psa.AssigneeId = u.Id;
                permissionSetList.add(psa);
            }
        }
        List<Database.upsertResult> uResults = Database.upsert(permissionSetList,false);
    }

    public class SafeClassException extends Exception{
    }
}