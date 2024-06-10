import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import rte_tbl from '@salesforce/resourceUrl/rte_tbl';
import dexcpqcartstylesCSS from '@salesforce/resourceUrl/dexcpqcartstyles';
import saveDocumentTemplateSectionDetails from '@salesforce/apex/SaveDocumentTemplatesection.saveDocumentTemplateSectionDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deletetemplate from '@salesforce/apex/SaveDocumentTemplatesection.deletetemplate';
import getAllPopupMessages from '@salesforce/apex/PopUpMessageSelector.getAllConstants';
import gettemplatesectiondata from '@salesforce/apex/SaveDocumentTemplatesection.gettemplatesectiondata';
import getContentVersions from '@salesforce/apex/FooterClass.getContentVersions';
import getSearchedContentVersions from '@salesforce/apex/FooterClass.getSearchedContentVersions';

export default class TemplateTableDetails extends LightningElement {

    @track tableOnLoad = true;
    @track tableDisplayed = false;
    @track selectedRow = '';

    isAllBorders = false;
    isNoBorders = false;
    isOutsideBorders = false;
    isOutsideThickBorders = false;
    isOutsideThickAllBorders = false;

    isClearTable = false;
    newPage = false;
    mergeBodyCell = false;
    mergeHeaderCell = false;
    isColResizeCheck = false;
    isColSwapCheck = false;
    showmergefield = false;
    showImageModal = false;
    confirmMergeCell = false;
    showCellBgColor = false;
    isHeaderCellBgColor = false;
    isHeaderMergeField = false;
    isTableColumnSizeChange = false;

    imageUrls = [];
    mainimageUrls = [];
    @track divContentArray = [];
    selectedimageid;
    @track tableHeadersData = [];
    @track selectedImageHeight = "75px";
    @track selectedImageWidth = "75px";
    showText = true;
    searchData;
    cellBgColor = '';
    imagebuttonlabel = 'Select Image';
    showimages = false;
    imageselected = false;
    selectedimageurl;
    imagesfound = false;

    @api selectedObjectName;
    showStatement = false;
    showLstOfObj = false;
    originalTableWidth = 0;

    @track columnWidths = [];
    @track noBordersIcon = '';
    @track allBordersIcon = '';
    @track outsideBordersIcon = '';
    @track thickOutsideBordersIcon = '';
    @track thickOutsideAllBordersIcon = '';

    draggedColumnIndex;
    resizing;
    selectedThValue;
    resizingColumnIndex;
    initialResizeX;
    resizingColumn = null;

    tablehasdata=false;

    fontsize = "12px";

    fontsizeoptions = [
        { value: '8px', label: '8' }, { value: '9px', label: '9' }, { value: '10px', label: '10' }, { value: '12px', label: '12' },
        { value: '14px', label: '14' }, { value: '16px', label: '16' }, { value: '18px', label: '18' }, { value: '20px', label: '20' }, { value: '22px', label: '22' }, { value: '24px', label: '24' }, { value: '26px', label: '26' }, { value: '28px', label: '28' }, { value: '36px', label: '36' }, { value: '48px', label: '48' }, { value: '72px', label: '72' }
    ];

    fontfamily = "Verdana";
    fontfamilyoptions = [
        { value: 'sans-serif', label: 'Arial' },
        { value: 'Verdana', label: 'Verdana' },
        { value: 'serif', label: 'Times New Roman' },
        { value: 'courier', label: 'Courier' },
    ];

    @track columnWidthValue;
    @track columnWidthOptions = [
        { label: '25%', value: '25' },
        { label: '50%', value: '50' },
        { label: '100%', value: '100' },
        { label: '125%', value: '125' },
        { label: '150%', value: '150' }
    ];

    selectedHeader;
    selectedHFontColor;
    selectedBFontColor;
    selectedHbgColor;
    selectedBBgcolor;
    @track selectedBDRbgcolor = "#000000";

    popUpMessage;

    @wire(getAllPopupMessages)
    allConstants({ error, data }) {
        if (data) {
            this.popUpMessage = data;
            console.log('Success');
        } else {
            this.error = error;
        }
    }


    renderedCallback() {
        Promise.all([
            loadStyle(this, rte_tbl + '/rte_tbl1.css'),
            loadStyle(this, dexcpqcartstylesCSS),
        ])
            .then(() => {
            })
            .catch(error => {
                console.error(error.body.message);
            });
        this.newfontsize();
    }


    @api documenttemplaterecordid;
    @api documenttemplaterecord;
    @api showtabledetails = false;
    showtablecontent = false;
    @track rowIndex;
    @track rownumber = 2;
    @track colnumber = 2;
    @track showBool = false;
    @track isSerialNumberCheck = false;
    @track isHeaderSelectedCheck = true;
    @track isColWidthChangedCheck = false;
    @api recordidtoedit = '';
    @track clauseId = '';
    @api disableButton = false;
    @api disabledeleteButton = false;
    @api sectiontype = '';
    @track value = '';
    @api rowcount;
    @track savedRecordID;
    @api recordidvalueprop;
    selectedTableRow;
    disableButton = false;

    @track Recorddetailsnew = {
        Name: '',
        DxCPQ__Section_Content__c: '',
        DxCPQ__DisplaySectionName__c: false,
        DxCPQ__New_Page__c: false,
        DxCPQ__Document_Template__c: '',
        DxCPQ__Sequence__c: 0,
        DxCPQ__Type__c: '',
        Id: '', DxCPQ__Section_Details__c: ''
    };

    isLoaded = false;
    tableheaders = [];
    @track tablerows = [];
    tablecolumns = [];
    isDisabled = false;
    @track selectedfontcolor = '#8DC141';
    @track selectedbgcolor = '#003366';
    @api sectionrecordid;


    connectedCallback() {
        this.getContentVersionData();
    }

    /**
    * Method to get Content version data for Images.
    */
    getContentVersionData() {
        getContentVersions()
            .then(data => {
                if (data) {
                    data.forEach((val) => {
                        this.imageUrls.push({ Id: val.Id, URL: '/sfc/servlet.shepherd/version/download/' + val.Id, title: val.Title, height: this.selectedImageHeight, width: this.selectedImageWidth });
                    });
                    this.showimages = true;
                    this.mainimageUrls = this.imageUrls;
                    if (this.imageUrls.length > 0) {
                        this.imagesfound = true;
                    }
                } else if (error) {
                    console.log('error in Content Versions Fetch' + JSON.stringify(error));
                }
            })
            .catch(error => {
                console.error('error caught ', error);
                this.isLoaded = false;
            })
    }

    /**
    * Method to insert selected Image in the desired Table Cell.
    */
    handleselectedImage(event) {
        this.selectedimageid = event.currentTarget.dataset.id;
        this.showImageModal = false;
        this.imageselected = true;
        this.selectedimageurl = '/sfc/servlet.shepherd/version/download/' + this.selectedimageid;
        let selectedImageData = `<img height="${this.selectedImageHeight}" width="${this.selectedImageWidth}" src="${this.selectedimageurl}"/>`;
        let elm = this.template.querySelector(`[data-id="${this.selectedTableRow}"]`);
        elm.value = selectedImageData;
        let innerdiv = this.selectedTableRow + 'div';
        let elm1 = this.template.querySelector(`[data-id="${innerdiv}"]`);
        elm1.value = selectedImageData;
        this.template.querySelector('c-modal').hide();
    }

