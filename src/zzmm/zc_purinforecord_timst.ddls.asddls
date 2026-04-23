@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '采购信息记录更改时间戳'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PURINFORECORD_TIMST
  as select from C_PurInfoRecordDocumentChanges( P_DateFunction : '*' , P_StartDate: '20260101', P_EndDate: '99991231' )
{
  key ChangeDocObject,
  key ChangeDocument,
  key DatabaseTable,
  key ChangeDocTableKey,
  key ChangeDocDatabaseTableField,


      ChangeDocPreviousUnit,
      ChangeDocNewUnit,
      ChangeDocPreviousCurrency,
      ChangeDocNewCurrency,
      ChangeDocNewFieldValue,
      ChangeDocPreviousFieldValue,
      ChangeDocTextIsChanged,

      CreatedByUser,
      CreationDate,
      CreationTime,
      ChangeTransactionCode,
      ChangeDocChangeType,
      ChangeDocObjectClass,

      cast ( dats_tims_to_tstmp( CreationDate,CreationTime,'UTC',$session.client,'NULL' )  as timestampl ) as LastChangeDateTime

}
