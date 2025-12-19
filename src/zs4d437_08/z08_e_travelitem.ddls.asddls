@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extension Include for Travel Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@AbapCatalog.extensibility: {
    extensible: true,
    allowNewDatasources: false,
    dataSources: ['Item'],
    elementSuffix: 'Z08'}
    
define view entity Z08_E_TravelItem
  as select from z08_tritem as Item
{
  key item_uuid as ItemUuid

}
