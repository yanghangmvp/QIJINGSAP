CLASS zzcl_query_fi001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    TYPES: ty_result              TYPE zc_query_fi001,
           tty_result             TYPE TABLE OF ty_result
                                  WITH KEY companycode
                                           fiscalyearperiodfrom
                                           fiscalyearperiodto
                                           itemno
                                           itemtext,
           ty_settingforcashflow  TYPE zztfi004,
           tty_settingforcashflow TYPE TABLE OF ty_settingforcashflow WITH KEY companycode fiitem fisuit,
           BEGIN OF ty_accitemforcf,
             companycode                 TYPE i_glaccountlineitem-companycode,
             fiscalyear                  TYPE i_glaccountlineitem-fiscalyear,
             fiscalyearperiod            TYPE i_glaccountlineitem-fiscalyearperiod,
             glaccount                   TYPE i_glaccountlineitem-glaccount,
             amountincompanycodecurrency TYPE i_glaccountlineitem-amountincompanycodecurrency,
             paymentdifferencereason     TYPE i_operationalacctgdocitem-paymentdifferencereason,
           END OF ty_accitemforcf,
           tty_accitemforcf TYPE TABLE OF ty_accitemforcf
                     WITH KEY companycode fiscalyear paymentdifferencereason.

    DATA: gt_accitemforcf TYPE tty_accitemforcf,
          gs_accitemforcf TYPE ty_accitemforcf.


    DATA: gt_settingforcashflow TYPE tty_settingforcashflow,
          gs_settingforcashflow TYPE ty_settingforcashflow.

    DATA: gv_fiscalyearfrom           TYPE i_actcostingruntypevh-fiscalyear.
    DATA: gv_fiscalperiodfrom         TYPE i_actcostingruntypevh-fiscalperiod.
    DATA: gv_fiscalyearperiodfrom     TYPE fins_fyearperiod.
    DATA: gv_lastfiscalyearperiodfrom TYPE fins_fyearperiod.
    DATA: gv_fiscalyearto           TYPE i_actcostingruntypevh-fiscalyear.
    DATA: gv_fiscalperiodto         TYPE i_actcostingruntypevh-fiscalperiod.
    DATA: gv_fiscalyearperiodto     TYPE fins_fyearperiod.
    DATA: gv_lastfiscalyearperiodto TYPE fins_fyearperiod.
    DATA: gv_companycode TYPE i_glaccountlineitem-companycode.

    DATA: gs_result TYPE ty_result.

    METHODS build_0
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS build_1
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS build_2
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS build_3
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS build_4
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS build_5
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS build_6
      IMPORTING is_settingforcashflow TYPE ty_settingforcashflow
      CHANGING  ct_result             TYPE tty_result.

    METHODS get_data
      IMPORTING io_request  TYPE REF TO if_rap_query_request
                io_response TYPE REF TO if_rap_query_response
      RAISING   cx_rap_query_prov_not_impl
                cx_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_FI001 IMPLEMENTATION.


  METHOD build_0.
*输出文本
    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

  ENDMETHOD.


  METHOD build_1.
*按科目统计
    DATA: ls_settingforcashflow TYPE ty_settingforcashflow.


    ls_settingforcashflow = is_settingforcashflow.


*&---."如果结束科目为空则结束科目为开始科目
    IF ls_settingforcashflow-glaccountfrom IS INITIAL.
      ls_settingforcashflow-glaccountto = ls_settingforcashflow-glaccountfrom.
    ENDIF.

    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

    LOOP AT gt_accitemforcf INTO gs_accitemforcf
            WHERE glaccount BETWEEN ls_settingforcashflow-glaccountfrom
            AND ls_settingforcashflow-glaccountto.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        gs_accitemforcf-amountincompanycodecurrency = - gs_accitemforcf-amountincompanycodecurrency.
      ENDIF.

      CLEAR gs_result.
      gs_result-itemno   = is_settingforcashflow-fiitem.
      gs_result-itemtext = is_settingforcashflow-fitext.
      IF gs_accitemforcf-fiscalyearperiod BETWEEN gv_fiscalyearperiodfrom AND gv_fiscalyearperiodto.
        gs_result-amount = gs_accitemforcf-amountincompanycodecurrency.
      ENDIF.

      IF gs_accitemforcf-fiscalyearperiod BETWEEN gv_lastfiscalyearperiodfrom AND gv_lastfiscalyearperiodto.
        gs_result-amountlastyear = gs_accitemforcf-amountincompanycodecurrency.
      ENDIF.

      COLLECT gs_result INTO ct_result.

    ENDLOOP.

  ENDMETHOD.


  METHOD build_2.
