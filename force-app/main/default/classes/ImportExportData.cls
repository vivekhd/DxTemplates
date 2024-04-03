public class ImportExportData {
    public class templateWrapper{
        @AuraEnabled
        Public sobject document_template {get;set;}
    }
    
    public static templateWrapper templateData(){
        templateWrapper tWrapper = new templateWrapper();
        List<sObject> allData = new List<sObject>();
        return twrapper;
    }
    
    @AuraEnabled
    public static List<sObject> allDocTemps(){
        List<Document_Template__c> docTemp= [SELECT id from Document_Template__c];
        return docTemp;
    }
    
    @AuraEnabled
    public static String getAllDocumentTemplatesData(){
        try{
            Map<String, Object> dTMap = new Map<String, Object>();
            Map<String,String> holdCVData = new Map<String,String>();
            List<Document_Template__c> docTemp = [SELECT Id, Name, isactive__c, Related_To_Type__c, Version_Number__c, Previously_Active__c, Parent_Template__c, Watermark_Data__c, External_Id__c FROM Document_Template__c WITH SECURITY_ENFORCED order by CreatedDate Desc limit 50000];
            List<String> templateIds = new List<String>();
            for(Document_Template__c dt : docTemp){
                templateIds.add(dt.Id);
            }
            System.debug('templateIds ---> '+ templateIds);
            //document template sections
            List<Document_Template_Section__c> dts = [select Id,Name, DisplaySectionName__c, Document_Template__c, ChildObject__c,  Document_Clause__c, Header_Content__c, IsActive__c, IsEditable__c, New_Page__c, Parent_Section__c, RuleId__c, Section_Content__c, Section_Details__c, Sequence__c, Type__c  from Document_Template_Section__c with USER_MODE LIMIT 50000];
            System.debug('dts ---> '+ dts);
            List<String> templatesectionclauses = new List<String>();
            List<String> templatesectionrules = new List<String>();
            for(Document_Template_Section__c dtSection : dts){
                if (dtSection.DxCPQ__Document_Clause__c!=null){
                	templatesectionclauses.add(dtSection.DxCPQ__Document_Clause__c);
                }
                if(dtSection.DxCPQ__RuleId__c!=null){
                    templatesectionrules.add(dtSection.DxCPQ__RuleId__c);
                }
            }
            //document clauses
            List<Document_Clause__c> dc = [select Id,Name, Body__c, Category__c, IsActive__c, Product__c, Status__c from Document_Clause__c where id IN:templatesectionclauses with USER_MODE LIMIT 50000];
            System.debug('dc ---> '+ dc);
            List<Rule__c> rules = [select Id,Rule_Description__c,Rule_Expression__c from Rule__c  where id IN:templatesectionrules];
            List<String> ruleIds = new List<String>();
            for(Rule__c rId : rules){
				ruleIds.add(rId.Id);
            }
            List<Rule_Condition__c> ruleConditions = [select Id, Name, Evaluation_Object__c, Condition_Field__c,ConditionIndex__c,DataType__c,Is_Cart_Item_Condition__c,Operator__c,Value__c,Rule__c from Rule_Condition__c where Rule__c IN:ruleIds];
            
			//List<ContentVersion> cvLst = [select Id, ContentDocumentId, ContentBodyId, FirstPublishLocationId,VersionData,  FileExtension, FileType, PathOnClient from ContentVersion where FirstPublishLocationId IN:templateIds];
            //System.debug('cvLst ---> '+ cvLst);
            //for(ContentVersion cvdt : cvLst){
            //    String cvImageData = EncodingUtil.base64Encode(cvdt.VersionData);
            //    holdCVData.put(cvdt.Id, cvImageData);
            //}
            
            //System.debug('image CV data ---> '+ holdCVData);
            dTMap.put('Templates', docTemp);
            dTMap.put('Template Sections', dts);
            dTMap.put('Document Clauses', dc);
            dTMap.put('Rules',rules);
            dTMap.put('Rule Conditions',ruleConditions);
            //dTMap.put('Content Version', cvLst);
            //dTMap.put('Image CV Data', holdCVData);
            System.debug('dTMap -----> '+ dTMap);
            String finalMap = JSON.serialize(dTMap); 
            System.debug('finalMap ---> '+ finalMap);
            return finalMap;
        }
        catch(exception e){
            System.debug('error message ----> '+ e.getMessage());
            return '';
        }
       
    }
    
    @AuraEnabled
    public static List<Map<String,String>> createImportedTemplates(String tempLst){
        List<Map<String,String>> recordIds = new List<Map<String,String>>();
        List<Document_Template__c> templateLst = (List<Document_Template__c>) JSON.deserialize(tempLst, List<Document_Template__c>.class);
        List<Document_Template__c> createdRecords = new List<Document_Template__c>();
		for (Document_Template__c obj : templateLst) {
            createdRecords.add(obj);
        }
		insert createdRecords;
		for (Document_Template__c obj : createdRecords) {
            //newRecords.put(String.valueOf(obj.Id), obj.DxCPQ__External_ID__c); 
            map<String,String> newRecords = new Map<String,String>();
            newRecords.put('Id', String.valueOf(obj.Id));
            newRecords.put('ExternalId', obj.DxCPQ__External_ID__c);
            recordIds.add(newRecords);
            
        }
        
        return recordIDs;
    }
    
    @AuraEnabled
    public static List<String> createImportedTemplateSections(String tempSecLst){
        List<String> recordIds = new List<String>();
        List<Document_Template_Section__c> templateSecLst = (List<Document_Template_Section__c>) JSON.deserialize(tempSecLst, List<Document_Template_Section__c>.class);
        List<Document_Template_Section__c> createdRecords = new List<Document_Template_Section__c>();
		for (Document_Template_Section__c obj : templateSecLst) {
            createdRecords.add(obj);
        }
		insert createdRecords;

		for (Document_Template_Section__c obj : createdRecords) {
            recordIds.add(obj.Id);
        }
        
        return recordIds;
        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> createImportedClauses(String tempClausesLst){
        List<Map<String,String>> recordIds = new List<Map<String,String>>();
        List<Document_Clause__c> templateClausesLst = (List<Document_Clause__c>) JSON.deserialize(tempClausesLst, List<Document_Clause__c>.class);
        List<Document_Clause__c> createdRecords = new List<Document_Clause__c>();
		for (Document_Clause__c obj : templateClausesLst) {
            createdRecords.add(obj);
        }
		insert createdRecords;
		//map<String,String> newRecords = new Map<String,String>();
		for (Document_Clause__c obj : createdRecords) {
            map<String,String> newRecords = new Map<String,String>();
            newRecords.put('Id', String.valueOf(obj.Id));
            newRecords.put('ExternalId', obj.DxCPQ__External_ID__c);
            recordIds.add(newRecords);
        }
        return recordIds;        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> createImportedRules(String tempRuleLst){
        List<Map<String,String>> recordIds = new List<Map<String,String>>();
        List<Rule__c> templateRulesLst = (List<Rule__c>) JSON.deserialize(tempRuleLst, List<Rule__c>.class);
        List<Rule__c> createdRecords = new List<Rule__c>();
		for (Rule__c obj : templateRulesLst) {
            createdRecords.add(obj);
        }
		insert createdRecords;
		//map<String,String> newRecords = new Map<String,String>();
		for (Rule__c obj : createdRecords) {
            map<String,String> newRecords = new Map<String,String>();
            newRecords.put('Id', String.valueOf(obj.Id));
            newRecords.put('ExternalId', obj.DxCPQ__External_Id__c);
            recordIds.add(newRecords);
        }
        return recordIds;        
    }
    
    @AuraEnabled
    public static List<Map<String,String>> createImportedRuleConditions(String tempRuleCondLst){
        List<Map<String,String>> recordIds = new List<Map<String,String>>();
        List<Rule_Condition__c> templateRuleCondLst = (List<Rule_Condition__c>) JSON.deserialize(tempRuleCondLst, List<Rule_Condition__c>.class);
        List<Rule_Condition__c> createdRecords = new List<Rule_Condition__c>();
		for (Rule_Condition__c obj : templateRuleCondLst) {
            createdRecords.add(obj);
        }
		insert createdRecords;
		//map<String,String> newRecords = new Map<String,String>();
		for (Rule_Condition__c obj : createdRecords) {
            map<String,String> newRecords = new Map<String,String>();
            newRecords.put('Id', String.valueOf(obj.Id));
            newRecords.put('ExternalId', obj.DxCPQ__External_Id__c);
            recordIds.add(newRecords);
        }
        return recordIds;        
    }
}