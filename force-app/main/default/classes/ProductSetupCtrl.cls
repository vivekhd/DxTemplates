/**
* Class			    : ProductSetupCtrl
* Developer			: 
* Created Date		: 
* @description		: Apex controller class named ProductSetupCtrl.
*              This class contains methods related to product setup functionality and is designed to be used with Lightning components.
* Last Modified Date: 
*/
public with sharing class ProductSetupCtrl {
    public static Safely safe = new Safely();

	/**
     * @description AuraEnabled method to retrieve a list of lookup values based on the search text and the specified SObject type.
     * @param searchText - The text used for searching lookup values.
     * @param sObjectType - The API name of the SObject for which lookup values are to be retrieved.
     * @return List of SObjects representing lookup values matching the search criteria.
     */
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

    /**
     * @description AuraEnabled method to retrieve web links for user documentation.
     * @return list of metadata records for helplinks
     */
    @AuraEnabled
    public static List<DxTemplates_PDFLink__mdt> getPDFLinks(){
        List<DxTemplates_PDFLink__mdt> linkLst = [select Id,MasterLabel,DeveloperName, Section_PDF_URL__c from DxTemplates_PDFLink__mdt with USER_MODE ];
        return linkLst;
    }
    
    /**
     * @description method to retrieve the content data for a given contentversion id.
     * @return String - base64 data of the requested image
     */
    @AuraEnabled
    public static String getOriginalImageCVID(String contentVersionId) {
        ContentVersion cvData = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1]  ;
        return EncodingUtil.base64Encode(cvData.VersionData);
    }
    
    public class SafeClassException extends Exception{}    
}