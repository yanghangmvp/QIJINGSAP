CLASS lhc_fi005 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR fi005 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR fi005 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ fi005 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK fi005.

    METHODS zpush FOR MODIFY
      IMPORTING keys FOR ACTION fi005~zpush RESULT result.

ENDCLASS.

CLASS lhc_fi005 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD zpush.
    DATA: lv_companycode TYPE RANGE OF zc_query_fi005-br_ent_cod,
          lv_zzyear      TYPE RANGE OF zc_query_fi005-zzyear,
          lv_zzmonth     TYPE RANGE OF zc_query_fi005-zzmonth.

    DATA: ls_zztta004 TYPE zztta004,
          lt_zztta004 TYPE TABLE OF zztta004.

    DATA: lr_fi005 TYPE REF TO zzcl_query_fi005.
    DATA: lt_result TYPE TABLE OF zc_query_fi005.

    DATA: lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA: lt_range TYPE if_rap_query_filter=>tt_range_option.

    "删除缓存表数据
    DELETE FROM zztta004.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc = 0.
      APPEND VALUE #( low = key-%key-uuid
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.
    ENDIF.

    APPEND VALUE #( name = 'UUID'
                    range = lt_range ) TO lt_filters.

    "获取数据
    CREATE OBJECT lr_fi005.
    CALL METHOD lr_fi005->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    lt_zztta004 = CORRESPONDING #( lt_result ).

    INSERT zztta004 FROM TABLE @lt_zztta004.

   DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZZ_JT_TA004'.
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
              iv_job_text = |TA-科目余额JOB|
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
                 )  TO reported-fi005.

    APPEND VALUE #(
                %tky-uuid = key-uuid
                %param = CORRESPONDING #( key )
            ) TO result.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_fi005 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_fi005 IMPLEMENTATION.

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
