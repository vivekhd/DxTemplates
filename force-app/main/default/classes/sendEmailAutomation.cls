/* 
* Class			    : sendEmailAutomation
* Developer			: Rahul Bejgam (ASE - Dextara)
* Created Date		: 08/03/2023
* Description		: This class renders the pdf from Document__c record content and generated the pdf version.
* Last Modified Date: 08/10/2023
*/
global class SendEmailAutomation implements Queueable,Database.AllowsCallouts{
    public static Safely safe = new Safely();
    private static Savepoint sp1;
    
    Id documentRecordInserted;    
    Id attachmentParentId;
    String attachmentName;

    public class SafeClassException extends Exception { }
    
    global sendEmailAutomation (Id docInserted, String attachmentName, Id attachmentParentId) { 
		this.documentRecordInserted = docInserted;
        this.attachmentName = attachmentName;
        this.attachmentParentId = attachmentParentId;
    }
    
    public void execute(QueueableContext context) {
        try {            
            /* .pdf version of the Document__c record Content */
            Pagereference pg = Page.renderAsPdfLWC;
            pg.getParameters().put('documentId',documentRecordInserted);
            
            /* Attachment Generation and Insertion of the generated Document to Parent Record */
            Attachment objAttachment = new Attachment();
            objAttachment.Name = attachmentName;
            objAttachment.ParentId = attachmentParentId; 
            if(!Test.isRunningTest()){
                objAttachment.Body = pg.getContentAsPDF();  
            } else {
                objAttachment.Body = Blob.valueOf('Testing Attachment');  
            }
                   
            objAttachment.IsPrivate = false;
            
            List<Attachment> atttobeinserted = new List<Attachment>();
            atttobeinserted.add(objAttachment);
            Savepoint sp1 = Database.setSavepoint();
        
            Database.SaveResult[] urListsave = safe.doInsert(atttobeinserted);
            List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(urListsave);
            if(errorList1.size()>0){
                Database.rollback(sp1);
                throw new SafeClassException(String.join( errorList1, ', ' ));
            }
        }
        catch(Exception ex) {
            LogHandler.createLog((Id) null,'sendEmailAutomation.execute() Queueable Class','Document Id- '+ documentRecordInserted + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');
        }
    }
}