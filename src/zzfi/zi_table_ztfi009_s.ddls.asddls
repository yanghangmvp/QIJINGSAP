@EndUserText.label: '科目与变动维度映射表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi009All'
  }
}
define root view entity ZI_table_Ztfi009_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_TABLE_ZTFI009'
  composition [0..*] of ZI_table_Ztfi009 as _Ztfi009
{
  @UI.facet: [ {
    id: 'ZI_table_Ztfi009', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '科目与变动维度映射表', 
    position: 1 , 
    targetElement: '_Ztfi009'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi009,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
}
where I_Language.Language = $session.system_language
