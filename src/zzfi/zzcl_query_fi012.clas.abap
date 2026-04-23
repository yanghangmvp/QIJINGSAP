CLASS zzcl_query_fi012 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    TYPES:
      tt_results TYPE STANDARD TABLE OF zc_query_fi012 WITH EMPTY KEY.

    CLASS-METHODS:
      get_data
        IMPORTING
          it_ranges       TYPE if_rap_query_filter=>tt_name_range_pairs
          iv_offset       TYPE int8 OPTIONAL
          iv_max_rows     TYPE i OPTIONAL
          it_sort_tab     TYPE abap_sortorder_tab OPTIONAL
        EXPORTING
          ev_total_number TYPE int8
          et_data         TYPE tt_results.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_FI012 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    "Get filter ranges
    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        "Handle error
    ENDTRY.

    "Get offset and page size
    DATA(lv_offset)    = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
    DATA(lv_max_rows)  = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
    THEN 0 ELSE lv_page_size ).

    "sorting
    DATA(sort_elements) = io_request->get_sort_elements( ).
    DATA(lt_sort_tab)   = VALUE abap_sortorder_tab( FOR sort_element IN sort_elements (
    name = sort_element-element_name
    descending = sort_element-descending ) ).

    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZC_QUERY_FI012'.
            IF io_request->is_data_requested( ).
              get_data(
              EXPORTING
              it_ranges       = lt_ranges
              iv_offset       = lv_offset
              iv_max_rows     = lv_max_rows
              it_sort_tab     = lt_sort_tab
              IMPORTING
              ev_total_number = DATA(lv_head_total_number)
              et_data         = DATA(lt_data)
              ).

              io_response->set_data( lt_data ).
            ENDIF.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lv_head_total_number ).
            ENDIF.
        ENDCASE.

      CATCH cx_rap_query_provider.

    ENDTRY.

  ENDMETHOD.


  METHOD get_data.

    DATA: lt_result      TYPE TABLE OF zc_query_fi012,
          ls_result      TYPE zc_query_fi012,
          lr_companycode TYPE RANGE OF zc_query_fi012-companycode,
          lr_budat       TYPE RANGE OF budat,
          lr_belnr       TYPE RANGE OF belnr_d,
          lr_buzei       TYPE RANGE OF i_accountingdocumentjournal-ledgergllineitem,
          lr_uuid        TYPE RANGE OF zc_query_fi012-uuid,
          lv_companycode TYPE zc_query_fi012-companycode,
          lv_budat       TYPE budat,
          lv_belnr       TYPE belnr_d,
          lv_buzei       TYPE c LENGTH 6,
          ls_budat       LIKE LINE OF lr_budat,
          ls_belnr       LIKE LINE OF lr_belnr,
          ls_buzei       LIKE LINE OF lr_buzei.

