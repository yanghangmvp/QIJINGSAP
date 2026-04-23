@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTSD002'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_TABLE_ZTSD002
  as projection on ZR_TABLE_ZTSD002

{
  key Purchaseorderbycustomer,
  key Salesdocumentitem,
      Salesdocumentitemcategory,
      Product,
      Orderquantity,
      Orderquantityunit,
      Batch,
      Plant,
      Serialnumber,
      Storagelocation,
      Zbeizuitem,
      Zplatformcode,
      Zdmssotype,
      Conditiontype,
      Conditionratevalue,
      Conditionquantity,
      Conditionamount,
      Zdua1,
      Zdua2,
      Zdua3,
      Zdua4,
      Zdua5,
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
      _SD001 : redirected to parent ZC_TABLE_ZTSD001

}
