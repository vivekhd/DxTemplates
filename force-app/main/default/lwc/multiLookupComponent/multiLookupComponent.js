import { LightningElement, api, track } from 'lwc';
import retrieveRecords from '@salesforce/apex/MultiSelectLookupController.retrieveRecords';
import createLog from '@salesforce/apex/LogHandler.createLog';

export default class DxMultiLookupComponent extends LightningElement {
    //code added by Bhavya for default template
    @api defaultTemplateName;

    @api objectApiName;
    @api labelName;
    @api fieldApiNames;
    @api filterFieldApiName;
    @api iconName;
    @api whereClause;
    @api whereClauseTwo;
    @api readOnly = false;
    @api isSectionClone = false;
    searchInput = "";
    @track
    selectedRecord;
    @api globalItems;
    @track globalSelectedItems = [];
    @track lstResult = [];
    @api placeholder = 'Search here...';
    isDisplayErrorMessage = false;
    isDialogDisplay = false;
    isDisplayMessage = false;
    @api hasMultiSelect;

    connectedCallback() {
        this.hasMultiSelect = this.hasMultiSelect !== undefined ? (this.hasMultiSelect === "true" ? true : false) : true;
        if (this.globalItems !== undefined && this.globalItems !== null) {
            if (this.globalItems instanceof Array) {
                this.globalSelectedItems = JSON.parse(JSON.stringify(this.globalItems));
            } else {
                this.selectedRecord = JSON.parse(JSON.stringify(this.globalItems));
            }
        }
    
        //console.log('The multi select feature is: ' + this.hasMultiSelect);
    
        if (this.defaultTemplateName !== '' && this.defaultTemplateName !== null) {
            const customEvent = {
                target: {
                    value: this.defaultTemplateName,
                }
            };
    
            // Call handleKeyChange and wait for it to complete using .then()
            Promise.resolve(this.handleKeyChange(customEvent))
                .then(() => {
                    // Now that lstResult is populated, call handleSelectedRecord for the first record
                    if (this.lstResult && this.lstResult.length > 0) {
                        const simulatedEvent = {
                            target: {
                                getAttribute: function(attr) {
                                    if (attr === 'data-recid') {
                                        return this.lstResult[0].recordId; // Get first record's id
                                    }
                                    return null;
                                }.bind(this)
                            }
                        };
                        
                        // Call handleSelectedRecord with the simulated event
                        this.handleSelectedRecord(simulatedEvent);
                    }
                })
                .catch((error) => {
                    console.error('Error in handleKeyChange: ', error);
                });
        }
    }
    

    @api
    selectedRecordHandler(record) {
        this.selectedRecord = record;
    }

    toggleResult(event) {
        this.lstResult = [];
        this.isDisplayErrorMessage = false;
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        }
    }

    handleKeyChange(event) {
        this.searchInput = event.target.value;
    
        if (this.isSectionClone) {
            this.whereClauseTwo = 'Name Like \'%' + this.searchInput + '%\' OR ' + 'DxCPQ__Document_Template__r.Name Like \'%' + this.searchInput + '%\'';
            this.filterFieldApiName = "";
        }
    
        this.lstResult = [];
        this.isDisplayErrorMessage = false;
    
        return new Promise((resolve, reject) => {
            if (this.searchInput.trim().length > 0) {
                retrieveRecords({
                    objectName: this.objectApiName,
                    fieldAPINames: this.fieldApiNames,
                    filterFieldAPIName: this.filterFieldApiName,
                    strInput: this.searchInput,
                    whereClauseTwo: this.whereClauseTwo ? this.whereClauseTwo : "",
                    whereClause: this.whereClause ? this.whereClause : "",
                    isSectionClone: this.isSectionClone
                })
                    .then(result => {
                        if (result.length > 0) {
                            this.lstResult = this.isSectionClone ? this.constructSectionLabel(result) : result;
                            this.isDialogDisplay = true;
                            this.isDisplayErrorMessage = false;
                        } else {
                            this.isDialogDisplay = false;
                            this.isDisplayErrorMessage = true;
                            this.lstResult = undefined;
                        }
                        resolve();  // Ensure promise resolves when done
                    })
                    .catch(error => {
                        this.error = error;
                        this.lstResult = undefined;
                        this.isDialogDisplay = false;
                        createLog({
                            recordId: this.templatesectionid,
                            className: 'multiLookupComponent LWC Component',
                            exceptionMessage: error.body.message,
                            LogData: error.body.exceptionType,
                            logType: 'Exception'
                        })
                        .then(result => { console.log('Log is generated'); })
                        .catch(error => { console.log('Log is not generated ' + JSON.stringify(error)); });
    
                        reject(error);  // Ensure promise rejects if there is an error
                    });
            } else {
                this.isDialogDisplay = false;
                resolve();  // Resolve immediately if input is blank
            }
        });
    }

    constructSectionLabel(inputJson) {
        const records = inputJson;
        
        records.forEach(record => {
            const docTemplate = record.recordObject.DxCPQ__Document_Template__r;
            record.sectionName = record.recordName;
            const newRecordName = `${docTemplate.Name}-V${docTemplate.DxCPQ__Version_Number__c}: ${record.recordName} (${record.recordObject.DxCPQ__Type__c})`;
            record.recordName = newRecordName;
            
        });
        
        return records;
    }

    handleSelectedRecord(event) {
        this.isDialogDisplay = false;
        var objId = event.target.getAttribute('data-recid');
        this.selectedRecord = this.lstResult.find(data => data.recordId === objId);
        const selectedRecord = this.selectedRecord;
        const singleRecordevt = new CustomEvent('singlepill', {
            detail: { selectedRecord }
        });
        this.dispatchEvent(singleRecordevt);
        // this.globalSelectedItems.push(this.selectedRecord);
        if (this.globalSelectedItems.some(action => action.recordId === this.selectedRecord.recordId)) {
            //alert("Object found inside the array.");
        } else {
            this.globalSelectedItems.push(this.selectedRecord);
        }
        this.searchInput = '';
        const updatedRows = this.globalSelectedItems;
        const evt = new CustomEvent('selectpill', {
            detail: { updatedRows }
        });
        this.dispatchEvent(evt);

    }

    handleRemoveRecord(event) {
        this.searchInput = '';
        this.selectedRecord = null;
        this.isDialogDisplay = false;
        const removeItem = event.target.dataset.item;
        this.globalSelectedItems = this.globalSelectedItems.filter(item => item.recordName != removeItem);
        const updatedRows = this.globalSelectedItems;
        const evt = new CustomEvent('removepill', {
            detail: { updatedRows }
        });
        this.dispatchEvent(evt);
    }

    @api
    updateWhereClause(updateCheck) {
        this.whereClause = updateCheck;
    }
    
    @api
    clearPills() {
        this.globalSelectedItems = [];
        this.searchInput = '';
        this.selectedRecord = null;
        this.isDialogDisplay = false;
    }

    @api
    existingRecords(globalSelecteddata) {
        this.globalSelectedItems = [];
        this.globalSelectedItems = globalSelecteddata;
    }

    @api
    existingSingleRecords(globalSelecteddata) {
        this.selectedRecord = [];
        this.selectedRecord = globalSelecteddata;
    }
}