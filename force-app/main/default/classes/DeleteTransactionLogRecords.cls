/** 
* Class			    : DeleteTransactionLogRecords
* Developer			: Rahul Bejgam (SE - Dextara Digital)
* Created Date		: 
* @description		: Batch class to delete TransactionLog__c records older than 30 days.
* Last Modified Date: 
*/
public with sharing class DeleteTransactionLogRecords implements Database.Batchable<sObject>,schedulable{
	
    /**
     * @description Method to start the batch process by querying TransactionLog__c records created more than 30 days ago.
     * @param bc The batchable context passed by the system.
     * @return Database.QueryLocator object containing the query locator for the batch job.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM TransactionLog__c where createddate!=LAST_N_DAYS:30';
        return Database.getQueryLocator(query);
    }

    /**
     * @description An instance of the Safely class used for safe database operations.
     */
    public static Safely safe = new Safely();
    
	/**
     * @description Executes the batch process by deleting the provided list of TransactionLog__c records.
     * Checks for accessibility and deletability of TransactionLog__c object before performing the deletion.
     * @param bc The batchable context passed by the system.
     * @param logRecordsToDeleted List of TransactionLog__c records to be deleted.
     */
    public void execute(Database.BatchableContext bc, List<TransactionLog__c> logRecordsToDeleted)  {
        try{
            if(Schema.sObjectType.TransactionLog__c.isAccessible() && Schema.sObjectType.TransactionLog__c.isDeletable() && !logRecordsToDeleted.isEmpty())  {
                List<Database.DeleteResult> deleteResult = safe.doDelete(logRecordsToDeleted);
                List<String> errorList = Safely.safeClassExceptionHandlerDelete(deleteResult);
                if(errorList.size()>0){
                    throw new SafeClassException(String.join(errorList, ', ' ));
                }
            }
        } catch(Exception ex){
            LogHandler.createLog((Id) null,'DeleteTransactionLogRecords.execute()', ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(), ex.getMessage(),'Exception');
        }
    }

	 /**
     * Marks the completion of the batch job.
     * @description This method is called after all batches are processed.
     * @param bc The batchable context passed by the system.
     */
    public void finish(Database.BatchableContext bc) { }

    /**
     * Executes the scheduled job.
     * This method is responsible for executing the scheduled job.
     * @description It initiates the execution of a batch job to delete transaction log records.
     * @param sc The schedulable context passed by the system.
     */
    public void execute(system.SchedulableContext sc) {
        Database.executeBatch(new DeleteTransactionLogRecords());
    }

    /**
     * @description Custom exception class to handle exceptions in the SafeClass.
     * Extends the standard Exception class.
     */
    public class SafeClassException extends Exception{}
}