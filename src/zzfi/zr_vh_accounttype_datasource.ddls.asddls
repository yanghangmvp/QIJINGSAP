@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.resultSet.sizeCategory: #XS
@EndUserText.label: '账户类型搜索帮助'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_VH_ACCOUNTTYPE_DATASOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDACCOUNTTYPE' ) as a

{
  key a.value_low as value,
      a.text
}
