@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view ex2'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z09_C_Travel
  provider contract transactional_query
  as projection on Z09_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity: { name: '/DMO/I_Customer_StdVH',
        element: 'CustomerID' } } ] 
      CustomerId,
      BeginDate,
      EndDate,
      @EndUserText.label: 'Duration (days)'
      Duration,
      Status,
      @UI.hidden: true
      ChangedAt,
      @UI.hidden: true
      ChangedBy,
      @UI.hidden: true
      LocChangeAt
}
