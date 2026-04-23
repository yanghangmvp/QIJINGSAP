CLASS zzcl_job_fi001 DEFINITION
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



CLASS ZZCL_JOB_FI001 IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
       ( selname        = 'DOCNO'
         kind           = if_apj_dt_exec_object=>select_option
         datatype       = 'C'
         length         = 40
         param_text     = '单据号'
         changeable_ind = abap_true )
       ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA:lv_text     TYPE string,
         lv_severity TYPE c LENGTH 1.

    DATA: lv_begin TYPE i,
          lv_end   TYPE i,
          lv_max   TYPE i,
          lv_curr  TYPE i,
          lv_times TYPE i.
    DATA: lt_tmp TYPE TABLE OF zztta001.
    DATA: lv_sql        TYPE string,
          lv_sql_head   TYPE string,
          lv_sql_delete TYPE string,
          lv_sql_value  TYPE string,
          lt_sql_table  TYPE TABLE OF string,
          o_resp        TYPE zzs_rest_out.

    DATA: lt_field TYPE TABLE OF char30.

    lv_severity = if_bali_constants=>c_severity_status.

    lt_field = VALUE #( ( 'TYPE' )
                        ( 'BR_CTP_KEY' )
                        ( 'BR_CTP_COD' )
                        ( 'BR_CTP_DES' )
                        ( 'CREDIT_NUM' )
                        ( 'COUNTRY' )
                        ( 'CITY' )
                        ( 'PROPERTY' )
                        ( 'SYS_ID' )
                        ( 'DATEUPD' )
                        ).


    SELECT SINGLE *
      FROM zztfi006
     WHERE zzenumb = 'TA001'
      INTO @DATA(ls_conf).

    SELECT *
      FROM zztta001
      INTO TABLE @DATA(lt_ta001).

    "删除已有主键
    lv_sql_delete = |DELETE FROM { ls_conf-zztable };|.
    "推送数据
    zzcl_jdbc_ta_process=>send_ta( lv_sql_delete ).

*    lv_sql_head = |INSERT INTO { ls_conf-zzdatabase }.{ ls_conf-zztable }| &&
*                  |(TYPE, BR_CTP_KEY, BR_CTP_COD, BR_CTP_DES, CREDIT_NUM, COUNTRY, CITY, PROPERTY, SYS_ID, DATEUPD)|.

    lv_sql_head = |INSERT INTO { ls_conf-zztable }| &&
                  |(TYPE, BR_CTP_KEY, BR_CTP_COD, BR_CTP_DES, CREDIT_NUM, COUNTRY, CITY, PROPERTY, SYS_ID, DATEUPD) values|.

    TRY.
        "记录日志
        DATA(l_log) = cl_bali_log=>create_with_header(
             header = cl_bali_header_setter=>create( object    = 'ZZ_ALO_API'
                                                     subobject = 'ZZ_ALO_API_SUB' ) ).

        "分包推送
        DATA(lines) = lines( lt_ta001 ).
        lv_times = ceil( CONV decfloat16( lines / ls_conf-zzpack ) ).

        lv_text = |共分{ lv_times } 包执行,每包大小{ ls_conf-zzpack }|.
        l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).

        DO lv_times TIMES.
          lv_curr = sy-index .
          lv_begin = ls_conf-zzpack * ( lv_curr - 1 ) + 1 .
          lv_end = ls_conf-zzpack * ( lv_curr ).
          CLEAR: lt_tmp.
          APPEND LINES OF lt_ta001 FROM lv_begin TO lv_end TO lt_tmp.

          CLEAR: lv_sql.
          lv_sql = lv_sql_head.
          LOOP AT lt_tmp INTO DATA(ls_tmp).
            CLEAR: lv_sql_value.
*            lv_sql_value = | SELECT |.
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
*            lv_sql_value = lv_sql_value+0(lv_length) && | FROM dummy UNION ALL|.
            lv_sql_value = lv_sql_value+0(lv_length) && | ),|.

            lv_sql = lv_sql && lv_sql_value .
          ENDLOOP.

*          lv_length = strlen( lv_sql ) - 10.
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
