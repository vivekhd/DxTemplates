public with sharing class LanguageTranslatorBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    public final List<String> stringList;
    public final String selectedLanguage;
    public final String templateId;
    public Boolean batchStatus = false;
    public Map<String, Map<String, Object>> translatedStringMap = new Map<String, Map<String, Object>>();
    
    public LanguageTranslatorBatch(List<String> translatedInputList, String inputLanguage, String docTemplateId) {
        stringList = translatedInputList;
        this.selectedLanguage = inputLanguage;
        this.templateId = docTemplateId;
    }
 
    public Iterable<String> start(Database.BatchableContext context) {
        return stringList;
    }
    
    public void execute(Database.BatchableContext context, List<String> scope) {
        for(String inputTranslationString : scope) {
            String translatedString = LanguageTranslatorClass.translateText(inputTranslationString, this.selectedLanguage);
            Map<String, Object> translationDetails = (Map<String, Object>) JSON.deserializeUntyped(translatedString);
            translatedStringMap.put(inputTranslationString, translationDetails);
        }
    }
    
    public void finish(Database.BatchableContext context) {
        List<DxCPQ__Translator__c> translatedRecordsList = new List<DxCPQ__Translator__c>();
        
        for (String key : translatedStringMap.keySet()) {
            Map<String, Object> translationDetails = translatedStringMap.get(key);
            List<Object> translations = (List<Object>) translationDetails.get('translations');
            if (!translations.isEmpty()) {
                Map<String, Object> firstTranslation = (Map<String, Object>) translations[0];
                String translatedText = (String) firstTranslation.get('translatedText');
                
                DxCPQ__Translator__c translator = new DxCPQ__Translator__c();
                translator.Name = key;
                translator.DxCPQ__Translated_Value__c = translatedText;
                translator.DxCPQ__Language__c = this.selectedLanguage;
                translator.DxCPQ__DocumentTemplate__c = this.templateId;
                translatedRecordsList.add(translator);
            }
        }
        
        insert translatedRecordsList;
        batchStatus = true;
    }  
}