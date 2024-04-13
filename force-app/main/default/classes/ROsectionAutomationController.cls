/**
* Class			    : ROsectionAutomationController
* Developer			: Rahul Bejgam (ASE - Dextara)
* Created Date		: 08/03/2023
* @description		: This class creates the data-wrapper. This class performs the dataquery for header HTML and related object record, numerical calculation and formats data. 
*                      The class is for only Autogeneration of pdf.
* Last Modified Date: 08/11/2023
*/
public with sharing class ROsectionAutomationController {

    /* User Selected Styles from Template Builder */
    public static String dateFormat;
    public static String timeFormat;
    public static String numberFormat;
    public static String currencyFormat;

    public static Id relatedObjectSectionID;
    public static String errorTypeCaught = null;
    public static String roHtmlContent = '<tbody>';

    /* Variables to hold the Sum Calculations of field records */
    public static Map<String,Decimal> currencyFieldTotals;
    public static Map<String,Decimal> currencyFieldSubTotals; 

    /* Function that returns the HTML Version of the Related Object section content */
   /**
 * @description Generates HTML content for a related object section based on the provided template section and record ID.
 * @param recordid The ID of the record for which the related object section is generated.
 * @param templatesectionid The ID of the template section used for generating the HTML content.
 * @return HTML content representing the related object section with data and optional chart.
 */
    public static string getSectionDataAsHTML(String recordid,String templatesectionid)  {
        relatedObjectSectionID = templatesectionid;                
        List<sObject> relatedObjectQueriedRecords = new List<sObject>();

        try {
            Document_Template_Section__c relatedObjectSection = [select id,Section_Content__c from Document_Template_Section__c where id=:templatesectionid WITH SECURITY_ENFORCED];
            Map<string,Object> contentAndStylingMap = (Map<string,Object>)JSON.deserializeUntyped(relatedObjectSection.Section_Content__c);

            /* Object and Fields for Query Formation */
            String relatedObjectAPIName = String.valueof(contentAndStylingMap.get('mainChildObject'));   
            String relatedObjectFieldNameToGroupRecords = String.valueof(contentAndStylingMap.get('grouping'));                     
            List<Object> selectedFieldAsHeaderAPIList = (List<Object>) contentAndStylingMap.get('tablelistValues');
            List<Object> selectedFieldsAsHeaderLabelList = (List<Object>) contentAndStylingMap.get('tablelistLabels');

            /* "Where" Condition - from filtering option of Template Builder */
            String whereClauseinQuery = '';
            if(contentAndStylingMap.get('whereClause')!='' && contentAndStylingMap.get('whereClause')!=null &&  contentAndStylingMap.get('whereClause')!='()')  {
                whereClauseinQuery = ' AND ' + (String) contentAndStylingMap.get('whereClause');
            }

            /* Serial Number to display on the Table */
            Integer tableSerialNumber = 1;

            /* Subtotal and Total Fields for Calculation */
            List<Object> subTotFieldNames = (List<Object>) contentAndStylingMap.get('subTotal');
            
            Map<String,Object> rowStyleList = (Map<String,Object>) contentAndStylingMap.get('style');
            Map<String,Object> totalRowStyles = (Map<String,Object>) rowStyleList.get('total');
            Map<String,Object> subTotalRowStyles = (Map<String,Object>) rowStyleList.get('subTotal');

            String totalRowBGcolor = String.valueOf(totalRowStyles.get('totalRowBGcolor'));
            String totalRowFontcolor = String.valueOf(totalRowStyles.get('totalRowFontcolor'));
            String subTotalRowBGColor = String.valueOf(subTotalRowStyles.get('subTotalRowBGColor'));            
            String subTotalRowFontColor = String.valueOf(subTotalRowStyles.get('subTotalRowFontColor'));

            /* Styling Options given for the user from Template Builder */
            dateFormat = (String) contentAndStylingMap.get('dateFormat');
            timeFormat = (String) contentAndStylingMap.get('timeFormat');
            numberFormat = (String) contentAndStylingMap.get('numberFormat');
            currencyFormat = (String) contentAndStylingMap.get('currencyFormat');
            Boolean displaySerialNumber = (Boolean) contentAndStylingMap.get('SerialNumber');

            /* Inline Styles for SubTotal and GrandTotal */
            /* Html Inline style for Category <td> */
            Map<String,Object> tableStyleList = (Map<String,Object>) contentAndStylingMap.get('style');  
            Map<String,Object> categoryStyleAttributes = (Map<String,Object>) tableStyleList.get('category');
            Integer dataColSpanForCategory = (displaySerialNumber) ? selectedFieldsAsHeaderLabelList.size()+1 : selectedFieldsAsHeaderLabelList.size();       
            String categoryInlineStyle = 'border: 1px solid black ; background-color:' + categoryStyleAttributes.get('backgroundColor') + '; color:'+ categoryStyleAttributes.get('fontcolor') +'; font-size:' + categoryStyleAttributes.get('fontsize') + '; font-family:'+ categoryStyleAttributes.get('fontfamily') + ';' ;
            
            /* fieldlist String preparation for Querying */
            List<string> fieldsList= new List<string> ();
            for(Object rec: selectedFieldAsHeaderAPIList)  {
                fieldsList.add(String.valueOf(rec));
            }
            String fieldString = string.join(fieldsList,','); 

            /* Map that contains field(Key) - field type (value)*/
            Map<String,String> fieldNameType = getObjectFieldTypeMap(relatedObjectAPIName, fieldsList);

            /*Chart Styles*/
            Boolean displayChart = (Boolean) contentAndStylingMap.get('displayChart');
            Boolean displayChartInNewPage = (Boolean) contentAndStylingMap.get('chartNewPage');
            String barChartColor = (String) contentAndStylingMap.get('chartBarColor');
            String chartLabel = (String) contentAndStylingMap.get('chartLabel');
            String chartYAxis = (String) contentAndStylingMap.get('selGraphvalue');
            Map<String,Decimal> categorySubTotalValueMap = new Map<String,Decimal> {};
            Map<String,Map<String,String>> chartQuantifiers = new Map<String,Map<String,String>> {};
			
            /* Fields selected to calculate the Total and Sub Total */
            currencyFieldTotals = new Map<String,Decimal> {};
            for(Object currTempField : subTotFieldNames) {
                currencyFieldTotals.put((String) currTempField,0);
            }
            currencyFieldSubTotals = currencyFieldTotals.clone();
            
            String securityEnforced=' WITH SECURITY_ENFORCED';
            /*grouping field was selected*/
            if(relatedObjectFieldNameToGroupRecords!=null && relatedObjectFieldNameToGroupRecords!='') {
                
                Set<String> fieldStringSet = new Set<String>();
                for(String field : fieldsList)    {
                    fieldStringSet.add(field.tolowercase());
                }
                fieldStringSet.add(relatedObjectFieldNameToGroupRecords.tolowercase());
                String fieldStringquery = String.join(new List<String>(fieldStringSet), ', ');             
                String recordsQuery = 'select '+String.escapeSingleQuotes(fieldStringquery)+' from '+String.escapeSingleQuotes(relatedObjectAPIName)+' where '+String.escapeSingleQuotes(string.valueof(contentAndStylingMap.get('childLookupfieldAPIname')))+'='+'\''+String.escapeSingleQuotes(recordid)+'\''+' '+ whereClauseinQuery+' '+String.escapeSingleQuotes(securityEnforced)+' order by '+String.escapeSingleQuotes(relatedObjectFieldNameToGroupRecords)+' desc';
                relatedObjectQueriedRecords = Database.query(recordsQuery);    
                
                String ptrfield = (String) relatedObjectFieldNameToGroupRecords;  
                Map<Object, List<SObject>> recordCategoryMap = new Map<Object, List<SObject>>();
                
                for(Sobject ptrRecord : relatedObjectQueriedRecords)  {
                    if(!recordCategoryMap.containsKey(ptrRecord.get(ptrfield)) && ptrRecord.get(ptrfield)!=null)  {
                        List<SObject> recordList = new  List<SObject>();
                        recordList.add(ptrRecord);
                        recordCategoryMap.put(ptrRecord.get(ptrfield),recordList);
                        categorySubTotalValueMap.put(String.valueOf(ptrRecord.get(ptrfield)),0.00);
                    }
                    else if(recordCategoryMap.containsKey(ptrRecord.get(ptrfield)) && ptrRecord.get(ptrfield)!=null)  {
                        List<SObject> recordList= recordCategoryMap.get(ptrRecord.get(ptrfield));
                        recordList.add(ptrRecord); 
                        recordCategoryMap.put(ptrRecord.get(ptrfield),recordList);
                    }
                    else {
                        if(recordCategoryMap.containsKey('Others'))  {
                            List<SObject> recordList= recordCategoryMap.get('Others');
                            recordList.add(ptrRecord); 
                            recordCategoryMap.put('Others',recordList); 
                            categorySubTotalValueMap.put('Others',0.00);   
                        }
                        else {
                            List<SObject> recordList = new  List<SObject>();
                            recordList.add(ptrRecord);
                            recordCategoryMap.put('Others',recordList);
                        }
                    }
                }      
                Boolean firstTDblock ;

                for(Object key: recordCategoryMap.keyset())  {
                    roHtmlContent = roHtmlContent + '<tr> <td  colspan=\"'+ dataColSpanForCategory +'\" scope="col" Style = \"'+ categoryInlineStyle + '\">' + String.valueOf(key).toUpperCase() + '</td> </tr> ';
                                        
                    String ptrKey = (String) key;
                    List<Object> recordListofKey = recordCategoryMap.get(ptrKey);
                    tableSerialNumber = 1;

                    Integer count = recordListofKey.size();
                    for(Integer i=0; i<count; i++)  {
                        Sobject currRecord = (Sobject) recordListofKey[i];
                        roHtmlContent += '<tr>';
                        if(displaySerialNumber)  {
                            roHtmlContent = roHtmlContent + '<td scope="col" style="border: 1px solid black; text-align: center;">' + tableSerialNumber  + '</td>';
                        }
                        dataFetchFromCurrentRecord(selectedFieldAsHeaderAPIList, currRecord, fieldNameType);
                        roHtmlContent += '</tr>';
                        tableSerialNumber+=1; 
                    }                 
                    
                    firstTDblock = displaySerialNumber;
                    if(currencyFieldTotals.size() > 0) {
                        roHtmlContent += '<tr>';
                        roHtmlContent = roHtmlContent + '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + subTotalRowBGColor + ';color:' + subTotalRowFontColor + ';border-right-style: none; font-size: 12px">Sub Total</td>';
                        for(Object ptrFieldSubTotal : selectedFieldAsHeaderAPIList) {
                            if(currencyFieldTotals.containsKey((String) ptrFieldSubTotal) && subTotFieldNames.contains(ptrFieldSubTotal)) {
                                roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + subTotalRowBGColor + ';color:' + subTotalRowFontColor + '; text-align: center; border-right-style:none; border-left-style:none;\">' + currencyFieldSubTotals.get((String) ptrFieldSubTotal) + '</td>';
                            }
                            else {
                                if(firstTDblock)  {
                                    roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + subTotalRowBGColor + ';color:' + subTotalRowFontColor + ';border-right-style: none;border-left-style:none;\"> </td>';
                                }                                
                                firstTDblock = true;
                            }
                        }
                        roHtmlContent += '</tr>';
                    }
                    categorySubTotalValueMap.put(String.valueOf(key),currencyFieldSubTotals.get(chartYAxis));                                      
                    
                    /*Resetting the Subtotals to zero for next Category Sub-Total Calculation*/
                    for(String currTempField : currencyFieldTotals.keySet())  {
                        currencyFieldSubTotals.put(currTempField,0);
                    }
                }
                
                firstTDblock = displaySerialNumber;
                if(currencyFieldTotals.size() > 0)  {
                    roHtmlContent += '<tr>';
                    roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + totalRowBGcolor  + ' ; color: ' + totalRowFontcolor + ' ; border-right-style: none; font-size: 12px">Grand Total</td>';
                    
                    for(Object ptrFieldTotal : selectedFieldAsHeaderAPIList) {
                        if(currencyFieldTotals.containsKey((String) ptrFieldTotal) && subTotFieldNames.contains(ptrFieldTotal)) {
                            roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + totalRowBGcolor  + ';color:' + totalRowFontcolor + ';border-right-style:none; text-align: center; border-left-style:none;\">' + currencyFieldTotals.get((String) ptrFieldTotal) + '</td>';
                        } else {
                            if(firstTDblock)  {
                                roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + totalRowBGcolor  + ';color:' + totalRowFontcolor + ';border-right-style: none; border-left-style:none;\"> </td>';
                            }
                            firstTDblock = true;
                        }
                    }
                    roHtmlContent += '</tr>';
                }
            }

            /*No Grouping field was selected*/
            else {
                String recordsQuery = 'select '+String.escapeSingleQuotes(fieldString)+' from '+String.escapeSingleQuotes(relatedObjectAPIName)+' where '+String.escapeSingleQuotes(string.valueof(contentAndStylingMap.get('childLookupfieldAPIname')))+'='+'\''+String.escapeSingleQuotes(recordid)+'\''+' '+ whereClauseinQuery +' '+String.escapeSingleQuotes(securityEnforced);
                relatedObjectQueriedRecords = Database.query(recordsQuery);      

                for(Sobject currRecord: relatedObjectQueriedRecords) {
                    roHtmlContent += '<tr>';
                    if(displaySerialNumber)  {
                        roHtmlContent = roHtmlContent + '<td scope="col" style="border: 1px solid black; text-align: center;">' + tableSerialNumber  + '</td>';
                    }
                    dataFetchFromCurrentRecord(selectedFieldAsHeaderAPIList, currRecord, fieldNameType);                  
                    roHtmlContent += '</tr>';
                    tableSerialNumber += 1;
                }

                /*Adding GrandTotals to WrapperList*/
                Boolean firstTDblock = displaySerialNumber;
                if(currencyFieldTotals.size() > 0)  {
                    roHtmlContent += '<tr>';
                    roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + totalRowBGcolor  + ';color: ' + totalRowFontcolor + ';border-right-style: none; font-size: 12px">Grand Total</td>';
                    for(Object ptrFieldTotal : selectedFieldAsHeaderAPIList) {
                        if(currencyFieldTotals.containsKey((String) ptrFieldTotal) && subTotFieldNames.contains(ptrFieldTotal)) {
                            roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + totalRowBGcolor  + ';color:' + totalRowFontcolor + ';border-right-style:none; border-left-style:none;\">' + currencyFieldTotals.get((String) ptrFieldTotal) + '</td>';
                        }
                        else {
                            if(firstTDblock)  {
                                roHtmlContent += '<td colspan="1" scope="col" style="border: 1px solid black; background-color:' + totalRowBGcolor  + ' ; color: ' + totalRowFontcolor + ';border-right-style: none;border-left-style:none;\"> </td>';
                            }                            
                            firstTDblock = true;
                        }
                    }
                    roHtmlContent += '</tr>';  
                }              
            }
            roHtmlContent += '</tbody>';

            /*HTML formation of Chart*/
            if(displayChart){

                String newPageHtmlSnippet = displayChartInNewPage==true ? 'style="page-break-before:always;"' : '';
                String chartContent = '<div> <table width="100%" height="auto"' + newPageHtmlSnippet + '> <tr> <td width="75%" style="text-align: center;"> <h4>' + chartLabel + '</h4> </td> </tr>';
                chartContent += '<tr> <td> <div style="border:1px solid #666666; width:100%; height:300px;"> <table class="innerbase" style="width:calc(96% - 20px); height:280px; margin:10px; padding:0px 5px 0px 5px; border-bottom:2px solid #666666; background: repeating-linear-gradient( 180deg, #cccccc 0, #cccccc 1px, transparent 1px, transparent 20% );">';
                chartContent += '<tbody> <tr> <td style="width: 3%; text-align: center; writing-mode: vertical-rl; text-orientation: upright;">' + chartYAxis + '</td>';
                
                Map<String,String> chartStaticResourceStyle = new Map<String,String> {};
                for(ChartAutomationStyleResources__mdt chartStyleAttribute :  [SELECT Id,Label,Style_Composition__c FROM ChartAutomationStyleResources__mdt]){
                    chartStaticResourceStyle.put(chartStyleAttribute.label,chartStyleAttribute.Style_Composition__c );
                }

                /*Bar height Calculation*/
                for(String keyPtr : categorySubTotalValueMap.keySet()){
                    Decimal val = (categorySubTotalValueMap.get(keyPtr) / currencyFieldTotals.get(chartYAxis));
                    String htpt = String.valueOf((val.setScale(3))*100);
                    
                    Map<String,String> tempMap = new Map<String,String> {
                        'width' => String.valueOf(Math.round(93/(categorySubTotalValueMap.size()))) + '%',
                        'percent' => htpt +'%',
                        'height' => htpt +'% ; background : ' + barChartColor + ';',
                        'value' => String.valueOf(categorySubTotalValueMap.get(keyPtr))
                    };
                    chartQuantifiers.put(keyPtr,tempMap);
                }

                /*Bar Style formation*/
                for(String categoryItem : chartQuantifiers.keySet()){
                    chartContent += '<td style="' + chartStaticResourceStyle.get('itembase') +' width:' + chartQuantifiers.get(categoryItem).get('width')+ '" valign="bottom">';
                    chartContent += '<div style="' + chartStaticResourceStyle.get('itemtitle') + '">' + categoryItem + '</div>';
                    chartContent += '<div style="' + chartStaticResourceStyle.get('itemvalueout') + '">' + chartQuantifiers.get(categoryItem).get('percent') + '</div>';
                    chartContent += '<div style="' + chartStaticResourceStyle.get('itembar') + ' ;height : ' + chartQuantifiers.get(categoryItem).get('height') + '">';
                    chartContent += '<div style="' + chartStaticResourceStyle.get('itemvaluein') + ' padding:10px 5px 5px; color:#ffffff">' + chartQuantifiers.get(categoryItem).get('value') + '</div> </div> </td>';
                }

                chartContent += '</tr> </tbody> </table> </div> </td> </tr> ';
                chartContent +='<tr> <td style="text-align: center;"> Categories </td> </tr> </table> </div>';
                roHtmlContent+=chartContent;
            }
            
            return roHtmlContent;
        }
        catch(Exception ex) {
            LogHandler.createLog((Id) templatesectionid,'ROsectionAutomationController.getsectionData()','Template Id- '+ relatedObjectSectionID + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');   
        }
        return '';
    }
    
    /* Function that formulates each Object's Field and Type */
    /**
 * @description Retrieves a map containing the data type of each field in the specified object.
 * @param objName The API name of the object for which field data types are retrieved.
 * @param fieldList A list of field names for which data types need to be determined.
 * @return Map<String,String> A map where field names are keys, and values are their corresponding data types.
 */
    public static Map<String,String> getObjectFieldTypeMap(String objName, List<String> fieldList)  {
        Map<String,String> fieldNameType = new Map<String,String>();
        try {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(objName);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            for (String selfield: fieldList) {
                if(selfield.contains('.'))  {
                    if(selfield.contains('__r'))  {
                        String fieldcstm = selfield.replace('__r' , '__c');
                        List<String> tempfield = fieldcstm.split('\\.');
                        
                        // Related Object other than User Object
                        String objNameLkp = getReferenceObjectAPIName(objName,tempfield[0]);
                        
                        tempfield.remove(0);
                        Map<String,String> fieldNameTypeLookup = getObjectFieldTypeMap(objNameLkp,tempfield);
                        fieldNameType.put(selfield,fieldNameTypeLookup.get(tempfield[0]));
                    }
                    else {
                        List<String> tempfield = selfield.split('\\.');
                        tempfield.remove(0);
                        Map<String,String> fieldNameTypeLookup = getObjectFieldTypeMap('User',tempfield);
                        fieldNameType.put(selfield,fieldNameTypeLookup.get(tempfield[0]));
                    }
                }
                else {
                    String fielddataType = String.valueof(fieldMap.get(selfield).getDescribe().getType());
                    fieldNameType.put(selfield,fielddataType);
                }
            }
        }
        catch(Exception ex) {
            LogHandler.createLog((Id) null,'ROsectionAutomationController.getObjectFieldTypeMap()','Template Id- '+ relatedObjectSectionID + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');   
        }
        return fieldNameType;
    }
    
	/**
 * @description Retrieves the API name of the related object from a given object and lookup field.
 * @param fromObjName The API name of the source object where the lookup field is defined.
 * @param lkpField The API name of the lookup field for which the related object API name is to be retrieved.
 * @return The API name of the related object, or an empty string if an exception occurs.
 */
    public static string getReferenceObjectAPIName(String fromObjName, String lkpField)  {
        try {            
            Schema.DescribeFieldResult scehmaMap = Schema.getGlobalDescribe().get(fromObjName).getDescribe().fields.getMap().get(lkpField).getDescribe();
            for(Schema.SObjectType reference : scehmaMap.getReferenceTo()) {
                return reference.getDescribe().getName();
            }
        }
        catch(Exception ex)  {
            LogHandler.createLog((Id) null,'ROsectionAutomationController.getReferenceObjectAPIName()','Template Id- '+ relatedObjectSectionID + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');
        }
        return '';
    } 
    
	/**
 * @description Extracts data from the current record and populates the HTML content for a table cell.
 * @param selectedFieldAsHeaderAPIList List of selected field API names to be used as headers.
 * @param currRecord Current record from which data is extracted.
 * @param fieldNameType Mapping of field API names to their data types.
 */
    public static void dataFetchFromCurrentRecord(List<Object> selectedFieldAsHeaderAPIList, Sobject currRecord, Map<String,String> fieldNameType)  {
       try{
            for(Object field : selectedFieldAsHeaderAPIList) {
                Object recVal;   
                String fieldStr = (String) field;
                String fieldTypeAsText = ((String) fieldNameType.get(fieldStr)).toUpperCase();

                Map<String, Object> currRecordLkpData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(currRecord));
                
                if(fieldStr.contains('__r')) {
                    List<String> lkpFieldSplit = fieldStr.split('\\.');
                    if(currRecordLkpData.containsKey(lkpFieldSplit[0])) {	
                        Map<String, Object> childLkpData = (Map<String, Object>) currRecordLkpData.get(lkpFieldSplit[0]);
                        recVal = childLkpData.get(lkpFieldSplit[1]);
                        
                        if(currencyFieldTotals.containsKey(fieldStr))  {
                            if(recVal == null) {recVal = 0;}
                            
                            Decimal tempValueTotal = currencyFieldTotals.get(fieldStr) + (Decimal) recVal;
                            currencyFieldTotals.put(fieldStr, tempValueTotal);
                            
                            Decimal tempValueSubTotal = currencyFieldSubTotals.get(fieldStr) + (Decimal) recVal;
                            currencyFieldSubTotals.put(fieldStr, tempValueSubTotal);
                        } 
                    }
                    else {
                        recVal = ' ';
                    }
                }
                else if(!fieldStr.contains('__r') && fieldStr.contains('.'))  {
                    List<String> lkpFieldSplit = fieldStr.split('\\.');
                    Map<String, Object> childLkpData = (Map<String, Object>) currRecordLkpData.get(lkpFieldSplit[0]);
                    recVal = childLkpData.get(lkpFieldSplit[1]);
                    
                    if(currencyFieldTotals.containsKey(fieldStr)) {
                        if(recVal == null) {recVal = 0;}
                        
                        Decimal tempValueTotal = currencyFieldTotals.get(fieldStr) + (Decimal) recVal;
                        currencyFieldTotals.put(fieldStr, tempValueTotal);
                        
                        Decimal tempValueSubTotal = currencyFieldSubTotals.get(fieldStr) + (Decimal) recVal;
                        currencyFieldSubTotals.put(fieldStr, tempValueSubTotal);
                    }
                }
                else {
                    recVal = currRecord.get(fieldStr);
                    if(currencyFieldTotals.containsKey(fieldStr))  {
                        if(recVal == null) {recVal = 0;}
                        
                        Decimal tempValueTotal = currencyFieldTotals.get(fieldStr) + (Decimal) recVal;
                        currencyFieldTotals.put(fieldStr, tempValueTotal);
                        
                        Decimal tempValueSubTotal = currencyFieldSubTotals.get(fieldStr) + (Decimal) recVal;
                        currencyFieldSubTotals.put(fieldStr, tempValueSubTotal);
                    } 
                }
                String cellTDwidth = '70px';

                if(recVal!=null){
                    String returnedFormattedValue = String.valueOf(recVal);
                    cellTDwidth = (fieldTypeAsText == 'BOOLEAN') ? '30px' : '70px';

                    if(fieldTypeAsText == 'DATETIME') {
                        List<String> dateList = returnedFormattedValue.split(' ')[0].split('-');
                        String timeStr = returnedFormattedValue.split(' ')[1];
                        returnedFormattedValue = handleDateTimeFormatAsSelectedbyUser(dateList,timeStr,-1);
                    }
                    else if (fieldTypeAsText == 'TIME') {
                        String timeStr = returnedFormattedValue.split('\\.')[0];
                        returnedFormattedValue = handleDateTimeFormatAsSelectedbyUser(null,timeStr,0);
                    }
                    else if (fieldTypeAsText == 'DATE') {
                        List<String> dateList = returnedFormattedValue.split(' ')[0].split('-');
                        returnedFormattedValue = handleDateTimeFormatAsSelectedbyUser(dateList,null,0);
                    }
                    else if (fieldTypeAsText == 'NUMBER') {
                        returnedFormattedValue = String.valueOf(handleCurrencyNumberFormat(returnedFormattedValue, numberFormat));
                        cellTDwidth = '30px';
                    }
                    else if (fieldTypeAsText == 'CURRENCY') {
                        returnedFormattedValue = String.valueOf(handleCurrencyNumberFormat(returnedFormattedValue, currencyFormat));
                        cellTDwidth = '30px';
                    }
                    
                    /* Check for Image and styling the TD accordingly */
                    if(returnedFormattedValue.contains('servlet.shepherd/version/download/')){
                        roHtmlContent = roHtmlContent + '<td scope="col" width="100px" style="border: 1px solid black; text-align: center;"> <img style="max-height:100% ; max-width:100%; height:40px; width:40px;" src= '+ returnedFormattedValue +'> </td>';
                    } else {
                        roHtmlContent = roHtmlContent + '<td scope="col" width=\"' + cellTDwidth +'\" style="border: 1px solid black; text-align: center;">' + returnedFormattedValue + '</td>';
                    }
                } else {
                    roHtmlContent = roHtmlContent + '<td scope="col" width=\"' + cellTDwidth +'\" style="border: 1px solid black; text-align: center;"> </td>';
                }                 
            }
        }
        catch(Exception ex) {
            if(errorTypeCaught==null) {
                errorTypeCaught = ex.getTypeName();
                LogHandler.createLog((Id) null,'ROsectionAutomationController.dataFetchFromCurrentRecord()','Template Id- '+ relatedObjectSectionID + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');
            }
            else if(ex.getTypeName()!=errorTypeCaught) {
                LogHandler.createLog((Id) null,'ROsectionAutomationController.dataFetchFromCurrentRecord()','Template Id- '+ relatedObjectSectionID + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');
            }
        }
    }

    
    /*Functions to handle to the Date Time Style for the field value.*/
	/**
 * @description Handles the formatting of date and time based on the user's preferences.
 * @param dateList List of date components (year, month, day).
 * @param timeStr String representation of time.
 * @param valKey Integer to determine the output format: 
 *               0 for both date and time, 
 *               <0 for date only, 
 *               >0 for time only.
 * @return Formatted date, time, or both based on the valKey parameter.
 * @throws AuraHandledException if an exception occurs during the formatting process.
 */
    public static String handleDateTimeFormatAsSelectedbyUser(List<String> dateList, String timeStr, Integer valKey)  { 
        String dateFormatSep; 
        String dateFormatted = '';
        String timeFormatted = '';     
        Integer numDateFormat ; 
        String dateFormatStr = dateFormat;  
        String timeFormatStr = timeFormat;
        List<String> timer = new List<String> {};
        List<Integer> dateIndex = new List<Integer> {};
        List<String> monthLstHalf = new List<String>{'', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
        
        try{
            if (dateList != null && dateFormatStr != null) {          
                
                if(dateFormatStr.contains('*'))  {
                    numDateFormat = Integer.valueOf(dateFormatStr.substring(0, dateFormatStr.length() - 2));
                    Integer charIndex = (dateFormatStr.length() - 2); 
                    dateFormatSep = dateFormatStr.substring(charIndex,charIndex+1);
                }
                else {
                    numDateFormat = Integer.valueOf(dateFormatStr.substring(0, dateFormatStr.length() - 1));
                    Integer charIndex = (dateFormatStr.length() - 2); 
                    dateFormatSep = dateFormatStr.substring(charIndex+1); 
                }  
                
                while (numDateFormat > 0) {
                    Integer rem = Math.mod(numDateFormat, 10);
                    if (((Integer)(rem - 4)) <= 0) { dateIndex.add(0); }
                    else {
                        Integer key = rem - 4;
                        dateIndex.add(key);
                    }
                    numDateFormat = (Integer)Math.floor(numDateFormat / 10);
                }
                
                if (dateFormatStr.contains('4') && !dateFormatStr.contains('*')) {             
                    dateFormatted = dateList[dateIndex[2]] + dateFormatSep + dateList[dateIndex[1]] + dateFormatSep + dateList[dateIndex[0]];
                }
                else if (dateFormatStr.contains('2') && !dateFormatStr.contains('*')) {
                    dateFormatted = dateList[dateIndex[2]] + dateFormatSep + dateList[dateIndex[1]] + dateFormatSep + dateList[dateIndex[0]].substring(2);
                }
                else if (dateFormatStr.contains('4') && dateFormatStr.contains('*')) {
                    Integer mnthIndex = dateIndex.indexOf(1);
                    dateList[dateIndex[mnthIndex]] = monthLstHalf[(Integer.valueOf(dateList[1]))];
                    dateFormatted = dateList[dateIndex[2]] + dateFormatSep + dateList[dateIndex[1]] + dateFormatSep + dateList[dateIndex[0]];
                }
                else if (dateFormatStr.contains('2') && dateFormatStr.contains('*')) {
                    Integer mnthIndex = dateIndex.indexOf(1);
                    dateList[dateIndex[mnthIndex]] = monthLstHalf[(Integer.valueOf(dateList[1]))];
                    dateFormatted = dateList[dateIndex[2]] + dateFormatSep + dateList[dateIndex[1]] + dateFormatSep + dateList[dateIndex[0]].substring(2);
                }
            }
            
            if (timeStr != null && timeFormatStr != null) {
                if (timeFormatStr.contains('4')) {                    
                    timer = (List<String>)(timeStr).split(':');
                    Integer hr = (Integer.valueOf((timeStr).split(':')[0]));

                    if (hr <= 12) {
                        if (timeFormatStr.contains('3')) { timeFormatted = timeStr + ' AM'; }
                        else { timeFormatted = timer[0] + ':' + timer[1] + ' AM'; }
                    }
                    else {
                        hr = (Integer.valueOf(timeStr.split(':')[0])); 
                        hr = (Integer)hr - 12;                     
                        if (timeFormatStr.contains('3')) { timeFormatted = String.valueOf(hr + ':' + (String)timeStr.split(':')[1]) + ':' + (String)timeStr.split(':')[2] + ' PM'; }
                        else { timeFormatted = String.valueOf(hr) + ':' +(String)timeStr.split(':')[1]  + ' PM'; }
                    }
                }
                else {
                    if (timeFormatStr.contains('3')) { timeFormatted = timeStr; }
                    else { timeFormatted = (String)timeStr.split(':')[0] + ':' + (String)timeStr.split(':')[1] ; }
                }
            }
            
            if (valKey == 0) {
                return dateFormatted + ' ' + timeFormatted;
            }
            else if (valKey < 0) {
                return dateFormatted;
            }
            else if (valKey > 0) {
                return timeFormatted;
            }
        }
        catch(Exception ex)  {
            throw new AuraHandledException(ex.getMessage());
        }
        return '';
    }        
    
    /* Format the Number or Currency Field Value to User Selected Format */
    /**
 * @description Handles the formatting of a currency or number field based on the specified rounding pattern.
 * @param fieldValue String representation of the numerical value to be formatted.
 * @param roundPattern String representing the rounding pattern for the numerical value.
 * @return Object containing the formatted Decimal value or 'Error' if an exception occurs during the formatting.
 */
    public static Object handleCurrencyNumberFormat(String fieldValue, String roundPattern)  {
        try {
            Decimal value = (Decimal.valueOf(fieldValue)).setScale(Integer.valueOf(roundPattern));
            return (Object) value;
        }
        catch(Exception ex)  {
            return (Object) 'Error';
        }
    }

    /* Header Content Stored on the RO Template Section Record - called from Automation Class */
    /**
 * @description Retrieves the header content from a Document Template Section based on the provided section Id.
 * @param roTemplateSectionId Id of the Document Template Section to retrieve the header content from.
 * @return String representing the header content of the specified Document Template Section.
 *         If an exception occurs during the retrieval, an error message is returned.
 */
    public static String getHeaderContent(Id roTemplateSectionId)  {
        try {
            String query = 'Select Header_Content__c from Document_Template_Section__c where Id =\'' + roTemplateSectionId +'\' limit 1';
            Document_Template_Section__c roTemplateSection = Database.query(query);
            return ROTemplateSection.Header_Content__c;
        }
        catch(Exception ex)  {
            LogHandler.createLog((Id) null,'ROsectionAutomationController.getHeaderContent()','Template Id- '+ roTemplateSectionId + ' ' + ex.getLineNumber() + ex.getStackTraceString() + ex.getCause(),ex.getMessage(),'Exception');   
            return '<p> Error while querying header Content through Automation - Log is generated </p>';
        }
    }
    
	/**
 * @description Custom exception class named SafeClassException, extending the built-in Exception class.
 */
    public class SafeClassException extends Exception { }
}