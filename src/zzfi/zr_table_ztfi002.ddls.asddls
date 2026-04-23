@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTFI002'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TABLE_ZTFI002
  as select from    zztfi002        as FI002
    left outer join I_GLAccountText as _GLAccountText  on  _GLAccountText.GLAccount       = FI002.glaccount
                                                       and _GLAccountText.ChartOfAccounts = 'YCOA'
                                                       and _GLAccountText.Language        = $session.system_language
    left outer join I_GLAccountText as _AltAccountText on  _AltAccountText.GLAccount       = FI002.altvrecnclnaccts
                                                       and _AltAccountText.ChartOfAccounts = 'YCOA'
                                                       and _AltAccountText.Language        = $session.system_language

  association to parent ZR_TABLE_ZTFI001 as _FI001 on  _FI001.Reference1indocumentheader = $projection.Reference1indocumentheader
                                                   and _FI001.Datasource                 = $projection.Datasource
{
  key FI002.reference1indocumentheader    as Reference1indocumentheader,
  key FI002.datasource                    as Datasource,
  key FI002.accountingdocumentitem        as Accountingdocumentitem,
      FI002.glaccount                     as Glaccount,
      FI002.amountintransactioncurrency   as Amountintransactioncurrency,
      FI002.amountincompanycodecurrency   as Amountincompanycodecurrency,
      FI002.debitcreditcode               as Debitcreditcode,
      FI002.documentitemtext              as Documentitemtext,
      FI002.masterfixedasset              as Masterfixedasset,
      FI002.fixedasset                    as Fixedasset,
      FI002.assettransactiontype          as Assettransactiontype,
      FI002.reasoncode                    as Reasoncode,
      FI002.assignmentreference           as Assignmentreference,
      FI002.profitcenter                  as Profitcenter,
      FI002.costcenter                    as Costcenter,
      FI002.functionalarea                as Functionalarea,
      FI002.wbselement                    as Wbselement,
      FI002.customer                      as Customer,
      FI002.specialglcode                 as Specialglcode,
      FI002.altvrecnclnaccts              as Altvrecnclnaccts,
      FI002.creditcontrolarea             as Creditcontrolarea,
      FI002.vendor                        as Vendor,
      FI002.duecalculationbasedate        as Duecalculationbasedate,
      FI002.paymentreference              as Paymentreference,
      FI002.tradingpartner                as Tradingpartner,
      FI002.zz005                         as Zz005,
      FI002.salesorder                    as Salesorder,
      FI002.salesorderitem                as Salesorderitem,
      FI002.plant                         as Plant,
      FI002.material                      as Material,
      FI002.reference3idbybusinesspartner as Reference3idbybusinesspartner,
      @Semantics.user.createdBy: true
      FI002.created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      FI002.created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      FI002.last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      FI002.last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      FI002.local_last_changed_at         as LocalLastChangedAt,
      _GLAccountText.GLAccountName        as GLAccountName,
      _AltAccountText.GLAccountName       as AltAccountName,
      _FI001
}
