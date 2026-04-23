CLASS lhc_fi010 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR fi010 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR fi010 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ fi010 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK fi010.

    METHODS zzpost FOR MODIFY
      IMPORTING keys FOR ACTION fi010~zzpost RESULT result.

    METHODS zzrev FOR MODIFY
      IMPORTING keys FOR ACTION fi010~zzrev RESULT result.

ENDCLASS.

CLASS lhc_fi010 IMPLEMENTATION.

  METHOD get_instance_features.
    DATA: lv_abled_post TYPE abp_behv_op_ctrl.
    DATA: lv_abled_rev TYPE abp_behv_op_ctrl.
    DATA: lv_disabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-disabled.
    DATA: lv_enabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.

    READ TABLE keys INTO DATA(key) INDEX 1.

    SELECT COUNT(*)
      FROM zztfi014
     WHERE bukrs = @key-uuid+0(4)
       AND gjahr = @key-uuid+4(4)
       AND monat = @key-uuid+8(2).
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
    DATA ls_tab TYPE zjournal_entry_create_request.
    DATA ls_req TYPE zjournal_entry_create_reques18.
    DATA ls_item TYPE zjournal_entry_create_request9.
    DATA ls_debtor_item TYPE zjournal_entry_create_reques13.
    DATA ls_creditor_item TYPE zjournal_entry_create_reques16.
    DATA lv_itm TYPE n LENGTH 3.
    DATA o_resp TYPE zzs_rest_out.
    DATA(request) = VALUE zjournal_entry_bulk_create_req( ).

    DATA:lt_zztfi014 TYPE TABLE OF zztfi014,
         ls_zztfi014 TYPE zztfi014.

    DATA: lr_fi010 TYPE REF TO zzcl_query_fi010.
    DATA: lt_result TYPE TABLE OF zc_query_fi010.
    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_uuid) = key-uuid.
      APPEND VALUE #( name = 'BUKRS'
                      range = VALUE #( ( low = key-uuid+0(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'GJAHR'
                      range = VALUE #( ( low = key-uuid+4(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'MONAT'
                      range = VALUE #( ( low = key-uuid+8(2) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'ZSFYJZ'
                      range = VALUE #( ( low = '' sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
    ENDIF.


    "获取数据
    CREATE OBJECT lr_fi010.
    CALL METHOD lr_fi010->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    SELECT SUM( dmbtr ) AS dmbtr
      FROM @lt_result AS a
      INTO @DATA(lv_dmbtr).

    "获取当月时间范围
    SELECT SINGLE *
      FROM i_calendardate
     WHERE calendaryear = @key-uuid+4(4)
       AND calendarmonth = @key-uuid+8(2)
      INTO @DATA(ls_calendardate).

    "获取配置表数据
    SELECT SINGLE *
      FROM zzt_rest_sysid
     WHERE zztsysid = 'SELF'
      INTO @DATA(ls_zzt_rest_sysid).

    DATA(lv_username) = ls_zzt_rest_sysid-zzuser.
    DATA(lv_password) = ls_zzt_rest_sysid-zzpwd.
    DATA(lv_url) = ls_zzt_rest_sysid-zztkurl && ls_zzt_rest_sysid-zzurl && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi?sap-language=zh'.

    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url(  i_url =  lv_url ).
        destination->set_basic_authentication( i_user = CONV #( lv_username ) i_password = CONV #( lv_password ) ).
        DATA(proxy) = NEW zco_journal_entry_create_reque( destination = destination ).
        IF proxy IS NOT BOUND.
          o_resp-msgty = 'E'.
          o_resp-msgtx = '服务端口创建异常，请联系管理员!'.
          RETURN.
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_root->get_text( ).
    ENDTRY.

    CLEAR: request, ls_req, ls_tab, lv_itm, o_resp.

    ls_req-original_reference_document_ty = 'BKPFF'.
    ls_req-business_transaction_type = 'RFBU'.
    ls_req-company_code = key-uuid+0(4).
    ls_req-accounting_document_type = 'SA'.
    ls_req-document_date = ls_calendardate-lastdayofmonthdate.
    ls_req-posting_date = ls_calendardate-lastdayofmonthdate.
    ls_req-document_header_text = |{ key-uuid+4(4) }年{ key-uuid+8(2) }月制费成本结转|.
    ls_req-created_by_user = sy-uname.

    "总账
    READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
    CLEAR: ls_item.
    lv_itm = lv_itm + 1.
    ls_item-reference_document_item = lv_itm.
    IF lv_dmbtr > 0.
      ls_item-debit_credit_code = 'S'.
    ELSE.
      ls_item-debit_credit_code = 'H'.
    ENDIF.
    ls_item-glaccount-content = '1408010000'.
    ls_item-amount_in_transaction_currency-content = lv_dmbtr.
    ls_item-amount_in_transaction_currency-currency_code = ls_result-hwaer.
    ls_item-assignment_reference = '制费成本结转'.
    ls_item-document_item_text = |{ key-uuid+4(4) }年{ key-uuid+8(2) }月制费成本结转|.
    APPEND ls_item TO ls_req-item.

    LOOP AT lt_result INTO ls_result.
      CLEAR: ls_item.
      lv_itm = lv_itm + 1.
      ls_item-reference_document_item = lv_itm.
      IF ls_result-dmbtr > 0.
        ls_item-debit_credit_code = 'H'.
      ELSE.
        ls_item-debit_credit_code = 'S'.
      ENDIF.
      ls_item-amount_in_transaction_currency-content = 0 - ls_result-dmbtr.
      ls_item-glaccount-content = ls_result-hkont.
      ls_item-amount_in_transaction_currency-currency_code = ls_result-hwaer.
      ls_item-account_assignment-cost_center = ls_result-kostl.
      ls_item-assignment_reference = '制费成本结转'.
      ls_item-document_item_text = |{ key-uuid+4(4) }年{ key-uuid+8(2) }月制费成本结转|.
      APPEND ls_item TO ls_req-item.
    ENDLOOP.

    ls_tab-journal_entry = ls_req.
    APPEND ls_tab TO request-journal_entry_bulk_create_requ-journal_entry_create_request.
    GET TIME STAMP FIELD request-journal_entry_bulk_create_requ-message_header-creation_date_time.

    TRY.
        proxy->journal_entry_create_request_c(
          EXPORTING
            input = request
          IMPORTING
            output = DATA(response)
          ).
      CATCH cx_ai_system_fault INTO DATA(lo_fault).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_fault->get_text( ).
        RETURN.
    ENDTRY.

    DATA(lv_accounting_document) = response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-journal_entry_create_confirmat-accounting_document.
    IF lv_accounting_document = '0000000000'.
      o_resp-msgty = 'E'.
      LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-log-item INTO DATA(ls_item_log).
        o_resp-msgtx = o_resp-msgtx && ls_item_log-note && '/'.

        APPEND VALUE #(
               %msg      = new_message_with_text(
                       severity  = if_abap_behv_message=>severity-information
                       text      = ls_item_log-note
                   )
        )  TO reported-fi010.
      ENDLOOP.


    ELSE.
      o_resp-msgty = 'S'.

      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
        CLEAR: ls_zztfi014.
        <fs_result>-zsfyjz = abap_true.
        <fs_result>-belnr2 = lv_accounting_document.
        <fs_result>-budat2 = ls_calendardate-lastdayofmonthdate.
        MOVE-CORRESPONDING <fs_result> TO ls_zztfi014.

        APPEND ls_zztfi014 TO lt_zztfi014.

