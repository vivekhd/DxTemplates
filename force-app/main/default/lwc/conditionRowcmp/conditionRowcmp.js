import { LightningElement, api, track } from 'lwc';
import getLookupList from '@salesforce/apex/ProductSetupCtrl.getLookupList';
export default class DxCpqConditionRowcmp extends LightningElement {
  
    @api row;
    @api groupIndex;
    @api labelVariant;
    @api fieldWrapper;
    @api selectedGlobalValue;
    @api readOnly = false; 

    @track fieldsList;

    selectedFieldDataType;
    selectedFieldDetails;
    value="";
    condition=[];
    selectedCondition = [];
    showLabel="";
    labelHidden='label-hidden';
    data_index_action;
    selectedSObject;
    selectedSObjectData;
    selectedField; 
    operatorValue="==";
    operatorOptions=[
        { label: "Equals", value: "==" },
        { label: "Less than", value: "<" },
        { label: "Less or Equal", value: "<=" },
        { label: "Greater than", value: ">" },
        { label: "Greater or Equal", value: ">=" },
        { label: "Not Equal to", value: "!=" }
    ];
    actions=[
        { label: "AND", value: "AND" },
        { label: "OR", value: "OR" }
    ]

    //datatype flags
    
    isText = false;
    isCurrency = false;
    isCheckbox = false;
    isDate = false;
    ispicklist = false;
    isLongText = false;
    isNumber = false;
    isPercent = false;
    isLookup = false;

    selectedSObjectEventHandler(event) {
        let selectedObject = event.detail.value;
        let changeEvent = new CustomEvent('dxcpqconditionchange',{ bubbles: true, composed : true,detail:[{index: this.row._index, fieldName: 'selectedObject', value:selectedObject}]});
        this.dispatchEvent(changeEvent);        
        if(selectedObject!=null){
            this.setupFieldsList(selectedObject,true);  
        }  
    }


    addNewConditionRowHandler(){        
        const addNewRowEvent = new CustomEvent('addnewrow', { detail: {index: this.row._index}, bubbles: true, composed : true });
        this.dispatchEvent(addNewRowEvent);
    }

    setupFieldsList(objectName,dispatchEvent){       
        this.selectedSObjectData = this.fieldWrapper.find(sObj=> sObj.objectAPIName===objectName);       
        this.fieldsList=[];
        this.selectedSObjectData.fieldSet.forEach(fieldData => {
            this.fieldsList.push({ label: fieldData.name, value: fieldData.apiName });
        });
        let fieldName=[];
        fieldName = [...this.fieldsList];
        if(dispatchEvent === true){
            let changeEvent = new CustomEvent('dxcpqconditionchange',{ bubbles: true, composed : true,
                detail:[{index: this.row._index, fieldName: 'fieldName', value:fieldName},
                {index: this.row._index, fieldName: 'selectedSObjectData', value: this.selectedSObjectData}]});
            this.dispatchEvent(changeEvent);
        }

    }

    selectedFieldEventHandler(event){
       
        this.selectedField = event.detail.value;
    
        if(this.selectedField){
        this.selectedFieldDetails = this.row.selectedSObjectData.fieldSet.find(field=> field.apiName === this.selectedField);
            let changeEvent = new CustomEvent('dxcpqconditionchange',
                { bubbles: true, composed : true,
                    detail: [
                        { index: this.row._index, fieldName: 'selectedField', value: this.selectedField },
                        { index: this.row._index, fieldName: 'sObjectType', value: this.selectedFieldDetails.sObjectType },
                        { index: this.row._index, fieldName: 'value', value: "" }
                    ]
                });
        this.dispatchEvent(changeEvent);
        
       this.setupDatatype(this.selectedFieldDetails, true);
        }
    }

    
    selectedOperatorEventHandler(event){
        let changeEvent = new CustomEvent('dxcpqconditionchange',
                { bubbles: true, composed : true,
                    detail: [
                        { index: this.row._index, fieldName: 'operator', value: event.detail.value }
                    ]
                });
        this.dispatchEvent(changeEvent);
    }

    deleteConditionRowHandler(){
        const deleteRowEvent = new CustomEvent('deleterow', { detail: {index: this.row._index}, bubbles: true, composed : true });
        this.dispatchEvent(deleteRowEvent);
        
    }

