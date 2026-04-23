@EndUserText.label: '分配的现金流量码 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi005All'
  }
}
define root view entity ZI_TABLE_Ztfi005_S
  as select from I_Language
    left outer join ZZTFI005 on 0 = 0
  composition [0..*] of ZI_TABLE_Ztfi005 as _Ztfi005
{
  @UI.facet: [ {
    id: 'ZI_TABLE_Ztfi005', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '分配的现金流量码', 
    position: 1 , 
    targetElement: '_Ztfi005'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi005,
  @UI.hidden: true
  max( ZZTFI005.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
