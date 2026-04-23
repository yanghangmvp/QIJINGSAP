@EndUserText.label: '会计凭证审核平台-审核权限配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi008All'
  }
}
define root view entity ZI_Ztfi008_S
  as select from I_Language
    left outer join ZZTFI008 on 0 = 0
  composition [0..*] of ZI_config_Ztfi008 as _Ztfi008
{
  @UI.facet: [ {
    id: 'ZI_config_Ztfi008', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '会计凭证审核平台-审核权限配置表', 
    position: 1 , 
    targetElement: '_Ztfi008'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi008,
  @UI.hidden: true
  max( ZZTFI008.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
