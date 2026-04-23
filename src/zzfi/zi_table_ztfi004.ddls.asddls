@EndUserText.label: '现金流量表配置'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TABLE_Ztfi004
  as select from ZZTFI004
  association to parent ZI_TABLE_Ztfi004_S as _Ztfi004All on $projection.SingletonID = _Ztfi004All.SingletonID
{
  key COMPANYCODE as Companycode,
  key FIITEM as Fiitem,
  key FISUIT as Fisuit,
  FITEXT as Fitext,
  FITYPE as Fitype,
  FISIGN as Fisign,
  PAYMENTDIFFERENCEREASON as Paymentdifferencereason,
  ITEMFROM as Itemfrom,
  ITEMTO as Itemto,
  GLACCOUNTFROM as Glaccountfrom,
  GLACCOUNTTO as Glaccountto,
  DEBITCREDITCODE as Debitcreditcode,
  CONFIGDEPRECATIONCODE as ConfigDeprecationCode,
  @Consumption.hidden: true
  1 as SingletonID,
  _Ztfi004All
}