    /**
    * Method to search Images Using Search label
    */

    handleSearch(event) {
        let searchlabel = event.currentTarget.value;
        if (searchlabel !== '') {
            getSearchedContentVersions({ searchlabel: searchlabel })
                .then(result => {
                    this.searchData = result;
                    this.imageUrls = [];
                    result.forEach((val) => {
                        this.imageUrls.push({ Id: val.Id, URL: '/sfc/servlet.shepherd/version/download/' + val.Id, title: val.Title, height: '50px', width: '50px' });
                    });
                    this.showimages = true;
                })
                .catch(error => {
                    this.searchData = undefined;
                    if (error) {
                        console.log('templateheadertype handleSearch' + JSON.stringify(error));
                    }
                })
        } else {
            this.imageUrls = this.mainimageUrls;
        }
    }

    /**
    * Method to get selected Image Height and Width (Necessary in future if we want to control the size of Image)
    */

    get selectedImageStyle() {
        return `height: ${this.selectedImageHeight}; width: ${this.selectedImageWidth};`;
    }

    /**
    * Method to store the Table header data into the DOM.  
    */

    handleRichTextAreaHead(event) {
        this.selectedHeader = event.target.dataset.head;
        let key = this.selectedHeader;
        let elm = this.template.querySelector(`[data-id="${key}"]`);
        elm.innerHTML = event.detail.value;


        let divElement = event.target.nextElementSibling;
        let divContent = divElement.innerHTML;
        let existingIndex = this.divContentArray.findIndex(item => item['data-id'] === divElement.dataset.id);

        let parentTh = divElement.closest('th');
        let backgroundColor = parentTh ? parentTh.style.backgroundColor : '';
        console.log('bg color head ' + backgroundColor);

        if (existingIndex !== -1) {
            this.divContentArray[existingIndex] = { 'data-id': divElement.dataset.id, 'Content': divContent, 'backgroundColor': backgroundColor };
        } else {
            this.divContentArray.push({ 'data-id': divElement.dataset.id, 'Content': divContent, 'backgroundColor': backgroundColor });
        }
        //this.unsavedChanges();
       // console.log('div content array in head ' + JSON.stringify(this.divContentArray));
    }

    /**
    * Method to store the Table Body data into the DOM. 
    */

    handleRichTextArea(event) {
        this.selectedTableRow = event.target.dataset.id;
        let key = event.target.dataset.id + 'div';
        let elm = this.template.querySelector(`[data-id="${key}"]`);
        elm.innerHTML = event.detail.value;

        let divElement = event.target.nextElementSibling;
        let divContent = divElement.innerHTML;
        let existingIndex = this.divContentArray.findIndex(item => item['data-id'] === divElement.dataset.id);

        let parentTd = divElement.closest('td');
        let backgroundColor = parentTd ? parentTd.style.backgroundColor : '';
        console.log('bg color ' + backgroundColor);

        if (existingIndex !== -1) {
            this.divContentArray[existingIndex] = { 'data-id': divElement.dataset.id, 'Content': divContent, 'backgroundColor': backgroundColor };
        } else {
            this.divContentArray.push({ 'data-id': divElement.dataset.id, 'Content': divContent, 'backgroundColor': backgroundColor });
        }
        //console.log('div content array ' + JSON.stringify(this.divContentArray));
    }

    /**
    * Method to fetch the selected table body cell when the user clicks a table body cell. 
    */

    getSelectedTableRowHandler(event) {
        this.selectedTableRow = (event.target.dataset.id == undefined) ? this.selectedTableRow : event.target.dataset.id;
        this.unsavedChanges();
    }

    /**
    * Method to fetch the selected table header cell when the user clicks a table header cell. 
    */

    getSelectedTableHeader(event) {
        this.selectedHeader = (event.target.dataset.head == undefined) ? this.selectedHeader : event.target.dataset.head;
        this.unsavedChanges();
    }

    /**
    * Method to Activate the selected Template  
    */

    @api
    handleActivateTemplate(isActive, objName) {
        this.selectedObjectName = objName;
        this.isDisabled = isActive;
        this.disableButton = isActive;
        this.disabledeleteButton = isActive;
    }

    /**
    * Method to handle Merge fields in Table Body Cells 
    */

    handlemergefieldadd() {
        this.template.querySelector('c-modal').show();
        this.showmergefield = true;
        this.showImageModal = false;
        this.isHeaderMergeField = false;
        this.isHeaderCellBgColor = false;
        this.isClearTable = false;
        this.isTableColumnSizeChange = false;
    }

    /**
    * Method to handle Merge fields in Table Header Cells 
    */

    handleHeadermergefieldadd() {
        this.template.querySelector('c-modal').show();
        this.showmergefield = true;
        this.showImageModal = false;
        this.isHeaderCellBgColor = false;
        this.isHeaderMergeField = true;
        this.isClearTable = false;
        this.isTableColumnSizeChange = false;
    }

    /**
    * Method to handle Images in Table Body Cells 
    */

    handleImageadd() {
        this.template.querySelector('c-modal').show();
        this.showmergefield = false;
        this.showImageModal = true;
        this.isClearTable = false;
        this.isTableColumnSizeChange = false;
    }

    /**
    * Method to store the Table merge fields data into the DOM.  
    */

    getMergeField() {
        let mergeField = this.template.querySelector('c-dx-lookup-fields-displaycmp').getMergeField();
        if (mergeField != undefined) {
            let mergefieldname = '{!' + this.selectedObjectName + '.' + mergeField + '}';
            this.template.querySelector('c-modal').hide();

            if (this.isHeaderMergeField === false) {
                let elm = this.template.querySelector(`[data-id="${this.selectedTableRow}"]`);
                elm.value += mergefieldname;
                let innerdiv = this.selectedTableRow + 'div';
                let elm1 = this.template.querySelector(`[data-id="${innerdiv}"]`);
                elm1.value += mergefieldname;
            }
            else {
                let elm2 = this.template.querySelector(`[data-head="${this.selectedHeader}"]`);
                elm2.value += mergefieldname;
            }
        }
    }

    /**
    * Method to add a new row to the table 
    */

