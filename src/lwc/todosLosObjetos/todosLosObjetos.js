import { LightningElement, api, wire } from 'lwc';
import getCurrencyFields from '@salesforce/apex/CurrencyConversionController.getCurrencyFields';
import convertCurrencyFields from '@salesforce/apex/CurrencyConversionController.convertCurrencyFields';
import getTargetCurrencies from '@salesforce/apex/CurrencyConversionController.getTargetCurrencies';

export default class TodosLosObjetos extends LightningElement {
    @api recordId;
    @api objectApiName;
    currencyFields;
    targetCurrencies;
    selectedCurrency;
    currencyData = [];
    errorMessage;

    connectedCallback() {
        this.getCurrencyFields();
        this.getTargetCurrencies();
    }

    getCurrencyFields() {
        getCurrencyFields({ objectName: this.objectApiName })
            .then(result => {
                this.currencyFields = result;
                this.errorMessage = undefined;
            })
            .catch(error => {
                this.errorMessage = 'Error al obtener campos de tipo currency: ' + error.body.message;
            });
    }

    getTargetCurrencies() {
        getTargetCurrencies()
            .then(result => {
                this.targetCurrencies = result.map(currency => ({ label: currency, value: currency }));
                this.errorMessage = undefined;
            })
            .catch(error => {
                this.errorMessage = 'Error al obtener monedas de conversión: ' + error.body.message;
            });
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.target.value;
    }

    get isCurrencyAvailable() {
        return this.currencyFields && this.currencyFields.length > 0;
    }

    convertCurrency() {
        convertCurrencyFields({
            objectName: this.objectApiName,
            currencyFields: this.currencyFields,
            targetCurrency: this.selectedCurrency,
            recordId: this.recordId
        })
            .then(result => {
                this.currencyData = this.currencyFields.map(field => ({
                    field: field,
                    originalValue: result.originalValues[field],
                    convertedValue: result.convertedValues[field]
                }));
                this.errorMessage = undefined;
            })
            .catch(error => {
                this.errorMessage = 'Error al convertir campos de tipo currency: ' + error.body.message;
            });
    }
}
