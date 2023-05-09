/**
 * Created by javier.villalobos on 09/05/2023.
 */

public with sharing class CurrencyConversionController {
    @AuraEnabled
    public static List<String> getCurrencyFields(String objectName) {
        List<String> currencyFields = new List<String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            if (field.getDescribe().getType() == Schema.DisplayType.CURRENCY) {
                currencyFields.add(fieldName);
            }
        }
        return currencyFields;
    }

    @AuraEnabled
    public static Map<String, Map<String, Decimal>> convertCurrencyFields(String objectName, List<String> currencyFields, String targetCurrency, String recordId) {
        Decimal conversionRate = getConversionRate(targetCurrency);
        Map<String, Decimal> originalValues = new Map<String, Decimal>();
        Map<String, Decimal> convertedValues = new Map<String, Decimal>();

        for (String fieldName : currencyFields) {
            Decimal originalValue = getFieldValue(objectName, fieldName, recordId);
            Decimal convertedValue = originalValue * conversionRate;
            originalValues.put(fieldName, originalValue);
            convertedValues.put(fieldName, convertedValue);
        }
        return new Map<String, Map<String, Decimal>>{
                'originalValues' => originalValues,
                'convertedValues' => convertedValues
        };
    }


    private static Decimal getConversionRate(String targetCurrency) {
        TasaConversionMoneda__mdt conversionRateMetadata = [SELECT TasaConversion__c FROM TasaConversionMoneda__mdt WHERE MonedaDestino__c = :targetCurrency LIMIT 1];
        return conversionRateMetadata.TasaConversion__c;
    }

    private static Decimal getFieldValue(String objectName, String fieldName, String recordId) {
        String query = 'SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE Id = :recordId';
        SObject record = Database.query(query);
        return (Decimal) record.get(fieldName);
    }

    @AuraEnabled
    public static List<String> getTargetCurrencies() {
        List<String> targetCurrencies = new List<String>();
        List<TasaConversionMoneda__mdt> metadataRecords = [SELECT MonedaDestino__c FROM TasaConversionMoneda__mdt];

        for (TasaConversionMoneda__mdt record : metadataRecords) {
            targetCurrencies.add(record.MonedaDestino__c);
        }
        return targetCurrencies;
    }



}
