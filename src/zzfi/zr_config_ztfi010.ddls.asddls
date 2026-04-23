@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTFI010'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CONFIG_ZTFI010
  as select from zztfi010 as ZTFI010
{
  key uuid                          as UUID,
      reference1indocumentheader    as Reference1indocumentheader,
      datasource                    as Datasource,
      originalreferencedocumenttype as Originalreferencedocumenttype,
      businesstransactiontype       as Businesstransactiontype,
      companycode                   as Companycode,
      accountingdocumenttype        as Accountingdocumenttype,
      fiscalperiod                  as Fiscalperiod,
      postingdate                   as Postingdate,
      documentdate                  as Documentdate,
      transactioncurrency           as Transactioncurrency,
      exchangerate                  as Exchangerate,
      accountingdocumentheadertext  as Accountingdocumentheadertext,
      accountingdocumentitem        as Accountingdocumentitem,
      glaccount                     as Glaccount,
      amountintransactioncurrency   as Amountintransactioncurrency,
      amountincompanycodecurrency   as Amountincompanycodecurrency,
      debitcreditcode               as Debitcreditcode,
      documentitemtext              as Documentitemtext,
      masterfixedasset              as Masterfixedasset,
      fixedasset                    as Fixedasset,
      assettransactiontype          as Assettransactiontype,
      reasoncode                    as Reasoncode,
      assignmentreference           as Assignmentreference,
      altvrecnclnaccts              as Altvrecnclnaccts,
      costcenter                    as Costcenter,
      customer                      as Customer,
      duecalculationbasedate        as Duecalculationbasedate,
      functionalarea                as Functionalarea,
      profitcenter                  as Profitcenter,
      tradingpartner                as Tradingpartner,
      material                      as Material,
      salesorder                    as Salesorder,
      salesorderitem                as Salesorderitem,
      vendor                        as Vendor,
      wbselement                    as Wbselement,
      zz005                         as Zz005,
      zflag                         as Zflag,
      @Semantics.user.createdBy: true
      created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at         as LocalLastChangedAt
}
