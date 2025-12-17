@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z07_C_Travel
  provider contract transactional_query
  as projection on Z07_R_Travel
{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      Description,
      @Search.defaultSearchElement: true 
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Customer_StdVH', 
                                                      element: 'CustomerID' } 
                                            } ]
      CustomerId,
      BeginDate,
      EndDate,
      Status,
      ChangedAt,
      ChangedBy
}
