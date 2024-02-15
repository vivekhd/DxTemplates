import { api, LightningElement, wire } from 'lwc';

export default class DxCpqMenuSetupRow extends LightningElement {
    @api myWrapper;
    isExpanded;
    selectedRecordId;
    
    connectedCallback(){
        this.isExpanded = false;
    }

    chooseWrapper(event){
        let index = event.currentTarget.dataset.index;
        let recId= event.currentTarget.dataset.catid;
        const selectedEvent = new CustomEvent("select", {bubbles: true, composed:true, detail: {id: recId, _index:index, row: this.myWrapper}});
        this.dispatchEvent(selectedEvent);
    }
}