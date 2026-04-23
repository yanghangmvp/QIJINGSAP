@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '物料更改时间戳'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PRODUCT_TIMST
  as select from I_Product           as a
    join         I_ProductPlantBasic as b on a.Product = b.Product
{
  key a.Product,
  key b.Plant,
      concat( a.Product, b.Plant ) as uuid,
      case a.LastChangeDate when '00000000'
      then cast (dats_tims_to_tstmp( a.CreationDate,a.CreationTime,'UTC',$session.client,'NULL' )  as timestampl )
      else cast (dats_tims_to_tstmp( a.LastChangeDate,a.LastChangeTime,'UTC',$session.client,'NULL' ) as timestampl )
       end                         as LastChangeDateTime
}
