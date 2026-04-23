CLASS zzcl_api_mm001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_component,
            purchaseorder       TYPE string,
            purchaseorderitem   TYPE string,
            scheduleline        TYPE string,
            reservationitem     TYPE string,
            recordtype          TYPE string, "记录类型
            quantityinentryunit TYPE string,
            material            TYPE string,
          END OF ty_component,
          BEGIN OF tty_component,
            results TYPE TABLE OF ty_component WITH EMPTY KEY,
          END OF tty_component.

    TYPES:BEGIN OF ty_account,
            purchaseorder     TYPE string,
            purchaseorderitem TYPE string,
            masterfixedasset  TYPE string,
            fixedasset        TYPE string,
            costcenter        TYPE string,
          END OF ty_account,
          BEGIN OF tty_account,
            results TYPE TABLE OF ty_account WITH EMPTY KEY,
          END OF tty_account.

    TYPES:BEGIN OF ty_schedule,
            purchasingdocument         TYPE string,
            purchasingdocumentitem     TYPE string,
            scheduleline               TYPE string,
            delivdatecategory          TYPE string, "交货日期的类别
            schedulelinedeliverydate   TYPE string, "交货日期
            to_subcontractingcomponent TYPE tty_component,
          END OF ty_schedule,
          BEGIN OF tty_schedule,
            results TYPE TABLE OF ty_schedule WITH EMPTY KEY,
          END OF tty_schedule.

    TYPES:BEGIN OF ty_pricing,
            purchaseorder         TYPE string,
            purchaseorderitem     TYPE string,
            conditiontype         TYPE string,  "条件类型
            conditionratevalue    TYPE string,
            conditioncurrency     TYPE string,
            conditionquantityunit TYPE string,
          END OF ty_pricing,
          BEGIN OF tty_pricing,
            results TYPE TABLE OF ty_pricing WITH EMPTY KEY,
          END OF tty_pricing.

    TYPES:BEGIN OF ty_item,
            purchaseorder                  TYPE string,
            purchaseorderitem              TYPE string,
            yy1_purchaseorderitem_pdi      TYPE string,
            accountassignmentcategory      TYPE string,
            purchaseorderitemcategory      TYPE string,
            documentcurrency               TYPE string,
            materialgroup                  TYPE string,
            material                       TYPE string,
            manufacturermaterial           TYPE string,
            purchaseorderitemtext          TYPE string,
            orderquantity                  TYPE string,
            purchaseorderquantityunit      TYPE string,
            taxcode                        TYPE string,
            plant                          TYPE string,
            purchaserequisition            TYPE string,
            purchaserequisitionitem        TYPE string,
            requisitionername              TYPE string,
            goodsreceiptisexpected         TYPE abap_bool,
            invoiceisexpected              TYPE abap_bool,
            invoiceisgoodsreceiptbased     TYPE abap_bool,
            unlimitedoverdeliveryisallowed TYPE abap_bool,
            isreturnsitem                  TYPE abap_bool,
