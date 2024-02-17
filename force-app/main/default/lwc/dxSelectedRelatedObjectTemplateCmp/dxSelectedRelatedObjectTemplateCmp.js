import { LightningElement, api } from 'lwc';
import getRelatedObjectForSelectedDocumentTemplate from '@salesforce/apex/RelatedObjectsClass.getRelatedObjectForSelectedDocumentTemplate';
export default class DxSelectedRelatedObjectTemplateCmp extends LightningElement {
    @api recordId;
    @api objectApiName;
    relatedObject;
    showTemplateSelector;
    selectedObjectId;
    showTemplate;
    searchlabel;

    connectedCallback() {
       window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            getRelatedObjectForSelectedDocumentTemplate({docTempId:this.recordId}).then(result=>{
               if(result){
                   this.relatedObject=result.DxCPQ__Related_To_Type__c;
                this.searchlabel = 'Search Record';
                   if(this.relatedObject){
                       this.showTemplateSelector=true;
                   }
               }
            }).catch(error=>{
            })
        }, 0);
    }

    selectItemEventHandler(event){
        this.selectedObjectId = event.detail.selectedRecord.recordId;    
        if(this.selectedObjectId!=undefined){
            this.showTemplate=true;
        }  
    }

    updateItemEventHandler(event){
        this.selectedObjectId=undefined;
        this.showTemplate=false;
    }

}