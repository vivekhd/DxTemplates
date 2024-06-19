public class AttachmentDeletionBatch implements Database.Batchable<sObject> {
    public static Safely safe = new Safely();
    private static Savepoint sp;
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'select id,(select id from Attachments ) from DxCPQ__Document__c ';
		return Database.getQueryLocator(query);
	}
	public void execute(Database.BatchableContext bc, List<DxCPQ__Document__c> documentsList) {
		try {
			if(sp == null ) {sp = Database.setSavepoint();}
			List<Attachment> allAttachments = new List<Attachment>();
			for (DxCPQ__Document__c doc : documentsList) {
				for (Attachment att : doc.Attachments) {
					allAttachments.add(att);
				}
			}
			Database.DeleteResult[] deleteResult = safe.doDelete(allAttachments);
				List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
			if(errorList.size()>0){
				Database.rollback(sp);
				throw new SafeClassException(String.join( errorList, ', ' ));
			}
		}catch(Exception e) {
			System.debug('Error in AtachmentDeletionBatch');
		}
	}
	public void finish(Database.BatchableContext bc) {
	
	}
    public class SafeClassException extends Exception   { }
}