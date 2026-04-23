@EndUserText.label: '科目与变动维度映射表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_table_Ztfi009
  as select from    zztfi009
    left outer join ZR_VH_ZZMOVE_DATASOURCE as _datasources on zztfi009.zzmove_s = _datasources.value
    left outer join ZR_VH_ZZMOVE_DATASOURCE as _datasourceh on zztfi009.zzmove_h = _datasourceh.value
    left outer join I_CnsldtnGLAccountVH    as _GLAccount   on  zztfi009.glaccount         = _GLAccount.GLAccount
                                                            and _GLAccount.ChartOfAccounts = 'YCOA'
  association        to parent ZI_table_Ztfi009_S    as _Ztfi009All                 on $projection.SingletonID = _Ztfi009All.SingletonID
  association [0..*] to I_ConfignDeprecationCodeText as _ConfignDeprecationCodeText on $projection.ConfigDeprecationCode = _ConfignDeprecationCodeText.ConfigurationDeprecationCode
{
      @ObjectModel.text.element     : [ 'GLAccountName' ]
  key zztfi009.glaccount             as Glaccount,
      @ObjectModel.text.element     : [ 'zzmovesname' ]
      zztfi009.zzmove_s              as ZzmoveS,
      @ObjectModel.text.element     : [ 'zzmovehname' ]
      zztfi009.zzmove_h              as ZzmoveH,
      _GLAccount.GLAccountName       as GLAccountName,
      _datasources.text              as zzmovesname,
      _datasourceh.text              as zzmovehname,
      @ObjectModel.text.association: '_ConfignDeprecationCodeText'
      @Consumption.valueHelpDefinition: [ {
        entity: {
          name: 'I_ConfignDeprecationCode',
          element: 'ConfigurationDeprecationCode'
        },
        useForValidation: true
      } ]
      zztfi009.configdeprecationcode as ConfigDeprecationCode,
      @Consumption.hidden: true
      1                              as SingletonID,
      _Ztfi009All,
      case
      when zztfi009.configdeprecationcode = 'W' then 2
      when zztfi009.configdeprecationcode = 'E' then 1
      else 3
      end                            as ConfigDeprecationCode_Critlty,
      _ConfignDeprecationCodeText
}
