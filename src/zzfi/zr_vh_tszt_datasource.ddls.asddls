@AccessControl.authorizationCheck: #CHECK
@ObjectModel.resultSet.sizeCategory: #XS
@EndUserText.label: '推送状态'
define view entity ZR_VH_TSZT_DATASOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDTSZT' ) as a

{
  key a.value_low as value,
      a.text
}
