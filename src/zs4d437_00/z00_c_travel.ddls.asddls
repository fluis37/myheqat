@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection Travel'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity Z00_C_Travel
  provider contract transactional_query
  as projection on Z00_R_Travel
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      Description,
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: '/DMO/I_Customer_StdVH',
              element: 'CustomerID'
          },
          distinctValues: true,
          useForValidation: true,
          label: 'Customer'
      }]
      
      CustomerId,

      BeginDate,
      EndDate,
            @EndUserText.label: 'Durations (days)'
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      @UI.hidden: true
      LocChangedAt
}
