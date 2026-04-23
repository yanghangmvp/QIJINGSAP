@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '固定资产时间戳'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_FIXEDASSET_TIM
  as select from I_FixedAsset
{
  key CompanyCode,
  key MasterFixedAsset,
  key FixedAsset,

      case LastChangeDate when ''  then CreationDateTime
                                   else LastChangeDateTime
        end as LastChangeDateTime
}
