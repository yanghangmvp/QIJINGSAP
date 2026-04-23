@AccessControl.authorizationCheck: #CHECK
@ObjectModel.resultSet.sizeCategory: #XS
@EndUserText.label: '回款类型搜索帮助'
define view entity ZR_VH_REYPE_DATASOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDRECEIVABLESTYPE' ) as a

{
  key a.value_low as value,
      a.text
}
