@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTFI002'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TABLE_ZTFI002
  as projection on ZR_TABLE_ZTFI002
{
  key Reference1indocumentheader,
  key Datasource,
  key Accountingdocumentitem,
      @ObjectModel.text.element     : [ 'GLAccountName' ]
      Glaccount,
      Amountintransactioncurrency,
      Amountincompanycodecurrency,
      Debitcreditcode,
      Documentitemtext,
      Masterfixedasset,
      Fixedasset,
      Assettransactiontype,
      Reasoncode,
      Assignmentreference,
      Profitcenter,
      Costcenter,
      Functionalarea,
      Wbselement,
      Customer,
      Specialglcode,
      @ObjectModel.text.element     : [ 'AltAccountName' ]
      Altvrecnclnaccts,
      Creditcontrolarea,
      Vendor,
      Duecalculationbasedate,
      Paymentreference,
      Tradingpartner,
      Zz005,
      Salesorder,
      Salesorderitem,
      Plant,
      Material,
      Reference3idbybusinesspartner,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.lastChangedBy: true
      }
      LastChangedBy,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      GLAccountName,
      AltAccountName,
      _FI001 : redirected to parent ZC_TABLE_ZTFI001
}
