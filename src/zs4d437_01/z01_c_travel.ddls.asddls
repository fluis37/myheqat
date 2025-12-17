@EndUserText.label: 'Flight Travel (Projection)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity Z01_C_Travel 
    provider contract transactional_query
    as projection on Z01_R_TRAVEL
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
    Status,
    ChangedAt,
    ChangedBy
}
