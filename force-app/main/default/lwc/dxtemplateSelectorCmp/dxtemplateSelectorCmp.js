import { getRecord } from "lightning/uiRecordApi";
import rte_tbl from '@salesforce/resourceUrl/rte_tbl';
import {api, LightningElement, track, wire } from 'lwc';
import {loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import saveAsRecordAttachment from '@salesforce/apex/DisplayPDFController.savePDFtoQuote';

export default class DxtemplateSelectorCmp extends LightningElement {

    @api recordId;
    @api objectLabel;
    @api objectApiName;

    @track modifiedPDFName;
    @track pageSize = 'A4';
    @track showSendEmailModal = false;
    @track pageOrientation = 'Potrait';
    @track saveRecordToAttachmentLabel;
    @track pageSizeOptions = [
        { label: 'A4', value: 'A4' },
        { label: 'A5', value: 'A5' },
        { label: 'Letter', value: 'Letter' },
    ];
    @track  pageOrientationOptions = [
        { label: 'Potrait', value: 'Potrait' },
        { label: 'LandScape', value: 'LandScape' }
    ];
  
    downloadURL;
    pdfdocumentid;
    showModal=true;
    isLoaded=false;
    selectedTemplateId;    
    showTemplate=false;
    templateWhereClause2;
    showPreviewButton=false;
    showGenerateButton=false;
    showSaveAttachmentButton=false;
    showTemplateSelectionHolder=true;
    templateWhereClause="IsActive__c = true";
    pageProperties = {'pageSize' : 'A4','pageOrientation' : 'Potrait'};

    @wire(getRecord, { recordId: "$recordId" })
    recordDetails;

    handlePdfModeSelection(event) {
        this.pageSize = (event.target.label === 'Page Size') ? event.target.value : this.pageSize;
        this.pageOrientation = (event.target.label === 'Page Orientation') ? event.target.value : this.pageOrientation;
        this.pageProperties.pageSize = this.pageSize;
        this.pageProperties.pageOrientation = this.pageOrientation;
    }

    connectedCallbackHandler() {
        this.saveRecordToAttachmentLabel = `Save as Attachment`;
        this.templateWhereClause2 = ` Related_To_Type__c = \'${this.objectApiName}\'`;
        this.selectedTemplateId=undefined;
        this.showTemplate=false;
        this.showPreviewButton =false;
        this.showSaveAttachmentButton=false;
        this.showGenerateButton=false;
        this.template.addEventListener('showgenerate', this.handleGeneration.bind(this));
    }

    handleGeneration(event){
        this.showGenerateButton = true;
    }

    connectedCallback() {
        this.connectedCallbackHandler();
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {}, 0);
    }

    selectItemEventHandler(event){
        this.selectedTemplateId = event.detail.selectedRecord.recordId;
        if(this.selectedTemplateId!=undefined){
            this.showTemplate=true;
            this.showTemplateSelectionHolder=true;
        }
    }

    updateItemEventHandler(event){
        this.showTemplate=false;
        this.showPreviewButton =false;
        this.showGenerateButton=false;
        this.selectedTemplateId=undefined;
        this.showSaveAttachmentButton=false;
        this.pageOrientation = 'Potrait';
    }

    closeModal(){
        this.showModal=false;
    }

    handlePDF() {
        this.isLoaded=true;    
        this.modifiedPDFName = this.recordId;    
        this.template.querySelector('c-dx-show-selected-template').pageProperties = this.pageProperties;     
        this.template.querySelector('c-dx-show-selected-template').handlePDF();
    }

    handlepdfgeneration(event) {
        this.isLoaded=false;
        this.showGenerateButton = false;
        this.showPreviewButton = true;
        this.showSaveAttachmentButton =true;
        this.downloadURL=event.detail.downloadURL;
        this.pdfdocumentid=event.detail.attachmentid;
    }   

    previewPDF() {
        this.pageSize = 'A4';
        this.pageOrientation = 'Potrait';
        window.open(this.downloadURL, "_blank");
    }

    saveRecordToAttachment() {
        this.modifiedPDFName = (this.modifiedPDFName==" " || this.modifiedPDFName==null || this.modifiedPDFName.split(' ').length-1 == this.modifiedPDFName.length) ? this.recordId : this.modifiedPDFName;
        saveAsRecordAttachment({documentid : this.pdfdocumentid, quoteId:this.recordId, pdfName:this.modifiedPDFName})
        .then((result) => {            
            this.downloadURL = `/servlet/servlet.FileDownload?file=${result}`;
            this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: `PDF saved as an Attachment successfully.`, variant: 'success'}));
            this.showSaveAttachmentButton =false;     
        })
        .catch((error) => {
            this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: `PDF couldn't be saved as an Attachment, Please contact System Administrator.`, variant: 'error'}));
            console.log('Attachment saving failed! ', JSON.stringify(error));
        });
    }

    handlePDFRename(event){
        this.modifiedPDFName = event.detail.value;
    }

    renderedCallback() {
        Promise.all([ loadStyle(this, rte_tbl + '/rte_tbl1.css'), loadStyle( this, dexcpqcartstylesCSS )])
        .then(() => { console.log( 'Files loaded'); })
        .catch(error => { console.log( error.body.message ); });
    }
}