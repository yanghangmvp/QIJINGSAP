CLASS lhc_fi004 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR fi004 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR fi004 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ fi004 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK fi004.

    METHODS zpush FOR MODIFY
      IMPORTING keys FOR ACTION fi004~zpush RESULT result.

    METHODS zchange FOR MODIFY
      IMPORTING keys FOR ACTION fi004~zchange RESULT result.

    METHODS exceluploaddialog FOR MODIFY
      IMPORTING keys FOR ACTION fi004~exceluploaddialog.

ENDCLASS.

CLASS lhc_fi004 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD zpush.

    DATA: ls_zztta003 TYPE zztta003,
          lt_zztta003 TYPE TABLE OF zztta003.

    DATA: lr_fi004 TYPE REF TO zzcl_query_fi004.
    DATA: lt_result TYPE TABLE OF zc_query_fi004.

    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    "删除缓存表数据
    DELETE FROM zztta003.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      APPEND VALUE #( low = key-%key-uuid
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.
    ENDIF.

    APPEND VALUE #( name = 'UUID'
                    range = lt_range ) TO lt_filters.

    "获取数据
    CREATE OBJECT lr_fi004.
    CALL METHOD lr_fi004->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    lt_zztta003 = CORRESPONDING #( lt_result ).

    INSERT zztta003 FROM TABLE @lt_zztta003.

    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZZ_JT_TA003'.
    DATA job_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_parameter TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA range_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA job_name TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.

    job_start_info-start_immediately = abap_true.
    TRY.
        cl_apj_rt_api=>schedule_job(
              EXPORTING
              iv_job_template_name = job_template_name
              iv_job_text = |TA-综合管理纬度JOB|
              is_start_info = job_start_info
              it_job_parameter_value = job_parameters
              IMPORTING
              ev_jobname  = job_name
              ev_jobcount = job_count
              ).
      CATCH cx_root INTO DATA(lr_root).
        DATA(lv_text) = lr_root->get_longtext( ).
    ENDTRY.

    APPEND VALUE #( %tky-uuid = key-uuid
                    %msg      = new_message_with_text(
                                severity  = if_abap_behv_message=>severity-success
                                text      = '推送成功'
                            )
                 )  TO reported-fi004.

    APPEND VALUE #(
                %tky-uuid = key-uuid
                %param = CORRESPONDING #( key )
            ) TO result.

  ENDMETHOD.

  METHOD zchange.
    DATA: lr_fi004 TYPE REF TO zzcl_query_fi004.
    DATA: lt_result TYPE TABLE OF zc_query_fi004.

    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    DATA: ls_ztfi012 TYPE zztfi012.

    DATA: lv_text TYPE string.

    LOOP AT keys INTO DATA(key).
      DATA(ls_param) = key-%param.

      APPEND VALUE #( low = key-%key-uuid
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.

    ENDLOOP.

    APPEND VALUE #( name = 'UUID'
                    range = lt_range ) TO lt_filters.

    "获取数据
    CREATE OBJECT lr_fi004.
    CALL METHOD lr_fi004->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.
    SORT lt_result BY uuid.

    LOOP AT keys INTO key.
      READ TABLE lt_result INTO DATA(ls_result) WITH KEY uuid = key-uuid BINARY SEARCH.
      IF sy-subrc = 0.
        IF ls_result-zzedit IS NOT INITIAL.

          ls_ztfi012-zzdefault_dec = ls_result-amount = ls_param-zzdefault_dec.
          ls_ztfi012-zzdefault = ls_result-note = ls_param-zzdefault.

          ls_ztfi012-fiscalyear = ls_result-zzyear.
          ls_ztfi012-companycode = ls_result-ent_cod.
          ls_ztfi012-accountingdocument = ls_result-voucher.
          ls_ztfi012-ledgergllineitem = ls_result-line.
          ls_ztfi012-zzitemtype = ls_result-type.
          ls_ztfi012-zzcode = ls_result-sub_cod.

          MODIFY zztfi012 FROM @ls_ztfi012.

          APPEND VALUE #(
               %tky-uuid = key-uuid
               %param = CORRESPONDING #( ls_result )
            ) TO result.

          lv_text = |{ ls_result-voucher },{ ls_result-line },{ ls_result-type },{ ls_result-sub_cod }修改成功|.

          APPEND VALUE #( %tky = key-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-success
                          text = lv_text )
                     ) TO reported-fi004.
        ELSE.

          lv_text = |{ ls_result-voucher },{ ls_result-line },{ ls_result-type },{ ls_result-sub_cod }不允许修改|.

          APPEND VALUE #( %tky = key-%tky
                          %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = lv_text )
                     ) TO reported-fi004.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD exceluploaddialog.

    DATA: lt_ztfi012 TYPE TABLE OF zztfi012.

    LOOP AT keys INTO DATA(key).
      APPEND VALUE #( fiscalyear = key-%param-fiscalyear
                      companycode = key-%param-companycode
                      accountingdocument = key-%param-accountingdocument
                      ledgergllineitem = key-%param-ledgergllineitem
                      zzitemtype = key-%param-zzitemtype
                      zzcode = key-%param-zzcode
                      zzdefault = key-%param-zzdefault
                      zzdefault_dec = key-%param-zzdefault_dec
                 ) TO lt_ztfi012.
    ENDLOOP.

    MODIFY zztfi012 FROM TABLE @lt_ztfi012.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_fi004 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_fi004 IMPLEMENTATION.

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
