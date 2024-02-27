/**
 * Class: RelatedObjectsClass
 * Developer:
 * Created Date:
 * @description : tility class for managing related objects and rule conditions.
 * Last Modified Date:
 */
global with sharing class RelatedObjectsClass {
    
    public static Safely safe = new Safely();
	private static Savepoint sp1;
    
    //Below method will return the list of child object names for the selectedobject
    /**
     * @description Returns a map of child object names for the selected object.
     * @param selectedObject The object for which to retrieve child object names.
     * @return Map containing child object names and their corresponding relationship field names.
     */
    @AuraEnabled
    public static map<string,string> getRelatedObjects(string selectedObject){
        try{
            map<string,string> relatedObjectsMap = new map<string,string>();
            list<Schema.Childrelationship> relatedObjectsList = Schema.getGlobalDescribe().get(selectedObject).getdescribe().getChildRelationships();
            for (Schema.Childrelationship relatedObject : relatedObjectsList) 
            {
                if(relatedObject.getChildSObject().getDescribe().getKeyPrefix()!=null
                &&
                !relatedObject.getChildSObject().getDescribe().isCustomSetting())
                {
                    String objectName=relatedObject.getChildSObject().getDescribe().getName();
                    if(!objectName.endsWithIgnoreCase('__Share') || !objectName.endsWithIgnoreCase('ChangeEvent') )
                    {
                        relatedObjectsMap.put(objectName,String.Valueof(relatedObject.getField()));
                    }
                }
            }
            return relatedObjectsMap;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'RelatedObjectsClass.getRelatedObjects()','selectedObject -> '+selectedObject+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }
    
    //Below method will return the list of field names present in the selected object
    /**
     * @description Returns a map of field names present in the selected object.
     * @param selectedObject The object for which to retrieve field names.
     * @return Map containing field names and their corresponding labels.
     */
    @AuraEnabled
    public static Map<string,string> getFields(String selectedObject){
    try{
        Map<string,string> reqFieldsMap=new Map<string,string>();
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> mapOfField = r.fields.getMap();        
        
        for(String fieldName : mapOfField.keySet()) {
            Schema.SObjectField field = mapOfField.get(fieldName);
            Schema.DescribeFieldResult f = field.getDescribe();
            reqFields.add(String.ValueOf(field));
            reqFieldsMap.put(String.ValueOf(field),String.Valueof(F.getLabel()));
        }
        return reqFieldsMap;
    }
    catch (Exception ex) {
        LogHandler.createLog((Id) null,'RelatedObjectsClass.getFields()','selectedObject -> '+selectedObject+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        return null;
    }  
    }
    
    /**
     * @description Returns the related object details for the selected Document Template.
     * @param docTempId The Document Template ID.
     * @return Document_Template__c object.
     */
    @AuraEnabled
    public static Document_Template__c getRelatedObjectForSelectedDocumentTemplate(Id docTempId){
        Document_Template__c docTemp = [SELECT Id, Name, Related_To_Type__c, IsActive__c FROM Document_Template__c WHERE Id=:docTempId WITH SECURITY_ENFORCED LIMIT 1];
        return docTemp;
    }
    
    /**
     * @description Returns grouping values (picklist values) for fields in the selected object.
     * @param selectedObject The object for which to retrieve grouping values.
     * @return Map containing field names and their grouping values.
     */
    @AuraEnabled
    public static Map<String,Object> getGroupingValues(String selectedObject){
        try{
            Map<String,Object> reqFields = new Map<String,Object>();
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(selectedObject);
            Schema.DescribeSObjectResult r = sobjType.getDescribe();
            Map<String, Schema.SObjectField> mapOfField = r.fields.getMap();
            for(String fieldName : mapOfField.keySet()) {
                Schema.SObjectField field = mapOfField.get(fieldName);
                Schema.DescribeFieldResult f = field.getDescribe();
                if(f.getType()+''=='PICKLIST')
                {                
                    List<Object> lst = new List<Object>();
                    for(Integer i=0;i<f.getPicklistValues().size();i++)
                    {
                        Map<String,String> mp = new Map<String,String>();
                        mp.put('label',f.getPicklistValues()[i].getLabel());
                        mp.put('value',f.getPicklistValues()[i].getValue());
                        lst.add(mp);
                    }
                    reqFields.put(fieldName,lst);
                }        	
            }
            return reqFields;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'RelatedObjectsClass.getGroupingValues()','selectedObject -> '+selectedObject+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }    
    
    /* TemplateRelatedObjects LWC Calls - Intended for Filtering Rules - Modified by Rahul*/
    /**
     * @description Returns a list of ConditionObjectWrapper objects for the selected child object label.
     * @param selectedChildObjectLabel The label of the child object for which to retrieve conditions.
     * @return List of ConditionObjectWrapper objects containing object label, API name, and field set details.
     */
    @AuraEnabled	
    public static List<ConditionObjectWrapper> getSObjectListFiltering(String selectedChildObjectLabel){        	
        List<ConditionObjectWrapper> conditionObjectList = new List<ConditionObjectWrapper>();	
        ConditionObjectWrapper cWrap =  new ConditionObjectWrapper();	
                cWrap.objectLabelName = selectedChildObjectLabel;	
                cWrap.objectAPIName = selectedChildObjectLabel;	
                cWrap.fieldSet = getFieldsWrapper(cWrap.objectAPIName);	
        conditionObjectList.add(cWrap);	
        return conditionObjectList;	
    }
    
	/**
     * @description Returns a list of fields wrapped in a custom class.
     * @param selectedObject The object for which to retrieve fields.
     * @return List of FieldWrap objects containing field details.
     */
    public static List<FieldWrap> getFieldsWrapper(String selectedObject){
        try{
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Schema.SObjectType ctype = gd.get(selectedObject); 
            Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();   
            List<FieldWrap> strList = new List<FieldWrap>();        
            for(String fieldName: fmap.keySet()) {
                String dType = String.valueOf(fmap.get(fieldName).getDescribe().getType());
                if(dType== 'PICKLIST' || dType == 'BOOLEAN' || dType == 'INTEGER' || dType == 'DOUBLE' || dType=='CURRENCY' || dType=='PERCENT' || dType=='STRING' || dType=='TEXT'){
                //if(dType== 'PICKLIST' || dType == 'BOOLEAN' || dType == 'INTEGER' || dType == 'DOUBLE' || dType=='CURRENCY' || dType=='PERCENT'){	
                    FieldWrap wmp = new FieldWrap();
                    wmp.name = fmap.get(fieldName).getDescribe().getLabel(); 
                    wmp.apiName = fieldName;
                    wmp.dataType = String.valueOf(fmap.get(fieldName).getDescribe().getType());
                    if(wmp.dataType=='PICKLIST'){
                        List<String> plistValues = new List<String> ();
                        List<Schema.PicklistEntry> plist = fmap.get(fieldName).getDescribe().getPickListValues();
                        for(Schema.PicklistEntry pl : plist){
                            plistValues.add(pl.getValue());
                        }
                        wmp.values = plistValues;
                    }
                    strList.add(wmp);
                }
            }
            return strList;   
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'RelatedObjectsClass.getFieldsWrapper()','selectedObject -> '+selectedObject+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }   
    }
    
	/**
     * @description Returns existing Rule Conditions for the specified rule name.
     * @param ruleName The name of the rule for which to retrieve conditions.
     * @return List of Rule_Condition__c objects.
     */
    @AuraEnabled
    public static List<Rule_Condition__c> getExistingConditions(String ruleName){
        List<Rule_Condition__c> existingConditions = RuleSelector.getRuleConditions(ruleName);
        return existingConditions;
    }
    
	/**
     * @description Clones rules from the parent template and returns the cloned rule ID.
     * @param parentTempSecId The ID of the parent template section.
     * @return ID of the cloned rule.
     */
    public static Id cloneRulesFromParentTemplate(Id parentTempSecId){
        try{
            
            Id docRule = [Select ruleId__c from document_template_section__c where id=:parentTempSecId WITH SECURITY_ENFORCED limit 1].ruleId__c;
            Rule__c tempRule = [Select Id, Rule_Expression__c,Rule_Description__c, (Select Condition_Field__c,ConditionIndex__c,DataType__c,Evaluation_Object__c,Value__c,Name,Operator__c from Rule_Conditions__r) from rule__c where Id=:docRule WITH SECURITY_ENFORCED];
            List<Map<String,Object>> condsArr = new List<Map<String,Object>> {};
            for(Rule_Condition__c item : tempRule.Rule_Conditions__r) {
                Map<String,Object> condMap = new Map<String,Object> {};
                condMap.put('Id',null);
                condMap.put('conditionIndex',item.ConditionIndex__c);
                condMap.put('selectedObject',item.Evaluation_Object__c);
                condMap.put('value',item.Value__c);
                condMap.put('operator',item.Operator__c);
                condMap.put('conditionName',item.Name);
                condMap.put('selectedField',item.Condition_Field__c);
                condMap.put('dataType',item.DataType__c);
                condsArr.add(condMap);
            }
            String condString = JSON.serializePretty(condsArr);
            String cloneRule = createRuleCondition(condString, tempRule.Rule_Expression__c, null, null);
            return cloneRule;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'RelatedObjectsClass.cloneRulesFromParentTemplate()','parentTempSecId -> '+parentTempSecId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }
    
	/**
     * @description Creates or updates rule conditions based on the provided data.
     * @param ruleConditions JSON string containing rule conditions data.
     * @param ruleExpression Rule expression string.
     * @param deleteIds List of IDs to delete.
     * @param sectionrecordid Section record ID.
     * @return Name (ID) of the created or updated rule.
     */
    @AuraEnabled
    public static String createRuleCondition(String ruleConditions, String ruleExpression, List<Id> deleteIds , String sectionrecordid){
        try{
            Id tempruleId;
            String ruleName;
            if(deleteIds != null && deleteIds.size() > 0){
                RuleSelector.deleteRuleConditions(deleteIds); 
            }
            ruleExpression = ruleExpression.replaceAll('"','');

            if(sectionrecordid!=null &&!sectionrecordid.contains('NotSaved')){
                Document_Template_Section__c tsobj = [select RuleId__c,Name from Document_Template_Section__c where id=:sectionrecordid WITH SECURITY_ENFORCED];
                tempruleId = tsobj.RuleId__c;
                
                if(tempruleId==null){
                    Rule__c newRule = new Rule__c();
                    newRule.Rule_Expression__c = ruleExpression;
                    newRule.Rule_Description__c = 'Template Filtering Rule';
                    //insert newRule;      

                    Database.SaveResult[] srLst1 = safe.doInsert(new List<Rule__C> {newRule});
                    List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(srLst1);
                    if(errorList1.size()>0){
                        throw new SafeClassException(String.join( errorList1, ', ' ));
                    } else{
                        newRule.Id = srLst1[0].Id;
                    }
                
                
                    tempruleId = newRule.Id;
                    //Rule__c arr = [Select Name from Rule__c where Id=:tempruleId WITH SECURITY_ENFORCED];
                    //ruleName = arr.Name;
                    ruleName = tempruleId;
                }
                else{
                    Rule__c arr = [Select Name,Rule_Expression__c from Rule__c where Id=:tempruleId WITH SECURITY_ENFORCED];
                    arr.Rule_Expression__c = ruleExpression;
                    //update arr;

                    Database.SaveResult[] srLst1 = safe.doUpdate(new List<Rule__c> {arr});
                    List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(srLst1);
                    if(errorList1.size()>0){
                        throw new SafeClassException(String.join( errorList1, ', ' ));
                    }
                }
            }
            else{
                Rule__c newRule = new Rule__c();
                newRule.Rule_Expression__c = ruleExpression;
                newRule.Rule_Description__c = 'Template Filtering Rule';
                //insert newRule;
                
                Database.SaveResult[] srLst1 = safe.doInsert(new List<Rule__C> {newRule});
                List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(srLst1);
                if(errorList1.size()>0){
                    throw new SafeClassException(String.join( errorList1, ', ' ));
                } else{
                    newRule.Id = srLst1[0].Id;
                }
                
                tempruleId = newRule.Id;
                //Rule__c arr = [Select Name from Rule__c where Id=:tempruleId WITH SECURITY_ENFORCED];
                //ruleName = arr.Name;
                ruleName = tempruleId;
            }        
            
            List<Rule_Condition__c> conditions = new List<Rule_Condition__c>();
            List<Rule_Condition__c> insertConditionsList = new List<Rule_Condition__c>();
            List<Rule_Condition__c> updateConditionsList = new List<Rule_Condition__c>();
            String jsonStr = ruleConditions;
            
            JSONParser conditionParser = JSON.createParser(jsonStr);
            while (conditionParser.nextToken() != null) {
                if (conditionParser.getCurrentToken() == JSONToken.START_OBJECT) {
                    RuleConditionWrapper ruleCondition = (RuleConditionWrapper)conditionParser.readValueAs(RuleConditionWrapper.class);
                    Rule_Condition__c condition = new  Rule_Condition__c();
                    if(!String.isBlank(ruleCondition.Id)){
                        condition.Id = ruleCondition.Id;
                    }
                    condition.Name = ruleCondition.conditionName;
                    if(condition.Id==null){
                        condition.Rule__c= tempruleId;
                    }               
                    
                    condition.Operator__c= ruleCondition.operator;
                    condition.Evaluation_Object__c= ruleCondition.selectedObject;
                    condition.DataType__c= ruleCondition.dataType;
                    condition.Condition_Field__c= ruleCondition.selectedField;
                    condition.Value__c= ruleCondition.value;
                    condition.ConditionIndex__c = ruleCondition.conditionIndex;
                    conditions.add(condition);
                }
            }
            if(conditions.size()>0){
                for(Rule_Condition__c rulCond : conditions) {
                    if (rulCond.Id==null) {                                        
                        insertConditionsList.add(rulCond);
                    } else {                        
                        updateConditionsList.add(rulCond);
                    }
                }
                if(insertConditionsList.size()>0){
                    if (sp1 == null){ sp1 = Database.setSavepoint();} 
                    Database.SaveResult[] srLst1 = safe.doInsert(insertConditionsList);
                    List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(srLst1);
                    if(errorList1.size()>0){
                        Database.rollback(sp1);
                        throw new SafeClassException(String.join( errorList1, ', ' ));
                    }
                }
                if(updateConditionsList.size()>0){
                    if (sp1 == null) {sp1 = Database.setSavepoint();}
                    Database.SaveResult[] srList2 = safe.doUpdate(updateConditionsList);
                    List<String> errorList2 = Safely.safeClassExceptionHandlerInsert(srList2);
                    if(errorList2.size()>0){
                        Database.rollback(sp1);
                        throw new SafeClassException(String.join( errorList2, ', ' ));
                    }
                }
            }
            return ruleName;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'RelatedObjectsClass.createRuleCondition()','sectionrecordid -> '+sectionrecordid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }  
    }
    
	/**
     *@description Custom wrapper class for rule conditions.
     */
    public class RuleConditionWrapper{
        /**
         * @description Represents the unique identifier (Id) of the condition.
         *              Used to uniquely identify and manage the condition in the client-side.
         */
        @AuraEnabled
        public String Id { get; set; }
        
        /**
         * @description Represents the name of the condition, providing a meaningful label or identifier.
         */
        @AuraEnabled
        public String conditionName { get; set; }
        
        /**
         * @description Represents the operator used in the condition, defining the type of comparison.
         *              Examples include '=', '!=', '>', '<', etc.
         */
        @AuraEnabled
        public String operator { get; set; }
        
        /**
         * @description Represents the object selected in the condition, specifying the context or entity for the condition.
         */
        @AuraEnabled
        public String selectedObject { get; set; }
        
        /**
         * @description Represents the data type of the selected field in the condition.
         *              Examples include 'Text', 'Number', 'Date', etc.
         */
        @AuraEnabled
        public String dataType { get; set; }
        
        /**
         * @description Represents the field selected in the condition, indicating the property or attribute being compared.
         */
        @AuraEnabled
        public String selectedField { get; set; }
        
        /**
         * @description Represents the value used in the condition for comparison with the selected field.
         */
        @AuraEnabled
        public String value { get; set; }
        
        /**
         * @description Represents the index of the condition, providing its position or order among multiple conditions.
         */
        @AuraEnabled
        public String conditionIndex { get; set; }

	}
    
	/**
     * @description Custom wrapper class for condition objects.
     */
    public class ConditionObjectWrapper{
       /**
         * @description Represents the label or display name of the Salesforce object.
         *              Used for presenting a human-readable name associated with the object.
         */
        @AuraEnabled
        public String objectLabelName { get; set; }
        
        /**
         * @description Represents the API name of the Salesforce object.
         *              Used for identifying the object programmatically in Apex and API calls.
         */
        @AuraEnabled
        public String objectAPIName { get; set; }
        
        /**
         * @description Represents a list of FieldWrap objects, each providing information about a field on the Salesforce object.
         *              Used for displaying and managing details about fields associated with the object.
         * @see FieldWrap
         */
        @AuraEnabled
        public List<FieldWrap> fieldSet { get; set; }
 }
	
	/**
     * @description Custom wrapper class for fields.
     */
   	public class FieldWrap{
        /**
         * @description Represents the name or label associated with a field.
         *              Used for displaying a human-readable identifier for the field.
         */
        @AuraEnabled
        public String name { get; set; }
        
        /**
         * @description Represents the API name of a field.
         *              Used for programmatic identification and reference to the field in Apex and API calls.
         */
        @AuraEnabled
        public String apiName { get; set; }
        
        /**
         * @description Represents the data type of a field.
         *              Used for specifying the type of data that can be stored in the field.
         */
        @AuraEnabled
        public String dataType { get; set; }
        
        /**
         * @description Represents a list of values associated with a field, particularly applicable for picklist fields.
         *              Used for displaying and managing the available values for selection in the user interface.
         */
        @AuraEnabled
        public List<String> values { get; set; }
}
    
	/**
     * @description Custom exception class for safe handling.
     */
    public class SafeClassException extends Exception{        
	}
    
	/**
     * @description Handles resetting conditions for the specified template rule.
     * @param templateRuleId The ID of the template rule to reset.
     * @return Success or Error message.
     */
    @AuraEnabled
    public static String handleTemplateRuleResetCondition(Id templateRuleId) {
        try{
            Rule__c templateRule = [Select Id from Rule__c Where Id=:templateRuleId WITH SECURITY_ENFORCED limit 1];        
            List<Rule__c> deleteRule = new List<Rule__c> {templateRule};
            
            Savepoint sp = Database.setSavepoint();
            List<Database.DeleteResult> deleteResult = safe.doDelete(deleteRule);
            List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
            if(errorList.size()>0){
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            } 
            return 'Success';
        } catch(Exception ex){
            LogHandler.createLog((Id) null,'RelatedObjectsClass.handleTemplateRuleResetCondition()','Rule Id -> '+ templateRuleId +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        	return 'Error';
        }
    }
}