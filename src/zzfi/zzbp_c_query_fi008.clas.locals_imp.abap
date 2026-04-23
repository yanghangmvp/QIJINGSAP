CLASS lhc_zc_query_fi008 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zc_query_fi008 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_query_fi008 RESULT result.



    METHODS read FOR READ
      IMPORTING keys FOR READ zc_query_fi008 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_query_fi008.

    METHODS zzpost FOR MODIFY
      IMPORTING keys FOR ACTION zc_query_fi008~zzpost  RESULT result..

    METHODS zzrev FOR MODIFY
      IMPORTING keys FOR ACTION zc_query_fi008~zzrev RESULT result..

ENDCLASS.

CLASS lhc_zc_query_fi008 IMPLEMENTATION.

  METHOD get_instance_features.
    DATA: lv_abled_post TYPE abp_behv_op_ctrl.
    DATA: lv_abled_rev TYPE abp_behv_op_ctrl.
    DATA: lv_disabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-disabled.
    DATA: lv_enabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.

    READ TABLE keys INTO DATA(key) INDEX 1.

    SELECT COUNT(*)
      FROM zztfi013
     WHERE companycode = @key-uuid+0(4)
       AND fiscalyear = @key-uuid+4(4)
       AND fiscalperiod = @key-uuid+8(2).
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

    DATA:lt_zztfi013 TYPE TABLE OF zztfi013,
         ls_zztfi013 TYPE zztfi013.

    DATA: lr_fi008 TYPE REF TO zzcl_query_fi008.
    DATA: lt_result TYPE TABLE OF zc_query_fi008.
    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_uuid) = key-uuid.
      APPEND VALUE #( name = 'COMPANYCODE'
                      range = VALUE #( ( low = key-uuid+0(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'FISCALYEAR'
                      range = VALUE #( ( low = key-uuid+4(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'FISCALPERIOD'
                      range = VALUE #( ( low = key-uuid+8(2) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'HASITBEENPROCESSED'
                     range = VALUE #( ( low = '' sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
    ENDIF.

    "获取数据
    CREATE OBJECT lr_fi008.
    CALL METHOD lr_fi008->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    DATA(lt_tmp) = lt_result.
    SORT lt_tmp BY companycode transactioncurrency.
    DELETE ADJACENT DUPLICATES FROM lt_tmp COMPARING companycode transactioncurrency.

    READ TABLE lt_tmp INTO DATA(ls_tmp) INDEX 1.
    "获取当月时间范围
    SELECT SINGLE *
      FROM i_calendardate
     WHERE calendaryear = @ls_tmp-fiscalyear
       AND calendarmonth = @ls_tmp-fiscalperiod
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
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_root->get_text( ).
    ENDTRY.


    LOOP AT lt_tmp INTO ls_tmp.


