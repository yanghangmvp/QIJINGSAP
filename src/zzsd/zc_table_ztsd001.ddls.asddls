@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTSD001'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TABLE_ZTSD001
  provider contract transactional_query
  as projection on ZR_TABLE_ZTSD001
{
  key Purchaseorderbycustomer,
      Fsysid,
      Salesdocumenttype,
      Salesdocumentdate,
      Salesorganization,
      Distributionchannel,
      Organizationdivision,
      Salesoffice,
      Salesgroup,
      Soldtoparty,
      Transactioncurrency,
      Sddocumentreason,
      Zlogisticscompany,
      Zlogisticsnumber,
      Zpaymentdate,
      Zpaymenttime,
      Zpaymentmethod,
      Zpaymentamount,
      Zhbeizu,
      Zplatformcode,
      Zdmssotype,
      Customeraccountassignmentgroup,
      Zfphm,
      Zdua1,
      Zdua2,
      Zdua3,
      Zdua4,
      Zdua5,
      Salesdocument,
      Deliverydocument,
      Billingdocument,
      Zzxzt,
      Msgty,
      Msgtx,
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
      _SD002 : redirected to composition child ZC_TABLE_ZTSD002
}