*按原因代码统计
    DATA: ls_settingforcashflow TYPE ty_settingforcashflow.


    ls_settingforcashflow = is_settingforcashflow.

    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

    LOOP AT gt_accitemforcf INTO gs_accitemforcf
            WHERE paymentdifferencereason = ls_settingforcashflow-paymentdifferencereason.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        gs_accitemforcf-amountincompanycodecurrency = - gs_accitemforcf-amountincompanycodecurrency.
      ENDIF.

      CLEAR gs_result.
      gs_result-itemno   = is_settingforcashflow-fiitem.
      gs_result-itemtext = is_settingforcashflow-fitext.
      IF gs_accitemforcf-fiscalyearperiod BETWEEN gv_fiscalyearperiodfrom AND gv_fiscalyearperiodto.
        gs_result-amount = gs_accitemforcf-amountincompanycodecurrency.
      ENDIF.
      IF gs_accitemforcf-fiscalyearperiod BETWEEN gv_lastfiscalyearperiodfrom AND gv_lastfiscalyearperiodto.
        gs_result-amountlastyear = gs_accitemforcf-amountincompanycodecurrency.
      ENDIF.
      COLLECT gs_result INTO ct_result.

    ENDLOOP.
  ENDMETHOD.


  METHOD build_3.
*按项目号统计
    DATA: ls_settingforcashflow TYPE ty_settingforcashflow.
    DATA(lt_result) = ct_result[].

    ls_settingforcashflow = is_settingforcashflow.


*&---."如果结束项目为空则结束科目为开始项目
    IF ls_settingforcashflow-itemto IS INITIAL.
      ls_settingforcashflow-itemto = ls_settingforcashflow-itemfrom.
    ENDIF.

    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

    LOOP AT lt_result INTO gs_result
            WHERE itemno BETWEEN ls_settingforcashflow-itemfrom
            AND ls_settingforcashflow-itemto.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        gs_result-amount = - gs_result-amount.
        gs_result-amountlastyear = - gs_result-amountlastyear.
      ENDIF.

      gs_result-itemno   = ls_settingforcashflow-fiitem.
      gs_result-itemtext = ls_settingforcashflow-fitext.
      COLLECT gs_result INTO ct_result.

    ENDLOOP.
  ENDMETHOD.


  METHOD build_4.
*特殊逻辑
    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

  ENDMETHOD.


  METHOD build_5.
*期初行
    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

    "本期期初
    SELECT companycode,
    SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency
    FROM i_glaccountlineitem AS glaccountlineitem
    WHERE sourceledger = '0L'
          AND companycode = @gv_companycode
          AND fiscalyear = substring( @gv_fiscalyearperiodfrom,1,4 )
          AND fiscalyearperiod < @gv_fiscalyearperiodfrom
          AND ledger = '0L'
          AND glaccountlineitem~glaccount BETWEEN '1001000000' AND '1012999999'
    GROUP BY companycode
    INTO TABLE @DATA(lt_start).
    IF sy-subrc = 0.
      READ TABLE lt_start INTO DATA(ls_start) INDEX 1.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        ls_start-amountincompanycodecurrency = - ls_start-amountincompanycodecurrency.
      ENDIF.

      CLEAR gs_result.
      gs_result-itemno   = is_settingforcashflow-fiitem.
      gs_result-itemtext = is_settingforcashflow-fitext.
      gs_result-amount   = ls_start-amountincompanycodecurrency.
      COLLECT gs_result INTO ct_result.
    ENDIF.

    "上年同期期初
    SELECT companycode,
    SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency
    FROM i_glaccountlineitem AS glaccountlineitem
    WHERE sourceledger = '0L'
          AND companycode = @gv_companycode
          AND ledger = '0L'
          AND fiscalyear = substring( @gv_lastfiscalyearperiodfrom,1,4 )
          AND fiscalyearperiod < @gv_lastfiscalyearperiodfrom
          AND glaccountlineitem~glaccount BETWEEN '1001000000' AND '1012999999'
    GROUP BY companycode
    INTO TABLE @DATA(lt_lastyearstart).
    IF sy-subrc = 0.
      READ TABLE lt_lastyearstart INTO DATA(ls_lastyearstart) INDEX 1.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        ls_lastyearstart-amountincompanycodecurrency = - ls_lastyearstart-amountincompanycodecurrency.
      ENDIF.

      CLEAR gs_result.
      gs_result-itemno   = is_settingforcashflow-fiitem.
      gs_result-itemtext = is_settingforcashflow-fitext.
      gs_result-amountlastyear   = ls_lastyearstart-amountincompanycodecurrency.
      COLLECT gs_result INTO ct_result.
    ENDIF.

  ENDMETHOD.


  METHOD build_6.
