CLASS zzcl_query_fi007 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_result TYPE TABLE OF zc_query_fi007.

*   rap 查询提供者接口
    INTERFACES if_rap_query_provider .

    METHODS get_data
      IMPORTING io_request  TYPE REF TO if_rap_query_request
                io_response TYPE REF TO if_rap_query_response
      RAISING   cx_rap_query_prov_not_impl
                cx_rap_query_provider.

    METHODS read_data
      IMPORTING
        it_filters TYPE if_rap_query_filter=>tt_name_range_pairs
      EXPORTING
        et_result  TYPE  tt_result
        et_flag    TYPE c.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_FI007 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi007.
    DATA: lv_flag TYPE c.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range

        CLEAR: lv_flag.
        me->read_data(
           EXPORTING
             it_filters = lt_filters
           IMPORTING
             et_result = lt_result
             et_flag   = lv_flag ).

*&---====================2.数据获取后，select 排序/过滤/分页/返回设置
*&---设置过滤器
        "选择屏幕为小于当前期间，批量查询是会过滤掉非选择屏幕选定的值，但是穿透时如果不通过主键进行筛选会导致无法确定唯一值
        "限制穿透时才走通用过滤器
        IF lv_flag IS NOT INITIAL.
          zzcl_query_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_result ).
        ENDIF.
*&---设置记录总数
        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.
*&---设置排序
        zzcl_query_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_result ).
*&---设置按页查询
        zzcl_query_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_result ).
*&---返回数据
        io_response->set_data( lt_result ).

      CATCH cx_root INTO DATA(lr_root).
        DATA(lv_msg) = lr_root->get_longtext( ).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD read_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi007,
          ls_result TYPE zc_query_fi007.

    DATA: lr_companycode TYPE RANGE OF zc_query_fi007-ent_cod,
          lr_zzyear      TYPE RANGE OF zc_query_fi007-zzyear,
          lr_zzmonth     TYPE RANGE OF zc_query_fi007-zzmonth,
          lr_uuid        TYPE RANGE OF zc_query_fi007-uuid.

    DATA: lv_companycode TYPE zc_query_fi007-ent_cod.

    "当期年度期间
    DATA: lv_fiscalyear   TYPE i_accountingdocumentjournal-fiscalyear,
          lv_fiscalperiod TYPE i_accountingdocumentjournal-fiscalperiod.

    DATA: lv_date(5) TYPE p.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'ENT_COD'.
          lr_companycode = CORRESPONDING #( ls_filter-range ).
          lv_companycode = lr_companycode[ 1 ]-low.
        WHEN 'ZZYEAR'.
          lr_zzyear = CORRESPONDING #( ls_filter-range ).
          lv_fiscalyear = lr_zzyear[ 1 ]-low.
        WHEN 'ZZMONTH'.
          lr_zzmonth = CORRESPONDING #( ls_filter-range ).
          lv_fiscalperiod = lr_zzmonth[ 1 ]-low.
        WHEN 'UUID'.
          et_flag = abap_true.

          lr_uuid = CORRESPONDING #( ls_filter-range ).

          SPLIT lr_uuid[ 1 ]  AT '~' INTO TABLE DATA(lt_range).

          READ TABLE lt_range INTO DATA(ls_range) INDEX 6.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_companycode = ls_range.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 7.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_fiscalyear = ls_range.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 8.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_fiscalperiod = ls_range.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    "当前月日期范围
    SELECT SINGLE *
      FROM i_calendardate
     WHERE calendaryear = @lv_fiscalyear
       AND calendarmonth = @lv_fiscalperiod
      INTO @DATA(ls_calendardate).

    SELECT companycode,
           @lv_fiscalyear AS fiscalyear,
           @lv_fiscalperiod AS fiscalperiod,
           glaccount,
           customer,
           supplier,
           CAST( @space AS CHAR( 10 ) ) AS td,
           postingdate,
           companycodecurrency,
           debitamountincocodecrcy,
           creditamountincocodecrcy
      FROM i_accountingdocumentjournal( p_language = @sy-langu )
     WHERE ledger = '0L'
       AND companycode = @lv_companycode
       AND ( ( fiscalyear = @lv_fiscalyear AND fiscalperiod <= @lv_fiscalperiod ) OR
           fiscalyear < @lv_fiscalyear )
*       AND financialaccounttype IN ( 'K', 'D' )
       AND ( glaccount LIKE '1122%' OR glaccount LIKE '2202%' OR glaccount LIKE '1221%' OR glaccount LIKE '2241%' OR glaccount LIKE '1123%' OR glaccount LIKE '2703%' )
