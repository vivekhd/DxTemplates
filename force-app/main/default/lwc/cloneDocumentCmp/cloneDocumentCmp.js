import { LightningElement, api, track } from 'lwc';
import cloneDocumentTemplate from '@salesforce/apex/SaveDocumentTemplate.cloneDocumentTemplate';
import { CloseActionScreenEvent } from 'lightning/actions'
export default class CloneDocumentCmp extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api parentTemplateRelatedToType;
    @track resultObj;

    connectedCallback() {
       window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
        }, 0);
    }

    /**
     * handleSubmit: With this method, we are creating a clone template of the current selected template
     */
    handleSubmit(event) {
        event.preventDefault();
        let docTempObj ={'sobjectType':'DxCPQ__Document_Template__c'};
        const fields = event.detail.fields;
        docTempObj.Name=fields.Name;
        docTempObj.DxCPQ__Related_To_Type__c = this.parentTemplateRelatedToType;
        docTempObj.DxCPQ__Description__c = fields.DxCPQ__Description__c;
        docTempObj.DxCPQ__Parent_Template__c=fields.DxCPQ__Parent_Template__c;
        cloneDocumentTemplate({docTemp:docTempObj, docTempId:this.recordId}).then(result=>{
            if(result){
                this.resultObj = JSON.parse(JSON.stringify(result));
                const newDocTempEvt = new CustomEvent('doccreated', {
                detail: {id: result.Id,name:result.Name,templateObj:this.resultObj} ,bubbles: true
                });
                this.dispatchEvent(newDocTempEvt);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        
        }).catch(error=>{
            console.log(error);
        })
    }
}