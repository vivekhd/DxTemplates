import { LightningElement, track, api} from 'lwc';
import rte_tbl from '@salesforce/resourceUrl/rte_tbl';
import {loadStyle } from 'lightning/platformResourceLoader';
import createLog from '@salesforce/apex/LogHandler.createLog';
import { createRuleConditionHierarcy } from 'c/conditionUtil';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import getRelatedObjects from '@salesforce/apex/RelatedObjectsClass.getRelatedObjects';
import getConditions from '@salesforce/apex/RelatedObjectsClass.getExistingConditions';
import deletetemplate from '@salesforce/apex/SaveDocumentTemplatesection.deletetemplate';
import getSelectedRelatedObjectFields from '@salesforce/apex/MergeFieldsClass.getFields';
import createRuleCondition from '@salesforce/apex/RelatedObjectsClass.createRuleCondition';
import getSObjectListFiltering from '@salesforce/apex/RelatedObjectsClass.getSObjectListFiltering';
import getSelectedObjectPicklistFields from '@salesforce/apex/RelatedObjectsClass.getGroupingValues';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';
import resetRulesForTemplate from '@salesforce/apex/RelatedObjectsClass.handleTemplateRuleResetCondition';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';


export default class TemplateRelatedObjects extends LightningElement {

    @api selectedObjectName;
    @api showrelatedobjectdetails;
    @api documenttemplaterecordid;
    @api documenttemplaterecord;
    @api disableButton = false;
    @api disabledeleteButton = false;
    @api sectiontype = '';
    @api rowcount;
    @api sectionrecordid;

    @track showPicklist = false;
    @track categoryStyleClass;
    @track showCalculatorFields = false;
    @track Recorddetailsnew = {
        Name: '',
        DxCPQ__Section_Content__c: '',
        DxCPQ__New_Page__c: false,
        DxCPQ__Document_Template__c: '',
        DxCPQ__Sequence__c: 0,
        DxCPQ__Type__c: '',
        Id: '',
        DxCPQ__RuleId__c: '',
    };
    @track displayTableCategoryData = [];  
    @track formats = ['font'];
    @track listOfRelatedObjects = [];
    @track listOfAddedFields = [];
    @track displayTableHeaderData = [];
    @track displayTableRowData = [];
    @track allRelatedObjectsChoiceSet;
    @track numericFieldsForSubTotalSelection = [];
    @track selectedFieldsForSubTotalCalculation = [];
    @track selectedSubTotalFieldLabelsList = [];
    @track selectedSubTotalFieldAPIList = [];
    referenceObjectsFieldDetailsMap = {};

    listOfRemovedFields = [];
    chartLabel = 'Chart';
    selectedBarChartColor = '#007CBA';
    selectedFieldToBeRemoved;
    selectedField;
    selectedfields;
    showChartBox = true;
    loadDisplayTableContent = false;
    displaySaveTableButton = false;
    selectedChildObjectName;
    savedRecordID;
    isLoaded = false;
    fontsize = "10px";
    selectedHFontColor = 'black';
    selectedBFontColor = 'black';
    selectedHbgColor = 'white';
    selectedBBgcolor = 'white';
    SerialNumber = false;
    subtotal = false;
    showdate = true;
    showtime = true;
    shownumber = true;
    showcurrency = true;
    subTotalFieldListForChartGeneration = [];
    selectedSubTotalFieldForChartGeneration;
    relatedRecordsGrouping = false;
    nosubTotal = false;
    displayChartSection = false;
    chartControl = false;
    chartNewPage = true;
    newPage = false;
    sectionSpan;
    selectedGroupingPicklistOption = null;
    ruleCondition = false;
    selectedTableRow;
    childobjects;
    changedHeaders = [];
    renamedHeaderLabel;
    displayfields = false;
    loadUp = false;
    showpicklistValues = false;
    selectedRelatedObjectPicklistFields = [];
    selectedObjectAllPicklistValueSet = [];
    selectedPicklistFieldValueSet = [];
    checkTotals = [];
    dateFormatvalue = '564/';
    timeFormatvalue = '124';
    numFormatvalue = '2';
    curFormatvalue = '1';
    renderedData = false;

    //SubTotal and Total BG Color
    selectedSubTotalBGColor = '#0077b6';
    selectedTotalBGColor = '#03045e';
    selectedSubTotalFontColor = '#FFFFFF';
    selectedTotalFontColor = '#FFFFFF';

    // Filtering params
    listOfExistingConditions = [];
    conditionsArr;
    selectedGlobalValue;
    ruleExpression;
    ruleConditions = [];
    ruleConditionsWrapper;
    listOfActualConditions;
    conditionExists = false;
    allConditions = [];
    ruleIdCreated = '';
    ruleExists = false;
    hasSpecialCharacter = false;

    get numformats() {
        return [{
                label: 'x',
                value: '0'
            },
            {
                label: 'x.y',
                value: '1'
            },
            {
                label: 'x.yz',
                value: '2'
            },
            {
                label: 'x.yza',
                value: '3'
            }
        ];
    }

    get curformats() {
        return [{
                label: 'x',
                value: '0'
            },
            {
                label: 'x.y',
                value: '1'
            },
            {
                label: 'x.yz',
                value: '2'
            },
            {
                label: 'x.yza',
                value: '3'
            }
        ];
    }

    get timeformats() {
        return [{
                label: 'HH : MM XM (12 hr)',
                value: '124'
            },
            {
                label: 'HH : MM : SS XM (12 hr)',
                value: '1234'
            },
            {
                label: 'HH : MM (24 hr)',
                value: '12'
            },
            {
                label: 'HH : MM : SS (24 hr)',
                value: '123'
            }
        ];
    }

    get dateformats() {
        return [{
                label: 'mm/dd/yyyy',
                value: '564/'
            }, {
                label: 'MMM/dd/yyyy',
                value: '564/*'
            },
            {
                label: 'dd/mm/yyyy',
                value: '654/'
            }, {
                label: 'dd/MMM/yyyy',
                value: '654/*'
            },
            {
                label: 'yyyy/dd/mm',
                value: '465/'
            }, {
                label: 'yyyy/mm/dd',
                value: '456/'
            },
            {
                label: 'mm-dd-yyyy',
                value: '564-'
            }, {
                label: 'MMM-dd-yyyy',
                value: '564-*'
            },
            {
                label: 'dd-mm-yyyy',
                value: '654-'
            }, {
                label: 'dd-MMM-yyyy',
                value: '654-*'
            },
            {
                label: 'yyyy-dd-mm',
                value: '465-'
            },
            {
                label: 'yyyy-mm-dd',
                value: '456-'
            }, {
                label: 'yyyy-MMM-dd',
                value: '456-*'
            },
            {
                label: 'mm/dd/yy',
                value: '562/'
            }, {
                label: 'MMM/dd/yy',
                value: '562/*'
            },
            {
                label: 'dd/mm/yy',
                value: '652/'
            }, {
                label: 'dd/MMM/yy',
                value: '652/*'
            },
            {
                label: 'mm-dd-yy',
                value: '562-'
            }, {
                label: 'MMM-dd-yy',
                value: '562-*'
            },
            {
                label: 'dd-mm-yy',
                value: '652-'
            },
        ];
    }

    get enableChartConfigurationOption(){
        return this.isDisabled && this.showCalculatorFields;
    }

    calculateOptions = [{
            label: 'Calculate grand total',
            value: 'CalculateGrandTotal'
        },
        {
            label: 'calculate SubTotal',
            value: 'calculateSubTotal'
        }
    ];

    fontsizeoptions = [{
            value: '8px',
            label: '8'
        }, {
            value: '9px',
            label: '9'
        }, {
            value: '10px',
            label: '10'
        }, {
            value: '12px',
            label: '12'
        },
        {
            value: '13px',
            label: '13'
        }, {
            value: '14px',
            label: '14'
        }, {
            value: '15px',
            label: '15'
        }, {
            value: '16px',
            label: '16'
        },
    ];

    fontfamily = 'Verdana';
    fontfamilyoptions = [{
            value: 'Arial',
            label: 'Arial'
        },
        {
            value: 'Verdana',
            label: 'Verdana'
        },
        {
            value: 'Times New Roman',
            label: 'Times New Roman'
        },
        {
            value: 'Georgia',
            label: 'Georgia'
        },
        {
            value: 'Courier New',
            label: 'Courier New'
        },
        {
            value: 'Brush Script MT',
            label: 'Brush Script MT'
        }
    ];

    @track chartWithDemoData = [{
            "label": "group-1",
            "percent": "23%",
            "height": `height:23%; background-color:${this.selectedBarChartColor}`,
            "width": "width : 13.571428571428571%;",
            "value": 2367510
        },
        {
            "label": "group-2",
            "percent": "32%",
            "height": `height:32%; background-color:${this.selectedBarChartColor}`,
            "width": "width : 13.571428571428571%;",
            "value": 256372
        },
        {
            "label": "group-3",
            "percent": "20%",
            "height": `height:20%; background-color:${this.selectedBarChartColor}`,
            "width": "width : 13.571428571428571%;",
            "value": 2867396
        },
        {
            "label": "group-4",
            "percent": "9%",
            "height": `height:9%; background-color:${this.selectedBarChartColor}`,
            "width": "width : 13.571428571428571%;",
            "value": 1257704
        },
        {
            "label": "Others",
            "percent": "16%",
            "height": `height:16%; background-color:${this.selectedBarChartColor}`,
            "width": "width : 13.571428571428571%;",
            "value": 2327405
        }
    ];