*----------------暂估---------
      CLEAR: request,ls_req,ls_tab,lv_itm,o_resp.
      ls_req-original_reference_document_ty = 'BKPFF'.
      ls_req-business_transaction_type = 'RFBU'.
      ls_req-accounting_document_type = 'DA'.
      ls_req-company_code = ls_tmp-companycode.
      ls_req-document_date = ls_calendardate-lastdayofmonthdate.
      ls_req-posting_date = ls_calendardate-lastdayofmonthdate.
      ls_req-created_by_user = sy-uname.
      ls_req-document_header_text = |{ ls_tmp-fiscalyear }年{ ls_tmp-fiscalperiod }月销售暂估收入过账|.

      "1（按“客户”分组，每组生成一条分录）
      SELECT a~soldtoparty,
             b~reconciliationaccount,
             c~tradingpartner ,
             SUM( estimatedtotalamount ) AS amount
        FROM @lt_result AS a
        JOIN i_customercompany WITH PRIVILEGED ACCESS AS b ON a~soldtoparty = b~customer
                                                          AND a~companycode = b~companycode
        LEFT OUTER JOIN i_customer WITH PRIVILEGED ACCESS AS c ON a~soldtoparty = c~customer
       WHERE a~companycode  = @ls_tmp-companycode
         AND a~transactioncurrency  = @ls_tmp-transactioncurrency
        GROUP BY soldtoparty ,reconciliationaccount,tradingpartner
        INTO TABLE @DATA(lt_soldtoparty).
      LOOP AT lt_soldtoparty INTO DATA(ls_soldtoparty).
        lv_itm = lv_itm + 1.
        CLEAR:ls_debtor_item.
        ls_debtor_item-reference_document_item = lv_itm.
        ls_debtor_item-debtor = ls_soldtoparty-soldtoparty.
        ls_debtor_item-altv_recncln_accts-content = '1122010110'.

        ls_debtor_item-amount_in_transaction_currency-content = ls_soldtoparty-amount.
        ls_debtor_item-amount_in_transaction_currency-currency_code = ls_tmp-transactioncurrency.
        IF ls_soldtoparty-amount > 0.
          ls_debtor_item-debit_credit_code = 'S'.
        ELSE.
          ls_debtor_item-debit_credit_code = 'H'.
        ENDIF.
        ls_debtor_item-assignment_reference = '销售暂估收入过账'.
        ls_debtor_item-document_item_text = ls_req-document_header_text.
        APPEND ls_debtor_item TO ls_req-debtor_item.
      ENDLOOP.


      "2（按“物料科目分配组”分组，每组生成一条分录）
      SELECT a~accountdetnproductgroup,
             SUM( estimatedrevenue ) AS amount
        FROM @lt_result AS a
       WHERE a~companycode  = @ls_tmp-companycode
         AND a~transactioncurrency  = @ls_tmp-transactioncurrency
        GROUP BY accountdetnproductgroup
        INTO TABLE @DATA(lt_productgroup).
      LOOP AT lt_productgroup INTO DATA(ls_productgroup).
        lv_itm = lv_itm + 1.
        "总帐
        CLEAR:ls_item.
        ls_item-reference_document_item = lv_itm.
        CASE ls_productgroup-accountdetnproductgroup.
          WHEN 'Z1'.
            ls_item-glaccount-content = '6001020101'.
          WHEN 'Z2'.
            ls_item-glaccount-content = '6001050201'.
          WHEN 'Z3'.
            ls_item-glaccount-content = '6001020821'.
          WHEN 'Z4' OR 'Z9'.
            ls_item-glaccount-content = '6001020899'.
        ENDCASE.

        ls_item-amount_in_transaction_currency-content = ls_productgroup-amount * -1.
        ls_item-amount_in_transaction_currency-currency_code = ls_tmp-transactioncurrency.
        IF ls_productgroup-amount > 0.
          ls_item-debit_credit_code = 'H'.
        ELSE.
          ls_item-debit_credit_code = 'S'.
        ENDIF.
        ls_item-document_item_text = ls_req-document_header_text.
        ls_item-assignment_reference = '销售暂估收入过账'.
        "账户分配
        ls_item-account_assignment-profit_center = 'PGH00'.
        APPEND ls_item TO ls_req-item.
      ENDLOOP.

      "3（不分组，所有条目生成一条分录）
      SELECT SUM( estimatedtaxamount ) AS amount
        FROM @lt_result AS a
       WHERE a~companycode  = @ls_tmp-companycode
         AND a~transactioncurrency  = @ls_tmp-transactioncurrency
        INTO @DATA(lv_amount).
      lv_itm = lv_itm + 1.
      "总帐
      CLEAR:ls_item.
      ls_item-reference_document_item = lv_itm.
      ls_item-glaccount-content = '2221160401'.
      ls_item-amount_in_transaction_currency-content = lv_amount * -1.
      ls_item-amount_in_transaction_currency-currency_code = ls_tmp-transactioncurrency.
      IF lv_amount > 0.
        ls_item-debit_credit_code = 'H'.
      ELSE.
        ls_item-debit_credit_code = 'S'.
      ENDIF.
      ls_item-document_item_text = ls_req-document_header_text.
      ls_item-assignment_reference = '销售暂估收入过账'.
      "账户分配
      ls_item-account_assignment-profit_center = 'PGH00'.
      APPEND ls_item TO ls_req-item.
      TRY .
          DATA(lv_uuid_zg) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_tab-journal_entry = ls_req.
      ls_tab-message_header-id-content = lv_uuid_zg.
      APPEND ls_tab TO request-journal_entry_bulk_create_requ-journal_entry_create_request.


