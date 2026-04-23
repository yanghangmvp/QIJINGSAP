@EndUserText.label: '会计凭证暂存行项目表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_CONFIG_Ztfi002
  as select from zztfi002
  association to parent ZI_CONFIG_Ztfi002_S as _Ztfi002All on $projection.SingletonID = _Ztfi002All.SingletonID
{
  key reference1indocumentheader  as Reference1indocumentheader,
  key datasource                  as Datasource,
  key accountingdocumentitem      as Accountingdocumentitem,
      glaccount                   as Glaccount,
      amountintransactioncurrency as Amountintransactioncurrency,
      amountincompanycodecurrency as Amountincompanycodecurrency,
      debitcreditcode             as Debitcreditcode,
      documentitemtext            as Documentitemtext,
      masterfixedasset            as Masterfixedasset,
      fixedasset                  as Fixedasset,
      assettransactiontype        as Assettransactiontype,
      reasoncode                  as Reasoncode,
      assignmentreference         as Assignmentreference,
      profitcenter                as Profitcenter,
      costcenter                  as Costcenter,
      functionalarea              as Functionalarea,
      wbselement                  as Wbselement,
      customer                    as Customer,
      specialglcode               as Specialglcode,
      altvrecnclnaccts            as Altvrecnclnaccts,
      creditcontrolarea           as Creditcontrolarea,
      vendor                      as Vendor,
      duecalculationbasedate      as Duecalculationbasedate,
      paymentreference            as Paymentreference,
      tradingpartner              as Tradingpartner,
      zz005                       as Zz005,
      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                  as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by             as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at             as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.hidden: true
      local_last_changed_at       as LocalLastChangedAt,
      @Consumption.hidden: true
      1                           as SingletonID,
      _Ztfi002All
}