    handlenewrow() {
        if (Number(this.rownumber) < 20) {
            let myObj = new Object();
            myObj.rownumber = 'row' + (Number(this.rownumber) + 1);
            let columns = [];
            for (let j = 1; j <= this.colnumber; j++) {
                columns.push({ id: 'row' + (this.rownumber + 1) + 'col' + j, divid: 'row' + this.rownumber + 'col' + j + 'div' });
                this.tablecolumns.push({ id: 'row' + this.rownumber + 'col' + j, divid: 'row' + this.rownumber + 'col' + j + 'div' });
            }
            myObj.columns = columns;
            this.tablerows.push(myObj);
            this.rownumber = Number(this.rownumber) + 1;
            this.handletablecreate();
            let parentData = this;
            setTimeout(function () { parentData.handleBorderStyling(); }, 100);
        }
        else {
            let errormsg = new ShowToastEvent({
                title: 'Error',
                message: 'Number of Rows Cannot be more than 20',
                variant: 'Error',
            });
            this.dispatchEvent(errormsg);
        }
    }

    /**
    * Method to add a new column to the table 
    */
    handlenewcolumn() {
        if (Number(this.colnumber) < 10) {
            this.colnumber = Number(this.colnumber) + 1;
            let colcount = this.colnumber;
            this.tableheaders.push('Header ' + this.colnumber);
            this.tablerows.forEach((loopvar, index) => {
                let rowcolumns = loopvar.columns;
                for (let j = colcount; j <= colcount; j++) {
                    rowcolumns.push({ id: 'row' + (index + 1) + 'col' + j, divid: 'row' + index + 'col' + j + 'div' });
                    this.tablecolumns.push({ id: 'row' + (index + 1) + 'col' + j, divid: 'row' + index + 'col' + j + 'div' });
                }
                loopvar.columns = rowcolumns;
            });
            this.handletablecreate();
            let parentData = this;
            setTimeout(function () { parentData.handleBorderStyling(); }, 100);
        }
        else {
            let errormsg1 = new ShowToastEvent({
                title: 'Error',
                message: 'Number of Columns Cannot be more than 10',
                variant: 'Error',
            });
            this.dispatchEvent(errormsg1);
        }
    }


    /**
    * Method to create a table based on the rows and columns
    */

    handletablecreate() {
        if (!(this.rownumber > 0 && this.rownumber < 21)) {
            let errormsg = new ShowToastEvent({
                title: 'Error',
                message: 'Number of Rows Should Be Atleast 1 and Atmost 20',
                variant: 'Error',
            });
            this.dispatchEvent(errormsg);
        }
        else if (!(this.colnumber > 0 && this.colnumber < 11)) {
            let errormsg1 = new ShowToastEvent({
                title: 'Error',
                message: 'Number of Columns Should Be Atleast 1 and Atmost 10',
                variant: 'Error',
            });
            this.dispatchEvent(errormsg1);
        }
        else {
            this.tableheaders = [];
            this.tablecolumns = [];
            this.tablerows = [];
            this.tableOnLoad = false;
            this.tableDisplayed = true;
            this.showtablecontent = true;
            let colcount = this.colnumber;

            for (let i = 0; i < colcount; i++) {
                this.tableheaders.push('Header ' + (i + 1));
            }
            this.rowcount = this.rownumber;
            for (let i = 1; i <= this.rowcount; i++) {
                let myObj = new Object();
                myObj.rownumber = 'row' + i;
                myObj.rowindex = i;
                let columns = [];
                for (let j = 1; j <= colcount; j++) {
                    columns.push({ id: 'row' + i + 'col' + j, divid: 'row' + i + 'col' + j + 'div', isMerged: false, isRemoved: false, backgroundColor: false });
                    this.tablecolumns.push({ id: 'row' + i + 'col' + j, divid: 'row' + i + 'col' + j + 'div', isMerged: false, isRemoved: false, backgroundColor: false });
                }
                myObj.columns = columns;
                this.tablerows.push(myObj);
            }
            if (this.tablehasdata == false){
                this.unsavedChanges();
                this.tablehasdata= true;
            }
        }
    }


    /**
    * Method to delete the last row of the table 
    */

    handleDeleteRow() {
        if (this.rownumber > 1 && this.tablerows.length > 0) {
            this.tablerows.pop();
            this.rownumber = Number(this.rownumber) - 1;
            this.unsavedChanges();
        }
        else {
            let errormsg = new ShowToastEvent({
                title: 'Error',
                message: 'Number of Rows Cannot be less than 1',
                variant: 'Error',
            });
            this.dispatchEvent(errormsg);
        }
    }

    /**
    * Method to delete the last (right most) column of the table 
    */

    handleDeleteColumn() {
        if (this.colnumber > 1) {
            this.colnumber = Number(this.colnumber) - 1;
            let colcount = this.colnumber;
            this.tableheaders.pop();
            this.tablerows.forEach((row, index) => {
                let rowcolumns = row.columns;
                if (rowcolumns.length > colcount) {
                    if (rowcolumns[colcount].isRemoved) {
                        let previousCellIndex = colcount - 1;
                        while (previousCellIndex >= 0) {
                            if (rowcolumns[previousCellIndex].isRemoved) {
                                previousCellIndex--;
                            } else {
                                let colspan = this.template.querySelector(`[data-id="${rowcolumns[previousCellIndex].id}"]`).closest('td').getAttribute('colspan') || 1;
                                if (colspan > 1) {
                                    this.template.querySelector(`[data-id="${rowcolumns[previousCellIndex].id}"]`).closest('td').setAttribute('colspan', colspan - 1);
                                }
                                break;
                            }
                        }
                    }
                    if (!rowcolumns[colcount].isRemoved) {
                        rowcolumns.splice(colcount, 1);
                        this.tablecolumns.pop();
                    }
                }
            });
            this.unsavedChanges();
            // console.log('table data after deleting ' + JSON.stringify(this.tablerows))
        } else {
            let errormsg1 = new ShowToastEvent({
                title: 'Error',
                message: 'Number of Columns Cannot be less than 1',
                variant: 'Error',
            });
            this.dispatchEvent(errormsg1);
        }
    }

    /**
    * Method to handle font size , font colors, background colors of the table cells.
    */
    newfontsize() {
        let thElements = this.template.querySelectorAll('th');
        let tdElements = this.template.querySelectorAll('td');

        thElements.forEach(th => {
            let thId = th.getAttribute('data-headercell');
            th.style.fontSize = this.fontsize;
            th.style.color = this.selectedHFontColor;

            let thColumn = this.tablecolumns.find(column => column.id === thId);
            if ((!thColumn || !thColumn.backgroundColor) && this.selectedHbgColor) {
                th.style.backgroundColor = this.selectedHbgColor;
            }
        });

        tdElements.forEach(td => {
            let tdId = td.getAttribute('data-bodycell');
            td.style.fontSize = this.fontsize;
            td.style.color = this.selectedBFontColor;

            let tdColumn = this.tablecolumns.find(column => column.id === tdId);
            if ((!tdColumn || !tdColumn.backgroundColor) && this.selectedBBgcolor) {
                td.style.backgroundColor = this.selectedBBgcolor;
            }
        });
    }

    /**
    * Method to handle font color change 
    */

    handlefontcolorchange(event) {
        this.selectedfontcolor = event.target.value;
    }

    /**
    * Method to handle background color change 
    */

    handlebgcolorchange(event) {
        this.selectedbgcolor = event.target.value;
    }

