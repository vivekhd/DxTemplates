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
    
    public static list<Rule__c> createRule(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule__c> ruleToInsert = new List<Rule__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule__c rl = new Rule__c();
            rl.Name = 'R1' + i;
            rl.Rule_Type__c = 'Qualification';
            rl.Rule_Expression__c = 'C1';
            rl.Evaluation_Object__c = 'Opportunity';
            ruleToInsert.add(rl);
        }
        return createRecords(ruleToInsert, doInsert, attributes);
    }
    /*public static list<Rule__c> createRuleAttribute(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule__c> ruleToInsert = new List<Rule__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule__c rl = new Rule__c();
            rl.Name = 'RAttribute' + i;
            rl.Rule_Type__c = 'Attribute';
            rl.Rule_Expression__c = 'condition1 ';
            rl.Evaluation_Object__c = 'Configured_Attribute__c';
            ruleToInsert.add(rl);
        }
        return createRecords(ruleToInsert, doInsert, attributes);
    }
    public static list<Rule__c> createRuleQuote(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule__c> ruleToInsert = new List<Rule__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule__c rl = new Rule__c();
            rl.Name = 'R1' + i;
            rl.Rule_Type__c = 'Qualification';
            rl.Rule_Expression__c = 'Condition1';
            rl.Evaluation_Object__c = 'DxCPQ__Quote__c';
            ruleToInsert.add(rl);
        }
        return createRecords(ruleToInsert, doInsert, attributes);
    }*/
    
    public static list<Rule_Condition__c> createRuleCondition(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule_Condition__c> ruleConditionToInsert = new List<Rule_Condition__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule_Condition__c rc = new Rule_Condition__c();
            rc.Name = 'C1' + i;
            rc.Condition_Field__c= 'StageName';
            rc.Value__c = 'Value Proposition';
            ruleConditionToInsert.add(rc);
        }
        return createRecords(ruleConditionToInsert, doInsert, attributes);
    }
    
    /*public static list<Product2> createProduct(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Product2> product2ToInsert = new List<Product2>();
        for(Integer i=0; i< numToInsert; i++){
            Product2 P1 = new product2();
            P1.Name ='test product' + i;
            P1.isActive = true;
            product2ToInsert.add(P1);
        }
        return createRecords(product2ToInsert, doInsert, attributes);
    }
    
    public static list<Rule_Product__c> createRuleProduct(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule_Product__c> ruleProductToInsert = new List<Rule_Product__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule_Product__c rp1 = new Rule_Product__c();
            ruleProductToInsert.add(rp1);
            
        }
        return createRecords(ruleProductToInsert, doInsert, attributes);
    }
    
    public static list<Rule_Action__c> createRuleAction(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Rule_Action__c> ruleActionToInsert = new List<Rule_Action__c>();
        for(Integer i=0; i< numToInsert; i++){
            Rule_Action__c ra1 = new Rule_Action__c();
            ra1.Action_Type__c='Hide';
            ra1.Scope__c='Auto';
            ra1.Message__c='test';
            ra1.Message_Type__c='Info';
            ruleActionToInsert.add(ra1);
        }
        return createRecords(ruleActionToInsert, doInsert, attributes);
    }
    
    public static List<Attribute__c> createAttribute(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Attribute__c> attributeToInsert = new List<Attribute__c>();
        for(Integer i=0; i< numToInsert; i++){
            Attribute__c a1 = new Attribute__c();
            a1.Name='Value Proposition';
            a1.Name__c ='Existing Business';
            a1.Value__c='test opp'+i;
            a1.DataType__c = 'picklist';
            a1.Active__c=true;
            attributeToInsert.add(a1);
        }
        return createRecords(attributeToInsert, doInsert, attributes);
    }
    public static List<Attributes_Group__c> createAttributeGroup(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Attributes_Group__c> attributeGroupInsert = new List<Attributes_Group__c>();
        for(Integer i=0; i< numToInsert; i++){
            Attributes_Group__c attGroup = new Attributes_Group__c();
            attGroup.Name = 'Test '+i;
            attributeGroupInsert.add(attGroup);
        }
        return createRecords(attributeGroupInsert, doInsert, attributes); 
    }
    
    public static List<Configured_Attribute__c> createConfiguredAttribute(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Configured_Attribute__c> attributeConfiguredInsert = new List<Configured_Attribute__c>();
        for(Integer i=0; i< numToInsert; i++){
            Configured_Attribute__c conAtt = new Configured_Attribute__c();
            conAtt.Name = 'TestCofigAtt ' + i; 
            conAtt.Value__c = 'TestVal ' + i;
            conAtt.isReadOnly__c=false;
            attributeConfiguredInsert.add(conAtt);
        }
        return createRecords(attributeConfiguredInsert, doInsert, attributes);
        
    }
    public static List<Group__c> createGroup(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Group__c> groupInsert = new List<Group__c>();
        for(Integer i=0; i< numToInsert; i++){
            Group__c gop = new Group__c();
            gop.Name='Dairy Group'+i;
            groupInsert.add(gop);
        }
        return createRecords(groupInsert, doInsert, attributes); 
    }
       
    public static List<Object_Rule__c> createObjectRule(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Object_Rule__c> objectRuleInsert = new List<Object_Rule__c>();
        for(Integer i=0; i< numToInsert; i++){
            Object_Rule__c objRule = new Object_Rule__c();
            objectRuleInsert.add(objRule);
        }
        return createRecords(objectRuleInsert, doInsert, attributes); 
    }
    
    public static List<Product_Attribute__c> createProductAttribute(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Product_Attribute__c> productAttributeInsert = new List<Product_Attribute__c>();
        for(Integer i=0; i< numToInsert; i++){
            Product_Attribute__c prodAtt = new Product_Attribute__c();
            prodAtt.Configurable__c=false;
            prodAtt.Hidden__c=false;
            prodAtt.isRequired__c=false;
            productAttributeInsert.add(prodAtt);
        }
        return createRecords(productAttributeInsert, doInsert, attributes); 
    }
    
    public static List<Product_Category__c> createProductCategory(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Product_Category__c> productCategoryInsert = new List<Product_Category__c>();
        for(Integer i=0; i< numToInsert; i++){
            Product_Category__c prodCat = new Product_Category__c();
            productCategoryInsert.add(prodCat);
        }
        return createRecords(productCategoryInsert, doInsert, attributes); 
    }
    
    public static List<Product_Relationship__c> createProductRelationship(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Product_Relationship__c> productRealationshipInsert = new List<Product_Relationship__c>();
        for(Integer i=0; i< numToInsert; i++){
            Product_Relationship__c prodRel = new Product_Relationship__c();
            prodRel.Bundled__c=false;
            prodRel.Included__c=false;
            prodRel.IsBundled__c=false;
            prodRel.IsDefaultSelected__c=false;
            prodRel.Quantity_Editable__c=false;
            prodRel.RelType__c='Recommendation';
            productRealationshipInsert.add(prodRel);
        }
        return createRecords(productRealationshipInsert, doInsert, attributes); 
    }
    
    public static List<Quote__c> createQuote(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Quote__c> QuoteInsert = new List<Quote__c>();
        for(Integer i=0; i< numToInsert; i++){
            Quote__c quote = new Quote__c();
            quote.Amendment_Quote__c=false;
            quote.isActive__c=true;
            //quote.IsSyncing__c=false;
            quote.IsSyncing__c=true;
            QuoteInsert.add(quote);
        }
        return createRecords(QuoteInsert, doInsert, attributes); 
    }
    
    public static List<Category__c> createCategory(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Category__c> CategoryToInsert = new List<Category__c>();
        for(Integer i=0; i< numToInsert; i++){
            Category__c cat = new Category__c();
            cat.Name = 'TestAccount' + i;
            cat.isActive__c = true;
            CategoryToInsert.add(cat);
        }
        return createRecords(CategoryToInsert, doInsert, attributes);
    }*/

    public static List<TransactionLog__c> createTransactionLog(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<TransactionLog__c> TransactionLogToInsert = new List<TransactionLog__c>();
        for(Integer i=0; i< numToInsert; i++){
            TransactionLog__c trn = new TransactionLog__c();
            TransactionLogToInsert.add(trn);
        }
        return createRecords(TransactionLogToInsert, doInsert, attributes);
    }

    /*public static List<Field_Detail__c> createFieldDetail(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Field_Detail__c> FieldDetailToInsert = new List<Field_Detail__c>();
        for(Integer i=0; i< numToInsert; i++){
            Field_Detail__c fdt = new Field_Detail__c();
            fdt.ReadOnly__c = false;
            fdt.Visible__c = false;
            FieldDetailToInsert.add(fdt);
        }
        return createRecords(FieldDetailToInsert, doInsert, attributes);
    }
    public static List<Price_Matrix__c> createPriceMatrix(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Price_Matrix__c> PriceMatrixToInsert = new List<Price_Matrix__c>();
        for(Integer i=0; i< numToInsert; i++){
            Price_Matrix__c prm = new Price_Matrix__c();
            prm.Discount_Amount__c = 1000;
            prm.Markup_Amount__c = 300;
            PriceMatrixToInsert.add(prm);
        }
        return createRecords(PriceMatrixToInsert, doInsert, attributes);
    }
    public static List<Product_Hierarchy__c> createProductHierarchy(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Product_Hierarchy__c> ProductHierarchyToInsert = new List<Product_Hierarchy__c>();
        for(Integer i=0; i< numToInsert; i++){
            Product_Hierarchy__c prh = new Product_Hierarchy__c();
            ProductHierarchyToInsert.add(prh);          
        }
        return createRecords(ProductHierarchyToInsert, doInsert, attributes);
    }
    public static List<Section__c> createSection(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Section__c> SectionToInsert = new List<Section__c>();
        for(Integer i=0; i< numToInsert; i++){
            Section__c sct = new Section__c();
            sct.Name = 'TestAccount' + i;
            sct.Visible__c = false;
            sct.Sobject__c = 'Product2';
            sct.Section_Sequence__c = 1 + i;
            sct.Section_Alignment__c = 'Horizontal';
            SectionToInsert.add(sct);
        }
        return createRecords(SectionToInsert, doInsert, attributes);
    }
    
    public static List<Volume_Pricing__c> createVolumePricing(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Volume_Pricing__c> VolumePricingToInsert = new List<Volume_Pricing__c>();
        for(Integer i=0; i< numToInsert; i++){
            Volume_Pricing__c volprice = new Volume_Pricing__c();
            volprice.Name = 'TestAccount' + i;
            VolumePricingToInsert.add(volprice);
        }
        return createRecords(VolumePricingToInsert, doInsert, attributes);
      }
    
    public static List<Pricing_Attribute__c> createPricingAttribute(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Pricing_Attribute__c> pricingAttributeToInsert = new List<Pricing_Attribute__c>();
        for(Integer i=0; i< numToInsert; i++){
            Pricing_Attribute__c pa1 = new Pricing_Attribute__c();
            pricingAttributeToInsert.add(pa1);
        }
        return createRecords(pricingAttributeToInsert, doInsert, attributes);
    }
    
    
    
    public static List<Quote_Event__c> createQuoteEvent(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Quote_Event__c> quoteEventToInsert = new List<Quote_Event__c>();
        for(Integer i=0; i< numToInsert; i++){
            Quote_Event__c qe1 = new Quote_Event__c();
            qe1.Event__c='Quote Created';
            quoteEventToInsert.add(qe1);
        }
        return createRecords(quoteEventToInsert, doInsert, attributes);
    }
    
    public static List<AttributeRule__c> createAttributeRule(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<AttributeRule__c> attributeRuleInsert = new List<AttributeRule__c>();
        for(Integer i=0; i< numToInsert; i++){
            AttributeRule__c att = new AttributeRule__c();
            attributeRuleInsert.add(att);
        }
        return createRecords(attributeRuleInsert, doInsert, attributes); 
    }
    
    
    public static List<Grid_Column_Setup__c> createGridColumnSetUp(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Grid_Column_Setup__c> gridColumSetupInsert = new List<Grid_Column_Setup__c>();
        for(Integer i=0; i< numToInsert; i++){
            Grid_Column_Setup__c gcs = new Grid_Column_Setup__c();
            gcs.isCart_Visible__c=true;
            gcs.isDefault__c=true;
            gcs.isTable_Visible__c=true;
            gcs.Data_Type__c ='text';
            gridColumSetupInsert.add(gcs);
        }
        return createRecords(gridColumSetupInsert, doInsert, attributes); 
    }
    
    public static List<Subscription__c> createSubscription(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Subscription__c> SubscriptionToInsert = new List<Subscription__c>();
        for(Integer i=0; i< numToInsert; i++){
            Subscription__c sub = new Subscription__c();
            sub.SubscriptionType__c = 'Renewable';
            sub.Quantity__c = 10;
            sub.Unit_Cost__c = 30;
            SubscriptionToInsert.add(sub);
        }
        return createRecords(SubscriptionToInsert, doInsert, attributes);
    }

    public static List<Quote_Line_Item__c> createQuotelineItem(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Quote_Line_Item__c> QuoteLineItemcToInsert = new List<Quote_Line_Item__c>();
        for(Integer i=0; i< numToInsert; i++){
            Quote_Line_Item__c qli = new Quote_Line_Item__c();
            qli.Quantity__c = 10;
            
            QuoteLineItemcToInsert.add(qli);
        }
        return createRecords(QuoteLineItemcToInsert, doInsert, attributes);
    }
  
     public static List<Opportunity> createOpportunity(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Opportunity> OpportunityToInsert = new List<Opportunity>();
        for(Integer i=0; i< numToInsert; i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'OppName' + i;
            opp.CloseDate = Date.today() + 30;
            opp.StageName = 'Closed Won';
            OpportunityToInsert.add(opp);
        }
        return createRecords(OpportunityToInsert, doInsert, attributes);
    }    
    
    public static List<OpportunityLineItem> createOpportunityLineItem(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<OpportunityLineItem> OppLineItemcToInsert = new List<OpportunityLineItem>();
        for(Integer i=0; i< numToInsert; i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Quantity = 10;
            oli.TotalPrice = 2000;
            OppLineItemcToInsert.add(oli);
        }
        return createRecords(OppLineItemcToInsert, doInsert, attributes);
    }*/
    
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
            docTemplateSection.ChildObject__c = 'Test';
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
    
    /*Public static List<Contract> createContract(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Contract> docContractToInsert = New List<Contract>();
        for(Integer i=0; i< numToInsert; i++){
            Contract con = new Contract();
            con.StartDate = system.today();
            //con.EndDate = system.today() + 100;
            con.ContractTerm = 12;   
            docContractToInsert.add(con);
        }
        return createRecords(docContractToInsert, doInsert, attributes);
    }
    
    Public static List<Pricebook2> createPriceBook(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Pricebook2> doPricebookToInsert = New List<Pricebook2>();
        for(Integer i=0; i< numToInsert; i++){
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'Test Pricebook '+i;
            pb.IsActive = true;
            doPricebookToInsert.add(pb);
        }
        return createRecords(doPricebookToInsert, doInsert, attributes);
    }
    
    Public static List<PricebookEntry> createPriceBookEntry(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<PricebookEntry> doPricebookEntryToInsert = New List<PricebookEntry>();
        for(Integer i=0; i< numToInsert; i++){
            PricebookEntry pbe = new PricebookEntry();
            pbe.IsActive = true;
            pbe.UnitPrice = 500;
            doPricebookEntryToInsert.add(pbe);
        }
        return createRecords(doPricebookEntryToInsert, doInsert, attributes);
    }
    
     Public static List<Grid_Details__c> createGridDetails(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<Grid_Details__c> doGridDetailsToInsert = New List<Grid_Details__c>();
        for(Integer i=0; i< numToInsert; i++){
            Grid_Details__c gd = new Grid_Details__c();
            gd.Default_Page_Size__c = 50;
            doGridDetailsToInsert.add(gd);
        }
        return createRecords(doGridDetailsToInsert, doInsert, attributes);
    }
    
    Public static List<ContentVersion > createContentVersions(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<ContentVersion > doContentVersionToInsert = New List<ContentVersion >();
        for(Integer i=0; i< numToInsert; i++){
            ContentVersion cv = new ContentVersion();
            cv.Title          = 'a picture ' + i;
            cv.PathOnClient   = 'Pic.jpg';
            cv.VersionData    = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            doContentVersionToInsert.add(cv);
        }
        return createRecords(doContentVersionToInsert, doInsert, attributes);
    }
    
    Public static List<ContentDocumentLink> createContentDocumentLinks(Integer numToInsert, Boolean doInsert, Map<String, Object> attributes){
        List<ContentDocumentLink> doContentDocumentLinkToInsert = New List<ContentDocumentLink>();
        for(Integer i=0; i< numToInsert; i++){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.shareType = 'V';
            cdl.visibility = 'AllUsers';
            doContentDocumentLinkToInsert.add(cdl);
        }
        return createRecords(doContentDocumentLinkToInsert, doInsert, attributes);
    }
    
    public static list<ProductSetupCtrl.ProductAttributeValueWrapper> createPavWrapper(List<Product_Attribute__c> prodAttLst){
        list<ProductSetupCtrl.ProductAttributeValueWrapper> pavWrapLst = new list<ProductSetupCtrl.ProductAttributeValueWrapper>();
        
        ProductSetupCtrl.ProductAttributeValueWrapper pavw = new ProductSetupCtrl.ProductAttributeValueWrapper();
        
        pavw.productAttribute = prodAttLst[0];
        pavw.productAttributeValues = createProductAttributeValues(prodAttLst);
        pavWrapLst.add(pavw);
        
        return pavWrapLst;
    }
    
    public static List<Product_Attribute_Value__c> createProductAttributeValues(List<Product_Attribute__c> prodAttLst){
        List<Product_Attribute_Value__c> prodAttValLst = new List<Product_Attribute_Value__c>();
        for(Integer i=0; i< 3; i++){
            Product_Attribute_Value__c pav = new Product_Attribute_Value__c();
            pav.Name = 'test'+String.valueOf(i);
            pav.Product_Attribute__c = prodAttLst[0].Id;
        }
        return createRecords(prodAttValLst, true, null);
    }
    
    public static List<Attribute_Value__c> createAttributeValues(List<Attribute__c> attLst){
        List<Attribute_Value__c> attValLst = new List<Attribute_Value__c>();
        for(Integer i=0; i< 3; i++){
            Attribute_Value__c av = new Attribute_Value__c();
            av.Name = 'test'+String.valueOf(i);
            av.Attribute__c = attLst[0].Id;
        }
        return createRecords(attValLst, true, null);
    }*/
    
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
        List<PermissionSet> permissionstobeassigned = [SELECT Id, Label FROM PermissionSet WHERE Name IN ('DxCPQ_Setup','DxCPQ_Cart','DxCPQ_Super_Admin')];
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
    
    /*Public static PriceBook2 getStandardPriceBook(){
        Pricebook2 spb = new Pricebook2();
        spb.Id = Test.getStandardPricebookId();
        spb.IsActive = true;
        return spb;
    }*/

    public class SafeClassException extends Exception{
    }
}