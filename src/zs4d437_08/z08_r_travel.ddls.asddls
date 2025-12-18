@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel (Data Model)'

define root view entity Z08_R_TRAVEL
  as select from z08_travel
{
  key agency_id   as AgencyId,
  key travel_id   as TravelId,
      description as Description,
      customer_id as CustomerId,
      begin_date  as BeginDate,
      end_date    as EndDate,
      dats_days_between( begin_date, end_date ) as Duration,
      status      as Status,
      @Semantics.systemDateTime.lastChangedAt: true  //màj automatique à la sauvegarde
      changed_at  as ChangedAt,
      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,
// ajout du champs loc_changed pour le mode draft 
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_changed_at as LocChangedAt
}
