@EndUserText.label: '分配的现金流量码'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_TABLE_Ztfi005
  as select from ZZTFI005
  association to parent ZI_TABLE_Ztfi005_S as _Ztfi005All on $projection.SingletonID = _Ztfi005All.SingletonID
{
  key COMPANYCODE as Companycode,
  key FISCALYEAR as Fiscalyear,
  key ACCOUNTINGDOCUMENT as Accountingdocument,
  key LEDGERGLLINEITEM as Ledgergllineitem,
  PAYMENTDIFFERENCEREASON as Paymentdifferencereason,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  @Semantics.user.lastChangedBy: true
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _Ztfi005All
}
