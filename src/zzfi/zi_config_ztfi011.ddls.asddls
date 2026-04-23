@EndUserText.label: '综合管理维度项目配置表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_config_Ztfi011
  as select from ZZTFI011
  association to parent ZI_config_Ztfi011_S as _Ztfi011All on $projection.SingletonID = _Ztfi011All.SingletonID
  association [0..*] to I_ConfignDeprecationCodeText as _ConfignDeprecationCodeText on $projection.ConfigDeprecationCode = _ConfignDeprecationCodeText.ConfigurationDeprecationCode
{
  key GLACCOUNT_FROM as GlaccountFrom,
  key GLACCOUNT_TO as GlaccountTo,
  key ZZITEMTYPE as Zzitemtype,
  key ZZCODE as Zzcode,
  ZZITEMNAME as Zzitemname,
  ZZCODENAME as Zzcodename,
  ZZEDIT as Zzedit,
  ZZMANDATORY as Zzmandatory,
  ZZDEFAULT as Zzdefault,
  ZZDEFAULT_DEC as ZzdefaultDec,
  @ObjectModel.text.association: '_ConfignDeprecationCodeText'
  @Consumption.valueHelpDefinition: [ {
    entity: {
      name: 'I_ConfignDeprecationCode', 
      element: 'ConfigurationDeprecationCode'
    }, 
    useForValidation: true
  } ]
  CONFIGDEPRECATIONCODE as ConfigDeprecationCode,
  @Consumption.hidden: true
  1 as SingletonID,
  _Ztfi011All,
  case when CONFIGDEPRECATIONCODE = 'W' then 2 when CONFIGDEPRECATIONCODE = 'E' then 1 else 3 end as ConfigDeprecationCode_Critlty,
  _ConfignDeprecationCodeText
}
