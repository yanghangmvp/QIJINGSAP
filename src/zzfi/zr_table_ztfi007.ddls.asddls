@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTFI007'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TABLE_ZTFI007
  as select from    zztfi007a                    as FI007
    left outer join ZR_VH_REYPE_DATASOURCE       as _datasource1 on FI007.receivablestype = _datasource1.value
    left outer join ZR_VH_STATUS_DATASOURCE      as _datasource2 on FI007.status = _datasource2.value
    left outer join ZR_VH_ACCOUNTTYPE_DATASOURCE as _datasource3 on FI007.accounttype = _datasource3.value
{
  key FI007.recordid              as Recordid,
  key FI007.unitno                as Unitno,
      FI007.accountno             as Accountno,
      FI007.accountname           as Accountname,
      FI007.bankno                as Bankno,
      FI007.openbank              as Openbank,
      FI007.recorddate            as Recorddate,
      FI007.balancedir            as Balancedir,
      FI007.currencyno            as Currencyno,
      FI007.amount                as Amount,
      FI007.opaccountno           as Opaccountno,
      FI007.opaccountname         as Opaccountname,
      FI007.opbranchbankname      as Opbranchbankname,
      FI007.hostid                as Hostid,
      FI007.ticketn               as Ticketn,
      FI007.summary               as Summary,
      FI007.remark                as Remark,
      FI007.postscript            as Postscript,
      FI007.hosttime              as Hosttime,
      FI007.merchantnumber        as Merchantnumber,
      FI007.merchantname          as Merchantname,
      FI007.storecode             as Storecode,
      FI007.storename             as Storename,
      FI007.status                as Status,
      FI007.accounttype           as Accounttype,
      FI007.receivablestype       as Receivablestype,
      FI007.accountingdocument    as Accountingdocument,
      FI007.fiscalyear            as Fiscalyear,
      FI007.postdata              as Postdata,
      FI007.flag                  as Flag,
      FI007.msgty                 as Msgty,
      FI007.msgtx                 as Msgtx,
      _datasource1.text           as receivablestypetxt,
      _datasource2.text           as statustxt,
      _datasource3.text           as accounttypetxt,
      @Semantics.user.createdBy: true
      FI007.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      FI007.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      FI007.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      FI007.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      FI007.local_last_changed_at as LocalLastChangedAt
}
