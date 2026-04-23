@EndUserText.label: '综合管理维度项目配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi011All'
  }
}
define root view entity ZI_config_Ztfi011_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_CONFIG_ZTFI011'
  composition [0..*] of ZI_config_Ztfi011 as _Ztfi011
{
  @UI.facet: [ {
    id: 'ZI_config_Ztfi011', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '综合管理维度项目配置表', 
    position: 1 , 
    targetElement: '_Ztfi011'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi011,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
}
where I_Language.Language = $session.system_language
