@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZGENTRAVEL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_00GENTRAVEL
  as select from Z00_GENTRAVEL as Travel
{
  key agency_id as AgencyID,
  key travel_id as TravelID,
  description as Description,
  customer_id as CustomerID,
  begin_date as BeginDate,
  end_date as EndDate,
  status as Status,
  @Semantics.systemDateTime.createdAt: true
  create_at as CreateAt,
  @Semantics.user.createdBy: true
  create_by as CreateBy,
  @Semantics.systemDateTime.lastChangedAt: true
  changed_at as ChangedAt,
  @Semantics.user.lastChangedBy: true
  changed_by as ChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  loc_changed_at as LocChangedAt
}
