@EndUserText.label: '车型记录表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztmm001All'
  }
}
define root view entity ZI_TABLE_Ztmm001_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_TABLE_ZTMM001'
  composition [0..*] of ZI_TABLE_Ztmm001 as _Ztmm001
{
  @UI.facet: [ {
    id: 'ZI_TABLE_Ztmm001', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '车型记录表', 
    position: 1 , 
    targetElement: '_Ztmm001'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztmm001,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
}
where I_Language.Language = $session.system_language
