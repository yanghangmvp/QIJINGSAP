@EndUserText.label: '销售订单转积分订单配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztsd003All'
  }
}
define root view entity ZI_CONFIG_Ztsd003_S
  as select from I_Language
    left outer join ZZTSD003 on 0 = 0
  composition [0..*] of ZI_CONFIG_Ztsd003 as _Ztsd003
{
  @UI.facet: [ {
    id: 'ZI_CONFIG_Ztsd003', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '销售订单转积分订单配置表', 
    position: 1 , 
    targetElement: '_Ztsd003'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztsd003,
  @UI.hidden: true
  max( ZZTSD003.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