    selectedActionEventHandler(event){
        let changeEvent = new CustomEvent('dxcpqconditionchange',
                {
                    detail: [
                        { index: this.row._index, fieldName: 'action', value: event.detail.value }
                    ], bubbles: true, composed : true
                });
        this.dispatchEvent(changeEvent);
    }




    
    setupDatatype(fieldDetails, dispatchEvent){
        if(fieldDetails.dataType === "STRING"){
            this.resetDataType();
            this.isText=true;
        }
        else if(fieldDetails.dataType==="CURRENCY"){
            this.resetDataType();
            this.isCurrency=true;
        }
        else if(fieldDetails.dataType==="BOOLEAN"){
            this.resetDataType();
            this.isCheckbox=true;
            let changeEvent = new CustomEvent('dxcpqconditionchange',{detail:[{index: this.row._index, fieldName: 'value', value:false}], bubbles: true, composed : true});
            this.dispatchEvent(changeEvent);
        }
        else if(fieldDetails.dataType==="DATETIME"){
            this.resetDataType();
            this.isDate=true;
        }
        else if(fieldDetails.dataType==="PICKLIST"){
            this.resetDataType();
            this.ispicklist=true;
            this.setupPicklistFields(fieldDetails.values);
        }
        else if(fieldDetails.dataType==="TEXTAREA"){
            this.resetDataType();
            this.isLongText=true;
        }
        else if(fieldDetails.dataType==="DOUBLE" || fieldDetails.dataType==="INTEGER"){
            this.resetDataType();
            this.isNumber=true;
        }
        else if(fieldDetails.dataType==="PERCENT"){
            this.resetDataType();
            this.isPercent=true;
        }
        else if(fieldDetails.dataType==="lookup"){
            this.resetDataType();
            this.isLookup=true;
            let changeEvent = new CustomEvent('dxcpqconditionchange',
                {
                    detail: [
                        { index: this.row._index, fieldName: 'lookupDetailsboxClass', value: 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' },
                        { index: this.row._index, fieldName: 'lookupDetailsisValueSelected', value: false },
                        { index: this.row._index, fieldName: 'lookupDetailsiconName', value: 'standard:account' }
                    ], bubbles: true, composed : true
                });
            this.dispatchEvent(changeEvent);
        }
        if(dispatchEvent===true){
            let changeEvent = new CustomEvent('dxcpqconditionchange',
                {
                    detail: [
                        { index: this.row._index, fieldName: 'dataType', value: fieldDetails.dataType },
                        { index: this.row._index, fieldName: 'isText', value: this.isText },
                        { index: this.row._index, fieldName: 'isCurrency', value: this.isCurrency },
                        { index: this.row._index, fieldName: 'isCheckbox', value: this.isCheckbox },
                        { index: this.row._index, fieldName: 'isDate', value: this.isDate },
                        { index: this.row._index, fieldName: 'ispicklist', value: this.ispicklist },
                        { index: this.row._index, fieldName: 'isLongText', value: this.isLongText },
                        { index: this.row._index, fieldName: 'isNumber', value: this.isNumber },
                        { index: this.row._index, fieldName: 'isPercent', value: this.isPercent },
                        { index: this.row._index, fieldName: 'isLookup', value: this.isLookup }
                    ], bubbles: true, composed : true
                });
        this.dispatchEvent(changeEvent);
        }

    }

    resetDataType(){
        this.isText = false;
        this.isCurrency = false;
        this.isCheckbox = false;
        this.isDate = false;
        this.ispicklist = false;
        this.isLongText = false;
        this.isNumber = false;
        this.isPercent = false;
        this.isLookup = false;

    }

    setupPicklistFields(picklistvalues){
        let fieldPicklistValues=[];
        picklistvalues.forEach(value=>{
            fieldPicklistValues.push({ label: value, value: value });
        })
        
        let changeEvent = new CustomEvent('dxcpqconditionchange',{detail:[{index: this.row._index, fieldName: 'picklistValues', value:fieldPicklistValues}], bubbles: true, composed : true});
        this.dispatchEvent(changeEvent); 
    }


    lookupEventHandler(event){
        let searchText = event.target.value;
        let sObjectType = this.row.sObjectType;       
        if(searchText.length>=2){         
            getLookupList({searchText: searchText,sObjectType: sObjectType}).then((result) => {
                let lookupDetailsdata = result;
                let changeEvent = new CustomEvent('dxcpqconditionchange',{detail:[{index: this.row._index, fieldName: 'lookupDetailsdata', value:lookupDetailsdata}], bubbles: true, composed : true});
                this.dispatchEvent(changeEvent); 
            }).catch((error) => {
                console.log('Error in LWC_ConditionRowCMP' + JSON.stringify(error));
            });
        }
        
    }

    assignedValueEventHandler(event){
        let value = event.detail.value;        
        let changeEvent = new CustomEvent('dxcpqconditionchange',{detail:[{index: this.row._index, fieldName: 'value', value:value}], bubbles: true, composed : true});
        this.dispatchEvent(changeEvent);       
    }

    assignedCheckboxValueEventHandler(event){
        let value = event.target.checked;
        let changeEvent = new CustomEvent('dxcpqconditionchange',{detail:[{index: this.row._index, fieldName: 'value', value:value}], bubbles: true, composed : true});
        this.dispatchEvent(changeEvent); 
    }


    //lookup creation
    handleClick() {
        let changeEvent = new CustomEvent('dxcpqconditionchange', {
            detail: [   
                        { index: this.row._index, fieldName: 'lookupDetailsinputClass', value: 'slds-has-focus' },
                        { index: this.row._index, fieldName: 'lookupDetailsboxClass', value: 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open' }
            ]
        });
        this.dispatchEvent(changeEvent);

      }
    
    onSelect(event) {
        let changeEvent = new CustomEvent('dxcpqconditionchange', {
            detail: [   
                        { index: this.row._index, fieldName: 'lookupDetailsselectedId', value: event.currentTarget.dataset.id },
                        { index: this.row._index, fieldName: 'lookupDetailsselectedName', value: event.currentTarget.dataset.name },
                        { index: this.row._index, fieldName: 'value', value: event.currentTarget.dataset.name },
                        { index: this.row._index, fieldName: 'lookupDetailsisValueSelected', value: true },
                        { index: this.row._index, fieldName: 'lookupDetailsboxClass', value: 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }
            ], bubbles: true, composed : true
        });
        this.dispatchEvent(changeEvent);   
    }

    handleRemovePill() {
        let changeEvent = new CustomEvent('dxcpqconditionchange', {
            detail: [   
                        { index: this.row._index, fieldName: 'lookupDetailsisValueSelected', value: false },
                        { index: this.row._index, fieldName: 'lookupDetailsselectedName', value: "" },
                        { index: this.row._index, fieldName: 'lookupDetailsselectedId', value: "" },
                        { index: this.row._index, fieldName: 'value', value: "" },
                        { index: this.row._index, fieldName: 'lookupDetailsboxClass', value: 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus' }
            ], bubbles: true, composed : true
        });
        this.dispatchEvent(changeEvent);
        
        
    }

    addNewGroupHandler(){        
        let action;
        let disableAction;
        if (this.row.selectedGlobalValue === 'allConditionsAreMet') {
            action = "AND";
            disableAction=true;
        } else if (this.row.selectedGlobalValue === 'anyConditionIsMet') {
            action = "OR";
            disableAction=true;
        } else if (this.row.selectedGlobalValue === 'customLogicIsMet') {
            action = "AND";
            disableAction=false;
        }
        
        let addNewGroupEvent = new CustomEvent('dxcpqaddnewgroup', {
            bubbles: true, composed : true, detail: { index: this.row._index, action: action, disableAction:disableAction}
        });
        this.dispatchEvent(addNewGroupEvent);
    }



    handleGlobalExpressionOptionsForRow(event){
        let selectedExpression = event.detail.value;
        let groupIndex=this.row._index+"-"+parseInt(event.currentTarget.dataset.id);
        let takeActionEvent = new CustomEvent('dxcpqtakeaction', {
            bubbles: true, composed : true, detail: { index: groupIndex, expression: selectedExpression}
        });
        this.dispatchEvent(takeActionEvent);
    }

    handleGlobalExpressionOptionsForGroups(event){
        let selectedExpression = event.detail.value;
        let childrenIndex=this.row._index;
        let takeActionEvent = new CustomEvent('dxcpqtakeaction', {
            bubbles: true, composed : true, detail: { index: childrenIndex, expression: selectedExpression}
        });
        this.dispatchEvent(takeActionEvent);
    }


    selectedGroupActionEventHandler(event){
        let childIndex=this.row._index+"-"+parseInt(event.currentTarget.dataset.id);
        let selectedAction =  event.detail.value;
        let takeActionEventForGroup = new CustomEvent('dxcpqtakeactionforgroup', {
            bubbles: true, composed : true, detail: { index: childIndex, action: selectedAction}
        });
        this.dispatchEvent(takeActionEventForGroup);
    }

    selectedChildActionEventHandler(event){
        let selectedAction = event.detail.value;
        let changeEvent = new CustomEvent('dxcpqconditionchange', {bubbles: true, composed : true,
            detail: [   
                        { index: this.row._index, fieldName: 'childAction', value: selectedAction,},
            ]
        });
        this.dispatchEvent(changeEvent);
    }
}