@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTSD002'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define view entity ZR_TABLE_ZTSD002
  as select from zztsd002 as SD002
  association to parent ZR_TABLE_ZTSD001 as _SD001 on _SD001.Purchaseorderbycustomer = $projection.Purchaseorderbycustomer

{
  key purchaseorderbycustomer   as Purchaseorderbycustomer,
  key salesdocumentitem         as Salesdocumentitem,
      salesdocumentitemcategory as Salesdocumentitemcategory,
      product                   as Product,
      orderquantity             as Orderquantity,
      orderquantityunit         as Orderquantityunit,
      batch                     as Batch,
      plant                     as Plant,
      serialnumber              as Serialnumber,
      storagelocation           as Storagelocation,
      zbeizuitem                as Zbeizuitem,
      zplatformcode             as Zplatformcode,
      zdmssotype                as Zdmssotype,
      conditiontype             as Conditiontype,
      conditionratevalue        as Conditionratevalue,
      conditionquantity         as Conditionquantity,
      conditionamount           as Conditionamount,
      zdua1                     as Zdua1,
      zdua2                     as Zdua2,
      zdua3                     as Zdua3,
      zdua4                     as Zdua4,
      zdua5                     as Zdua5,
      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt,
      _SD001
}
