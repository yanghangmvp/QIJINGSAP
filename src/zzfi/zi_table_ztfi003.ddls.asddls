@EndUserText.label: '备选统驭科目配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TABLE_Ztfi003
  as select from ZZTFI003
  association to parent ZI_TABLE_Ztfi003_S as _Ztfi003All on $projection.SingletonID = _Ztfi003All.SingletonID
{
  key ZZKHONT_TY as ZzkhontTy,
  key ZZKHONT_BX as ZzkhontBx,
  KRZKY as Krzky,
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
  _Ztfi003All
}
