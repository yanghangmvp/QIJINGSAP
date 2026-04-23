CLASS zzcl_query_fi013 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.



*   rap 查询提供者接口
    INTERFACES if_rap_query_provider .

    METHODS get_data
      IMPORTING io_request  TYPE REF TO if_rap_query_request
                io_response TYPE REF TO if_rap_query_response
      RAISING   cx_rap_query_prov_not_impl
                cx_rap_query_provider.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_FI013 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result     TYPE TABLE OF zc_query_fi013,
          lt_result_tmp TYPE TABLE OF zc_query_fi013,
          ls_result     TYPE zc_query_fi013,
          ls_result_tmp TYPE zc_query_fi013.

    DATA: lr_glaccount TYPE RANGE OF i_accountingdocumentjournal-glaccount.
    DATA: lr_gl_tmp TYPE RANGE OF i_accountingdocumentjournal-glaccount.
    DATA: lt_mapping TYPE TABLE OF  zzt_rest_append.

    DATA: lv_bukrs        TYPE zc_query_fi013-bukrs,
          lv_year         TYPE zc_query_fi013-zzyear,
          lv_period       TYPE zc_query_fi013-zzpoper,
          lv_month        TYPE numc2,
          lv_yearmonth(6).

    FIELD-SYMBOLS:<fs_value> TYPE any.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'BUKRS'.
              lv_bukrs = ls_filter-range[ 1 ]-low.
            WHEN 'ZZYEAR'.
              lv_year = ls_filter-range[ 1 ]-low.
            WHEN 'ZZPOPER'.
              lv_period = ls_filter-range[ 1 ]-low.
              lv_month = lv_period.
          ENDCASE.
        ENDLOOP.
      CATCH cx_root INTO DATA(lr_root).
        DATA(lv_msg) = lr_root->get_longtext( ).
    ENDTRY.
    lv_yearmonth = lv_year && lv_month.

    lt_mapping = VALUE #(
       ( zzappkey = 'LINE01'     zzappvalue = '1601010000' )
       ( zzappkey = 'LINE01'     zzappvalue = '1602010000' )
       ( zzappkey = 'LINE01'     zzappvalue = '1603010000' )
       ( zzappkey = 'LINE02'     zzappvalue = '1601030000' )
       ( zzappkey = 'LINE02'     zzappvalue = '1602030000' )
       ( zzappkey = 'LINE02'     zzappvalue = '1603030000' )
       ( zzappkey = 'LINE03'     zzappvalue = '1601040000' )
       ( zzappkey = 'LINE03'     zzappvalue = '1602040000' )
       ( zzappkey = 'LINE03'     zzappvalue = '1603040000' )
       ( zzappkey = 'LINE04'     zzappvalue = '1601050000' )
       ( zzappkey = 'LINE04'     zzappvalue = '1602050000' )
       ( zzappkey = 'LINE04'     zzappvalue = '1603050000' )
       ( zzappkey = 'LINE05'     zzappvalue = '1601060000' )
       ( zzappkey = 'LINE05'     zzappvalue = '1602060000' )
       ( zzappkey = 'LINE05'     zzappvalue = '1603060000' )
       ( zzappkey = 'LINE06'     zzappvalue = '1601990000' )
       ( zzappkey = 'LINE06'     zzappvalue = '1602990000' )
       ( zzappkey = 'LINE06'     zzappvalue = '1603990000' )
    ).
    SORT lt_mapping BY zzappvalue.
    LOOP AT lt_mapping INTO DATA(ls_mapping).
      APPEND VALUE #( low = ls_mapping-zzappvalue sign = 'I'  option = 'EQ'   ) TO lr_glaccount.
    ENDLOOP.
    "余额
    SELECT substring( a~postingdate, 1, 6 ) AS yearmonth,
           a~glaccount,
           a~assettransactiontype,
           a~financialtransactiontype,
          SUM( a~debitamountincocodecrcy + a~creditamountincocodecrcy ) AS amount
      FROM i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a
     WHERE a~ledger = '0L'
       AND a~companycode = @lv_bukrs
       AND a~glaccount IN @lr_glaccount
       AND substring( a~postingdate, 1, 6 ) <= @lv_yearmonth
       GROUP BY substring( a~postingdate, 1, 6 ),a~glaccount,a~assettransactiontype,a~financialtransactiontype
       INTO TABLE @DATA(lt_journal).


    SELECT substring( a~postingdate, 1, 6 ) AS yearmonth,
           a~glaccount,
           a~financialtransactiontype,
           SUM(  a~debitamountincocodecrcy + a~creditamountincocodecrcy  ) AS amount
      FROM i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a
     WHERE a~ledger = '0L'
       AND a~companycode = @lv_bukrs
       AND a~glaccount IN @lr_glaccount
       AND substring( a~postingdate, 1, 6 ) <= @lv_yearmonth
       GROUP BY substring( a~postingdate, 1, 6 ),a~glaccount,a~financialtransactiontype
       INTO TABLE @DATA(lt_journal2).
    "填充数据

