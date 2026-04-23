@AccessControl.authorizationCheck: #CHECK
@ObjectModel.resultSet.sizeCategory: #XS
@EndUserText.label: '状态搜索帮助'

define view entity ZR_VH_STATUS_DATASOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDSTATUS' ) as a

{
  key a.value_low as value,
      a.text
}
