import { LightningElement, track, wire, api } from 'lwc';
import getDocumentTemplates from '@salesforce/apex/SaveDocumentTemplate.getDocumentTemplates';
import createDocumentTemplate from '@salesforce/apex/SaveDocumentTemplate.createDocumentTemplate';
import getRelatedToTypeOptions from '@salesforce/apex/SaveDocumentTemplate.getRelatedToTypeOptions';
import createLog from '@salesforce/apex/LogHandler.createLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';

export default class DxTemplateSetup extends LightningElement {

    @track docGridData = [];
    relatedtoTypeObj;
    relatedToTypeBeforeSave;
    documentsExist = false;
    @track selectedDocumentId;
    allDocumentTemplates = [];
    showAddNewTemplate = false;
    popUpMessage;

    @api relatedTypeOptions = [];
    @api templateRelatedTo

    @wire(getAllPopupMessages)
    allConstants({ error, data }) {
        if (data) {
            this.popUpMessage = data;
        } else {
            this.error = error;
        }
    }

    connectedCallback() {
        this.documentsExist = false;
        this.docGridData = [];
        this.getRelatedToTypeOptionValues();
        this.getDocumentTemplatesMethod();
    }

    
   getRelatedToTypeOptionValues()  {
        getRelatedToTypeOptions()
            .then(data => {
                if (data && data.length > 0) {
                    let optionList = [];
                    data.forEach(option => {
                        optionList.push({'label':option.DxCPQ__Related_To_Type__c,'value':option.DxCPQ__Related_To_Type__c});
                    })
                    optionList.push({'label':'All','value':null});
                    this.relatedTypeOptions = optionList ;
                }
            })
            .catch(error => {
                  let tempError = error.toString();
            let errorMessage = error.message || 'Unknown error message';
            createLog({recordId:'', className:'dxTemplateSetup LWC Component', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
            })

    }

    getDocumentTemplatesMethod() {
        getDocumentTemplates({ filterValue: this.templateRelatedTo })
        .then(data => {
            if (data && data.length > 0) {
                this.allDocumentTemplates = data;
                data.forEach(docTemp => {
                    this.docGridData.push({ label: docTemp.Name + ' - v' + docTemp.DxCPQ__Version_Number__c, Name: docTemp.Id, sObjectName: docTemp.DxCPQ__Related_To_Type__c });
                });
                this.selectedDocumentId = this.docGridData[0].Name;
                this.relatedtoTypeObj = this.docGridData[0].sObjectName;
                this.showAddNewTemplate = true;
                this.showUpdatedTemplate = true;
                this.documentsExist = true;
                if (this.templateRelatedTo != null) {
                    const tempEvent = {'detail':{'row':{'Name':this.selectedDocumentId}}};
                    this.handleTemplateSelection(tempEvent);
                }
            }
        })
        .catch(error => {
              let tempError = error.toString();
            let errorMessage = error.message || 'Unknown error message';
            createLog({recordId:'', className:'dxTemplateSetup LWC Component', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
        })
    }

    handleFilterSelection(event) {
        this.templateRelatedTo = event.detail.value;
        this.connectedCallback();
    }

    handleTemplateSelection(event) {
        this.showUpdatedTemplate = false;
        this.selectedDocumentId = event.detail.row.Name;
        let templateRecord;
        this.allDocumentTemplates.forEach(temp => {
            if (temp.Id == this.selectedDocumentId) {
                templateRecord = temp;
            }
        })
        this.showUpdatedTemplate = true;
        this.template.querySelector('c-template-designer-c-m-p').resetallvaluesonAllcmp();
        this.template.querySelector('c-template-designer-c-m-p').handleConnectedCallback(templateRecord);
        this.template.querySelector('c-template-designer-c-m-p').passingObject(this.relatedtoTypeObj);
    }

    handleNewTemplateCreation(event) {
        this.selectedDocumentId = event.detail.id;
        let templateName = event.detail.name;
        this.relatedtoTypeObj = event.detail.templateObjName;
        this.allDocumentTemplates.splice(0, 0, event.detail.templateObj);
        this.documentsExist = false;
        this.docGridData.splice(0, 0, { label: templateName + ' - v' + event.detail.templateObj.DxCPQ__Version_Number__c, Name: this.selectedDocumentId, sObjectName: this.relatedtoTypeObj });
        this.template.querySelector('c-menu-setup').passOn(this.docGridData);
        this.documentsExist = true;
        this.template.querySelector('c-template-designer-c-m-p').resetallvaluesonAllcmp();
        this.template.querySelector('c-template-designer-c-m-p').handleConnectedCallback(event.detail.templateObj);
    }

    handleNewTemplateCreationwithoutEvent(docid, docname, docObj, docrecord) {
        this.selectedDocumentId = docid;
        this.relatedtoTypeObj = docObj;
        let templateName = docname;
        this.allDocumentTemplates.splice(0, 0, docrecord);
        this.documentsExist = false;
        this.docGridData.splice(0, 0, { label: templateName + ' - v' + docrecord.DxCPQ__Version_Number__c, Name: this.selectedDocumentId, sObjectName: this.relatedtoTypeObj });
        this.template.querySelector('c-menu-setup').passOn(this.docGridData);
        this.documentsExist = true;
        this.template.querySelector('c-template-designer-c-m-p').resetallvaluesonAllcmp();
        this.template.querySelector('c-template-designer-c-m-p').handleConnectedCallback(docrecord);
    }

    deleteTemplateHandler(event) {
        let delTempId = event.detail.id;
        for (let i = 0; i < this.docGridData.length; i++) {
            if (this.docGridData[i].Name == delTempId) {
                this.docGridData.splice(i, 1);
            }
        }

        for (let i = 0; i < this.allDocumentTemplates.length; i++) {
            if (this.allDocumentTemplates[i].Id == delTempId) {
                this.allDocumentTemplates.splice(i, 1);
            }
        }

        this.template.querySelector('c-menu-setup').passOn(this.docGridData);
        this.selectedDocumentId = this.docGridData[0].Name;
        this.template.querySelector('c-template-designer-c-m-p').resetallvaluesonAllcmp();
        this.template.querySelector('c-template-designer-c-m-p').handleConnectedCallback(this.allDocumentTemplates[0]);
    }

    editTemplateHandler(event) {
        let editTempId = event.detail.id;
        let editTempName = event.detail.name;
        this.allDocumentTemplates.forEach(temp => {
            if (temp.Id == event.detail.Id) {
                temp = event.detail.templateObj;
            }
        })
        for (let i = 0; i < this.docGridData.length; i++) {
            if (this.docGridData[i].Name == editTempId) {
                this.docGridData[i].label = editTempName + ' - v' + event.detail.version;
            }
        }
        this.template.querySelector('c-menu-setup').passOn(this.docGridData);
    }

    handleNewTemplateCreationscreen(event) {
        var createdoccheck = event.detail.newtemplatecreation;
        if (createdoccheck == true) {
            this.showAddNewTemplate = true;
            this.template.querySelector('c-modal').show();
        }
    }

    handleRelatedToTypeChange(event) {
        //this.relatedtoTypeObj = event.target.value;
        this.relatedToTypeBeforeSave = event.target.value;
    }

    handleCreateSubmit(event) {
        event.preventDefault();
        let docTempObj = { 'sobjectType': 'Document_Template__c' };
        const fields = event.detail.fields;
        docTempObj.Name = fields.Name;
        docTempObj.DxCPQ__IsActive__c = fields.DxCPQ__IsActive__c;
        docTempObj.DxCPQ__Related_To_Type__c = fields.DxCPQ__Related_To_Type__c;
        docTempObj.DxCPQ__Description__c = fields.DxCPQ__Description__c;
        docTempObj.DxCPQ__Version_Number__c = fields.DxCPQ__Version_Number__c;
        this.relatedtoTypeObj = this.relatedToTypeBeforeSave;

        createDocumentTemplate({ docTemp: docTempObj }).then(result => {
            if (result) {
                this.handleNewTemplateCreationwithoutEvent(result.Id, result.Name, result.DxCPQ__Related_To_Type__c, result);
                if (this.relatedtoTypeObj != null || this.relatedtoTypeObj != undefined) {
                    this.showUpdatedTemplate = true;
                    this.template.querySelector('c-template-designer-c-m-p').passingObject(this.relatedtoTypeObj);
                    this.showAddNewTemplate = false;
                }

                const toastEvt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Template "' + docTempObj.Name + '" was Created',
                    variant: 'Success',
                });
                this.dispatchEvent(toastEvt);
                this.template.querySelector('c-modal').hide();
            }
        }).catch(error => {
            let tempError = error.toString();
            let errorMessage = error.message || 'Unknown error message';
            createLog({recordId:'', className:'dxTemplateSetup LWC Component', exceptionMessage:errorMessage, logData:tempError, logType:'Exception'});
       

        })
    }
}