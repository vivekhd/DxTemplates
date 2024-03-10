/* The MergeFieldsClass assists in merging record fields into templates, handles title case conversions, 
 * and retrieves object fields for dynamic form generation.
 * Error handling ensures robustness. 
 * It integrates with Salesforce Aura components, offering versatile 
 * functionality for template customization and data presentation. 
 * With features like field merging and dynamic form 
 * generation, it enhances user experience and 
 * streamlines data management within Salesforce applications.
*/


/**
 * @description Represents the MergeFieldsClass, which is a class with sharing.
 *              This class provides functionality related to merging fields.
 */
public with sharing class MergeFieldsClass {
    /**
     * @description    Merges fields from the specified record into the selected template contents
     * @param          selectedTemplateContents  List of Document_Template_Section__c representing selected template contents
     * @param          recordId                  Id of the record from which fields will be merged
     * @return         List<Document_Template_Section__c> The modified template contents with merged fields
     */

    public static List<Document_Template_Section__c> mergefieldsMethod(List<Document_Template_Section__c> selectedTemplateContents, Id recordId) {   
        try{
            String objectName = recordId.getSObjectType().getDescribe().getName();
            String mainstr;
            for(Document_Template_Section__c sec: selectedTemplateContents) {
                if(mainstr==null){
                    mainstr=sec.Section_Content__c;
                }else{
                    mainstr=mainstr+sec.Section_Content__c;
                }
            }
            String mainObject=objectName;
            
            Pattern p = Pattern.compile('\\{!.+?\\}');
            Matcher m = p.matcher(mainstr);
            String mainfields;
            Set<String> mainfieldsList = new Set<String>();
            
            while(m.find()) {
                String strReplace = '{!'+mainObject+'.';
                String str = m.group(0).replace(strReplace,'').replace('}',', ');
                String str1 = str.replace(',','');
                mainfieldsList.add(str1);           
            }

            for(String str : mainfieldsList){
                if(mainfields==null){
                    mainfields=str;
                }else{
                    mainfields = mainfields+', '+str;  
                }
            }

            if(mainfields!=null) {
                mainfields = mainfields.removeEnd(', ');
                string mainSOQL='Select '+String.escapeSingleQuotes(mainfields)+' from '+String.escapeSingleQuotes(mainObject)+' where Id= \'' + recordId + '\' WITH SECURITY_ENFORCED';
                sObject qrec=Database.query(mainSOQL);
                Map<String, Object> mainMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qrec));           
                
                for(Document_Template_Section__c sec: selectedTemplateContents) {
                    for(String str:mainfieldsList)  {
                        str = str.replaceAll('(\\s+)', '');
                        if(mainMap.containskey(str)) {
                            string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                            sec.Section_Content__c=sec.Section_Content__c.replace(mergefieldsyntax, String.valueOf(mainMap.get(str)));
                        } else {
                            String finalvalue;
                            if(str.contains('.')){
                                List<String> strList = new List<string>();
                                strList=str.split('\\.');
                                Map<String, Object> tempObj=new Map<String, Object>();
                                tempObj=mainMap;
                                String resVal; 
                                for(Integer j=0; j<strList.size(); j++) {
                                    if(tempObj.containskey(strList[j]))  {
                                        if(j==strList.size()-1)   {
                                            finalvalue=String.valueOf(tempObj.get(strList[j]));
                                        }else  {
                                            tempObj=(Map<String, Object>)tempObj.get(strList[j]);                                            
                                        }
                                    }
                                }
                            }
                            if(finalvalue!=null)  {
                                string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                                sec.Section_Content__c=sec.Section_Content__c.replace(mergefieldsyntax, finalvalue); 
                            }
                        }
                    }
                }
            }
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'MergeFieldsClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }        
        return selectedTemplateContents;
    }
    
    /**
     * @description    Converts a phrase to title case
     * @param          phrase String to be converted to title case
     * @return         String Phrase converted to title case
     */
    public static String toTitleCase(String phrase){
        String titlePhrase = '';
        try{
            Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};
                if(phrase != null && phrase.length() > 0){
                    String[] splitPhrase = phrase.trim().split(' ');                
                    for(integer i = 0; i < splitPhrase.size(); i++){
                        if(!forceLower.contains(splitPhrase[i].toLowerCase()) || i == 0 || i == (splitPhrase.size()-1) ){
                            titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase())+(splitPhrase[i].substring(1).toLowerCase())+' ';
                        }else{
                            titlePhrase += splitPhrase[i].toLowerCase()+' ';
                        }
                    }
                }
        } catch(Exception ex){
            LogHandler.createLog((Id) null,'MergeFieldsClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
        return titlePhrase.trim();
    }
    
    /**
     * @description    Retrieves the fields of a selected object
     * @param          selectedObject String name of the selected object
     * @return         List<FieldWrap> List of FieldWrap objects representing the fields of the selected object
     */
    @AuraEnabled
    public static List<FieldWrap> getFields(String selectedObject){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType ctype = gd.get(selectedObject); 
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();   
        List<FieldWrap> strList = new List<FieldWrap>();
        try{
            for(String fieldName: fmap.keySet()) {
                FieldWrap wmp = new FieldWrap();
                String dType = String.valueOf(fmap.get(fieldName).getDescribe().getType());
                wmp.name = fmap.get(fieldName).getDescribe().getLabel(); 
                wmp.apiName = fmap.get(fieldName).getDescribe().getName();
                
                wmp.dataType = String.valueOf(fmap.get(fieldName).getDescribe().getType()); 
                if(dType== 'REFERENCE'){
                    wmp.name=wmp.name+'>';
                    Schema.DescribeFieldResult f = fmap.get(fieldName).getDescribe();
                    for(Schema.SObjectType reference : f.getReferenceTo()) {
                        wmp.sObjectName = String.valueOf(reference.getDescribe().getName());
                    }
                    wmp.relationshipName=String.valueOf(fmap.get(fieldName).getDescribe().getRelationshipName());
                }
                
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
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'MergeFieldsClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
        return strList;    
    }
    
    /**
     * @description Represents a wrapper class used to encapsulate field information.
     *              This class provides properties to store metadata about a field, such as its name, API name,
     *              data type, values, sObject name, and relationship name.
     */
    public class FieldWrap{
        /**
         * @description Represents the name of the field.
         */
        @AuraEnabled
        public String name{get;set;}
        
        /**
         * @description Represents the API name of the field.
         */
        @AuraEnabled
        public String apiName{get;set;}
        
        /**
         * @description Represents the data type of the field.
         */
        @AuraEnabled
        public String dataType{get;set;}
        
        /**
         * @description Represents the list of values associated with the field.
         */
        @AuraEnabled
        public List<String> values{get;set;}
        
        /**
         * @description Represents the API name of the sObject to which the field belongs.
         */
        @AuraEnabled
        public String sObjectName{get;set;}
        
        /**
         * @description Represents the relationship name of the field (if it's a related field).
         */
        @AuraEnabled
        public String relationshipName{get;set;}
    }    

     /**
     * @description    Merges fields from the specified record into the selected template contents
     * @param          selectedTemplateContents  List of Document_Template_Section__c representing selected template contents
     * @param          recordIds                  List of Ids of the records from which fields will be merged
     * @return         List<Document_Template_Section__c> The modified template contents with merged fields
     */
    public static List<Document_Template_Section__c> mergefieldsMethodMultiple(List<Document_Template_Section__c> selectedTemplateContents, List<String> recordIds) {   
        try{
            List<Document_Template_Section__c> docsTempLst = new List<Document_Template_Section__c>();
				String objectName = ((Id)recordIds[0]).getSObjectType().getDescribe().getName();
				String mainstr;
				for(Document_Template_Section__c sec: selectedTemplateContents) {
					if(mainstr==null){
						mainstr=sec.Section_Content__c;
					}else{
						mainstr=mainstr+sec.Section_Content__c;
					}
				}
				String mainObject=objectName;
				
				Pattern p = Pattern.compile('\\{!.+?\\}');
				Matcher m = p.matcher(mainstr);
				String mainfields;
				Set<String> mainfieldsList = new Set<String>();
            while(m.find()) {
					String strReplace = '{!'+mainObject+'.';
					String str = m.group(0).replace(strReplace,'').replace('}',', ');
					String str1 = str.replace(',','');
					mainfieldsList.add(str1);
				}
				for(String str : mainfieldsList){
					if(mainfields==null){
						mainfields=str;
					}else{
						mainfields = mainfields+', '+str;  
					}
				}
            Integer executeHeadFoot = 0;
            	string mainSOQL='Select '+String.escapeSingleQuotes(mainfields)+' from '+String.escapeSingleQuotes(mainObject)+' where Id IN :recordIds WITH SECURITY_ENFORCED';
            for(Sobject qrec : Database.query(mainSOQL)){
                    
                    Boolean executeVar = false;
                    if(mainfields!=null) {
                        mainfields = mainfields.removeEnd(', ');
                        Map<String, Object> mainMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qrec));
                        for(Document_Template_Section__c sec: selectedTemplateContents) {
                            Document_Template_Section__c tempSec = (Document_Template_Section__c) JSON.deserialize(JSON.serialize(sec), Document_Template_Section__c.class);
                            if(executeHeadFoot == 0){
                                executeVar = true;
                            }
                            else{
                                if(!tempSec.DxCPQ__Type__c.equals('Header')  &&	 !tempSec.DxCPQ__Type__c.equals('Footer')  ){
                                    executeVar = true;
                            	}
                                else{
                                    executeVar = false;
                                }
                            }
                            if(executeVar){
                                for(String str:mainfieldsList)  {
                                    str = str.replaceAll('(\\s+)', '');
                                    if(mainMap.containskey(str)) {
                                        string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                                        tempSec.Section_Content__c=tempSec.Section_Content__c.replace(mergefieldsyntax, String.valueOf(mainMap.get(str)));
                                    } else {
                                        String finalvalue;
                                        if(str.contains('.')){
                                            List<String> strList = new List<string>();
                                            strList=str.split('\\.');
                                            Map<String, Object> tempObj=new Map<String, Object>();
                                            tempObj=mainMap;
                                            String resVal; 
                                            for(Integer j=0; j<strList.size(); j++) {
                                                if(tempObj.containskey(strList[j]))  {
                                                    if(j==strList.size()-1)   {
                                                        finalvalue=String.valueOf(tempObj.get(strList[j]));
                                                    }else  {
                                                        tempObj=(Map<String, Object>)tempObj.get(strList[j]);                                            
                                                    }
                                                }
                                            }
                                        }
                                        if(finalvalue!=null)  {
                                            string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                                            tempSec.Section_Content__c=tempSec.Section_Content__c.replace(mergefieldsyntax, finalvalue); 
                                        }
                                        else{
                                            string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                                            tempSec.Section_Content__c=tempSec.Section_Content__c.replace(mergefieldsyntax, ''); 
                                        }
                                    }
                                }
                                docsTempLst.add(tempSec);
                            }
                            executeVar = false;
                            
                        }   
                        
                    } 
                   executeHeadFoot = executeHeadFoot + 1; 
                } 
                mainstr = '';
            selectedTemplateContents = docsTempLst;
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'MergeFieldsClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }        
        return selectedTemplateContents;
    }
  
}