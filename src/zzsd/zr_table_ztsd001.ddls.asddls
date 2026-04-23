@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTSD001'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TABLE_ZTSD001
  as select from zztsd001 as SD001
  composition [0..*] of ZR_TABLE_ZTSD002 as _SD002
{
  key purchaseorderbycustomer        as Purchaseorderbycustomer,
      fsysid                         as Fsysid,
      salesdocumenttype              as Salesdocumenttype,
      salesdocumentdate              as Salesdocumentdate,
      salesorganization              as Salesorganization,
      distributionchannel            as Distributionchannel,
      organizationdivision           as Organizationdivision,
      salesoffice                    as Salesoffice,
      salesgroup                     as Salesgroup,
      soldtoparty                    as Soldtoparty,
      transactioncurrency            as Transactioncurrency,
      sddocumentreason               as Sddocumentreason,
      zlogisticscompany              as Zlogisticscompany,
      zlogisticsnumber               as Zlogisticsnumber,
      zpaymentdate                   as Zpaymentdate,
      zpaymenttime                   as Zpaymenttime,
      zpaymentmethod                 as Zpaymentmethod,
      zpaymentamount                 as Zpaymentamount,
      zhbeizu                        as Zhbeizu,
      zplatformcode                  as Zplatformcode,
      zdmssotype                     as Zdmssotype,
      customeraccountassignmentgroup as Customeraccountassignmentgroup,
      zfphm                          as Zfphm,
      zdua1                          as Zdua1,
      zdua2                          as Zdua2,
      zdua3                          as Zdua3,
      zdua4                          as Zdua4,
      zdua5                          as Zdua5,
      salesdocument                  as Salesdocument,
      deliverydocument               as Deliverydocument,
      billingdocument                as Billingdocument,
      zzxzt                          as Zzxzt,
      msgty                          as Msgty,
      msgtx                          as Msgtx,
      @Semantics.user.createdBy: true
      created_by                     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at          as LocalLastChangedAt,
      _SD002
}
