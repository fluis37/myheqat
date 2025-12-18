@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Flight Travel (Data Model)'
define root view entity Z02_R_TRAVEL
  as select from z02_travel
  
  composition [0..*] of Z02_R_TRAVELITEM as _TravelItem
  {
    key agency_id   as AgencyId,
    key travel_id   as TravelId,
        description as Description,
        customer_id as CustomerId,
        begin_date  as BeginDate,
        end_date    as EndDate,
        dats_days_between( begin_date, end_date) as Duration,
        status      as Status,
        @Semantics.systemDateTime.lastChangedAt: true
        changed_at  as ChangedAt,
        @Semantics.user.lastChangedBy: true
        changed_by  as ChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        loc_changed_at as LocChangedAt,
        
        _TravelItem
        
  }
