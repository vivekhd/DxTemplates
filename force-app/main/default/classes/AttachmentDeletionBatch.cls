public class AttachmentDeletionBatch implements Database.Batchable<sObject> {
    public static Safely safe = new Safely();
    private static Savepoint sp;
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'Select Id,ParentId from Attachment where ParentId IN (Select Id from DxCPQ_Document__c)';
		return Database.getQueryLocator(query);
	}
	public void execute(Database.BatchableContext bc, List<Attachment> attachmentsList) {
		try {
            	if(sp == null ) {sp = Database.setSavepoint();}
				Database.DeleteResult[] deleteResult = safe.doDelete(attachmentsList);
            	 List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
                if(errorList.size()>0){
                    Database.rollback(sp);
                    throw new SafeClassException(String.join( errorList, ', ' ));
                }
				
			}catch(Exception e) {
			
			}
	}
	public void finish(Database.BatchableContext bc) {
	}
     public class SafeClassException extends Exception   { }
}