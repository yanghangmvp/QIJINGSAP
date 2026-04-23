CLASS zzcl_job_fi009 DEFINITION
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



CLASS ZZCL_JOB_FI009 IMPLEMENTATION.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lv_text     TYPE string,
          lv_severity TYPE c LENGTH 1.
    DATA: lv_job(1).
    DATA: lv_numb TYPE zzt_rest_append-zznumb VALUE 'FII011'.
    DATA: lr_fi011 TYPE REF TO zzcl_api_fi011.
    DATA: o_resp TYPE zzs_rest_out.
    DATA: lt_data TYPE zzt_fii011_in.
    DATA: lr_document TYPE RANGE OF zztfi001-reference1indocumentheader.
    DATA: lv_tbegin  TYPE abp_lastchange_tstmpl.
    DATA: lv_tend TYPE abp_lastchange_tstmpl.
    DATA: lr_timst TYPE RANGE OF abp_lastchange_tstmpl.

    lv_severity = if_bali_constants=>c_severity_status.

    "获取输入参数内容"
    LOOP AT it_parameters INTO DATA(ls_param).
      CASE ls_param-selname.
        WHEN 'REFERENC'.
          APPEND VALUE #( option = ls_param-option
                          sign   = ls_param-sign
                          low    = ls_param-low
                          high   = ls_param-high
                     ) TO lr_document.
      ENDCASE.
    ENDLOOP.

    SELECT SINGLE *
      FROM zzt_rest_append
     WHERE zznumb = @lv_numb
       AND zzappac = 'PUSH'
       AND zzappkey = 'COUNT'
      INTO @DATA(ls_append).

    IF lr_document[] IS NOT INITIAL.
      SELECT *
        FROM zztfi001
       WHERE datasource = 'A03'
         AND reference1indocumentheader IN @lr_document
         AND zztszt IS NOT INITIAL
        INTO TABLE @DATA(lt_zztfi001).
    ELSE.
      lv_tbegin = zzcl_comm_tool=>get_last_execute( lv_numb ).
      GET TIME STAMP FIELD lv_tend.
      APPEND VALUE #( low = lv_tbegin high = lv_tend sign = 'I' option = 'BT' ) TO lr_timst.

      SELECT *
        FROM zztfi001
       WHERE datasource = 'A03'
         AND zztszt IS NOT INITIAL
         AND zzskzt IS INITIAL
        INTO TABLE @lt_zztfi001.

      SELECT *
        FROM zztfi001
       WHERE datasource = 'A03'
         AND zztszt IS NOT INITIAL
         AND last_changed_at IN @lr_timst
         APPENDING TABLE @lt_zztfi001.
    ENDIF.

    DATA: lv_begin TYPE i,
          lv_end   TYPE i,
          lv_max   TYPE i,
          lv_curr  TYPE i,
          lv_pack  TYPE i,
          lv_times TYPE i.
    DATA: lt_tmp TYPE zzt_fii011_in.

    lv_pack = ls_append-zzappvalue.
    CREATE OBJECT lr_fi011.
    TRY.
        "记录日志
        DATA(l_log) = cl_bali_log=>create_with_header(
             header = cl_bali_header_setter=>create( object    = 'ZZ_ALO_API'
                                                     subobject = 'ZZ_ALO_API_SUB' ) ).

        "分包推送
        DATA(lines) = lines( lt_zztfi001 ).
        lv_times = ceil( CONV decfloat16( lines / lv_pack ) ).

        lv_text = |共分{ lv_times } 包执行,每包大小{ lv_pack }|.
        l_log->add_item(  item = cl_bali_free_text_setter=>create( severity = lv_severity text  = CONV #( lv_text ) ) ).

        DO lv_times TIMES.
          lv_curr = sy-index .
          lv_begin = lv_pack * ( lv_curr - 1 ) + 1 .
          lv_end = lv_pack * ( lv_curr ).
          CLEAR: lt_tmp.
          APPEND LINES OF lt_zztfi001 FROM lv_begin TO lv_end TO lt_tmp.

          "推送数据
          o_resp = lr_fi011->push( lt_tmp ).

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


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
       ( selname        = 'REFERENC'
         kind           = if_apj_dt_exec_object=>select_option
         datatype       = 'C'
         length         = 20
         param_text     = '外部凭证号'
         changeable_ind = abap_true )
         ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_parameters   TYPE if_apj_rt_exec_object=>tt_templ_val.

    APPEND VALUE #( selname = 'REFERENC'
                    sign = 'I'
                    option = 'EQ'
                    low = '32321'
               ) TO lt_parameters.

    TRY.
        me->if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_apj_rt_content.
        "handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