    //Template specific fix
    sectionItemsToselect = [{
            label: 'New Page',
            value: 'New Page'
        },
        {
            label: 'Display Section Name',
            value: 'Display Section Name'
        }
    ];

    connectedCallback() {
        this.displayTableHeaderData = [];
        this.displayTableCategoryData = [];
        this.renderedData = false;
    }

    @api clearChildObjSelection() {
        this.renderedData = false;
        this.showPicklist = false;
        this.displayfields = false;
        this.loadDisplayTableContent = false;
    }

    /*
      Styles are getting loaded here
    */
    renderedCallback() {
        Promise.all([
                loadStyle(this, rte_tbl + '/rte_tbl1.css'),
                loadStyle(this, dexcpqcartstylesCSS),
            ])
            .then(() => {})
            .catch(error => {
                createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});        
            });

        this.newfontsize();
    }

    @api handleObjectNameSelection(objName) {
        getRelatedObjects({ selectedObject: objName })
        .then(result => {
            if (result != null) {
                let options = Object.keys(result).map((key) => ({label: key, value: key}));
                if (options != null && options != undefined) {
                    this.allRelatedObjectsChoiceSet = options;
                    this.childobjects = result;
                    if (!!this.allRelatedObjectsChoiceSet && !!this.childobjects) {
                        this.renderedData = true;
                    }
                }
            }
        })
        .catch(error => {
            createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
        })
    }

    @api handleActivateTemplate(isActive, objName) {
        this.selectedObjectName = objName;
        this.isDisabled = isActive;
        this.disableButton = isActive;
        this.disabledeleteButton = isActive;
    }

    /*
    This function deals with the new page part in the sections.
    We have a new page checkbox on template creation UI.
    Once the user selects the new page for a particular section, then that section appears in the next page.
    */
    handlecheckboxChange(event) {
        const mystring = JSON.stringify(event.detail.value);
        this.Recorddetailsnew.DxCPQ__New_Page__c = mystring.includes('New Page');
    }

    /*
    This function handles the deletion part of a section
    */
    handlesectionDelete() {
        if (this.sectionrecordid.indexOf('NotSaved') !== -1) {
            this.dispatchEvent(new CustomEvent('deletesectiondata', {detail: this.sectionrecordid}));
        } else {
            deletetemplate({ secidtobedeleted: this.sectionrecordid, doctemplateid: this.documenttemplaterecordid })
            .then(result => {
                if (result != null) {
                    this.dispatchEvent(new CustomEvent('deletesectiondata', {
                        detail: this.sectionrecordid
                    }));
                }
            })
            .catch(error => {
                createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
            })
        }
    }

    // This function takes the user input for the section name 
    handlename(event) {
        this.Recorddetailsnew.Name = event.detail.value;
    }

    @api assignDocTempId(recordID) {
        this.documenttemplaterecordid = recordID;
    }

    // This function resets all the listed parameters below
    @api resetvaluesonchildcmp() {
        this.isLoaded = true;
        this.documenttemplaterecordid = '';
        this.Recorddetailsnew = {
            Name: '',
            DxCPQ__Section_Content__c: '',
            DxCPQ__New_Page__c: false,
            DxCPQ__Document_Template__c: '',
            DxCPQ__Sequence__c: 0,
            DxCPQ__Type__c: '',
            DxCPQ__RuleId__c: '',
            Id: '',
        };
        this.selectedfields = '';
        this.selectedChildObjectName = '';
        this.displayfields = false;
        this.loadDisplayTableContent = false;
        this.displaySaveTableButton = false;
        this.displayTableHeaderData = [];
        this.displayTableCategoryData = [];
        this.relatedRecordsGrouping = false;
        this.chartControl = false;
        this.chartNewPage = true;
        this.listOfRelatedObjects = [];
        this.chartLabel = 'Chart';
        this.selectedBarChartColor = '#007CBA';
        this.showCalculatorFields = false;
        this.displayChartSection = false;
        this.selectedSubTotalFieldForChartGeneration = null;
        this.selectedGroupingPicklistOption = '';
        this.showPicklist = false;
        this.numericFieldsForSubTotalSelection = [];
        this.subTotalFieldListForChartGeneration = [];
        this.selectedFieldsForSubTotalCalculation = [];
        this.selectedSubTotalFieldLabelsList = [];
        this.selectedSubTotalFieldAPIList = [];
        this.newPage = false;
        this.changedHeaders = [];

        // Filtering QLIs reset
        this.filteringCondition = '';
        this.ruleConditionsWrapper = new Map();
        this.conditionsArr = [];
        this.conditionExists = false;
        this.allConditions = [];
        this.listOfExistingConditions = [];
        this.ruleIdCreated = '';
        this.hasSpecialCharacter = false;
        this.ruleExists = false;

        // reset values for styles
        this.selectedHFontColor = '';
        this.selectedHbgColor = '';
        this.selectedBFontColor = '';
        this.selectedBBgcolor = '';
        this.dateFormatvalue = '564/';
        this.timeFormatvalue = '124';
        this.numFormatvalue = '2';
        this.curFormatvalue = '1';
        this.fontfamily = "Verdana";
        this.fontsize = '10px';
        this.SerialNumber = false;
        this.categoryStyleClass = '';
        this.selectedTotalBGColor = '#03045e';
        this.selectedSubTotalBGColor = '#0077b6';
        this.selectedTotalFontColor = '#FFFFFF';
        this.selectedSubTotalFontColor = '#FFFFFF';
        this.referenceObjectsFieldDetailsMap = {};
        this.isLoaded = false;
        this.handleObjectNameSelection(this.selectedObjectName);
    }

    /*
      This function is used to display the data onload. 
      It displays the data related to the various sections
      a. Object Name
      b. Selected Fields
      c. Rules 
      d. Date Format
      e. Number Format
      f. Chart 
      g. Table
      h. Colors
      i. Attributes
    */
    @api 
    async loadsectionsectionvaluesforedit(recordID) {

        this.handleObjectNameSelection(this.selectedObjectName);
        this.isLoaded = true;
        this.sectionrecordid = recordID;
        this.Recorddetailsnew.Id = recordID;

        this.displayTableHeaderData = [];
        this.displayTableCategoryData = [];
        this.selectedRelatedObjectPicklistFields = [];
        this.newPage = false;
        this.ruleExists = false;
        this.changedHeaders = [];
        this.referenceObjectsFieldDetailsMap = {};
        this.selectedFieldsForSubTotalCalculation = [];

        const result = await gettemplatesectiondata({ editrecordid: recordID })
        if (result != null) {
            this.isLoaded = false;
            this.Recorddetailsnew.Name = result.Name;
            this.Recorddetailsnew.DxCPQ__Document_Template__c = result.DxCPQ__Document_Template__c;
            this.Recorddetailsnew.DxCPQ__Sequence__c = result.DxCPQ__Sequence__c;
            this.Recorddetailsnew.DxCPQ__Type__c = result.DxCPQ__Type__c;
            this.Recorddetailsnew.DxCPQ__New_Page__c = result.DxCPQ__New_Page__c;
            this.Recorddetailsnew.DxCPQ__Section_Content__c = result.DxCPQ__Section_Content__c;

            if (result.DxCPQ__RuleId__c != null && result.DxCPQ__RuleId__c != '') {
                this.Recorddetailsnew.DxCPQ__RuleId__c = result.DxCPQ__RuleId__r.Id;
                this.ruleExpression = result.DxCPQ__RuleId__r.DxCPQ__Rule_Expression__c;
            } else {
                this.Recorddetailsnew.DxCPQ__RuleId__c = '';
            }
            this.sectiontype = result.DxCPQ__Type__c;

            // Filtering On Load 
            if (result.DxCPQ__RuleId__r != null) {
                this.ruleIdCreated = result.DxCPQ__RuleId__r.Id;
                this.ruleExists = true;
            } else {
                this.ruleIdCreated = null;
                this.listOfExistingConditions = [];
                this.conditionsArr = [];
                this.ruleExists = false;
                this.filteringCondition = '';
            }

            if (this.ruleIdCreated != null && this.ruleIdCreated != '') {
                this.handleRuleWrapperMaking();
                let event = new Object();
                this.getExistingConditions(event);
                this.ruleExists = true;
            }
            this.newPage = result.DxCPQ__New_Page__c;

            if (result.DxCPQ__Section_Content__c != null && result.DxCPQ__Section_Content__c != undefined) {
                var sectionContentToLoad = JSON.parse(result.DxCPQ__Section_Content__c);
                this.showPicklist = true;
                this.value = sectionContentToLoad.mainChildObject;
                this.listOfRelatedObjects = [];
                this.loadUp = false;
                this.listOfAddedFields = [];
                this.numericFieldsForSubTotalSelection = [];
                this.showCalculatorFields = false;
                this.displayChartSection = false;

                if (sectionContentToLoad.mainChildObject) {
                    setTimeout(() => {
                        this.template.querySelector('c-search-category[data-id="childObject"]').setupOptions([{
                            label: sectionContentToLoad.mainChildObject,
                            value: sectionContentToLoad.mainChildObject,
                            selected: true
                        }]);
                    }, 2000);
                }

                if (sectionContentToLoad.grouping) {
                    this.showPicklist = true;
                    setTimeout(() => {
                        this.template.querySelector('c-search-category[data-id="picklist"]').setupOptions([{
                            label: sectionContentToLoad.grouping,
                            value: sectionContentToLoad.grouping,
                            selected: true
                        }]);
                    }, 1000);
                }

                this.displayfields = true;
                this.selectedfields = sectionContentToLoad.tablelistLabels;                   
                this.selectedChildObjectName = sectionContentToLoad.mainChildObject;
                this.handleTableDisplay(sectionContentToLoad.tablelistLabels, true);
                await this.handleObjectselection({ detail: { values: [sectionContentToLoad.mainChildObject] } });

                // Added Fields
                this.loadUp = true;                
                this.selectedSubTotalFieldAPIList = [];
                this.selectedSubTotalFieldLabelsList = [];
                for (let j = 0; j < sectionContentToLoad.tablelistValues.length; j++) {
                    let duplicationFlag = true;
                    
                    for (let i = 0; i < this.listOfRelatedObjects[0].fieldList.length; i++) {
                        if (this.listOfRelatedObjects[0].fieldList[i].value.toLowerCase() == sectionContentToLoad.tablelistValues[j].toLowerCase()) {
                            this.listOfAddedFields.push(this.listOfRelatedObjects[0].fieldList[i]);
                            if (this.listOfRelatedObjects[0].fieldList[i].dataType == "NUMBER" || this.listOfRelatedObjects[0].fieldList[i].dataType == "CURRENCY" || this.listOfRelatedObjects[0].fieldList[i].dataType == "DOUBLE") {
                                this.numericFieldsForSubTotalSelection.push(this.listOfRelatedObjects[0].fieldList[i]);
                                this.showCalculatorFields = true;
                            }
                            sectionContentToLoad.subTotal.forEach(key => {
                                if (key.toLowerCase() == this.listOfRelatedObjects[0].fieldList[i].value.toLowerCase()) {
                                    this.selectedSubTotalFieldLabelsList.push(this.listOfRelatedObjects[0].fieldList[i].label);
                                    this.selectedSubTotalFieldAPIList.push(this.listOfRelatedObjects[0].fieldList[i].value);
                                    this.selectedFieldsForSubTotalCalculation.push(this.listOfRelatedObjects[0].fieldList[i]);
                                }
                            });
                            if (sectionContentToLoad.tablelistLabels.indexOf(sectionContentToLoad.selGraphvalue) == j) this.selectedSubTotalFieldForChartGeneration = this.listOfRelatedObjects[0].fieldList[i].label;
                            this.listOfRelatedObjects[0].fieldList.splice(i, 1);
                            break;
                        }

                        if (sectionContentToLoad.tablelistValues[j].includes('.') && duplicationFlag) {
                            let referencedFieldLabel = sectionContentToLoad.tablelistValues[j].replace('.', '*');
                            let referenceObject = this.listOfRelatedObjects[0].fieldWrap.filter((fieldDetail) => fieldDetail.relationshipName == (referencedFieldLabel.replace(referencedFieldLabel.substring(referencedFieldLabel.indexOf('*')), '')));
                            if (referenceObject.length > 0 && duplicationFlag) {
                                let referencedFieldDetail;
                                let tempVar = referencedFieldLabel.replace(referencedFieldLabel.substring(0, referencedFieldLabel.indexOf('*') + 1), ''); 
                                if(this.referenceObjectsFieldDetailsMap[referenceObject[0].sObjectName]){
                                    referencedFieldDetail = this.referenceObjectsFieldDetailsMap[referenceObject[0].sObjectName].filter(fieldDetail => {  if(tempVar.toLowerCase() == fieldDetail.apiName.toLowerCase()) { return fieldDetail; } })[0];
                                } else{
                                    await getSelectedRelatedObjectFields({ selectedObject: referenceObject[0].sObjectName })
                                    .then(result => {
                                        this.referenceObjectsFieldDetailsMap[referenceObject[0].sObjectName] = result;
                                        referencedFieldDetail = result.filter(fieldDetail => {  if(tempVar.toLowerCase() == fieldDetail.apiName.toLowerCase()) { return fieldDetail; } })[0];
                                    })
                                    .catch((error) => {
                                        createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
                                    })
                                } 
                                if (referencedFieldDetail && duplicationFlag) {
                                    let referencedFieldLabel = this.handleReferencedFieldAdditionOnLoad(referenceObject[0], referencedFieldDetail, sectionContentToLoad.tablelistValues[j], sectionContentToLoad.subTotal);
                                    if (sectionContentToLoad.tablelistLabels.indexOf(sectionContentToLoad.selGraphvalue) == j) {
                                        this.selectedSubTotalFieldForChartGeneration = referencedFieldLabel;
                                    }
                                    duplicationFlag = false;
                                }                               
                            }
                            
                        }
                    }
                }
                this.subTotalFieldListForChartGeneration = this.selectedSubTotalFieldLabelsList.map((fieldLabel) => ({'label' : fieldLabel, 'value': fieldLabel}));
                this.selectedGroupingPicklistOption = sectionContentToLoad.grouping;
                if (sectionContentToLoad.grouping != null && sectionContentToLoad.grouping != "") {
                    this.relatedRecordsGrouping = true;
                    this.nosubTotal = false;
                    this.chartControl = false;
                    this.displayTableCategoryData = sectionContentToLoad.groupingCatVals.map((picklistChoice) => {return picklistChoice.toUpperCase();})
                } else {
                    this.relatedRecordsGrouping = false;
                }

                // Styles on Load
                this.selectedHFontColor = sectionContentToLoad.style.header.fontcolor;
                this.selectedHbgColor = sectionContentToLoad.style.header.backgroundColor;
                this.selectedBFontColor = sectionContentToLoad.style.category.fontcolor;
                this.selectedBBgcolor = sectionContentToLoad.style.category.backgroundColor;

                this.selectedSubTotalBGColor = sectionContentToLoad.style.subTotal.subTotalRowBGColor;
                this.selectedSubTotalFontColor = sectionContentToLoad.style.subTotal.subTotalRowFontColor;
                this.selectedTotalBGColor = sectionContentToLoad.style.total.totalRowBGcolor;
                this.selectedTotalFontColor = sectionContentToLoad.style.total.totalRowFontColor;
                
                this.dateFormatvalue = sectionContentToLoad.dateFormat;
                this.timeFormatvalue = sectionContentToLoad.timeFormat;
                this.numFormatvalue = sectionContentToLoad.numberFormat;
                this.curFormatvalue = sectionContentToLoad.currencyFormat;
                this.fontfamily = sectionContentToLoad.style.header.fontfamily;
                this.fontsize = sectionContentToLoad.style.header.fontsize;

                // Filtering Conditions On Load
                if (this.ruleIdCreated != '') {
                    this.filteringCondition = sectionContentToLoad.whereClause.substring(1, sectionContentToLoad.whereClause.length - 1);
                }

                // Serial Number On Load
                this.SerialNumber = sectionContentToLoad.SerialNumber;
                setTimeout(() => {
                    this.template.querySelector('[data-id="serial-numer-option"]').checked = sectionContentToLoad.SerialNumber;
                });

                // New Page on Load
                this.newPage = sectionContentToLoad.newPage;
                setTimeout(() => {
                    this.template.querySelector('[data-id="section-page-option"]').checked = sectionContentToLoad.newPage;
                });

                //Chart things On Load
                if (sectionContentToLoad.subTotal != null && sectionContentToLoad.subTotal != "" && sectionContentToLoad.displayChart == true) {
                    this.displayChartSection = sectionContentToLoad.displayChart;
                    this.chartLabel = sectionContentToLoad.chartLabel;
                    this.selectedBarChartColor = sectionContentToLoad.chartBarColor;
                    this.chartControl = true;
                    this.showCalculatorFields = true;

                    setTimeout(() => {
                        this.template.querySelector('[data-id="chart-configuration"]').checked = sectionContentToLoad.displayChart;
                        this.template.querySelectorAll(`.chart-color`).forEach(item =>{
                            item.style.background = this.selectedBarChartColor;
                        });
                    });

                    setTimeout(() => {
                        this.template.querySelector('[data-id="chart-subtotal-field"]').options = [{ 'label': this.selectedSubTotalFieldForChartGeneration, 'value': this.selectedSubTotalFieldForChartGeneration, selected: true }];
                        this.template.querySelector('[data-id="chart-subtotal-field"]').value = this.selectedSubTotalFieldForChartGeneration
                        this.template.querySelector('[data-id="chart-page-option"]').checked = sectionContentToLoad.chartNewPage;
                    });
                } else {
                    this.chartControl = false;
                    this.chartLabel = "Chart";
                    this.selectedSubTotalFieldForChartGeneration = null;
                    this.displayChartSection = false;
                    this.template.querySelector(`[data-id="chart-configuration"]`).checked = this.displayChartSection;
                }
            }
        } else {
        createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});
        this.isLoaded = false;
        }
    }

    handleReferencedFieldAdditionOnLoad(referenceObject, referencedFieldDetail, fieldValueForHeader, listOfSubTotalFieldsAdded){
        let fieldLabelsAdded = this.listOfAddedFields.map((field)=>{return field.value;})
        if (this.listOfAddedFields.length < this.displayTableHeaderData.length && !fieldLabelsAdded.includes(fieldValueForHeader)) {
            this.listOfAddedFields.push({
                'label': referenceObject.name.substring(0, referenceObject.name.length - 1) + '.' + referencedFieldDetail.name,
                "value": fieldValueForHeader,
                "dataType": referencedFieldDetail.dataType
            });
        }
        if (referencedFieldDetail.dataType == "NUMBER" || referencedFieldDetail.dataType == "CURRENCY" || referencedFieldDetail.dataType == "DOUBLE") {
            this.numericFieldsForSubTotalSelection.push({
                'label': referenceObject.name.substring(0, referenceObject.name.length - 1) + '.' + referencedFieldDetail.name,
                "value": fieldValueForHeader,
                "dataType": referencedFieldDetail.dataType
            });
            this.showCalculatorFields = true;
        }
        if (listOfSubTotalFieldsAdded.includes(fieldValueForHeader) && this.selectedFieldsForSubTotalCalculation.findIndex(({value}) => value == fieldValueForHeader) == -1) {
            this.selectedSubTotalFieldLabelsList.push(referenceObject.name.substring(0, referenceObject.name.length - 1) + '.' + referencedFieldDetail.name);
            this.selectedSubTotalFieldAPIList.push(fieldValueForHeader);
            this.selectedFieldsForSubTotalCalculation.push(({
                'label': referenceObject.name.substring(0, referenceObject.name.length - 1) + '.' + referencedFieldDetail.name,
                "value": fieldValueForHeader,
                "dataType": referencedFieldDetail.dataType
            }));
        }
        return referenceObject.name.substring(0, referenceObject.name.length - 1) + '.' + referencedFieldDetail.name;
    }

    /*
      Based on the user selection on "Object Fields", the picklist fields available in that object will be displayed in another picklist
    */
    async handleObjectselection(event) {
        this.showPicklist = false;
        const selectedRelatedObjectName = (event.detail.values && event.detail.values.length > 0) ? event.detail.values[0] : "";
        if (event.detail.values == '') {
            this.listOfRelatedObjects = [];
        }

        if (selectedRelatedObjectName == null || selectedRelatedObjectName == '') {
            this.displayfields = false;
            this.loadDisplayTableContent = false;
            this.displayTableHeaderData = [];
            this.displayTableRowData = [];
        } else {
            this.selectedChildObjectName = selectedRelatedObjectName;
            this.listOfAddedFields = [];
            this.displayTableCategoryData = [];
            this.selectedRelatedObjectPicklistFields = [];

            getSelectedObjectPicklistFields({ selectedObject: this.selectedChildObjectName })
            .then((result) => {
                this.selectedObjectAllPicklistValueSet = result;
                this.showPicklist = true;
                this.selectedRelatedObjectPicklistFields = Object.keys(result).map((key) => ({'label' : key,'value' : key}));
            }).catch((error) => {
                createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage:(error.message || 'Unknown error message'), logData:error.toString(), logType:'Exception'});
            })

            let result = await this.handleReferenceObjectFieldsRetrieval(this.selectedChildObjectName);
            if(result){
                let sObjectFieldWrapper = {};
                sObjectFieldWrapper.index = 0;
                sObjectFieldWrapper.fieldList = result.map(({name, apiName, dataType}) => ({ label: name, value: apiName, dataType: dataType }));
                sObjectFieldWrapper.fieldWrap = result;
                this.listOfRelatedObjects.push(sObjectFieldWrapper);
                this.displayfields = true;
            }
        }
        this.handleRuleWrapperMaking();
    }

    /*
    Based on the user selection on the picklist field, the selected picklist field will be used in grouping the data in the table.
    */
    handleSelectedGroupingValue(event) {
        if (event.detail.values.length != 0) {
            this.relatedRecordsGrouping = true;
            this.selectedGroupingPicklistOption = event.detail.values[0];
            this.selectedPicklistFieldValueSet = this.selectedObjectAllPicklistValueSet[this.selectedGroupingPicklistOption];
            this.showpicklistValues = true;
            this.displayTableCategoryData = [];
            this.displayTableCategoryData = this.selectedPicklistFieldValueSet.map(({value}) => { return value.toUpperCase() });
            this.showChartBox = (this.displayTableCategoryData.length > 0) ? true : this.showChartBox;
        } else {
            this.displayTableCategoryData = [];
            this.relatedRecordsGrouping = false;
            this.selectedGroupingPicklistOption = '';
        }
        this.chartControl = this.relatedRecordsGrouping && this.displayChartSection && this.nosubTotal;
    }

    /*
     Based on the user input on Object, the related fields are displayed in the dual list box.
     Once the user selects the fields in dual list box they will be displayed in the preview table
    */
    handleTableDisplay(selectedfieldsArray, isonload, fieldIndexToRemove) {
        if (isonload == true) {
            if (selectedfieldsArray.length > 1 && selectedfieldsArray.includes(',')) {
                if (selectedfieldsArray.includes(',')) {
                    let referenceField = selectedfieldsArray.split(',');
                    this.displayTableHeaderData = [...referenceField];
                } else {
                    this.displayTableHeaderData.push(selectedfieldsArray);
                }
            }
            if (this.displayTableHeaderData.length < 1) {
                if (selectedfieldsArray.length > 1) {
                    this.displayTableHeaderData = [...selectedfieldsArray];
                } else {
                    this.displayTableHeaderData.push(selectedfieldsArray);
                }
            }
        } else {
            let selectedFieldLabel;
            let selectedFieldToBeRemoved;
            for (let i = 0; i < this.listOfAddedFields.length; i++) {
                if (this.listOfAddedFields[i].value == selectedfieldsArray) {
                    selectedFieldLabel = this.listOfAddedFields[i].label;
                }
            } 
            for (let i = 0; i < this.listOfRemovedFields.length; i++) {
                if (this.listOfRemovedFields[i][0].value == selectedfieldsArray) {
                    selectedFieldToBeRemoved = this.listOfRemovedFields[i][0].label;
                }
            }
            if (this.displayTableHeaderData.includes(selectedFieldToBeRemoved)) {
                this.displayTableHeaderData.splice(this.displayTableHeaderData.indexOf(selectedFieldToBeRemoved), 1);
            } else if (fieldIndexToRemove != -1 && fieldIndexToRemove != undefined) {
                this.displayTableHeaderData.splice(fieldIndexToRemove, 1);
            } else {
                this.displayTableHeaderData.push(selectedFieldLabel);
            }
        }
        this.sectionSpan = this.displayTableHeaderData.length;
        this.categoryStyleClass = "background-color :" + this.selectedBBgcolor + "; color:" + this.selectedBFontColor + ';font-size:' + this.fontsize + ';font-family:' + this.fontfamily + ';';
        this.displayTableRowData = [];
        this.displayTableRowData.push({ columns : this.displayTableHeaderData.map((key) => ('<data>')) });
        this.loadDisplayTableContent = true;
        this.displaySaveTableButton = true;
    }

    /*
    All the data entered above will be stored in the JSON Format and will get saved in the Document Template section 
    */
    handleSectionSave() {
        let documentSectionContent = {};
        if (this.selectedChildObjectName == '' || this.Recorddetailsnew.Name == '' || this.listOfAddedFields == '') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Section name, Related Object and atleast one field are mandatory to choose!',
                variant: 'Error'
            }));
        } else {
            let childloopkupfieldAPIname;
            let documentSectionContentAsString;
            let chartSectionFlagged = true;

            if (this.ruleIdCreated != '' && this.ruleIdCreated != null) {
                this.getExistingConditions({});
                this.filteringCondition = this.handleFilterClauseMaking(this.ruleExpression, this.listOfActualConditions);
            } else {
                this.filteringCondition = '';
            }

            if(this.displayChartSection){ 
                if(this.selectedSubTotalFieldAPIList.length > 1 && this.selectedSubTotalFieldForChartGeneration != null ){
                    chartSectionFlagged = true;
                    documentSectionContent.displayChart = this.displayChartSection;
                    documentSectionContent.chartBarColor = this.selectedBarChartColor;
                    documentSectionContent.selGraphvalue = this.displayTableHeaderData[this.listOfAddedFields.findIndex(field => field.label == this.selectedSubTotalFieldForChartGeneration)];
                } else {
                    chartSectionFlagged = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'A Sub-Total field must be selected for Chart inside PDF document. Please select all valid options.',
                        variant: 'Error'
                    }));
                }
            }

            if (this.selectedChildObjectName != undefined) {
                if (Object.prototype.hasOwnProperty.call(this.childobjects, this.selectedChildObjectName)) {
                    childloopkupfieldAPIname = this.childobjects[this.selectedChildObjectName];
                }
                documentSectionContent.newPage = this.newPage;
                documentSectionContent.chartLabel = this.chartLabel;
                documentSectionContent.SerialNumber = this.SerialNumber;
                documentSectionContent.chartNewPage = this.chartNewPage;
                documentSectionContent.dateFormat = this.dateFormatvalue;
                documentSectionContent.timeFormat = this.timeFormatvalue;
                documentSectionContent.numberFormat = this.numFormatvalue;
                documentSectionContent.currencyFormat = this.curFormatvalue;                          
                documentSectionContent.tablelistLabels = this.displayTableHeaderData;              
                documentSectionContent.grouping = this.selectedGroupingPicklistOption;
                documentSectionContent.mainChildObject = this.selectedChildObjectName;
                documentSectionContent.whereClause = '(' + this.filteringCondition + ')';
                documentSectionContent.childLookupfieldAPIname = childloopkupfieldAPIname;
                documentSectionContent.subTotal = this.selectedFieldsForSubTotalCalculation.map(({value}) => {return value;});  
                documentSectionContent.groupingCatVals = (!this.selectedGroupingPicklistOption) ? '' : this.selectedObjectAllPicklistValueSet[this.selectedGroupingPicklistOption].map(({label}) => {return label;});              
                documentSectionContent.tablelistValues = this.listOfAddedFields.map(({value}) => (value));
                documentSectionContent.mainparentObject = this.documenttemplaterecord.DxCPQ__Related_To_Type__c;
                documentSectionContent.style = {
                    category : {fontcolor  : this.selectedBFontColor, backgroundColor  : this.selectedBBgcolor, fontfamily  : this.fontfamily, fontsize  : this.fontsize},
                    header : {fontcolor  : this.selectedHFontColor , backgroundColor  : this.selectedHbgColor , fontfamily  : this.fontfamily , fontsize  : this.fontsize},
                    subTotal : {subTotalRowBGColor : this.selectedSubTotalBGColor, subTotalRowFontColor : this.selectedSubTotalFontColor},
                    total : {totalRowBGcolor : this.selectedTotalBGColor, totalRowFontColor : this.selectedTotalFontColor}
                };
                documentSectionContentAsString = JSON.stringify(documentSectionContent);
            }

            if (documentSectionContentAsString != '' && documentSectionContentAsString != null) {
                this.Recorddetailsnew.DxCPQ__Section_Content__c = documentSectionContentAsString;
            }
            if (this.sectionrecordid != '' && this.sectionrecordid.indexOf('NotSaved') == -1) {
                this.Recorddetailsnew.Id = this.sectionrecordid;
            }
            this.Recorddetailsnew.DxCPQ__Type__c = this.sectiontype;
            this.Recorddetailsnew.DxCPQ__New_Page__c = this.newPage;            
            this.Recorddetailsnew.DxCPQ__Sequence__c = this.rowcount;          
            this.Recorddetailsnew.DxCPQ__RuleId__c = this.ruleIdCreated;
            this.Recorddetailsnew.DxCPQ__Document_Template__c = this.documenttemplaterecordid;
            if (this.Recorddetailsnew.Name != '' && this.Recorddetailsnew.Name != null && chartSectionFlagged) {
                this.saveSectionContentWrapper();
            }
        }
    }

    saveSectionContentWrapper(){
        saveDocumentTemplateSectionDetails({ recordDetails: this.Recorddetailsnew })
        .then(result => {
            if (result != null) {
                this.savedRecordID = result;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Section "' + this.Recorddetailsnew.Name + '"' + ' was Saved',
                    variant: 'success',
                }));
                this.dispatchEvent(new CustomEvent('savesectiondata', {
                    detail: this.savedRecordID
                }));
                this.template.querySelector('c-hidden-component').callFromComponent(result.Id, this.displayTableHeaderData, this.selectedHbgColor, this.selectedHFontColor, this.fontsize, this.fontfamily, this.SerialNumber);
                this.template.querySelector('c-template-designer-cmp').showPreview = true;
            }
        })
        .catch(error => {
            createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});
        })
    }

    async handleReferenceObjectFieldsRetrieval(sObjectName){
        let allFieldsWrapper;
        if(this.referenceObjectsFieldDetailsMap[sObjectName]){
            allFieldsWrapper = this.referenceObjectsFieldDetailsMap[sObjectName]
        } else {
            await getSelectedRelatedObjectFields({ selectedObject: sObjectName })
            .then(result =>{
                allFieldsWrapper = result;
                this.referenceObjectsFieldDetailsMap[sObjectName] = result;
            }).catch(error =>{
                createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});
            });
        }
        return allFieldsWrapper;
    }

    /*
      1. When the user selects a field in the dual list box, the below function handles the functionality part to display the user selected fields in the right most dual list box.
      2. It also includes the code for displaying the lookup fields
    */
    handleSelectedField(event) {
        let selectedField = event.currentTarget.value;
        let index = event.currentTarget.dataset.id;
        this.listOfRelatedObjects.splice(parseInt(index) + 1);
        this.listOfRelatedObjects.forEach(fieldDetail => {
            if (fieldDetail.index == index) {
                fieldDetail.value = selectedField;
                fieldDetail.fieldWrap.forEach(field => {
                    if (field.apiName == selectedField) {
                        fieldDetail.selectedFieldAPIName = field.apiName;
                        fieldDetail.selectedFieldName = field.name;
                        fieldDetail.dataType = field.dataType;
                        if (field.dataType == 'REFERENCE') {
                            fieldDetail.selectedObject = field.sObjectName;
                            fieldDetail.relationshipName = field.relationshipName;
                            let existingValues = [];
                            let fieldArray = this.listOfAddedFields.filter((fieldDetail) => fieldDetail.value.includes(field.relationshipName));
                            if (fieldArray.length > 0) {
                                fieldArray.forEach(temp => {
                                    existingValues.push(temp.value.split('.')[1])
                                });
                            }
                            if(this.referenceObjectsFieldDetailsMap[field.sObjectName]){
                                let sObjectFieldWrapper = {};
                                let index = this.listOfRelatedObjects.length;
                                sObjectFieldWrapper.index = index;
                                sObjectFieldWrapper.fieldList = this.referenceObjectsFieldDetailsMap[field.sObjectName].filter((fieldDetail) => (fieldDetail.dataType != "REFERENCE" && !existingValues.includes(fieldDetail.apiName))).map((fieldDetail) => ({label: fieldDetail.name, value: fieldDetail.apiName, dataType: fieldDetail.dataType}));
                                sObjectFieldWrapper.fieldWrap = this.referenceObjectsFieldDetailsMap[field.sObjectName];
                                this.listOfRelatedObjects.push(sObjectFieldWrapper);
                            } else {
                                getSelectedRelatedObjectFields({ selectedObject: field.sObjectName })
                                .then(result => {
                                    if (result) {
                                        this.referenceObjectsFieldDetailsMap[field.sObjectName] = result;
                                        let sObjectFieldWrapper = {};
                                        sObjectFieldWrapper.index = this.listOfRelatedObjects.length;
                                        sObjectFieldWrapper.fieldList = result.filter((fieldDetail) => (fieldDetail.dataType != "REFERENCE" && !existingValues.includes(fieldDetail.apiName))).map((fieldDetail) => ({label: fieldDetail.name, value: fieldDetail.apiName, dataType: fieldDetail.dataType}));
                                        sObjectFieldWrapper.fieldWrap = result;
                                        this.listOfRelatedObjects.push(sObjectFieldWrapper);
                                    }
                                }).catch(error => {
                                    createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});
                                })
                            }
                        } else {
                            let selectedApiName;
                            for (let i = 0; i < this.listOfRelatedObjects.length; i++) {
                                if (i == this.listOfRelatedObjects.length - 1) {
                                    if (selectedApiName) {
                                        selectedApiName = selectedApiName + '.' + this.listOfRelatedObjects[i].value;
                                    } else {
                                        selectedApiName = this.listOfRelatedObjects[i].value;
                                    }
                                } else {
                                    if (selectedApiName) {
                                        selectedApiName = selectedApiName + '.' + this.listOfRelatedObjects[i].relationshipName;
                                    } else {
                                        selectedApiName = this.listOfRelatedObjects[i].relationshipName;
                                    }
                                }
                            }
                            this.selectedField = selectedApiName;
                        }
                    }
                })
            }
        })
    }

    /*
    This piece of code deals in displaying the fields for selecting the calculation of  grandtotals and subtotals of the available number and currency fields 
    */
    handleNumberFieldSelection(bool) {
        this.numericFieldsForSubTotalSelection = [];
        if (bool) {
            /* for (let i = 0; i < this.listOfAddedFields.length; i++) {
                if (this.listOfAddedFields[i].dataType == 'DOUBLE' || this.listOfAddedFields[i].dataType == 'CURRENCY' ||
                    this.listOfAddedFields[i].dataType == 'NUMBER') {
                    this.numericFieldsForSubTotalSelection.push(this.listOfAddedFields[i]);
                }
            } */
            this.numericFieldsForSubTotalSelection = this.listOfAddedFields.filter(({dataType}) => {return (dataType == 'DOUBLE' || dataType == 'CURRENCY' || dataType == 'NUMBER')});
        }
        if (this.numericFieldsForSubTotalSelection.length > 0) {
            this.showCalculatorFields = true;
            //this.numericFieldsForSubTotalSelectionOptions = this.numericFieldsForSubTotalSelection;
        }
    }

    /*
      Based on the selection of subtotals and grandtotals, the functionality to display the fields required for Graph creation is listed below
     */
    modifyNumericalFields() {
        /* this.numericFieldsForSubTotalSelection = this.numericFieldsForSubTotalSelectionOptions.filter(elem => {
            if (!this.selectedSubTotalFieldLabelsList.includes(elem.label)) return elem;
        }); */
        this.updateSubTotalFieldListForChartGeneration();
    }

    /**
     The selected fields for the calculation of subtotals and grandtotals are omitted from the picklist. Addition and removal of the picklist fields is handled here (as the input is of multi-select type)
     */
    updateSubTotalFieldListForChartGeneration() {
        this.subTotalFieldListForChartGeneration = this.selectedSubTotalFieldLabelsList.map((fieldLabel) => ({'label' : fieldLabel, 'value': fieldLabel}));
        if (this.subTotalFieldListForChartGeneration.length > 0) {
            this.nosubTotal = true;
        }
    }

    /*
      this piece of code displays the picklist for showing the values for displaying the chart/graph
     */
    chartValueChange(event) {
        this.selectedSubTotalFieldForChartGeneration = event.detail.value;
        this.chartControl = !(this.selectedSubTotalFieldForChartGeneration.length == 0 || (!this.relatedRecordsGrouping) || !(this.nosubTotal))
    }

    /*
      The piece of code is to store the value of selected Subtotal feld calculation.
     */
    handleSubTotalFieldsSelection(event) {
        let selectedNumericFieldValueFromSubTotalFields = event.target.value;
        let selectedNumericFieldDetail = (this.numericFieldsForSubTotalSelection.filter(({value}) => (value == selectedNumericFieldValueFromSubTotalFields)))[0];
        /* for (let i = 0; i < this.numericFieldsForSubTotalSelection.length; i++) {
            if (this.numericFieldsForSubTotalSelection[i].value == selectedNumericFieldValueFromSubTotalFields) {
                numfieldlabel = this.numericFieldsForSubTotalSelection[i].label;
            }
        } */
        if (!this.selectedSubTotalFieldLabelsList.includes(selectedNumericFieldDetail.label)){            
            this.selectedFieldsForSubTotalCalculation.push(selectedNumericFieldDetail);
            this.selectedSubTotalFieldLabelsList.push(selectedNumericFieldDetail.label);
            this.selectedSubTotalFieldAPIList.push(selectedNumericFieldDetail.value);
        }
        this.modifyNumericalFields();
    }

    /*
      Removing the selected subtotal fields from pill container and moving it back to picklist is donw by the below code
     */
      handleNumericFieldRemovalFromSelectedList(event) {
        if(!this.isDisabled){
            let index = this.selectedFieldsForSubTotalCalculation.findIndex(({label}) => label == event.target.name);
            this.selectedFieldsForSubTotalCalculation.splice(index,1);
            this.selectedSubTotalFieldAPIList = this.selectedFieldsForSubTotalCalculation.map(({value}) => {return value;})
            this.selectedSubTotalFieldLabelsList = this.selectedFieldsForSubTotalCalculation.map(({label}) => {return label;})
            if(this.selectedSubTotalFieldForChartGeneration == event.target.name) {
                this.selectedSubTotalFieldForChartGeneration = null;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'A Sub-Total field must be selected for Chart inside PDF document. Please select a valid option.',
                    variant: 'Error'
                }));
            }
            this.chartControl = (this.selectedSubTotalFieldLabelsList.length == 0 || !(this.selectedSubTotalFieldLabelsList.includes(this.selectedSubTotalFieldForChartGeneration)) || (!this.relatedRecordsGrouping)) ? false : true;
            this.modifyNumericalFields();
        }
    }

    /*
    Adding the selected fields in the dual list box and the reciprocates on the table preview
     */
    handleFieldAdditionToSelectedList() {
        if (this.selectedField != '') {
            let selectedVal = this.selectedField;
            var checkDuplicate = false;
            this.loadUp = true;
            let label;

            let selectedFieldLabel;
            for (let i = 0; i < this.listOfRelatedObjects[0].fieldList.length; i++) {
                if (this.listOfRelatedObjects[0].fieldList[i].value == selectedVal) {
                    this.listOfAddedFields.push(this.listOfRelatedObjects[0].fieldList[i]);
                    selectedFieldLabel = this.listOfRelatedObjects[0].fieldList[i].label;
                    this.listOfRelatedObjects[0].fieldList.splice(i, 1);
                }
            }
            if (selectedVal.includes('.')) {
                let referenceField = selectedVal.split('.');
                let fieldlabel;
                for (let i = 0; i < this.listOfRelatedObjects[0].fieldWrap.length; i++) {
                    if (this.listOfRelatedObjects[0].fieldWrap[i].relationshipName == referenceField[0]) {
                        fieldlabel = this.listOfRelatedObjects[0].fieldWrap[i].name;
                        fieldlabel = fieldlabel.replace('>', '');
                    }
                }
                for (let i = 0; i < this.listOfRelatedObjects[1].fieldList.length; i++) {
                    label = this.listOfRelatedObjects[1].fieldList[i].label;
                    let temp = fieldlabel + '.' + label;
                    if (this.displayTableHeaderData.includes(temp)) {
                        checkDuplicate = true;
                    }
                    if (this.listOfRelatedObjects[1].fieldList[i].value == referenceField[1] && !checkDuplicate) {
                        this.listOfAddedFields.push({
                            "label": fieldlabel + '.' + label,
                            "value": selectedVal,
                            "dataType": this.listOfRelatedObjects[1].fieldList[i].dataType
                        });
                        this.listOfRelatedObjects[1].fieldList.splice(i, 1);
                    }
                }
            }
            this.handleNumberFieldSelection(true);
            if (!checkDuplicate) {
                this.handleTableDisplay(selectedVal, false);
            }
        }
        this.selectedField = '';
        if (this.numericFieldsForSubTotalSelection.length === 0) {
            this.showCalculatorFields = false;
            this.displayChartSection = false;
            this.template.querySelector(`[data-id="chart-configuration"]`).checked = this.displayChartSection;
        }

    }

    /*
       Selecting the field from the list of selected fields from the right most dual list box  
     */
    handleSelectedFieldsBox(event) {
        this.selectedFieldToBeRemoved = event.currentTarget.value;
    }

    /*
      Removing the selected field from the list of selected fields from dual list box
     */
    handleFieldRemovalFromSelectedList() {
        if (this.selectedFieldToBeRemoved != '') {
            /* if (this.changedHeaders.length > 0) {
                for (let i = 0; i < this.listOfAddedFields.length; i++) {
                    for (let j = 0; j < this.changedHeaders.length; j++) {
                        if (this.listOfAddedFields[i].label == this.changedHeaders[j].current) {
                            this.listOfAddedFields[i].label = this.changedHeaders[j].previous;
                        }
                    }
                }
            } */
            let fieldIndex = this.listOfAddedFields.findIndex((fieldDetail) => { return fieldDetail.value == this.selectedFieldToBeRemoved});
            for (let i = 0; i < this.listOfAddedFields.length; i++) {
                if (this.listOfAddedFields[i].value == this.selectedFieldToBeRemoved) {
                    if (this.listOfAddedFields[i].value.includes('.')) {
                        this.listOfRelatedObjects[1].fieldList.unshift({
                            "label": this.listOfAddedFields[i].label.split('.')[1],
                            "value": this.listOfAddedFields[i].value.split('.')[1]
                        });
                        let t = this.listOfAddedFields.splice(i, 1);
                        this.listOfRemovedFields.push(t);
                        break;
                    } else {
                        this.listOfRelatedObjects[0].fieldList.unshift(this.listOfAddedFields[i]);
                        const t = this.listOfAddedFields.splice(i, 1);
                        this.listOfRemovedFields.push(t);
                        break;
                    }
                }
            }
            /*
            if (this.changedHeaders.length > 0) {
                for (let i = 0; i < this.listOfAddedFields.length; i++) {
                    for (let j = 0; j < this.changedHeaders.length; j++) {
                        if (this.listOfAddedFields[i].label == this.changedHeaders[j].previous) {
                            this.listOfAddedFields[i].label = this.changedHeaders[j].current;
                        }
                    }
                }
            } */
            this.handleNumberFieldSelection(true);
            this.handleTableDisplay(this.selectedFieldToBeRemoved, false, fieldIndex);
        }
        this.selectedFieldToBeRemoved = '';
        if (this.numericFieldsForSubTotalSelection.length === 0) {
            this.showCalculatorFields = false;
            this.displayChartSection = false;
            this.template.querySelector(`[data-id="chart-configuration"]`).checked = this.displayChartSection;
        }
    }

    /*
    Swapping the selected fields upwards in the dual list box and the change can be seen in the preview table
     */
    handleFieldToMoveUpward() {
        this.loadUp = true;
        let selectedVal = this.selectedFieldToBeRemoved;
        let addedfields = this.listOfAddedFields;
        for (let i = 0; i < this.listOfAddedFields.length; i++) {
            if (selectedVal == addedfields[i].value && i != 0) {
                let temp = addedfields[i - 1];
                addedfields[i - 1] = addedfields[i];
                addedfields[i] = temp;
                break;
            }
        }
        this.listOfAddedFields = addedfields;
        this.displayTableHeaderData = this.listOfAddedFields.map(({label}) => (label));
    }

    /*
    Swapping the selected fields downwards in the dual list box and the change can be seen in the preview table
     */
    handleFieldToMoveDownward() {
        this.loadUp = true;
        let selectedVal = this.selectedFieldToBeRemoved;
        let addedfields = this.listOfAddedFields;
        for (let i = 0; i < this.listOfAddedFields.length; i++) {
            if (selectedVal == addedfields[i].value && i != (this.listOfAddedFields.length - 1)) {
                let temp = addedfields[i + 1];
                addedfields[i + 1] = addedfields[i];
                addedfields[i] = temp;
                break;
            }
        }
        this.listOfAddedFields = addedfields;
        this.displayTableHeaderData = this.listOfAddedFields.map(({label}) => (label));
    }

    /* Chart Header Changes by Rahul */

    /*
    This piece of code is used for getting the selected header value
     */
    handleRichTextArea(event) {
        this.renamedHeaderLabel = event.detail.value;
    }

    /*
    This function gets the row data-id of the selected header
     */
    getSelectedTableRowHandler(event) {
        this.selectedTableRow = event.target.dataset.id;
        this.template.querySelectorAll('[data-id="' + this.selectedTableRow + '"]')[0];
        this.handleActionButtonsVisibility(this.selectedTableRow);
    }

    /*
    This functions displays the save and cancel buttons on the selected table header
     */
    handleActionButtonsVisibility(dataId) {
        let allSaveButtons = this.template.querySelectorAll('[data-id][data-okay]');
        let allCancelButtons = this.template.querySelectorAll('[data-id][data-cancel]');
        this.setActionButtonsVisibility(dataId, allSaveButtons);
        this.setActionButtonsVisibility(dataId, allCancelButtons);
    }

    /*
    This piece of code hides the save and cancel buttons on save/cancel
     */
    setActionButtonsVisibility(dataId, buttons) {
        if (!!buttons && buttons.length > 0) {
            for (let sbCounter = 0; sbCounter < buttons.length; sbCounter++) {
                let button = buttons[sbCounter];
                if (button.dataset.id == dataId) {
                    button.classList.add('slds-show');
                    button.classList.remove('slds-hide');
                } else {
                    button.classList.remove('slds-show');
                    button.classList.add('slds-hide');
                }
            }
        }
    }

    /*
    This piece of code reverts the previous value of the selected header on hitting cancel
     */
    revertHeaderLabelRename(event) {
        /* for (let j = 0; j < this.changedHeaders.length; j++) {
            let ind = this.changedHeaders[j].index;
            if (this.listOfAddedFields[ind].label == this.changedHeaders[j].current) {
                let temp = this.changedHeaders[j].previous;
                this.listOfAddedFields[ind].label = this.changedHeaders[j].previous;
                this.displayTableHeaderData[ind] = '' + temp + '';
            }
        } */
        this.template.querySelector(`lightning-input-rich-text[data-position="${event.target.dataset.position}"]`).value = event.target.dataset.id;
        this.displayTableHeaderData[event.target.dataset.position] = event.target.dataset.id;
        this.handleActionButtonsVisibility(null);
    }

    /*
    This piece of code saves the updated value of the selected header on hitting save
     */
    handleHeaderLabelRename(event) {
        /*         
        const selectedRecordId = event.target.dataset.id;
        const len = this.renamedHeaderLabel.length;
        this.renamedHeaderLabel = this.renamedHeaderLabel.substring(3, len - 4);
        let bool = false;
        let ind = this.displayTableHeaderData.indexOf(selectedRecordId);
        for (let i = 0; i < this.changedHeaders.length; i++) {
            if (this.changedHeaders[i].previous == selectedRecordId) {
                bool = true;
                this.changedHeaders[i].current = this.renamedHeaderLabel;
                break;
            }
        }
        if (!bool) {
            this.changedHeaders.push({
                previous: selectedRecordId,
                current: this.renamedHeaderLabel,
                index: ind
            });
        } 
        */
        this.displayTableHeaderData[event.target.dataset.position] = this.renamedHeaderLabel.substring(3, this.renamedHeaderLabel.length - 4);
        this.handleActionButtonsVisibility(null);
    }

    /* Table Style Controllers - Changes by Rahul */

    handleSerialNumber(event) {
        this.SerialNumber = event.detail.checked;
    }

    handleDisplayChart(event) {
        this.displayChartSection = event.detail.checked;
        this.chartWithDemoData = this.chartWithDemoData.map(categoryData => {
            return {...categoryData, height: `height:${categoryData.percent}; background-color:${this.selectedBarChartColor}`};
        });
        this.chartControl = !this.relatedRecordsGrouping && this.displayChartSection && this.nosubTotal;
        if(this.displayChartSection) this.template.querySelector('[data-scroll="scroll-to-chart-section-start"]').scrollIntoView();
    }

    handleChartLabel(event) {
        this.chartLabel = event.detail.value;
    }
    handleChartNewPage(event) {
        this.chartNewPage = event.detail.checked;
    }
    handleHFontColorChange(event) {
        this.selectedHFontColor = event.detail.value;
    }
    handleHbgColorChange(event) {
        this.selectedHbgColor = event.detail.value;
    }
    handlesubtotal(event) {
        this.subtotal = event.detail.checked;
    }

    handlefontfamilyChange(event) {
        this.fontfamily = event.detail.value.replace('&quot;', '');
        this.template.querySelectorAll('.display-table')[0].style.fontFamily = this.fontfamily;
        this.categoryStyleClass = "background-color :" + this.selectedBBgcolor + "; color:" + this.selectedBFontColor + ';font-size:' + this.fontsize + ';font-family:' + this.fontfamily + ';';
    }

    handleBFontColorChange(event) {
        this.selectedBFontColor = event.detail.value;
        this.template.querySelectorAll('.display-table')[0].style.color = this.selectedBFontColor;
    }

    handleBBgColorchange(event) {
        this.selectedBBgcolor = event.detail.value;
        this.template.querySelectorAll('.display-table')[0].style.backgroundColor = this.selectedBBgcolor;
    }

    handleBDRbgColorchange(event) {
        this.selectedBDRbgcolor = event.detail.value;
        this.template.querySelectorAll('.display-table').style.border = "5px solid" + this.selectedBDRbgcolor;
    }

    handleSubTotalBGColorChange(event){
        this.selectedSubTotalBGColor = event.detail.value;
    }
    handleSubTotalFontColorChange(event){
        this.selectedSubTotalFontColor = event.detail.value;
    }
    handleTotalBGColorChange(event){
        this.selectedTotalBGColor = event.detail.value;
    }
    handleTotalFontColorChange(event){
        this.selectedTotalFontColor = event.detail.value;
    }

    handleBarChartColorChange(event) {
        this.selectedBarChartColor = event.detail.value;
        let dataIdArray = ['group-1', 'group-2', 'group-3', 'group-4', 'Others'];
        dataIdArray.forEach((item) => {
            this.template.querySelector(`[data-id=${item}]`).style.background = this.selectedBarChartColor;
        });
    }

    newfontsize() {
        let lenth = this.template.querySelectorAll('th').length;
        for (let i = 0; i < lenth; i++) {
            this.template.querySelectorAll('th')[i].style.fontSize = this.fontsize;
            this.template.querySelectorAll('th')[i].style.color = this.selectedHFontColor;
            this.template.querySelectorAll('th')[i].style.backgroundColor = this.selectedHbgColor;
        }
        this.categoryStyleClass = "background-color :" + this.selectedBBgcolor + "; color:" + this.selectedBFontColor + ';font-size:' + this.fontsize + ';font-family:' + this.fontfamily + ';';
    }

    handlefontsizeChange(event) {
        this.fontsize = event.detail.value;
        let lenth = this.template.querySelectorAll('th').length;
        for (let i = 0; i < lenth; i++) {
            this.template.querySelectorAll('th')[i].style.fontSize = this.fontsize;
        }
        this.categoryStyleClass = "background-color :" + this.selectedBBgcolor + "; color:" + this.selectedBFontColor + ';font-size:' + this.fontsize + ';font-family:' + this.fontfamily + ';';
    }

    handleDateFormat(event) {
        this.dateFormatvalue = event.detail.value;
    }
    handleTimeFormat(event) {
        this.timeFormatvalue = event.detail.value;
    }
    handleNumFormat(event) {
        this.numFormatvalue = event.detail.value;
    }
    handlecurFormat(event) {
        this.curFormatvalue = event.detail.value;
    }
    handleNewPage(event) {
        this.newPage = event.detail.checked;
    }

    /* Filtering based on Objects -> Changes by Rahul */

    /*Closing the modal box for filter rules creation*/
    closePreviewModal() {
        this.ruleCondition = false;
        this.template.querySelector('c-modal').hide();
    }

    /* this is to show the rules popup window on selecting the fileter label */
    handleFiltering() {
        this.ruleCondition = true;
        this.template.querySelector('c-modal').show();
    }

    /* The piece of code is to get the object names for selection in rules */
    handleRuleWrapperMaking() {
        if (this.selectedChildObjectName !== undefined) {
            getSObjectListFiltering({ selectedChildObjectLabel: this.selectedChildObjectName })
            .then((result) => {
                this.fieldWrapper = result;
            })
            .catch((error) => {
                createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
            });
        }
    }

    /*
    The piece of code is to create the rules after entering the conditions in rules popup window.
    */
    handleCreateRules() {
        const conditionChild = this.template.querySelector('c-conditioncmp').getConditionDetails();
        this.ruleExpression = conditionChild.expression;
        this.createRuleConditionObjects(conditionChild.listOfConditions);
        let listOfConditions = JSON.stringify(this.ruleConditions);
        let deleteIds = null;
        let ruleExp = JSON.stringify(this.ruleExpression);
        createRuleCondition({
            ruleConditions: listOfConditions,
            ruleExpression: ruleExp,
            deleteIds: deleteIds,
            sectionrecordid: this.sectionrecordid
        })
        .then(result => {
            this.ruleIdCreated = result;
            this.ruleExists = true;

            let event = new Object();
            this.getExistingConditions(event);
        })
        .catch(error => {
            createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
        });

        this.template.querySelector('c-modal').hide();
    }

    /*
    The piece of code is to delete the rules aftere entering the conditions in rules popup window.
    */
    removeDeletedConditions(listOfConditions, receivedConditions) {
        let existingIds = [];
        let receivedIds = [];
        listOfConditions.forEach(con => {
            if (con.Id) {
                existingIds.push(con.Id);
            }
        })
        receivedConditions.forEach(con => {
            receivedIds.push(con.Id);
        })
        receivedIds = receivedIds.filter(el => {
            return !existingIds.includes(el);
        });
        return receivedIds;
    }

    /*
    The piece of code is to delete the rules condition aftere entering the coditions in rules popup window.
    (As condition1 && condition2 || condition3)
    */
    createRuleConditionObjects(arrayList) {
        this.hasSpecialCharacter = false;
        let regExpr = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
        arrayList.forEach(condition => {
            let conditionChildWrapper = {};
            conditionChildWrapper.Id = condition.Id;
            conditionChildWrapper.conditionName = condition.conditionName;
            conditionChildWrapper.dataType = condition.dataType;
            conditionChildWrapper.operator = (condition.operator == '==') ? '==' : condition.operator;
            conditionChildWrapper.selectedObject = condition.selectedObject;
            conditionChildWrapper.selectedField = condition.selectedField;
            conditionChildWrapper.value = condition.value;
            conditionChildWrapper.conditionIndex = condition._index;
            if (regExpr.test(conditionChildWrapper.value)) {
                this.hasSpecialCharacter = true;
            }            
            this.ruleConditions.push(conditionChildWrapper);
            if (condition.children && condition.children.length > 0) {
                condition.children.forEach(child => {
                    if (child.group && child.group.length > 0) {
                        this.createRuleConditionObjects(child.group);
                    }
                })
            }
        })
    }

    handleFilterRuleReset() {
        resetRulesForTemplate({ templateRuleId: this.ruleIdCreated })
        .then(result => {
            if (result == 'Success') {
                this.ruleIdCreated = null;
                this.listOfExistingConditions = [];
                this.conditionsArr = [];
                this.ruleExists = false;
                this.filteringCondition = '';
                this.ruleConditions = [];
                this.ruleCondition = false;
                this.handleSectionSave(null);
            } else {
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Reset didn\'t work', variant: 'Error' }));
            }
        })
        .catch(error => {
            createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
        });
        this.ruleCondition = false;
        this.template.querySelector('c-modal').hide();
    }

    /*
    The piece of code is to update  the rules wnich are already saved aftere entering the coditions in rules popup window .
    (As condition1 && condition2 || condition3)
    */
    handleRuleUpdates() {
        this.ruleConditions = [];
        const conditionChild = this.template.querySelector('c-conditioncmp').getConditionDetails();
        this.createRuleConditionObjects(conditionChild.listOfConditions);
        let listOfConditions = JSON.stringify(this.ruleConditions);
        let expression = JSON.stringify(conditionChild.expression);
        let deleteIds = this.removeDeletedConditions(this.ruleConditions, this.conditionsArr);
        if (!this.hasSpecialCharacter) {
            createRuleCondition({
                ruleConditions: listOfConditions,
                ruleExpression: expression,
                deleteIds: deleteIds,
                sectionrecordid: this.sectionrecordid
            })
            .then(result => {
                this.ruleExists = true;
                this.ruleExpression = expression;
                let event = new Object();
                this.getExistingConditions(event);
            })
            .catch(error => {
                createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
            });
        }
        this.template.querySelector('c-modal').hide();
    }

    /*
      The piece of code is to get the conditions of templates in onload
    */
    getExistingConditions() {
        this.ruleConditionsWrapper = new Map();
        this.conditionsArr = [];
        this.conditionExists = false;
        this.allConditions = [];
        this.listOfExistingConditions = [];
        getConditions({ ruleName: this.ruleIdCreated})
        .then(result => {
            if (result.length > 0) {
                this.conditionsArr = JSON.parse(JSON.stringify(result));
                this.listOfActualConditions = this.conditionsArr;
                this.conditionsArr.forEach(con => {
                    this.ruleConditionsWrapper.set(con.Name, con);
                });
                if (this.fieldWrapper !== undefined) {
                    let conditionResult = createRuleConditionHierarcy(this.ruleExpression, this.ruleConditionsWrapper, this.fieldWrapper);
                    this.listOfExistingConditions = conditionResult.listOfConditions;
                    this.selectedGlobalValue = conditionResult.selectedGlobalValue;
                    this.conditionExists = true;
                }
            }
        })
        .catch(error => {
            createLog({recordId:null, className:'templateRelatedObjects LWC Component', exceptionMessage: (error.message || 'Unknown error message'), logData: error.toString(), logType:'Exception'});     
        });
    }

    /*
    This function is to send the rules according to rule cnditions to apex to run SOQL Queries
    */
    handleFilterClauseMaking(ruleExpression, lstOfConditions) {
        let actualResult = ruleExpression;
        let lst = [];
        for (let i = 0; i < lstOfConditions.length; i++) {
            let res = '' + lstOfConditions[i].DxCPQ__Condition_Field__c + ' ';
            if (lstOfConditions[i].DxCPQ__DataType__c == 'STRING' || lstOfConditions[i].DxCPQ__DataType__c == 'TEXT') {
                if (lstOfConditions[i].DxCPQ__Operator__c != '!=') {
                    res = res + 'LIKE' + ' ' + '\'%' + lstOfConditions[i].DxCPQ__Value__c + '%\'';
                } else {
                    res = '( NOT ' + lstOfConditions[i].DxCPQ__Condition_Field__c + ' LIKE' + ' ' + '\'%' + lstOfConditions[i].DxCPQ__Value__c + '%\' )';
                }
            } else if (lstOfConditions[i].DxCPQ__DataType__c == 'PICKLIST') {
                res = res + lstOfConditions[i].DxCPQ__Operator__c + ' ' + '\'' + lstOfConditions[i].DxCPQ__Value__c + '\'';
            } else {
                res = res + lstOfConditions[i].DxCPQ__Operator__c + ' ' + lstOfConditions[i].DxCPQ__Value__c;
            }
            lst.push(res);
        }
        for (let i = 0; i < lst.length; i++) {
            let ind = i + 1;
            let con = 'Condition' + ind;
            ruleExpression = actualResult.replace(con, lst[i]);
            actualResult = ruleExpression;
        }
        ruleExpression = actualResult.replaceAll('==', '=').replaceAll('&&', 'and').replaceAll('||', 'or').replaceAll('"', '');
        return ruleExpression;
    }

}