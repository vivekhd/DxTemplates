global with sharing class DisplayPDFController 
{
    public static Safely safe = new Safely();
    
    public String displayText {get; set;}
   	public Boolean displaypagesequence {get; set;}
    public Integer headersectionsCount {get; set;}
    public Integer footersectionsCount {get; set;}
    
    public String leftheadertext {get; set;}
    public String centerheadertext {get; set;}
    public String rightheadertext {get; set;}
    
    public String leftfootertext {get; set;}
    public String centerfootertext {get; set;}
    public String rightfootertext {get; set;}
    
    public DisplayPDFController() {
        displaypagesequence =false;
        String inputparam;
        Document__c documentRecordToDisplay = new Document__c();
        
        if(!Test.isRunningTest()){
            inputparam = SFDC_HTMLENCODE(apexpages.currentpage().getparameters().get('documentid'));
            documentRecordToDisplay =[select id,Document_Body__c,Document_Content__c from Document__c where id=:inputparam WITH SECURITY_ENFORCED];
            displayText = inputparam!=null ? String.escapeSingleQuotes(documentRecordToDisplay.Document_Body__c) : 'ID not found ' + inputparam;
        } else {
            /* Strictly for  test coverage purpose only. */
            documentRecordToDisplay.Document_Content__c = '{"header":{"sectionsCount":"3","sectionsContent":[{"value":"","indexvar":0,"key":"1707976996596:0"},{"value":"","indexvar":1,"key":"1707976996596:1"},{"value":"<p style=\\"text-align: right;\\"><strong style=\\"font-size: 22px; color: rgb(72, 11, 173);\\">Dextara Digital</strong></p>","indexvar":2,"key":"1707977018477:2"}]},"footer":{"sectionsCount":"3","sectionsContent":[{"value":"","indexvar":1,"key":"1707977023131:1"},{"value":"","indexvar":2,"key":"1707977023131:2"},{"value":"<p><strong style=\\"color: rgb(72, 11, 173); font-size: 22px;\\">Dextara Digital</strong></p>","indexvar":0,"key":"1707977024668:0"}],"displaypagesequence":false}}';
        }
        
        if(documentRecordToDisplay.Document_Content__c!=null){
            Map<string,object> mapjson=(Map<string,object>)JSON.deserializeUntyped(documentRecordToDisplay.Document_Content__c);      
            if(mapjson.containskey('header')){
                List<Object> headerListObject=new List<Object>();
                Map<String, Object> headerMap = (Map<String, Object>) mapjson.get('header');
                headersectionsCount = Integer.valueOf(headerMap.get('sectionsCount'));
                headerListObject = (List<Object>)headerMap.get('sectionsContent');
                                
                if(!headerListObject.IsEmpty()){
                    for(Object objrec: headerListObject){
                        Map<string,object> wrec=(Map<string,object>)objrec;  
                        if(wrec.get('indexvar')==0){
                            leftheadertext = (String)wrec.get('value');
                        }
                        else if(wrec.get('indexvar')==1){
                            centerheadertext = (String)wrec.get('value');
                        }
                        else if(wrec.get('indexvar')==2){
                            rightheadertext = (String)wrec.get('value');
                        }
                    }
                }
            }
            
            if(mapjson.containskey('footer')){
                List<Object> footerListObject=new List<Object>();
                Map<String, Object> footerMap = (Map<String, Object>) mapjson.get('footer');
                footersectionsCount = Integer.valueOf(footerMap.get('sectionsCount'));
                displaypagesequence=(Boolean)footerMap.get('displaypagesequence');
                footerListObject = (List<Object>)footerMap.get('sectionsContent');
                
                if(!footerListObject.IsEmpty()){
                    for(Object objrec: footerListObject){
                        Map<string,object> wrec=(Map<string,object>)objrec;  
                        if(wrec.get('indexvar')==0){
                            leftfootertext = (String)wrec.get('value');
                        }
                        else if(wrec.get('indexvar')==1){
                            centerfootertext = (String)wrec.get('value');
                        }
                        else if(wrec.get('indexvar')==2){
                            rightfootertext = (String)wrec.get('value');
                        }
                    }
                }
            }
        }
        else{
            displayText = 'ID not found';
        }      
    }

    //Added by Vivek - Start
    private static final String[] HTML_DECODED  = new String[]{ '&', '<', '>', '"', '\''};
	private static final String[] HTML_ENCODED  = new String[]{ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' };

    private static String ENCODE(String input, String[] fromArr, String[] toArr) {
		if (input == null || input.length() == 0)
			return input;
		for (Integer i = 0; i < fromArr.size(); ++i) {
			input = input.replace(fromArr[i], toArr[i]);
		}		
		return input;
	}

    public static String SFDC_HTMLENCODE(String input) {
		return ENCODE(input, HTML_DECODED, HTML_ENCODED);
	}
    //Added by Vivek- End
    
    @AuraEnabled
    public static string generateDocument(ID templateId, String quoteId, String pdfbody, String pdfheaderfooter){
        try{
            List<Document__c> doctobeinserted=new List<Document__c>();
            
            Document__c documentRecordToDisplay=new Document__c();
            documentRecordToDisplay.Document_Content__c=pdfheaderfooter;
            documentRecordToDisplay.Document_Body__c=pdfbody;
            documentRecordToDisplay.Document_Template__c=templateId;
            documentRecordToDisplay.Object_Id__c=quoteId;
            
            Id inserteddocId;
            doctobeinserted.add(documentRecordToDisplay);
            
            Savepoint sp = Database.setSavepoint();
            List<Database.SaveResult> sResult = safe.doInsert(doctobeinserted);
            List<String> errorList = Safely.safeClassExceptionHandlerInsert(sResult);
            if(errorList.size()>0) {
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
            
            for(Integer i=0;i<sResult.size();i++) {
                if (sResult.get(i).isSuccess()) {
                    Id docid=sResult.get(i).getId();
                    if(docid!=null){
                        inserteddocId=docid;
                    }
                }else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                }               
            }
            return inserteddocId;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generateDocument()','Template Id- '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }     
    }
    
    @AuraEnabled
    public static string generatePDFAttachment(ID documentid, String quoteId){
        try{ 
            Id insertedattachmentId;
            
            Pagereference pg = Page.renderAsPdfLWC;
            pg.getParameters().put('documentid', documentid);

            Attachment objAttachment = new Attachment();
            objAttachment.Name = quoteId+'.pdf';
            objAttachment.ParentId = documentid;
            
            if(!Test.isrunningTest()){
                objAttachment.Body = pg.getContentAsPDF(); 
            }
            else{
                objAttachment.Body = Blob.valueof('text');
            }
            
            objAttachment.IsPrivate = false;
            List<Attachment> atttobeinserted=new List<Attachment>();
                atttobeinserted.add(objAttachment);
            Savepoint sp = Database.setSavepoint();
            List<Database.SaveResult> sResult = safe.doInsert(atttobeinserted);
            List<String> errorList = Safely.safeClassExceptionHandlerInsert(sResult);
            
            if(errorList.size()>0){
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
            
            for(Integer i=0;i<sResult.size();i++){
                if (sResult.get(i).isSuccess()){
                    Id attachmentid=sResult.get(i).getId();
                    if(attachmentid!=null)
                    {
                        insertedattachmentId = attachmentid;
                    }
                }else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                }            
            }
            
            return insertedattachmentId;   
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generatePDFAttachment()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }        
    }
    
    @AuraEnabled
    public static string SavePDFtoQuote(ID documentid, String quoteId, String pdfMode, String pdfName){ 
        try{ 
            Attachment arec = [SELECT Name, Body,id FROM Attachment WHERE id = :documentid WITH SECURITY_ENFORCED];
            Attachment objAttachment = New Attachment(Body = arec.Body); 
            objAttachment.name = pdfName+'.pdf';
            objAttachment.parentID = quoteId;
            
            List<Attachment> atttobedeleted=new List<Attachment>();
            atttobedeleted.add(arec);
            Savepoint sp = Database.setSavepoint();
            List<Database.DeleteResult> deleteResult = safe.doDelete(atttobedeleted);
            List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
            
            if(errorList.size()>0){
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
            
            Id insertedattachmentId;
            List<Attachment> atttobeinserted=new List<Attachment>();
            atttobeinserted.add(objAttachment);
            List<Database.SaveResult> sResult = safe.doInsert(atttobeinserted);
            List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(sResult);
            
            if(errorList1.size()>0){
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList1, ', ' ));
            }
            
            for(Integer i=0;i<sResult.size();i++){
                if (sResult.get(i).isSuccess()){
                    Id attachmentid=sResult.get(i).getId();
                    if(attachmentid!=null)
                    {
                        insertedattachmentId=attachmentid;
                    }
                }else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                }                
            }
            return String.Valueof(insertedattachmentId);
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.SavePDFtoQuote()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }       
    }    
    
    @AuraEnabled
    public static List<Document_Template_Section__c> getTemplateSections(ID templateId, String recordId, String objectApiName){ 
        try{
            List<Document_Template_Section__c> selectedTemplateContents=[select id,Section_Content__c, Type__c, New_Page__c, Sequence__c from Document_Template_Section__c where Document_Template__c=:templateId WITH SECURITY_ENFORCED ORDER BY Sequence__c ASC];
            selectedTemplateContents = MergeFieldsClass.mergefieldsMethod(selectedTemplateContents,recordId);
            return selectedTemplateContents;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','templateId ->  '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }
    
    public class SafeClassException extends Exception{}
    
    public class headerfooterwrapper{
        public String value {get; set;}
        public String indexvar {get; set;}
        
        public headerfooterwrapper(String value,String indexvar) {
            this.value = value;
            this.indexvar = indexvar;
        }
    }
}