* *   过滤器lr_glaccount
    LOOP AT it_ranges INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'COMPANYCODE'.
          lr_companycode = CORRESPONDING #( ls_filter-range ).
          lv_companycode = lr_companycode[ 1 ]-low.
        WHEN 'POSTDATE'.
          lr_budat = CORRESPONDING #( ls_filter-range ).
          lv_budat = lr_budat[ 1 ]-low.
        WHEN 'BELNR'.
          lr_belnr = CORRESPONDING #( ls_filter-range ).
          lv_belnr = lr_belnr[ 1 ]-low.
        WHEN 'BUZEI'.
          lr_buzei = CORRESPONDING #( ls_filter-range ).
          lv_buzei = lr_buzei[ 1 ]-low.
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).

          LOOP AT lr_uuid INTO DATA(ls_uuid).

            SPLIT ls_uuid-low  AT '-' INTO TABLE DATA(lt_range).

            READ TABLE lt_range INTO DATA(ls_range) INDEX 1.
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              lv_companycode = ls_range.
            ENDIF.

            READ TABLE lt_range INTO ls_range INDEX 2."年度
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              ls_budat-sign = 'I'.
              ls_budat-option = 'EQ'.
              ls_budat-low = ls_range.
              APPEND ls_budat TO lr_budat.
            ENDIF.

            READ TABLE lt_range INTO ls_range INDEX 3."凭证号
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              ls_belnr-sign = 'I'.
              ls_belnr-option = 'EQ'.
              ls_belnr-low = ls_range.
              APPEND ls_belnr TO lr_belnr.
            ENDIF.

            READ TABLE lt_range INTO ls_range INDEX 4."行号
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              ls_buzei-sign = 'I'.
              ls_buzei-option = 'EQ'.
              ls_buzei-low = ls_range.
              APPEND ls_buzei TO lr_buzei.
            ENDIF.

          ENDLOOP.

      ENDCASE.
    ENDLOOP.

    "查询银行存款帐户科目
    SELECT a~companycode,"公司代码
           a~glaccount,"银行帐户对应的科目
           a~bankaccount,"银行帐户
           a~referenceinfo, "银行帐户参考
           a~bankaccountcurrency "银行帐户币种
           FROM i_housebankaccountlinkage AS a
           WHERE a~companycode = @lv_companycode
      INTO TABLE @DATA(lt_bankaccount).

    "查询凭证数据
    IF lt_bankaccount IS NOT INITIAL.
      WITH +i AS ( SELECT DISTINCT companycode, glaccount FROM @lt_bankaccount AS i )
        SELECT a~companycode,"公司代码
          a~accountingdocument,"凭证号
          a~fiscalyear,"会计年度
          a~ledgergllineitem, "凭证行项目
          a~fiscalperiod,"会计期间
          a~glaccount,"科目
          a~postingdate,"过账日期
          a~businessarea,"业务范围
          a~creationdate,"录入日期
          a~reversalreferencedocument,"冲销凭证号
          a~transactioncurrency AS currency,"币种
          a~debitcreditcode ,"借贷方向
          a~documentitemtext,"凭证摘要
          a~accountingdocumenttype,"记账类型
          a~accountingdoccreatedbyuser,"记账会计
          a~debitamountintranscrcy,"借方金额
          a~creditamountintranscrcy,"贷方金额
          a~debitamountincocodecrcy,
          a~creditamountincocodecrcy
          FROM i_accountingdocumentjournal( p_language = @sy-langu ) AS a
          LEFT JOIN i_glaccount AS b ON a~companycode = b~companycode
                               AND a~glaccount = b~glaccount
         JOIN +i AS i ON  a~companycode = i~companycode
         AND  a~glaccount = i~glaccount
          WHERE a~companycode = @lv_companycode
          AND   ledger = '0L'
          AND a~postingdate IN @lr_budat"年度
          AND a~accountingdocument IN @lr_belnr"凭证号
          AND a~ledgergllineitem IN @lr_buzei"行号
          INTO TABLE @DATA(lt_data).
    ENDIF.

    IF lt_data[] IS NOT INITIAL.
      WITH +i AS ( SELECT DISTINCT companycode, fiscalyear,accountingdocument FROM @lt_data AS i )
           SELECT a~reference1indocumentheader,"来源系统唯一标识
             a~datasource,"数据来源
             a~companycode,"公司代码
             a~accountingdocument,"凭证编号
             a~fiscalyear"凭证年度
             FROM zztfi001 AS a
             JOIN +i AS i ON  a~companycode = i~companycode
             AND a~accountingdocument = i~accountingdocument
             AND a~fiscalyear = i~fiscalyear
                       INTO TABLE @DATA(lt_001).
    ENDIF.

    "公司名称
    SELECT SINGLE
           companycodename
      FROM i_companycodevh
     WHERE companycode = @lv_companycode
      INTO @DATA(lv_companycodename).

    IF lt_bankaccount IS NOT INITIAL.
      "科目名称
      WITH +i AS ( SELECT DISTINCT companycode, glaccount FROM @lt_bankaccount AS i )
      SELECT a~glaccount,
             a~glaccountname
        FROM i_glaccounttext AS a
        JOIN +i AS i ON a~glaccount = i~glaccount
       WHERE a~chartofaccounts = 'YCOA'
         AND a~language = @sy-langu
        INTO TABLE @DATA(lt_glaccounttext).
    ENDIF.

    SORT lt_data BY companycode fiscalyear accountingdocument ledgergllineitem.

