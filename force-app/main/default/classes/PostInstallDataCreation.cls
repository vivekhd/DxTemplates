/* 
* Class			    : PostInstallDataCreation
* Developer			: Rahul Bejgam        
* Created Date		: 09/09/2023
* Description		: This class is for running Apex after the package Installation for a default record creation on the Document Template and sending the status of theis apex transaction eiforther failure/success of the Apex transaction.
* Test Class        : PostInstallDataCreation_test.apxc
* Last Modified Date: 10/09/2023
*/

global class PostInstallDataCreation implements InstallHandler {
    public static Safely safe = new Safely();

    global void onInstall(InstallContext context) {
        try {
            if(!context.isUpgrade()) {            
                Document_Template__c newDocTemplate = new Document_Template__c (
                    Name = 'Template 1.0', 
                    Description__c = 'This is a default template created on package installation.',
                    Related_To_Type__c = 'Account',
                    Version_Number__c = 1
                );

                /*
                Database.SaveResult[] srList = Database.insert(new Document_Template__c[] {newDocTemplate},false);     
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Template with Id: ' + sr.getId());                        
                        String successBody = 'Hello Team, DxCPQ Template Package Installation was successfull. This mail is for the confirmation purpose.';
                        statusOfTheInstallation('Post Install Script run was Successfull - DxCPQ Package',successBody,context.installerId());
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            String errorBody = 'Hello Team, an error occured when creating a Template record through Apex transaction. Please review the following details.' + '\nError Details \nError Status : ' + err.getStatusCode() + '\nError Message : ' + err.getMessage() + '\nError Fields : ' + err.getFields() + '\nError Severity : Minor';
                            statusOfTheInstallation('Template record creation was unsuccessfull, Please create it.',errorBody,context.installerId());
                        }
                    }
                }
                */

                List<Database.SaveResult> sResult = safe.doInsert(new Document_Template__c[] {newDocTemplate});
                for(Integer i=0;i<sResult.size();i++){
                    if (sResult.get(i).isSuccess()){
                        String successBody = 'Hello Team, DxCPQ Template Package Installation was successfull. This mail is for the confirmation purpose.';
                        statusOfTheInstallation('Post Install Script run was Successfull - DxCPQ Package',successBody,context.installerId());
                    }   else if (!sResult.get(i).isSuccess())   {
                        Database.Error err = sResult.get(i).getErrors().get(0);

                        String errorBody = 'Hello Team, an error occured when creating a Template record through Apex transaction. Please review the following details.' + '\nError Details \nError Status : ' + err.getStatusCode() + '\nError Message : ' + err.getMessage() + '\nError Fields : ' + err.getFields() + '\nError Severity : Minor';
                        statusOfTheInstallation('Template record creation was unsuccessfull, Please create it.',errorBody,context.installerId());
                    }            
                }
            }
        }
        catch(Exception error){
            String errorDetails = '\nCause : ' + error.getCause() + '\nLine Number :' + error.getLineNumber() + '\nError Message :' + error.getMessage() + '\nError Stack : ' + error.getStackTraceString();
            String errorBody = 'Hello Team,\n An error occured while running an Apex transaction. Please review the following error details and contact the Package Manager for more details. \n Error : ' + error + '\nDebug Log :' + errorDetails;
            statusOfTheInstallation('Error - Post Install Apex Transaction - DxCPQ Template Package',errorBody,context.installerId());            
        }
    }

    global void statusOfTheInstallation(String mailSubject,String messageBody, Id userId){
        String installerEmailAddress = [Select Email from User where Id =: userId WITH SECURITY_ENFORCED].Email;
        Messaging.SingleEmailMessage emailDraft = new Messaging.SingleEmailMessage();
        emailDraft.toAddresses = new String[] { installerEmailAddress };
        emailDraft.optOutPolicy = 'FILTER';
        emailDraft.subject = mailSubject;
        emailDraft.plainTextBody = messageBody;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {emailDraft};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}