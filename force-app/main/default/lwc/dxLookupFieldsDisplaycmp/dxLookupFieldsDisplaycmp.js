import { LightningElement, track, api } from 'lwc';
import getFields from '@salesforce/apex/MergeFieldsClass.getFields';
export default class DxLookupFieldsDisplaycmp extends LightningElement {

    @track lstOfObjects = [];
    @api selectionObject;
    @track flag1 = false;
    selectedField;
    showStatement = false;
    showLstOfObj = false;


    connectedCallback() {
        this.objectselected = this.selectionObject;
        this.flag1 = true;
        getFields({ selectedObject: this.selectionObject })
            .then(result => {
                if (result) {
                    let tempObj = {};
                    let index = 0;
                    tempObj.index = index;
                    tempObj.fieldList = [];
                    result.forEach(field => {
                        tempObj.fieldList.push({ label: field.name, value: field.apiName });
                    });
                    tempObj.fieldWrap = result;
                    tempObj.uKey = (new Date()).getTime() + ":" + index;
                    this.lstOfObjects.push(tempObj);
                    if (this.lstOfObjects.length && this.lstOfObjects.length > 0) {
                        this.showLstOfObj = true;
                    }
                }
            }).catch(() => {
            })
    }

    handleSelectedField(event) {
        let selectedField = event.currentTarget.value;
        let index = event.currentTarget.dataset.id;
        this.lstOfObjects.splice(parseInt(index) + 1);
        this.lstOfObjects.forEach(obj => {
            if (obj.index == index) {
                obj.value = selectedField;

                obj.fieldWrap.forEach(field => {
                    if (field.apiName == selectedField) {
                        obj.selectedFieldAPIName = field.apiName;
                        obj.selectedFieldName = field.name;
                        obj.dataType = field.dataType;
                        if (field.dataType == 'REFERENCE') {
                            this.showStatement = false;
                            obj.selectedObject = field.sObjectName;
                            obj.relationshipName = field.relationshipName;
                            getFields({ selectedObject: field.sObjectName }).then(result => {
                                if (result) {
                                    let tempObj = {};
                                    let index = this.lstOfObjects.length;
                                    tempObj.index = index;
                                    tempObj.fieldList = [];
                                    result.forEach(field => {
                                        tempObj.fieldList.push({ label: field.name, value: field.apiName });
                                    });
                                    tempObj.fieldWrap = result;
                                    tempObj.uKey = (new Date()).getTime() + ":" + index;
                                    this.lstOfObjects.push(tempObj);
                                }
                            }).catch(() => {
                            })
                        } else {
                            let tempstr;
                            for (let i = 0; i < this.lstOfObjects.length; i++) {
                                if (i == this.lstOfObjects.length - 1) {
                                    if (tempstr) {
                                        tempstr = tempstr + '.' + this.lstOfObjects[i].value;
                                    } else {
                                        tempstr = this.lstOfObjects[i].value;
                                    }
                                } else {
                                    if (tempstr) {
                                        tempstr = tempstr + '.' + this.lstOfObjects[i].relationshipName;
                                    } else {
                                        tempstr = this.lstOfObjects[i].relationshipName;
                                    }
                                }
                            }
                            this.selectedField = tempstr;
                            this.showStatement = true;
                        }


                    }
                })
            }
        })

    }

    @api getMergeField() {
        return this.selectedField;
    }
}