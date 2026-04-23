@EndUserText.label: '会计凭证暂存行项目表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi002All'
  }
}
define root view entity ZI_CONFIG_Ztfi002_S
  as select from I_Language
    left outer join ZZTFI002 on 0 = 0
  composition [0..*] of ZI_CONFIG_Ztfi002 as _Ztfi002
{
  @UI.facet: [ {
    id: 'ZI_CONFIG_Ztfi002', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '会计凭证暂存行项目表', 
    position: 1 , 
    targetElement: '_Ztfi002'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi002,
  @UI.hidden: true
  max( ZZTFI002.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
