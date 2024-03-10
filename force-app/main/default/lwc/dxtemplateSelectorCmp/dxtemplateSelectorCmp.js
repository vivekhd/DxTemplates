import {api, LightningElement, track, wire } from 'lwc';
import {loadStyle } from 'lightning/platformResourceLoader';
import { getRecord, getSObjectInfo } from 'lightning/uiRecordApi';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import rte_tbl from '@salesforce/resourceUrl/rte_tbl';
import SavePDFtoQuote from '@salesforce/apex/DisplayPDFController.savePDFtoQuote';
import pdfModefun from '@salesforce/apex/DisplayPDFController.pdfMode';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class DxtemplateSelectorCmp extends NavigationMixin(LightningElement) {

    templateWhereClause= " IsActive__c = true";
    flag1 = true;
    templateWhereClause2;
    @track backtoObj;
    @track savePDFtoObj;
    @track sendEmailWithAttachment;
    header = "Template Selector";
    showModal=true;
    selectedTemplateId;
    showTemplate=false;
    showTemplateSelector=true;
    @api recordId;
    @api objectApiName;
    @api objectLabel;
    pdfmodeValue='Potrait';
    showpreviewbutton=false;
    showgeneratepdf=false;
    showsavepdftoquote=false;
    showsendemail = false;
    downloadURL;
    isLoaded=false;
    pdfdocumentid;
    pdf={};
    currentPageReference;
    @track isDisabled = true;
    @track showSendEmailModal = false;
    @track modifiedPDFName ;

    get pdfmodeoptions() {
        return [
            { label: 'Potrait', value: 'potrait' },
            { label: 'Landscape', value: 'Landscape' },
        ];
    }

    @wire(CurrentPageReference)
    getCurrentPageReference(currentPageReference) {

         this.backtoObj="Back to "+this.objectLabel;
         this.savePDFtoObj = "Save PDF to "+this.objectLabel;
         this.sendEmailWithAttachment = "Send Email With "+ this.objectLabel+" PDF Attachment";
         
          this.templateWhereClause2 = " Related_To_Type__c = "+ "\'"+this.objectApiName+ "\'";
          console.log('templateWhereClause2 '+this.templateWhereClause2);
        console.log('CurrentPageReference Method',currentPageReference);
      this.currentPageReference = currentPageReference;
      console.log(this.currentPageReference.state.c__recordId);
      if( this.recordId != this.currentPageReference.state.c__recordId){
        console.log(' IF CurrentPageReference Method');

        this.selectedTemplateId=undefined;
        this.showTemplate=false;
        this.showpreviewbutton =false;
        this.showsavepdftoquote=false;
        this.showsendemail = false;
        this.showgeneratepdf=false;
        this.recordId = this.currentPageReference.state.c__recordId;
        this.template.querySelector('c-multi-lookup-component').clearPills();
        console.log('Inside-->'+this.currentPageReference.state.c__recordId);
      }else{
        console.log('ELSE CurrentPageReference Method');
      }
    }

    connectedCallback() {
       
    //    console.log('objectApiName '+this.objectName);
    //    SObject record = this.recordId.getSObject();
    //    sObjectName = record.getSObjectType().getDescribe().getName();
    
        // if(this.flag1 === true)
        // {
        //     window.location.reload();
        //     this.flag1 = false;
        // }

        console.log('QUOTEID',this.recordId);
       window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {

        }, 0);
      
    }

    selectItemEventHandler(event){
        this.selectedTemplateId = event.detail.selectedRecord.recordId;
        if(this.selectedTemplateId!=undefined){
            this.showTemplate=true;
            this.showTemplateSelector=true;
            this.showgeneratepdf = true;
        }
    }

    updateItemEventHandler(event){
        this.selectedTemplateId=undefined;
        this.showTemplate=false;
        this.showpreviewbutton =false;
        this.showsavepdftoquote=false;
        this.showsendemail = false;
        this.showgeneratepdf=false;

    }

    closeModal(){
        this.showModal=false;
    }

    handlePDF()
    {
        this.isLoaded=true;        
        this.template.querySelector('c-dx-show-selected-template').handlePDF();
        this.modifiedPDFName = this.recordId;
    }

    handlepdfgeneration(event)
    {
        this.showgeneratepdf = false;
        this.showpreviewbutton=true;
        this.showsavepdftoquote =true;
        console.log('handlepdfgeneration-',JSON.stringify(event));
        this.downloadURL=event.detail.downloadURL;
        this.pdfdocumentid=event.detail.attachmentid;
        this.isLoaded=false;
    }   

    previewPDF()
    {
        // this.showpreview=true;
        // this.template.querySelector('c-modal').show();
        
        var url = this.downloadURL; // get from processing apex response
        window.open(url, "_blank");
         
    }

    onpdfselection(event)
    {
        this.pdfmodeValue = event.detail.value;
        this.pdf.pdfModes1=this.pdfmodeValue;
        console.log('helloWorld',this.pdfmodeValue);
        console.log('this.pdf',this.pdf);
        this.pdfSize();
    }

    pdfSize()
    {
        console.log('kkk',this.pdf);
        pdfModefun({wrapperdata: this.pdf})
        .then(kushik => {             
            console.log('send Data',kushik);  
        })
        .catch(error =>{
            console.log('error in JS',error);
        });
    }

    savePDFtoQuote()
    {
        console.log('savePDFtoQuote-',this.pdfdocumentid);
        if(this.modifiedPDFName==" " || this.modifiedPDFName==null || this.modifiedPDFName.split(' ').length-1 == this.modifiedPDFName.length){
            this.modifiedPDFName = this.recordId;
        }
        SavePDFtoQuote({documentid : this.pdfdocumentid, quoteId:this.recordId, pdfName:this.modifiedPDFName})
        
        .then((result) => {            
            console.log('this is result'+JSON.parse(JSON.stringify(result)));
            console.log('this is result',result);
            this.downloadURL = '/servlet/servlet.FileDownload?file='+result;
            const event4 = new ShowToastEvent({
                title: 'Success',
                message:
                'Saved as attachment to the record!',
                variant: 'success',
                });

                this.dispatchEvent(event4);
                this.showsavepdftoquote =false;
                this.showsendemail=true;            
        })
        .catch((err) => {
            console.log('this is error savePDFtoQuote',err);
        });
    }
    // selectedTemplateHandler(){
    //     if(this.selectedTemplateId!=undefined){
    //         this.showTemplate=true;
    //         this.showTemplateSelector=true;
    //     }
    // }

    handlePDFRename(event){
        console.log('Renaming ' + event);
        this.modifiedPDFName = event.detail.value;
    }

    renderedCallback(){
        console.log('Inside RenderedCallback');
        Promise.all([
          loadStyle(this, rte_tbl + '/rte_tbl1.css'),
          loadStyle( this, dexcpqcartstylesCSS )
          ]).then(() => {
              console.log( 'Files loaded');
          })
          .catch(error => {
              console.log( error.body.message );
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
          this.cssMaxorMinClass2 = this.buttonClicked ? 'dxcappcontainer2max': 'dxcappcontainer2nor';
          this.iconMaxorMinName = this.buttonClicked ? 'utility:pop_in': 'utility:new_window';
          this.titleMaxorMinName =  this.buttonClicked ? 'Minimize Window': 'Maximize Window';
      }

    // Modified by Rahul
    handleBacktoQuote(event){
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

    //js for calling screen flow in seperate modal

    showSendEmailMethod(event)
    {
        this.showSendEmailModal = true;
        //this.isDisabled = true;
        // const flowStatus = this.template.querySelector('c-call-flow').handleInputChange();
        // console.log('flowStatus->',flowStatus );
    }

    submitDetails()
    {
        this.showSendEmailModal = false;
    }

    closeModal()
    {
        this.showSendEmailModal = false;
    }

    disconnectedCallback() {
        this.showTemplate = false;
    }

}