@EndUserText.label: 'TA系统配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_CONFIG_ZTFI006
  as select from ZZTFI006
  association to parent ZI_CONFIG_ZTFI006_S as _FI006 on $projection.SingletonID = _FI006.SingletonID
{
  key ZZENUMB as Zzenumb,
  ZZDATABASE as Zzdatabase,
  ZZTABLE as Zztable,
  ZZPACK as Zzpack,
  @Consumption.hidden: true
  1 as SingletonID,
  _FI006
}
