/**
 	* Class:              DexUtilTestDataFactory
    * Developer		:     Abhishek Goel
    * Created Date	:     30/1/2020
    * @description	:     This generic test is used to create the records for test classes
    * Last Modified Date: 30/1/2020
    * Change Log: 
    */
    @isTest
    public with sharing class DexUtilTestDataFactory {
    /**
     * @description An instance of the Safely class used for safe database operations.
     */
    public static Safely safe = new Safely();
     /**
     * @description Creates records with optional attributes and inserts them into the database.
     * 
     * @param records    List of SObject records to be created.
     * @param doInsert   Boolean flag indicating whether to insert the records into the database.
     * @param attributes Map of attributes to be applied to the records during creation.
     *                   Keys represent field names, and values can be single values or lists of values
     *                   corresponding to each record in the 'records' list.
     * @return           List of created SObject records.
     */
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

   /**
     * @description Creates a list of Account records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Account records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Account records.
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

    /**
     * @description Creates a list of Contact records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Contact records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Contact records.
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

   /**
     * @description Creates a list of Opportunity records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Opportunity records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Opportunity records.
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
        /**
         * @description Creates a list of Rule__c records with specified attributes and optionally inserts them into the database.
         * 
         * @param numToInsert  The number of Rule__c records to create.
         * @param doInsert     Boolean flag indicating whether to insert the records into the database.
         * @param attributes   Map of attributes to be applied to the records during creation.
         *                     Keys represent field names, and values can be single values or lists of values
         *                     corresponding to each record.
         * @return             List of created Rule__c records.
 		*/
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
        /**
         * @description Creates a list of Rule_Condition__c records with specified attributes and optionally inserts them into the database.
         * 
         * @param numToInsert  The number of Rule_Condition__c records to create.
         * @param doInsert     Boolean flag indicating whether to insert the records into the database.
         * @param attributes   Map of attributes to be applied to the records during creation.
         *                     Keys represent field names, and values can be single values or lists of values
         *                     corresponding to each record.
         * @return             List of created Rule_Condition__c records.
 		*/
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
     /**
     * @description Creates a list of TransactionLog__c records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of TransactionLog__c records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created TransactionLog__c records.
     */
    public static List<TransactionLog__c> createTransactionLog(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<TransactionLog__c> transactionLogToInsert = new List<TransactionLog__c>();
        for(Integer i=0; i< numToInsert; i++){
            TransactionLog__c trn = new TransactionLog__c();
            transactionLogToInsert.add(trn);
        }
        return createRecords(transactionLogToInsert, doInsert, attributes);
    }

  /**
     * @description Creates a list of Document_Template__c records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Document_Template__c records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Document_Template__c records.
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

    /**
     * @description Creates a list of Document__c records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Document__c records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Document__c records.
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

    /**
     * @description Creates a list of Document_Clause__c records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Document_Clause__c records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Document_Clause__c records.
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

   /**
     * @description Creates a list of Document_Template_Section__c records with specified attributes and optionally inserts them into the database.
     * 
     * @param numToInsert  The number of Document_Template_Section__c records to create.
     * @param doInsert     Boolean flag indicating whether to insert the records into the database.
     * @param attributes   Map of attributes to be applied to the records during creation.
     *                     Keys represent field names, and values can be single values or lists of values
     *                     corresponding to each record.
     * @return             List of created Document_Template_Section__c records.
     */
    Public static List<Document_Template_Section__c> createDocumentTemplateSection(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Document_Template_Section__c> docTemplateSectionToInsert = New List<Document_Template_Section__c>();
        for(Integer i=0; i< numToInsert; i++){
            Document_Template_Section__c docTemplateSection = new Document_Template_Section__c();
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
    /**
     * @description Creates a test User record with a unique username and assigns the System Administrator profile.
     * 
     * @return The created test User.
     */
    public static User createTestUser(){
        List<user> lstuser = new List<User>();
        String uniqueUserName = 'dxcpq' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [select id from profile where name LIKE '%System Administrator%'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = prof.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        lstuser.add(u);
        set<Id> userId = new set<Id>();
        List<user> retUser = createRecords(lstuser, true, new Map<String, Object>());
        userId.add(retUser[0].Id);
        assignPermissionSetToUsers(userId);
        return retUser[0];
    }
    /**
     * @description Assigns the specified Permission Set to the given set of Users.
     * 
     * @param usersId The set of User IDs to which the Permission Set will be assigned.
     */
    public static void assignPermissionSetToUsers (Set<Id> usersId) {
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
       Database.upsert(permissionSetList,false);
    }
	/**
     * @description Custom exception class to handle exceptions in the SafeClass.
     * Extends the standard Exception class.
     */
    public class SafeClassException extends Exception{
    }
}