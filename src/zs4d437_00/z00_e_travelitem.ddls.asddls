@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AbapCatalog.extensibility: {
    extensible: true,
    dataSources: [ 'Item' ],
    allowNewDatasources: false,
    elementSuffix: 'Z00'
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Extesion include for Travel Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z00_E_travelItem
  as select from z00_tritem as Item
{
  key item_uuid as ItemUuid
}
