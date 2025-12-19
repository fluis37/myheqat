@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension Include for Travel Items'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility: {
 extensible: true,
 allowNewDatasources: false,
 dataSources: ['Item'],
 elementSuffix: 'Z06'
}
define view entity Z06_E_TravelItem
  as select from z06_tritem as Item
{
  key item_uuid as ItemUuid
}
