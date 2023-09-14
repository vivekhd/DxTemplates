public with sharing class MergeFieldsClass {
    public static List<Document_Template_Section__c> mergefieldsMethod(List<Document_Template_Section__c> selectedTemplateContents, Id recordId)
    {   
        String objectName = recordId.getSObjectType().getDescribe().getName();
        String mainstr;
        for(Document_Template_Section__c sec: selectedTemplateContents){
            if(mainstr==null){
                mainstr=sec.Section_Content__c;
            }else{
                mainstr=mainstr+sec.Section_Content__c;
            }
        }
        System.debug('the mainstr'+mainstr);

        String mainObject=objectName;
        System.debug('the mainObject'+mainObject);
 
        
        
        
      //  Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(mainObject).getDescribe();
        
   
        
     /*   ApexClass abc=[select id,name,namespaceprefix from apexclass where name like '%MergeFieldsClass%' WITH SECURITY_ENFORCED];
        system.debug('abc-'+abc);
        if(abc.namespaceprefix!=null)
        {
            if(describeResult.getKeyPrefix() != null )
            {
            	mainObject=abc.namespaceprefix+'__'+mainObject;
            }
        }
        System.debug('the mainObject2'+mainObject);	*/								   
        //String mainstr='<p>Hello <span style="color: rgb(68, 68, 68);">{!Quote.Name},</span></p><p><br></p><p><span style="color: rgb(68, 68, 68);">Close Date: </span>{!Quote.Close_Date__c}</p><p>Status: <span style="color: rgb(68, 68, 68);">{!Quote.Status__c}</span></p><p><br></p>';
      
        system.debug('mainstr before-'+mainstr);
        Pattern p = Pattern.compile('\\{!.+?\\}');
        Matcher m = p.matcher(mainstr);
        String mainfields;
        Set<String> mainfieldsList = new Set<String>();
        while(m.find()) {
            System.debug(m.group(0));
            String strReplace = '{!'+mainObject+'.';
            String str = m.group(0).replace(strReplace,'').replace('}',', ');
            String str1 = str.replace(',','');
            mainfieldsList.add(str1);
            
        }
        
        System.debug('mainfieldsList ' + mainfieldsList);

        for(String str : mainfieldsList){
            if(mainfields==null){
                mainfields=str;
            }else{
                mainfields = mainfields+', '+str;  
            }
        }

        if(mainfields!=null){
            mainfields = mainfields.removeEnd(', ');
            System.debug('mainfields   '+ mainfields);
            string mainSOQL='Select '+String.escapeSingleQuotes(mainfields)+' from '+String.escapeSingleQuotes(mainObject)+' where Id= \'' + recordId + '\' WITH SECURITY_ENFORCED';
            System.debug('mainSOQL'+mainSOQL);
            sObject qrec=Database.query(mainSOQL);
            System.debug('returned soql'+qrec);
            Map<String, Object> mainMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qrec));
            System.debug('there are values'+mainMap.values());
            system.debug('JSON.serialize(qrec)'+JSON.serialize(qrec));
            
            
        for(Document_Template_Section__c sec: selectedTemplateContents){
                for(String str:mainfieldsList)
                {
                    str = str.replaceAll('(\\s+)', '');
                    system.debug('str---'+str);
                    system.debug('mainMap.keyset---'+mainMap.keyset());
                    if(mainMap.containskey(str))
                    {
                        System.debug(str);
                        string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                        sec.Section_Content__c=sec.Section_Content__c.replace(mergefieldsyntax, String.valueOf(mainMap.get(str)));
                    }else
                    {
                        system.debug('else'+ str);
                        String finalvalue;
                        if(str.contains('.')){
                            List<String> strList = new List<string>();
                            strList=str.split('\\.');
                            Map<String, Object> tempObj=new Map<String, Object>();
                            tempObj=mainMap;
                            String resVal; 
                            for(Integer j=0; j<strList.size(); j++){
                                if(tempObj.containskey(strList[j]))
                                {
                                    if(j==strList.size()-1)
                                    {
                                        finalvalue=String.valueOf(tempObj.get(strList[j]));
                                    }else
                                    {
                                        tempObj=(Map<String, Object>)tempObj.get(strList[j]);
                                        
                                    }
                                }
                            }
                        }
                        if(finalvalue!=null)
                        {
                            string mergefieldsyntax='{!'+mainObject+'.'+str+'}';
                            sec.Section_Content__c=sec.Section_Content__c.replace(mergefieldsyntax, finalvalue); 
                        }
                    }
                }
            }
        }
        return selectedTemplateContents;
    }
    
    public static String toTitleCase(String phrase){
        String titlePhrase = '';
        //a set of words that should always (or at least, almost always) be in lower case when in Title Case
        //eg The Day of the Jackal.  First and last word of a phrase should always be Capped though.
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
        return titlePhrase.trim();
    }
    
    @AuraEnabled
    public static List<FieldWrap> getFields(String selectedObject){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType ctype = gd.get(selectedObject); 
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();   
        List<FieldWrap> strList = new List<FieldWrap>();
        for(String fieldName: fmap.keySet()) {
            FieldWrap wmp = new FieldWrap();
            System.debug('this is the field name today'+fieldName+'----->'+fmap.get(fieldName).getDescribe());
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
        return strList;    
    }
    
    public class FieldWrap{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String apiName{get;set;}
        @AuraEnabled
        public String dataType{get;set;}
        @AuraEnabled
        public List<String> values{get;set;}
        @AuraEnabled
        public String sObjectName{get;set;}
        @AuraEnabled
        public String relationshipName{get;set;}
    }

/*    @AuraEnabled
    public static Account createTestButtonInsert(String accName){
        Account acc = new Account();
        acc.Name=accName;
        insert acc;
        return acc;
    }*/
    
}