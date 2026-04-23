CLASS lhc_fi011 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR fi011 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR fi011 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ fi011 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK fi011.

    METHODS zzpost FOR MODIFY
      IMPORTING keys FOR ACTION fi011~zzpost RESULT result.

    METHODS zzrev FOR MODIFY
      IMPORTING keys FOR ACTION fi011~zzrev RESULT result.

ENDCLASS.

CLASS lhc_fi011 IMPLEMENTATION.

  METHOD get_instance_features.
    DATA: lv_abled_post TYPE abp_behv_op_ctrl.
    DATA: lv_abled_rev TYPE abp_behv_op_ctrl.
    DATA: lv_disabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-disabled.
    DATA: lv_enabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.

    READ TABLE keys INTO DATA(key) INDEX 1.

    SELECT COUNT(*)
      FROM zztfi015
     WHERE werks = @key-uuid+0(4)
       AND gjahr = @key-uuid+4(4)
       AND monat = @key-uuid+8(2)
       AND matnr = @key-uuid+10(40).
    IF sy-subrc = 0.
      lv_abled_post = lv_disabled.
      lv_abled_rev = lv_enabled.
    ELSE.
      lv_abled_post = lv_enabled.
      lv_abled_rev = lv_disabled.
    ENDIF.

    LOOP AT keys INTO key.
      APPEND VALUE #( %tky = key-%tky
                      %action-zzpost = lv_abled_post
                      %action-zzrev = lv_abled_rev
                       )
      TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD zzpost.
    TYPES: BEGIN OF ty_glacct,
             supplierinvoiceitem       TYPE string,
             glaccount                 TYPE string,
             documentcurrency          TYPE string,
             supplierinvoiceitemamount TYPE string,
             debitcreditcode           TYPE string,
           END OF ty_glacct,

           BEGIN OF ty_material,
             supplierinvoiceitem       TYPE string,
             material                  TYPE string,
             valuationarea             TYPE string,
             documentcurrency          TYPE string,
             supplierinvoiceitemamount TYPE string,
             quantity                  TYPE string,
             taxcode                   TYPE string,
             quantityunit              TYPE string,
             debitcreditcode           TYPE string,
           END OF ty_material,
           BEGIN OF ty_supplierinvoice,
             companycode                  TYPE string,
             documentdate                 TYPE string,
             postingdate                  TYPE string,
             taxdeterminationdate         TYPE string,
             invoicingparty               TYPE string,
             invoicegrossamount           TYPE string,
             documentcurrency             TYPE string,
             duecalculationbasedate       TYPE string,
             to_suplrinvcitemmaterial     TYPE TABLE OF ty_material WITH EMPTY KEY,
             to_supplierinvoiceitemglacct TYPE TABLE OF ty_glacct WITH EMPTY KEY,
           END OF ty_supplierinvoice.

    DATA: ls_supplierinvoice TYPE ty_supplierinvoice,
          ls_material        TYPE ty_material,
          ls_glacct          TYPE ty_glacct.

    DATA: lt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA: ls_http_req  TYPE zzs_http_req,
          ls_http_resp TYPE zzs_http_resp.

    DATA: lv_index TYPE n.

    DATA: lt_zztfi015 TYPE TABLE OF zztfi015,
          ls_zztfi015 TYPE zztfi015.

    DATA: lr_fi011 TYPE REF TO zzcl_query_fi011.
    DATA: lt_result TYPE TABLE OF zc_query_fi011.
    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    lt_mapping = VALUE #(
        ( abap = 'CompanyCode'                               json = 'CompanyCode' )
        ( abap = 'DocumentDate'                              json = 'DocumentDate' )
        ( abap = 'PostingDate'                               json = 'PostingDate' )
        ( abap = 'TaxDeterminationDate'                      json = 'TaxDeterminationDate' )
        ( abap = 'InvoicingParty'                            json = 'InvoicingParty' )
        ( abap = 'InvoiceGrossAmount'                        json = 'InvoiceGrossAmount' )
        ( abap = 'DocumentCurrency'                          json = 'DocumentCurrency' )
        ( abap = 'DueCalculationBaseDate'                    json = 'DueCalculationBaseDate' )
        ( abap = 'to_SuplrInvcItemMaterial'                  json = 'to_SuplrInvcItemMaterial' )
        ( abap = 'SupplierInvoiceItem'                       json = 'SupplierInvoiceItem' )
        ( abap = 'Material'                                  json = 'Material' )
        ( abap = 'ValuationArea'                             json = 'ValuationArea' )
        ( abap = 'SupplierInvoiceItemAmount'                 json = 'SupplierInvoiceItemAmount' )
        ( abap = 'Quantity'                                  json = 'Quantity' )
        ( abap = 'TaxCode'                                   json = 'TaxCode' )
        ( abap = 'QuantityUnit'                              json = 'QuantityUnit' )
        ( abap = 'DebitCreditCode'                           json = 'DebitCreditCode' )
        ( abap = 'to_SupplierInvoiceItemGLAcct'              json = 'to_SupplierInvoiceItemGLAcct' )
        ( abap = 'GLAccount'                                 json = 'GLAccount' )
    ).

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_uuid) = key-uuid.
      APPEND VALUE #( name = 'WERKS'
                      range = VALUE #( ( low = key-uuid+0(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'GJAHR'
                      range = VALUE #( ( low = key-uuid+4(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'MONAT'
                      range = VALUE #( ( low = key-uuid+8(2) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'ZSFYFT'
                      range = VALUE #( ( low = '' sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
    ENDIF.

    "获取数据
    CREATE OBJECT lr_fi011.
    CALL METHOD lr_fi011->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    "获取当月时间范围
    SELECT SINGLE *
      FROM i_calendardate
     WHERE calendaryear = @key-uuid+4(4)
       AND calendarmonth = @key-uuid+8(2)
      INTO @DATA(ls_calendardate).

    FREE: lt_zztfi015.
    CLEAR: ls_supplierinvoice, lv_index.
    LOOP AT lt_result INTO DATA(ls_result).
      CLEAR: ls_material, ls_glacct.
      DATA(ls_temp) = ls_result.
      lv_index = lv_index + 1.

      "物料
      ls_material-supplierinvoiceitem = lv_index.
      ls_material-material = ls_temp-matnr.
      ls_material-valuationarea = ls_temp-werks.
      ls_material-documentcurrency = ls_temp-hwaer.
      IF ls_temp-dmbtr4 > 0.
        ls_material-supplierinvoiceitemamount = ls_temp-dmbtr4.
        ls_material-debitcreditcode = 'S'.
      ELSE.
        ls_material-supplierinvoiceitemamount = 0 - ls_temp-dmbtr4.
        ls_material-debitcreditcode = 'H'.
      ENDIF.
      ls_material-quantity = ls_temp-menge.
      ls_material-taxcode = 'J0'.
      ls_material-quantityunit = ls_temp-meins.

      CONDENSE ls_material-supplierinvoiceitemamount NO-GAPS.
      CONDENSE ls_material-quantity NO-GAPS.
      APPEND ls_material TO ls_supplierinvoice-to_suplrinvcitemmaterial.

      "总账科目
      ls_glacct-supplierinvoiceitem = lv_index.
      ls_glacct-glaccount = '1408010000'.
      ls_glacct-documentcurrency = ls_temp-hwaer.
      IF ls_temp-dmbtr4 > 0.
        ls_glacct-supplierinvoiceitemamount = ls_temp-dmbtr4.
        ls_glacct-debitcreditcode = 'S'.
      ELSE.
        ls_glacct-supplierinvoiceitemamount = 0 - ls_temp-dmbtr4.
        ls_glacct-debitcreditcode = 'H'.
      ENDIF.
      CONDENSE ls_glacct-supplierinvoiceitemamount NO-GAPS.
      APPEND ls_glacct TO ls_supplierinvoice-to_supplierinvoiceitemglacct.

      AT LAST.
        ls_supplierinvoice-companycode = ls_temp-bukrs.
        ls_supplierinvoice-documentdate = zzcl_comm_tool=>date2iso( iv_date = CONV string( ls_calendardate-lastdayofmonthdate ) ).
        ls_supplierinvoice-postingdate = ls_supplierinvoice-documentdate.
        ls_supplierinvoice-taxdeterminationdate = ls_supplierinvoice-documentdate.
        ls_supplierinvoice-duecalculationbasedate = ls_supplierinvoice-documentdate.
        ls_supplierinvoice-invoicingparty = 'A99999'.
        ls_supplierinvoice-invoicegrossamount = '0'.
        ls_supplierinvoice-documentcurrency = ls_temp-hwaer.
      ENDAT.
    ENDLOOP.

    ls_http_req-version = 'ODATAV2'.
    ls_http_req-method = 'POST'.
    ls_http_req-url = |/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice?sap-language=zh|.

    "传入数据转JSON
    ls_http_req-body = /ui2/cl_json=>serialize(
          data          = ls_supplierinvoice
          compress      = abap_true
          name_mappings = lt_mapping ).

    ls_http_resp = zzcl_comm_tool=>http( ls_http_req ).
    IF ls_http_resp-code = '201'.
      TYPES:BEGIN OF ty_heads,
              supplierinvoice TYPE string,
            END OF ty_heads,
            BEGIN OF ty_ress,
              d TYPE ty_heads,
            END OF  ty_ress.
      DATA:ls_ress TYPE ty_ress.
      /ui2/cl_json=>deserialize( EXPORTING json  = ls_http_resp-body
                                  CHANGING data  = ls_ress ).


      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
        CLEAR: ls_zztfi015.
        <fs_result>-zsfyft = abap_true.
        <fs_result>-belnr = ls_ress-d-supplierinvoice.
        <fs_result>-budat = ls_calendardate-lastdayofmonthdate.
        MOVE-CORRESPONDING <fs_result> TO ls_zztfi015.

        APPEND ls_zztfi015 TO lt_zztfi015.

