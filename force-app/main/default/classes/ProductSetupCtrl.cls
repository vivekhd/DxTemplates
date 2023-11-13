public with sharing class ProductSetupCtrl {
    public static Safely safe = new Safely();

    @AuraEnabled
    public static List<Sobject> getLookupList(String searchText, String sObjectType){
        List<sObject> lookupValues;
        try {
            String searchInput = '%' + searchText + '%';
            String queryStr = 'select ID, Name From '+String.escapeSingleQuotes(sObjectType)+' WHERE Name Like :searchInput WITH SECURITY_ENFORCED';
            lookupValues = Database.query(queryStr);
            return lookupValues;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'ProductSetupCtrl.getLookupList()','sObjectType -> '+ sObjectType +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return lookupValues;
        }  
    }
    
    public class SafeClassException extends Exception{}    
}