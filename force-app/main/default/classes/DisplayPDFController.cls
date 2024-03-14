/* The DisplayPDFController class orchestrates 
 * PDF generation from templates, manages attachments
 * to records like Quotes, and handles content versions. 
 * With error handling and logging, it 
 * ensures smooth operations. Its integration with Aura components 
 * streamlines PDF management, offering a robust solution for 
 * generating, managing, and displaying PDF documents within 
 * Salesforce applications while maintaining data integrity and user experience.
 */


/**
 * @description Represents the DisplayPDFController class, which is a global class with sharing.
 *              This class provides functionality related to displaying PDF files.
 */
global with sharing class DisplayPDFController 
{
    /**
     * @description Instance of the Safely class for safe operations.
     */
    public static Safely safe = new Safely();
    
    /**
     * @description URL of the image to be displayed.
     */
    public String imageURL {get; set;}
    
    /**
     * @description Flag indicating whether to display all pages.
     */
    public Boolean showAllPages {get; set;}
    
    /**
     * @description Flag indicating whether to use default CSS styles.
     */
    public Boolean defaultCSS {get; set;}
    
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
     * @description Size of the page.
     */
    public static String pageSize {get;set;}
    /**
     * @description Array containing characters to be decoded in HTML entities.
     */
    private static final String[] html_DECODED  = new String[]{ '&', '<', '>', '"', '\''};
    /**
     * @description Array containing corresponding HTML encoded values.
     */
	private static final String[] html_ENCODED  = new String[]{ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' };
    

    /**
    * @description Constructor for the DisplayPDFController class.
    *              This constructor initializes a new instance of the DisplayPDFController class.
    */
    public DisplayPDFController() {
        try {
            showAllPages =  true;
            displaypagesequence = false;
            String inputparam = ApexPages.currentPage().getParameters().get('documentid');
            inputparam = String.escapeSingleQuotes(inputparam);
            Document__c docrec = [SELECT Id, Document_Body__c, Document_Content__c, Document_Template__r.Watermark_Data__c  
                                  FROM Document__c 
                                  WHERE Id = :inputparam WITH SECURITY_ENFORCED];
            if (docrec.Document_Template__r.Watermark_Data__c != null) {
                String inputStr =  docrec.Document_Template__r.Watermark_Data__c;
                String contentVersionID;
                String pageOption;
                
                List<Object> jsonObjectList = (List<Object>) JSON.deserializeUntyped(inputStr);
                
                for (Object obj : jsonObjectList) {
                    Map<String, Object> jsonObject = (Map<String, Object>) obj;
                    if (jsonObject.get('isPrimary') != null && (Boolean) jsonObject.get('isPrimary')) {
                        contentVersionID = (String) jsonObject.get('contentVersionID');
                        pageOption = (String) jsonObject.get('pageOption');
                        pageOption = pageOption.substring(0, pageOption.indexOf(' - '));
                    }
                }
                System.debug('pageOption >> '+ pageOption);
                if(pageOption == 'All Pages'){
                    showAllPages = true;
                } else {
                    showAllPages = false;
                }
                deFaultCSS = false;
                imageURL = getSFDomainBaseURL() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=' + contentVersionID; 
            }
            else{
                showAllPages = false;
                defaultCSS = true;  
            } 
            if(inputparam != null){
                displayText = String.escapeSingleQuotes(docrec.Document_Body__c).replace('\\', '');        
            } else {
                displayText = 'ID not found ' + inputparam;
            }
            
            if(docrec.Document_Content__c != null){
                Map<String, Object> mapjson = (Map<String, Object>) JSON.deserializeUntyped(docrec.Document_Content__c);      
                if(mapjson.containsKey('header')){
                    List<Object> headerListObject = new List<Object>();
                    Map<String, Object> headerMap = (Map<String, Object>) mapjson.get('header');
                    headersectionsCount = Integer.valueOf(headerMap.get('sectionsCount'));
                    headerListObject = (List<Object>) headerMap.get('sectionsContent');

                    if(!headerListObject.isEmpty()){
                        for(Object objrec : headerListObject){
                            Map<String, Object> wrec = (Map<String, Object>) objrec;  
                            if(wrec.get('indexvar') == 0){
                                leftheadertext = (String) wrec.get('value');
                            } else if(wrec.get('indexvar') == 1){
                                centerheadertext = (String) wrec.get('value');
                            } else if(wrec.get('indexvar') == 2){
                                rightheadertext = (String) wrec.get('value');
                            }
                        }
                    }
                }

                if(mapjson.containsKey('footer')){
                    List<Object> footerListObject = new List<Object>();
                    Map<String, Object> footerMap = (Map<String, Object>) mapjson.get('footer');
                    footersectionsCount = Integer.valueOf(footerMap.get('sectionsCount'));
                    displaypagesequence = (Boolean) footerMap.get('displaypagesequence');
                    footerListObject = (List<Object>) footerMap.get('sectionsContent');
                    
                    if(!footerListObject.isEmpty()){
                        for(Object objrec : footerListObject){
                            Map<String, Object> wrec = (Map<String, Object>) objrec;  
                            if(wrec.get('indexvar') == 0){
                                leftfootertext = (String) wrec.get('value');
                            } else if(wrec.get('indexvar') == 1){
                                centerfootertext = (String) wrec.get('value');
                            } else if(wrec.get('indexvar') == 2){
                                rightfootertext = (String) wrec.get('value');
                            }
                        }
                    }
                }
            } else {
                displayText = 'ID not found';
            }      
        } catch(Exception ex) {
             LogHandler.createLog((Id) null,'DisplayPDFController.DisplayPDFController() - Constructor','Template Id-  '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //Added by Vivek - Start
        
        /**
     * @description Encodes the input string by replacing specific characters with their corresponding HTML encoded values.
     * @param input The input string to be encoded.
     * @param fromArr Array containing characters to be replaced.
     * @param toArr Array containing corresponding HTML encoded values.
     * @return The encoded string.
     */
    private String encode(String input, String[] fromArr, String[] toArr) {
        if (input == null || input.length() == 0){ return input; }

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
    public String SFDC_HTMLENCODE(String input) {
		return encode(input, html_DECODED, html_ENCODED);
	}
    //Added by Vivek- End
    
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
            
            Document__c docrec=new Document__c();
            docrec.Document_Content__c=pdfheaderfooter;
            docrec.Document_Body__c=pdfbody;
            docrec.Document_Template__c=templateId;
            docrec.Object_Id__c=quoteId;
            
            Id inserteddocId;
            doctobeinserted.add(docrec);
            
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
                    LogHandler.createLog((Id) null,'DisplayPDFController.generateDocument()','Template Id- '+templateId+' '+'Database Error while saving the result --> ',String.valueof(error),'Exception');
                }               
            }
            return inserteddocId;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generateDocument()','Template Id- '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
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
                    LogHandler.createLog((Id) null,'DisplayPDFController.generatePDFAttachment()','documentid ->  '+documentid+' '+'Database Error while saving the result --> ',String.valueof(error),'Exception');
                }            
            }
            
            return insertedattachmentId;   
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generatePDFAttachment()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
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
                    if(attachmentid!=null)
                    {
                        insertedattachmentId=attachmentid;
                    }
                }else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    LogHandler.createLog((Id) null,'DisplayPDFController.savePDFtoQuote()','documentid ->  '+documentid+' '+'Database Error while saving the result --> ',String.valueof(error),'Exception');
                }                
            }
            return String.Valueof(insertedattachmentId);
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.savePDFtoQuote()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
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
            List<Document_Template_Section__c> selectedTemplateContents=[select id,Section_Content__c, Type__c, New_Page__c, Sequence__c from Document_Template_Section__c where Document_Template__c=:templateId WITH SECURITY_ENFORCED ORDER BY Sequence__c ASC];
            selectedTemplateContents = MergeFieldsClass.mergefieldsMethod(selectedTemplateContents,recordId);
            return selectedTemplateContents;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','templateId ->  '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }  
    }
       
    //getting the template sections for the Multiple recordIds

    @AuraEnabled
    public static List<Document_Template_Section__c> getTemplateSectionsMulRecords(ID templateId, List<String> recordIdLst, String objectApiName){ 
        try{
            List<Document_Template_Section__c> selectedTemplateContents=[select id,Section_Content__c, Type__c, New_Page__c, Sequence__c from Document_Template_Section__c where Document_Template__c=:templateId WITH SECURITY_ENFORCED ORDER BY Sequence__c ASC];
            selectedTemplateContents = MergeFieldsClass.mergefieldsMethodMultiple(selectedTemplateContents,recordIdLst);
            return selectedTemplateContents;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','templateId ->  '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }  
    }
        
    /**
     * @description    Retrieves the PDF mode based on the provided wrapper data
     * @param          wrapperdata Map containing wrapper data with key-value pairs
     * @return         String PDF mode retrieved from the wrapper data
     */
    @AuraEnabled
    public static string pdfMode(Map<String,String> wrapperdata){
        try {
            String pageSize = wrapperdata.get('pdfModes1');
            DisplayPDFController.setName();
            return pageSize;
        } catch(Exception ex) {
             LogHandler.createLog((Id) null,'DisplayPDFController.pdfMode()','Wrapper data - '+wrapperdata+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
     * @description    Retrieves a string containing the page size
     * @return         String A string containing the page size
     */
    @AuraEnabled
    public static string setName() {
        try {
            String pageSize = 'pageSize'; 
            return 'pageSize' + pageSize;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
     * @description    Retrieves the object name associated with a PDF by its ID
     * @param          id  String ID of the PDF
     * @return         String Object name associated with the PDF
     */
    @AuraEnabled
    public static string pdfObjectName(string id){
        try {
            return 'ObjectName is Returned';
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
     * @description    Property to store PDF modes 
     */
    @AuraEnabled
    public String pdfModes1 { get; set; }
    
    /**
     * @description Custom exception class used for handling exceptions in SafeClass.
     */    
    public class SafeClassException extends Exception{}
    
    /**
     * @description Wrapper class for header and footer values
     */
    public class HeaderFooterWrapper {
		/**
         * @description Represents a value associated with a header or footer section.
         */
        public String value { get; set; } 
        
        /**
         * @description Represents the index variable associated with a header or footer section.
         */
        public String indexvar { get; set; } 
        
        /**
         * @description Constructor for the HeaderFooterWrapper class.
         * @param value The value associated with a header or footer section.
         * @param indexvar The index variable associated with a header or footer section.
         */
        public HeaderFooterWrapper(String value, String indexvar) {
            this.value = value;
            this.indexvar = indexvar;
        }
    }
    
    /**
     * @description    Retrieves a list of Opportunities created within the last 30 days
     * @return         List<Opportunity> List of Opportunities
     */
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        try {
            List<Opportunity> opportunities = [SELECT Amount, Name, StageName 
                                               FROM Opportunity 
                                               WHERE CreatedDate = LAST_N_DAYS:30 WITH USER_MODE];
            return opportunities;
        } catch(Exception ex) {
             LogHandler.createLog((Id) null,'DisplayPDFController.getOpportunities()','Template Id- '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }
    }
     
    /**
     * @description    Saves content versions (text or image) to Salesforce as ContentVersion records
     * @param          title           Title of the content version
     * @param          base64DataList List of maps containing base64-encoded data and record types (text or image)
     * @param          templateId      Id of the document template where the content versions should be associated
     * @return         List<Map<String, String>> List of maps containing saved record types and their corresponding Ids
     */
   @AuraEnabled(cacheable=false)
public static List<Map<String, String>> saveContentVersion(String title, List<Map<String, String>> base64DataList, String templateId, Boolean wtImage) {
    try {
        
        List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>(); 
        List<Map<String, String>> savedIds = new List<Map<String, String>>();
        List<Id> contentVersionIdsToDelete = new List<Id>();
        if(wtImage){
            for (ContentVersion cv : [SELECT Id, ContentDocumentId  FROM ContentVersion WHERE FirstPublishLocationId = :templateId  WITH USER_MODE]) {
                contentVersionIdsToDelete.add(cv.ContentDocumentId);
            }
        }
        else{
            for (ContentVersion cv : [SELECT Id, ContentDocumentId  FROM ContentVersion WHERE FirstPublishLocationId = :templateId and Title != 'OriginalImg' WITH USER_MODE]) {
                contentVersionIdsToDelete.add(cv.ContentDocumentId);
            } 
        }
        
        List<Id> contentDocumentIdsToDelete = new List<Id>();
        List<ContentDocument> cdlst = [SELECT Id FROM ContentDocument WHERE Id IN :contentVersionIdsToDelete WITH USER_MODE];
        if (!cdlst.isEmpty()) {
            delete cdlst;
        }
        for(Map<String, String> dataUrl : base64DataList) {
            String recordType = dataUrl.keySet().iterator().next();
            String data = dataUrl.get(recordType);
            
            if(recordType.equalsIgnoreCase('Text') || recordType.equalsIgnoreCase('Image') || recordType.equalsIgnoreCase('OriginalImg')) {
                ContentVersion contentVersion = new ContentVersion(
                    Title = dataUrl.get('title'),
                    VersionData = EncodingUtil.base64Decode(data),
                    PathOnClient = title + '.png',
                    FirstPublishLocationId = templateId
                );
                
                contentVersionsToInsert.add(contentVersion);
            }
        }
         if (Schema.sObjectType.ContentVersion.isCreateable()) {
            insert contentVersionsToInsert;
            for(ContentVersion contentVersion : contentVersionsToInsert) {
                Map<String, String> savedId = new Map<String, String>();
                savedId.put(contentVersion.Title, contentVersion.Id);
                savedIds.add(savedId);
            }
             return savedIds;
         }
        else{
            LogHandler.createLog((Id) null,'DisplayPDFController.saveContentVersion()','Insufficient permissions to create ContentVersion records. ','Insufficient permissions to create ContentVersion records.', 'Insufficient permissions');
        }
       
    } catch(Exception ex) {
         LogHandler.createLog((Id) null,'DisplayPDFController.saveContentVersion()','Failed to create the Contentversion records '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Failed to create the Contentversion records');  
    }
}
    
    
    
    /**
    * @description    Retrieves the base URL of the Salesforce domain
    * @return         String Base URL of the Salesforce domain
    */
    @AuraEnabled(cacheable=false)
    public static String getSFDomainBaseURL() {
        try {
            String baseURL = URL.getOrgDomainURL().toExternalForm();
            return baseURL;
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getSFDomainBaseURL()','Template Id- '+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
   /**
     * @description   					Retrieves data of a document template by its ID
     * @param 			templateId 		String ID of the document template
     * @return           				Document_Template__c
     */
    @AuraEnabled
    public static Document_Template__c getDocumentTemplateData(String templateId) {
        try {
            Document_Template__c dtData = [SELECT Id, Watermark_Data__c FROM Document_Template__c  
                                           WHERE Id = :templateId WITH USER_MODE LIMIT 1];
            return dtData;
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getDocumentTemplateData()','Template Id- '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}