CLASS lhc_zc_query_fi009 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zc_query_fi009 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zc_query_fi009 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zc_query_fi009 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zc_query_fi009.

    METHODS zpush FOR MODIFY
      IMPORTING keys FOR ACTION zc_query_fi009~zpush RESULT result.

ENDCLASS.

CLASS lhc_zc_query_fi009 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD zpush.


   DATA JOB TYPE REF TO zzcl_job_fi008.
      CREATE OBJECT JOB.
      JOB->if_apj_rt_run~execute( ).

*    DATA: lr_fi009 TYPE REF TO zzcl_api_fi009.
*    DATA: o_resp TYPE zzs_rest_out.
*    DATA: lt_in  TYPE zzt_fii009_in.
*    CREATE OBJECT lr_fi009.
*
*    LOOP AT keys INTO DATA(key).
*      APPEND  key-%key-uuid TO lt_in.
*
*      APPEND VALUE #(
*            %tky = key-%tky
*            %param = CORRESPONDING #( key )
*        ) TO result.
*    ENDLOOP.
*
*
*    o_resp = lr_fi009->push( i_req = lt_in ).

    APPEND VALUE #(
                    %msg      = new_message_with_text(
                            severity  = if_abap_behv_message=>severity-success
                            text      = '推送成功,结果请查看接口日志'
                        )
             )  TO reported-ZC_QUERY_FI009.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_zc_query_fi009 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zc_query_fi009 IMPLEMENTATION.

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
