CLASS lhc_sd002 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR sd002 RESULT result.

ENDCLASS.

CLASS lhc_sd002 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_table_ztsd001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR sd001
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR sd001 RESULT result,
      zzprocess FOR MODIFY
        IMPORTING keys FOR ACTION sd001~zzprocess RESULT result.
ENDCLASS.

CLASS lhc_zr_table_ztsd001 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.



  METHOD get_instance_features.
    DATA: lv_abled_process TYPE abp_behv_op_ctrl.
    DATA: lv_disabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-disabled.
    DATA: lv_enabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.

    READ ENTITIES OF zr_table_ztsd001 IN LOCAL MODE
    ENTITY sd001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    LOOP AT results INTO DATA(ls_result).

      "已过账按钮不可编辑
      IF ls_result-zzxzt = '06'.
        lv_abled_process = lv_disabled.
      ELSE.
        lv_abled_process = lv_enabled.
      ENDIF.


      APPEND VALUE #( %tky = ls_result-%tky
                      %action-zzprocess = lv_abled_process

                      )
      TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD zzprocess.

    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZZ_JT_SD001'.
    DATA job_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_parameter TYPE cl_apj_rt_api=>ty_job_parameter_value.
    DATA range_value TYPE cl_apj_rt_api=>ty_value_range.
    DATA job_name TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.


    READ ENTITIES OF zr_table_ztsd001 IN LOCAL MODE
    ENTITY sd001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).


    LOOP AT results INTO DATA(ls_result).
      APPEND VALUE #( low = ls_result-purchaseorderbycustomer sign = 'I' option = 'EQ'  ) TO job_parameter-t_value.
    ENDLOOP.
    job_parameter-name = 'REFNO'.
    APPEND job_parameter TO job_parameters.

    job_start_info-start_immediately = abap_true.

    TRY.
        cl_apj_rt_api=>schedule_job(
              EXPORTING
              iv_job_template_name = job_template_name
              iv_job_text = |销售订单处理流程-{ sy-datum }{ sy-uzeit }-{ sy-uname }|
              is_start_info = job_start_info
              it_job_parameter_value = job_parameters
              IMPORTING
              ev_jobname  = job_name
              ev_jobcount = job_count
              ).
      CATCH cx_root INTO DATA(lr_root).
        DATA(lv_text) = lr_root->get_longtext( ).
    ENDTRY.

    APPEND VALUE #( %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-success
                   text       = '已发送后台处理，请稍后刷新界面查看处理结果'
                  )
               )  TO reported-sd001.


    READ ENTITIES OF zr_table_ztsd001 IN LOCAL MODE
    ENTITY sd001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tmp).

    result = VALUE #( FOR ls_tmp IN lt_tmp ( %tky      = ls_tmp-%tky
                                             %param    = ls_tmp
                                           ) ).



  ENDMETHOD.

ENDCLASS.
