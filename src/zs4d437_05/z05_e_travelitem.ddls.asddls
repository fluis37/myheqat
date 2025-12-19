@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension include for Travel Items'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility: {
 extensible: true,
allowNewDatasources: false,
dataSources: ['Item'],
elementSuffix: 'Z05' 
}

define view entity Z05_E_TravelItem
  as select from z05_tritem as Item
{
  key item_uuid as ItemUuid
}
