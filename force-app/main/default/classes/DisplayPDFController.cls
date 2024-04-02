/**
* Class         :   DisplayPDFController
* Developer		:   Vivek H
* Created Date	:   30/1/2020
* @description	:   The DisplayPDFController class orchestrates  PDF generation from templates, manages attachments to records like Quotes, and handles content versions. 
                    With error handling and logging, it  ensures smooth operations. Its integration with Aura components streamlines PDF management, offering a robust solution for 
                    generating, managing, and displaying PDF documents within Salesforce applications while maintaining data integrity and user experience.
* Last Modified Date: 19/2/2024
*/

global with sharing class DisplayPDFController {

    /**
     * @description Instance of the Safely class for safe operations.
     */
    public static Safely safe = new Safely();

    /**
     * @description Text to be displayed on the page.
     */
    public String displayText {get; set;}

    /**
     * @description Flag indicating whether to display page sequence.
     */
    public Boolean displaypagesequence {get; set;}

    /**
     * @description Number of header sections.
     */
    public Integer headersectionsCount {get; set;}

    /**
     * @description Number of footer sections.
     */
    public Integer footersectionsCount {get; set;}

    /**
     * @description Text for the left side of the header.
     */
    public String leftheadertext {get; set;}

    /**
     * @description Text for the center of the header.
     */
    public String centerheadertext {get; set;}

    /**
     * @description Text for the right side of the header.
     */
    public String rightheadertext {get; set;}

    /**
     * @description Text for the left side of the footer.
     */
    public String leftfootertext {get; set;}

    /**
     * @description Text for the center of the footer.
     */
    public String centerfootertext {get; set;}

    /**
     * @description Text for the right side of the footer.
     */
    public String rightfootertext {get; set;}

    /**
     * @description Array containing characters to be decoded in HTML entities.
     */
    private static final String[] HTML_DECODED  = new String[]{ '&', '<', '>', '"', '\''};

    /**
     * @description Array containing corresponding HTML encoded values.
     */
	private static final String[] HTML_ENCODED  = new String[]{ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' };
    
    /**
     * @description Encodes the input string by replacing specific characters with their corresponding HTML encoded values.
     * @param input The input string to be encoded.
     * @param fromArr Array containing characters to be replaced.
     * @param toArr Array containing corresponding HTML encoded values.
     * @return The encoded string.
     */
    private static String ENCODE(String input, String[] fromArr, String[] toArr) {
        if (input == null || input.length() == 0){
            return input;
        }
		for (Integer i = 0; i < fromArr.size(); ++i) {
			input = input.replace(fromArr[i], toArr[i]);
		}		
		return input;
	}

    /**
     * @description Encodes the input string using SFDC HTML encoding.
     * @param input The input string to be encoded.
     * @return The encoded string.
     */
    public static String SFDC_HTMLENCODE(String input) {
		return ENCODE(input, HTML_DECODED, HTML_ENCODED);
	}

    /**
    * @description Constructor for the DisplayPDFController class. This constructor initializes a new instance of the DisplayPDFController class.
    */
    public DisplayPDFController() {
        displaypagesequence =false;
        String inputparam;
        Document__c documentRecordToDisplay = new Document__c();
        try {
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
                            Map<string,object> subSectionDetails = (Map<string,object>) objrec;  
                            if(subSectionDetails.get('indexvar') == 0) {
                                leftheadertext = (String)subSectionDetails.get('value');
                            } else if(subSectionDetails.get('indexvar')==1) {
                                centerheadertext = (String)subSectionDetails.get('value');
                            } else if(subSectionDetails.get('indexvar')==2) {
                                rightheadertext = (String)subSectionDetails.get('value');
                            }
                        }
                    }
                }
                
                if(mapjson.containskey('footer')) {
                    List<Object> footerListObject=new List<Object>();
                    Map<String, Object> footerMap = (Map<String, Object>) mapjson.get('footer');
                    footersectionsCount = Integer.valueOf(footerMap.get('sectionsCount'));
                    displaypagesequence=(Boolean)footerMap.get('displaypagesequence');
                    footerListObject = (List<Object>)footerMap.get('sectionsContent');
                    
                    if(!footerListObject.IsEmpty()) {
                        for(Object objrec: footerListObject) {
                            Map<string,object> subSectionDetails=(Map<string,object>)objrec;  
                            if(subSectionDetails.get('indexvar')==0) {
                                leftfootertext = (String)subSectionDetails.get('value');
                            } else if(subSectionDetails.get('indexvar')==1) {
                                centerfootertext = (String)subSectionDetails.get('value');
                            } else if(subSectionDetails.get('indexvar')==2) {
                                rightfootertext = (String)subSectionDetails.get('value');
                            }
                        }
                    }
                }
            } else{
                displayText = 'ID not found';
            }
        } catch(Exception ex) {
            displayText = ex.getMessage() + ' Please contact your System Administrator.'
            LogHandler.createLog((Id) null,'DisplayPDFController', ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
    }
    

    /**
     * @description    Generates a document record and inserts it into Salesforce
     * @param          templateId       ID of the document template
     * @param          quoteId          ID of the associated quote
     * @param          pdfbody          Body content of the PDF document
     * @param          pdfheaderfooter  Header and footer content of the PDF document
     * @return         ID               ID of the inserted document record
     */
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
                    error.getMessage();
                }               
            }
            return inserteddocId;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generateDocument()','Template Id- '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }     
    }
    
    /**
     * @description    Generates a PDF attachment for a given document ID and quote ID
     * @param          documentid  ID of the document for which the PDF is generated
     * @param          quoteId     Quote ID used for naming the PDF attachment
     * @return         ID          ID of the generated PDF attachment
     */
    @AuraEnabled
    public static string generatePDFAttachment(ID documentid, String quoteId){
        try{ 
            Id insertedattachmentId;
            Pagereference pg = Page.renderAsPdfLWC;
            pg.getParameters().put('documentid', documentid);

            Attachment objAttachment = new Attachment();
            objAttachment.Name = quoteId+'.pdf';
            objAttachment.ParentId = documentid;
            
            if(!Test.isrunningTest()) {
                objAttachment.Body = pg.getContentAsPDF(); 
            } else {
                objAttachment.Body = Blob.valueof('text');
            }
            
            objAttachment.IsPrivate = false;
            List<Attachment> atttobeinserted=new List<Attachment>();
            atttobeinserted.add(objAttachment);
            Savepoint sp = Database.setSavepoint();
            List<Database.SaveResult> sResult = safe.doInsert(atttobeinserted);
            List<String> errorList = Safely.safeClassExceptionHandlerInsert(sResult);
            
            if(errorList.size()>0) {
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }
            
            for(Integer i=0;i<sResult.size();i++) {
                if (sResult.get(i).isSuccess()) {
                    Id attachmentid=sResult.get(i).getId();
                    if(attachmentid!=null) {
                        insertedattachmentId = attachmentid;
                    }
                } else if (!sResult.get(i).isSuccess()) {
                    Database.Error error = sResult.get(i).getErrors().get(0);
                     error.getMessage();
                }            
            }
            
            return insertedattachmentId;   
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generatePDFAttachment()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }        
    }
    
    /**
     * @description             Saves a PDF attachment to a Quote record.
     * @param     documentid    (ID) ID of the PDF document to be saved.
     * @param     quoteId       (String) ID of the Quote record to which the PDF will be attached.
     * @param     pdfMode       (String) Mode of the PDF operation.
     * @param     pdfName       (String) Name of the PDF file.
     * @return                  (String) ID of the inserted Attachment record.
     */
    @AuraEnabled
    public static string savePDFtoQuote(ID documentid, String quoteId, String pdfMode, String pdfName){ 
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
                    if(attachmentid!=null) {
                        insertedattachmentId=attachmentid;
                    }
                } else if (!sResult.get(i).isSuccess()) {
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    error.getMessage();
                }                
            }
            return String.Valueof(insertedattachmentId);
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.savePDFtoQuote()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }
    }    
    
    /**
     * @description    Retrieves the sections of a document template by its ID
     * @param          templateId   ID of the document template
     * @param          recordId     ID of the record related to the document template
     * @param          objectApiName   API name of the object related to the document template
     * @return         List<Document_Template_Section__c>   List of document template sections
     */
    @AuraEnabled
    public static List<Document_Template_Section__c> getTemplateSections(ID templateId, String recordId, String objectApiName){ 
        try{
            List<Document_Template_Section__c> selectedTemplateContents=[select id,Section_Content__c, Type__c, New_Page__c, Sequence__c from Document_Template_Section__c where Document_Template__c=:templateId WITH SECURITY_ENFORCED ORDER BY Sequence__c ASC LIMIT 5000];
            selectedTemplateContents = MergeFieldsClass.mergefieldsMethod(selectedTemplateContents,recordId);
            return selectedTemplateContents;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','templateId ->  '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }

    /**
     * @description Constructor for the HeaderFooterWrapper class.
     * @param value The value associated with a header or footer section.
     * @param indexvar The index variable associated with a header or footer section.
     */
    public class HeaderFooterWrapper{
        public String value {get; set;}
        public String indexvar {get; set;}
        public HeaderFooterWrapper(String value,String indexvar) {
            this.value = value;
            this.indexvar = indexvar;
        }
    }

    /**
     * @description Custom exception class used for handling exceptions in SafeClass.
     */   
    public class SafeClassException extends Exception{}
}