    /**
    * Method to handle change in number of rows. 
    */
    handlerowchange(event) {
        this.rownumber = event.target.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in number of columns.
    */
    handlecolchange(event) {
        this.colnumber = event.target.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in section name of the template.
    */
    handlename(event) {
        this.Recorddetailsnew.Name = event.detail.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle the selected Border style
    */

    handleMenuItemSelect(event) {
        this.selectedBorderStyle = event.detail.value;
        this.unsavedChanges();
        //console.log('Selected value:', this.selectedBorderStyle);
    }

    /**
    * Method to save the template section details into the database.
    */

    handlesectionsave(event) {
        if (this.tableOnLoad === true && this.tableDisplayed === false && this.showtablecontent === false) {
            let showTableClickCheck = new ShowToastEvent({
                title: 'Error',
                message: 'Please Click on Show Table button before Saving/Updating Table Section',
                variant: 'error',
            });
            this.dispatchEvent(showTableClickCheck);
        }
        else {
            const saveEvent = new CustomEvent('datasaved', {detail: true });
            this.dispatchEvent(saveEvent);
            this.isColResizeCheck = false;
            this.isColSwapCheck = false;
            let jsonString = '';
            let obj = {};
            obj.rownumber = this.rownumber;
            obj.colnumber = this.colnumber;
            obj.serialNumberColumn = this.isSerialNumberCheck;
            obj.headersIncluded = this.isHeaderSelectedCheck
            obj.colWidthChanged = this.isColWidthChangedCheck;
            obj.headerFont = this.selectedHFontColor;
            obj.bodyFont = this.selectedBFontColor;
            obj.headbackground = this.selectedHbgColor;
            obj.bodybackground = this.selectedBBgcolor;
            obj.fontsize = this.fontsize;
            obj.fontfamily = this.fontfamily;
            obj.borderstyle = this.selectedBorderStyle;
            obj.bordercolor = this.selectedBDRbgcolor;
            obj.newPage = this.newPage;
            //console.log('div content array ' + JSON.stringify(this.divContentArray));
            obj.sectionInfo = this.divContentArray;

            jsonString = JSON.stringify(obj);

            this.Recorddetailsnew.DxCPQ__Section_Details__c = jsonString;
            let tableclass = this.template.querySelector('.tableMainClass');

            let colSwapRows = tableclass.querySelectorAll('.colswap');
            colSwapRows.forEach(row => {
                row.parentNode.removeChild(row);
            });

            let colWidthUpdateRows = tableclass.querySelectorAll('.colwidthupdaterow');
            colWidthUpdateRows.forEach(row => {
                row.parentNode.removeChild(row);
            });

            if (this.newpage) {
                this.Recorddetailsnew.DxCPQ__Section_Content__c = "<div style=\"page-break-before : always;\">" + tableclass.innerHTML.replace(/hidden=""/g, '') + "</div>";
            } else {
                this.Recorddetailsnew.DxCPQ__Section_Content__c = tableclass.innerHTML.replace(/hidden=""/g, '');
            }
            this.Recorddetailsnew.DxCPQ__New_Page__c = this.newpage;

            //this.Recorddetailsnew.DxCPQ__Section_Content__c = tableclass.innerHTML.replace(/hidden=""/g, '');


            this.Recorddetailsnew.DxCPQ__Document_Template__c = this.documenttemplaterecordid;
            this.Recorddetailsnew.DxCPQ__New_Page__c = this.newPage;
            this.Recorddetailsnew.DxCPQ__Sequence__c = this.rowcount;
            this.Recorddetailsnew.DxCPQ__Type__c = this.sectiontype;
            let currecid = this.sectionrecordid;
            if (currecid != '' && this.sectionrecordid.indexOf('NotSaved') == -1) {
                this.Recorddetailsnew.Id = this.sectionrecordid;
            }

            if (this.Recorddetailsnew.Name != '' && this.Recorddetailsnew.Name != null) {

                saveDocumentTemplateSectionDetails({ Recorddetails: this.Recorddetailsnew })
                    .then(result => {
                        if (result != null) {
                            this.savedRecordID = result;
                            let event4 = new ShowToastEvent({
                                title: 'Success',
                                message: 'Section "' + this.Recorddetailsnew.Name + '"' + ' was Saved',
                                variant: 'success',
                            });
                            this.dispatchEvent(event4);
                            let firecustomevent = new CustomEvent('savesectiondata', {
                                detail:
                                    this.savedRecordID
                            });
                            this.dispatchEvent(firecustomevent);
                        }
                        else {
                            let resultNullCheck = new ShowToastEvent({
                                title: 'Error',
                                message: 'Error Occured. Please Check the Latest Transaction Log',
                                variant: 'Error',
                            });
                            this.dispatchEvent(resultNullCheck);
                        }
                    })
                    .catch(error => {
                        console.log('error', error);
                    })
            }
            else {
                let Errormsg = new ShowToastEvent({
                    title: 'Error',
                    message: this.popUpMessage.TEMPLATETABLE_DETAILS12,
                    variant: 'Error',
                });
                this.dispatchEvent(Errormsg);
            }
        }
    }

    /**
    * Method to handle change in font size
    */

    handlefontsizeChange(event) {
        this.fontsize = event.detail.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in font family 
    */

    handlefontfamilyChange(event) {
        this.fontfamily = event.detail.value;
        this.template.querySelectorAll('.mytable')[0].style.fontFamily = this.fontfamily;
        this.unsavedChanges();
    }

    /**
    * Method to delete template section 
    */
    handlesectionDelete(event) {
        if (this.sectionrecordid.indexOf('NotSaved') !== -1) {
            let firecustomevent = new CustomEvent('deletesectiondata', { detail: this.sectionrecordid });
            this.dispatchEvent(firecustomevent);
        }
        else {
            deletetemplate({ secidtobedeleted: this.sectionrecordid, doctemplateid: this.documenttemplaterecordid })
                .then(result => {
                    if (result != null) {
                        let firecustomevent = new CustomEvent('deletesectiondata', { detail: this.sectionrecordid });
                        this.dispatchEvent(firecustomevent);
                    }
                })
                .catch(error => {
                    console.log('Error while deleting the Template' + JSON.stringify(error));
                })
        }
    }

    /**
    * Method to reset values based on change in template section. 
    */
    @api resetvaluesonchildcmp() {

        this.tableOnLoad = true;
        this.tableDisplayed = false;
        this.showtablecontent = false;
        this.newPage = false;

        this.isLoaded = true;
        this.documenttemplaterecordid = '';
        this.Recorddetailsnew = {
            Name: '',
            DxCPQ__Section_Content__c: '',
            DxCPQ__DisplaySectionName__c: false,
            DxCPQ__New_Page__c: false,
            DxCPQ__Document_Template__c: '',
            DxCPQ__Sequence__c: 0,
            DxCPQ__Type__c: '',
            Id: '',
        };
        this.clauseId = '';
        this.template.querySelectorAll('lightning-input-rich-text').forEach(element => {
            if (element.value != null) {
                element.value = '';
            }
        });
        this.template.querySelectorAll('lightning-checkbox-group ').forEach(element => {
            if (element.value != null) {
                element.value = '';
            }
        });

        this.selectedBDRbgcolor = '';
        this.selectedBBgcolor = '';
        this.selectedBFontColor = '';
        this.selectedHbgColor = '';
        this.selectedHFontColor = '';
        this.isSerialNumberCheck = false;
        this.isHeaderSelectedCheck = true;
        this.isColWidthChangedCheck = false;
        this.isNoBorders = false;
        this.isAllBorders = false;
        this.isOutsideBorders = false;
        this.isOutsideThickBorders = false;
        this.isOutsideThickAllBorders = false;

        this.noBordersIcon = '';
        this.allBordersIcon = '';
        this.outsideBordersIcon = '';
        this.thickOutsideBordersIcon = '';
        this.thickOutsideAllBordersIcon = '';

        let parentData = this;
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);

        this.rownumber = 2;
        this.colnumber = 2;

        this.divContentArray = [];

        this.fontsize = "12px";
        this.fontfamily = "Verdana";

        this.isLoaded = false;

    }

    /**
    * Method to fetch document template id from the parent record Id
    */

    @api assignDocTempId(recordID) {
        this.documenttemplaterecordid = recordID;
    }

    /**
    * Method to load section data from the section content of the database  
    */

    @api loadsectionsectionvaluesforedit(recordID) {
        this.isLoaded = true;
        this.tableOnLoad = false;
        this.tableDisplayed = true;
        this.showtablecontent = true;
        this.newPage = false;

        this.noBordersIcon = '';
        this.allBordersIcon = '';
        this.outsideBordersIcon = '';
        this.thickOutsideBordersIcon = '';
        this.thickOutsideAllBordersIcon = '';
        this.divContentArray = [];

        this.Recorddetailsnew.Id = recordID;

        let parsedContent;

        gettemplatesectiondata({ editrecordid: recordID })
            .then(result => {
                if (result != null) {
                    this.Recorddetailsnew = { ...this.Recorddetailsnew, ...result };
                    let parsedJson = JSON.parse(this.Recorddetailsnew.DxCPQ__Section_Details__c);

                    parsedContent = parsedJson.sectionInfo;
                    this.divContentArray = parsedContent;
                    this.rownumber = parsedJson.rownumber;
                    this.colnumber = parsedJson.colnumber;
                    this.selectedBBgcolor = parsedJson.bodybackground;
                    this.selectedBDRbgcolor = parsedJson.bordercolor;
                    this.selectedBFontColor = parsedJson.bodyFont;
                    this.selectedHFontColor = parsedJson.headerFont;
                    this.selectedHbgColor = parsedJson.headbackground;
                    this.fontfamily = parsedJson.fontfamily;
                    this.fontsize = parsedJson.fontsize;
                    this.isSerialNumberCheck = parsedJson.serialNumberColumn;
                    this.isHeaderSelectedCheck = parsedJson.headersIncluded;
                    this.isColWidthChangedCheck = parsedJson.colWidthChanged;
                    this.selectedBorderStyle = parsedJson.borderstyle;
                    this.tablehasdata= true;

                    this.newPage = parsedJson.newPage;
                    setTimeout(() => {
                        this.template.querySelector('[data-id="newPageTable"]').checked = parsedJson.newPage;
                    });

                    this.handletablecreate();
                }
            })
            .then(() => {
                switch (this.selectedBorderStyle) {
                    case 'NoBorders':
                        return this.handleNoBorders();
                    case 'AllBorders':
                        return this.handleAllBorders();
                    case 'OutsideBorders':
                        return this.handleOutsideBorders();
                    case 'ThickOutsideBorders':
                        return this.handleThickOutsideBorders();
                    case 'ThickOutsideAllBorders':
                        return this.handleThickOutsideAllBorders();
                    default:
                        // console.log('Border Not Selected');
                        return Promise.resolve();
                }
            })
            .then(() => {

                //console.log('parsed content ' + JSON.stringify(parsedContent));

                this.template.querySelectorAll('lightning-input-rich-text').forEach(element => {
                    if (parsedContent != null && parsedContent != undefined) {
                        parsedContent.forEach(item => {
                            if (item['data-id'].startsWith(element.dataset.id) || item['data-id'].startsWith(element.dataset.head)) {
                                if (item['Content'] != null && item['Content'] != undefined) {
                                    element.value = item['Content'];
                                }
                                if (item['backgroundColor']) {
                                    let parentElement = element.closest('td') || element.closest('th');
                                    if (parentElement) {
                                        parentElement.style.backgroundColor = item['backgroundColor'];
                                    }
                                }
                            }
                        });
                    }
                });

                this.template.querySelectorAll('div[data-id]').forEach(divElement => {
                    if (parsedContent != null && parsedContent != undefined) {
                        parsedContent.forEach(item => {
                            if (item['data-id'] === divElement.dataset.id) {
                                if (item['Content'] != null && item['Content'] != undefined) {
                                    divElement.innerHTML = item['Content'];
                                }
                                if (item['backgroundColor']) {
                                    let parentElement = divElement.closest('td') || divElement.closest('th');
                                    if (parentElement) {
                                        parentElement.style.backgroundColor = item['backgroundColor'];
                                    }
                                }
                            }
                        });
                    }
                });

                this.template.querySelectorAll('lightning-checkbox-group').forEach(element => {
                    if (result.DxCPQ__New_Page__c != null) {
                        element.showBool = result.DxCPQ__New_Page__c;
                    }
                    if (result.DxCPQ__DisplaySectionName__c != null) {
                        element.showBool = result.DxCPQ__DisplaySectionName__c;
                    }
                });
            })
            .catch(error => {
                console.error('error caught ', JSON.stringify(error));
            })
            .finally(() => {
                this.isLoaded = false;
            });
    }

    /**
    * Method to handle change in font color of Table Header Cells  
    */

    handleHFontColorChange(event) {
        this.selectedHFontColor = event.detail.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in background color of Table Header Cells  
    */

    handleHbgColorChange(event) {
        this.selectedHbgColor = event.detail.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in font color of Table Body Cells  
    */

    handleBFontColorChange(event) {
        this.selectedBFontColor = event.detail.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in background color of Table Body Cells  
    */

    handleBBgColorchange(event) {
        this.selectedBBgcolor = event.detail.value;
        this.unsavedChanges();
    }

    /**
    * Method to handle change in border color of the Table.  
    */

    handleBDRbgColorchange(event) {
        this.selectedBDRbgcolor = event.detail.value;
        this.handleBorderStyling();
        this.unsavedChanges();
    }

    /**
    * Method to apply No Borders to Table Cells  
    */

    handleNoBorders() {
        this.isNoBorders = true;
        this.isAllBorders = false;
        this.isOutsideBorders = false;
        this.isOutsideThickBorders = false;
        this.isOutsideThickAllBorders = false;
        this.handleBorderStyling();
    }

    /**
    * Method to apply All Borders to Table Cells  
    */

    handleAllBorders() {
        this.isNoBorders = false;
        this.isAllBorders = true;
        this.isOutsideBorders = false;
        this.isOutsideThickBorders = false;
        this.isOutsideThickAllBorders = false;
        this.handleBorderStyling();
    }

    /**
    * Method to apply Outside Borders to Table Cells  
    */

    handleOutsideBorders() {
        this.isNoBorders = false;
        this.isAllBorders = false;
        this.isOutsideBorders = true;
        this.isOutsideThickBorders = false;
        this.isOutsideThickAllBorders = false;
        this.handleBorderStyling();
    }

    /**
    * Method to apply Thick Outside Borders to Table Cells 
    */

    handleThickOutsideBorders() {
        this.isNoBorders = false;
        this.isAllBorders = false;
        this.isOutsideBorders = false;
        this.isOutsideThickBorders = true;
        this.isOutsideThickAllBorders = false;
        this.handleBorderStyling();
    }

    /**
    * Method to apply Thick Outside All Borders to Table Cells 
    */

    handleThickOutsideAllBorders() {
        this.isNoBorders = false;
        this.isAllBorders = false;
        this.isOutsideBorders = false;
        this.isOutsideThickBorders = false;
        this.isOutsideThickAllBorders = true;
        this.handleBorderStyling();
    }

    /**
    * Method to apply Border Styling based on selected Border. 
    */

    handleBorderStyling() {
        if (!!this.isNoBorders) {

            let tableCells = this.template.querySelectorAll('.mytable, .mytable td, .mytable th');
            tableCells.forEach(cell => {
                cell.style.border = "none";
            });

            this.noBordersIcon = 'utility:check';
            this.allBordersIcon = '';
            this.outsideBordersIcon = '';
            this.thickOutsideBordersIcon = '';
            this.thickOutsideAllBordersIcon = '';

        } else if (!!this.isAllBorders) {
            let tableCells1 = this.template.querySelectorAll('.mytable');
            tableCells1.forEach(cell => {
                cell.style.border = "none";
            });

            let tableCells = this.template.querySelectorAll('.mytable td, .mytable th');
            tableCells.forEach(cell => {
                cell.style.border = `1px solid ${this.selectedBDRbgcolor}`;
            });

            this.noBordersIcon = '';
            this.allBordersIcon = 'utility:check';
            this.outsideBordersIcon = '';
            this.thickOutsideBordersIcon = '';
            this.thickOutsideAllBordersIcon = '';

        } else if (!!this.isOutsideBorders) {
            let tableCells1 = this.template.querySelectorAll('.mytable td, .mytable th');
            tableCells1.forEach(cell => {
                cell.style.border = "none";
            });

            let tableCells = this.template.querySelectorAll('.mytable');
            tableCells.forEach(cell => {
                cell.style.border = `1px solid ${this.selectedBDRbgcolor}`;
            });

            this.noBordersIcon = '';
            this.allBordersIcon = '';
            this.outsideBordersIcon = 'utility:check';
            this.thickOutsideBordersIcon = '';
            this.thickOutsideAllBordersIcon = '';

        }
        else if (!!this.isOutsideThickBorders) {
            let tableCells2 = this.template.querySelectorAll('.mytable td, .mytable th');
            tableCells2.forEach(cell => {
                cell.style.border = "none";
            });

            let tableCells3 = this.template.querySelectorAll('.mytable');
            tableCells3.forEach(cell => {
                cell.style.border = `2.5px solid ${this.selectedBDRbgcolor}`;
            });

            this.noBordersIcon = '';
            this.allBordersIcon = '';
            this.outsideBordersIcon = '';
            this.thickOutsideBordersIcon = 'utility:check';
            this.thickOutsideAllBordersIcon = '';
        }

        else if (!!this.isOutsideThickAllBorders) {
            let tableCells1 = this.template.querySelectorAll('.mytable td, .mytable th');
            tableCells1.forEach(cell => {
                cell.style.border = "none";
            });

            let tableCells = this.template.querySelectorAll('.mytable td, .mytable th');
            tableCells.forEach(cell => {
                cell.style.border = `1px solid ${this.selectedBDRbgcolor}`;
            });

            let tableCells2 = this.template.querySelectorAll('.mytable');
            tableCells2.forEach(cell => {
                cell.style.border = `2.5px solid ${this.selectedBDRbgcolor}`;
            });

            this.noBordersIcon = '';
            this.allBordersIcon = '';
            this.outsideBordersIcon = '';
            this.thickOutsideBordersIcon = '';
            this.thickOutsideAllBordersIcon = 'utility:check';
        }
    }

    /**
    * Method to include Serial Numbers Column to the table
    */

    handleSnoClick(event) {
        this.isSerialNumberCheck = event.target.checked;
        let parentData = this;
        this.unsavedChanges();
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);
    }

    /**
    * Method to include/exclude Headers to the table
    */

    handleHeaderInclusionClick(event) {
        this.isHeaderSelectedCheck = event.target.checked;
        let parentData = this;
        this.unsavedChanges();
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);
    }

    /**
    * Method to change column width for resizing 
    */

    handleColWidthChangeClick(event) {
        this.isColWidthChangedCheck = event.target.checked;
        let parentData = this;
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);
        this.computeColumnWidths();
    }

    /**
    * Method to map the header th values with the new offset width values  
    */

    computeColumnWidths() {
        let thElements = this.template.querySelectorAll('th');
        this.columnWidths = Array.from(thElements).map(th => th.offsetWidth);

        this.tableHeadersData = this.tableheaders.map((header, index) => ({
            header,
            width: this.columnWidths[index] || 0,
        }));
    }

    /**
    * Method to clear Table Cells and build again
    */

    handleclearTable() {
        this.template.querySelector('c-modal').show();
        this.isClearTable = true;
        this.showmergefield = false;
        this.showImageModal = false;
        this.isHeaderMergeField = false;
        this.isHeaderCellBgColor = false;
        this.isTableColumnSizeChange = false;
    }

    /**
    * Method to cancel clear table. 
    */

    cancelTableClear() {
        this.template.querySelector('c-modal').hide();
        this.isClearTable = false;
    }
    /**
    * Method to cancel col width change model. 
    */

    cancelTableColSizeChanges() {
        this.template.querySelector('c-modal').hide();
        this.isTableColumnSizeChange = false;
    }

    /**
    * Method to reset table styles for table cells.
    */

    submitTableClear() {
        this.template.querySelector('c-modal').hide();
        this.isClearTable = false;
        this.selectedBDRbgcolor = '';
        this.selectedBBgcolor = '';
        this.selectedBFontColor = '';
        this.selectedHbgColor = '';
        this.selectedHFontColor = '';
        this.tableDisplayed = false;
        this.tableOnLoad = true;
        this.showtablecontent = false;
        this.isSerialNumberCheck = false;
        this.isHeaderSelectedCheck = true;
        this.isColWidthChangedCheck = false;
        this.isNoBorders = false;
        this.isAllBorders = false;
        this.isOutsideBorders = false;
        this.isOutsideThickBorders = false;
        this.isOutsideThickAllBorders = false;
    }

    /**
    * Method to handle merging of table body cells 
    */

    handleMergeRightCell(event) {
        if (this.mergeHeaderCell === true) {
            //let selectedTh = event.target.closest('th');
            let selectedTh = this.selectedThValue;
            let columnIndex = Array.from(selectedTh.parentElement.children).indexOf(selectedTh);
            let lastColumnIndex = this.tableheaders.length - 1;

            if (columnIndex < lastColumnIndex) {
                let currentTh = selectedTh;
                let nextTh = currentTh.nextElementSibling;

                if (nextTh && Array.from(nextTh.parentElement.children).indexOf(nextTh) <= lastColumnIndex) {
                    let currentColspan = parseInt(currentTh.getAttribute('colspan')) || 1;
                    let nextColspan = parseInt(nextTh.getAttribute('colspan')) || 1;
                    let newColspan = currentColspan + nextColspan;

                    if (columnIndex + newColspan - 1 <= lastColumnIndex) {
                        currentTh.setAttribute('colspan', newColspan);
                        let countToRemove = Math.min(nextColspan, lastColumnIndex - columnIndex);
                        let nextSibling = nextTh;
                        while (countToRemove > 0 && nextSibling) {
                            let nextNextSibling = nextSibling.nextElementSibling;
                            // nextSibling = nextNextSibling;
                            nextSibling.remove();
                            countToRemove--;
                        }
                    } else {
                        let errorDisplay = new ShowToastEvent({
                            title: 'Error',
                            message: 'Cannot merge cells beyond column boundary',
                            variant: 'error',
                        });
                        this.dispatchEvent(errorDisplay);

                        console.error("Cannot merge cells beyond column boundary");
                    }
                } else {
                    let errorDisplay1 = new ShowToastEvent({
                        title: 'Error',
                        message: 'Cannot merge cells beyond column boundary',
                        variant: 'error',
                    });
                    this.dispatchEvent(errorDisplay1);

                    console.error("Cannot merge cell in the last column");
                }
            } else {
                let errorDisplay2 = new ShowToastEvent({
                    title: 'Error',
                    message: 'Cannot merge cells beyond column boundary',
                    variant: 'error',
                });
                this.dispatchEvent(errorDisplay2);
                console.error("Cannot merge cell in the last column");
            }
        }
        else if (this.mergeBodyCell === true) {
            let selectedDiv = this.template.querySelector(`[data-id="${this.selectedTableRow}"]`);
            let rowIndex = parseInt(this.selectedTableRow.match(/row(\d+)/)[1]) - 1;
            let selectedTd = selectedDiv.closest('td');

            if (selectedTd) {
                let columnIndex = Array.from(selectedTd.parentElement.children).indexOf(selectedTd);
                let lastColumnIndex = this.tablecolumns.length - 1;

                if (columnIndex < lastColumnIndex) {
                    let currentTd = selectedTd;
                    let nextTd = currentTd.nextElementSibling;

                    if (nextTd && Array.from(nextTd.parentElement.children).indexOf(nextTd) <= lastColumnIndex) {
                        let currentColspan = parseInt(currentTd.getAttribute('colspan')) || 1;
                        let nextColspan = parseInt(nextTd.getAttribute('colspan')) || 1;

                        let newColspan = currentColspan + nextColspan;

                        if (columnIndex + newColspan - 1 <= lastColumnIndex) {
                            currentTd.setAttribute('colspan', newColspan);
                            let countToRemove = Math.min(nextColspan, lastColumnIndex - columnIndex);
                            let nextSibling = nextTd;
                            while (countToRemove > 0 && nextSibling) {
                                let nextNextSibling = nextSibling.nextElementSibling;
                                let removedCell = this.tablerows[rowIndex].columns[columnIndex + currentColspan];
                                if (removedCell) {
                                    //removedCell.isMerged = false;
                                    removedCell.isRemoved = true;
                                }
                                nextSibling.remove();
                                countToRemove--;
                            }
                            for (let i = columnIndex; i <= columnIndex + currentColspan - 1; i++) {
                                this.tablerows[rowIndex].columns[i].isMerged = true;
                            }
                        } else {
                            let errorDisplay = new ShowToastEvent({
                                title: 'Error',
                                message: 'Cannot merge cells beyond column boundary',
                                variant: 'error',
                            });
                            this.dispatchEvent(errorDisplay);

                            console.error("Cannot merge cells beyond column boundary");
                        }
                    } else {
                        let errorDisplay1 = new ShowToastEvent({
                            title: 'Error',
                            message: 'Cannot merge cells beyond column boundary',
                            variant: 'error',
                        });
                        this.dispatchEvent(errorDisplay1);

                        console.error("Cannot merge cell in the last column");
                    }
                } else {
                    let errorDisplay2 = new ShowToastEvent({
                        title: 'Error',
                        message: 'Cannot merge cells beyond column boundary',
                        variant: 'error',
                    });
                    this.dispatchEvent(errorDisplay2);
                    console.error("Cannot merge cell in the last column");
                }
            } else {
                let errorDisplay3 = new ShowToastEvent({
                    title: 'Error',
                    message: 'Div not found within a td',
                    variant: 'error',
                });
                this.dispatchEvent(errorDisplay3);
                console.error("Div not found within a td");
            }

            // console.log('table rows after merge right cell ' + JSON.stringify(this.tablerows));
        }
        this.template.querySelector('c-modal').hide();
        this.confirmMergeCell = false;
        this.mergeBodyCell = false;
        this.mergeHeaderCell = false;
    }

    handleMergeCellClick() {
        this.template.querySelector('c-modal').show();
        this.confirmMergeCell = true;
        this.mergeBodyCell = true;
        this.mergeHeaderCell = false;

        this.showmergefield = false;
        this.showImageModal = false;
        this.isHeaderMergeField = false;
        this.isHeaderCellBgColor = false;
        this.isClearTable = false;
        this.isTableColumnSizeChange = false;
    }

    handleMergeHeaderCellClick(event) {
        this.template.querySelector('c-modal').show();
        this.confirmMergeCell = true;
        this.mergeBodyCell = false;
        this.mergeHeaderCell = true;
        this.selectedThValue = event.target.closest('th');
        this.showmergefield = false;
        this.showImageModal = false;
        this.isHeaderMergeField = false;
        this.isHeaderCellBgColor = false;
        this.isClearTable = false;
        this.isTableColumnSizeChange = false;
    }

    cancelMergeCell() {
        this.template.querySelector('c-modal').hide();
        this.isClearTable = false;
        this.confirmMergeCell = false;
        this.mergeBodyCell = false;
        this.mergeHeaderCell = false;
    }

    // /**
    // * Method to handle merging of table header cells
    // */

    // handleHeaderMergeRightCell(event) {

    // }

    /**
    * Method to handle column swapping on drag start
    */

    handleDragStart(event) {
        this.draggedColumnIndex = Array.from(event.target.parentNode.children).indexOf(event.target);
        event.dataTransfer.setData('text/plain', '');
    }

    /**
    * Method to handle column swapping on drag over
    */

    handleDragOver(event) {
        event.preventDefault();
        let draggedColumn = event.target.closest('th');
        draggedColumn.style.borderColor = 'silver';
        draggedColumn.style.borderRadius = '5px';
        draggedColumn.style.boxShadow = '0 0 5px 5px silver';

        let columnIndex = Array.from(draggedColumn.parentNode.children).indexOf(draggedColumn);
        let allRows = this.template.querySelectorAll('tbody tr');
        allRows.forEach(row => {
            let cell = row.querySelectorAll('td')[columnIndex];
            cell.style.borderLeft = '2px groove silver';
            cell.style.borderRight = '2px groove silver';
            cell.style.boxShadow = '0 5px silver';
        });
    }

    /**
    * Method to handle column swapping on drag leave
    */

    handleDragLeave(event) {
        event.preventDefault();
        let draggedColumn = event.target.closest('th');
        draggedColumn.style.borderLeft = '';
        draggedColumn.style.borderRight = '';
        draggedColumn.style.boxShadow = '';

        let columnIndex = Array.from(draggedColumn.parentNode.children).indexOf(draggedColumn);
        let allRows = this.template.querySelectorAll('tbody tr');
        allRows.forEach(row => {
            let cell = row.querySelectorAll('td')[columnIndex];
            cell.style.borderLeft = '';
            cell.style.borderRight = '';
            cell.style.boxShadow = '';
        });
    }

    /**
    * Method to handle column swapping on drag drop
    */

    handleDrop(event) {
        event.preventDefault();
        let oldIndex = this.draggedColumnIndex;
        let newTh = event.target.closest('th');
        let newIndex = Array.from(newTh.parentNode.children).indexOf(newTh);
        this.handleColumnSwap(oldIndex, newIndex);

        let allColumns = this.template.querySelectorAll('th,td');
        allColumns.forEach(column => {
            column.style.borderColor = '';
            column.style.borderRadius = '';
            column.style.borderLeft = '';
            column.style.borderRight = '';
            column.style.boxShadow = '';
        });

        let parentData = this;
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);
    }


    /**
    * Method to handle column swapping by swapping old Index with new Index
    */

    handleColumnSwap(oldIndex, newIndex) {
        let headersCopy = [...this.tableheaders];
        let rowsCopy = [...this.tablerows];
        let [removed] = headersCopy.splice(oldIndex, 1);
        headersCopy.splice(newIndex, 0, removed);

        for (let i = 0; i < rowsCopy.length; i++) {
            let row = rowsCopy[i];
            let [removedCol] = row.columns.splice(oldIndex, 1);
            row.columns.splice(newIndex, 0, removedCol);
        }

        this.tableheaders = headersCopy;
        this.tablerows = rowsCopy;
    }

    /**
    * Method to handle column resizing on mouse down
    */

    handleMouseDown(event) {
        let resizeHandle = event.target;
        let index = parseInt(resizeHandle.dataset.index, 10);
        let th = this.template.querySelector(`th:nth-child(${index + 1})`);
        let startingWidth = th.offsetWidth;
        let startX = event.clientX;

        let handleMouseMove = (moveEvent) => {
            let deltaX = moveEvent.clientX - startX;
            let newWidth = startingWidth + deltaX;
            th.style.width = `${newWidth}px`;
        };

        let handleMouseUp = () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
            this.resizingColumn = null;
        };

        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
        this.resizingColumn = th;
    }

    /**
    * Method to handle column resizing on mouse enter
    */

    handleResizeHandleMouseEnter(event) {
        let resizeHandle = event.target;
        let index = parseInt(resizeHandle.dataset.index, 10);
        let th = this.template.querySelector(`th:nth-child(${index + 1})`);
        this.resizingColumn = th;
    }

    /**
    * Method to handle column resizing on mouse leave 
    */

    handleResizeHandleMouseLeave() {
        this.resizingColumn = null;
    }

    handleNewPage(event) {
        this.newPage = event.detail.checked;
        this.unsavedChanges();
    }


    handleCellbgColor(event) {
        this.cellBgColor = '';
        this.template.querySelector('c-modal').show();
        this.showCellBgColor = true;
        this.isClearTable = false;
        this.showmergefield = false;
        this.showImageModal = false;
        this.isHeaderMergeField = false;
        this.isHeaderCellBgColor = false;
        this.isTableColumnSizeChange = false;
    }

    handleHeaderCellbgColor(event) {
        this.cellBgColor = '';
        this.template.querySelector('c-modal').show();
        this.showCellBgColor = true;
        this.isClearTable = false;
        this.showmergefield = false;
        this.showImageModal = false;
        this.isHeaderMergeField = false;
        this.isHeaderCellBgColor = true;
        this.isTableColumnSizeChange = false;
    }

    handleCellBgColorChange(event) {
        try {
            this.cellBgColor = (event && event.detail && event.detail.value !== undefined) ? event.detail.value : this.cellBgColor;

        } catch (error) {
            console.error('Error in handleCellBgColorChange', error);
        }
    }


    handleInsertCellBgColor() {
        try {
            if (this.isHeaderCellBgColor === false) {
                console.log('sel table row ' + this.selectedTableRow);
                let elm = this.template.querySelector(`[data-id="${this.selectedTableRow}"]`);
                elm.style.backgroundColor = this.cellBgColor;
                let innerdiv = this.selectedTableRow + 'div';
                let elm1 = this.template.querySelector(`[data-id="${innerdiv}"]`);
                let selectedTd = elm1.closest('td');
                selectedTd.style.backgroundColor = this.cellBgColor;



                let colIndex = this.tablecolumns.findIndex(col => col.id === this.selectedTableRow);
                if (colIndex !== -1) {
                    this.tablecolumns[colIndex].backgroundColor = true;
                }

                console.log('tabl cols after bg clr true ' + JSON.stringify(this.tablecolumns));
            }
            else {

                let elm2 = this.template.querySelector(`[data-head="${this.selectedHeader}"]`);
                elm2.style.backgroundColor = this.cellBgColor;
                let selectedHeaderTd = elm2.closest('th');
                selectedHeaderTd.style.backgroundColor = this.cellBgColor;
            }
            this.template.querySelector('c-modal').hide();
        }
        catch (error) {
            console.error('Error caught ' + error);
        }
    }

    handleColResize(event) {
        this.isColSwapCheck = false;
        let parentData = this;
        this.unsavedChanges();
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);
        this.isColResizeCheck = event.target.checked;
    }

    handleColSwap(event) {
        this.isColResizeCheck = false;
        let parentData = this;
        this.unsavedChanges();
        setTimeout(function () { parentData.handleBorderStyling(); }, 100);
        this.isColSwapCheck = event.target.checked;
    }

    unsavedChanges(){
        const saveEvent = new CustomEvent('datasaved', {detail: false });
        this.dispatchEvent(saveEvent);
    }
}