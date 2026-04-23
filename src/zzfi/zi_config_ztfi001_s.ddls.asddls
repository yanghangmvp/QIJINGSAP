@EndUserText.label: '会计凭证暂存抬头表 Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'Ztfi001All'
  }
}
define root view entity ZI_CONFIG_Ztfi001_S
  as select from I_Language
    left outer join ZZTFI001 on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_CONFIG_Ztfi001 as _Ztfi001
{
  @UI.facet: [ {
    id: 'Transport', 
    purpose: #STANDARD, 
    type: #IDENTIFICATION_REFERENCE, 
    label: '传输', 
    position: 1 , 
    hidden: #(HideTransport)
  }, {
    id: 'ZI_CONFIG_Ztfi001', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: '会计凭证暂存抬头表', 
    position: 2 , 
    targetElement: '_Ztfi001'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Ztfi001,
  @UI.hidden: true
  max( ZZTFI001.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  }, {
    type: #FOR_ACTION, 
    dataAction: 'SelectCustomizingTransptReq', 
    label: '选择传输'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText,
  @UI.hidden: true
  cast( 'X' as ABAP_BOOLEAN preserving type) as HideTransport
}
where I_Language.Language = $session.system_language
