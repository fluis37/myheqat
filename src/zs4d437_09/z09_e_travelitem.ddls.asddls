@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension Include for Travel Items'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility: {
 extensible: true,
 allowNewDatasources: false,
 dataSources: ['Item'],
 elementSuffix: 'Z09'
 }
define view entity Z09_E_TravelItem
as select from z09_tritem as Item
{
    key item_uuid as ItemUuid
}
