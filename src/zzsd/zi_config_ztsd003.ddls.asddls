@EndUserText.label: '销售订单转积分订单配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_CONFIG_Ztsd003
  as select from ZZTSD003
  association to parent ZI_CONFIG_Ztsd003_S as _Ztsd003All on $projection.SingletonID = _Ztsd003All.SingletonID
{
  key SALESORGANIZATION as Salesorganization,
  key FSYSID as Fsysid,
  key ZDMSSOTYPE as Zdmssotype,
  ZZXFLAG as Zzxflag,
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
  _Ztsd003All
}