*----------------冲销暂估---------
      CLEAR: ls_req,ls_tab,lv_itm,o_resp.
      ls_req-original_reference_document_ty = 'BKPFF'.
      ls_req-business_transaction_type = 'RFBU'.
      ls_req-accounting_document_type = 'DA'.
      ls_req-company_code = ls_tmp-companycode.
      ls_req-document_date = ls_calendardate-lastdayofmonthdate + 1.
      ls_req-posting_date = ls_calendardate-lastdayofmonthdate + 1.
      ls_req-created_by_user = sy-uname.
      ls_req-document_header_text = |冲销{ ls_tmp-fiscalyear }年{ ls_tmp-fiscalperiod }月销售暂估收入过账|.
      LOOP AT lt_soldtoparty INTO ls_soldtoparty.
        lv_itm = lv_itm + 1.
        CLEAR:ls_debtor_item.
        ls_debtor_item-reference_document_item = lv_itm.
        ls_debtor_item-debtor = ls_soldtoparty-soldtoparty.
        ls_debtor_item-altv_recncln_accts-content = '1122010110'.

        ls_debtor_item-amount_in_transaction_currency-content = ls_soldtoparty-amount * -1.
        ls_debtor_item-amount_in_transaction_currency-currency_code = ls_tmp-transactioncurrency.
        IF ls_soldtoparty-amount > 0.
          ls_debtor_item-debit_credit_code = 'S'.
        ELSE.
          ls_debtor_item-debit_credit_code = 'H'.
        ENDIF.
        ls_debtor_item-assignment_reference = '冲销销售暂估收入过账'.
        ls_debtor_item-document_item_text = ls_req-document_header_text.
        APPEND ls_debtor_item TO ls_req-debtor_item.
      ENDLOOP.
      LOOP AT lt_productgroup INTO ls_productgroup.
        lv_itm = lv_itm + 1.
        "总帐
        CLEAR:ls_item.
        ls_item-reference_document_item = lv_itm.
        CASE ls_productgroup-accountdetnproductgroup.
          WHEN 'Z1'.
            ls_item-glaccount-content = '6001020101'.
          WHEN 'Z2'.
            ls_item-glaccount-content = '6001050201'.
          WHEN 'Z3'.
            ls_item-glaccount-content = '6001020821'.
          WHEN 'Z4' OR 'Z9'.
            ls_item-glaccount-content = '6001020899'.
        ENDCASE.

        ls_item-amount_in_transaction_currency-content = ls_productgroup-amount .
        ls_item-amount_in_transaction_currency-currency_code = ls_tmp-transactioncurrency.
        IF ls_productgroup-amount > 0.
          ls_item-debit_credit_code = 'H'.
        ELSE.
          ls_item-debit_credit_code = 'S'.
        ENDIF.
        ls_item-document_item_text = ls_req-document_header_text.
        ls_item-assignment_reference = '冲销销售暂估收入过账'.
        "账户分配
        ls_item-account_assignment-profit_center = 'PGH00'.
        APPEND ls_item TO ls_req-item.
      ENDLOOP.

      lv_itm = lv_itm + 1.
      "总帐
      CLEAR:ls_item.
      ls_item-reference_document_item = lv_itm.
      ls_item-glaccount-content = '2221160401'.
      ls_item-amount_in_transaction_currency-content = lv_amount.
      ls_item-amount_in_transaction_currency-currency_code = ls_tmp-transactioncurrency.
      IF lv_amount > 0.
        ls_item-debit_credit_code = 'H'.
      ELSE.
        ls_item-debit_credit_code = 'S'.
      ENDIF.
      ls_item-document_item_text = ls_req-document_header_text.
      ls_item-assignment_reference = '冲销销售暂估收入过账'.
      "账户分配
      ls_item-account_assignment-profit_center = 'PGH00'.
      APPEND ls_item TO ls_req-item.
      TRY .
          DATA(lv_uuid_cxzg) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_tab-journal_entry = ls_req.
      ls_tab-message_header-id-content = lv_uuid_cxzg.
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

      LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat INTO DATA(ls_confirmat).

        CASE ls_confirmat-message_header-reference_id-content.
          WHEN lv_uuid_zg.
            DATA(lv_accounting_zg) = ls_confirmat-journal_entry_create_confirmat-accounting_document.
            DATA(lv_year_zg) = ls_confirmat-journal_entry_create_confirmat-fiscal_year.
          WHEN lv_uuid_cxzg.
            DATA(lv_accounting_cxzg) = ls_confirmat-journal_entry_create_confirmat-accounting_document.
            DATA(lv_year_cxzg) = ls_confirmat-journal_entry_create_confirmat-fiscal_year.
        ENDCASE.

        IF lv_accounting_zg = '0000000000'.
          DATA lv_error TYPE string.
          o_resp-msgty = 'E'.
          LOOP AT ls_confirmat-log-item INTO DATA(ls_item_log).
            APPEND VALUE #(
                     %msg      = new_message_with_text(
                             severity  = if_abap_behv_message=>severity-information
                             text      = ls_item_log-note
                         )
              )  TO reported-zc_query_fi008.
            lv_error = lv_error && ls_item_log-note && '/'.
          ENDLOOP.
        ELSE.
          o_resp-msgty = 'S'.
        ENDIF.

      ENDLOOP.


      IF  o_resp-msgty = 'S'.
        SELECT *
            FROM @lt_result AS a
           WHERE a~companycode = @ls_tmp-companycode
             AND a~transactioncurrency = @ls_tmp-transactioncurrency
            INTO TABLE @DATA(lt_data).
        LOOP AT lt_data INTO DATA(ls_data).
          CLEAR: ls_zztfi013.
          MOVE-CORRESPONDING ls_data TO ls_zztfi013.
          ls_zztfi013-accountingdocument1 = lv_accounting_zg.
          ls_zztfi013-postingdate1 = ls_calendardate-lastdayofmonthdate.
          ls_zztfi013-accountingdocument2 = lv_accounting_cxzg.
          ls_zztfi013-postingdate2 = ls_calendardate-lastdayofmonthdate + 1.
          APPEND ls_zztfi013 TO lt_zztfi013.
        ENDLOOP.

        MODIFY zztfi013 FROM TABLE @lt_zztfi013.

      ELSE.