*          DiscountInKindEligibility      TYPE abap_bool,
            purchasingitemisfreeofcharge   TYPE abap_bool,
            netpricequantity               TYPE string,
            orderpriceunit                 TYPE string,
            netpriceamount                 TYPE string,
            iscompletelydelivered          TYPE abap_bool,
            supplierconfirmationcontrolkey TYPE string,
            overdelivtolrtdlmtratioinpct   TYPE string,
            underdelivtolrtdlmtratioinpct  TYPE string,
            costcenter                     TYPE string,
            masterfixedasset               TYPE string,
            fixedasset                     TYPE string,
            to_accountassignment           TYPE tty_account,
            to_purchaseorderpricingelement TYPE tty_pricing,
            to_scheduleline                TYPE tty_schedule,
          END OF ty_item,
          BEGIN OF tty_item,
            results TYPE TABLE OF ty_item WITH EMPTY KEY,
          END OF tty_item,
          BEGIN OF ty_data,
            purchaseorder              TYPE ebeln,
            purchaseordertype          TYPE string,
            purchaseorderdate          TYPE string,
            companycode                TYPE string,
            purchasingorganization     TYPE string,
            purchasinggroup            TYPE string,
            supplier                   TYPE lifnr,
            paymentterms               TYPE string,
            correspncexternalreference TYPE string,
            yy1_refdocno_pdh           TYPE string,
            to_purchaseorderitem       TYPE tty_item,
          END OF ty_data.
    TYPES:BEGIN OF ty_item_d,
            accountassignmentcategory      TYPE string,
            purchaseorderitemcategory      TYPE string,
            documentcurrency               TYPE string,
            materialgroup                  TYPE string,
            manufacturermaterial           TYPE string,
            purchaseorderitemtext          TYPE string,
            orderquantity                  TYPE string,
            purchaseorderquantityunit      TYPE string,
            taxcode                        TYPE string,
            plant                          TYPE string,
            purchaserequisition            TYPE string,
            purchaserequisitionitem        TYPE string,
            requisitionername              TYPE string,
            goodsreceiptisexpected         TYPE abap_bool,
            invoiceisexpected              TYPE abap_bool,
            invoiceisgoodsreceiptbased     TYPE abap_bool,
            unlimitedoverdeliveryisallowed TYPE abap_bool,
            isreturnsitem                  TYPE abap_bool,
            purchasingitemisfreeofcharge   TYPE abap_bool,
            netpricequantity               TYPE string,
            orderpriceunit                 TYPE string,
            netpriceamount                 TYPE string,
            iscompletelydelivered          TYPE abap_bool,
            supplierconfirmationcontrolkey TYPE string,
            overdelivtolrtdlmtratioinpct   TYPE string,
            underdelivtolrtdlmtratioinpct  TYPE string,
            costcenter                     TYPE string,
            masterfixedasset               TYPE string,
            fixedasset                     TYPE string,
            discountinkindeligibility      TYPE string,
          END OF ty_item_d.
    TYPES:BEGIN OF ty_item_change,
            d TYPE ty_item_d,
          END OF ty_item_change,

          BEGIN OF ty_data_change,
            purchaseorder          TYPE ebeln,
            purchaseordertype      TYPE string,
            purchaseorderdate      TYPE string,
            companycode            TYPE string,
            purchasingorganization TYPE string,
            purchasinggroup        TYPE string,
            supplier               TYPE lifnr,
            paymentterms           TYPE string,
            iscompletelydelivered  TYPE abap_bool,
            deleteflag             TYPE string,
          END OF ty_data_change.


    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gv_mode(1).

    DATA:lv_text TYPE string.
    DATA:lv_text1 TYPE string.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_mmi001_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM001 IMPLEMENTATION.


  METHOD inbound.


    DATA:ls_data        TYPE ty_data,
         ls_account     TYPE ty_account,
         ls_schedule    TYPE ty_schedule,
         ls_item_change TYPE ty_item_change,
         ls_item        TYPE ty_item,
         lt_item        TYPE TABLE OF ty_item.
    DATA:lv_json TYPE string.

    DATA(ls_req) = i_req-data.

    IF ls_req-head-purchaseorder IS NOT INITIAL.
      SELECT SINGLE COUNT(*)
        FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS
       WHERE purchaseorder = @ls_req-head-purchaseorder.
      IF sy-subrc = 0.
        gv_mode = 'U'.
      ELSE.
        gv_mode = 'I'.
      ENDIF.
    ELSE.
      gv_mode = 'I'.
    ENDIF.

    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    IF gv_mode = 'I'.
      "PO 抬头
      ls_data-purchaseorder = ls_req-head-purchaseorder.
      ls_data-purchaseordertype = ls_req-head-purchaseordertype.
      ls_data-purchaseorderdate = zzcl_comm_tool=>date2iso( ls_req-head-purchaseorderdate ).
      ls_data-companycode = ls_req-head-companycode.
      ls_data-purchasingorganization = ls_req-head-purchasingorganization.
      ls_data-purchasinggroup = ls_req-head-purchasinggroup.
      ls_data-supplier = ls_req-head-supplier.
      ls_data-paymentterms = ls_req-head-paymentterms.
      ls_data-yy1_refdocno_pdh = ls_req-head-correspncexternalreference.

      "PO 行
      CLEAR:lt_item,lt_item[].
      LOOP AT ls_req-item INTO DATA(ls_tmp_item).
        CLEAR:ls_item.
        ls_item-purchaseorder                    = ls_req-head-purchaseorder.
        ls_item-purchaseorderitem                = ls_tmp_item-purchaseorderitem.
        ls_item-yy1_purchaseorderitem_pdi        = ls_tmp_item-purchaseorderitem.
        ls_item-accountassignmentcategory        = ls_tmp_item-accountassignmentcategory.
        ls_item-purchaseorderitemcategory        = ls_tmp_item-purchaseorderitemcategory.
        ls_item-documentcurrency                 = ls_tmp_item-documentcurrency.
        ls_item-material                         = ls_tmp_item-material.
        ls_item-materialgroup                    = ls_tmp_item-materialgroup.
        ls_item-manufacturermaterial             = ls_tmp_item-manufacturermaterial.
        ls_item-purchaseorderitemtext            = ls_tmp_item-purchaseorderitemtext.
        ls_item-orderquantity                    = ls_tmp_item-orderquantity.
        ls_item-purchaseorderquantityunit        = ls_tmp_item-purchaseorderquantityunit.
        IF  ls_item-purchaseorderquantityunit IS INITIAL.
          SELECT SINGLE b~unitofmeasurecommercialname
           FROM i_product WITH PRIVILEGED ACCESS AS a
           JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS b ON b~unitofmeasure = a~baseunit
                                                               AND b~language = 1
         WHERE a~product = @ls_tmp_item-material
           INTO @ls_item-purchaseorderquantityunit .
        ENDIF.
        ls_item-taxcode                          = ls_tmp_item-taxcode.
        ls_item-plant                            = ls_tmp_item-plant.
        ls_item-purchaserequisition              = ls_tmp_item-purchaserequisition.
        ls_item-purchaserequisitionitem          = ls_tmp_item-purchaserequisitionitem.
        ls_item-goodsreceiptisexpected           = ls_tmp_item-goodsreceiptisexpected.
        ls_item-invoiceisexpected                = ls_tmp_item-invoiceisexpected .

        ls_item-invoiceisgoodsreceiptbased       = ls_tmp_item-invoiceisgoodsreceiptbased .
        ls_item-unlimitedoverdeliveryisallowed   = ls_tmp_item-unlimitedoverdeliveryisallowed .
        ls_item-isreturnsitem                    = ls_tmp_item-isreturnsitem.
        ls_item-netpricequantity                 = ls_tmp_item-netpricequantity.
        ls_item-orderpriceunit                   = ls_tmp_item-orderpriceunit.
        ls_item-netpriceamount                   = ls_tmp_item-netpriceamount.
        "ls_item-purchasingitemisfreeofcharge   = ls_tmp_item-purchasingitemisfreeofcharge.
        "add by handtqh 20260209
        CASE ls_tmp_item-purchasingitemisfreeofcharge.
          WHEN 'X'.
            ls_item-purchasingitemisfreeofcharge                    = abap_true.
          WHEN 'NULL' OR 'null'.
            ls_item-purchasingitemisfreeofcharge                    = abap_undefined.
            CLEAR: ls_item-netpriceamount  .
          WHEN ''.
            ls_item-purchasingitemisfreeofcharge                    = abap_false.
            CLEAR: ls_item-netpriceamount  .
        ENDCASE.

        ls_item-requisitionername                = ls_tmp_item-requisitionername.
        ls_item-iscompletelydelivered            = ls_tmp_item-iscompletelydelivered.
        ls_item-supplierconfirmationcontrolkey   = ls_tmp_item-supplierconfirmationcontrolkey.
        ls_item-overdelivtolrtdlmtratioinpct     = ls_tmp_item-overdelivtolrtdlmtratioinpct.
        ls_item-underdelivtolrtdlmtratioinpct    = ls_tmp_item-underdelivtolrtdlmtratioinpct.
