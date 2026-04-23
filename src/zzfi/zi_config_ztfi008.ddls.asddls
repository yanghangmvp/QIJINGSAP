@EndUserText.label: '会计凭证审核平台-审核权限配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_config_Ztfi008
  as select from ZZTFI008
  association to parent ZI_Ztfi008_S as _Ztfi008All on $projection.SingletonID = _Ztfi008All.SingletonID
{
  key DATASOURCE as Datasource,
  key ZZUSERID as Zzuserid,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  @Semantics.user.lastChangedBy: true
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _Ztfi008All
}
