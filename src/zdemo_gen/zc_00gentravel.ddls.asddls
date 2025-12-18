@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZGENTRAVEL'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_00GENTRAVEL
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_00GENTRAVEL
  association [1..1] to ZR_00GENTRAVEL as _BaseEntity on $projection.AGENCYID = _BaseEntity.AGENCYID and $projection.TRAVELID = _BaseEntity.TRAVELID
{
  key AgencyID,
  key TravelID,
  Description,
  CustomerID,
  BeginDate,
  EndDate,
  Status,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreateAt,
  @Semantics: {
    User.Createdby: true
  }
  CreateBy,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  ChangedAt,
  @Semantics: {
    User.Lastchangedby: true
  }
  ChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocChangedAt,
  _BaseEntity
}
