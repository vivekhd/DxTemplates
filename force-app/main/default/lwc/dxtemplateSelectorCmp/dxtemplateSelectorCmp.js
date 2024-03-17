import {api, LightningElement, track, wire } from 'lwc';
import {loadStyle } from 'lightning/platformResourceLoader';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import rte_tbl from '@salesforce/resourceUrl/rte_tbl';
import SavePDFtoQuote from '@salesforce/apex/DisplayPDFController.savePDFtoQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import createLog from '@salesforce/apex/LogHandler.createLog';

export default class DxtemplateSelectorCmp extends NavigationMixin(LightningElement) {

    templateWhereClause = " IsActive__c = true";
    flag1 = true;
    templateWhereClause2;
    @track backtoObj;
    @track savePDFtoObj;
    @track sendEmailWithAttachment;
    header = "Template Selector";
    showModal = true;
    selectedTemplateId;
    showTemplate = false;
    showTemplateSelector = true;
    @api recordId;
    @api objectApiName;
    @api objectLabel;
    @api recordName;
    showpreviewbutton = false;
    showgeneratepdf = false;
    showsavepdftoquote = false;
    showsendemail = false;
    downloadURL;
    isLoaded = false;
    pdfdocumentid;
    pdf = {};
    currentPageReference;
    @track isDisabled = true;
    @track showSendEmailModal = false;
    @track modifiedPDFName;

    @wire(CurrentPageReference)
    getCurrentPageReference(currentPageReference) {
        debugger;
        this.backtoObj = "Back to " + this.objectLabel;
        this.savePDFtoObj = "Save PDF to " + this.objectLabel;
        this.sendEmailWithAttachment = "Send Email With " + this.objectLabel + " PDF Attachment";
        this.templateWhereClause2 = " Related_To_Type__c = " + "\'" + this.objectApiName + "\'";
        this.currentPageReference = currentPageReference;
        if (this.recordId != this.currentPageReference.state.c__recordId) {
            this.selectedTemplateId = undefined;
            this.showTemplate = false;
            this.showpreviewbutton = false;
            this.showsavepdftoquote = false;
            this.showsendemail = false;
            this.showgeneratepdf = false;
            this.recordId = this.currentPageReference.state.c__recordId;
            this.template.querySelector('c-multi-lookup-component').clearPills();
        }
    }

    connectedCallback() {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => { }, 0);
        let dateKey = new Date().toLocaleString().split(', ');
        this.modifiedPDFName = this.recordName + '-' + dateKey[0].replaceAll('/','') + '-' + dateKey[1].split(' ')[0].replaceAll(':','');
    }

    selectItemEventHandler(event) {
        this.selectedTemplateId = event.detail.selectedRecord.recordId;
        if (this.selectedTemplateId != undefined) {
            this.showTemplate = true;
            this.showTemplateSelector = true;
            this.showgeneratepdf = true;
        }
    }

    updateItemEventHandler() {
        this.selectedTemplateId = undefined;
        this.showTemplate = false;
        this.showpreviewbutton = false;
        this.showsavepdftoquote = false;
        this.showsendemail = false;
        this.showgeneratepdf = false;
    }

    closeModal() {
        this.showModal = false;
        this.showSendEmailModal = false;
    }

    handlePDF() {
        this.isLoaded = true;
        this.template.querySelector('c-dx-show-selected-template').handlePDF();
    }

    handlepdfgeneration(event) {
        this.showgeneratepdf = false;
        this.showpreviewbutton = true;
        this.showsavepdftoquote = true;
        this.downloadURL = event.detail.downloadURL;
        this.pdfdocumentid = event.detail.attachmentid;
        this.isLoaded = false;
    }

    previewPDF() {
        window.open(this.downloadURL, "_blank");
    }

    savePDFtoQuote() {
        SavePDFtoQuote({ documentid: this.pdfdocumentid, quoteId: this.recordId, pdfName: this.modifiedPDFName })
        .then((result) => {
            this.downloadURL = '/servlet/servlet.FileDownload?file=' + result;
            const event4 = new ShowToastEvent({
                title: 'Success',
                message: `PDF document is saved under ${this.objectLabel} successfully!`,
                variant: 'success',
            });
            this.dispatchEvent(event4);
            this.showsavepdftoquote = false;
            this.showsendemail = true;
        })
        .catch(() => {
            const event4 = new ShowToastEvent({
                title: 'Error',
                message: `An Error occurred while saving the PDF document. Please contact the System Administrator.`,
                variant: 'error',
            });
            this.dispatchEvent(event4);
        })
    }

    handlePDFRename(event) {
        this.modifiedPDFName = event.detail.value;
    }

    renderedCallback() {
        Promise.all([
                loadStyle(this, rte_tbl + '/rte_tbl1.css'),
                loadStyle(this, dexcpqcartstylesCSS)
            ]).then(() => {
            })
            .catch(error => {
                let tempError = error.toString();
                let errorMessage = error.message || 'Unknown error message';
                createLog({recordId:'', className:'dxtemplateSelectorCmp LWC Component', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
            });
    }

    buttonClicked; //defaulted to false
    @track cssMaxorMinClass2 = 'dxcappcontainer2nor';
    @track iconMaxorMinName = 'utility:new_window';
    @track titleMaxorMinName = 'Maximize Window';
    productBundleRelationship;

    //Handles click on the 'Show/hide content'button
    minorMaxWindow() {
        this.buttonClicked = !this.buttonClicked; //set to true if false, false if true.
        this.cssMaxorMinClass2 = this.buttonClicked ? 'dxcappcontainer2max' : 'dxcappcontainer2nor';
        this.iconMaxorMinName = this.buttonClicked ? 'utility:pop_in' : 'utility:new_window';
        this.titleMaxorMinName = this.buttonClicked ? 'Minimize Window' : 'Maximize Window';
    }

    // Modified by Rahul
    handleBacktoQuote() {
        //history.back();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        });
    }

    showSendEmailMethod() {
        this.showSendEmailModal = true;
    }

    submitDetails() {
        this.showSendEmailModal = false;
    }

    disconnectedCallback() {
        this.showTemplate = false;
    }

}
