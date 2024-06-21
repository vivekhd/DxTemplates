public class AttachmentDeletionBatch implements Database.Batchable<sObject>, Schedulable {
    public static Safely safe = new Safely();
    private static Savepoint sp;
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'Select Id, (Select Id from Attachments ) from Document__c ORDER BY CreatedDate LIMIT 500';
		return Database.getQueryLocator(query);
	}
    
	public void execute(Database.BatchableContext bc, List<Document__c> documentsList) {
		try {
			if(sp == null ) { sp = Database.setSavepoint(); }
			List<Attachment> allAttachments = new List<Attachment>();
			for (Document__c doc : documentsList) {
				for (Attachment att : doc.Attachments) {
					allAttachments.add(att);
				}
			}
			Database.DeleteResult[] deleteResult = safe.doDelete(allAttachments);
			List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
			if(errorList.size()>0) {
				Database.rollback(sp);
				throw new SafeClassException(String.join( errorList, ', ' ));
			}
		} catch(Exception e) {
			System.debug('Error in AtachmentDeletionBatch');
		}
	}
    
	public void finish(Database.BatchableContext bc) {
	
	}
    
    /**
     * Executes the scheduled job.
     * This method is responsible for executing the scheduled job.
     * @description It initiates the execution of a batch job to delete transaction log records.
     * @param sc The schedulable context passed by the system.
     */
    public void execute(system.SchedulableContext sc) {
        Database.executeBatch(new AttachmentDeletionBatch());
    }
    
    public class SafeClassException extends Exception   { }
}