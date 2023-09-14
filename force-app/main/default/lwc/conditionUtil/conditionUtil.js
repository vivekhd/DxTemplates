let  selectedGlobalValue;
let listOfExistingConditions=[];


let fieldWrapper =[];
let sObjectList = [];

let globalExpressionOptions=[{label: "All Conditions Are Met", value: "allConditionsAreMet"},
                                     {label: "Any Condition Is Met", value: "anyConditionIsMet"},
                                     {label: "Custom Logic Is Met", value: "customLogicIsMet"}];


let mapOfRC;



const createRuleConditionHierarcy=(ruleExpression, ruleConditionsMap, fieldWrap ) =>{
      
    fieldWrapper=[...fieldWrap]; 
    let tempArr = [];
    if(fieldWrapper && fieldWrapper.length>0){
        fieldWrapper.forEach(wp=>{
            let jsonObj = {};
            jsonObj['label'] = wp.objectLabelName;
            jsonObj['value']=wp.objectAPIName;
            tempArr.push(jsonObj);
        })
        sObjectList=[...tempArr];
    }
    
        
        mapOfRC = ruleConditionsMap;
        let stackArr = [];
        let conditionIndex = 1;
        let andReplace = ruleExpression.replaceAll("&&","AND");
        let orReplace = andReplace.replaceAll("||","OR")
        let statement = "("+orReplace+")";
        for (let i = 0; i <= statement.length; i++) {
            if (statement.charAt(i) == '(') {
                stackArr.push('(');
            } else if (statement.charAt(i) == 'C') {
                stackArr.push('Condition' + conditionIndex);
                conditionIndex++;
            } else if (statement.charAt(i) == ')') {
                stackArr.push(')');
            } else if (statement.charAt(i) == 'A' || statement.charAt(i) == 'O') {
                let logicalOpe = statement.charAt(i) == 'A' ? 'AND' : 'OR';

                stackArr.push(logicalOpe);
            }
        }


        for (let i = 0; stackArr.length > 1; i++) {
            if (stackArr[i]) {
                if (stackArr[i] == ')') {
                    debugger;
                    let tempObj = { "Condition": [], Operator: "", parallelCondition: [], isChild: false }
                    let condtionObj = [];
                    let indexCount = 0;
                    let hasCondition = false;
                    let hasOperator = false;
                    for (let j = i; stackArr[j] != '('; j--) {
                        indexCount = j;
                        if (!(stackArr[j] instanceof Object) && stackArr[j].startsWith('Condition')) {
                            hasCondition = true;
                            tempObj.Condition.push(stackArr[j]);
                        } else if (stackArr[j] === "AND" || stackArr[j] === "OR") {
                            tempObj.Operator = stackArr[j];
                            hasOperator = true;
                        } else if (stackArr[j] instanceof Object) {
                            condtionObj.push(stackArr[j]);
                        }
                    }
                    indexCount = indexCount > 0 ? indexCount - 1 : indexCount;
                    if (hasCondition == true) {
                        tempObj.parallelCondition = condtionObj;
                    } else if (hasOperator == true) {
                        tempObj.Condition = condtionObj;
                        tempObj.isChild = true
                    } else {
                        tempObj = condtionObj[0];
                        tempObj.isChild = true;
                    }

                    stackArr.splice(indexCount, (i + 1) - (indexCount), tempObj);
                    i = indexCount;
                } else if (i + 1 > stackArr.length) {
                    break;
                }
            }
        }
        let arrayList = createConditionHierarchy(stackArr);
        let existingConditions = createListOfConditions(arrayList);
        let listOfConditions = sortListOfExistingConditions(existingConditions);
        let result={};
        result.selectedGlobalValue = selectedGlobalValue;
        result.listOfConditions = listOfConditions;
        return result;
    }


    const sortListOfExistingConditions=(arrayList)=>{

        arrayList.sort((a, b) => {
            let x = a.conditionName.replace("Condition","");
            let y = b.conditionName.replace("Condition","");
            return x-y;
        });
        arrayList.forEach(con=>{
            if(con.children && con.children.length>0){
                con.children.forEach(groupObj=>{
                    if(groupObj.group && groupObj.group>0){
                        sortListOfExistingConditions(groupObj.group);
                    }    
                })
            }
        })
        return arrayList;
    }


    const createConditionHierarchy=(ConditionArr)=> {
        let lstOfCondition = [];
        debugger;
        ConditionArr.forEach(obj => {
            let hasConditionArray = false;
            let lastCondition;
            if (obj.Condition && obj.Condition.length) {
                obj.Condition.forEach(condition => {
                    if (condition instanceof Object) {
                        hasConditionArray = true;
                    } else {
                        let tempObj = {};
                        tempObj.Name = condition;
                        tempObj.operator = obj.Operator;

                        lastCondition = condition;
                        lstOfCondition.push(tempObj);
                    }
                });

                if (hasConditionArray == true) {
                    let tempArr = [];
                    let tempObj = {};
                    obj.Condition.forEach(childCondition => {
                        let childGrp = createConditionHierarchy([childCondition]);
                        let childGrpObj = {};
                        childGrpObj.group = childGrp;
                        tempArr.push(childGrpObj);
                    });
                    tempObj.Name = lastCondition;
                    tempObj.group = [];
                    tempObj.groupOperator = obj.Operator;
                    tempObj.group = tempArr;
                    lstOfCondition = { hasConditionArray: true, conditionGroup: tempObj }
                }
                if (obj.parallelCondition && obj.parallelCondition.length > 0) {

                    let tempArr = createConditionHierarchy(obj.parallelCondition);
                    debugger;
                    if (tempArr instanceof Array) {
                        if (obj.parallelCondition && obj.parallelCondition.length > 0 && obj.parallelCondition[0].isChild == true) {
                            let tempObj = {}
                            tempObj.Name = lastCondition;
                            tempObj.group = [];
                            tempObj.groupOperator = obj.Operator;
                            tempObj.group = tempArr;
                            lstOfCondition.pop();
                            lstOfCondition.push(tempObj);
                        } else {
                            tempArr.forEach(parallelCondition => {
                                parallelCondition.operator = obj.Operator;
                            });
                            lstOfCondition.push(...tempArr);
                        }
                    } else if (tempArr instanceof Object) {
                        let tempObj = {};
                        tempObj.Name = lastCondition;
                        tempObj.group = [];
                        tempObj.groupOperator = obj.Operator;
                        tempObj.groupConnectOperator = tempArr.conditionGroup.groupOperator;
                        tempObj.group = [tempArr.conditionGroup.group];
                        //lstOfCondition = [tempObj];
                        lstOfCondition.pop();
                        lstOfCondition.push(tempObj);
                    }
                }



            }
        });
        return lstOfCondition;
    }


    const createListOfConditions=(arrayList)=>{
        listOfExistingConditions=[];
        let list = [];
        if (arrayList instanceof Array && arrayList.length>0) {
            arrayList.forEach(obj => {
                let tempObj={};
                tempObj.Name=obj.Name;
                tempObj.action = obj.operator;
                if(obj.operator==="AND"){
                    selectedGlobalValue = "allConditionsAreMet";
                }else if(obj.operator ==="OR"){
                    selectedGlobalValue = "anyConditionIsMet";
                }else{
                    tempObj.action="AND";
                    selectedGlobalValue="allConditionsAreMet";
                }
                createConditionObject(tempObj, obj.Name);
                list.push(tempObj);
                if(obj.group && obj.group.length>0){
                        tempObj.childAction = obj.groupOperator;
                        createGroupForConditionObject(obj.group,obj.groupConnectOperator, tempObj);
                    }
            })
        }else if (arrayList instanceof Object) {
            arrayList.conditionGroup.group.forEach(conditionArray => {
                conditionArray.group.forEach(conditionObj => {
                    let tempObj = {};
                    tempObj.Name=conditionObj.Name;
                    tempObj.action = conditionObj.operator;
                    if (conditionObj.operator === "AND") {
                        selectedGlobalValue = "allConditionsAreMet";
                    } else if (conditionObj.operator === "OR") {
                        selectedGlobalValue = "anyConditionIsMet";
                    }else{
                    tempObj.action="AND";
                    selectedGlobalValue="allConditionsAreMet";
                    }
                    createConditionObject(tempObj, conditionObj.Name);
                    list.push(tempObj);
                    if(conditionObj.group && conditionObj.group.length>0){
                        tempObj.childAction = conditionObj.groupOperator;
                        createGroupForConditionObject(conditionObj.group, conditionObj.groupConnectOperator, tempObj);
                        
                    }
                })
            })
        }
        

        return list;
    };

 const createGroupForConditionObject=(arrayList, groupConnectOperator, parentObj)=> {
        parentObj.children=[];
        if (groupConnectOperator === "AND") {
            parentObj.selectedGlobalValue = "allConditionsAreMet";
        } else if (groupConnectOperator === "OR") {
            parentObj.selectedGlobalValue = "anyConditionIsMet";
        }else{
            parentObj.selectedGlobalValue="allConditionsAreMet"
        }
        arrayList.forEach(child => {
            
            if(child instanceof Array && child.length>0){
                child.forEach(childArr=>{
                    

                    if(childArr instanceof Object){
                        let groupObj = {};
                        groupObj.group=[];
                        groupObj.actionOptions=globalExpressionOptions;
                        if(groupConnectOperator){
                            groupObj.action = groupConnectOperator;
                        }else{
                            groupObj.action="AND"
                        }
                        
                        childArr.group.forEach(groupCondition=>{
                            let tempObj = {};
                            tempObj.Name = groupCondition.Name;
                            tempObj.action = groupCondition.operator;
                            if (groupCondition.operator === "AND") {
                                groupObj.selectedGlobalValue = "allConditionsAreMet";
                            } else if (groupCondition.operator === "OR") {
                                groupObj.selectedGlobalValue = "anyConditionIsMet";
                            } else {
                                tempObj.action = "AND";
                                groupObj.selectedGlobalValue = "allConditionsAreMet";
                            }
                            createConditionObject(tempObj, groupCondition.Name);
                            groupObj.group.push(tempObj);
                            if(groupCondition.group && groupCondition.group.length>0){
                                tempObj.childAction = groupCondition.groupOperator;
                                createGroupForConditionObject(groupCondition.group, groupCondition.groupConnectOperator, tempObj);
                            }
                        })
                        parentObj.children.push(groupObj);
                    }
                })

            }else if (child instanceof Object) {
                if(parentObj.children && parentObj.children.length==0){
                    parentObj.children.push({"group":[]});
                    if (groupConnectOperator) {
                        parentObj.children[0].action = groupConnectOperator;
                    } else {
                        parentObj.children[0].action = "AND"
                    }
                    parentObj.children[0].actionOptions = globalExpressionOptions;
                }
                let tempObj={};
                tempObj.Name=child.Name;
                tempObj.action = child.operator;
                if (child.operator === "AND") {
                   parentObj.children[0].selectedGlobalValue = "allConditionsAreMet";
                } else if (child.operator === "OR") {
                    parentObj.children[0].selectedGlobalValue = "anyConditionIsMet";
                }else {
                    tempObj.action = "AND";
                    parentObj.children[0].selectedGlobalValue = "allConditionsAreMet";
                }
                createConditionObject(tempObj, child.Name);
                parentObj.children[0].group.push(tempObj);
                if(child.group && child.group.length>0){
                    tempObj.childAction = child.groupOperator;
                    createGroupForConditionObject(child.group, child.groupConnectOperator, tempObj);
                }
                
            }
        })
    };

    
    const createConditionObject=(tempObj, condition)=>{
                    let rc = mapOfRC.get(condition);
                    tempObj.conditionName = condition;
                    tempObj.objectName = sObjectList;
                    tempObj.selectedObject = rc.DxCPQ__Evaluation_Object__c;
                    tempObj.Id = rc.Id;
                    setupFieldsList(rc.DxCPQ__Evaluation_Object__c, rc.DxCPQ__Condition_Field__c, tempObj);
                    tempObj.selectedField = rc.DxCPQ__Condition_Field__c;
                    tempObj.operator = rc.DxCPQ__Operator__c;
                    tempObj.actionOptions = globalExpressionOptions;
                    tempObj.disableActionValue = false;
                    tempObj.dataType=rc.DxCPQ__DataType__c;
                    if (rc.DxCPQ__DataType__c) {
                        if (rc.DxCPQ__DataType__c === "STRING") {
                            setDefaultDataType(tempObj);
                            tempObj.isText = true;

                        }
                        else if (rc.DxCPQ__DataType__c === "CURRENCY") {
                            setDefaultDataType(tempObj);
                            tempObj.isCurrency = true;
                        }
                        else if (rc.DxCPQ__DataType__c === "BOOLEAN") {
                            setDefaultDataType(tempObj);
                            tempObj.isCheckbox = true;
                        }
                        else if (rc.DxCPQ__DataType__c === "DATETIME") {
                            setDefaultDataType(tempObj);
                            tempObj.isDate = true;
                        }
                        else if (rc.DxCPQ__DataType__c === "PICKLIST") {
                            setDefaultDataType(tempObj);
                            tempObj.ispicklist = true;

                        }
                        else if (rc.DxCPQ__DataType__c === "TEXTAREA") {
                            setDefaultDataType(tempObj);
                            tempObj.isLongText = true;
                        }
                        else if (rc.DxCPQ__DataType__c === "DOUBLE" || rc.DxCPQ__DataType__c === "INTEGER") {
                            setDefaultDataType(tempObj);
                            tempObj.isNumber = true;
                        }
                        else if (rc.DxCPQ__DataType__c === "PERCENT") {
                            setDefaultDataType(tempObj);
                            tempObj.isPercent = true;
                        }
                    }
                    if(tempObj.isCheckbox===true){
                        if(rc.DxCPQ__Value__c=="true"){
                            tempObj.value=true;
                        }else{
                            tempObj.value=false;
                        }
                    }else{
                        tempObj.value = rc.DxCPQ__Value__c;
                    }
                    
                    tempObj._index = rc.DxCPQ__ConditionIndex__c;
                    tempObj.uKey = (new Date()).getTime() + ":" + tempObj._index;
    };
    
    
    const setDefaultDataType=(tempObj)=>{
        tempObj.isText = false;
        tempObj.isCurrency = false;
        tempObj.isCheckbox = false;
        tempObj.isDate = false;
        tempObj.ispicklist = false;
        tempObj.isLongText = false;
        tempObj.isNumber = false;
        tempObj.isPercent = false;
    };



    const setupFieldsList=(objectName, fieldName, tempObj)=> {
        let selectedSObjectData = fieldWrapper.find(sObj => sObj.objectAPIName === objectName);
        let fieldsList = [];

        selectedSObjectData.fieldSet.forEach(fieldData => {
            fieldsList.push({ label: fieldData.name, value: fieldData.apiName });
        });
        tempObj.fieldName = fieldsList;
        tempObj.selectedSObjectData=selectedSObjectData;

        let selectedFieldDetails = selectedSObjectData.fieldSet.find(field => field.apiName === fieldName);
        let pickListValues = [];
        if (selectedFieldDetails.dataType === "PICKLIST") {
            if (selectedFieldDetails.values) {
                selectedFieldDetails.values.forEach(value => {
                    pickListValues.push({ label: value, value: value });
                });
            }
        }
        tempObj.picklistValues = pickListValues;
    };

    export {createRuleConditionHierarcy};