CLASS zzcl_api_mm002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_serialnumbers,
            "            material                 TYPE string,
            serialnumber TYPE string,
            "            materialdocument         TYPE string,
            "            materialdocumentitem     TYPE string,
            "            materialdocumentyear     TYPE string,
            "            manufacturerserialnumber TYPE string,
            "            serialnumberisrecursive  TYPE string,
          END OF ty_serialnumbers,
          BEGIN OF tty_serialnumbers,
            results TYPE TABLE OF ty_serialnumbers WITH EMPTY KEY,
          END OF tty_serialnumbers,
          BEGIN OF ty_item,
            materialdocumentyear           TYPE string,
            materialdocument               TYPE string,
            materialdocumentitem           TYPE string,
            material                       TYPE matnr,
            plant                          TYPE string,
            storagelocation                TYPE string,
            batch                          TYPE string,
            batchbysupplier                TYPE string,
            goodsmovementtype              TYPE string,
            inventorystocktype             TYPE string,
            inventoryvaluationtype         TYPE string,
            inventoryspecialstocktype      TYPE string,
            supplier                       TYPE lifnr,
            customer                       TYPE kunnr,
            salesorder                     TYPE vbeln_va,
            salesorderitem                 TYPE string,
            salesorderscheduleline         TYPE string,
            purchaseorder                  TYPE ebeln,
            purchaseorderitem(5),
            wbselement                     TYPE string,
            manufacturingorder             TYPE aufnr,
            manufacturingorderitem         TYPE string,
            goodsmovementrefdoctype        TYPE string,
            goodsmovementreasoncode        TYPE string,
            delivery                       TYPE vbeln_vl,
            deliveryitem(6),
            accountassignmentcategory      TYPE string,
            costcenter                     TYPE string,
            controllingarea                TYPE string,
            costobject                     TYPE string,
            glaccount                      TYPE string,
            functionalarea                 TYPE string,
            profitabilitysegment           TYPE string,
            profitcenter                   TYPE string,
            masterfixedasset               TYPE string,
            fixedasset                     TYPE string,
            materialbaseunit               TYPE string,
            quantityinbaseunit             TYPE string,
            entryunit                      TYPE string,
            quantityinentryunit            TYPE string,
            companycodecurrency            TYPE string,
            gdsmvtextamtincocodecrcy       TYPE string,
            slsprcamtinclvatincocodecrcy   TYPE string,
            fiscalyear                     TYPE string,
            fiscalyearperiod               TYPE string,
            fiscalyearvariant              TYPE string,
            issgorrcvgmaterial             TYPE string,
            issgorrcvgbatch                TYPE string,
            issuingorreceivingplant        TYPE string,
            issuingorreceivingstorageloc   TYPE string,
            issuingorreceivingstocktype    TYPE string,
            issgorrcvgspclstockind         TYPE string,
            issuingorreceivingvaltype      TYPE string,
            iscompletelydelivered          TYPE string,
            materialdocumentitemtext       TYPE string,
            goodsrecipientname             TYPE string,
            unloadingpointname             TYPE string,
            shelflifeexpirationdate        TYPE string,
            manufacturedate                TYPE string,
            serialnumbersarecreatedautomly TYPE string,
            reservation                    TYPE string,
            reservationitem                TYPE string,
            reservationitemrecordtype      TYPE string,
            reservationisfinallyissued     TYPE string,
            specialstockidfgsalesorder     TYPE string,
            specialstockidfgsalesorderitem TYPE string,
            specialstockidfgwbselement     TYPE string,
            isautomaticallycreated         TYPE string,
            materialdocumentline           TYPE string,
            materialdocumentparentline     TYPE string,
            hierarchynodelevel             TYPE string,
            goodsmovementiscancelled       TYPE abap_bool,
            reversedmaterialdocumentyear   TYPE string,
            reversedmaterialdocument       TYPE string,
            reversedmaterialdocumentitem   TYPE string,
            referencedocumentfiscalyear    TYPE string,
            invtrymgmtrefdocumentitem      TYPE string,
            invtrymgmtreferencedocument    TYPE string,
            materialdocumentpostingtype    TYPE string,
            inventoryusabilitycode         TYPE string,
            ewmwarehouse                   TYPE string,
            ewmstoragebin                  TYPE string,
            debitcreditcode                TYPE string,
            to_serialnumbers               TYPE tty_serialnumbers,
          END OF ty_item,
          BEGIN OF tty_item,
            results TYPE TABLE OF ty_item WITH EMPTY KEY,
          END OF tty_item,
          BEGIN OF ty_data,
            materialdocumentyear        TYPE string,
            materialdocument            TYPE string,
            inventorytransactiontype    TYPE string,
            documentdate                TYPE string,
            postingdate                 TYPE string,
            creationdate                TYPE string,
            creationtime                TYPE string,
            createdbyuser               TYPE string,
            materialdocumentheadertext  TYPE string,
            referencedocument           TYPE string,
            versionforprintingslip      TYPE string,
            manualprintistriggered      TYPE string,
            ctrlpostgforextwhsemgmtsyst TYPE string,
            goodsmovementcode           TYPE string,
            isreversed                  TYPE string,
            to_materialdocumentitem     TYPE tty_item,
          END OF ty_data.


    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gs_tmp TYPE zzs_mmi002_in.

    DATA:gv_srv    TYPE string,
         gv_entity TYPE string.
    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_mmi002_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi002_resp.

    "更新交货单
    METHODS update_inb
      IMPORTING
        i_data TYPE ty_item OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi002_resp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm002 IMPLEMENTATION.


  METHOD inbound.
    DATA lv_json    TYPE string.
    DATA ls_data    TYPE ty_data.
    DATA ls_item    TYPE ty_item.
    DATA:ls_serialnumbers TYPE ty_serialnumbers.
    DATA:lt_serialnumbers TYPE TABLE OF ty_serialnumbers.

    gs_tmp = i_req-data.

    "新增校验，防止重复过账
    IF gs_tmp-head-referencedocument IS NOT INITIAL.
      READ TABLE gs_tmp-item INTO DATA(ls_item_check) INDEX 1.
      SELECT COUNT( * )
        FROM i_materialdocumentheader_2 WITH PRIVILEGED ACCESS AS a
        JOIN i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS b ON a~materialdocumentyear = b~materialdocumentyear
                                                                AND a~materialdocument = b~materialdocument
        JOIN @gs_tmp-item AS item ON b~goodsmovementtype  = item~goodsmovementtype
                                 AND b~materialdocumentitemtext  = item~materialdocumentline
       WHERE a~referencedocument = @gs_tmp-head-referencedocument.
      IF sy-subrc = 0.
        o_resp-msgty  = 'E'.
        o_resp-msgtx  = '该单据已过账，请不要重复提交'.
        RETURN.
      ENDIF.
    ENDIF.

    " 数据整合
    MOVE-CORRESPONDING gs_tmp-head TO ls_data.
    " 凭证日期
    ls_data-documentdate = zzcl_comm_tool=>date2iso( gs_tmp-head-documentdate ).
    " 过账日期
    ls_data-postingdate  = zzcl_comm_tool=>date2iso( gs_tmp-head-postingdate ).

    LOOP AT gs_tmp-item INTO DATA(ls_tmp).
      CLEAR ls_item.
      MOVE-CORRESPONDING ls_tmp TO ls_item.

      ls_item-manufacturingorder = |{ ls_item-manufacturingorder ALPHA = IN }|.
      ls_item-delivery           = |{ ls_item-delivery ALPHA = IN }|.
      ls_item-deliveryitem       = |{ ls_item-deliveryitem ALPHA = IN }|.
      ls_item-purchaseorder      = |{ ls_item-purchaseorder ALPHA = IN }|.
      ls_item-purchaseorderitem  = |{ ls_item-purchaseorderitem ALPHA = IN }|.
      ls_item-material = ls_item-material.
      " 移动类型确认 code
      CASE ls_item-goodsmovementtype.
        WHEN '101' OR '102' OR '161'. " 采购入库 生产入库 采购退货
          IF ls_item-delivery IS NOT INITIAL.
            ls_data-goodsmovementcode = '01'.
            ls_item-goodsmovementrefdoctype = 'B'.

            " 行项目
            SELECT SINGLE a~purchaseorder,
                          a~purchaseorderitem,
                          sddocumentcategory
              FROM i_deliverydocumentitem WITH
              PRIVILEGED ACCESS AS a
              WHERE deliverydocument     = @ls_item-delivery
                AND deliverydocumentitem = @ls_item-deliveryitem
              INTO @DATA(ls_deliverydocumentitem).

            IF ls_deliverydocumentitem-sddocumentcategory = '7'.
              IF ls_item-batch IS NOT INITIAL OR ls_item-shelflifeexpirationdate IS NOT INITIAL.
                " 更新交货单
                update_inb( EXPORTING i_data = ls_item
                            IMPORTING o_resp = o_resp ).
                IF o_resp-msgty = 'E'.
                  RETURN.
                ENDIF.
              ENDIF.
            ENDIF.

            " 采购订单写入
            IF ls_item-purchaseorder IS INITIAL.
              ls_item-purchaseorder     = ls_deliverydocumentitem-purchaseorder.
              ls_item-purchaseorderitem = ls_deliverydocumentitem-purchaseorderitem.
            ENDIF.
          ENDIF.

          IF ls_item-manufacturingorder IS NOT INITIAL.
            ls_data-goodsmovementcode = '02'.
            ls_item-goodsmovementrefdoctype = 'F'.
          ENDIF.

          IF ls_item-purchaseorder IS NOT INITIAL.
            ls_data-goodsmovementcode = '01'.
            ls_item-goodsmovementrefdoctype = 'B'.
          ENDIF.
        WHEN '201' OR '202'. " 成本中心领料/冲销
          ls_data-goodsmovementcode = '03'.
        WHEN '711' OR '712'. " 盘盈/盘亏
          ls_data-goodsmovementcode = '03'.
        WHEN '551'. " 报废
          ls_data-goodsmovementcode = '03'.
        WHEN '261'. " 副产品收货.
          DATA(lv_261_flag) = abap_true.

          ls_data-goodsmovementcode = '03'.
          " 获取预留
          IF ls_item-reservation IS INITIAL.
            SELECT SINGLE b~reservation,
                          b~reservationitem
              FROM i_reservationdocumentheader WITH PRIVILEGED ACCESS AS a
              JOIN i_reservationdocumentitem WITH
              PRIVILEGED ACCESS AS b ON a~reservation = b~reservation
              WHERE a~orderid = @ls_item-manufacturingorder
                AND b~product = @ls_item-material
                AND b~goodsmovementtype              = @ls_item-goodsmovementtype
                AND b~reservationitmismarkedfordeltn = ''
              INTO ( @ls_item-reservation, @ls_item-reservationitem ).
          ENDIF.

        WHEN '531'. " 生产订单投料
          ls_data-goodsmovementcode = '05'.
          " 获取预留
          IF ls_item-reservation IS INITIAL.
            SELECT SINGLE b~reservation,
                          b~reservationitem
              FROM i_reservationdocumentheader WITH PRIVILEGED ACCESS AS a
              JOIN i_reservationdocumentitem WITH
              PRIVILEGED ACCESS AS b ON a~reservation = b~reservation
              WHERE a~orderid           = @ls_item-manufacturingorder
                AND b~product           = @ls_item-material
                AND b~goodsmovementtype = @ls_item-goodsmovementtype
              INTO ( @ls_item-reservation, @ls_item-reservationitem ).
          ENDIF.
        WHEN '262' OR '532'.
          ls_data-goodsmovementcode = '03'.
        WHEN '311'. " 库存调拨
          ls_data-goodsmovementcode = '04'.

        WHEN '315'.
          ls_data-goodsmovementcode = '04'.
          IF ls_item-issuingorreceivingplant IS INITIAL .
            ls_item-issuingorreceivingplant = ls_item-plant.
          ENDIF.

        WHEN '309'. " 物料转物料
          ls_data-goodsmovementcode = '04'.
        WHEN '122'. " 原采购退货
          IF ls_item-delivery IS NOT INITIAL.
            ls_data-goodsmovementcode = '01'.
            ls_item-goodsmovementrefdoctype = 'B'.
          ENDIF.

      ENDCASE.
      " 订单单位
      IF ls_item-entryunit IS INITIAL.
        SELECT SINGLE baseunit FROM i_product WITH
          PRIVILEGED ACCESS
          WHERE product = @ls_item-material
          INTO @ls_item-entryunit.
      ENDIF.

      ls_item-manufacturedate         = zzcl_comm_tool=>date2iso( ls_item-manufacturedate ).
      ls_item-shelflifeexpirationdate = zzcl_comm_tool=>date2iso( ls_item-shelflifeexpirationdate ).

      "ADD BY HANDTQH 20260209


      CASE ls_item-goodsmovementiscancelled.
        WHEN 'X'.
          ls_item-goodsmovementiscancelled                    = abap_true.
        WHEN 'NULL' OR 'null'.
          ls_item-goodsmovementiscancelled                    = abap_undefined.
        WHEN ''.
          ls_item-goodsmovementiscancelled                    = abap_false.
      ENDCASE.

      ls_serialnumbers-serialnumber = ls_tmp-serialnumber.
      APPEND ls_serialnumbers TO ls_item-to_serialnumbers-results.

      CLEAR: ls_item-materialdocumentline.
      ls_item-materialdocumentitemtext = ls_tmp-materialdocumentline.

      APPEND ls_item TO ls_data-to_materialdocumentitem-results.
      CLEAR:ls_item-to_serialnumbers-results.
    ENDLOOP.

