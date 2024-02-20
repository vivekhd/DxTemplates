/* 
* Class			    : sendEmailAutomation
* Developer			: Rahul Bejgam (ASE - Dextara)
* Created Date		: 08/03/2023
* Description		: This class renders the pdf from Document__c record content and generated the pdf version.
* Last Modified Date: 08/10/2023
*/
global class sendEmailAutomation implements Queueable,Database.AllowsCallouts{
    String attachmentName;
    Id documentRecordInserted;
    private static Savepoint sp1;  
    public static Safely safe = new Safely();
    String emailStructure;
    public class SafeClassException extends Exception {}
    
    global sendEmailAutomation (Id docInserted, String attachmentName, String emailStructure) {
		this.documentRecordInserted = docInserted;
        this.attachmentName = attachmentName;
        this.emailStructure = emailStructure;
    }
    
    public void execute(QueueableContext context) {
        try {
            List<String> errorList;
            Id insertedAttachmentId;
            Attachment documentAttachment = new Attachment();

            /* .pdf version of the Document__c record Content */
            Pagereference pg = Page.renderAsPdfLWC;
            pg.getParameters().put('documentId',documentRecordInserted);
            
            /* Attachment Generation and Insertion of the generated Document to Parent Record */
            /* documentAttachment.Name = attachmentName;
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
            } */
            if(!Test.isRunningTest()){
                Attachment objAttachment = new Attachment();
                objAttachment.parentID = '001IS000002OC2kYAG';
                objAttachment.Name = 'Automation Document'+System.today()+'.pdf'; 
                objAttachment.Body = pg.getContentAsPDF();
                objAttachment.IsPrivate = false;            
                insert objAttachment;
            }            

            if(emailStructure != null) {
                 Messaging.EmailFileAttachment attachmentToInsert = new Messaging.EmailFileAttachment();
                attachmentToInsert.setFileName(attachmentName+'.pdf');
                attachmentToInsert.setBody(pg.getContentAsPDF()); 
                documentAutomationController.emailWrapper emailToBeSent = (documentAutomationController.emailWrapper) JSON.deserialize(emailStructure ,documentAutomationController.emailWrapper.class);

                Messaging.SingleEmailMessage emailContent = new Messaging.SingleEmailMessage();
                //emailContent.setFileAttachments(new Messaging.EmailFileAttachment[] {attachmentToInsert});
                if(emailToBeSent.emailTemplateId != null) { emailContent.setOrgWideEmailAddressId(emailToBeSent.fromAddress); }
                emailContent.setToAddresses(emailToBeSent.toAddresses); 
                emailContent.setCcAddresses(emailToBeSent.toCCAddresses);
                emailContent.setBccAddresses(emailToBeSent.toBCCAddresses);
                emailContent.setSubject(emailToBeSent.emailSubject);
                emailContent.setHTMLBody(emailToBeSent.emailBody);
                if(emailToBeSent.emailTemplateId != null) { emailContent.setTemplateId(emailToBeSent.emailTemplateId); }
                LogHandler.createLog((Id) null,'Email Framework Structure','Document Id- '+ documentRecordInserted + ' ' + JSON.serialize(emailContent),'','Exception');

                Messaging.SendEmailResult [] emailSentStatus = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailContent});
            }
        }
        catch(Exception ex) {
            LogHandler.createLog((Id) null,'sendEmailAutomation.execute() Queueable Class','Document Id- '+ documentRecordInserted + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');
        }
    }
}
