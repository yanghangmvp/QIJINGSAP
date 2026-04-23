@EndUserText.label: '凭证数据来源'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZR_VH_DOC_DATASOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDDATASOURCE' ) as a

{
  key a.value_low as value,
      a.text
}
