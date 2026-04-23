CLASS zzcl_job_fi002 DEFINITION
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



CLASS ZZCL_JOB_FI002 IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA:lv_text     TYPE string,
         lv_severity TYPE c LENGTH 1.

    DATA: lv_begin TYPE i,
          lv_end   TYPE i,
          lv_max   TYPE i,
          lv_curr  TYPE i,
          lv_times TYPE i.
    DATA: lt_tmp TYPE TABLE OF zztta002.
    DATA: lv_sql        TYPE string,
          lv_sql_head   TYPE string,
          lv_sql_delete TYPE string,
          lv_sql_value  TYPE string,
          lt_sql_table  TYPE TABLE OF string,
          o_resp        TYPE zzs_rest_out.

    DATA: lt_field TYPE TABLE OF char30.

    DATA: lv_month TYPE numc2.

    lv_severity = if_bali_constants=>c_severity_status.

    lt_field = VALUE #(
                        (   'ZZYEAR'    )
                        (   'ZZMONTH'   )
                        (   'GP_ENT_COD'    )
                        (   'GP_ENT_DES'    )
						(   'ENT_COD'   )
						(   'ENT_DES'   )
						(   'VOUCHER'   )
						(   'LINE'  )
						(   'POST_DATE' )
						(   'DOC_DATE'  )
						(   'DIRECTION' )
						(   'GP_ACC_COD'    )
						(   'GP_ACC_DES'    )
						(   'BR_ACC_COD'    )
						(   'BR_ACC_DES'    )
						(   'BR_ACC_AREA'    )
						(   'BR_CTP_KEY'    )
						(   'BR_CUS_COD'    )
						(   'BR_CUS_DES'    )
						(   'GP_CTP_COD'    )
						(   'GP_CTP_DES'    )
						(   'CREDIT_NUM'    )
						(   'BR_SUP_COD'    )
						(   'BR_SUP_DES'    )
						(   'ZZMOVE'    )
						(   'CF_COD'    )
						(   'TEXT'  )
						(   'CURRENCY'  )
						(   'AMOUNT'    )
						(   'CURRENCY_T'    )
						(   'AMOUNT_T'  )
						(   'SYS_ID'    )
						(   'DATEUPD'   )
                        ).


    SELECT SINGLE *
      FROM zztfi006
     WHERE zzenumb = 'TA002'
      INTO @DATA(ls_conf).

    SELECT *
      FROM zztta002
      INTO TABLE @DATA(lt_ta002).

    "删除已有主键
    READ TABLE lt_ta002 INTO DATA(ls_ta002) INDEX 1.
    IF sy-subrc = 0.
      lv_sql_delete = |DELETE FROM { ls_conf-zztable } | &&
                      |WHERE ENT_COD = '{ ls_ta002-ent_cod }' AND | &&
                      |YEAR = '{ ls_ta002-zzyear }' AND | &&
                      |MONTH = '{ ls_ta002-zzmonth }';|.
      "推送数据
      zzcl_jdbc_ta_process=>send_ta( lv_sql_delete ).
    ENDIF.

    lv_sql_head = |INSERT INTO { ls_conf-zztable }| &&
                  |(YEAR, MONTH, GP_ENT_COD, GP_ENT_DES, ENT_COD, ENT_DES, VOUCHER, LINE| &&
                  |,POST_DATE, DOC_DATE, DIRECTION, GP_ACC_COD, GP_ACC_DES, BR_ACC_COD, BR_ACC_DES, BR_ACC_AREA, BR_CTP_KEY| &&
                  |,BR_CUS_COD, BR_CUS_DES, GP_CTP_COD, GP_CTP_DES, CREDIT_NUM, BR_SUP_COD, BR_SUP_DES, MOVE| &&
                  |,CF_COD, TEXT, CURRENCY, AMOUNT, CURRENCY_T, AMOUNT_T, SYS_ID, DATEUPD) values|.

    TRY.
        "记录日志
        DATA(l_log) = cl_bali_log=>create_with_header(
             header = cl_bali_header_setter=>create( object    = 'ZZ_ALO_API'
                                                     subobject = 'ZZ_ALO_API_SUB' ) ).

        "分包推送
        DATA(lines) = lines( lt_ta002 ).
        lv_times = ceil( CONV decfloat16( lines / ls_conf-zzpack ) ).

        lv_text = |共分{ lv_times } 包执行,每包大小{ ls_conf-zzpack }|.
        l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).

        DO lv_times TIMES.
          lv_curr = sy-index .
          lv_begin = ls_conf-zzpack * ( lv_curr - 1 ) + 1 .
          lv_end = ls_conf-zzpack * ( lv_curr ).
          CLEAR: lt_tmp.
          APPEND LINES OF lt_ta002 FROM lv_begin TO lv_end TO lt_tmp.

          CLEAR: lv_sql.
          lv_sql = lv_sql_head.
          LOOP AT lt_tmp INTO DATA(ls_tmp).
            CLEAR: lv_sql_value.
            lv_sql_value = | ( |.

            LOOP  AT lt_field INTO DATA(ls_field).
              ASSIGN COMPONENT ls_field OF STRUCTURE ls_tmp TO FIELD-SYMBOL(<fs_value>).
              IF <fs_value> IS ASSIGNED.
                lv_sql_value = lv_sql_value && |'{ <fs_value> }',|.
              ELSE.
                lv_sql_value = lv_sql_value && |'',|.
              ENDIF.
            ENDLOOP.
            DATA(lv_length) = strlen( lv_sql_value ) - 1.
            lv_sql_value = lv_sql_value+0(lv_length) && | ),|.

            lv_sql = lv_sql && lv_sql_value .
          ENDLOOP.

          lv_length = strlen( lv_sql ) - 1.
          lv_sql = lv_sql+0(lv_length) && ';'.
          "推送数据
          o_resp =  zzcl_jdbc_ta_process=>send_ta( lv_sql ).

          lv_text = |当前包序号:{ lv_curr },执行结果{ o_resp-msgty },消息{ o_resp-msgtx }|.
          l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity  text  = CONV #( lv_text ) ) ).
        ENDDO.


        lv_text = |执行结束|.
        l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity  text  = CONV #( lv_text ) ) ).
        "存储日志
        cl_bali_log_db=>get_instance( )->save_log_2nd_db_connection( log = l_log assign_to_current_appl_job = abap_true ).
      CATCH cx_web_http_client_error
       cx_bali_runtime INTO DATA(lx_error).
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