*        APPEND VALUE #(
*                        %msg      = new_message_with_text(
*                                severity  = if_abap_behv_message=>severity-information
*                                text      = lv_error
*                            )
*                 )  TO reported-zc_query_fi008.
        EXIT.
      ENDIF.



    ENDLOOP.



  ENDMETHOD.

  METHOD zzrev.


    DATA: lr_fi008 TYPE REF TO zzcl_query_fi008.
    DATA: lt_result TYPE TABLE OF zc_query_fi008.
    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.



    DATA ls_tab TYPE zjournal_entry_create_request.
    DATA ls_req TYPE zjournal_entry_create_reques18.
    DATA lv_itm TYPE n LENGTH 3.
    DATA o_resp TYPE zzs_rest_out.
    DATA(request) = VALUE zjournal_entry_bulk_create_req( ).


    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      DATA(lv_uuid) = key-uuid.
      APPEND VALUE #( name = 'COMPANYCODE'
                      range = VALUE #( ( low = key-uuid+0(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'FISCALYEAR'
                      range = VALUE #( ( low = key-uuid+4(4) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'FISCALPERIOD'
                      range = VALUE #( ( low = key-uuid+8(2) sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
      APPEND VALUE #( name = 'HASITBEENPROCESSED'
                     range = VALUE #( ( low = 'X' sign = 'I' option = 'EQ' ) ) ) TO lt_filters.
    ENDIF.

    "获取数据
    CREATE OBJECT lr_fi008.
    CALL METHOD lr_fi008->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    SORT lt_result BY accountingdocument1 accountingdocument2.
    DELETE ADJACENT DUPLICATES FROM lt_result COMPARING accountingdocument1 accountingdocument2.
    DATA: lt_jr  TYPE  TABLE FOR ACTION IMPORT i_journalentrytp~reverse.


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
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_root->get_text( ).
    ENDTRY.

    LOOP AT lt_result INTO DATA(ls_result).

