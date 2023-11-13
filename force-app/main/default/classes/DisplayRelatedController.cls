public with sharing class DisplayRelatedController {
    
    public String displayText{  get;  set;  }
    
    public DisplayRelatedController() {
        Id documentid;
        try{
            documentid = apexpages.currentPage().getparameters().get('documentId');
            String query = 'Select Document_Body__c, Name from Document__c where id = \'' + documentid + '\' limit 1';
            Document__c docrec = Database.query(query);
            displayText = String.escapeSingleQuotes(docrec.Document_Body__c);
        }
        catch(Exception ex){
            LogHandler.createLog((Id) null,'DisplayRelatedController','Document Record Id- '+ documentid +' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
    }
}