*
        IF ls_tmp_item-accountassignmentcategory IS NOT INITIAL.
*          ls_account-purchaseorder                 = ls_tmp-req-head-purchaseorder.
          ls_account-purchaseorderitem             = ls_tmp_item-purchaseorderitem.
*          ls_account-costcenter                    = ls_tmp_item-costcenter.
          ls_account-masterfixedasset              = ls_tmp_item-masterfixedasset.
          ls_account-fixedasset                    = ls_tmp_item-fixedasset.
          APPEND ls_account TO ls_item-to_accountassignment-results.
          CLEAR ls_account.
        ENDIF.

        IF ls_tmp_item-schedulelinedeliverydate IS NOT INITIAL.
          CLEAR: ls_schedule.
          ls_schedule-purchasingdocumentitem = ls_tmp_item-purchaseorderitem.
          ls_schedule-scheduleline = '1'.
          ls_schedule-schedulelinedeliverydate  = zzcl_comm_tool=>date2iso( ls_tmp_item-schedulelinedeliverydate ).
          APPEND ls_schedule TO ls_item-to_scheduleline-results.
        ENDIF.

        APPEND ls_item TO lt_item.
        CLEAR ls_item.

      ENDLOOP."ADD BY HANDTQH 20260204 将ENDLOOP移动到这个地方

      ls_data-to_purchaseorderitem-results = lt_item."ADD BY HANDTQH 20260204 将行项目赋值到API结构中

