@EndUserText.label: '备选统驭科目配置表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi003All'
  }
}
define root view entity ZI_TABLE_Ztfi003_S
  as select from I_Language
    left outer join ZZTFI003 on 0 = 0
  composition [0..*] of ZI_TABLE_Ztfi003 as _Ztfi003
{
  @UI.facet: [ {
    id: 'ZI_TABLE_Ztfi003', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '备选统驭科目配置表', 
    position: 1 , 
    targetElement: '_Ztfi003'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi003,
  @UI.hidden: true
  max( ZZTFI003.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
