public with sharing class DeleteTransactionLogRecords implements Database.Batchable<sObject>,schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM TransactionLog__c where createddate!=LAST_N_DAYS:30';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<TransactionLog__c> logRecordsToDelete)  {
        if(Schema.sObjectType.TransactionLog__c.isAccessible() && Schema.sObjectType.TransactionLog__c.isDeletable()){
            if(!logRecordsToDelete.isEmpty())  {
                DELETE logRecordsToDelete;
            }
        }
    }

    public void finish(Database.BatchableContext bc) { }
    
    public void execute(system.SchedulableContext sc) {
        Database.executeBatch(new DeleteTransactionLogRecords());
    }
}