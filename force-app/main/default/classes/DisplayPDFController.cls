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
global with sharing class DisplayPDFController {
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
     * @description Array containing characters to be decoded in HTML entities.
     */
    private static final String[] html_DECODED  = new String[]{ '&', '<', '>', '"', '\''};

    /**
     * @description Array containing corresponding HTML encoded values.
     */
	private static final String[] html_ENCODED  = new String[]{ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' };
    
    public DisplayPDFController() {
        displaypagesequence =false;
        String inputparam;
        Document__c documentRecordToDisplay = new Document__c();
        
        if(!Test.isRunningTest()){
            showAllPages = false;
            defaultCSS = true;
            inputparam = SFDC_HTMLENCODE(apexpages.currentpage().getparameters().get('documentid'));
            documentRecordToDisplay =[select id,Document_Body__c,Document_Content__c, Document_Template__r.Watermark_Data__c from Document__c where id=:inputparam WITH SECURITY_ENFORCED];
            displayText = inputparam!=null ? String.escapeSingleQuotes(documentRecordToDisplay.Document_Body__c).replace('\\', '') : 'ID not found ' + inputparam;
            if (docrec.Document_Template__r.Watermark_Data__c != null) {
                String contentVersionID;
                String pageOption;
                List<Object> jsonObjectList = (List<Object>) JSON.deserializeUntyped(docrec.Document_Template__r.Watermark_Data__c);
                for (Object obj : jsonObjectList) {
                    Map<String, Object> jsonObject = (Map<String, Object>) obj;
                    if (jsonObject.get('isPrimary') != null && (Boolean) jsonObject.get('isPrimary')) {
                        contentVersionID = (String) jsonObject.get('contentVersionID');
                        pageOption = (String) jsonObject.get('pageOption');
                        pageOption = pageOption.substring(0, pageOption.indexOf(' - '));
                    }
                }
                showAllPages = (pageOption == 'All Pages') ? true : false;
                deFaultCSS = false;
                imageURL = PdfDisplay.getDomainUrl() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=' + contentVersionID; 
            }
        } else {
            /* Strictly for  test coverage purpose only. */
            documentRecordToDisplay.Document_Content__c = '{"header":{"sectionsCount":"3","sectionsContent":[{"value":"","indexvar":0,"key":"1707976996596:0"},{"value":"","indexvar":1,"key":"1707976996596:1"},{"value":"<p style=\\"text-align: right;\\"><strong style=\\"font-size: 22px; color: rgb(72, 11, 173);\\">Dextara Digital</strong></p>","indexvar":2,"key":"1707977018477:2"}]},"footer":{"sectionsCount":"3","sectionsContent":[{"value":"","indexvar":1,"key":"1707977023131:1"},{"value":"","indexvar":2,"key":"1707977023131:2"},{"value":"<p><strong style=\\"color: rgb(72, 11, 173); font-size: 22px;\\">Dextara Digital</strong></p>","indexvar":0,"key":"1707977024668:0"}],"displaypagesequence":false}}';
        }

        try {
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
                            } else if(wrec.get('indexvar')==1){
                                centerheadertext = (String)wrec.get('value');
                            } else if(wrec.get('indexvar')==2){
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
                            } else if(wrec.get('indexvar')==1){
                                centerfootertext = (String)wrec.get('value');
                            } else if(wrec.get('indexvar')==2){
                                rightfootertext = (String)wrec.get('value');
                            }
                        }
                    }
                }
            } else {
                displayText = 'Requested Template does not exist or is invalid.';
            }      
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.DisplayPDFController() - Constructor','Template Id-  '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            displayText = ex.getMessage();
        }
    }

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
    
    /**
     * @description    Generates a document record and inserts it into Salesforce
     * @param          templateId       ID of the document template
     * @param          quoteId          ID of the associated quote
     * @param          pdfbody          Body content of the PDF document
     * @param          pdfheaderfooter  Header and footer content of the PDF document
     * @return         ID               ID of the inserted document record
     */
  /* changes done by reethika Parameter templatedId changed to documentId and document record Insertion
   logic changed to document updation logic*/
    @AuraEnabled
    public static string generateDocument(ID documentId, String quoteId, String pdfbody, String pdfheaderfooter){
        try{
            List<Document__c> doctobeinserted=new List<Document__c>();
            
            Document__c documentRecordToDisplay=new Document__c();
            documentRecordToDisplay.Document_Content__c=pdfheaderfooter;
            documentRecordToDisplay.Document_Body__c=pdfbody;
            documentRecordToDisplay.Document_Template__c=templateId;
            documentRecordToDisplay.Object_Id__c = quoteId;
            
            Id inserteddocId;
            doctobeinserted.add(documentRecordToDisplay);
            
            Savepoint sp = Database.setSavepoint();
            List<Database.SaveResult> sResult = safe.doUpdate(doctobeinserted);            
            for(Integer i=0;i<sResult.size();i++) {
                if (sResult.get(i).isSuccess()) {
                    inserteddocId = (sResult.get(i).getId()) ? sResult.get(i).getId() : null;
                } else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    throw new SafeClassException(error.getMessage());
                }               
            }
            return inserteddocId;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.generateDocument()','document Id- '+documentId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
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
            objAttachment.IsPrivate = false;
            objAttachment.ParentId = documentid
            objAttachment.Body = (!Test.isrunningTest()) ? pg.getContentAsPDF() : Blob.valueof('text');

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
                if (sResult.get(i).isSuccess()) {
                    Id attachmentid=sResult.get(i).getId();
                    if(attachmentid!=null) {
                        insertedattachmentId = attachmentid;
                    }
                }else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    throw new SafeClassException(error.getMessage());
                }            
            }
            return insertedattachmentId;   
        } catch (Exception ex) {
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
                    if(attachmentid!=null) {
                        insertedattachmentId=attachmentid;
                    }
                }else if (!sResult.get(i).isSuccess()){
                    Database.Error error = sResult.get(i).getErrors().get(0);
                    throw new SafeClassException(error.getMessage());
                }                
            }
            return String.Valueof(insertedattachmentId);
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.savePDFtoQuote()','documentid ->  '+documentid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return 'Error';
        }       
    }    
    
    /**
    * @description    Retrieves the sections of a document template by its ID. changes done by Reethika - Dynamically selected class is called using interface and map is returned from that class
                        Dynamically selected flow will be executed and the string returned from flow is deserailised to map and final map
                        is constructed . mergefieldsclass parameters got changed from size 3 to 4, an extra parameter of replaceData (datatype-Map)
                        is added.
    * @param          templateId   ID of the document template
    * @param          recordId     ID of the record related to the document template
    * @param          objectApiName   API name of the object related to the document template
    * @return         Map<String,Object>  List of document template sections
    */
    @AuraEnabled
    public static Map<String,Object> getTemplateSections(ID templateId, String recordId, String objectApiName){ 
        try{
            List<Document_Template_Section__c> selectedTemplateContents=[select id,Section_Content__c, Type__c, New_Page__c, Sequence__c from Document_Template_Section__c where Document_Template__c=:templateId WITH SECURITY_ENFORCED ORDER BY Sequence__c ASC];
            List<Document_Template__c> templateData=[SELECT ClassId__c,FlowId__c FROM Document_Template__c WHERE id=:templateId WITH SECURITY_ENFORCED];
            Map<String,Object> replaceData=new Map<String,Object>();
            if(!string.isEmpty(templateData[0].ClassId__c)) {
                List<ApexClass> classnames= [SELECT Name FROM ApexClass WHERE Id=:templateData[0].ClassId__c WITH SECURITY_ENFORCED];
                Type t = Type.forName(classnames[0].Name);
                DXHandlerInterface api = (DXHandlerInterface)t.newInstance();
                Map<String,Object> tempData= new Map<String,Object>();
                tempData.put('templateId',templateId);
                tempData.put('recordId',recordId);
                replaceData=api.execute(tempData);                
            }
            if(!string.isEmpty(templateData[0].FlowId__c)) {
                    List <FlowDefinitionView> flownames= [SELECT  Label, ApiName,Id,DurableId FROM FlowDefinitionView where ProcessType='AutoLaunchedFlow' AND IsActive=True AND DurableId=:templateData[0].FlowId__c WITH SECURITY_ENFORCED];   
                    Map<String,Object> inputs=new map<String,Object>{'recordIdVal'=>recordId};
                    Flow.Interview myFlow = Flow.Interview.createInterview(flownames[0].ApiName, inputs);
                    myFlow.start();
                    string data=(string)myFlow.getvariableValue('genericData');
                    if(!string.isEmpty(data)){
                    Map<String, Object>  mapdata =(Map<String, Object>) JSON.deserializeUntyped(data); 
                    replaceData.putAll(mapdata); 
                }                  
            }
            List<Document__c> data=[SELECT Id from Document__c WHERE Document_Template__c =: templateId WITH SECURITY_ENFORCED];
            Id docid;
            List<Document__c> doclist=new List<Document__c>();
            Document__c doc= new Document__c();
            doc.Document_Template__c=templateId;
            if(!string.isEmpty(templateData[0].FlowId__c) || !string.isEmpty(templateData[0].ClassId__c)){
                doc.Token_Data__c=JSON.serialize(replaceData);
            }
           
            if(data.size() ==0){
                doclist.add(doc); 
            } else {
                doc.Id=data[0].Id;
                docid=data[0].Id;
                doclist.add(doc); 
            }

            Savepoint sp = Database.setSavepoint();
            Database.UpsertResult[] urList2 = safe.doUpsert(doclist);
            List<String> errorList = Safely.safeClassExceptionHandlerUpsert(urList2);
            if(errorList.size()>0){
                Database.rollback(sp);
                throw new SafeClassException(String.join( errorList, ', ' ));
            }

            for(Integer i=0;i<urList2.size();i++) {
                if (urList2.get(i).isSuccess()) {
                    docid=urList2.get(i).getId();
                }else if (!urList2.get(i).isSuccess()){
                    Database.Error error = urList2.get(i).getErrors().get(0);
                    LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','Template Id- '+templateId+' '+'Database Error while saving the result --> ',String.valueof(error),'Exception');
                }               
            }

            selectedTemplateContents = MergeFieldsClass.mergefieldsMethod(selectedTemplateContents,recordId,replaceData);            
            Map<String,Object> templatecontentsData=new Map<String,Object>();
            templatecontentsData.put('selectedTemplateContents',selectedTemplateContents);            
            templatecontentsData.put('documentId',docid);
            return templatecontentsData;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','templateId ->  '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }

    //getting the template sections for the Multiple recordIds
    @AuraEnabled
    public static List<Document_Template_Section__c> getTemplateSectionsMulRecords(ID templateId, List<String> recordIdLst, String objectApiName){ 
        try{
            List<Document_Template_Section__c> selectedTemplateContents=[select id,Section_Content__c, Type__c, New_Page__c, Sequence__c from Document_Template_Section__c where Document_Template__c=:templateId WITH SECURITY_ENFORCED ORDER BY Sequence__c ASC];
            selectedTemplateContents = MergeFieldsClass.mergefieldsMethodMultiple(selectedTemplateContents,recordIdLst);
            return selectedTemplateContents;
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getTemplateSections()','templateId ->  '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            throw new AuraHandledException(ex.getMessage());
        }  
    }
    
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
            return null;
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
            } else {
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
            }else{
                LogHandler.createLog((Id) null,'DisplayPDFController.saveContentVersion()','Insufficient permissions to create ContentVersion records. ','Insufficient permissions to create ContentVersion records.', 'Insufficient permissions');
                return null;
            }
        
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.saveContentVersion()','Failed to create the Contentversion records '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Failed to create the Contentversion records');  
            return null;
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
            Document_Template__c dtData = [SELECT Id, Name,Watermark_Data__c FROM Document_Template__c  
                                           WHERE Id = :templateId WITH USER_MODE LIMIT 1];
            return dtData;
        } catch(Exception ex) {
            LogHandler.createLog((Id) null,'DisplayPDFController.getDocumentTemplateData()','Template Id- '+templateId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }
    }
}