**********************************************************************一、账面原值
    lr_gl_tmp = VALUE #(
    ( low = '1601010000' sign = 'I'  option = 'EQ'   )
    ( low = '1601030000' sign = 'I'  option = 'EQ'   )
    ( low = '1601040000' sign = 'I'  option = 'EQ'   )
    ( low = '1601050000' sign = 'I'  option = 'EQ'   )
    ( low = '1601060000' sign = 'I'  option = 'EQ'   )
    ( low = '1601990000' sign = 'I'  option = 'EQ'   )
    ).
    APPEND VALUE #( zzxm = '一、账面原值'  uuid = 1 ) TO lt_result.

    SELECT a~glaccount,
           SUM( amount ) AS amount
      FROM @lt_journal AS a
     WHERE a~yearmonth < @lv_yearmonth
       AND a~glaccount IN @lr_gl_tmp
     GROUP BY glaccount
      INTO TABLE @DATA(lt_qcye).
    CLEAR: ls_result.
    ls_result-zzxm = '     1.期初余额'.
    ls_result-uuid = 2.
    LOOP AT lt_qcye INTO DATA(ls_qcye).
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_qcye-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_qcye-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_qcye-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result.

    "本期增加金额
    SELECT a~assettransactiontype,
           a~glaccount,
        SUM( amount ) AS amount
       FROM @lt_journal AS a
      WHERE a~yearmonth = @lv_yearmonth
        AND a~glaccount IN @lr_gl_tmp
        AND a~assettransactiontype IN ( '100','346','150','116' )
      GROUP BY assettransactiontype,glaccount
       INTO TABLE @DATA(lt_bqzj).
    "（1）购置
    CLEAR: ls_result.
    ls_result-zzxm = '        （1）购置'.
    ls_result-uuid = 4.
    LOOP AT lt_bqzj INTO DATA(ls_bqzj) WHERE assettransactiontype = '100' OR assettransactiontype = '150'.
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqzj-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> += ls_bqzj-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqzj-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result_tmp.
    "（2）在建工程
    CLEAR: ls_result.
    ls_result-zzxm = '        （2）在建工程'.
    ls_result-uuid = 5.
    LOOP AT lt_bqzj INTO ls_bqzj WHERE assettransactiontype = '346' OR assettransactiontype = '116' .
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqzj-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> += ls_bqzj-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqzj-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （3）企业合并增加'  uuid = 6 ) TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （4）投资性房地产转入' uuid = 7  ) TO lt_result_tmp.

    SELECT SINGLE
           3 AS uuid,
          '     2.本期增加金额' AS zzxm ,
           SUM( line01 ) AS line01,
           SUM( line02 ) AS line02,
           SUM( line03 ) AS line03,
           SUM( line04 ) AS line04,
           SUM( line05 ) AS line05,
           SUM( line06 ) AS line06,
           SUM( total ) AS total
      FROM @lt_result_tmp AS a
      INTO @ls_result.
    APPEND ls_result TO lt_result.
    APPEND LINES OF lt_result_tmp TO lt_result.
    CLEAR: ls_result ,lt_result_tmp.


    "本期减少金额
    SELECT a~financialtransactiontype,
           a~glaccount,
          abs( SUM( amount ) )  AS amount
       FROM @lt_journal2 AS a
      WHERE a~yearmonth = @lv_yearmonth
        AND a~glaccount IN @lr_gl_tmp
        AND a~financialtransactiontype IN ( '930' )
      GROUP BY financialtransactiontype,glaccount
       INTO TABLE @DATA(lt_bqjs).
    "（1）处置或报废
    CLEAR: ls_result.
    ls_result-zzxm = '        （1）处置或报废'.
    ls_result-uuid = 9.
    LOOP AT lt_bqjs INTO DATA(ls_bqjs) WHERE financialtransactiontype = '930'.
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqjs-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> += ls_bqjs-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqjs-amount.
    ENDLOOP.

    APPEND ls_result TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （2）转出到在建工程' uuid = 10 ) TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （3）转出到投资性房地产' uuid = 11 ) TO lt_result_tmp.

    SELECT SINGLE
          8 AS uuid,
          '     3.本期减少金额' AS zzxm ,
           SUM( line01 ) AS line01,
           SUM( line02 ) AS line02,
           SUM( line03 ) AS line03,
           SUM( line04 ) AS line04,
           SUM( line05 ) AS line05,
           SUM( line06 ) AS line06,
           SUM( total ) AS total
      FROM @lt_result_tmp AS a
      INTO @ls_result.
    APPEND ls_result TO lt_result.
    APPEND LINES OF lt_result_tmp TO lt_result.
    CLEAR: ls_result ,lt_result_tmp.

    "4.期末余额
    SELECT a~glaccount,
           SUM( amount ) AS amount
      FROM @lt_journal AS a
     WHERE a~yearmonth <= @lv_yearmonth
       AND a~glaccount IN @lr_gl_tmp
     GROUP BY glaccount
      INTO TABLE @DATA(lt_qmye).
    CLEAR: ls_result.
    ls_result-zzxm = '     4.期末余额'.
    ls_result-uuid = 12.
    LOOP AT lt_qmye INTO DATA(ls_qmye).
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_qmye-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_qmye-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_qmye-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result.

