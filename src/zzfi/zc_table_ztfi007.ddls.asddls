@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTFI007'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TABLE_ZTFI007
  provider contract transactional_query
  as projection on ZR_TABLE_ZTFI007
{
  key Recordid,
  key Unitno,
      Accountno,
      Accountname,
      Bankno,
      Openbank,
      Recorddate,
      Balancedir,
      Currencyno,
      Amount,
      Opaccountno,
      Opaccountname,
      Opbranchbankname,
      Hostid,
      Ticketn,
      Summary,
      Remark,
      Postscript,
      Hosttime,
      Merchantnumber,
      Merchantname,
      Storecode,
      Storename,
      @ObjectModel.text.element     : [ 'statustxt' ]
      Status,
      @ObjectModel.text.element     : [ 'accounttypetxt' ]
      Accounttype,
      @ObjectModel.text.element     : [ 'receivablestypetxt' ]
      Receivablestype,
      Accountingdocument,
      Fiscalyear,
      Postdata,
      Flag,
      Msgty,
      Msgtx,
      receivablestypetxt,
      statustxt,
      accounttypetxt,

      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.lastChangedBy: true
      }
      LastChangedBy,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt
}
