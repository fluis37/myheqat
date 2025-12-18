@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection of Z08_R_TRAVEL'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z08_C_TRAVEL
  provider contract transactional_query
  as projection on Z08_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true

      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Customer_StdVH',
              element: 'CustomerID'
          }
      }]
      CustomerId,
      BeginDate,
      EndDate,
      
      @EndUserText.label: 'Duration (days)'
      Duration,
      
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt,
      
      //Redirect the association to the projection view for flight travel items and classify it as composition.
      _TravelItem : redirected to composition child Z08_C_TRAVELITEM

}