*期末行
    CLEAR gs_result.
    gs_result-itemno   = is_settingforcashflow-fiitem.
    gs_result-itemtext = is_settingforcashflow-fitext.
    COLLECT gs_result INTO ct_result.

    "本期期末
    SELECT companycode,
    SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency
    FROM i_glaccountlineitem AS glaccountlineitem
    WHERE sourceledger = '0L'
          AND companycode = @gv_companycode
          AND ledger = '0L'
          AND fiscalyear = substring( @gv_fiscalyearperiodto,1,4 )
          AND fiscalyearperiod <= @gv_fiscalyearperiodto
          AND glaccountlineitem~glaccount BETWEEN '1001000000' AND '1012999999'
    GROUP BY companycode
    INTO TABLE @DATA(lt_start).
    IF sy-subrc = 0.
      READ TABLE lt_start INTO DATA(ls_start) INDEX 1.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        ls_start-amountincompanycodecurrency = - ls_start-amountincompanycodecurrency.
      ENDIF.

      CLEAR gs_result.
      gs_result-itemno   = is_settingforcashflow-fiitem.
      gs_result-itemtext = is_settingforcashflow-fitext.
      gs_result-amount   = ls_start-amountincompanycodecurrency.
      COLLECT gs_result INTO ct_result.
    ENDIF.

    "上年同期期末
    SELECT companycode,
    SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency
    FROM i_glaccountlineitem AS glaccountlineitem
    WHERE sourceledger = '0L'
          AND companycode = @gv_companycode
          AND ledger = '0L'
          AND fiscalyear = substring( @gv_lastfiscalyearperiodto,1,4 )
          AND fiscalyearperiod <= @gv_lastfiscalyearperiodto
          AND glaccountlineitem~glaccount BETWEEN '1001000000' AND '1012999999'
    GROUP BY companycode
    INTO TABLE @DATA(lt_lastyearstart).
    IF sy-subrc = 0.
      READ TABLE lt_lastyearstart INTO DATA(ls_lastyearstart) INDEX 1.

      IF is_settingforcashflow-fisign IS NOT INITIAL.
        ls_lastyearstart-amountincompanycodecurrency = - ls_lastyearstart-amountincompanycodecurrency.
      ENDIF.

      CLEAR gs_result.
      gs_result-itemno   = is_settingforcashflow-fiitem.
      gs_result-itemtext = is_settingforcashflow-fitext.
      gs_result-amountlastyear   = ls_lastyearstart-amountincompanycodecurrency.
      COLLECT gs_result INTO ct_result.
    ENDIF.
  ENDMETHOD.


  METHOD get_data.

    DATA lv_other_filter TYPE c.
    DATA lt_result TYPE tty_result.
    DATA ls_result TYPE ty_result.



    TRY.
        DATA(lt_filters) = io_request->get_filter(  )->get_as_ranges(  ).

        CLEAR: gv_fiscalyearfrom.
        CLEAR: gv_fiscalperiodfrom.
        CLEAR: gv_fiscalyearperiodfrom.
        CLEAR: gv_lastfiscalyearperiodfrom.
        CLEAR: gv_fiscalyearto.
        CLEAR: gv_fiscalperiodto.
        CLEAR: gv_fiscalyearperiodto.
        CLEAR: gv_lastfiscalyearperiodto.
        CLEAR: gv_companycode.
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'FISCALYEARPERIODFROM'.
              DATA(lr_fiscalyearperiodfrom)  = ls_filter-range.
              gv_fiscalyearfrom           = lr_fiscalyearperiodfrom[ 1 ]-low+0(4).
              gv_fiscalperiodfrom         = lr_fiscalyearperiodfrom[ 1 ]-low+4(3).
              gv_fiscalyearperiodfrom     = lr_fiscalyearperiodfrom[ 1 ]-low.