*&---接口HTTP 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    gv_srv = 'API_MATERIAL_DOCUMENT_SRV'.
    gv_entity = 'A_MaterialDocumentHeader'.
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request( ).
        lo_http_client->enable_path_prefix( ).
        DATA(lv_uri_path) = |/{ gv_srv }/{ gv_entity }| &&
                            |?sap-language={ gv_language }|.
        lo_request->set_uri_path( i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name  = 'Accept'
                                      i_value = 'application/json' ).
        lo_http_client->set_csrf_token( ).

        lo_request->set_content_type( 'application/json' ).
        " 传入数据转JSON
        lv_json = /ui2/cl_json=>serialize( data          = ls_data
                                           compress      = abap_true
                                           name_mappings = gt_mapping ).

        lo_request->set_text( lv_json ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text( ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        lo_http_client->close( ).
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

          SELECT materialdocumentitemtext AS materialdocumentline,
                      materialdocument,
                      materialdocumentitem,
                      materialdocumentyear
           FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS
          WHERE materialdocument = @ls_ress-d-materialdocument
            AND materialdocumentyear = @ls_ress-d-materialdocumentyear
            AND isautomaticallycreated = ''
           INTO TABLE @DATA(lt_doc).
          IF sy-subrc = 0.
            LOOP AT lt_doc INTO DATA(ls_doc).
              APPEND VALUE #(
                referencedocument = gs_tmp-head-referencedocument
                materialdocumentline = ls_doc-materialdocumentline
                materialdocument = ls_doc-materialdocument
                materialdocumentitemid = ls_doc-materialdocumentitem
                materialdocumentyear = ls_doc-materialdocumentyear
              ) TO o_resp-msgdetail.
            ENDLOOP.
          ENDIF.


          IF lv_261_flag = abap_true.
            WAIT UP TO '1' SECONDS.
          ENDIF.

        ELSE.
          DATA ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_res
                                     CHANGING  data = ls_rese ).

          o_resp-msgty = 'E'.
          LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetail).
            o_resp-msgtx = o_resp-msgtx && ls_errordetail-message.
          ENDLOOP.
          IF o_resp-msgtx IS INITIAL.
            o_resp-msgtx = ls_rese-error-message-value.
          ENDIF.

        ENDIF.
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lx_web_http_client_error->get_longtext( ).
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

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.
  ENDMETHOD.


  METHOD update_inb.
    TYPES: BEGIN OF ty_deliveryitem,
             batch                   TYPE string, " 批次
             shelflifeexpirationdate TYPE string, " 过期日期
           END OF ty_deliveryitem.
    TYPES: BEGIN OF ty_deliveryitems,
             d TYPE ty_deliveryitem,
           END OF ty_deliveryitems.

    DATA lt_mapping              TYPE /ui2/cl_json=>name_mappings.
    DATA lv_json                 TYPE string.
    DATA ls_item                 TYPE ty_deliveryitems.
    DATA lv_deliverydocument     TYPE i_deliverydocumentitem-deliverydocument.
    DATA lv_deliverydocumentitem TYPE i_deliverydocumentitem-deliverydocumentitem.

