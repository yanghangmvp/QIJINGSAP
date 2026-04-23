@EndUserText.label: '销售订单转积分-积分比例配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_config_Ztsd004
  as select from ZZTSD004
  association to parent ZI_congig_Ztsd004_S as _Ztsd004All on $projection.SingletonID = _Ztsd004All.SingletonID
{
  key WAERS as Waers,
  key ZZBEGIN as Zzbegin,
  key ZZEND as Zzend,
  ZZBL as Zzbl,
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
  _Ztsd004All
}
