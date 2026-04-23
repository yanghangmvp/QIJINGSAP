CLASS zzcl_query_fi015 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_result TYPE TABLE OF zc_query_fi015.

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
        et_result  TYPE  tt_result.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_query_fi015 IMPLEMENTATION.
  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi015.

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
    DATA: lt_result TYPE TABLE OF zc_query_fi015,
          ls_result TYPE zc_query_fi015.

    DATA: lv_companycode      TYPE zc_query_fi015-companycode,
          lv_year             TYPE zc_query_fi015-firstacquisitionfiscalyear,
          lv_period           TYPE zc_query_fi015-firstacquisitionfiscalperiod,
          lr_masterfixedasset TYPE RANGE OF zc_query_fi015-masterfixedasset.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'COMPANYCODE'.
          lv_companycode = ls_filter-range[ 1 ]-low.
        WHEN 'FIRSTACQUISITIONFISCALYEAR'.
          lv_year = ls_filter-range[ 1 ]-low.
        WHEN 'FIRSTACQUISITIONFISCALPERIOD'.
          lv_period = ls_filter-range[ 1 ]-low..
        WHEN 'MASTERFIXEDASSET'.
          lr_masterfixedasset = CORRESPONDING #( ls_filter-range ).
      ENDCASE.
    ENDLOOP.

    SELECT DISTINCT
           b~companycode,
           @lv_year AS firstacquisitionfiscalyear,
           @lv_period AS firstacquisitionfiscalperiod,
           a~masterfixedasset,
           c~supplier
      FROM i_fixedassetforledger AS a
      JOIN i_accountingdocumentjournal AS b ON a~masterfixedasset = b~masterfixedasset
      JOIN i_fixedasset AS c ON b~companycode = c~companycode
                            AND a~masterfixedasset = c~masterfixedasset
     WHERE b~companycode = @lv_companycode
       AND ( ( a~firstacquisitionfiscalyear = @lv_year AND a~firstacquisitionfiscalperiod <= @lv_period ) OR
               a~firstacquisitionfiscalyear < @lv_year )
       AND a~masterfixedasset IN @lr_masterfixedasset
       AND c~assetclass LIKE 'Z5%'
       AND a~ledger = '0L'
       AND b~ledger = '0L'
      INTO TABLE @DATA(lt_fixedasset).
    SORT lt_fixedasset BY firstacquisitionfiscalyear firstacquisitionfiscalperiod masterfixedasset.

    IF lt_fixedasset IS NOT INITIAL.
      "项目名称
      SELECT masterfixedasset,
             fixedassetdescription,
             assetadditionaldescription
        FROM i_fixedasset
         FOR ALL ENTRIES IN @lt_fixedasset
       WHERE masterfixedasset = @lt_fixedasset-masterfixedasset
        INTO TABLE @DATA(lt_description).
      SORT lt_description BY masterfixedasset.

      "供应商名称
      SELECT supplier,
             suppliername
        FROM i_supplier
         FOR ALL ENTRIES IN @lt_fixedasset
       WHERE supplier = @lt_fixedasset-supplier
        INTO TABLE @DATA(lt_supplier).
      SORT lt_supplier BY supplier.

      "期初(末)余额
      SELECT b~companycode,
             a~firstacquisitionfiscalyear,
             a~firstacquisitionfiscalperiod,
             a~masterfixedasset,
             b~debitamountincocodecrcy,
             b~creditamountincocodecrcy
        FROM i_fixedassetforledger AS a
        JOIN i_accountingdocumentjournal AS b ON a~masterfixedasset = b~masterfixedasset
       WHERE b~companycode = @lv_companycode
         AND ( ( a~firstacquisitionfiscalyear = @lv_year AND a~firstacquisitionfiscalperiod <= @lv_period ) OR
                 a~firstacquisitionfiscalyear < @lv_year )
         AND a~masterfixedasset IN @lr_masterfixedasset
         AND ( b~glaccount LIKE '1604%' OR b~glaccount = '1802010000' )
         AND a~ledger = '0L'
         AND b~ledger = '0L'
        INTO TABLE @DATA(lt_ye).
      SORT lt_ye BY firstacquisitionfiscalyear firstacquisitionfiscalperiod masterfixedasset.

      IF lt_ye IS NOT INITIAL.
        "期初
        SELECT a~masterfixedasset,
          SUM( a~debitamountincocodecrcy ) AS debitamountincocodecrcy,
          SUM( a~creditamountincocodecrcy ) AS creditamountincocodecrcy
          FROM @lt_ye AS a
         WHERE ( ( a~firstacquisitionfiscalyear = @lv_year AND a~firstacquisitionfiscalperiod < @lv_period ) OR
                   a~firstacquisitionfiscalyear < @lv_year )
         GROUP BY a~masterfixedasset
          INTO TABLE @DATA(lt_qc_sum).
        SORT lt_qc_sum BY masterfixedasset.

        "期末
        SELECT a~masterfixedasset,
          SUM( a~debitamountincocodecrcy ) AS debitamountincocodecrcy,
          SUM( a~creditamountincocodecrcy ) AS creditamountincocodecrcy
          FROM @lt_ye AS a
         GROUP BY a~masterfixedasset
          INTO TABLE @DATA(lt_qm_sum).
        SORT lt_qm_sum BY masterfixedasset.
      ENDIF.

      "本期增加金额
      SELECT a~masterfixedasset,
        SUM( b~debitamountincocodecrcy ) AS debitamountincocodecrcy,
        SUM( b~creditamountincocodecrcy ) AS creditamountincocodecrcy
        FROM i_fixedassetforledger AS a
        JOIN i_accountingdocumentjournal AS b ON a~masterfixedasset = b~masterfixedasset
       WHERE b~companycode = @lv_companycode
         AND a~firstacquisitionfiscalyear = @lv_year
         AND a~firstacquisitionfiscalperiod = @lv_period
         AND a~masterfixedasset IN @lr_masterfixedasset
         AND ( b~assettransactiontype = '900' OR b~assettransactiontype BETWEEN '100' AND '199' )
         AND a~ledger = '0L'
         AND b~ledger = '0L'
       GROUP BY a~masterfixedasset
        INTO TABLE @DATA(lt_zj).
      SORT lt_zj BY masterfixedasset.

      "本期转固金额
      SELECT a~masterfixedasset,
        SUM( 0 - b~debitamountincocodecrcy ) AS debitamountincocodecrcy,
        SUM( 0 - b~creditamountincocodecrcy ) AS creditamountincocodecrcy
        FROM i_fixedassetforledger AS a
        JOIN i_accountingdocumentjournal AS b ON a~masterfixedasset = b~masterfixedasset
       WHERE b~companycode = @lv_companycode
         AND a~firstacquisitionfiscalyear = @lv_year
         AND a~firstacquisitionfiscalperiod = @lv_period
         AND a~masterfixedasset IN @lr_masterfixedasset
         AND b~assettransactiontype IN ( '345', '340' )
         AND a~ledger = '0L'
         AND b~ledger = '0L'
       GROUP BY a~masterfixedasset
        INTO TABLE @DATA(lt_zg).
      SORT lt_zg BY masterfixedasset.

      "本期其他减少
      SELECT a~masterfixedasset,
        SUM( 0 - b~debitamountincocodecrcy ) AS debitamountincocodecrcy,
        SUM( 0 - b~creditamountincocodecrcy ) AS creditamountincocodecrcy
        FROM i_fixedassetforledger AS a
        JOIN i_accountingdocumentjournal AS b ON a~masterfixedasset = b~masterfixedasset
       WHERE b~companycode = @lv_companycode
         AND ( ( a~firstacquisitionfiscalyear = @lv_year AND a~firstacquisitionfiscalperiod <= @lv_period ) OR
                 a~firstacquisitionfiscalyear < @lv_year )
         AND a~masterfixedasset IN @lr_masterfixedasset
         AND b~financialtransactiontype = '930'
         AND a~ledger = '0L'
         AND b~ledger = '0L'
       GROUP BY a~masterfixedasset
        INTO TABLE @DATA(lt_js).
      SORT lt_js BY masterfixedasset.

      "累计(本期)利息资本化金额
      SELECT b~companycode,
             a~firstacquisitionfiscalyear,
             a~firstacquisitionfiscalperiod,
             a~masterfixedasset,
             b~debitamountincocodecrcy,
             b~creditamountincocodecrcy
        FROM i_fixedassetforledger AS a
        JOIN i_accountingdocumentjournal AS b ON a~masterfixedasset = b~masterfixedasset
       WHERE b~companycode = @lv_companycode
         AND ( ( a~firstacquisitionfiscalyear = @lv_year AND a~firstacquisitionfiscalperiod <= @lv_period ) OR
                 a~firstacquisitionfiscalyear < @lv_year )
         AND a~masterfixedasset IN @lr_masterfixedasset
         AND b~accountingdocumenttype = 'RE'
         AND b~financialaccounttype = 'A'
         AND a~ledger = '0L'
         AND b~ledger = '0L'
        INTO TABLE @DATA(lt_lx).
      SORT lt_lx BY firstacquisitionfiscalyear firstacquisitionfiscalperiod masterfixedasset.

      IF lt_lx IS NOT INITIAL.
        "累计
        SELECT a~masterfixedasset,
          SUM( a~debitamountincocodecrcy ) AS debitamountincocodecrcy,
          SUM( a~creditamountincocodecrcy ) AS creditamountincocodecrcy
          FROM @lt_lx AS a
         GROUP BY a~masterfixedasset
          INTO TABLE @DATA(lt_ljlx).
        SORT lt_ljlx BY masterfixedasset.

        "本期
        SELECT a~masterfixedasset,
          SUM( a~debitamountincocodecrcy ) AS debitamountincocodecrcy,
          SUM( a~creditamountincocodecrcy ) AS creditamountincocodecrcy
          FROM @lt_lx AS a
         WHERE a~firstacquisitionfiscalyear = @lv_year
           AND a~firstacquisitionfiscalperiod = @lv_period
         GROUP BY a~masterfixedasset
          INTO TABLE @DATA(lt_bqlx).
        SORT lt_bqlx BY masterfixedasset.
      ENDIF.
    ENDIF.

    LOOP AT lt_fixedasset INTO DATA(ls_fixedasset).
      CLEAR: ls_result.

      ls_result = CORRESPONDING #( ls_fixedasset ).

      "期初
      READ TABLE lt_qc_sum INTO DATA(ls_qc_sum) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_qc = ls_qc_sum-debitamountincocodecrcy + ls_qc_sum-creditamountincocodecrcy.
        CLEAR: ls_qc_sum.
      ENDIF.

      "期末
      READ TABLE lt_qm_sum INTO DATA(ls_qm_sum) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_qm = ls_qm_sum-debitamountincocodecrcy + ls_qm_sum-creditamountincocodecrcy.
        CLEAR: ls_qm_sum.
      ENDIF.

      "本期增加金额
      READ TABLE lt_zj INTO DATA(ls_zj) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_zj = ls_zj-debitamountincocodecrcy + ls_zj-creditamountincocodecrcy.
        CLEAR: ls_zj.
      ENDIF.

      IF ls_result-amount_qc = 0 AND ls_result-amount_zj = 0.
        CONTINUE.
      ENDIF.

      "本期转固金额
      READ TABLE lt_zg INTO DATA(ls_zg) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_zg = ls_zg-debitamountincocodecrcy + ls_zg-creditamountincocodecrcy.
        CLEAR: ls_zg.
      ENDIF.

      "本期其他减少
      READ TABLE lt_js INTO DATA(ls_js) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_js = ls_js-debitamountincocodecrcy + ls_js-creditamountincocodecrcy.
        CLEAR: ls_js.
      ENDIF.

      "累计利息资本化金额
      READ TABLE lt_ljlx INTO DATA(ls_ljlx) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_ljlx = ls_ljlx-debitamountincocodecrcy + ls_ljlx-creditamountincocodecrcy.
        CLEAR: ls_ljlx.
      ENDIF.

      "本期利息资本化金额
      READ TABLE lt_bqlx INTO DATA(ls_bqlx) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-amount_bqlx = ls_bqlx-debitamountincocodecrcy + ls_bqlx-creditamountincocodecrcy.
        CLEAR: ls_ljlx.
      ENDIF.

      "项目名称
      READ TABLE lt_description INTO DATA(ls_description) WITH KEY masterfixedasset = ls_result-masterfixedasset BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-fixedassetdescription = ls_description-fixedassetdescription.
        ls_result-assetadditionaldescription = ls_description-assetadditionaldescription.
        CLEAR: ls_description.
      ENDIF.

      "供应商名称
      READ TABLE lt_supplier INTO DATA(ls_supplier) WITH KEY supplier = ls_result-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-suppliername = ls_supplier-suppliername.
        CLEAR: ls_supplier.
      ENDIF.

      APPEND ls_result TO lt_result.
    ENDLOOP.

    et_result =  lt_result.
  ENDMETHOD.

  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI015'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
