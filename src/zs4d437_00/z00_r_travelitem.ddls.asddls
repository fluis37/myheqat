@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel Item'
@AbapCatalog.viewEnhancementCategory: [ #PROJECTION_LIST ]
@AbapCatalog.extensibility: {
    extensible: true,
    elementSuffix: 'Z00',
    dataSources: [ '_Extension' ],
    allowNewDatasources: false
}
define view entity Z00_R_TravelItem
  as select from z00_tritem
  association to parent Z00_R_Travel as _Travel    on  $projection.AgencyId = _Travel.AgencyId
                                                   and $projection.TravelId = _Travel.TravelId


  association to Z00_E_travelItem    as _Extension on  $projection.ItemUuid = _Extension.ItemUuid
{
  key item_uuid            as ItemUuid,
      agency_id            as AgencyId,
      travel_id            as TravelId,
      carrier_id           as CarrierId,
      connection_id        as ConnectionId,
      flight_date          as FlightDate,
      booking_id           as BookingId,
      passenger_first_name as PassengerFirstName,
      passenger_last_name  as PassengerLastName,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at           as ChangedAt,
      @Semantics.user.lastChangedBy: true
      changed_by           as ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_changed_at       as LocChangedAt,

      _Travel,
      _Extension

}
