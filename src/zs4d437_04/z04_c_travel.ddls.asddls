@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Z04_R_TRAVEL'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z04_C_Travel
  provider contract transactional_query
  as projection on Z04_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    @Search.defaultSearchElement: true
    Description,
    @Search.defaultSearchElement: true
    @Consumption.valueHelpDefinition:
        [{ entity:
            { name: '/DMO/I_Customer_StdVH',
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
