@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTFI001'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TABLE_ZTFI001
  as select from    zztfi001              as FI001
    left outer join ZR_VH_DOC_DATASOURCE  as _datasource  on FI001.datasource = _datasource.value
    left outer join ZR_VH_TSZT_DATASOURCE as _datasource2 on FI001.zztszt = _datasource2.value
  composition [0..*] of ZR_TABLE_ZTFI002 as _FI002
{
  key FI001.reference1indocumentheader    as Reference1indocumentheader,
  key FI001.datasource                    as Datasource,
      FI001.originalreferencedocumenttype as Originalreferencedocumenttype,
      FI001.businesstransactiontype       as Businesstransactiontype,
      FI001.companycode                   as CompanyCode,
      FI001.accountingdocumenttype        as Accountingdocumenttype,
      FI001.fiscalperiod                  as Fiscalperiod,
      FI001.postingdate                   as Postingdate,
      FI001.documentdate                  as Documentdate,
      FI001.transactioncurrency           as Transactioncurrency,
      FI001.exchangerate                  as Exchangerate,
      FI001.accountingdoccreatedbyuser    as Accountingdoccreatedbyuser,
      FI001.accountingdocumentheadertext  as Accountingdocumentheadertext,
      FI001.accountingdocument            as Accountingdocument,
      FI001.fiscalyear                    as FiscalYear,
      FI001.virtualnum                    as Virtualnum,
      FI001.flag                          as Flag,
      FI001.zztszt                        as Zztszt,
      FI001.msgty                         as Msgty,
      FI001.msgtx                         as Msgtx,
      @Semantics.user.createdBy: true
      FI001.created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      FI001.created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      FI001.last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      FI001.last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      FI001.local_last_changed_at         as LocalLastChangedAt,
      _datasource.text                    as DatasourceText,
      _datasource2.text                   as TsztText,
      _FI002
}
