CLASS zzcl_api_mm016 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_serialnumbers,
            serialnumber TYPE string,   "序列号
          END OF ty_serialnumbers,

          BEGIN OF ty_item,
            material                   TYPE matnr,  "物料编号
            plant                      TYPE string, "工厂
            storagelocation            TYPE string, "库存地点编号
            goodsmovementtype          TYPE string, "移动类型(库存管理)
            costcenter                 TYPE string, "成本中心
            quantityinentryunit        TYPE string, "数量
            materialdocumentitemtext   TYPE string, "关联单号行号
            specialstockidfgwbselement TYPE string, "项目编号
            wbselement                 TYPE string, "项目编号
            materialdocumentline       TYPE string, "行号
            to_serialnumbers           TYPE TABLE OF ty_serialnumbers WITH EMPTY KEY,
          END OF ty_item,

          BEGIN OF ty_data,
            documentdate            TYPE string,    "创建日期
            postingdate             TYPE string,    "过账日期
            referencedocument       TYPE string,    "单据编号
            goodsmovementcode       TYPE string,    "货物移动编码
            to_materialdocumentitem TYPE TABLE OF ty_item WITH EMPTY KEY,
          END OF ty_data.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_mmi016_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi002_resp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm016 IMPLEMENTATION.


  METHOD inbound.
    DATA: lv_json TYPE string.
    DATA: ls_data TYPE ty_data.
    DATA: lt_serialnumbers TYPE TABLE OF ty_serialnumbers.
    DATA: ls_req TYPE zzs_mmi016_in.

    DATA: ls_ztmm003 TYPE zztmm003,
          lt_ztmm004 TYPE TABLE OF zztmm004.

    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

    ls_req = i_req-data.

    "新增校验，防止重复过账
    IF ls_req-head-bill_code IS NOT INITIAL.
      SELECT COUNT( * )
        FROM i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS a
        JOIN i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS b ON a~materialdocumentyear = b~materialdocumentyear
                                                                AND a~materialdocument = b~materialdocument
       WHERE a~referencedocument = @ls_req-head-bill_code
         AND b~goodsmovementtype = @ls_req-head-fyd_def_001.
      IF sy-subrc = 0.
        o_resp-msgty  = 'E'.
        o_resp-msgtx  = '该单据已过账，请不要重复提交'.
        RETURN.
      ENDIF.
    ENDIF.

    CLEAR: ls_data, lt_serialnumbers, ls_ztmm003, lt_ztmm004.

    ls_data-documentdate = zzcl_comm_tool=>date2iso( ls_req-head-cdate ).
    ls_data-postingdate = zzcl_comm_tool=>date2iso( ls_req-head-budat ).
    ls_data-referencedocument = ls_req-head-bill_code.

    CASE ls_req-head-fyd_def_001.
      WHEN '101' OR '102' OR '161'. " 采购入库 生产入库 采购退货
        ls_data-goodsmovementcode = '01'.
      WHEN '201' OR '202'. " 成本中心领料/冲销
        ls_data-goodsmovementcode = '03'.
      WHEN '711' OR '712'. " 盘盈/盘亏
        ls_data-goodsmovementcode = '03'.
      WHEN '551' OR '552'. " 报废/冲销
        ls_data-goodsmovementcode = '03'.
      WHEN '261'. " 副产品收货.
        ls_data-goodsmovementcode = '03'.
      WHEN '531'. " 生产订单投料
        ls_data-goodsmovementcode = '05'.
      WHEN '262' OR '532'.
        ls_data-goodsmovementcode = '03'.
      WHEN '311'. " 库存调拨
        ls_data-goodsmovementcode = '04'.
      WHEN '309'. " 物料转物料
        ls_data-goodsmovementcode = '04'.
      WHEN '122'. " 原采购退货
        ls_data-goodsmovementcode = '01'.
      WHEN '221' OR '222'.  "库存中的项目消耗/冲销
        ls_data-goodsmovementcode = '03'.
    ENDCASE.

    IF ls_req-head-fyd_def_001 BETWEEN 'Z21' AND 'Z38'.
      ls_data-goodsmovementcode = '03'.
    ENDIF.

    LOOP AT ls_req-item INTO DATA(ls_item).

      IF ls_req-head-zrel_flag <> '0'.
        IF ls_req-head-rel_bill_code IS INITIAL OR ls_item-rel_bill_itemcode IS INITIAL.
          o_resp-msgty  = 'E'.
          o_resp-msgtx  = '请填写上游系统关联单号'.
          RETURN.
        ENDIF.
      ENDIF.

      APPEND VALUE #( serialnumber = ls_item-serialnumbers ) TO lt_serialnumbers.

      APPEND VALUE #( material                   = ls_item-flj_def_001
                      materialdocumentline       = ls_item-line_no
                      materialdocumentitemtext   = |{ ls_req-head-rel_bill_code }:{ ls_item-rel_bill_itemcode }|
                      quantityinentryunit        = ls_item-fsq_def_001
                      storagelocation            = ls_item-location
                      plant                      = ls_item-factory_code