*&---接口http 链接调用
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_uri_path) = |/API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder?sap-language=zh|.
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
            TYPES:BEGIN OF ty_heads,
                    purchaseorder     TYPE string,
                    purchaseorderitem TYPE string,
                  END OF ty_heads,
                  BEGIN OF ty_ress,
                    d TYPE ty_heads,
                  END OF  ty_ress.
            DATA:ls_ress TYPE ty_ress.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_ress ).

            o_resp-msgty  = 'S'.
            o_resp-msgtx  = 'success'.
            o_resp-sapnum = ls_ress-d-purchaseorder.
          ELSE.
            DATA:ls_rese TYPE zzs_odata_fail.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_rese ).
            o_resp-msgty = 'E'.
            LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails)  WHERE severity = 'error'.
              o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
            ENDLOOP.
            IF  o_resp-msgtx  IS INITIAL.
              o_resp-msgtx = ls_rese-error-message-value.
            ENDIF.


          ENDIF.
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          RETURN.
      ENDTRY.

    ENDIF.


    IF  gv_mode = 'U'.

      DATA: lv_method TYPE if_web_http_client=>method .
      DATA: lv_posnr TYPE ebelp.
*行项目修改
      LOOP AT ls_req-item INTO ls_tmp_item.
        CLEAR:ls_item_change.
        MOVE-CORRESPONDING ls_tmp_item TO ls_item_change-d.

        CASE ls_tmp_item-iscompletelydelivered.
          WHEN 'X'.
            ls_item_change-d-iscompletelydelivered                    = abap_true.
          WHEN 'NULL' OR 'null'.
            ls_item_change-d-iscompletelydelivered                    = abap_undefined.
          WHEN ''.
            ls_item_change-d-iscompletelydelivered                    = abap_false.
        ENDCASE.

        ls_item_change-d-accountassignmentcategory  = ls_tmp_item-accountassignmentcategory.
        ls_item_change-d-purchaseorderitemcategory  = ls_tmp_item-purchaseorderitemcategory.
        ls_item_change-d-materialgroup              = ls_tmp_item-materialgroup.
        ls_item_change-d-manufacturermaterial       = ls_tmp_item-manufacturermaterial .
        ls_item_change-d-purchaseorderitemtext      = ls_tmp_item-purchaseorderitemtext.
        ls_item_change-d-orderquantity              = ls_tmp_item-orderquantity .
        ls_item_change-d-purchaseorderquantityunit  = ls_tmp_item-purchaseorderquantityunit.
        ls_item_change-d-taxcode                    = ls_tmp_item-taxcode.
        ls_item_change-d-plant                      = ls_tmp_item-plant .
        ls_item_change-d-purchaserequisition        = ls_tmp_item-purchaserequisition .
        ls_item_change-d-purchaserequisitionitem    = ls_tmp_item-purchaserequisitionitem .
        ls_item_change-d-requisitionername          = ls_tmp_item-requisitionername .
        ls_item_change-d-goodsreceiptisexpected     = ls_tmp_item-goodsreceiptisexpected .
        ls_item_change-d-invoiceisexpected          = ls_tmp_item-invoiceisexpected .
        ls_item_change-d-invoiceisgoodsreceiptbased = ls_tmp_item-invoiceisgoodsreceiptbased  .
        ls_item_change-d-isreturnsitem              = ls_tmp_item-isreturnsitem  .
        ls_item_change-d-discountinkindeligibility  = ls_tmp_item-discountinkindeligibility .


        "add by handtqh 20260209
        CASE ls_tmp_item-purchasingitemisfreeofcharge.
          WHEN 'X'.
            ls_item_change-d-purchasingitemisfreeofcharge                    = abap_true.
          WHEN 'NULL' OR 'null'.
            ls_item_change-d-purchasingitemisfreeofcharge                    = abap_undefined.
          WHEN ''.
            ls_item_change-d-purchasingitemisfreeofcharge                    = abap_false.
        ENDCASE.
        "ls_item_change-d-purchasingitemisfreeofcharge   = ls_tmp_item-purchasingitemisfreeofcharge .
        ls_item_change-d-netpricequantity           = ls_tmp_item-netpricequantity .
        ls_item_change-d-orderpriceunit             = ls_tmp_item-orderpriceunit .
        ls_item_change-d-netpriceamount             = ls_tmp_item-netpriceamount .
        ls_item_change-d-supplierconfirmationcontrolkey  = ls_tmp_item-supplierconfirmationcontrolkey .
        ls_item_change-d-unlimitedoverdeliveryisallowed  = ls_tmp_item-unlimitedoverdeliveryisallowed .
        ls_item_change-d-overdelivtolrtdlmtratioinpct    = ls_tmp_item-underdelivtolrtdlmtratioinpct .
        ls_item_change-d-underdelivtolrtdlmtratioinpct   = ls_tmp_item-underdelivtolrtdlmtratioinpct.
        ls_item_change-d-costcenter                 = ls_tmp_item-costcenter  .
        ls_item_change-d-masterfixedasset           = ls_tmp_item-masterfixedasset .
        ls_item_change-d-fixedasset                 = ls_tmp_item-fixedasset .

        lv_posnr = ls_tmp_item-purchaseorderitem.

        "删除
        IF ls_tmp_item-deleteflag = abap_true.
          lv_method = if_web_http_client=>delete.
          CLEAR:ls_item_change.
        ELSE.
          lv_method = if_web_http_client=>patch.
        ENDIF.
