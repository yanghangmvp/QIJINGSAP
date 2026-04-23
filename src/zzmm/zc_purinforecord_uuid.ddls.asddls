@EndUserText.label: '采购价格主数据主键'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PURINFORECORD_UUID
  as select from C_PurgInfoRecdPriceCndnDEX
{
  key PurchasingInfoRecord,
  key ConditionRecord,
  key ConditionValidityEndDate,
      concat ( concat( PurchasingInfoRecord, ConditionRecord ) , ConditionValidityEndDate ) as uuid
}
