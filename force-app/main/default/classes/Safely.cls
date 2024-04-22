/**
* Class			    : Safely
* Developer			: 
* Created Date		: 
* @description Class wraps DML Calls in FLS / Crud checks.Library is baseed on a fluent api system.All calls are constructed, then chained with options.
* For instances.`new Safely().allOrNothing().doInsert(List<sObject>);`
*
* Notable chainable methods include:
* - allOrNothing() - this enforces the AllOrNothing DML flag.All DML is
*      eventually executed via Database.* methods which accept an allOrNothing
*      parameter requiring all of the records to succeed or fail.
* - throwIfRemovedFields() - this method, if called, will result in an
*     exception being thrown if any record being modified has fields removed
*     by the security decision.
* Last Modified Date: 
*/
public with sharing class Safely {
    @testVisible private Boolean allOrNothing = false;
    @testVisible private Boolean throwIfRemovedFields = true;

    /**
    * @description inner class extends Exception Class
    */
    public class RemovedFieldsException extends Exception {
    }

    /**
    * @description Enables the AllOrNothing DML flag.
    * @return Safely instance with the AllOrNothing flag enabled.
    */
    public Safely allOrNothing() {
        this.allOrNothing = true;
        return this;
    }

    /**
    * @description Enables the throwIfRemovedFields flag.
    * @return Safely instance with throwIfRemovedFields flag enabled.
    */
    public Safely throwIfRemovedFields() {
        this.throwIfRemovedFields = true;
        return this;
    }

    /**
    * @description Inserts a list of SObjects into the database.
    * @param records List of SObjects to insert.
    * @return List of SaveResult for each insertion.
    */
    public List<Database.SaveResult> doInsert(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        if (CanTheUser.create(records)) {
            return doDML(System.AccessType.CREATABLE, records);
        }
        return new List<Database.SaveResult>();
    }
	
	/**
    * @description Inserts a single SObject into the database.
    * @param record SObject to insert.
    * @return List of SaveResult for the insertion.
    */
    public List<Database.SaveResult> doInsert(SObject record) {
        return doInsert(new List<Sobject>{ record });
    }

    /**
    * @description Updates a list of SObjects in the database.
    * @param records List of SObjects to update.
    * @return List of SaveResult for each update.
    */
    public List<Database.SaveResult> doUpdate(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        if (CanTheUser.edit(records)) {
            return doDML(System.AccessType.UPDATABLE, records);
        }
        return new List<Database.SaveResult>();
    }
	
    /**
    * @description Updates a single SObject in the database.
    * @param record SObject to update.
    * @return List of SaveResult for the update.
    */
    public List<Database.SaveResult> doUpdate(SObject record) {
        return doUpdate(new List<Sobject>{ record });
    }

    /**
    * @description Updates a single SObject in the database.
    * @param records SObject to update.
    * @return List of SaveResult for the update.
    */
    public List<Database.UpsertResult> doUpsert(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.UpsertResult>();
        }
        if (CanTheUser.edit(records) && CanTheUser.create(records)) {
            return Database.upsert(
                records,
                this.allOrNothing
            );
        }
        return new List<Database.UpsertResult>();
    }

    /**
    * @description Updates a single SObject in the database.
    * @param records SObject to update.
    * @param uniqueField SObject to update.
    * @return List of SaveResult for the update.
    */
    public List<Database.UpsertResult> doUpsert(List<SObject> records, Schema.sObjectField uniqueField) {
        if (records.isEmpty()) {
            return new List<Database.UpsertResult>();
        }
        if (CanTheUser.edit(records) && CanTheUser.create(records)) {
            return Database.upsert(
                records,
                uniqueField,
                this.allOrNothing
            );
        }
        return new List<Database.UpsertResult>();
    }
	
    /**
    * @description Updates a single SObject in the database.
    * @param record SObject to update.
    * @return List of SaveResult for the update.
    */
    public List<Database.UpsertResult> doUpsert(Sobject record) {
        return doUpsert(new List<Sobject>{ record });
    }

    /**
    * @description Deletes a list of SObjects from the database.
    * @param records List of SObjects to delete.
    * @return List of DeleteResult for each deletion.
    */
    public List<Database.DeleteResult> doDelete(List<SObject> records) {
        if (records.isEmpty()) {
            return new List<Database.DeleteResult>();
        }
        if (CanTheUser.destroy(records)) {
            return Database.delete(records, this.allOrNothing);
        }
        return new List<Database.DeleteResult>();
    }

    /**
    * @description Deletes a single SObject from the database.
    * @param record SObject to delete.
    * @return List of DeleteResult for the deletion.
    */
    public List<Database.DeleteResult> doDelete(SObject record) {
        return doDelete(new List<Sobject>{ record });
    }

    /**
    * @description Executes a SOQL query and returns a list of SObjects.
    * @param query SOQL query string.
    * @return List of SObjects retrieved from the query.
    */
    public List<SObject> doQuery(String query) {
        List<SObject> records = Database.query(query);
        SObjectAccessDecision securityDecision = guardAgainstRemovedFields(
            AccessType.READABLE,
            records
        );
        return securityDecision.getRecords();
    }

    /**
    * @description Executes DML operations based on the access type.
    * @param accessType Type of access (CREATABLE, UPDATABLE).
    * @param records List of SObjects to perform DML operations on.
    * @return List of SaveResult for DML operations.
    */
    private List<Database.SaveResult> doDML(
        System.AccessType accessType,
        List<SObject> records
    ) {
        switch on accessType {
            when CREATABLE {
                return Database.insert(
                   records,
                    this.allOrNothing
                );
            }
            when UPDATABLE {
                return Database.update(
                    records,
                    this.allOrNothing
                );
            }
            when else {
                return new List<Database.SaveResult>();
            }
        }
    }
	
    /**
    * @description Guards against removed fields during DML operations.
    * @param accessType Type of access (READABLE, UPDATABLE).
    * @param records List of SObjects to check for removed fields.
    * @return SObjectAccessDecision object.
    */
    private SObjectAccessDecision guardAgainstRemovedFields(
        System.AccessType accessType,
        List<SObject> records
    ) {
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
            accessType, // What kind of Access are we checking?
            records, // The records to check
            true // <- true here also enforces CRUD.
        );
        Map<String, Set<String>> removedFields = securityDecision.getRemovedFields();
        if (this.throwIfRemovedFields && !removedFields.isEmpty()) {
            throw new RemovedFieldsException(
                'ThrowIfRemovedFields is enabled and the following fields were removed: ' +
                removedFields
            );
        }
        return securityDecision;
    }

    /**
    * @description Handles exceptions during DML operations and returns a list of error messages.
    * @param srList List of SaveResult from DML operations.
    * @return List of error messages.
    */
    public static List<String> safeClassExceptionHandlerInsert(Database.SaveResult[] srList){
        List<String> errorList = new List<String>();
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {             
                for(Database.Error err : sr.getErrors()) {
                    errorList.add(err.getMessage());
                }
            }
        } 
        return errorList;
    }

   /**
   * @description Handles exceptions during upsert operations and returns a list of error messages.
   * @param srList List of UpsertResult from upsert operations.
   * @return List of error messages.
   */
    public static List<String> safeClassExceptionHandlerUpsert(Database.UpsertResult[] srList){
        List<String> errorList = new List<String>();
        for (Database.UpsertResult sr : srList) {
            if (!sr.isSuccess()) {             
                for(Database.Error err : sr.getErrors()) {
                    errorList.add(err.getMessage());
                }
            }
        } 
        return errorList;
    }
	
   /**
   * @description Handles exceptions during delete operations and returns a list of error messages.
   * @param srList List of DeleteResult from delete operations.
   * @return List of error messages.
   */
    public static List<String> safeClassExceptionHandlerDelete(Database.DeleteResult[] srList){
        List<String> errorList = new List<String>();
        for (Database.DeleteResult sr : srList) {
            if (!sr.isSuccess()) {             
                for(Database.Error err : sr.getErrors()) {
                    errorList.add(err.getMessage());
                }
            }
        } 
        return errorList;
    }

    /**
    * @description this safeClassExceptionHandlerUpdate method is used to get
    * the errors when update failed.
    * Author : Reethika
    */
    public static List<String> safeClassExceptionHandlerUpdate(Database.SaveResult[] srList){
        List<String> errorList = new List<String>();
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {             
                for(Database.Error err : sr.getErrors()) {
                    errorList.add(err.getMessage());
                }
            }
        } 
        return errorList;
    }
}