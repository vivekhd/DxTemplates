/**
* The LanguageTranslator class facilitates the conversion of content tokens into a user-selected language.
* It also retrieves the available organization languages that users can choose for their conversations.
* This class ensures robustness through comprehensive error handling mechanisms.
* It is designed to seamlessly integrate with Salesforce Lightning Web Components (LWC),
* providing versatile functionality for template customization and data presentation.
* By utilizing the LanguageTranslator class, data management within Salesforce applications is streamlined,
* enhancing the overall efficiency and user experience.
*/


/**
* @description Represents LanguageTranslatorClass, which is a class with sharing.
*              class facilitates the conversion of content tokens into a user-selected language.
*/
public with sharing class LanguageTranslatorClass {
    
    /**
	* @description    Retrieves all available user languages from the LanguageLocaleKey picklist on the User object.
	* @return         List<ComboBoxOption> List of available user languages as ComboBoxOption objects.
	*/
    @AuraEnabled
    public static List<ComboBoxOption> getAllUserLanguages(){
        List<ComboBoxOption> options = new List<ComboBoxOption>();
        try {
            for(PicklistEntry value: User.LanguageLocalekey.getDescribe().getPicklistValues()) {
                options.add(new ComboBoxOption(value.getValue(),value.getLabel()));
            }
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'LanguageTranslatorClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
        return options;
    }
    
    /**
 	* @description    Retrieves translation records for a specified language or the current user's language if none is provided.
 	* @param          language String representing the language for which to retrieve translation records.
 	* @return         List<DxCPQ__Translator__c> List of translation records for the specified language.
 	*/
    @AuraEnabled
    public static List<DxCPQ__Translator__c> langTransRecs(String language){ 
        String str;  
        if(language!=null){
            str = language;
        }else{
            str = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id= :UserInfo.getUserId()].LanguageLocaleKey;
        }
        List<DxCPQ__Translator__c> translatedList = [select id, name, DxCPQ__FieldValue__c, DxCPQ__Translated_Value__c,DxCPQ__Language__c, DxCPQ__DocumentTemplate__c  from DxCPQ__Translator__c  WHERE DxCPQ__Language__c =: str];
        return translatedList;
    }
    
    /**
 	* @description    Retrieves translation records for a specified language.
 	* @param          language String representing the language for which to retrieve translation records.
 	* @return         List<DxCPQ__Translator__c> List of translation records for the specified language.
 	*/
    @AuraEnabled
    public static List<DxCPQ__Translator__c> selectedLangMethod(String language){
        List<DxCPQ__Translator__c> translatedList = [select id, name, DxCPQ__FieldValue__c, DxCPQ__Translated_Value__c,DxCPQ__Language__c, DxCPQ__DocumentTemplate__c  from DxCPQ__Translator__c  WHERE DxCPQ__Language__c =: language];
        return translatedList;
    }
    
    /**
 	* @description    Retrieves the current user's language setting.
 	* @return         String Current user's language setting.
 	*/
    @AuraEnabled
    public static String currectUserLang(){    
        return [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id= :UserInfo.getUserId()].LanguageLocaleKey;
    }  
    
    /**
    * @description    Creates or updates translation records based on provided JSON data, language, and section ID.
    * @param          jsonStringData String containing JSON data with translation records.
    * @param          language String representing the language for the translation records.
    * @param          sectionId Id of the section related to the translation records.
    * @return         Boolean True if the operation was successful, false otherwise.
    */
    @AuraEnabled
    public static Boolean createUpdateMethod(String jsonStringData, String language, Id sectionId){
        Boolean upsertSuccess = false;
        try{
            Id docTemplateId = [Select id, DxCPQ__Document_Template__c from DxCPQ__Document_Template_Section__c where Id =: sectionId].DxCPQ__Document_Template__c;
            List<wrapperData> wrapdata=(List<wrapperData>)JSON.deserialize(jsonStringData, List<wrapperData>.class);
            String regex = '^[a-zA-Z0-9_-]{18}$'; 
            List<DxCPQ__Translator__c> upsertTransLanguages = new List<DxCPQ__Translator__c>();
            for(wrapperData wrapItem : wrapdata){
                DxCPQ__Translator__c transRec = new DxCPQ__Translator__c();
                if(Pattern.matches(regex, wrapItem.Id)){
                    transRec.Id = wrapItem.Id;
                }
                transRec.Name = wrapItem.Name;
                transRec.DxCPQ__FieldValue__c = wrapItem.FieldValue;
                transRec.DxCPQ__Translated_Value__c = wrapItem.TranslatedValue;
                transRec.DxCPQ__Language__c = language;
                transRec.DxCPQ__DocumentTemplate__c = docTemplateId;
                upsertTransLanguages.add(transRec);
            }
            if(upsertTransLanguages.size()>0){
                List<Database.upsertResult> uResults = Database.upsert(upsertTransLanguages,false);
                upsertSuccess = true;
            }
        } catch(exception ex){
            LogHandler.createLog((Id) null,'LanguageTranslatorClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
        }
        return upsertSuccess;
    }
    
    /**
    * @description    Deletes a translation record identified by its ID.
    * @param          deleteRecordId Id of the translation record to be deleted.
    * @return         Boolean True if the operation was successful, false otherwise.
 	*/
    @AuraEnabled
    public static Boolean deleteMethod(Id deleteRecordId){
        Boolean deleteSuccess=false;
        try{
            DxCPQ__Translator__c translationRec = [SELECT Id, DxCPQ__Language__c FROM DxCPQ__Translator__c WHERE Id = :deleteRecordId LIMIT 1];
            if(translationRec!=null){
                Database.DeleteResult drRcord = Database.delete(translationRec, false);
                deleteSuccess = true;
            }
        } catch(Exception ex){
            LogHandler.createLog((Id) null,'LanguageTranslatorClass Error',ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');    
        }
        return deleteSuccess; 
    }
    
    /**
 	* @description    Wrapper class to hold data for translation records.
 	*/
    public class wrapperData{
        public String Id;
        public String Name;
        public String FieldValue;
        public String TranslatedValue;
    }
    
    /**
 	* @description    Class to represent options in a combo box.
 	*/
    public class ComboBoxOption {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        
        public ComboBoxOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
}