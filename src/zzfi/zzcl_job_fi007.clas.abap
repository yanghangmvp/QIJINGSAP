CLASS zzcl_job_fi007 DEFINITION
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



CLASS ZZCL_JOB_FI007 IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
          ( selname        = 'DATE'
            kind           = if_apj_dt_exec_object=>select_option
            datatype       = 'D'
            length         = 8
            param_text     = '查询日期'
            mandatory_ind  = abap_false
            changeable_ind = abap_true
            )

            ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA: lv_begin TYPE sy-datum.
    DATA: lv_end TYPE sy-datum.

    DATA: lr_fi010 TYPE REF TO zzcl_api_fi010.

    "获取输入参数内容"
    LOOP AT it_parameters INTO DATA(ls_param).
      CASE ls_param-selname.
        WHEN 'DATE'.
          lv_begin  = ls_param-low.
          lv_end  = ls_param-high.

      ENDCASE.
    ENDLOOP.

    IF lv_begin IS INITIAL.
      lv_begin = sy-datum - 1.
      lv_end = sy-datum.
    ENDIF.

    CREATE OBJECT lr_fi010.
    lr_fi010->process( iv_begin = lv_begin  iv_end = lv_end ).

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_parameters   TYPE if_apj_rt_exec_object=>tt_templ_val.
    APPEND VALUE #( selname = 'DATE' low = '20260401' high = '20260401'  option = 'BT' sign = 'I' ) TO lt_parameters.
    TRY.
        me->if_apj_rt_exec_object~execute( lt_parameters ).
      CATCH cx_apj_rt_content.
        "handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