*       AND clearingaccountingdocument IS INITIAL
       AND ( clearingdate IS INITIAL OR clearingdate > @ls_calendardate-lastdayofmonthdate )
       AND reversalreferencedocument IS INITIAL
       AND isopenitemmanaged = 'X'
      INTO TABLE @DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      CLEAR: lv_date.

      lv_date = sy-datum - <fs_data>-postingdate.

      IF <fs_data>-glaccount CP '1531*'
         OR <fs_data>-glaccount CP '1532*'
         OR <fs_data>-glaccount CP '2701*'
         OR <fs_data>-glaccount CP '2702*'
         OR <fs_data>-glaccount CP '2703*'.

        IF lv_date <= 365.
          <fs_data>-td = 'TD03'.
        ELSEIF 365 < lv_date AND lv_date <= 730.
          <fs_data>-td = 'TD04'.
        ELSEIF 730 < lv_date AND lv_date <= 1095.
          <fs_data>-td = 'TD05'.
        ELSEIF 1095 < lv_date AND lv_date <= 1460.
          <fs_data>-td = 'TD06'.
        ELSEIF 1460 < lv_date AND lv_date <= 1825.
          <fs_data>-td = 'TD07'.
        ELSEIF lv_date > 1825.
          <fs_data>-td = 'TD09'.
        ENDIF.

      ELSEIF <fs_data>-glaccount CP '2231*'
          OR <fs_data>-glaccount CP '2501*'
          OR <fs_data>-glaccount CP '2502*'.

        IF lv_date <= 365.
          <fs_data>-td = 'TD03'.
        ELSEIF 365 < lv_date AND lv_date <= 730.
          <fs_data>-td = 'TD04'.
        ELSEIF 730 < lv_date AND lv_date <= 1825.
          <fs_data>-td = 'TD08'.
        ELSEIF lv_date > 1825.
          <fs_data>-td = 'TD09'.
        ENDIF.

      ELSE.

        IF lv_date <= 91.
          <fs_data>-td = 'TD01'.
        ELSEIF 91 < lv_date AND lv_date <= 365.
          <fs_data>-td = 'TD02'.
        ELSEIF 365 < lv_date AND lv_date <= 730.
          <fs_data>-td = 'TD04'.
        ELSEIF 730 < lv_date AND lv_date <= 1095.
          <fs_data>-td = 'TD05'.
        ELSEIF 1095 < lv_date AND lv_date <= 1460.
          <fs_data>-td = 'TD06'.
        ELSEIF 1460 < lv_date AND lv_date <= 1825.
          <fs_data>-td = 'TD07'.
        ELSEIF lv_date > 1825.
          <fs_data>-td = 'TD09'.
        ENDIF.

      ENDIF.
    ENDLOOP.

    SORT lt_data BY fiscalyear fiscalperiod glaccount customer supplier td.

    "公司名称
    SELECT SINGLE
           companycodename
      FROM i_companycodevh
     WHERE companycode = @lv_companycode
      INTO @DATA(lv_companycodename).

    IF lt_data IS NOT INITIAL.
      "科目名称
      WITH +i AS ( SELECT DISTINCT glaccount FROM @lt_data AS i )
      SELECT a~glaccount,
             a~glaccountname
        FROM i_glaccounttext AS a
        JOIN +i AS i ON a~glaccount = i~glaccount
       WHERE a~chartofaccounts = 'YCOA'
         AND a~language = @sy-langu
        INTO TABLE @DATA(lt_glaccounttext).
      SORT lt_glaccounttext BY glaccount.

      "客户名称
      WITH +i AS ( SELECT DISTINCT customer FROM @lt_data AS i WHERE customer IS NOT INITIAL )
      SELECT a~customer,
             a~customername
        FROM i_customer AS a
        JOIN +i AS i ON a~customer = i~customer
        INTO TABLE @DATA(lt_customer).
      SORT lt_customer BY customer.

      "供应商名称
      WITH +i AS ( SELECT DISTINCT supplier FROM @lt_data AS i WHERE supplier IS NOT INITIAL )
      SELECT a~supplier,
             a~suppliername
        FROM i_supplier AS a
        JOIN +i AS i ON a~supplier = i~supplier
        INTO TABLE @DATA(lt_supplier).
      SORT lt_supplier BY supplier.

    ENDIF.

    CLEAR: ls_result.
    LOOP AT lt_data INTO DATA(ls_data).

      DATA(ls_save) = ls_data.

      "期末余额（本位币）
      ls_result-amount = ls_result-amount + ls_data-debitamountincocodecrcy + ls_data-creditamountincocodecrcy.

      AT END OF td.

        IF ls_data-glaccount CP '2202*'
           OR ls_data-glaccount CP '2241*'
           OR ls_data-glaccount CP '2703*'.
          ls_result-amount = 0 - ls_result-amount.
        ENDIF.

        ls_result-zzyear = ls_save-fiscalyear.
        ls_result-zzmonth = ls_save-fiscalperiod.
        ls_result-ent_cod = ls_save-companycode.
        ls_result-ent_des = lv_companycodename.
        ls_result-br_acc_cod = ls_save-glaccount.
        ls_result-td = ls_save-td.
        ls_result-currency = ls_save-companycodecurrency.     "本位币
        ls_result-gp_ent_cod = 'G392'.
        ls_result-gp_ent_des = '启境智能汽车科技（广州）有限公司'.
        ls_result-sys_id = '启境SAP S4HC'.
        ls_result-dateupd = sy-datum && sy-uzeit.

        "科目名称
        READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext) WITH KEY glaccount = ls_result-br_acc_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-br_acc_des = ls_glaccounttext-glaccountname.
          CLEAR: ls_glaccounttext.
        ENDIF.

        IF ls_save-customer IS NOT INITIAL.
          "客户
          ls_result-br_ctp_cod = ls_save-customer.

          READ TABLE lt_customer INTO DATA(ls_customer) WITH KEY customer = ls_result-br_ctp_cod BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-br_ctp_des = ls_customer-customername.
            CLEAR: ls_customer.
          ENDIF.
        ELSE.
          "供应商
          ls_result-br_ctp_cod = ls_save-supplier.

          READ TABLE lt_supplier INTO DATA(ls_supplier) WITH KEY supplier = ls_result-br_ctp_cod BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-br_ctp_des = ls_supplier-suppliername.
            CLEAR: ls_supplier.
          ENDIF.
        ENDIF.

        ls_result-uuid = ls_result-zzyear && '~' && ls_result-zzmonth && '~' && ls_result-br_acc_cod && '~' &&
                         ls_result-br_ctp_cod && '~' && ls_result-td && '~' &&
                         ls_result-ent_cod && '~' && lv_fiscalyear && '~' && lv_fiscalperiod.

        APPEND ls_result TO lt_result.
        CLEAR: ls_result.
      ENDAT.
    ENDLOOP.

    et_result = lt_result.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI007'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
