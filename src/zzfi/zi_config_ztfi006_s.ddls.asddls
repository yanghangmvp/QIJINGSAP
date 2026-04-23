@EndUserText.label: 'TA系统配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'FI006'
  }
}
define root view entity ZI_CONFIG_ZTFI006_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_CONFIG_ZTFI006'
  composition [0..*] of ZI_CONFIG_ZTFI006 as _FI006all
{
  @UI.facet: [ {
    id: 'ZI_CONFIG_ZTFI006', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'TA系统配置表', 
    position: 1 , 
    targetElement: '_FI006all'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _FI006all,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
}
where I_Language.Language = $session.system_language
