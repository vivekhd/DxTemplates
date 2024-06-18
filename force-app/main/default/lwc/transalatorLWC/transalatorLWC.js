import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createLog from '@salesforce/apex/LogHandler.createLog';
import selectedLangMethod from '@salesforce/apex/LanguageTranslatorClass.selectedLangMethod';

export default class TransalatorLWC extends LightningElement {
    uniqueIdentifierVal = 0;
    @track translatedRecords = [];
    @track selectedLanguage = ''; 
    handleLanguageChange(event) {
        this.selectedLanguage = event.detail.value; // Update the selected language when it changes
    }
     @wire (selectedLangMethod, { language: '$selectedLanguage' })
        wiredSelectedLang({data, error}){
            if(data){
                this.translatedRecords = data;
            }
            else if(error){
                    let tempError = error.toString();
                    let errorMessage = error.message || 'Unknown error message';
                    createLog({ recordId: '', className: 'TransalatorLWC LWC Component - connectedCallback()', exceptionMessage: errorMessage, logData: tempError, logType: 'Exception' });
            }
        }

    get uniqueIdentifier() {
        this.uniqueIdentifierVal = this.uniqueIdentifierVal + 1;
        return this.uniqueIdentifierVal;
    }

    @track data = [{
        'Column1': '',
        'Column2': '',
        'Column3': '',
        'uid': this.uniqueIdentifier
    }];
    @track dataCopy = this.data;

    handleRemoveRow(event) {
        const indexVal = event.target.dataset.index;
        if (this.data.length > 1) {
            this.data.splice(indexVal, 1);
            this.data = [...this.data];
        }else if(this.data.length = 1){
            this.data = this.dataCopy;
        }
    }

    handleClick() {
        console.log('data-'+JSON.stringify(this.data));
        const newRow = {
            id: this.data.length + 1,
            'Column1': '',
            'Column2': '',
            'Column3': ''
        };
        this.data = [...this.data, newRow];
    }

    validateAlphabets(inputValue) {
        const regex = /^[a-zA-Z\s]*$/;
        let isValid = true;

        if (!regex.test(inputValue)) {
            isValid = false;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter only alphabets.',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }

        return isValid;
    }


    handleCellOneInputChange(event) {
        if(this.validateAlphabets(event.target.value)){
            const indexVal = parseInt(event.target.dataset.index);
            this.data[indexVal]["Column1"] = event.target.value;
            this.data = [...this.data];
        }
        
    }

    handleCellTwoInputChange(event) {
        this.validateAlphabets(event.target.value);
        const indexVal = parseInt(event.target.dataset.index);
        this.data[indexVal]["Column2"] = event.target.value;
        this.data = [...this.data];
    }

    handleCellThreeInputChange(event) {
        this.validateAlphabets(event.target.value);
        const indexVal = parseInt(event.target.dataset.index);
        this.data[indexVal]["Column3"] = event.target.value;
        this.data = [...this.data];
    }

    handleSave(event){

    }
}