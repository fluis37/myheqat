@EndUserText.label: 'Z4D437 02 Travel (Projection)'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

@Search.searchable: true

define root view entity Z02_C_Travel
  provider contract transactional_query
  as projection on Z02_R_TRAVEL
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
            }
        }]
        CustomerId,
        BeginDate,
        EndDate,
        Status,
        ChangedAt,
        ChangedBy
  }
