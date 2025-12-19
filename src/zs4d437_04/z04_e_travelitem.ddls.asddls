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
    dataSources: [ 'Item' ],
    elementSuffix: 'Z04'
}
define view entity Z04_E_TRAVELITEM as select from z04_tritem as Item
{
    key item_uuid as ItemUuid
}
