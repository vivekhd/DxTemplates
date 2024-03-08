/**
* Class			    : PdfDisplay
* Developer			: 
* Created Date		: 
* @description  	:  A global utility class for handling PDF display functionality and retrieving object details.
*              This class includes methods to get details of a Salesforce record's object and retrieve the organization's domain URL.
* Last Modified Date: 
*/
global with sharing class PdfDisplay {
 
    /**
     * @description An inner class to encapsulate details about a Salesforce object.
     *              Contains fields for the object name and label.
     */
    @namespaceAccessible
    public class ObjectDetails {
        @AuraEnabled public String objectName;
        @AuraEnabled public String objectLabel;
        
	/**
         * @description Constructor to initialize ObjectDetails with object name and label.
         * @param name  String representing the object name.
         * @param label String representing the object label.
         */
        public ObjectDetails(String name, String label) {
            objectName = name;
            objectLabel = label;
        }
    }
    
	/**
     * @description Retrieves details about a Salesforce record's object.
     * @param recordId Salesforce record Id for which object details are required.
     * @return ObjectDetails instance containing the object name and label.
     */
    @AuraEnabled 
    public static ObjectDetails getObjectDetails(Id recordId) {   
        String objectName;
        String objectLabel;
        try{    
            objectName = recordId.getSObjectType().getDescribe().getName();
            objectLabel = recordId.getSObjectType().getDescribe().getLabel();
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'PdfDisplay.getObjectDetails()','recordId : '+recordId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }  
        return new ObjectDetails(objectName, objectLabel);
    }
    
	/**
     * @description Retrieves the organization's domain URL.
     * @return String representing the organization's domain URL.
     */
    @AuraEnabled
    public static String getDomainUrl() {
        return URL.getOrgDomainUrl().toExternalForm();
    }
    
}