*                      specialstockidfgwbselement = ls_item-wbs_element
                      wbselement                 = ls_item-wbs_element
                      costcenter                 = ls_item-fcb_def_001
                      goodsmovementtype          = ls_req-head-fyd_def_001
                      to_serialnumbers           = lt_serialnumbers
                 ) TO ls_data-to_materialdocumentitem.
    ENDLOOP.

*&---接口http 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader?sap-language=zh|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).

        lo_request->set_content_type( 'application/json' ).
        "传入数据转JSON
        lv_json = /ui2/cl_json=>serialize(
              data          = ls_data
              compress      = abap_true
              name_mappings = gt_mapping ).

        lo_request->set_text( lv_json ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code = '201'.
          TYPES: BEGIN OF ty_heads,
                   materialdocument     TYPE string,
                   materialdocumentyear TYPE string,
                 END OF ty_heads.
          TYPES: BEGIN OF ty_ress,
                   d TYPE ty_heads,
                 END OF  ty_ress.
          DATA ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_res
                                     CHANGING  data = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          o_resp-sapnum = ls_ress-d-materialdocument.

          SELECT materialdocumentyear,
                 materialdocument,
                 materialdocumentitem,
                 materialdocumentline,
                 materialdocumentitemtext,
                 material,
                 quantityinentryunit,
                 storagelocation,
                 specialstockidfgwbselement,
                 plant,
                 costcenter
           FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
          WHERE materialdocument = @ls_ress-d-materialdocument
            AND materialdocumentyear = @ls_ress-d-materialdocumentyear
            AND isautomaticallycreated = ''
           INTO TABLE @DATA(lt_doc).
          IF sy-subrc = 0.
            SORT ls_req-item BY flj_def_001.

            LOOP AT lt_doc INTO DATA(ls_doc).
              APPEND VALUE #( referencedocument      = ls_req-head-bill_code
                              materialdocumentline   = ls_doc-materialdocumentline
                              materialdocument       = ls_doc-materialdocument
                              materialdocumentitemid = ls_doc-materialdocumentitem
                              materialdocumentyear   = ls_doc-materialdocumentyear
                         ) TO o_resp-msgdetail.

              READ TABLE ls_req-item INTO ls_item WITH KEY flj_def_001 = ls_doc-material BINARY SEARCH.
              IF sy-subrc = 0.
                APPEND VALUE #( materialdocumentyear   = ls_doc-materialdocumentyear
                                materialdocument       = ls_doc-materialdocument
                                materialdocumentitemid = ls_doc-materialdocumentitem
                                bill_code              = ls_req-head-bill_code
                                line_no                = ls_doc-materialdocumentline
                                rel_bill_itemcode      = ls_doc-materialdocumentitemtext
                                flj_def_001            = ls_doc-material
                                fsq_def_001            = ls_doc-quantityinentryunit
                                location               = ls_doc-storagelocation
                                wbs_element            = ls_doc-specialstockidfgwbselement
                                serialnumbers          = ls_item-serialnumbers
                                factory_code           = ls_doc-plant
                                fcb_def_001            = ls_doc-materialdocumentyear
                                status                 = ls_item-status
                           ) TO lt_ztmm004.
              ENDIF.
            ENDLOOP.
          ENDIF.

          "存表
          ls_ztmm003-materialdocumentyear = ls_ress-d-materialdocumentyear.
          ls_ztmm003-materialdocument     = ls_ress-d-materialdocument.
          ls_ztmm003-cdate                = ls_req-head-cdate.
          ls_ztmm003-budat                = ls_req-head-budat.
          ls_ztmm003-bill_code            = ls_req-head-bill_code.
          ls_ztmm003-rel_bill_code        = ls_req-head-rel_bill_code.
          ls_ztmm003-zrel_flag            = ls_req-head-zrel_flag.
          ls_ztmm003-fyd_def_001          = ls_req-head-fyd_def_001.
          ls_ztmm003-zrsv01               = ls_req-head-zrsv01.
          ls_ztmm003-zrsv02               = ls_req-head-zrsv02.
          ls_ztmm003-zrsv03               = ls_req-head-zrsv03.
          ls_ztmm003-zrsv04               = ls_req-head-zrsv04.
          ls_ztmm003-zrsv05               = ls_req-head-zrsv05.
          GET TIME STAMP FIELD ls_ztmm003-createdatetime.

          MODIFY zztmm003 FROM @ls_ztmm003.
          MODIFY zztmm004 FROM TABLE @lt_ztmm004.

        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
            o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
          ENDLOOP.

        ENDIF.

        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
    ( abap = 'MaterialDocumentYear' json = 'MaterialDocumentYear' )
    ( abap = 'MaterialDocument' json = 'MaterialDocument' )
    ( abap = 'InventoryTransactionType' json = 'InventoryTransactionType' )
    ( abap = 'DocumentDate' json = 'DocumentDate' )
    ( abap = 'PostingDate' json = 'PostingDate' )
    ( abap = 'CreationDate' json = 'CreationDate' )
    ( abap = 'CreationTime' json = 'CreationTime' )
    ( abap = 'CreatedByUser' json = 'CreatedByUser' )
    ( abap = 'MaterialDocumentHeaderText' json = 'MaterialDocumentHeaderText' )
    ( abap = 'ReferenceDocument' json = 'ReferenceDocument' )
    ( abap = 'VersionForPrintingSlip' json = 'VersionForPrintingSlip' )
    ( abap = 'ManualPrintIsTriggered' json = 'ManualPrintIsTriggered' )
    ( abap = 'CtrlPostgForExtWhseMgmtSyst' json = 'CtrlPostgForExtWhseMgmtSyst' )
    ( abap = 'GoodsMovementCode' json = 'GoodsMovementCode' )
    ( abap = 'MaterialDocumentItem' json = 'MaterialDocumentItem' )
    ( abap = 'Material' json = 'Material' )
    ( abap = 'Plant' json = 'Plant' )
    ( abap = 'StorageLocation' json = 'StorageLocation' )
    ( abap = 'Batch' json = 'Batch' )
    ( abap = 'BatchBySupplier' json = 'BatchBySupplier' )
    ( abap = 'GoodsMovementType' json = 'GoodsMovementType' )
    ( abap = 'InventoryStockType' json = 'InventoryStockType' )
    ( abap = 'InventoryValuationType' json = 'InventoryValuationType' )
    ( abap = 'InventorySpecialStockType' json = 'InventorySpecialStockType' )
    ( abap = 'Supplier' json = 'Supplier' )
    ( abap = 'Customer' json = 'Customer' )
    ( abap = 'SalesOrder' json = 'SalesOrder' )
    ( abap = 'SalesOrderItem' json = 'SalesOrderItem' )
    ( abap = 'SalesOrderScheduleLine' json = 'SalesOrderScheduleLine' )
    ( abap = 'PurchaseOrder' json = 'PurchaseOrder' )
    ( abap = 'PurchaseOrderItem' json = 'PurchaseOrderItem' )
    ( abap = 'WBSElement' json = 'WBSElement' )
    ( abap = 'ManufacturingOrder' json = 'ManufacturingOrder' )
    ( abap = 'ManufacturingOrderItem' json = 'ManufacturingOrderItem' )
    ( abap = 'GoodsMovementRefDocType' json = 'GoodsMovementRefDocType' )
    ( abap = 'GoodsMovementReasonCode' json = 'GoodsMovementReasonCode' )
    ( abap = 'Delivery' json = 'Delivery' )
    ( abap = 'DeliveryItem' json = 'DeliveryItem' )
    ( abap = 'AccountAssignmentCategory' json = 'AccountAssignmentCategory' )
    ( abap = 'CostCenter' json = 'CostCenter' )
    ( abap = 'ControllingArea' json = 'ControllingArea' )
    ( abap = 'CostObject' json = 'CostObject' )
    ( abap = 'GLAccount' json = 'GLAccount' )
    ( abap = 'FunctionalArea' json = 'FunctionalArea' )
    ( abap = 'ProfitabilitySegment' json = 'ProfitabilitySegment' )
    ( abap = 'ProfitCenter' json = 'ProfitCenter' )
    ( abap = 'MasterFixedAsset' json = 'MasterFixedAsset' )
    ( abap = 'FixedAsset' json = 'FixedAsset' )
    ( abap = 'MaterialBaseUnit' json = 'MaterialBaseUnit' )
    ( abap = 'QuantityInBaseUnit' json = 'QuantityInBaseUnit' )
    ( abap = 'EntryUnit' json = 'EntryUnit' )
    ( abap = 'QuantityInEntryUnit' json = 'QuantityInEntryUnit' )
    ( abap = 'CompanyCodeCurrency' json = 'CompanyCodeCurrency' )
    ( abap = 'GdsMvtExtAmtInCoCodeCrcy' json = 'GdsMvtExtAmtInCoCodeCrcy' )
    ( abap = 'SlsPrcAmtInclVATInCoCodeCrcy' json = 'SlsPrcAmtInclVATInCoCodeCrcy' )
    ( abap = 'FiscalYear' json = 'FiscalYear' )
    ( abap = 'FiscalYearPeriod' json = 'FiscalYearPeriod' )
    ( abap = 'FiscalYearVariant' json = 'FiscalYearVariant' )
    ( abap = 'IssgOrRcvgMaterial' json = 'IssgOrRcvgMaterial' )
    ( abap = 'IssgOrRcvgBatch' json = 'IssgOrRcvgBatch' )
    ( abap = 'IssuingOrReceivingPlant' json = 'IssuingOrReceivingPlant' )
    ( abap = 'IssuingOrReceivingStorageLoc' json = 'IssuingOrReceivingStorageLoc' )
    ( abap = 'IssuingOrReceivingStockType' json = 'IssuingOrReceivingStockType' )
    ( abap = 'IssgOrRcvgSpclStockInd' json = 'IssgOrRcvgSpclStockInd' )
    ( abap = 'IssuingOrReceivingValType' json = 'IssuingOrReceivingValType' )
    ( abap = 'IsCompletelyDelivered' json = 'IsCompletelyDelivered' )
    ( abap = 'MaterialDocumentItemText' json = 'MaterialDocumentItemText' )
    ( abap = 'GoodsRecipientName' json = 'GoodsRecipientName' )
    ( abap = 'UnloadingPointName' json = 'UnloadingPointName' )
    ( abap = 'ShelfLifeExpirationDate' json = 'ShelfLifeExpirationDate' )
    ( abap = 'ManufactureDate' json = 'ManufactureDate' )
    ( abap = 'SerialNumbersAreCreatedAutomly' json = 'SerialNumbersAreCreatedAutomly' )
    ( abap = 'Reservation' json = 'Reservation' )
    ( abap = 'ReservationItem' json = 'ReservationItem' )
    ( abap = 'ReservationItemRecordType' json = 'ReservationItemRecordType' )
    ( abap = 'ReservationIsFinallyIssued' json = 'ReservationIsFinallyIssued' )
    ( abap = 'SpecialStockIdfgSalesOrder' json = 'SpecialStockIdfgSalesOrder' )
    ( abap = 'SpecialStockIdfgSalesOrderItem' json = 'SpecialStockIdfgSalesOrderItem' )
    ( abap = 'SpecialStockIdfgWBSElement' json = 'SpecialStockIdfgWBSElement' )
    ( abap = 'IsAutomaticallyCreated' json = 'IsAutomaticallyCreated' )
    ( abap = 'MaterialDocumentLine' json = 'MaterialDocumentLine' )
    ( abap = 'MaterialDocumentParentLine' json = 'MaterialDocumentParentLine' )
    ( abap = 'HierarchyNodeLevel' json = 'HierarchyNodeLevel' )
    ( abap = 'GoodsMovementIsCancelled' json = 'GoodsMovementIsCancelled' )
    ( abap = 'ReversedMaterialDocumentYear' json = 'ReversedMaterialDocumentYear' )
    ( abap = 'ReversedMaterialDocument' json = 'ReversedMaterialDocument' )
    ( abap = 'ReversedMaterialDocumentItem' json = 'ReversedMaterialDocumentItem' )
    ( abap = 'ReferenceDocumentFiscalYear' json = 'ReferenceDocumentFiscalYear' )
    ( abap = 'InvtryMgmtRefDocumentItem' json = 'InvtryMgmtRefDocumentItem' )
    ( abap = 'InvtryMgmtReferenceDocument' json = 'InvtryMgmtReferenceDocument' )
    ( abap = 'MaterialDocumentPostingType' json = 'MaterialDocumentPostingType' )
    ( abap = 'InventoryUsabilityCode' json = 'InventoryUsabilityCode' )
    ( abap = 'EWMWarehouse' json = 'EWMWarehouse' )
    ( abap = 'EWMStorageBin' json = 'EWMStorageBin' )
    ( abap = 'DebitCreditCode' json = 'DebitCreditCode' )
    ( abap = 'to_SerialNumbers' json = 'to_SerialNumbers' )
    ( abap = 'SerialNumber' json = 'SerialNumber' )
    ( abap = 'to_MaterialDocumentItem'      json = 'to_MaterialDocumentItem'     )
    ( abap = 'results'                      json = 'results'                     )

    ).

  ENDMETHOD.
ENDCLASS.
