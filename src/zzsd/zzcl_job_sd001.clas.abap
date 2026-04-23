CLASS zzcl_job_sd001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_JOB_SD001 IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
       ( selname        = 'REFNO'
         kind           = if_apj_dt_exec_object=>select_option
         datatype       = 'C'
         length         = 20
         param_text     = '外围系统单据编号'

         changeable_ind = abap_true )
       ( selname        = 'VKORG'
         kind           = if_apj_dt_exec_object=>select_option
         datatype       = 'C'
         length         = 4
         param_text     = '销售组织'
         changeable_ind = abap_true )

       ( selname        = 'DMSTYPE'
         kind           = if_apj_dt_exec_object=>select_option
         datatype       = 'C'
         length         = 4
         param_text     = '外部系统订单类型'
         changeable_ind = abap_true )

         ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA:lv_text     TYPE string,
         lv_severity TYPE c LENGTH 1.
    DATA: lr_vkorg TYPE RANGE OF i_salesorder-salesorganization.
    DATA: lr_dmstype TYPE RANGE OF zztsd001-zdmssotype.
    DATA: lr_refno TYPE RANGE OF zztsd001-purchaseorderbycustomer.
    DATA lr_process TYPE REF TO zzcl_job_vl_process.
    DATA o_resp TYPE zzs_rest_out.

    lv_severity = if_bali_constants=>c_severity_status.

    "获取输入参数内容"
    LOOP AT it_parameters INTO DATA(ls_param).
      CASE ls_param-selname.
        WHEN 'REFNO'.

          APPEND VALUE #(
                  sign   = ls_param-sign
                  option = ls_param-option
                  low    = ls_param-low
                  high   = ls_param-high  ) TO lr_refno.

        WHEN 'VKORG'.
          APPEND VALUE #(
                  sign   = ls_param-sign
                  option = ls_param-option
                  low    = ls_param-low
                  high   = ls_param-high  ) TO lr_vkorg.

        WHEN 'DMSTYPE'.
          APPEND VALUE #(
                  sign   = ls_param-sign
                  option = ls_param-option
                  low    = ls_param-low
                  high   = ls_param-high  ) TO lr_dmstype.
      ENDCASE.
    ENDLOOP.

    SELECT *
      FROM zztsd001
     WHERE salesorganization IN @lr_vkorg
       AND purchaseorderbycustomer IN @lr_refno
       AND zdmssotype IN @lr_dmstype
       AND zzxzt <> '06'
      INTO TABLE @DATA(lt_sd001).
    TRY.
        "记录日志
        DATA(l_log) = cl_bali_log=>create_with_header(
             header = cl_bali_header_setter=>create( object    = 'ZZ_ALO_API'
                                                     subobject = 'ZZ_ALO_API_SUB' ) ).

        "锁对象
        DATA(lr_lock_object) =  cl_abap_lock_object_factory=>get_instance(
                                  EXPORTING iv_name = 'EZ_SD001' ).

        LOOP AT lt_sd001 INTO DATA(ls_sd001).

          lr_process = NEW zzcl_job_vl_process( iv_num = ls_sd001-purchaseorderbycustomer ).
          lv_text = |外部订单:{ ls_sd001-purchaseorderbycustomer }  开始执行|.
          l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).

          "加锁
          TRY.
              lr_lock_object->enqueue(
                        it_parameter =  VALUE #( ( name = 'REFNO' value =  REF #( ls_sd001-purchaseorderbycustomer ) ) )
                        it_table_mode = VALUE #( ( table_name = 'ZZTSD001' mode = 'E'  ) )
                        _scope = '1'
                         ).
            CATCH cx_abap_lock_failure INTO DATA(lr_exc).
              lv_text = lr_exc->get_longtext( ).
              l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
              CONTINUE.
            CATCH cx_abap_foreign_lock INTO DATA(lr_foreign).
              lv_text = lr_foreign->get_longtext( ).
              l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
              CONTINUE.
          ENDTRY.

*            01销售交货单已创建
*            02销售交货单已拣配
*            03销售交货单已过账
*            04销售交货单已POD
*            05销售开票已创建
*            06销售开票已过账
          o_resp-msgty = 'S'.
          IF ls_sd001-zzxzt = ''.
            "交货单创建
            o_resp =  lr_process->create_vl( ).
            ls_sd001-zzxzt = '01'.

            lv_text = |交货单创建：状态{ o_resp-msgty }  消息{ o_resp-msgtx }|.
            l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
          ENDIF.

          IF ls_sd001-zzxzt = '01' AND o_resp-msgty = 'S'.
            "交货单已拣配
            o_resp =  lr_process->pick_vl( ).
            ls_sd001-zzxzt = '02'.
            lv_text = |交货单已拣配：状态{ o_resp-msgty }  消息{ o_resp-msgtx }|.
            l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
          ENDIF.

          IF ls_sd001-zzxzt = '02' AND o_resp-msgty = 'S'.
            "交货单已过账
            o_resp =  lr_process->post_vl( ).
            ls_sd001-zzxzt = '03'.
            lv_text = |交货单已过账：状态{ o_resp-msgty }  消息{ o_resp-msgtx }|.
            l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
          ENDIF.

          IF ls_sd001-zzxzt = '03' AND o_resp-msgty = 'S'.
            "交货单已POD
            o_resp =  lr_process->pod_vl( ).
            ls_sd001-zzxzt = '04'.
            lv_text = |交货单已POD：状态{ o_resp-msgty }  消息{ o_resp-msgtx }|.
            l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
          ENDIF.

          IF ls_sd001-zzxzt = '04' AND o_resp-msgty = 'S'.
            "销售开票已创建
            o_resp =  lr_process->create_gr( ).
            ls_sd001-zzxzt = '05'.
            lv_text = |销售开票已创建：状态{ o_resp-msgty }  消息{ o_resp-msgtx }|.
            l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
          ENDIF.

          IF ls_sd001-zzxzt = '05' AND o_resp-msgty = 'S'.
            "销售开票已过账
            o_resp =  lr_process->post_gr( ).
            ls_sd001-zzxzt = '06'.
            lv_text = |销售开票已过账：状态{ o_resp-msgty }  消息{ o_resp-msgtx }|.
            l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).
          ENDIF.

          lv_text = |外部订单:{ ls_sd001-purchaseorderbycustomer } 执行结束|.
          l_log->add_item( item = cl_bali_free_text_setter=>create( severity = lv_severity text     = CONV #( lv_text ) ) ).
          FREE: lr_process.
        ENDLOOP.

        "存储日志
        cl_bali_log_db=>get_instance( )->save_log_2nd_db_connection( log = l_log assign_to_current_appl_job = abap_true ).
      CATCH cx_root INTO DATA(lr_root).
        DATA(lr_error) = lr_root->get_longtext( ).
    ENDTRY.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_parameters   TYPE if_apj_rt_exec_object=>tt_templ_val.

    TRY.
        me->if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_apj_rt_content.
        "handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
