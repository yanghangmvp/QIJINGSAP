CLASS lhc_zc_query_mm001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_query_mm001 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zc_query_mm001 RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zc_query_mm001.


    METHODS read FOR READ
      IMPORTING keys FOR READ zc_query_mm001 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_query_mm001.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zc_query_mm001 RESULT result.

    METHODS zpush FOR MODIFY
      IMPORTING keys FOR ACTION zc_query_mm001~zpush RESULT result.

ENDCLASS.

CLASS lhc_zc_query_mm001 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.



  METHOD read.
    DATA: lr_mm001 TYPE REF TO zzcl_query_mm001.
    DATA:lt_result TYPE TABLE OF zc_query_mm001.

    DATA:lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA:lt_range TYPE if_rap_query_filter=>tt_range_option.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( low = ls_key-%key-supplier
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.
    ENDLOOP.

    APPEND VALUE #(  name = 'SUPPLIER'
                     range = lt_range
    ) TO lt_filters.

    "获取数据
    CREATE OBJECT lr_mm001.
    CALL METHOD lr_mm001->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = lt_result.

    MOVE-CORRESPONDING lt_result TO result.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD zpush.

    DATA: lr_mm010 TYPE REF TO zzcl_api_mm010.
    DATA: o_resp TYPE zzs_rest_out.
    DATA: lt_in  TYPE zzt_mmi010_in.
    CREATE OBJECT lr_mm010.

    LOOP AT keys INTO DATA(key).
      APPEND  key-%key-supplier TO lt_in.

      APPEND VALUE #(
            %tky = key-%tky
            %param = CORRESPONDING #( key )
        ) TO result.
    ENDLOOP.


    o_resp = lr_mm010->push( lt_in ).

    APPEND VALUE #(
                    %msg      = new_message_with_text(
                            severity  = if_abap_behv_message=>severity-success
                            text      = '推送成功,结果请查看接口日志'
                        )
             )  TO reported-zc_query_mm001.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_mm001 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_mm001 IMPLEMENTATION.

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