*----------------暂估---------
      CLEAR: request,ls_req,ls_tab,lv_itm,o_resp.
      ls_req-original_reference_document_ty = 'BKPFF'.
      ls_req-business_transaction_type = 'RFBU'.
      ls_req-accounting_document_type = 'DA'.
      ls_req-company_code = ls_result-companycode.
      ls_req-created_by_user = sy-uname.
      ls_req-reversal_reference_document = ls_result-accountingdocument1 && ls_result-companycode && ls_result-postingdate1+0(4) .
      ls_req-reversal_date = sy-datlo.
      ls_req-reversal_reason = '01'.
      TRY .
          DATA(lv_uuid_zg) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_tab-journal_entry = ls_req.
      ls_tab-message_header-id-content = lv_uuid_zg.
      APPEND ls_tab TO request-journal_entry_bulk_create_requ-journal_entry_create_request.

*----------------冲销暂估---------
      CLEAR: ls_req,ls_tab,lv_itm,o_resp.
      ls_req-original_reference_document_ty = 'BKPFF'.
      ls_req-business_transaction_type = 'RFBU'.
      ls_req-accounting_document_type = 'DA'.
      ls_req-company_code = ls_result-companycode.
      ls_req-created_by_user = sy-uname.
      ls_req-reversal_reference_document = ls_result-accountingdocument2 && ls_result-companycode && ls_result-postingdate2+0(4) .
      ls_req-reversal_date = sy-datlo.
      ls_req-reversal_reason = '01'.
      TRY .
          DATA(lv_uuid_cxzg) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_tab-journal_entry = ls_req.
      ls_tab-message_header-id-content = lv_uuid_zg.
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


      LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat INTO DATA(ls_confirmat).

        CASE ls_confirmat-message_header-reference_id-content.
          WHEN lv_uuid_zg.
            DATA(lv_accounting_zg) = ls_confirmat-journal_entry_create_confirmat-accounting_document.
            DATA(lv_year_zg) = ls_confirmat-journal_entry_create_confirmat-fiscal_year.
*        WHEN lv_uuid_cxzg.
*          DATA(lv_accounting_cxzg) = ls_confirmat-journal_entry_create_confirmat-accounting_document.
*          DATA(lv_year_cxzg) = ls_confirmat-journal_entry_create_confirmat-fiscal_year.
        ENDCASE.

        IF lv_accounting_zg = '0000000000'.
          o_resp-msgty = 'E'.
          LOOP AT ls_confirmat-log-item INTO DATA(ls_item_log).
            APPEND VALUE #(
                     %msg      = new_message_with_text(
                             severity  = if_abap_behv_message=>severity-information
                             text      = ls_item_log-note
                         )
              )  TO reported-zc_query_fi008.
          ENDLOOP.
        ELSE.
          DELETE FROM zztfi013 WHERE accountingdocument1 = @ls_result-accountingdocument1
                                AND postingdate1 = @ls_result-postingdate1.
        ENDIF.

      ENDLOOP.



    ENDLOOP.







  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_fi008 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_fi008 IMPLEMENTATION.

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