*              gv_lastfiscalyearperiodfrom = gv_fiscalyearperiodfrom(4) - 1.
              gv_lastfiscalyearperiodfrom = |{ gv_fiscalyearfrom - 1 }{ gv_fiscalperiodfrom }|.
            WHEN 'FISCALYEARPERIODTO'.
              DATA(lr_fiscalyearperiodto)  = ls_filter-range.
              gv_fiscalyearto           = lr_fiscalyearperiodto[ 1 ]-low+0(4).
              gv_fiscalperiodto         = lr_fiscalyearperiodto[ 1 ]-low+4(3).
              gv_fiscalyearperiodto     = lr_fiscalyearperiodto[ 1 ]-low.
*              gv_lastfiscalyearperiodto = gv_fiscalyearperiodto(4) - 1.
              gv_lastfiscalyearperiodto = |{ gv_fiscalyearto - 1 }{ gv_fiscalperiodto }|.
            WHEN 'COMPANYCODE'.
              DATA(lr_companycode)    = ls_filter-range.
              gv_companycode = lr_companycode[ 1 ]-low.
            WHEN OTHERS.
              lv_other_filter = 'X'.
          ENDCASE.
        ENDLOOP.

        DATA(lo_paging) = io_request->get_paging( ).
        DATA(lv_offset) = lo_paging->get_offset( ).
        DATA(lv_page_size) = lo_paging->get_page_size( ).
        DATA(lt_fields) = io_request->get_requested_elements( ).


        "取现金流量输出规则表
        FREE: gt_settingforcashflow.
        SELECT *
        FROM zztfi004
        WHERE ( companycode IN @lr_companycode ) "优先按公司代码匹配
        INTO TABLE @gt_settingforcashflow.
        IF sy-subrc NE 0.

          SELECT *
          FROM zztfi004
          WHERE ( companycode = '*' ) "其次按公司代码星号匹配
          INTO TABLE @gt_settingforcashflow.
          IF sy-subrc NE 0.
            SELECT *
            FROM zztfi004
            WHERE ( companycode = '' ) "再次按公司代码空匹配
            INTO TABLE @gt_settingforcashflow.
          ENDIF.


        ENDIF.

        FREE: gt_accitemforcf.
        IF gt_settingforcashflow[] IS NOT INITIAL.
          SELECT FROM i_operationalacctgdocitem AS operationalacctgdocitem
          FIELDS
                        operationalacctgdocitem~companycode,
                        operationalacctgdocitem~fiscalyear,
                        operationalacctgdocitem~fiscalperiod,
                        operationalacctgdocitem~glaccount,
                        SUM( operationalacctgdocitem~amountincompanycodecurrency ) AS amountincompanycodecurrency,
                        operationalacctgdocitem~paymentdifferencereason

          WHERE  operationalacctgdocitem~companycode = @gv_companycode
*            AND  operationalacctgdocitem~fiscalyear = substring( @gv_fiscalyearperiodfrom,1,4 )
*            AND  operationalacctgdocitem~fiscalperiod  = substring( @gv_fiscalyearperiodfrom,5,3 )
            AND  operationalacctgdocitem~fiscalyear = @gv_fiscalyearfrom
            AND  operationalacctgdocitem~fiscalperiod BETWEEN @gv_fiscalperiodfrom AND @gv_fiscalperiodto
            AND  operationalacctgdocitem~paymentdifferencereason IS NOT INITIAL

          GROUP BY  operationalacctgdocitem~companycode,
                    operationalacctgdocitem~fiscalyear,
                    operationalacctgdocitem~fiscalperiod,
                    operationalacctgdocitem~glaccount,
                    operationalacctgdocitem~paymentdifferencereason
           INTO TABLE @DATA(lt_docitem).
          IF lt_docitem IS NOT INITIAL.

            LOOP  AT lt_docitem INTO DATA(ls_docitem).
              CLEAR: gs_accitemforcf.
              MOVE-CORRESPONDING ls_docitem TO gs_accitemforcf.
              gs_accitemforcf-fiscalyearperiod = ls_docitem-fiscalyear && ls_docitem-fiscalperiod.
              APPEND gs_accitemforcf TO gt_accitemforcf.
            ENDLOOP.

          ENDIF.

        ENDIF.

        SORT gt_settingforcashflow BY fiitem fisuit.

        FREE: lt_result.
        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                                      WHERE  fitype = '0'.