*&---导入结构JSON MAPPING
    lt_mapping = VALUE #( ( abap = 'd'                           json = 'd'                          )
                          ( abap = 'Batch'                       json = 'Batch'                      )
                          ( abap = 'ShelfLifeExpirationDate'     json = 'ShelfLifeExpirationDate'    ) ).

    lv_deliverydocument = i_data-delivery.
    lv_deliverydocumentitem = i_data-deliveryitem.

    ls_item-d-batch                   = i_data-batch.
    ls_item-d-shelflifeexpirationdate = zzcl_comm_tool=>date2iso( i_data-shelflifeexpirationdate ).

*&---接口HTTP 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    gv_srv = 'API_INBOUND_DELIVERY_SRV'.
    gv_entity = 'A_InbDeliveryItem'.
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request( ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/{ gv_srv };v=0002/{ gv_entity }|.
        lv_uri_path = lv_uri_path && |(DeliveryDocument='{ lv_deliverydocument }',| &&
                                     |DeliveryDocumentItem='{ lv_deliverydocumentitem }')| &&
                                     |?sap-language={ gv_language }|.

        lo_request->set_uri_path( i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name  = 'Accept'
                                      i_value = 'application/json' ).
        lo_request->set_header_field( i_name  = 'If-Match'
                                      i_value = '*' ).
        lo_http_client->set_csrf_token( ).

        lo_request->set_content_type( 'application/json' ).
        " 传入数据转JSON
        lv_json = /ui2/cl_json=>serialize( data          = ls_item
                                           compress      = abap_true
                                           name_mappings = lt_mapping ).

        lo_request->set_text( lv_json ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>patch ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text( ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code <> '204'.
          DATA ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json = lv_res
                                     CHANGING  data = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message-value.
        ENDIF.

        lo_http_client->close( ).
        FREE:lo_http_client,
              lo_request,
              lv_uri_path,
              lo_request.

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error). " TODO: variable is assigned but never used (ABAP cleaner)
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
