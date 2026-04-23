@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTFI001'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TABLE_ZTFI001
  provider contract transactional_query
  as projection on ZR_TABLE_ZTFI001
{
  key Reference1indocumentheader,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'ZR_VH_DOC_DATASOURCE' , element: 'value' }, useForValidation: true}]
      @ObjectModel.text.element     : [ 'DatasourceText' ]
  key Datasource,
      Originalreferencedocumenttype,
      Businesstransactiontype,
      CompanyCode,
      Accountingdocumenttype,
      Fiscalperiod,
      Postingdate,
      Documentdate,
      Transactioncurrency,
      Exchangerate,
      Accountingdoccreatedbyuser,
      Accountingdocumentheadertext,
      Accountingdocument,
      FiscalYear,
      Virtualnum,
      Flag,
      @ObjectModel.text.element     : [ 'TsztText' ]
      Zztszt,
      Msgty,
      Msgtx,
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
      LocalLastChangedAt,
      DatasourceText,
      TsztText,
      _FI002 : redirected to composition child ZC_TABLE_ZTFI002
}
