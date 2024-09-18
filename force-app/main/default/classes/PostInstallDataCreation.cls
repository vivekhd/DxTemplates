/* 
* Class			    : PostInstallDataCreation
* Developer			: Rahul Bejgam        
* Created Date		: 17/09/2024
* Description		: This class is for running Apex after the package Installation for a default record creation on the Document Template and sending the status of theis apex transaction eiforther failure/success of the Apex transaction.
                      The template and record data is created from the StaticResource with the name - TemplatesAndSectionData.json
* Test Class        : PostInstallDataCreation_test.apxc
* Last Modified Date: 10/09/2023
*/

global class PostInstallDataCreation implements InstallHandler {
    public static Safely safe = new Safely();

    global void onInstall(InstallContext context) {
        /* Org details for the mail body*/
        Organization orgInfo = [Select Id,Name,IsSandbox,OrganizationType from Organization WITH SECURITY_ENFORCED];
        String orgDetails = ' in the org - ' + URL.getOrgDomainURL().toExternalForm() + ' (' + orgInfo.Id + ' - ' + orgInfo.OrganizationType + '). ';
        
        try {
            if(!context.isUpgrade()) {
                List<Database.SaveResult> sResult;

                /* Launch the scheduled Apex Class for clearing the 30 days back Attachments related to Document__c on the last day of the month*/
                System.Schedule('Attachments Clearence', '0 0 23 L * ?', new AttachmentDeletionBatch());

                /* Create the Templates and Template Sections records from the Static Resource. */
                Boolean templateAndSectionDataCreatedFromStaticResource = createSampleTemplateAndTemplateSection();

                if( !templateAndSectionDataCreatedFromStaticResource ){
                    Document_Template__c newDocTemplate = new Document_Template__c (
                        Name = 'Template 1.0', 
                        Description__c = 'This is a default template created on package installation.',
                        Related_To_Type__c = 'Account',
                        Version_Number__c = 1
                    );
                    sResult = safe.doInsert(new Document_Template__c[] {newDocTemplate});
                }

                if (templateAndSectionDataCreatedFromStaticResource || sResult?.get(0).isSuccess()) {
                    String successBody = 'Hello Team,\nDXTemplates Package Installation was successful' + orgDetails +  ' \nThis mail is for the confirmation purpose.';
                    statusOfTheInstallation('Post Install Script run was Successful - DXTemplates Package',successBody,context.installerId());
                }  else  {
                    String errorBody = 'Hello Team, an error occured when creating a Template record through Apex transaction' + orgDetails;
                    statusOfTheInstallation('Post Install Script run was unsuccessful.',errorBody,context.installerId());
                }
            }
        } catch(Exception error) {
            String errorDetails = '\nCause : ' + error.getCause() + '\nLine Number :' + error.getLineNumber() + '\nError Message :' + error.getMessage() + '\nError Stack : ' + error.getStackTraceString();
            String errorBody = 'Hello Team,\n An error occured while running an Apex transaction ' + orgDetails + 'Please review the following error details and contact the Package Manager for more details. \n Error : ' + error + '\nDebug Log :' + errorDetails;
            statusOfTheInstallation('Error - Post Install Apex Transaction - DXTemplates Package',errorBody,context.installerId());            
        }
    }

    global void statusOfTheInstallation(String mailSubject,String messageBody, Id userId) {
        String installerEmailAddress = [Select Email from User where Id =: userId WITH SECURITY_ENFORCED].Email;
        Messaging.SingleEmailMessage emailDraft = new Messaging.SingleEmailMessage();
        emailDraft.toAddresses = new String[] { installerEmailAddress };
        emailDraft.subject = mailSubject;
        emailDraft.plainTextBody = messageBody;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {emailDraft};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

    private Boolean createSampleTemplateAndTemplateSection(){
        Boolean hasRecordDataToLoad = false;
        List<StaticResource> templateRelatedData = [SELECT Id,Body from StaticResource WHERE Name = 'TemplatesAndSectionData' AND ContentType = 'application/json' LIMIT 1];
        if(templateRelatedData.size() == 1){
            hasRecordDataToLoad = true;
            String jsonContent = templateRelatedData[0]?.Body.toString();
            JSONDataForTemplateAndSections formattedDataMaping = (JSONDataForTemplateAndSections) JSON.deserialize(jsonContent, JSONDataForTemplateAndSections.class);

            List<Map<String,String>> templateClausesDataMapping  = ImportExportData.createImportedClauses(JSON.serialize(formattedDataMaping.Document_Clauses));
            List<Map<String,String>> templateRecordsDataMapping =  ImportExportData.createImportedTemplates(JSON.serialize(formattedDataMaping.Templates));
            
            for (Map<String,String> tempIdEx: templateClausesDataMapping){
                for(Document_Template_Section__c eachDocTempSection : formattedDataMaping.Template_Sections){
                    if (eachDocTempSection.DxCPQ__Document_Clause__c == tempIdEx.get('ExternalId')){
                        eachDocTempSection.Document_Clause__c = tempIdEx.get('Id');
                    }
                }
            }
            
            for (Map<String,String> tempIdEx: templateRecordsDataMapping){
                for(Document_Template_Section__c eachDocTempSection : formattedDataMaping.Template_Sections){
                    if (eachDocTempSection.DxCPQ__External_Document_Template__c == tempIdEx.get('ExternalId')){
                        eachDocTempSection.Document_Template__c = tempIdEx.get('Id');
                    }
                }
            }
            List<String> sectionRecordsToInsert =  ImportExportData.createImportedTemplateSections(JSON.serialize(formattedDataMaping.Template_Sections));   
        }
        return hasRecordDataToLoad;
    }

    private class JSONDataForTemplateAndSections {
        private List<Document_Template__c> Templates;
        private List<Document_Template_Section__c> Template_Sections;
        private List<DxCPQ__Document_Clause__c> Document_Clauses;
    }
}