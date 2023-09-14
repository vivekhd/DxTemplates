public with sharing class ProductSetupCtrl {
    public static Safely safe = new Safely();
    
    /*public class FieldSetMemberWrapperClass{
        @AuraEnabled
        public Boolean isDBRequired                      { get; set; }
        @AuraEnabled
        public Boolean isRequired                        { get; set; }
        @AuraEnabled
        public String fieldType                          { get; set; }
        @AuraEnabled
        public String fieldLabel                         { get; set; }
        @AuraEnabled
        public String fieldAPIName                       { get; set; }
        @AuraEnabled
        public List<Schema.PicklistEntry> pickListValues { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }*/

    @AuraEnabled
    public static List<Sobject> getLookupList(String searchText, String sObjectType){
        try {

            String searchInput = '%' + searchText + '%';
            String queryStr = 'select ID, Name From '+String.escapeSingleQuotes(sObjectType)+' WHERE Name Like :searchInput WITH SECURITY_ENFORCED';
            List<sObject> lookupValues=Database.query(queryStr);
            return lookupValues;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'ProductSetupCtrl.getLookupList()','sObjectType -> '+ sObjectType +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }  
    }
    
    public class SafeClassException extends Exception{
    }
    
}