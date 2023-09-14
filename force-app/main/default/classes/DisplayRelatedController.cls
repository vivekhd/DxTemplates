global class DisplayRelatedController {
    
    public String displayText{get;set;}
    
    public DisplayRelatedController()
    {
        Id documentid = apexpages.currentPage().getparameters().get('documentId');
        //Id documentid = 'a04DH000003t51yYAA';
        System.debug(documentid);
        Document__c docrec = [select Document_Body__c, Name from Document__c where id=:documentid];
        displayText = String.escapeSingleQuotes(docrec.Document_Body__c);
    }
}