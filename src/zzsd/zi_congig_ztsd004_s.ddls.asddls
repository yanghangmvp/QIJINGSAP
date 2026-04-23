@EndUserText.label: '销售订单转积分-积分比例配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztsd004All'
  }
}
define root view entity ZI_congig_Ztsd004_S
  as select from I_Language
    left outer join ZZTSD004 on 0 = 0
  composition [0..*] of ZI_config_Ztsd004 as _sd004
{
  @UI.facet: [ {
    id: 'ZI_config_Ztsd004', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '销售订单转积分-积分比例配置表', 
    position: 1 , 
    targetElement: '_sd004'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _sd004,
  @UI.hidden: true
  max( ZZTSD004.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
