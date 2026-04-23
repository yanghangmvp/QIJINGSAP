@AccessControl.authorizationCheck: #CHECK
@ObjectModel.resultSet.sizeCategory: #XS
@EndUserText.label: '变动类型搜索帮助'
define view entity ZR_VH_ZZMOVE_DATASOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDMOVE' ) as a
{
  key a.value_low as value,
      a.text
}
