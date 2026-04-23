CLASS zzcl_query_fi009 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .

    TYPES:
      tt_results TYPE STANDARD TABLE OF zc_query_fi009 WITH EMPTY KEY.

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



CLASS ZZCL_QUERY_FI009 IMPLEMENTATION.


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

          WHEN 'ZC_QUERY_FI009'.
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

    DATA: lt_result       TYPE TABLE OF zc_query_fi009,
          ls_result       TYPE zc_query_fi009,
          lr_companycode  TYPE RANGE OF zc_query_fi009-companycode,
          lr_postdate     TYPE RANGE OF zc_query_fi009-postdate,
          lr_glaccount    TYPE RANGE OF zc_query_fi009-glaccount,
          lr_uuid         TYPE RANGE OF zc_query_fi009-uuid,
          ls_glaccount    LIKE LINE OF lr_glaccount,
          lv_companycode  TYPE zc_query_fi009-companycode,
          lv_postdate     TYPE zc_query_fi009-postdate,
          lv_glaccount    TYPE zc_query_fi009-glaccount,
          lv_before_datum TYPE zc_query_fi009-postdate.

* *   过滤器lr_glaccount
    LOOP AT it_ranges INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'COMPANYCODE'.
          lr_companycode = CORRESPONDING #( ls_filter-range ).
          lv_companycode = lr_companycode[ 1 ]-low.
        WHEN 'POSTDATE'.
          lr_postdate = CORRESPONDING #( ls_filter-range ).
          lv_postdate = lr_postdate[ 1 ]-low.
          lv_before_datum = lv_postdate - 1.
        WHEN 'GLACCOUNT'.
          lr_glaccount = CORRESPONDING #( ls_filter-range ).
          lv_glaccount = lr_glaccount[ 1 ]-low.
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).

          LOOP AT lr_uuid INTO DATA(ls_uuid).

            SPLIT ls_uuid-low  AT '-' INTO TABLE DATA(lt_range).

            READ TABLE lt_range INTO DATA(ls_range) INDEX 1.
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              lv_companycode = ls_range.
            ENDIF.

            READ TABLE lt_range INTO ls_range INDEX 2.
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              lv_postdate = ls_range.
              lv_before_datum = lv_postdate - 1.
            ENDIF.

            READ TABLE lt_range INTO ls_range INDEX 3.
            IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
              lv_glaccount = ls_range.
              ls_glaccount-sign = 'I'.
              ls_glaccount-option = 'EQ'.
              ls_glaccount-low = ls_range.
              APPEND ls_glaccount TO lr_glaccount.
            ENDIF.
          ENDLOOP.
          DATA(lvstr) = 'X'.
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
           AND a~glaccount IN @lr_glaccount
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
          a~companycodecurrency,"币种
          a~DebitAmountInTransCrcy,"借方金额
          a~CreditAmountInTransCrcy,"贷方金额
          a~DebitAmountInCoCodeCrcy,
          a~CreditAmountInCoCodeCrcy
          FROM i_accountingdocumentjournal( p_language = @sy-langu ) AS a
          LEFT JOIN i_glaccount AS b ON a~companycode = b~companycode
                               AND a~glaccount = b~glaccount
         JOIN +i AS i ON  a~companycode = i~companycode
         AND  a~glaccount = i~glaccount
          WHERE a~companycode = @lv_companycode
          AND   ledger = '0L'
          AND   postingdate <= @lv_postdate
          INTO TABLE @DATA(lt_data).
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

    SORT lt_data BY glaccount.

    LOOP  AT lt_bankaccount INTO DATA(ls_bankaccount).

      CLEAR:ls_result.
      ls_result-companycode = ls_bankaccount-companycode."公司代码
      ls_result-companyname = lv_companycodename."公司名称
      ls_result-glaccount = ls_bankaccount-glaccount."科目
      ls_result-bankaccount = ls_bankaccount-bankaccount
       && ls_bankaccount-referenceinfo."银行帐户
      READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext)
      WITH KEY glaccount = ls_result-glaccount.
      IF sy-subrc = 0.
        ls_result-glaccountname = ls_glaccounttext-glaccountname."科目名称
      ENDIF.

      GET TIME STAMP FIELD ls_result-timestamp."时间戳
*    UUID
      ls_result-currency = ls_bankaccount-bankaccountcurrency."币种

      READ TABLE lt_data
      WITH KEY glaccount = ls_bankaccount-glaccount
       BINARY SEARCH     TRANSPORTING NO FIELDS.

      IF  sy-subrc = 0.

        LOOP AT lt_data  INTO DATA(ls_data) FROM sy-tabix.
          IF  ls_data-glaccount NE ls_bankaccount-glaccount.
            EXIT.
          ENDIF.

          IF ls_bankaccount-bankaccountcurrency = ls_data-companycodecurrency.
            IF ls_data-postingdate <= lv_before_datum.
              ls_result-beginbalance = ls_result-beginbalance + ls_data-CreditAmountInCoCodeCrcy
              + ls_data-DebitAmountInCoCodeCrcy.
            ENDIF.
            IF ls_data-postingdate <= lv_postdate.
              ls_result-endbalance = ls_result-endbalance + ls_data-CreditAmountInCoCodeCrcy
              + ls_data-DebitAmountInCoCodeCrcy.
            ENDIF.
          ELSE.
            IF ls_data-postingdate <= lv_before_datum.
              ls_result-beginbalance = ls_result-beginbalance + ls_data-CreditAmountInTransCrcy
              + ls_data-DebitAmountInTransCrcy.
            ENDIF.
            IF ls_data-postingdate <= lv_postdate.
              ls_result-endbalance = ls_result-endbalance + ls_data-CreditAmountInTransCrcy
              + ls_data-DebitAmountInTransCrcy.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF ls_result-beginbalance < 0.
          ls_result-begindirect = 'S'.
        ELSEIF ls_result-beginbalance > 0.
          ls_result-begindirect = 'H'.
        ENDIF.

        IF ls_result-endbalance < 0.
          ls_result-enddirect = 'S'.
        ELSEIF ls_result-endbalance > 0.
          ls_result-enddirect = 'H'.
        ENDIF.

      ENDIF.

      ls_result-postdate = lv_postdate."查询日期

      ls_result-uuid = ls_result-companycode && '-' && ls_result-postdate
      && '-' && ls_result-glaccount.

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
