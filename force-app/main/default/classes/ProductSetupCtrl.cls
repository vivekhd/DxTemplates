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
    
    @AuraEnabled
    public static List<DxTemplates_PDFLink__mdt> getPDFLinks(){
        List<DxTemplates_PDFLink__mdt> linkLst = [select Id,MasterLabel,DeveloperName, Section_PDF_URL__c from DxTemplates_PDFLink__mdt with USER_MODE ];
        return linkLst;
    }
    
    @AuraEnabled
    public static String getOriginalImageCVID(String contentVersionId) {
        ContentVersion cvData = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1]  ;
        return EncodingUtil.base64Encode(cvData.VersionData);
    }
    
    public class SafeClassException extends Exception{}    
}