*        APPEND VALUE #(
*           %tky-uuid = <fs_result>-uuid
*           %param = CORRESPONDING #( <fs_result> )
*        ) TO result.
      ENDLOOP.

      MODIFY zztfi014 FROM TABLE @lt_zztfi014.
    ENDIF.

  ENDMETHOD.

  METHOD zzrev.
    DATA ls_tab TYPE zjournal_entry_create_request.
    DATA ls_req TYPE zjournal_entry_create_reques18.
    DATA ls_item TYPE zjournal_entry_create_request9.
    DATA ls_debtor_item TYPE zjournal_entry_create_reques13.
    DATA ls_creditor_item TYPE zjournal_entry_create_reques16.
    DATA lv_itm TYPE n LENGTH 3.
    DATA o_resp TYPE zzs_rest_out.
    DATA(request) = VALUE zjournal_entry_bulk_create_req( ).

    DATA:lt_zztfi014 TYPE TABLE OF zztfi014,
         ls_zztfi014 TYPE zztfi014.

    DATA: lr_fi010 TYPE REF TO zzcl_query_fi010.
    DATA: lt_result TYPE TABLE OF zc_query_fi010.
    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_uuid) = key-uuid.
      APPEND VALUE #( name = 'BUKRS'
                      range = VALUE #( ( low = key-uuid+0(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'GJAHR'
                      range = VALUE #( ( low = key-uuid+4(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'MONAT'
                      range = VALUE #( ( low = key-uuid+8(2) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'ZSFYJZ'
                      range = VALUE #( ( low = 'X' sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
    ENDIF.


    "获取数据
    CREATE OBJECT lr_fi010.
    CALL METHOD lr_fi010->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    "获取配置表数据
    SELECT SINGLE *
      FROM zzt_rest_sysid
     WHERE zztsysid = 'SELF'
      INTO @DATA(ls_zzt_rest_sysid).

    DATA(lv_username) = ls_zzt_rest_sysid-zzuser.
    DATA(lv_password) = ls_zzt_rest_sysid-zzpwd.
    DATA(lv_url) = ls_zzt_rest_sysid-zztkurl && ls_zzt_rest_sysid-zzurl && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi?sap-language=zh'.

    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url(  i_url =  lv_url ).
        destination->set_basic_authentication( i_user = CONV #( lv_username ) i_password = CONV #( lv_password ) ).
        DATA(proxy) = NEW zco_journal_entry_create_reque( destination = destination ).
        IF proxy IS NOT BOUND.
          o_resp-msgty = 'E'.
          o_resp-msgtx = '服务端口创建异常，请联系管理员!'.
          RETURN.
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_root->get_text( ).
    ENDTRY.

    READ TABLE lt_result INTO DATA(ls_result) INDEX 1.
    IF sy-subrc = 0.
      CLEAR: request,ls_req,ls_tab,lv_itm,o_resp.
      ls_req-original_reference_document_ty = 'BKPFF'.
      ls_req-business_transaction_type = 'RFBU'.
      ls_req-accounting_document_type = 'DA'.
      ls_req-company_code = ls_result-bukrs.
      ls_req-created_by_user = sy-uname.
      ls_req-reversal_reference_document = ls_result-belnr2 && ls_result-bukrs && ls_result-budat2+0(4) .
      ls_req-reversal_date = sy-datlo.
      ls_req-reversal_reason = '01'.
      ls_tab-journal_entry = ls_req.
      APPEND ls_tab TO request-journal_entry_bulk_create_requ-journal_entry_create_request.

      GET TIME STAMP FIELD request-journal_entry_bulk_create_requ-message_header-creation_date_time.
      TRY.
          proxy->journal_entry_create_request_c(
            EXPORTING
              input = request
            IMPORTING
              output = DATA(response)
            ).
        CATCH cx_ai_system_fault INTO DATA(lo_fault).
          o_resp-msgty = 'E'.
          o_resp-msgtx = lo_fault->get_text( ).
          RETURN.
      ENDTRY.

      DATA(lv_accounting_document) = response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-journal_entry_create_confirmat-accounting_document.
      IF lv_accounting_document = '0000000000'.
        o_resp-msgty = 'E'.
        LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-log-item INTO DATA(ls_item_log).
          o_resp-msgtx = o_resp-msgtx && ls_item_log-note && '/'.

          APPEND VALUE #(
                 %msg      = new_message_with_text(
                         severity  = if_abap_behv_message=>severity-information
                         text      = ls_item_log-note
                     )
          )  TO reported-fi010.
        ENDLOOP.


      ELSE.
        DELETE FROM zztfi014 WHERE belnr2 = @ls_result-belnr2
                               AND budat2 = @ls_result-budat2.

        APPEND VALUE #(
                 %msg      = new_message_with_text(
                         severity  = if_abap_behv_message=>severity-success
                         text      = '冲销成功'
                     )
          )  TO reported-fi010.
      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_fi010 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_fi010 IMPLEMENTATION.

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
