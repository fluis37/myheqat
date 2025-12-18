@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@EndUserText.label: 'Projection View Travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z03_C_Travel
  provider contract transactional_query
  as projection on Z03_R_Travel
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      Description,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Customer_StdVH',
              element: 'CustomerID'
          },
          label: 'Customer help'
      }]
      CustomerId,
      BeginDate,
      EndDate,
      @EndUserText.label: 'Duration (days)'
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangeAt
}
