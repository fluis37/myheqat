@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@EndUserText.label: 'CDS projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z05_C_Travel
  provider contract transactional_query
  as projection on Z05_R_Travel
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition:
         [ { entity:
                { name: '/DMO/I_Customer_StdVH',
                  element: 'CustomerID'
                }
             }
         ]
      CustomerId,
      BeginDate,
      EndDate,
      @EndUserText.label: 'Calculated duration'
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt, //8.0
      _TravelItem : redirected to composition child Z05_C_TRAVELITEM
}