**&---输出文本
          CALL METHOD me->build_0
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                                      WHERE  fitype = '1'.
**&---按科目统计
          CALL METHOD me->build_1
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                                    WHERE  fitype = '2'.
**&---按原因代码统计
          CALL METHOD me->build_2
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                                    WHERE  fitype = '3'.
**&---按项目号统计
          CALL METHOD me->build_3
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                            WHERE  fitype = '4'.
**&---特殊逻辑
          CALL METHOD me->build_4
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                            WHERE  fitype = '5'.
**&---期初行
          CALL METHOD me->build_5
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        LOOP AT gt_settingforcashflow INTO gs_settingforcashflow
                    WHERE  fitype = '6'.
**&---期末行
          CALL METHOD me->build_6
            EXPORTING
              is_settingforcashflow = gs_settingforcashflow
            CHANGING
              ct_result             = lt_result.
        ENDLOOP.

        IF lt_result[] IS NOT INITIAL.
          SORT lt_result BY itemno.
        ENDIF.

*&---====================2.数据获取后，SELECT 排序/过滤/分页/返回设置
*&---设置过滤器
        IF lv_other_filter IS NOT INITIAL.
          zzcl_query_utils=>filtering(
                                      EXPORTING io_filter = io_request->get_filter(  )
                                      CHANGING ct_data = lt_result ).
        ENDIF.

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_result ) ).
        ENDIF.

*&---设置排序
        zzcl_query_utils=>orderby(
                                  EXPORTING it_order = io_request->get_sort_elements( )
                                  CHANGING ct_data = lt_result ).
**********************************************************************
        IF io_request->is_data_requested( ).
          "增加聚合查询
          "request element & aggregate
          DATA(lt_req_elements) = io_request->get_requested_elements( ).
          DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
          IF lt_aggr_element IS NOT INITIAL.
            LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
              DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
              DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
              APPEND lv_aggregation TO lt_req_elements.
            ENDLOOP.
          ENDIF.

          DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = `, ` ).
          " grouping
          DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
          DATA(lv_grouping) = concat_lines_of(  table = lt_grouped_element sep = `, ` ).

          DATA lt_group_sort TYPE STANDARD TABLE OF string.
          DATA lv_group_sort TYPE string.

          LOOP AT lt_grouped_element ASSIGNING FIELD-SYMBOL(<ls_grouped_element>).
            DATA(lv_group_sort_element) = <ls_grouped_element> && ` ascending`.
            APPEND lv_group_sort_element TO lt_group_sort.
          ENDLOOP.
          " grouping sort
          lv_group_sort = concat_lines_of( table = lt_group_sort sep = `, ` ).

          IF lv_grouping IS NOT INITIAL.
            SELECT (lv_req_elements) FROM @lt_result AS result
                           GROUP BY (lv_grouping)
                           INTO CORRESPONDING FIELDS OF TABLE @lt_result.
          ELSE.
            SELECT (lv_req_elements) FROM @lt_result AS result
                             INTO CORRESPONDING FIELDS OF TABLE @lt_result.
          ENDIF.


        ENDIF.

***********************************************************************


*&---设置按页查询
        zzcl_query_utils=>paging(
                                    EXPORTING io_paging = io_request->get_paging(  )
                                    CHANGING ct_data = lt_result ).

        io_response->set_data( lt_result ).
      CATCH cx_rap_query_filter_no_range.
        "handle exception
    ENDTRY.



  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI001'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
        RETURN.
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
        RETURN.
      CATCH cx_sy_open_sql_db.
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
