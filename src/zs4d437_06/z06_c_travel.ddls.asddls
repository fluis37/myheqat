@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Z06_C_Travel'
@Metadata.ignorePropagatedAnnotations: true

@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z06_C_Travel
  provider contract transactional_query
  as projection on Z06_R_Travel
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      Description,
      @Search.defaultSearchElement: true
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
      Status,
      ChangedAt,
      ChangedBy
}
