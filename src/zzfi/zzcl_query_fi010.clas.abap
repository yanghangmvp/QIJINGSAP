CLASS zzcl_query_fi010 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_result TYPE TABLE OF zc_query_fi010.

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



CLASS zzcl_query_fi010 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi010.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range

        me->read_data(
           EXPORTING
             it_filters = lt_filters
           IMPORTING
             et_result = lt_result ).

*&---====================2.数据获取后，select 排序/过滤/分页/返回设置
*&---设置过滤器
        zzcl_query_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_result ).
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
    ENDTRY.
  ENDMETHOD.


  METHOD read_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi010,
          ls_result TYPE zc_query_fi010.

    DATA: lv_flag TYPE zc_query_fi010-zsfyjz.

    DATA: lv_companycode TYPE zc_query_fi010-bukrs,
          lv_year        TYPE zc_query_fi010-gjahr,
          lv_period      TYPE zc_query_fi010-monat,
          lr_uuid        TYPE RANGE OF zc_query_fi010-uuid.

    DATA: lv_date(5) TYPE p.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'ZSFYJZ'.
          lv_flag = ls_filter-range[ 1 ]-low.
        WHEN 'BUKRS'.
          lv_companycode = ls_filter-range[ 1 ]-low.
        WHEN 'GJAHR'.
          lv_year = ls_filter-range[ 1 ]-low..
        WHEN 'MONAT'.
          lv_period = ls_filter-range[ 1 ]-low.

      ENDCASE.
    ENDLOOP.

    IF lv_flag = abap_false.
      SELECT *
        FROM zztfi014
       WHERE bukrs = @lv_companycode
         AND gjahr = @lv_year
         AND monat = @lv_period
        INTO TABLE @DATA(lt_zztfi014).
      IF sy-subrc = 0.
        RETURN.
      ENDIF.

      SELECT companycode,
             fiscalyear,
             fiscalperiod,
             postingdate,
             accountingdocumenttype,
             accountingdocument,
             ledgergllineitem,
             debitcreditcode,
             glaccount,
             companycodecurrency,
             debitamountincocodecrcy,
             creditamountincocodecrcy,
             costcenter,
             functionalarea,
             accountingdocumentheadertext,
             documentitemtext
        FROM i_accountingdocumentjournal( p_language = '1' )
       WHERE ledger = '0L'
         AND companycode = @lv_companycode
         AND fiscalyear = @lv_year
         AND fiscalperiod = @lv_period
         AND costcenter = '0000100502'
         AND accountassignmenttype = 'KS'
         AND functionalarea = '3000'
        INTO TABLE @DATA(lt_accounting).
      SORT lt_accounting BY accountingdocument ledgergllineitem.

      IF lt_accounting IS NOT INITIAL.
        "科目名称
        SELECT glaccount,
               glaccountname
          FROM i_glaccounttext
           FOR ALL ENTRIES IN @lt_accounting
         WHERE glaccount = @lt_accounting-glaccount
           AND chartofaccounts = 'YCOA'
           AND language = '1'
          INTO TABLE @DATA(lt_glaccounttext).
        SORT lt_glaccounttext BY glaccount.

        "成本中心名称
        SELECT costcenter,
               costcentername
          FROM i_costcentertext
           FOR ALL ENTRIES IN @lt_accounting
         WHERE costcenter = @lt_accounting-costcenter
           AND controllingarea = 'A000'
           AND language = @sy-langu
           AND validitystartdate <= @sy-datum
           AND validityenddate >= @sy-datum
          INTO TABLE @DATA(lt_costcentertext).
        SORT lt_costcentertext BY costcenter.

        "职能范围名称
        SELECT functionalarea,
               functionalareaname
          FROM i_functionalareatext
           FOR ALL ENTRIES IN @lt_accounting
         WHERE functionalarea = @lt_accounting-functionalarea
           AND language = @sy-langu
          INTO TABLE @DATA(lt_functionalareatext).
        SORT lt_functionalareatext BY functionalarea.
      ENDIF.

      LOOP AT lt_accounting INTO DATA(ls_accounting).
        CLEAR: ls_result.

        ls_result-dmbtr = ls_accounting-debitamountincocodecrcy + ls_accounting-creditamountincocodecrcy.

        IF ls_result-dmbtr = 0.
          CONTINUE.
        ENDIF.

        ls_result-zsfyjz = lv_flag.
        ls_result-bukrs = ls_accounting-companycode.
        ls_result-gjahr = ls_accounting-fiscalyear.
        ls_result-monat = ls_accounting-fiscalperiod+1(2).
        ls_result-budat = ls_accounting-postingdate.
        ls_result-blart = ls_accounting-accountingdocumenttype.
        ls_result-belnr = ls_accounting-accountingdocument.
        ls_result-docln = ls_accounting-ledgergllineitem.
        ls_result-shkzg = ls_accounting-debitcreditcode.
        ls_result-hkont = ls_accounting-glaccount.
        ls_result-hwaer = ls_accounting-companycodecurrency.
        ls_result-kostl = ls_accounting-costcenter.
        ls_result-fkber = ls_accounting-functionalarea.
        ls_result-bktxt = ls_accounting-accountingdocumentheadertext.
        ls_result-sgtxt = ls_accounting-documentitemtext.

        "科目名称
        READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext) WITH KEY glaccount = ls_result-hkont BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-txt50 = ls_glaccounttext-glaccountname.
          CLEAR: ls_glaccounttext.
        ENDIF.

        "成本中心名称
        READ TABLE lt_costcentertext INTO DATA(ls_costcentertext) WITH KEY costcenter = ls_result-kostl BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-ktext = ls_costcentertext-costcentername.
          CLEAR: ls_costcentertext.
        ENDIF.

        "职能范围名称
        READ TABLE lt_functionalareatext INTO DATA(ls_functionalareatext) WITH KEY functionalarea = ls_result-fkber BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-fkbtx = ls_functionalareatext-functionalareaname.
          CLEAR: ls_functionalareatext.
        ENDIF.

        ls_result-uuid = lv_companycode && lv_year && lv_period &&
                         ls_result-belnr && ls_result-docln.

        APPEND ls_result TO lt_result.
      ENDLOOP.

    ELSE.
      SELECT *
        FROM zztfi014
       WHERE bukrs = @lv_companycode
         AND gjahr = @lv_year
         AND monat = @lv_period
        INTO TABLE @lt_zztfi014.
      SORT lt_zztfi014 BY belnr docln.
      MOVE-CORRESPONDING lt_zztfi014 TO lt_result.

      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
        <fs_result>-uuid = lv_companycode && lv_year && lv_period &&
                           <fs_result>-belnr && <fs_result>-docln.
        <fs_result>-zsfyjz = lv_flag.
      ENDLOOP.
    ENDIF.

    et_result =  lt_result.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI010'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
