CLASS zzcl_api_mm017 DEFINITION
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
            glaccount         TYPE string,
            wbselement        TYPE string,
            controllingarea   TYPE string,
          END OF ty_account,
          BEGIN OF tty_account,
            results TYPE TABLE OF ty_account WITH EMPTY KEY,
          END OF tty_account,
          BEGIN OF ty_account_d,
            d TYPE ty_account,
          END OF ty_account_d.

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
            storagelocation                TYPE string,
            to_accountassignment           TYPE tty_account,
            to_purchaseorderpricingelement TYPE tty_pricing,
            to_scheduleline                TYPE tty_schedule,
          END OF ty_item,
          BEGIN OF tty_item,
            results TYPE TABLE OF ty_item WITH EMPTY KEY,
          END OF tty_item,
          BEGIN OF ty_purchaseorder,
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
          END OF ty_purchaseorder,
          BEGIN OF ty_item_d,
            d TYPE ty_item,
          END OF ty_item_d.

    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gv_mode(1).

    "接口传入结构
    TYPES:BEGIN OF ty_entry,
            logistics_orderno         TYPE string,
            logistics_rowno           TYPE string,
            purchase_row_no           TYPE string,
            part_id                   TYPE string,
            order_num                 TYPE string,
            part_unit                 TYPE string,
            depot_no                  TYPE string,
            plan_arrive_time          TYPE string,
            zkostl                    TYPE string,
            uda1                      TYPE string,
            uda2                      TYPE string,
            accountassignmentcategory TYPE string,
            deleteflag                TYPE string,
            controllingarea           TYPE string,
            masterfixedasset          TYPE string,
            fixedasset                TYPE string,
          END OF ty_entry,
          BEGIN OF ty_billbody,
            entry TYPE TABLE OF ty_entry WITH EMPTY KEY,
          END OF ty_billbody,
          BEGIN OF ty_billheader,
            guid              TYPE string,
            ebeln             TYPE string,
            logistics_orderno TYPE string,
            order_type        TYPE string,
            supplier_id       TYPE string,
            factory_id        TYPE string,
            comp              TYPE string,
            orderissue_date   TYPE string,
            deleteflag        TYPE string,
          END OF ty_billheader,
          BEGIN OF ty_bill,
            billheader TYPE ty_billheader,
            billbody   TYPE ty_billbody,
          END OF ty_bill,
          BEGIN OF ty_req,
            bill TYPE TABLE OF ty_bill WITH EMPTY KEY,
          END OF ty_req.

    TYPES:BEGIN OF ty_resheader,
            guid         TYPE string,
            resultstatus TYPE string,
            resultmsg    TYPE string,
          END OF ty_resheader,
          BEGIN OF ty_resbillheader,
            billheader TYPE ty_resheader,
          END OF ty_resbillheader,
          BEGIN OF ty_resdetail,
            bill TYPE TABLE OF ty_resbillheader WITH EMPTY KEY,
          END OF ty_resdetail,
          BEGIN OF ty_res,
            restoken    TYPE string,
            resfuncname TYPE string,
            resfrom     TYPE string,
            resdetail   TYPE ty_resdetail,
          END OF ty_res.


    DATA:gt_mapping       TYPE /ui2/cl_json=>name_mappings,
         gt_mapping_entry TYPE /ui2/cl_json=>name_mappings.
    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    DATA: gs_bill TYPE ty_bill.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_rest_cpi OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi017_resp.

    METHODS process
      EXPORTING
        o_resp TYPE zzs_mmi017_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM017 IMPLEMENTATION.


  METHOD inbound.
    DATA: ls_data_json TYPE string.
    DATA: ls_data TYPE ty_req.
    DATA: ls_res TYPE ty_res.
    DATA: ls_out TYPE zzs_rest_out.
    DATA: ls_process TYPE zzs_mmi017_out.

    ls_data_json = i_req-data.

    /ui2/cl_json=>deserialize( EXPORTING json          = ls_data_json
                                         pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data          = ls_data ).

    LOOP AT ls_data-bill INTO gs_bill.
      CLEAR: ls_out.

      me->process(
          IMPORTING
              o_resp = o_resp-out
      ).

    ENDLOOP.

    o_resp-sapnum = gs_bill-billheader-ebeln.
    o_resp-msgty = o_resp-out-resultstatus.
    o_resp-msgtx = o_resp-out-resultmsg.

  ENDMETHOD.


  METHOD process.

    DATA:ls_data           TYPE ty_purchaseorder,
         ls_account        TYPE ty_account,
         ls_account_change TYPE ty_account_d,
         ls_schedule       TYPE ty_schedule,
         ls_item_change    TYPE ty_item_d,
         ls_item           TYPE ty_item,
         lt_item           TYPE TABLE OF ty_item.
    DATA:lv_json TYPE string.

    o_resp-guid = gs_bill-billheader-guid.

    IF gs_bill-billheader-ebeln IS NOT INITIAL.
      SELECT SINGLE COUNT(*)
        FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS
       WHERE purchaseorder = @gs_bill-billheader-ebeln.
      IF sy-subrc = 0.
        gv_mode = 'U'.
      ELSE.
        gv_mode = 'I'.
      ENDIF.
    ELSE.
      gv_mode = 'I'.
    ENDIF.

    SELECT *
      FROM zztmm005
     WHERE relsystem = 'PSSC'
      INTO TABLE @DATA(lt_zztmm005).
    IF gv_mode = 'I'.
      "PO 抬头
      ls_data-purchaseorder = gs_bill-billheader-ebeln.
      READ TABLE lt_zztmm005 INTO DATA(ls_zztmm005) WITH KEY conftype = 'ORDERTYPE'
                                                             transvalue  = gs_bill-billheader-order_type.
      IF sy-subrc = 0.
        ls_data-purchaseordertype  = ls_zztmm005-sapvalue.
      ENDIF.

      SELECT SINGLE a~plant,
                    a~purchasingorganization,
                    b~companycode
        FROM i_plantpurchasingorganization WITH PRIVILEGED ACCESS AS a
        LEFT JOIN i_purchasingorganization WITH PRIVILEGED ACCESS AS b ON a~purchasingorganization = b~purchasingorganization
       WHERE a~plant = @gs_bill-billheader-comp
        INTO @DATA(ls_organization).
      IF sy-subrc = 0.
        ls_data-companycode = ls_organization-companycode.
        ls_data-purchasingorganization = ls_organization-purchasingorganization.
      ENDIF.

      READ TABLE lt_zztmm005 INTO ls_zztmm005 WITH KEY conftype = 'PURCHASINGGROUP'.
      IF sy-subrc = 0.
        ls_data-purchasinggroup  = ls_zztmm005-sapvalue.
      ENDIF.

      ls_data-supplier = gs_bill-billheader-supplier_id.
      ls_data-yy1_refdocno_pdh = gs_bill-billheader-logistics_orderno.

      "PO 行
      CLEAR:lt_item,lt_item[].
      LOOP AT gs_bill-billbody-entry INTO DATA(ls_tmp_item).
        CLEAR: ls_item.
        ls_item-purchaseorder                    = gs_bill-billheader-ebeln.
        ls_item-plant                            = 'GH00'.
        ls_item-purchaseorderitem                = ls_tmp_item-purchase_row_no.
        ls_item-yy1_purchaseorderitem_pdi        = ls_tmp_item-logistics_rowno.
        ls_item-documentcurrency                 = 'CNY'.
        ls_item-material                         = ls_tmp_item-part_id.
        ls_item-orderquantity                    = ls_tmp_item-order_num.
        ls_item-purchaseorderquantityunit        = ls_tmp_item-part_unit.
        ls_item-storagelocation                  = ls_tmp_item-depot_no.
        IF  ls_item-purchaseorderquantityunit IS INITIAL.
          SELECT SINGLE b~unitofmeasurecommercialname
           FROM i_product WITH PRIVILEGED ACCESS AS a
           JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS b ON b~unitofmeasure = a~baseunit
                                                               AND b~language = 1
         WHERE a~product = @ls_tmp_item-part_id
           INTO @ls_item-purchaseorderquantityunit .
        ENDIF.

        ls_item-goodsreceiptisexpected           = 'X'.
        ls_item-invoiceisexpected                = 'X'.
        ls_item-iscompletelydelivered            = 'X'.

        IF ls_tmp_item-masterfixedasset IS NOT INITIAL.
          ls_tmp_item-accountassignmentcategory = 'A'.
          ls_tmp_item-controllingarea = 'A000'.
          ls_tmp_item-fixedasset = '0000'.
        ENDIF.

        IF ls_tmp_item-zkostl IS NOT INITIAL.
          ls_tmp_item-accountassignmentcategory = 'K'.
        ENDIF.

        IF ls_tmp_item-uda2 IS NOT INITIAL.
          ls_tmp_item-accountassignmentcategory = 'P'.
        ENDIF.

        IF ls_tmp_item-accountassignmentcategory IS NOT INITIAL.
          ls_account-purchaseorder                = gs_bill-billheader-ebeln.
          ls_account-purchaseorderitem            = ls_tmp_item-purchase_row_no.
          ls_account-costcenter                   = ls_tmp_item-zkostl.
          ls_account-glaccount                    = ls_tmp_item-uda1.
          ls_account-wbselement                   = ls_tmp_item-uda2.
          ls_account-controllingarea              = ls_tmp_item-controllingarea.
          ls_account-masterfixedasset             = ls_tmp_item-masterfixedasset.
          ls_account-fixedasset                   = ls_tmp_item-fixedasset.
          APPEND ls_account TO ls_item-to_accountassignment-results.
          CLEAR ls_account.
        ENDIF.

        ls_item-accountassignmentcategory = ls_tmp_item-accountassignmentcategory.

        IF ls_tmp_item-plan_arrive_time IS NOT INITIAL.
          CLEAR: ls_schedule.
          ls_schedule-purchasingdocumentitem = ls_tmp_item-purchase_row_no.
          ls_schedule-scheduleline = '1'.
          ls_schedule-schedulelinedeliverydate  = zzcl_comm_tool=>date2iso( ls_tmp_item-plan_arrive_time ).
          APPEND ls_schedule TO ls_item-to_scheduleline-results.
        ENDIF.

        APPEND ls_item TO lt_item.
        CLEAR ls_item.

      ENDLOOP.

      ls_data-to_purchaseorderitem-results = lt_item."ADD BY HANDTQH 20260204 将行项目赋值到API结构中


      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'POST'.
      gs_http_req-url = |/API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder?sap-language={ gv_language }|.
      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_data
            compress      = abap_true
            name_mappings = gt_mapping ).
      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '201'.
        TYPES: BEGIN OF ty_orderitem,
                 purchaseorderitem         TYPE string,
                 yy1_purchaseorderitem_pdi TYPE string,
               END OF ty_orderitem,
               BEGIN OF tty_orderitem,
                 results TYPE TABLE OF ty_orderitem WITH EMPTY KEY,
               END OF tty_orderitem,
               BEGIN OF ty_heads,
                 purchaseorder        TYPE string,
                 yy1_refdocno_pdh     TYPE string,
                 to_purchaseorderitem TYPE tty_orderitem,
               END OF ty_heads,
               BEGIN OF ty_ress,
                 d TYPE ty_heads,
               END OF  ty_ress.
        DATA:ls_ress TYPE ty_ress.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_ress ).

        LOOP AT ls_ress-d-to_purchaseorderitem-results INTO DATA(ls_orderitem).
          APPEND VALUE #( logistics_orderno = ls_ress-d-yy1_refdocno_pdh
                          purchaseorder = ls_ress-d-purchaseorder
                          purchaseorderitem = ls_orderitem-purchaseorderitem
                          zpurchaseorderitem = ls_orderitem-yy1_purchaseorderitem_pdi
                     ) TO o_resp-body.
        ENDLOOP.
        o_resp-resultstatus  = 'S'.
        o_resp-resultmsg  = 'success'.
        gs_bill-billheader-ebeln = ls_ress-d-purchaseorder.
      ELSE.
        DATA:ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-resultstatus = 'E'.
        LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails)  WHERE severity = 'error'.
          o_resp-resultmsg = o_resp-resultmsg && '/' && ls_errordetails-message.
        ENDLOOP.
        IF o_resp-resultmsg IS INITIAL.
          o_resp-resultmsg = ls_rese-error-message-value.
        ENDIF.
      ENDIF.

    ENDIF.

    IF  gv_mode = 'U'.

      DATA: lv_method TYPE string.
      DATA: lv_posnr TYPE ebelp.


      SELECT purchaseorder,
             purchaseorderitem
        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        WHERE purchaseorder = @gs_bill-billheader-ebeln
         INTO TABLE @DATA(lt_purchaseorderitem).
      SORT lt_purchaseorderitem BY purchaseorderitem.