*    LOOP  AT lt_bankaccount INTO DATA(ls_bankaccount).
    LOOP AT lt_data INTO DATA(ls_data).

      CLEAR:ls_result.

      ls_result-postdate = ls_data-postingdate."过账日期
      ls_result-companycode = ls_data-companycode."公司代码

      READ TABLE lt_001 INTO DATA(ls_001)
      WITH KEY  companycode = ls_data-companycode"公司代码
      accountingdocument = ls_data-accountingdocument"凭证编号
      fiscalyear = ls_data-fiscalyear."凭证年度
      IF  sy-subrc = 0.
        ls_result-datasource = ls_001-datasource."数据来源
        ls_result-reference1indocumentheader = ls_001-reference1indocumentheader."来源系统唯一标识
      ENDIF.

      ls_result-glaccount = ls_data-glaccount."总账科目
      ls_result-businessarea = ls_data-businessarea."业务范围
      ls_result-glaccount = ls_data-glaccount."总账科目
      ls_result-creationdate = ls_data-creationdate."录入日期
      ls_result-accountingdocument = ls_data-accountingdocument."  会计凭证号
      ls_result-ledgergllineitem = ls_data-ledgergllineitem."  会计凭证行号
      ls_result-reversalreferencedocument = ls_data-reversalreferencedocument."冲销凭证号

      READ TABLE lt_bankaccount INTO DATA(ls_bankaccount)
      WITH KEY    companycode =   ls_data-companycode
                 glaccount = ls_data-glaccount.

      IF sy-subrc = 0.
        ls_result-bankaccount = ls_bankaccount-bankaccount && ls_bankaccount-referenceinfo."银行账号
      ENDIF.

      ls_result-currency = ls_data-currency."货币类别
      ls_result-debitcreditcode = ls_data-debitcreditcode."借贷方向

      IF ls_bankaccount-bankaccountcurrency = ls_data-currency.

        ls_result-debitamountintranscrcy = ls_data-debitamountincocodecrcy."借方金额
        ls_result-creditamountintranscrcy = ls_data-creditamountincocodecrcy."贷方金额
      ELSE.
        ls_result-debitamountintranscrcy = ls_data-debitamountintranscrcy."借方金额
        ls_result-creditamountintranscrcy = ls_data-creditamountintranscrcy."贷方金额
      ENDIF.

      ls_result-documentitemtext = ls_data-documentitemtext."凭证摘要
      ls_result-accountingdocumenttype = ls_data-accountingdocumenttype."记账类型
      ls_result-accountingdoccreatedbyuser = ls_data-accountingdoccreatedbyuser."记账会计

      ls_result-uuid = ls_data-companycode && ls_data-fiscalyear "公司代码+年度+凭证号+行号
                     && ls_data-accountingdocument && ls_data-ledgergllineitem.

      GET TIME STAMP FIELD ls_result-timestamp."时间戳

      ls_result-uuid = ls_result-companycode && '-' && ls_result-postdate
      && '-' && ls_result-accountingdocument && '-' && ls_result-ledgergllineitem.

      APPEND ls_result TO lt_result.
    ENDLOOP.


    et_data = lt_result.

    "Sort table
    IF it_sort_tab IS NOT INITIAL.
      SORT et_data BY (it_sort_tab).
    ENDIF.

    "Get total number
    ev_total_number = lines( et_data ).

*    "Paging
*    IF iv_max_rows > 0.
*      DATA(lt_paged_result) = lt_data.
*      CLEAR lt_data.
*      LOOP AT lt_paged_result INTO DATA(lS_paged_result) FROM ( iv_offset + 1 ) TO ( iv_offset + iv_max_rows ).
*        APPEND ls_result TO lt_data.
*      ENDLOOP.
*    ENDIF.

    "Return data
*    et_data = lt_data.
  ENDMETHOD.
ENDCLASS.
