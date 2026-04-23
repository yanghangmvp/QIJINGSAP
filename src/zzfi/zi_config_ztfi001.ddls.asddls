@EndUserText.label: '会计凭证暂存抬头表'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_CONFIG_Ztfi001
  as select from zztfi001
  association to parent ZI_CONFIG_Ztfi001_S as _Ztfi001All on $projection.SingletonID = _Ztfi001All.SingletonID
{
  key reference1indocumentheader    as Reference1indocumentheader,
  key datasource                    as Datasource,
      originalreferencedocumenttype as Originalreferencedocumenttype,
      businesstransactiontype       as Businesstransactiontype,
      companycode                   as Companycode,
      accountingdocumenttype        as Accountingdocumenttype,
      fiscalperiod                  as Fiscalperiod,
      postingdate                   as Postingdate,
      documentdate                  as Documentdate,
      transactioncurrency           as Transactioncurrency,
      exchangerate                  as Exchangerate,
      accountingdoccreatedbyuser    as Accountingdoccreatedbyuser,
      accountingdocumentheadertext  as Accountingdocumentheadertext,
      accountingdocument            as Accountingdocument,
      fiscalyear                    as Fiscalyear,
      virtualnum                    as Virtualnum,
      flag                          as Flag,
      msgty                         as Msgty,
      msgtx                         as Msgtx,
      @Semantics.user.createdBy: true
      created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.hidden: true
      local_last_changed_at         as LocalLastChangedAt,
      @Consumption.hidden: true
      1                             as SingletonID,
      _Ztfi001All
}