*行项目修改
      LOOP AT gs_bill-billbody-entry  INTO ls_tmp_item.

        READ TABLE lt_purchaseorderitem INTO DATA(ls_purchaseorderitem) WITH KEY purchaseorderitem = ls_tmp_item-purchase_row_no BINARY SEARCH.
        IF sy-subrc = 0.

          CLEAR: ls_item_change.

          ls_item_change-d-orderquantity              = ls_tmp_item-order_num.
          ls_item_change-d-purchaseorderquantityunit  = ls_tmp_item-part_unit.
          ls_item_change-d-storagelocation            = ls_tmp_item-depot_no.
*
          lv_posnr = ls_tmp_item-purchase_row_no.

          "删除
          IF ls_tmp_item-deleteflag = abap_true OR gs_bill-billheader-deleteflag = abap_true.
            lv_method = 'DELETE'.
            CLEAR:ls_item_change.
          ELSE.
            lv_method = 'PATCH'.
          ENDIF.

          CLEAR: gs_http_req,gs_http_resp.
          gs_http_req-version = 'ODATAV2'.
          gs_http_req-method = lv_method.
          gs_http_req-url = |/API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrderItem| &&
                            |(PurchaseOrder='{ gs_bill-billheader-ebeln }',| &&
                            |PurchaseOrderItem='{ lv_posnr }')?sap-language={ gv_language }|.
          "传入数据转JSON
          gs_http_req-body = /ui2/cl_json=>serialize(
                data          = ls_item_change
                compress      = abap_true
                name_mappings = gt_mapping ).
          gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

          IF gs_http_resp-code = '204'.
            o_resp-resultstatus  = 'S'.
          ELSE.
            DATA:ls_rese_u TYPE zzs_odata_fail.
            /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                        CHANGING data  = ls_rese_u ).

            o_resp-resultstatus = 'E'.
            LOOP AT ls_rese_u-error-innererror-errordetails INTO ls_errordetails  WHERE severity = 'error'.
              o_resp-resultmsg = o_resp-resultmsg && '/' && ls_errordetails-message.
            ENDLOOP.
            IF o_resp-resultmsg IS INITIAL.
              o_resp-resultmsg = ls_rese_u-error-message-value.
            ENDIF.
          ENDIF.

          CLEAR ls_item_change.

          IF lv_method = 'PATCH'
             AND ( ls_tmp_item-zkostl IS NOT INITIAL OR
                   ls_tmp_item-uda1 IS NOT INITIAL OR
                   ls_tmp_item-uda2 IS NOT INITIAL OR
                   ls_tmp_item-controllingarea IS NOT INITIAL OR
                   ls_tmp_item-masterfixedasset IS NOT INITIAL OR
                   ls_tmp_item-fixedasset IS NOT INITIAL
                 ).

            CLEAR: ls_account_change.

            SELECT SINGLE
                   accountassignmentnumber
              FROM i_purordaccountassignmentapi01 WITH PRIVILEGED ACCESS
             WHERE purchaseorder = @gs_bill-billheader-ebeln
               AND purchaseorderitem = @lv_posnr
              INTO @DATA(lv_accountassignmentnumber).

            ls_account_change-d-costcenter = ls_tmp_item-zkostl.
            ls_account_change-d-glaccount  = ls_tmp_item-uda1.
            ls_account_change-d-wbselement = ls_tmp_item-uda2.
            ls_account_change-d-controllingarea = ls_tmp_item-controllingarea.
            ls_account_change-d-masterfixedasset = ls_tmp_item-masterfixedasset.
            ls_account_change-d-fixedasset = ls_tmp_item-fixedasset.

            CLEAR: gs_http_req,gs_http_resp.
            gs_http_req-version = 'ODATAV2'.
            gs_http_req-method = lv_method.
            gs_http_req-url = |/API_PURCHASEORDER_PROCESS_SRV/A_PurOrdAccountAssignment| &&
                              |(PurchaseOrder='{ gs_bill-billheader-ebeln }',| &&
                              |PurchaseOrderItem='{ lv_posnr }',| &&
                              |AccountAssignmentNumber='{ lv_accountassignmentnumber }')?sap-language={ gv_language }|.
            "传入数据转JSON
            gs_http_req-body = /ui2/cl_json=>serialize(
                  data          = ls_account_change
                  compress      = abap_true
                  name_mappings = gt_mapping ).
            gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

            IF gs_http_resp-code = '204'.
              o_resp-resultstatus  = 'S'.
            ELSE.
              /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                          CHANGING data  = ls_rese_u ).

              o_resp-resultstatus = 'E'.
              LOOP AT ls_rese_u-error-innererror-errordetails INTO ls_errordetails  WHERE severity = 'error'.
                o_resp-resultmsg = o_resp-resultmsg && '/' && ls_errordetails-message.
              ENDLOOP.
              IF o_resp-resultmsg IS INITIAL.
                o_resp-resultmsg = o_resp-resultmsg && '/' && ls_rese_u-error-message-value.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          CLEAR: ls_item.
          ls_item-purchaseorder                    = gs_bill-billheader-ebeln.
          ls_item-plant                            = 'GH00'.
          ls_item-purchaseorderitem                = ls_tmp_item-purchase_row_no.
          ls_item-yy1_purchaseorderitem_pdi        = ls_tmp_item-logistics_rowno.
          ls_item-documentcurrency                 = 'CNY'.
          ls_item-material                         = ls_tmp_item-part_id.
          ls_item-orderquantity                    = ls_tmp_item-order_num.
          ls_item-purchaseorderquantityunit        = ls_tmp_item-part_unit.
          ls_item-storagelocation                  = ls_tmp_item-depot_no.
          IF  ls_item-purchaseorderquantityunit IS INITIAL.
            SELECT SINGLE b~unitofmeasurecommercialname
             FROM i_product WITH PRIVILEGED ACCESS AS a
             JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS b ON b~unitofmeasure = a~baseunit
                                                                 AND b~language = 1
           WHERE a~product = @ls_tmp_item-part_id
             INTO @ls_item-purchaseorderquantityunit .
          ENDIF.

          ls_item-goodsreceiptisexpected           = 'X'.
          ls_item-invoiceisexpected                = 'X'.
          ls_item-iscompletelydelivered            = 'X'.

          IF ls_tmp_item-masterfixedasset IS NOT INITIAL.
            ls_tmp_item-accountassignmentcategory = 'A'.
            ls_tmp_item-controllingarea = 'A000'.
            ls_tmp_item-fixedasset = '0000'.
          ENDIF.

          IF ls_tmp_item-zkostl IS NOT INITIAL.
            ls_tmp_item-accountassignmentcategory = 'K'.
          ENDIF.

          IF ls_tmp_item-uda2 IS NOT INITIAL.
            ls_tmp_item-accountassignmentcategory = 'P'.
          ENDIF.

          CLEAR ls_account.
          IF ls_tmp_item-accountassignmentcategory IS NOT INITIAL.
            ls_account-purchaseorder                = gs_bill-billheader-ebeln.
            ls_account-purchaseorderitem            = ls_tmp_item-purchase_row_no.
            ls_account-costcenter                   = ls_tmp_item-zkostl.
            ls_account-glaccount                    = ls_tmp_item-uda1.
            ls_account-wbselement                   = ls_tmp_item-uda2.
            ls_account-controllingarea              = ls_tmp_item-controllingarea.
            ls_account-masterfixedasset             = ls_tmp_item-masterfixedasset.
            ls_account-fixedasset                   = ls_tmp_item-fixedasset.
            APPEND ls_account TO ls_item-to_accountassignment-results.
          ENDIF.

          ls_item-accountassignmentcategory = ls_tmp_item-accountassignmentcategory.

          IF ls_tmp_item-plan_arrive_time IS NOT INITIAL.
            CLEAR: ls_schedule.
            ls_schedule-purchasingdocumentitem = ls_tmp_item-purchase_row_no.
            ls_schedule-scheduleline = '1'.
            ls_schedule-schedulelinedeliverydate  = zzcl_comm_tool=>date2iso( ls_tmp_item-plan_arrive_time ).
            APPEND ls_schedule TO ls_item-to_scheduleline-results.
          ENDIF.

          CLEAR: gs_http_req,gs_http_resp.
          gs_http_req-version = 'ODATAV2'.
          gs_http_req-method = 'POST'.
          gs_http_req-url = |/API_PURCHASEORDER_PROCESS_SRV/A_PurchaseOrder('{ gs_bill-billheader-ebeln }')/to_PurchaseOrderItem?sap-language={ gv_language }|.
          "传入数据转JSON
          gs_http_req-body = /ui2/cl_json=>serialize(
                data          = ls_item
                compress      = abap_true
                name_mappings = gt_mapping ).
          gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

          IF gs_http_resp-code = '201'.
            o_resp-resultstatus  = 'S'.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                        CHANGING data  = ls_rese ).
            o_resp-resultstatus = 'E'.
            LOOP AT ls_rese-error-innererror-errordetails INTO ls_errordetails WHERE severity = 'error'.
              o_resp-resultmsg = o_resp-resultmsg && '/' && ls_errordetails-message.
            ENDLOOP.
            IF o_resp-resultmsg IS INITIAL.
              o_resp-resultmsg = o_resp-resultmsg && '/' && ls_rese-error-message-value.
            ENDIF.
          ENDIF.

        ENDIF.
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
            ( abap = 'WBSElement'                          json = 'WBSElement' )
            ( abap = 'GLAccount'                           json = 'GLAccount' )
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
            ( abap = 'StorageLocation'                     json = 'StorageLocation'   )
            ( abap = 'YY1_PurchaseOrderItem_PDI'           json = 'YY1_PurchaseOrderItem_PDI'   )
            ( abap = 'ControllingArea'                     json = 'ControllingArea'   )
                            ).
    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.
  ENDMETHOD.
ENDCLASS.