**********************************************************************二、累计折旧
    lr_gl_tmp = VALUE #(
    ( low = '1602010000' sign = 'I'  option = 'EQ'   )
    ( low = '1602030000' sign = 'I'  option = 'EQ'   )
    ( low = '1602040000' sign = 'I'  option = 'EQ'   )
    ( low = '1602050000' sign = 'I'  option = 'EQ'   )
    ( low = '1602060000' sign = 'I'  option = 'EQ'   )
    ( low = '1602990000' sign = 'I'  option = 'EQ'   )
    ).
    APPEND VALUE #( zzxm = '二、累计折旧' uuid = 13 ) TO lt_result.
    SELECT a~glaccount,
           abs( SUM( amount ) ) AS amount
      FROM @lt_journal2 AS a
     WHERE a~yearmonth < @lv_yearmonth
       AND a~glaccount IN @lr_gl_tmp
     GROUP BY glaccount
      INTO TABLE @DATA(lt_qcye2).
    CLEAR: ls_result.
    ls_result-zzxm = '     1.期初余额'.
    ls_result-uuid = 14.
    LOOP AT lt_qcye2 INTO DATA(ls_qcye2).
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_qcye2-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_qcye2-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_qcye2-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result.

    "本期增加金额
    SELECT a~financialtransactiontype,
           a~glaccount,
       abs( SUM( amount ) ) AS amount
       FROM @lt_journal2 AS a
      WHERE a~yearmonth = @lv_yearmonth
        AND a~glaccount IN @lr_gl_tmp
        AND a~financialtransactiontype IN ( '925' )
      GROUP BY financialtransactiontype,glaccount
       INTO TABLE @DATA(lt_bqzj2).
    "（1）计提
    CLEAR: ls_result.
    ls_result-zzxm = '        （1）计提'.
    ls_result-uuid = 16.
    LOOP AT lt_bqzj2 INTO DATA(ls_bqzj2) WHERE financialtransactiontype = '925'.
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqzj2-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_bqzj2-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqzj2-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （2）投资性房地产转入' uuid = 17 ) TO lt_result_tmp.
    SELECT SINGLE
           15 AS uuid,
           '     2.本期增加金额' AS zzxm ,
           SUM( line01 ) AS line01,
           SUM( line02 ) AS line02,
           SUM( line03 ) AS line03,
           SUM( line04 ) AS line04,
           SUM( line05 ) AS line05,
           SUM( line06 ) AS line06,
           SUM( total ) AS total
      FROM @lt_result_tmp AS a
      INTO @ls_result.
    APPEND ls_result TO lt_result.
    APPEND LINES OF lt_result_tmp TO lt_result.
    CLEAR: ls_result ,lt_result_tmp.

    "本期减少金额
    SELECT a~financialtransactiontype,
           a~glaccount,
       abs( SUM( amount ) ) AS amount
       FROM @lt_journal2 AS a
      WHERE a~yearmonth = @lv_yearmonth
        AND a~glaccount IN @lr_gl_tmp
        AND a~financialtransactiontype IN ( '930' )
      GROUP BY financialtransactiontype,glaccount
       INTO TABLE @DATA(lt_bqjs2).
    "（1）计提
    CLEAR: ls_result.
    ls_result-zzxm = '        （1）处置或报废'.
    ls_result-uuid = 19.
    LOOP AT lt_bqjs2 INTO DATA(ls_bqjs2) WHERE financialtransactiontype = '930'.
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqjs2-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_bqjs2-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqjs2-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （2）转出到投资性房地产'  uuid = 20 ) TO lt_result_tmp.
    SELECT SINGLE
            18 AS uuid,
          '     3.本期减少金额' AS zzxm ,
           SUM( line01 ) AS line01,
           SUM( line02 ) AS line02,
           SUM( line03 ) AS line03,
           SUM( line04 ) AS line04,
           SUM( line05 ) AS line05,
           SUM( line06 ) AS line06,
           SUM( total ) AS total
      FROM @lt_result_tmp AS a
      INTO @ls_result.
    APPEND ls_result TO lt_result.
    APPEND LINES OF lt_result_tmp TO lt_result.
    CLEAR: ls_result ,lt_result_tmp.

    "4.期末余额
    SELECT a~glaccount,
           abs( SUM( amount ) ) AS amount
      FROM @lt_journal2 AS a
     WHERE a~yearmonth <= @lv_yearmonth
       AND a~glaccount IN @lr_gl_tmp
     GROUP BY glaccount
      INTO TABLE @DATA(lt_qmye2).
    CLEAR: ls_result.
    ls_result-zzxm = '     4.期末余额'.
    ls_result-uuid = 21.
    LOOP AT lt_qmye2 INTO DATA(ls_qmye2).
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_qmye2-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_qmye2-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_qmye2-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result.

