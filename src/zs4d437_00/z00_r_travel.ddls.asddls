@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Travel Model 00'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z00_R_Travel
  as select from z00_travel
  composition [0..*] of Z00_R_TravelItem      as _TravelItem
  association [0..1] to /DMO/I_Customer_StdVH as _Customer on $projection.CustomerId = _Customer.CustomerID
{
  key agency_id                                                    as AgencyId,
  key travel_id                                                    as TravelId,
      description                                                  as Description,
      customer_id                                                  as CustomerId,
      concat_with_space(_Customer.FirstName, _Customer.LastName, 1) as CustomerName,
      begin_date                                                   as BeginDate,
      end_date                                                     as EndDate,
      dats_days_between( begin_date, end_date )                    as Duration,
      status                                                       as Status,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at                                                   as ChangedAt,
      @Semantics.user.lastChangedBy: true
      changed_by                                                   as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_change_at                                                as LocChangedAt,
      _Customer,
      _TravelItem

}
