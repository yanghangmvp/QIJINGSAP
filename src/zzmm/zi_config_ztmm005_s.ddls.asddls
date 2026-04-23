@EndUserText.label: '采购订单配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztmm005All'
  }
}
define root view entity ZI_CONFIG_Ztmm005_S
  as select from I_Language
    left outer join ZZTMM005 on 0 = 0
  composition [0..*] of ZI_CONFIG_Ztmm005 as _mm005
{
  @UI.facet: [ {
    id: 'ZI_CONFIG_Ztmm005', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '采购订单配置表', 
    position: 1 , 
    targetElement: '_mm005'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _mm005,
  @UI.hidden: true
  max( ZZTMM005.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