**********************************************************************三、减值准备
    lr_gl_tmp = VALUE #(
    ( low = '1603010000' sign = 'I'  option = 'EQ'   )
    ( low = '1603030000' sign = 'I'  option = 'EQ'   )
    ( low = '1603040000' sign = 'I'  option = 'EQ'   )
    ( low = '1603050000' sign = 'I'  option = 'EQ'   )
    ( low = '1603060000' sign = 'I'  option = 'EQ'   )
    ( low = '1603990000' sign = 'I'  option = 'EQ'   )
    ).
    APPEND VALUE #( zzxm = '三、减值准备' uuid = 22 ) TO lt_result.
    SELECT a~glaccount,
           abs( SUM( amount ) ) AS amount
      FROM @lt_journal2 AS a
     WHERE a~yearmonth < @lv_yearmonth
       AND a~glaccount IN @lr_gl_tmp
     GROUP BY glaccount
      INTO TABLE @DATA(lt_qcye3).
    CLEAR: ls_result.
    ls_result-zzxm = '     1.期初余额'.
    ls_result-uuid = 23.
    LOOP AT lt_qcye3 INTO DATA(ls_qcye3).
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_qcye3-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_qcye3-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_qcye3-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result.

    "本期增加金额
    SELECT a~financialtransactiontype,
           a~glaccount,
       abs( SUM( amount ) ) AS amount
       FROM @lt_journal2 AS a
      WHERE a~yearmonth = @lv_yearmonth
        AND a~glaccount IN @lr_gl_tmp
        AND a~financialtransactiontype IN ( '920' )
      GROUP BY financialtransactiontype,glaccount
       INTO TABLE @DATA(lt_bqzj3).
    "（1）计提
    CLEAR: ls_result.
    ls_result-zzxm = '        （1）计提'.
    ls_result-uuid = 25.
    LOOP AT lt_bqzj3 INTO DATA(ls_bqzj3) WHERE financialtransactiontype = '920'.
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqzj3-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_bqzj3-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqzj3-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result_tmp.
    APPEND VALUE #( zzxm = '        （2）投资性房地产转入' uuid = 26 ) TO lt_result_tmp.
    SELECT SINGLE
            24 AS uuid,
            '     2.本期增加金额' AS zzxm ,
           SUM( line01 ) AS line01,
           SUM( line02 ) AS line02,
           SUM( line03 ) AS line03,
           SUM( line04 ) AS line04,
           SUM( line05 ) AS line05,
           SUM( line06 ) AS line06,
           SUM( total ) AS total
      FROM @lt_result_tmp AS a
      INTO @ls_result.
    APPEND ls_result TO lt_result.
    APPEND LINES OF lt_result_tmp TO lt_result.
    CLEAR: ls_result ,lt_result_tmp.

    "本期减少金额
    SELECT a~financialtransactiontype,
           a~glaccount,
       abs( SUM( amount ) ) AS amount
       FROM @lt_journal2 AS a
      WHERE a~yearmonth = @lv_yearmonth
        AND a~glaccount IN @lr_gl_tmp
        AND a~financialtransactiontype IN ( '930' )
      GROUP BY financialtransactiontype,glaccount
       INTO TABLE @DATA(lt_bqjs3).
    "（1）计提
    CLEAR: ls_result.
    ls_result-zzxm = '        （1）处置或报废'.
    ls_result-uuid = 28.
    LOOP AT lt_bqjs3 INTO DATA(ls_bqjs3) WHERE financialtransactiontype = '930'.
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_bqjs3-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_bqjs3-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_bqjs3-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result_tmp.
    SELECT SINGLE
            27 AS uuid,
           '     3.本期减少金额' AS zzxm ,
           SUM( line01 ) AS line01,
           SUM( line02 ) AS line02,
           SUM( line03 ) AS line03,
           SUM( line04 ) AS line04,
           SUM( line05 ) AS line05,
           SUM( line06 ) AS line06,
           SUM( total ) AS total
      FROM @lt_result_tmp AS a
      INTO @ls_result.
    APPEND ls_result TO lt_result.
    APPEND LINES OF lt_result_tmp TO lt_result.
    CLEAR: ls_result ,lt_result_tmp.
    "4.期末余额
    SELECT a~glaccount,
          abs( SUM( amount ) )  AS amount
      FROM @lt_journal2 AS a
     WHERE a~yearmonth <= @lv_yearmonth
       AND a~glaccount IN @lr_gl_tmp
     GROUP BY glaccount
      INTO TABLE @DATA(lt_qmye3).
    CLEAR: ls_result.
    ls_result-zzxm = '     4.期末余额'.
    ls_result-uuid = 29.
    LOOP AT lt_qmye3 INTO DATA(ls_qmye3).
      READ TABLE lt_mapping INTO ls_mapping WITH KEY zzappvalue = ls_qmye3-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        ASSIGN COMPONENT ls_mapping-zzappkey OF STRUCTURE ls_result TO <fs_value>.
        IF sy-subrc = 0.
          <fs_value> = ls_qmye3-amount.
        ENDIF.
      ENDIF.
      ls_result-total = ls_result-total + ls_qmye3-amount.
    ENDLOOP.
    APPEND ls_result TO lt_result.

