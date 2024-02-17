import { LightningElement, api, track } from 'lwc';

export default class DxSearchCategory extends LightningElement {

    @api options;
    @api label;
    @api minChar = 2;
    @track values = [];
    @track optionData = [];
    @track searchString;
    @track message;
    @track showDropdown = false;
    @api searchtext;
    @api hasMultiSelect = false;
    @api disabled;
    defaultOption;
    @track selectedOption;
    mapOfValueLabel;

    connectedCallback() {
        this.mapOfValueLabel = new Map();
        this.showDropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;

        this.hasMultiSelect = this.hasMultiSelect === "false"?false:this.hasMultiSelect === "true"?true:false;
        if (optionData != null && optionData.length > 0) {
            var count = 1;
            for (var i = 0; i < optionData.length; i++) {
                if(optionData[i].selected){
                   this.selectedOption =  optionData[i];
                }
                if(optionData[i].isDefault){
                    this.defaultOption = optionData[i];
                }
                this.mapOfValueLabel.set(optionData[i].value, optionData[i].label);
            }
            this.searchString = count + ' Option(s) Selected';
        }
        this.optionData = optionData;
    }

    filterOptions(event) {
        this.searchString = event.target.value;
        if (this.searchString && this.searchString.length > 0) {
            this.message = '';
            if (this.searchString.length >= this.minChar) {
                var flag = true;
                for (var i = 0; i < this.optionData.length; i++) {
                    if (this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if (flag) {
                    this.message = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
    }

    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        if (selectedVal && this.hasMultiSelect === true) {
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            if (selectedVal === this.mapOfValueLabel.get('All')) {
                for (var i = 0; i < this.optionData.length; i++) {
                    if (options[i].value == this.mapOfValueLabel.get('All')) {
                        options[i].selected = true;
                        count++;
                    } else {
                        options[i].selected = false;
                    }
                }
            } else {
                for (var i = 0; i < options.length; i++) {
                    if (options[i].value === this.mapOfValueLabel.get('All')) {
                        options[i].selected = false;
                    }
                    if (options[i].value === selectedVal) {
                        options[i].selected = options[i].selected ? false : true;
                    }
                    if (options[i].selected) {
                        count++;
                    }
                }
            }
            this.optionData = options;
            this.onselectfireEvent();
            this.searchString = count + ' Option(s) Selected';
            event.preventDefault();
        }else{
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                if (options[i].value === selectedVal) {
                    options[i].selected = options[i].selected ? false : true;
                    if(options[i].selected === true){
                        this.selectedOption = options[i];
                    }else{
                        this.selectedOption = null;
                    }
                }else{
                    options[i].selected = false;
                }
            }
            this.optionData = options;
            this.onselectfireEvent();
        }
    }

    showOptions() {
        if (this.optionData) {
            this.message = '';
            this.searchString = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    removePill(event) {
        var value = event.currentTarget.name;
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
            if (options[i].value === value) {
                options[i].selected = false;
            }
            if (options[i].selected) {
                count++;
            }
        }
        this.optionData = options;
        this.onselectfireEvent();
        this.searchString = count + ' Option(s) Selected';
    }

    blurEvent() {
        var count = 0;
        for (var i = 0; i < this.optionData.length; i++) {
            if (this.optionData[i].selected) {
                count++;
            }
        }
        this.searchString = count + ' Option(s) Selected';
        this.showDropdown = false;
    }

    onselectfireEvent() {
        let eventData = {};
        this.values = [];
        for (var i = 0; i < this.optionData.length; i++) {
            if (this.optionData[i].selected)
                if(this.optionData[i].value){
                    this.values.push(this.optionData[i].value);
                }
        }
        eventData["values"] = this.values;
        eventData["label"] = this.label; 
        const selectedEvent = new CustomEvent("selectedcategoryvalues", {
            detail: eventData
        });
        this.dispatchEvent(selectedEvent);
    }
    
    clearSelectedItem(){
        for (var i = 0; i < this.optionData.length; i++) {
            this.optionData[i].selected = false;
        }
        this.onselectfireEvent();
        this.selectedOption=null;
    }

    @api 
    setupOptions(options){ 
        let isSelectedOption = false;
        this.options = JSON.parse(JSON.stringify(options));
        let index = 0;
        this.options.forEach(obj=>{
            //this.selectedOption = null;
            this.optionData[index].selected = obj.selected;
            if(obj.selected){
                this.selectedOption = obj;
                isSelectedOption = true;
            }
            index++;
        });
        if(!isSelectedOption){
            this.selectedOption = null;
        }
    }
}