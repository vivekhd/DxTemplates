public with sharing class SaveDocumentTemplatesection {
    public static Safely safe = new Safely();
    private static Savepoint sp1;
    @AuraEnabled
    public static List<Document_Template_Section__c> getAllDocumentTemplateSections(Id docTempId){
        List<Document_Template_Section__c> allSections=new List<Document_Template_Section__c>([select id,Sequence__c,Section_Content__c,Name,
                                                                                               Document_Clause__c,Document_Template__c,IsActive__c,IsEditable__c,New_Page__c,Document_Template__r.Name,
                                                                                               Type__c,Document_Template__r.Related_To_Type__c,Document_Template__r.Parent_Template__c,Document_Template__r.Previously_Active__c,Document_Template__r.IsActive__c,Document_Template__r.Version_Number__c
                                                                                               from Document_Template_Section__c where Document_Template__c=:docTempId WITH SECURITY_ENFORCED
                                                                                               order by Sequence__c asc limit 1000 ]);
        return allSections;
    }
    
    @AuraEnabled
    public static string saveDocumentTemplateSectionSequences(List<Document_Template_Section__c> allSectionRecords){
        String recId='';
        try{
            List<id> allSectionIds=new List<id>();
            Map<id,Decimal> sectionSeqMap=new Map<id,Decimal>();
            List<Document_Template_Section__c> allSectionsTobeUpdated=new List<Document_Template_Section__c>();
            
            for(Document_Template_Section__c rec:allSectionRecords) {
                allSectionIds.add(rec.id);
                sectionSeqMap.put(rec.id,rec.Sequence__c);
                recId=rec.id;
            }
            
            List<Document_Template_Section__c> allSections=new List<Document_Template_Section__c>([select id,Sequence__c from Document_Template_Section__c where id in:allSectionIds WITH SECURITY_ENFORCED ]);
            allSectionIds.clear();
            for(Document_Template_Section__c rec:allSections)
            {
                if(sectionSeqMap.containsKey(rec.id)){
                    if(sectionSeqMap.get(rec.id)!=rec.Sequence__c)
                    {
                        rec.Sequence__c=sectionSeqMap.get(rec.id);
                        allSectionsTobeUpdated.add(rec);
                    }
                }
            }
            sectionSeqMap.clear();
            if(!allSectionsTobeUpdated.isEmpty())
            {
                if (sp1 == null) sp1 = Database.setSavepoint();
                Database.SaveResult[] urList2 = safe.doUpdate(allSectionsTobeUpdated);
                List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(urList2);
                if(errorList1.size()>0){
                    Database.rollback(sp1);
                    throw new SafeClassException(String.join( errorList1, ', ' ));
                }
            }
            allSectionsTobeUpdated.clear();        
            return 'Ack received';
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'SaveDocumentTemplatesection.saveDocumentTemplateSectionSequences()','Template Id- '+recId+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }     
    }
    
    @AuraEnabled
    public static Document_Template_Section__c saveDocumentTemplateSectionDetails(Document_Template_Section__c recordDetails){
        String recordIDValue='';
        try{
            Document_Template_Section__c docTempsec = new Document_Template_Section__c();
            String recordId = recordDetails.Id;
            recordIDValue = recordId;            
            String clauseId=recordDetails.Document_Clause__c;
            list<string> arrOfStr;
            if(clauseId!=null && clauseId.contains('"')) {
                arrOfStr = clauseId.split('"');
                recordDetails.Document_Clause__c=arrOfStr[1];
            }
        
            if(recordId !='' ){
                docTempsec.ID = recordDetails.Id;
                docTempsec.Name = recordDetails.Name;
                docTempsec.Section_Content__c = recordDetails.Section_Content__c;
                docTempsec.New_Page__c = recordDetails.New_Page__c;
                docTempsec.Type__c = recordDetails.Type__c;
                docTempsec.New_Page__c = recordDetails.New_Page__c;
                docTempsec.Document_Clause__c = recordDetails.Document_Clause__c;
                docTempsec.Section_Details__c = String.Valueof(recordDetails.Section_Details__c);
                docTempsec.RuleId__c = recordDetails.RuleId__c ;
                
                List<Document_Template_Section__c> listtobeupdated=new List<Document_Template_Section__c>();
                listtobeupdated.add(docTempsec);
                if (sp1 == null) sp1 = Database.setSavepoint();
                Database.SaveResult[] urList2 = safe.doUpdate(listtobeupdated);
                List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(urList2);
                if(errorList1.size()>0){
                    Database.rollback(sp1);
                    throw new SafeClassException(String.join( errorList1, ', ' ));
                }
            }
            else{
                if(recordDetails.Name != null){
                    docTempsec.Name = recordDetails.Name;
                }
                if(recordDetails.Section_Content__c  != null){
                    docTempsec.Section_Content__c = recordDetails.Section_Content__c ;
                }
                if(recordDetails.New_Page__c !=null){
                    docTempsec.New_Page__c = recordDetails.New_Page__c ;
                }
                if(recordDetails.Document_Template__c!=null){
                    docTempsec.Document_Template__c = recordDetails.Document_Template__c ;
                }
                if(recordDetails.Sequence__c!=null){
                    docTempsec.Sequence__c = recordDetails.Sequence__c ;
                }
                if(recordDetails.Type__c!=null){
                    docTempsec.Type__c = recordDetails.Type__c ;
                }                   
                if(recordDetails.Document_Clause__c!=null){
                    docTempsec.Document_Clause__c = recordDetails.Document_Clause__c ;
                }
                if(recordDetails.Section_Details__c!=null){
                    docTempsec.Section_Details__c = recordDetails.Section_Details__c ;
                }
                if(recordDetails.RuleId__c!=null){
                    docTempsec.RuleId__c = recordDetails.RuleId__c ;
                }                
                
                List<Document_Template_Section__c> listtobecreated=new List<Document_Template_Section__c>();
                    listtobecreated.add(docTempsec);
                if (sp1 == null) sp1 = Database.setSavepoint();
                Database.SaveResult[] urListsave = safe.doInsert(listtobecreated);
                List<String> errorList2 = Safely.safeClassExceptionHandlerInsert(urListsave);
                if(errorList2.size()>0){
                    Database.rollback(sp1);
                    throw new SafeClassException(String.join( errorList2, ', ' ));
                }
                Id inserteddocId;
                
                for(Integer i=0;i<urListsave.size();i++) {
                    if (urListsave.get(i).isSuccess()) {
                        Id attachmentid=urListsave.get(i).getId();
                        if(attachmentid!=null)  {
                            inserteddocId=attachmentid;
                        }
                    } else if (!urListsave.get(i).isSuccess()) {
                        Database.Error error = urListsave.get(i).getErrors().get(0);
                    }                    
                }
                
                if(inserteddocId!=null) {
                    docTempsec.id=inserteddocId;
                }
            }
    
            List<Document_Template_Section__c> doctempSecList = [SELECT Id, Name, Type__c, Sequence__c FROM Document_Template_Section__c WHERE Document_Template__c=:Recorddetails.Document_Template__c WITH SECURITY_ENFORCED ORDER BY Sequence__c];
            Boolean headerExists;
            for(Document_Template_Section__c doctemSec : doctempSecList) {
                if(doctemSec.Type__c=='Header') {
                    doctemSec.Sequence__c=-1;
                    headerExists=true;
                }
                if(doctemSec.Type__c=='Footer') {
                    doctemSec.Sequence__c=doctempSecList.size();
                }
            }

            if (sp1 == null) sp1 = Database.setSavepoint();
            Database.SaveResult[] doctempS = safe.doUpdate(doctempSecList);
            List<String> errorList3 = Safely.safeClassExceptionHandlerInsert(doctempS);
            if(errorList3.size()>0){
                Database.rollback(sp1);
                throw new SafeClassException(String.join( errorList3, ', ' ));
            }
            return docTempsec;
        }
        catch (Exception ex) {
            LogHandler.createLog((Id) null,'SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails()','Template Id- '+recordIDValue+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }       
    }

    
    @AuraEnabled
    public static Document_Clause__c clauseBody(String inputParam){        
        list<string> arrOfStr = inputParam.split('"');
        Document_Clause__c dC = new Document_Clause__c();
        if(inputParam!=null && inputParam!=''){            
            dC = [select id,Body__c,name from Document_Clause__c where Id =:arrOfStr[1] WITH SECURITY_ENFORCED];            
        }
        return dC;      
    }
    
    
    @AuraEnabled
    public static String deletetemplate(String secidtobedeleted,String doctemplateid){
        try{
            Decimal deletedsectionindex;
            List<Document_Template_Section__c> sectionstobeupdated=new List<Document_Template_Section__c>();
            Map<id,Document_Template_Section__c> allSectionsMap=new Map<id,Document_Template_Section__c>([select id,Sequence__c,Section_Content__c,Name,
                                                                                                            Document_Clause__c,Document_Template__c,IsActive__c,IsEditable__c,New_Page__c,
                                                                                                            Type__c from Document_Template_Section__c where Document_Template__c=:doctemplateid WITH SECURITY_ENFORCED
                                                                                                            order by Sequence__c asc limit 1000 ]);
            
            if(allSectionsMap.containsKey(secidtobedeleted)) {
                deletedsectionindex=allSectionsMap.get(secidtobedeleted).Sequence__c;
            }
            
            for(Document_Template_Section__c rec:allSectionsMap.values()) {
                if(rec.Sequence__c>deletedsectionindex) {
                    rec.Sequence__c -=1;
                    sectionstobeupdated.add(rec);
                }
            }
            
            if(!sectionstobeupdated.IsEmpty()) {
                if (sp1 == null) sp1 = Database.setSavepoint();
                Database.SaveResult[] urList2 = safe.doUpdate(sectionstobeupdated);
                List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(urList2);
                if(errorList1.size()>0){
                    Database.rollback(sp1);
                    throw new SafeClassException(String.join( errorList1, ', ' ));
                }                    
            }
            
            Document_Template_Section__c deletesection = new Document_Template_Section__c();
            deletesection.id = secidtobedeleted;
            List<Document_Template_Section__c> deletedts=new List<Document_Template_Section__c>();
            deletedts.add(deletesection);
            if(deletedts.size()>0){
                if (sp1 == null) sp1 = Database.setSavepoint();
                List<Database.DeleteResult> deleteResult = safe.doDelete(deletedts);
                List<String> errorList4 = Safely.safeClassExceptionHandlerDelete(deleteResult);
                if(errorList4.size()>0){
                    Database.rollback(sp1);
                    throw new SafeClassException(String.join( errorList4, ', ' ));
                }
            }
            return 'success';
        } catch (Exception ex) {
            LogHandler.createLog((Id) null,'SaveDocumentTemplatesection.deletetemplate()','Template Id- '+doctemplateid+' '+ex.getLineNumber()+ex.getStackTraceString()+ex.getCause(),ex.getMessage(),'Exception');
            return null;
        }  
    }
    
    @AuraEnabled
    public static Document_Template_Section__c gettemplatesectiondata(String editrecordid){
        Document_Template_Section__c recorddata = new Document_Template_Section__c();
        recorddata =[SELECT Section_Details__c,Document_Clause__c,Document_Clause__r.name,Id,Name,New_Page__c,Section_Content__c,Sequence__c,Type__c,RuleId__r.Name,RuleId__r.Rule_Expression__c
                     FROM Document_Template_Section__c where id =:editrecordid WITH SECURITY_ENFORCED];
        return recorddata;
    }
 
    @AuraEnabled(cacheable=true)
    public static List<String> getSobjectFields(String selectedObject){
        SObjectType docsection = Schema.getGlobalDescribe().get(selectedObject);
        Map<String,Schema.SObjectField> mfields = docsection.getDescribe().fields.getMap();
        
        List<String> sObjectDetailsList = new List<String>();
        for(String s : mfields.keySet()) {
            sObjectDetailsList.add(String.valueOf(mfields.get(s)));
        }
        return sObjectDetailsList;
    }

    @AuraEnabled
    public static void saveData(String dataFrom, Id recordId){
        Document_Template_Section__c  arr = new Document_Template_Section__c() ;
        arr.Id = recordId;
        arr.Header_Content__c = dataFrom;
        if (sp1 == null) sp1 = Database.setSavepoint();
        Database.SaveResult[] urList2 = safe.doUpdate(arr);
        List<String> errorList1 = Safely.safeClassExceptionHandlerInsert(urList2);
        if(errorList1.size()>0){
            Database.rollback(sp1);
            throw new SafeClassException(String.join( errorList1, ', ' ));
        }
    }
    
    public class SafeClassException extends Exception{     
    }  
}