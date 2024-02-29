/* 
* Class			    : sendEmailAutomation
* Developer			: Rahul Bejgam (ASE - Dextara)
* Created Date		: 08/03/2023
* Description		: This class renders the pdf from Document__c record content and generated the pdf version.
* Last Modified Date: 08/10/2023
*/
global class sendEmailAutomation implements Queueable,Database.AllowsCallouts{
   
    String attachmentName;
    Id attachmentParentId;
    String emailStructure;
    Boolean isSpecificToFox;
    Id documentRecordInserted;
    private static Savepoint sp1;
    public static Safely safe = new Safely();
    public class SafeClassException extends Exception {}

    /* Deprecated method - removed for Fox Specific Changes. */
    @deprecated
    @deprecated
    global sendEmailAutomation(Id docInserted, String attachmentName, String emailStructure) {
		this.documentRecordInserted = docInserted;
        this.attachmentName = attachmentName;
        this.emailStructure = emailStructure;
    }

    /* Constructor used for the context of general Organizations. */
    @deprecated
    global sendEmailAutomation(Id docInserted, String attachmentName, Id attachmentParentId) { 
        this.documentRecordInserted = docInserted;
        this.attachmentName = attachmentName;
        this.attachmentParentId = attachmentParentId;
        this.isSpecificToFox = false;
        this.emailStructure = null;
    }

    /* Constructor used for the context of general Organizations. */
    global sendEmailAutomation(Id docInserted, String attachmentName, Id attachmentParentId, String ignoreThisText) { 
		this.documentRecordInserted = docInserted;
        this.attachmentName = attachmentName;
        this.attachmentParentId = attachmentParentId;
        this.isSpecificToFox = false;
        this.emailStructure = null;
    }
    
    /* Constructor used for the context of FOX Organization. */
    global sendEmailAutomation(Id docInserted, String attachmentName, String emailStructure, Boolean isSpecificToFox) {
		this.documentRecordInserted = docInserted;
        this.attachmentName = attachmentName;
        this.emailStructure = emailStructure;
        this.isSpecificToFox = true;
    }
    
    public void execute(QueueableContext context) {
        try {
            List<String> errorList;
            Id insertedAttachmentId;
            List<Messaging.EmailFileAttachment> existingAttachments = new List<Messaging.EmailFileAttachment>();

            /* .pdf version of the Document__c record Content */
            Pagereference pg = Page.renderAsPdfLWC;
            pg.getParameters().put('documentId',documentRecordInserted);
            
            /* Attachment Generation and Insertion of the generated Document to Parent Record */
            if(!isSpecificToFox && emailStructure==null){

                Attachment documentAttachment = new Attachment();
                    documentAttachment.Name = attachmentName;
                    documentAttachment.ParentId = attachmentParentId; 
                    documentAttachment.Body = pg.getContentAsPDF();
                    documentAttachment.IsPrivate = false;
                Savepoint sp1 = Database.setSavepoint();

                Database.SaveResult attachmentDMLStatus = Database.insert(documentAttachment);
                if (attachmentDMLStatus.isSuccess()) {
                    insertedAttachmentId = attachmentDMLStatus.getId();
                }
                errorList = Safely.safeClassExceptionHandlerInsert(new Database.SaveResult[] {attachmentDMLStatus});
                if(errorList.size()>0) {
                    Database.rollback(sp1);
                    throw new SafeClassException(String.join( errorList, ', ' ));
                }

            } else {
                if(emailStructure != null) {
                    Messaging.EmailFileAttachment attachmentToInsert = new Messaging.EmailFileAttachment();
                    attachmentToInsert.setFileName(attachmentName+'.pdf');
                    attachmentToInsert.setBody(pg.getContentAsPDF()); 
                    
                    documentAutomationController.emailWrapper emailToBeSent = (documentAutomationController.emailWrapper) JSON.deserialize(emailStructure ,documentAutomationController.emailWrapper.class);
                    if(emailToBeSent.contentDocumentIds != null && emailToBeSent.contentFugitiveMap != null){
                        existingAttachments = ContentDocumentAsAttachement(emailToBeSent.contentDocumentIds,emailToBeSent.contentFugitiveMap);
                    }
                    existingAttachments.add(attachmentToInsert);

                    Messaging.SingleEmailMessage emailContent = new Messaging.SingleEmailMessage();
                    emailContent.setFileAttachments(existingAttachments);
                    emailContent.setToAddresses(emailToBeSent.toAddresses); 
                    emailContent.setCcAddresses(emailToBeSent.toCCAddresses);
                    emailContent.setBccAddresses(emailToBeSent.toBCCAddresses);
                    emailContent.setSubject(emailToBeSent.emailSubject);
                    emailContent.setHTMLBody(emailToBeSent.emailBody);
                    if(emailToBeSent.fromAddress != null) { emailContent.setOrgWideEmailAddressId(emailToBeSent.fromAddress); }
                    if(emailToBeSent.emailTemplateId != null) { emailContent.setTemplateId(emailToBeSent.emailTemplateId); }
                    Messaging.SendEmailResult[] emailSentStatus = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailContent});

                    Map<String,Object> emailStatusInfo = new Map<String,Object> { 'status' => emailSentStatus[0].isSuccess(), 'errorInfo' => emailSentStatus[0].getErrors()};
                    DxCPQ__DXTemplates_HandlerClass__mdt metaDataContent = [SELECT Id,Label,DxCPQ__HandlerClassName__c FROM DxCPQ__DXTemplates_HandlerClass__mdt where Label = 'HandlerClass'];
                    if(metaDataContent != null) {
                        Type t = Type.forName(metaDataContent.DxCPQ__HandlerClassName__c);
                        DXHandlerInterface api = (DXHandlerInterface)t.newInstance();
                        Map<String,Object> replaceData = api.execute(emailStatusInfo);
                    }         
                }
            }
        }
        catch(Exception ex) {
            LogHandler.createLog((Id) null,'sendEmailAutomation.execute() Queueable Class','Document Id- '+ documentRecordInserted + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');
        }
    }

    /* FOX specific method for attaching the existing ContentVersion records to the Email being sent. */
    private List<Messaging.EmailFileAttachment> ContentDocumentAsAttachement(List<Id> contentDocumentIds,Map<Id,String> contentFugitiveMap) {
        List<ContentVersion> documents                  = new List<ContentVersion>{};
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
        documents.addAll([
            SELECT Id, Title, FileType,FileExtension, VersionData, isLatest, ContentDocumentId
            FROM ContentVersion
            WHERE isLatest = true AND ContentDocumentId IN :contentDocumentIds
        ]);
        
        for (ContentVersion document: documents) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(document.VersionData);
            attachment.setFileName(contentFugitiveMap.get(document.ContentDocumentId)+'-'+document.Title+'.'+document.FileExtension);
            attachments.add(attachment);
        }
        return attachments;
    }
}