**********************************************************************四、账面价值
    DATA lv_sign TYPE i.
    APPEND VALUE #( zzxm = '四、账面价值' uuid = 30 ) TO lt_result.
    CLEAR: ls_result_tmp.
    ls_result_tmp-zzxm = '     1.期末账面价值'.
    ls_result_tmp-uuid = 31.
    LOOP AT lt_result INTO ls_result WHERE uuid = '12'  OR uuid = '21' OR uuid = '29' .
      CASE ls_result-uuid.
        WHEN '12'.
          lv_sign = 1.
        WHEN '21'.
          lv_sign = -1.
        WHEN '29'.
          lv_sign = -1.
      ENDCASE.

      ls_result_tmp-line01 = ls_result_tmp-line01 + ls_result-line01  * lv_sign.
      ls_result_tmp-line02 = ls_result_tmp-line02 + ls_result-line02  * lv_sign.
      ls_result_tmp-line03 = ls_result_tmp-line03 + ls_result-line03  * lv_sign.
      ls_result_tmp-line04 = ls_result_tmp-line04 + ls_result-line04  * lv_sign.
      ls_result_tmp-line05 = ls_result_tmp-line05 + ls_result-line05  * lv_sign.
      ls_result_tmp-line06 = ls_result_tmp-line06 + ls_result-line06  * lv_sign.
      ls_result_tmp-total = ls_result_tmp-total + ls_result-total  * lv_sign.
    ENDLOOP.

    APPEND ls_result_tmp TO lt_result.

    CLEAR: ls_result_tmp.
    ls_result_tmp-zzxm = '     2.期初账面价值'.
    ls_result_tmp-uuid = 32.
    LOOP AT lt_result INTO ls_result WHERE uuid = '2'  OR uuid = '14' OR uuid = '23' .
      CASE ls_result-uuid.
        WHEN '2'.
          lv_sign = 1.
        WHEN '14'.
          lv_sign = -1.
        WHEN '23'.
          lv_sign = -1.
      ENDCASE.
      ls_result_tmp-line01 = ls_result_tmp-line01 + ls_result-line01  * lv_sign.
      ls_result_tmp-line02 = ls_result_tmp-line02 + ls_result-line02  * lv_sign.
      ls_result_tmp-line03 = ls_result_tmp-line03 + ls_result-line03  * lv_sign.
      ls_result_tmp-line04 = ls_result_tmp-line04 + ls_result-line04  * lv_sign.
      ls_result_tmp-line05 = ls_result_tmp-line05 + ls_result-line05  * lv_sign.
      ls_result_tmp-line06 = ls_result_tmp-line06 + ls_result-line06  * lv_sign.
      ls_result_tmp-total = ls_result_tmp-total + ls_result-total  * lv_sign.
    ENDLOOP.
    APPEND ls_result_tmp TO lt_result.


    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      <fs_result>-bukrs = lv_bukrs.
      <fs_result>-zzyear = lv_year.
      <fs_result>-zzpoper = lv_period.
    ENDLOOP.
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


  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI013'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