*&---接口HTTP 链接调用
        TRY.
            DATA(lo_http_client_u) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
            DATA(lo_request_u) = lo_http_client_u->get_http_request(   ).
            lo_http_client_u->enable_path_prefix( ).

            DATA(lv_uri_path_u) = |/API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrderItem| &&
                                  |(PurchaseOrder='{ ls_req-head-purchaseorder }',| &&
                                  |PurchaseOrderItem='{ lv_posnr }')|.

            lo_request_u->set_uri_path( EXPORTING i_uri_path = lv_uri_path_u ).
            lo_request_u->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
            lo_http_client_u->set_csrf_token(  ).

            lo_request_u->set_content_type( 'application/json' ).
            "传入数据转JSON
            IF ls_tmp_item-deleteflag <> abap_true.
              lv_json = /ui2/cl_json=>serialize(
                    data          = ls_item_change
                    compress      = abap_true
                    name_mappings = gt_mapping ).
            ENDIF.
            lo_request_u->set_text( lv_json ).

*&---执行http post 方法
            DATA(lo_response_u) = lo_http_client_u->execute( lv_method ).
*&---获取http reponse 数据
            DATA(lv_res_u) = lo_response_u->get_text(  ).
*&---确定http 状态
            DATA(status_u) = lo_response_u->get_status( ).
            IF status_u-code = '204'.
              o_resp-msgty  = 'S'.
              "              o_resp-msgtx  = 'success'.
              o_resp-sapnum = ls_ress-d-purchaseorder.
              lv_text = |项目{ lv_posnr  }更新成功{ lv_text1 };|.
              o_resp-msgtx = o_resp-msgtx && lv_text.
            ELSE.
              DATA:ls_rese_u TYPE zzs_odata_fail.
              /ui2/cl_json=>deserialize( EXPORTING json  = lv_res_u
                                          CHANGING data  = ls_rese_u ).
              o_resp-msgty = 'E'.
              lv_text = |项目{ lv_posnr  }更新失败{ ls_rese_u-error-message-value };|.
              o_resp-msgtx = o_resp-msgtx && lv_text.
            ENDIF.
            o_resp-sapnum  = ls_req-head-purchaseorder.
          CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error_u).
            RETURN.
        ENDTRY.

        CLEAR ls_item_change.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
         ( abap = 'PurchaseOrder'                       json = 'PurchaseOrder'                )
         ( abap = 'PurchaseOrderType'                   json = 'PurchaseOrderType'                 )
         ( abap = 'PurchaseOrderDate'                   json = 'PurchaseOrderDate'                 )
         ( abap = 'CompanyCode'                         json = 'CompanyCode'                 )
         ( abap = 'PurchasingOrganization'              json = 'PurchasingOrganization'                 )
         ( abap = 'PurchasingGroup'                     json = 'PurchasingGroup'                 )
         ( abap = 'Supplier'                            json = 'Supplier'           )
         ( abap = 'CorrespncExternalReference'          json = 'CorrespncExternalReference'           )
         ( abap = 'PaymentTerms'                        json = 'PaymentTerms'           )
         ( abap = 'PurchaseOrderItem'                   json = 'PurchaseOrderItem'           )
         ( abap = 'PurchasingDocumentItem'              json = 'PurchasingDocumentItem'           )
         ( abap = 'to_PurchaseOrderItem'                json = 'to_PurchaseOrderItem'     )
         ( abap = 'to_ScheduleLine'                     json = 'to_ScheduleLine'     )
         ( abap = 'to_SubcontractingComponent'          json = 'to_SubcontractingComponent'     )
         ( abap = 'to_AccountAssignment'                json = 'to_AccountAssignment'     )
         ( abap = 'to_PurchaseOrderPricingElement'      json = 'to_PurchaseOrderPricingElement'   )
         ( abap = 'results'                             json = 'results'                     )
         ( abap = 'AccountAssignmentCategory'           json = 'AccountAssignmentCategory'     )
         ( abap = 'PurchaseOrderItemCategory'           json = 'PurchaseOrderItemCategory'           )
         ( abap = 'DocumentCurrency'                    json = 'DocumentCurrency'                    )
         ( abap = 'MaterialGroup'                       json = 'MaterialGroup'                )
         ( abap = 'Material'                            json = 'Material'               )
         ( abap = 'ManufacturerMaterial'                json = 'ManufacturerMaterial'               )
         ( abap = 'PurchaseOrderItemText'               json = 'PurchaseOrderItemText'           )
         ( abap = 'OrderQuantity'                       json = 'OrderQuantity'          )
         ( abap = 'PurchaseOrderQuantityUnit'           json = 'PurchaseOrderQuantityUnit'      )
         ( abap = 'TaxCode'                             json = 'TaxCode'                 )
         ( abap = 'Plant'                               json = 'Plant'             )
         ( abap = 'PurchaseRequisition'                 json = 'PurchaseRequisition'                  )
         ( abap = 'PurchaseRequisitionItem'             json = 'PurchaseRequisitionItem'                    )
         ( abap = 'RequisitionerName'                   json = 'RequisitionerName'                       )
         ( abap = 'GoodsReceiptIsExpected'              json = 'GoodsReceiptIsExpected'             )
         ( abap = 'InvoiceIsExpected'                   json = 'InvoiceIsExpected'                       )
         ( abap = 'InvoiceIsGoodsReceiptBased'          json = 'InvoiceIsGoodsReceiptBased'             )
         ( abap = 'IsReturnsItem'                       json = 'IsReturnsItem'                   )
         ( abap = 'DiscountInKindEligibility'           json = 'DiscountInKindEligibility'         )
         ( abap = 'NetPriceQuantity'                    json = 'NetPriceQuantity'          )
         ( abap = 'OrderPriceUnit'                      json = 'OrderPriceUnit'          )
         ( abap = 'NetPriceAmount'                      json = 'NetPriceAmount'     )
         ( abap = 'IsCompletelyDelivered'               json = 'IsCompletelyDelivered' )
         ( abap = 'SupplierConfirmationControlKey'      json = 'SupplierConfirmationControlKey'             )
         ( abap = 'UnlimitedOverdeliveryIsAllowed'      json = 'UnlimitedOverdeliveryIsAllowed'     )
         ( abap = 'OverdelivTolrtdLmtRatioInPct'        json = 'OverdelivTolrtdLmtRatioInPct' )
         ( abap = 'UnderdelivTolrtdLmtRatioInPct'       json = 'UnderdelivTolrtdLmtRatioInPct'    )
         ( abap = 'PurchasingItemIsFreeOfCharge'        json = 'PurchasingItemIsFreeOfCharge'    )
         ( abap = 'CostCenter'                          json = 'CostCenter' )
         ( abap = 'MasterFixedAsset'                    json = 'MasterFixedAsset' )
         ( abap = 'FixedAsset'                          json = 'FixedAsset' )
         ( abap = 'ConditionType'                       json = 'ConditionType'   )
         ( abap = 'ConditionRateValue'                  json = 'ConditionRateValue'   )
         ( abap = 'ConditionCurrency'                   json = 'ConditionCurrency'   )
         ( abap = 'ConditionQuantityUnit'               json = 'ConditionQuantityUnit'   )
         ( abap = 'd'                                   json = 'd'   )
         ( abap = 'ScheduleLineDeliveryDate'            json = 'ScheduleLineDeliveryDate'   )
         ( abap = 'ScheduleLine'                        json = 'ScheduleLine'   )
         ( abap = 'YY1_RefDocno_PDH'                    json = 'YY1_RefDocno_PDH'   )
         ( abap = 'YY1_PurchaseOrderItem_PDI'           json = 'YY1_PurchaseOrderItem_PDI'   )
                         ).
    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.

  ENDMETHOD.
ENDCLASS.
