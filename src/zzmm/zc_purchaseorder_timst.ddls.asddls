@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '采购订单更改时间戳'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PURCHASEORDER_TIMST
  as select from I_PurchaseOrderHistoryAPI01 as a
    join         I_PurchaseOrderAPI01        as b on a.PurchaseOrder = b.PurchaseOrder
{
  key a.PurchasingHistoryDocument,
  key a.PurchasingHistoryDocumentItem,
      a.PostingDate,
      b.PurchaseOrderType,
      a.Plant,
      concat( a.PurchasingHistoryDocument, a.PurchasingHistoryDocumentItem ) as uuid
}
