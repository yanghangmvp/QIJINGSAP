@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTFI010'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CONFIG_ZTFI010
  provider contract transactional_query
  as projection on ZR_CONFIG_ZTFI010
  association [1..1] to ZR_CONFIG_ZTFI010 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
      Reference1indocumentheader,
      Datasource,
      Originalreferencedocumenttype,
      Businesstransactiontype,
      Companycode,
      Accountingdocumenttype,
      Fiscalperiod,
      Postingdate,
      Documentdate,
      Transactioncurrency,
      Exchangerate,
      Accountingdocumentheadertext,
      Accountingdocumentitem,
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
      Altvrecnclnaccts,
      Costcenter,
      Customer,
      Duecalculationbasedate,
      Functionalarea,
      Profitcenter,
      Tradingpartner,
      Material,
      Salesorder,
      Salesorderitem,
      Vendor,
      Wbselement,
      Zz005,
      Zflag,
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
      _BaseEntity
}
