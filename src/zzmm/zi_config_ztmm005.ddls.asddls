@EndUserText.label: '采购订单配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_CONFIG_Ztmm005
  as select from ZZTMM005
  association to parent ZI_CONFIG_Ztmm005_S as _Ztmm005All on $projection.SingletonID = _Ztmm005All.SingletonID
{
  key CONFTYPE as Conftype,
  key RELSYSTEM as Relsystem,
  key TRANSVALUE as Transvalue,
  CONFDESC as Confdesc,
  SAPVALUE as Sapvalue,
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
  _Ztmm005All
}