*        APPEND VALUE #(
*           %tky-uuid = <fs_result>-uuid
*           %param = CORRESPONDING #( <fs_result> )
*        ) TO result.
      ENDLOOP.

      MODIFY zztfi015 FROM TABLE @lt_zztfi015.

    ELSE.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = ls_http_resp-body
                                  CHANGING data  = ls_rese ).

      LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.

        APPEND VALUE #(
           %msg      = new_message_with_text(
                   severity  = if_abap_behv_message=>severity-information
                   text      = ls_errordetails-message
               )
        ) TO reported-fi011.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD zzrev.

    DATA: lr_fi011 TYPE REF TO zzcl_query_fi011.
    DATA: lt_result TYPE TABLE OF zc_query_fi011.
    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    DATA: ls_http_req  TYPE zzs_http_req,
          ls_http_resp TYPE zzs_http_resp.

    DATA: lv_datetime TYPE string.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_uuid) = key-uuid.
      APPEND VALUE #( name = 'WERKS'
                      range = VALUE #( ( low = key-uuid+0(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'GJAHR'
                      range = VALUE #( ( low = key-uuid+4(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'MONAT'
                      range = VALUE #( ( low = key-uuid+8(2) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'ZSFYFT'
                      range = VALUE #( ( low = 'X' sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
    ENDIF.

    "获取数据
    CREATE OBJECT lr_fi011.
    CALL METHOD lr_fi011->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
    IF sy-subrc = 0.
      lv_datetime = zzcl_comm_tool=>date2iso( iv_date = CONV string( ls_result-budat ) ).

      ls_http_req-version = 'ODATAV2'.
      ls_http_req-method = 'POST'.
      ls_http_req-url = |/API_SUPPLIERINVOICE_PROCESS_SRV/Cancel?| &&
                        |PostingDate=datetime'{ lv_datetime }'&| &&
                        |ReversalReason='02'&| &&
                        |FiscalYear='{ ls_result-gjahr }'&| &&
                        |SupplierInvoice='{ ls_result-belnr }'&| &&
                        |sap-language=zh|.

      ls_http_resp = zzcl_comm_tool=>http( ls_http_req ).

      IF ls_http_resp-code = '200'.
        DELETE FROM zztfi015 WHERE belnr = @ls_result-belnr
                               AND budat = @ls_result-budat.

        APPEND VALUE #(
                 %msg      = new_message_with_text(
                         severity  = if_abap_behv_message=>severity-success
                         text      = '冲销成功'
                     )
          )  TO reported-fi011.

      ELSE.
        DATA:ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = ls_http_resp-body
                                    CHANGING data  = ls_rese ).

        LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.

          APPEND VALUE #(
             %msg      = new_message_with_text(
                     severity  = if_abap_behv_message=>severity-information
                     text      = ls_errordetails-message
                 )
          ) TO reported-fi011.

        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_fi011 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_fi011 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
