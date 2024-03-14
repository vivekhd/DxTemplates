global with sharing class PdfDisplay {
    @namespaceAccessible
    public class ObjectDetails {
        @AuraEnabled public String objectName;
        @AuraEnabled public String objectLabel;
        
        public ObjectDetails(String name, String label) {
            objectName = name;
            objectLabel = label;
        }
    }
    
    @AuraEnabled 
    public static ObjectDetails getObjectDetails(Id recordId) {   
        String objectName;
        String objectLabel;
        try{    
            objectName = recordId.getSObjectType().getDescribe().getName();
            objectLabel = recordId.getSObjectType().getDescribe().getLabel();
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'PdfDisplay.getObjectDetails()','recordId -> '+recordId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }  
        return new ObjectDetails(objectName, objectLabel);
    }
    
    @AuraEnabled
    public static String getDomainUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
}