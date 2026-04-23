CLASS zzcl_query_fi005 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_result TYPE TABLE OF zc_query_fi005.

*   rap 查询提供者接口
    INTERFACES if_rap_query_provider .

    METHODS get_data
      IMPORTING io_request  TYPE REF TO if_rap_query_request
                io_response TYPE REF TO if_rap_query_response
      RAISING   cx_rap_query_prov_not_impl
                cx_rap_query_provider.

    METHODS read_data
      IMPORTING
        it_filters      TYPE if_rap_query_filter=>tt_name_range_pairs
      EXPORTING
        et_result       TYPE  tt_result
        et_companycode  TYPE  i_accountingdocumentjournal-companycode
        et_fiscalyear   TYPE  i_accountingdocumentjournal-fiscalyear
        et_fiscalperiod TYPE  i_accountingdocumentjournal-fiscalperiod .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_FI005 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result       TYPE TABLE OF zc_query_fi005,
          lt_old          TYPE TABLE OF zztta004_old,
          lv_companycode  TYPE i_accountingdocumentjournal-companycode,
          lv_fiscalyear   TYPE i_accountingdocumentjournal-fiscalyear,
          lv_fiscalperiod TYPE i_accountingdocumentjournal-fiscalperiod.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range

        me->read_data(
           EXPORTING
             it_filters = lt_filters
           IMPORTING
             et_result       = lt_result
             et_companycode  = lv_companycode
             et_fiscalyear   = lv_fiscalyear
             et_fiscalperiod = lv_fiscalperiod ).

        lt_old = CORRESPONDING #( lt_result ).

        "删除当期数据
        DELETE FROM zztta004_old WHERE zzyear = @lv_fiscalyear
                                   AND zzmonth = @lv_fiscalperiod
                                   AND br_ent_cod = @lv_companycode.

        "将当期数据存入表中
        MODIFY zztta004_old FROM TABLE @lt_old.

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
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD read_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi005,
          ls_result TYPE zc_query_fi005.

    DATA: lr_companycode TYPE RANGE OF zc_query_fi005-br_ent_cod,
          lr_zzyear      TYPE RANGE OF zc_query_fi005-zzyear,
          lr_zzmonth     TYPE RANGE OF zc_query_fi005-zzmonth,
          lr_uuid        TYPE RANGE OF zc_query_fi005-uuid.

    DATA: lv_companycode TYPE zc_query_fi005-br_ent_cod.

    "当期年度期间
    DATA: lv_fiscalyear   TYPE i_accountingdocumentjournal-fiscalyear,
          lv_fiscalperiod TYPE i_accountingdocumentjournal-fiscalperiod.

    "期初年度期间
    DATA: lv_fiscalyear_old   TYPE i_accountingdocumentjournal-fiscalyear,
          lv_fiscalperiod_old TYPE i_accountingdocumentjournal-fiscalperiod.

    "年初年度
    DATA: lv_fiscalyear_nc TYPE i_accountingdocumentjournal-fiscalyear.

    DATA: lv_sql TYPE string.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'BR_ENT_COD'.
          lr_companycode = CORRESPONDING #( ls_filter-range ).
          lv_companycode = lr_companycode[ 1 ]-low.
        WHEN 'ZZYEAR'.
          lr_zzyear = CORRESPONDING #( ls_filter-range ).
          lv_fiscalyear = lr_zzyear[ 1 ]-low.
        WHEN 'ZZMONTH'.
          lr_zzmonth = CORRESPONDING #( ls_filter-range ).
          lv_fiscalperiod = lr_zzmonth[ 1 ]-low.
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).

          SPLIT lr_uuid[ 1 ]  AT '-' INTO TABLE DATA(lt_range).

          READ TABLE lt_range INTO DATA(ls_range) INDEX 3.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_companycode = ls_range.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 4.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_fiscalyear = ls_range.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 5.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_fiscalperiod = ls_range.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    IF lv_fiscalperiod = 1.
      lv_fiscalyear_old = lv_fiscalyear - 1.
      lv_fiscalperiod_old = 12.

      lv_sql = |b~profitlossaccounttype IS INITIAL|.
    ELSE.
      lv_fiscalyear_old = lv_fiscalyear.
      lv_fiscalperiod_old = lv_fiscalperiod - 1.
    ENDIF.

    lv_fiscalyear_nc = lv_fiscalyear - 1.

    IF lv_fiscalperiod_old = 12.

    ENDIF.

    "当期数据
    SELECT a~companycode,
           a~fiscalyear,
           a~fiscalperiod,
           a~glaccount,
           a~functionalarea,
           a~transactioncurrency,     "交易货币
           a~companycodecurrency,     "本位币
           a~debitamountincocodecrcy,
           a~debitcreditcode,
           ( 0 - a~creditamountincocodecrcy ) AS creditamountincocodecrcy,
           a~debitamountintranscrcy,
           ( 0 - a~creditamountintranscrcy ) AS creditamountintranscrcy,
           b~profitlossaccounttype
      FROM i_accountingdocumentjournal( p_language = @sy-langu ) AS a
      LEFT JOIN i_glaccount AS b ON a~companycode = b~companycode
                                AND a~glaccount = b~glaccount
     WHERE a~companycode = @lv_companycode
       AND a~fiscalyear = @lv_fiscalyear
       AND a~fiscalperiod = @lv_fiscalperiod
       AND a~ledger = '0L'
      INTO TABLE @DATA(lt_data).
    SORT lt_data BY companycode fiscalyear fiscalperiod glaccount functionalarea transactioncurrency.

    "期初数据
    SELECT a~zzyear,
           a~zzmonth,
           a~br_ent_cod,
           a~br_acc_cod,
           a~br_acc_area,
           a~currency_t,
           a~sys_id,
           a~gp_ent_cod,
           a~gp_ent_des,
           a~br_ent_des,
           a~gp_acc_cod,
           a~gp_acc_des,
           a~br_acc_des,
           a~currency,
           a~beginbl_y,
           a~beginbl,
           a~debitbl,
           a~creditbl,
           a~debitbl_a,
           a~creditbl_a,
           a~endbl,
           a~beginbl_y_t,
           a~beginbl_t,
           a~debitbl_t,
           a~creditbl_t,
           a~debitbl_a_t,
           a~creditbl_a_t,
           a~endbl_t,
           a~dateupd,
           b~profitlossaccounttype
      FROM zztta004_old AS a
      JOIN i_glaccount AS b ON a~br_ent_cod = b~companycode
                           AND a~br_acc_cod = b~glaccount
     WHERE a~br_ent_cod = @lv_companycode
       AND a~zzyear = @lv_fiscalyear_old
       AND a~zzmonth = @lv_fiscalperiod_old
       AND a~sys_id = '华望SAP S4HC'
*       AND (lv_sql)
      INTO TABLE @DATA(lt_old).

    "取13期数据
    IF lv_fiscalperiod = 1.
      SELECT a~zzyear,
             a~zzmonth,
             a~br_ent_cod,
             a~br_acc_cod,
             a~br_acc_area,
             a~currency_t,
             a~sys_id,
             a~gp_ent_cod,
             a~gp_ent_des,
             a~br_ent_des,
             a~gp_acc_cod,
             a~gp_acc_des,
             a~br_acc_des,
             a~currency,
             a~beginbl_y,
             a~beginbl,
             a~debitbl,
             a~creditbl,
             a~debitbl_a,
             a~creditbl_a,
             a~endbl,
             a~beginbl_y_t,
             a~beginbl_t,
             a~debitbl_t,
             a~creditbl_t,
             a~debitbl_a_t,
             a~creditbl_a_t,
             a~endbl_t,
             a~dateupd,
             b~profitlossaccounttype
        FROM zztta004_old AS a
        JOIN i_glaccount AS b ON a~br_ent_cod = b~companycode
                             AND a~br_acc_cod = b~glaccount
       WHERE a~br_ent_cod = @lv_companycode
         AND a~zzyear = @lv_fiscalyear_old
         AND a~zzmonth = 13
         AND a~sys_id = '华望SAP S4HC'
*         AND (lv_sql)
         APPENDING TABLE @lt_old.
    ENDIF.

    SORT lt_old BY br_acc_cod br_acc_area currency_t zzmonth DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_old COMPARING br_acc_cod br_acc_area currency_t.

    "年初数据
    SELECT a~*
      FROM zztta004_old AS a
      JOIN i_glaccount AS b ON a~br_ent_cod = b~companycode
                           AND a~br_acc_cod = b~glaccount
     WHERE a~br_ent_cod = @lv_companycode
       AND a~zzyear = @lv_fiscalyear_nc
       AND a~zzmonth = 13
       AND a~sys_id = '华望SAP S4HC'
       AND b~profitlossaccounttype IS INITIAL
      INTO TABLE @DATA(lt_old_nc).

    SELECT a~*
      FROM zztta004_old AS a
      JOIN i_glaccount AS b ON a~br_ent_cod = b~companycode
                           AND a~br_acc_cod = b~glaccount
     WHERE a~br_ent_cod = @lv_companycode
       AND a~zzyear = @lv_fiscalyear_nc
       AND a~zzmonth = 12
       AND a~sys_id = '华望SAP S4HC'
       AND b~profitlossaccounttype IS INITIAL
       APPENDING TABLE @lt_old_nc.
    SORT lt_old_nc BY br_acc_cod br_acc_area currency_t zzmonth DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_old_nc COMPARING br_acc_cod br_acc_area currency_t.

    "损益科目特殊逻辑
    SELECT glaccount,
           transactioncurrency,     "交易货币
           companycodecurrency,     "本位币
      SUM( amountincompanycodecurrency ) AS amountincompanycodecurrency,
      SUM( amountinbalancetransaccrcy  ) AS amountinbalancetransaccrcy
      FROM i_glaccountlineitem
     WHERE companycode = @lv_companycode
       AND fiscalyear = @lv_fiscalyear
       AND fiscalperiod = 0
       AND ledger = '0L'
       AND glaccount = '4104050000'
     GROUP BY glaccount, transactioncurrency, companycodecurrency
      INTO TABLE @DATA(lt_sykm).
    SORT lt_sykm BY glaccount transactioncurrency.

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
    ENDIF.

    IF lt_old IS NOT INITIAL.
      WITH +i AS ( SELECT DISTINCT br_acc_cod FROM @lt_old AS i )
      SELECT a~glaccount,
             a~glaccountname
        FROM i_glaccounttext AS a
        JOIN +i AS i ON a~glaccount = i~br_acc_cod
       WHERE a~chartofaccounts = 'YCOA'
         AND a~language = @sy-langu
         APPENDING TABLE @lt_glaccounttext.
    ENDIF.

    "损益科目
    SELECT glaccount,
           glaccountname
      FROM i_glaccounttext
     WHERE chartofaccounts = 'YCOA'
       AND language = @sy-langu
       AND glaccount = '4104050000'
       APPENDING TABLE @lt_glaccounttext.

    SORT lt_glaccounttext BY glaccount.
    DELETE ADJACENT DUPLICATES FROM lt_glaccounttext COMPARING glaccount.

    "处理当期数据
    CLEAR: ls_result.
    LOOP AT lt_data INTO DATA(ls_data).

      DATA(ls_save) = ls_data.

      IF ls_data-debitcreditcode = 'S'.
        ls_result-debitbl = ls_result-debitbl + ls_data-debitamountincocodecrcy.    "本期借方金额（本位币）
        ls_result-debitbl_t = ls_result-debitbl_t + ls_data-debitamountintranscrcy. "本期借方金额（交易货币）
      ENDIF.

      IF ls_data-debitcreditcode = 'H'.
        ls_result-creditbl = ls_result-creditbl + ls_data-creditamountincocodecrcy.     "本期贷方金额（本位币）
        ls_result-creditbl_t = ls_result-creditbl_t + ls_data-creditamountintranscrcy.  "本期贷方金额（交易货币）
      ENDIF.

      AT END OF transactioncurrency.

        ls_result-creditbl = 0 - ls_result-creditbl.        "本期贷方金额（本位币）
        ls_result-creditbl_t = 0 - ls_result-creditbl_t.    "本期贷方金额（交易货币）

        ls_result-zzyear = ls_save-fiscalyear.
        ls_result-zzmonth = ls_save-fiscalperiod.
        ls_result-br_ent_cod = ls_save-companycode.
        ls_result-br_ent_des = lv_companycodename.
        ls_result-br_acc_cod = ls_save-glaccount.
        ls_result-currency = ls_save-companycodecurrency.     "本位币
        ls_result-currency_t = ls_save-transactioncurrency.   "交易货币
        ls_result-br_acc_area = ls_data-functionalarea.
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

        "年初余额（本位币）
        IF ls_save-profitlossaccounttype IS INITIAL.
          READ TABLE lt_old_nc INTO DATA(ls_old_nc) WITH KEY br_acc_cod = ls_result-br_acc_cod
                                                             br_acc_area = ls_result-br_acc_area
                                                             currency_t = ls_result-currency_t
                                                             BINARY SEARCH.
          IF sy-subrc = 0.
*            ls_result-beginbl_y = ls_old_nc-debitbl_a - ls_old_nc-creditbl_a.
            ls_result-beginbl_y = ls_old_nc-endbl.
            CLEAR: ls_old_nc.
          ENDIF.
        ENDIF.

        ls_result-debitbl_a = ls_result-debitbl.      "借方累计金额（本位币）
        ls_result-creditbl_a = ls_result-creditbl.    "贷方累计金额（本位币）

        ls_result-debitbl_a_t = ls_result-debitbl_t.     "借方累计金额（交易货币）
        ls_result-creditbl_a_t = ls_result-creditbl_t.   "贷方累计金额（交易货币）

        READ TABLE lt_old INTO DATA(ls_old) WITH KEY br_acc_cod = ls_result-br_acc_cod
                                                     br_acc_area = ls_result-br_acc_area
                                                     currency_t = ls_result-currency_t
                                                     BINARY SEARCH.
        IF sy-subrc = 0.

*          ls_result-beginbl = ls_old-debitbl_a - ls_old-creditbl_a.        "期初余额（本位币）
          ls_result-beginbl = ls_old-endbl.                                  "期初余额（本位币）

          IF lv_fiscalperiod <> 1.
            ls_result-debitbl_a = ls_old-debitbl_a + ls_result-debitbl_a.      "借方累计金额（本位币）
            ls_result-creditbl_a = ls_old-creditbl_a + ls_result-creditbl_a.   "贷方累计金额（本位币）
          ENDIF.

*          ls_result-beginbl_t = ls_old-debitbl_a_t - ls_old-creditbl_a_t.        "期初余额（交易货币）
          ls_result-beginbl_t = ls_old-endbl_t.                                     "期初余额（交易货币）

          IF lv_fiscalperiod <> 1.
            ls_result-debitbl_a_t = ls_old-debitbl_a_t + ls_result-debitbl_a_t.      "借方累计金额（交易货币）
            ls_result-creditbl_a_t = ls_old-creditbl_a_t + ls_result-creditbl_a_t.   "贷方累计金额（交易货币）
          ENDIF.

        ENDIF.

        IF ls_save-profitlossaccounttype IS NOT INITIAL AND lv_fiscalperiod = 1.
          CLEAR: ls_result-beginbl, ls_result-beginbl_t.
        ENDIF.

        "年初余额（交易货币）
        IF ls_save-profitlossaccounttype IS INITIAL.
          READ TABLE lt_old_nc INTO ls_old_nc WITH KEY br_acc_cod = ls_result-br_acc_cod
                                                       br_acc_area = ls_result-br_acc_area
                                                       currency_t = ls_result-currency_t
                                                       BINARY SEARCH.
          IF sy-subrc = 0.
*            ls_result-beginbl_y_t = ls_old_nc-debitbl_a_t - ls_old_nc-creditbl_a_t.
            ls_result-beginbl_y_t = ls_old_nc-endbl_t.
            CLEAR: ls_old_nc.
          ENDIF.
        ENDIF.

        "特殊科目
        IF ls_result-br_acc_cod = '4104050000'.
          READ TABLE lt_sykm INTO DATA(ls_sykm) WITH KEY glaccount = ls_result-br_acc_cod
                                                         transactioncurrency = ls_result-currency_t
                                                         BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-beginbl_y = ls_sykm-amountincompanycodecurrency.   "年初余额（本位币）
            ls_result-beginbl_y_t = ls_sykm-amountinbalancetransaccrcy.   "年初余额（交易货币）
            CLEAR: ls_sykm.
          ENDIF.

          IF lv_fiscalperiod = 1.
            ls_result-beginbl = ls_result-beginbl_y.  "期初余额（本位币）
            ls_result-beginbl_t = ls_result-beginbl_y_t.  "期初余额（交易货币）
          ELSE.
            ls_result-beginbl = ls_old-endbl.  "期初余额（本位币）
            ls_result-beginbl_t = ls_old-endbl_t.  "期初余额（交易货币）
          ENDIF.

          ls_result-endbl = ls_result-beginbl + ls_result-debitbl + ls_result-creditbl. "期末余额（本位币）
          ls_result-endbl_t = ls_result-beginbl_t + ls_result-debitbl_t + ls_result-creditbl_t.   "期末余额（交易货币）

        ELSE.
          ls_result-endbl = ls_result-beginbl_y + ls_result-debitbl_a + ls_result-creditbl_a. "期末余额（本位币）
          ls_result-endbl_t = ls_result-beginbl_y_t + ls_result-debitbl_a_t + ls_result-creditbl_a_t.   "期末余额（交易货币）
        ENDIF.

        ls_result-uuid = ls_result-currency_t && '-' && ls_result-br_acc_cod && '-' &&
                         ls_result-br_ent_cod && '-' && ls_result-zzyear && '-' && ls_result-zzmonth && '-' && ls_result-br_acc_area.

        APPEND ls_result TO lt_result.
        CLEAR: ls_result, ls_old.
      ENDAT.
    ENDLOOP.
    SORT lt_result BY br_acc_cod currency_t br_acc_area.

    "处理上期且不包含当期的数据
    LOOP AT lt_old INTO ls_old.
      READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY br_acc_cod = ls_old-br_acc_cod
                                                           currency_t = ls_old-currency_t
                                                           br_acc_area = ls_old-br_acc_area
                                                           BINARY SEARCH.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR: ls_result.
      ls_result-zzyear = lv_fiscalyear.
      ls_result-zzmonth = lv_fiscalperiod.
      ls_result-br_ent_cod = lv_companycode.
      ls_result-br_ent_des = lv_companycodename.
      ls_result-br_acc_cod = ls_old-br_acc_cod.
      ls_result-currency = ls_old-currency.       "本位币
      ls_result-currency_t = ls_old-currency_t.   "交易货币
      ls_result-br_acc_area = ls_old-br_acc_area.
      ls_result-gp_ent_cod = 'G392'.
      ls_result-gp_ent_des = '启境智能汽车科技（广州）有限公司'.
      ls_result-sys_id = '启境SAP S4HC'.
      ls_result-dateupd = sy-datum && sy-uzeit.

      "科目名称
      READ TABLE lt_glaccounttext INTO ls_glaccounttext WITH KEY glaccount = ls_result-br_acc_cod BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-br_acc_des = ls_glaccounttext-glaccountname.
        CLEAR: ls_glaccounttext.
      ENDIF.

      "年初余额（本位币）
      READ TABLE lt_old_nc INTO ls_old_nc WITH KEY br_acc_cod = ls_result-br_acc_cod
                                                   br_acc_area = ls_result-br_acc_area
                                                   currency_t = ls_result-currency_t
                                                   BINARY SEARCH.
      IF sy-subrc = 0.
*        ls_result-beginbl_y = ls_old_nc-debitbl_a - ls_old_nc-creditbl_a.
        ls_result-beginbl_y = ls_old_nc-endbl.
        CLEAR: ls_old_nc.
      ENDIF.

*      ls_result-beginbl = ls_old-debitbl_a - ls_old-creditbl_a.     "期初余额（本位币）
      ls_result-beginbl = ls_old-endbl.                             "期初余额（本位币）

      IF lv_fiscalperiod <> 1.
        ls_result-debitbl_a = ls_old-debitbl_a.                       "借方累计金额（本位币）
        ls_result-creditbl_a = ls_old-creditbl_a.                     "贷方累计金额（本位币）
      ENDIF.

      "年初余额（交易货币）
      READ TABLE lt_old_nc INTO ls_old_nc WITH KEY br_acc_cod = ls_result-br_acc_cod
                                                   br_acc_area = ls_result-br_acc_area
                                                   currency_t = ls_result-currency_t
                                                   BINARY SEARCH.
      IF sy-subrc = 0.
*        ls_result-beginbl_y_t = ls_old_nc-debitbl_a_t - ls_old_nc-creditbl_a_t.
        ls_result-beginbl_y_t = ls_old_nc-endbl_t.
        CLEAR: ls_old_nc.
      ENDIF.

*      ls_result-beginbl_t = ls_old-debitbl_a_t - ls_old-creditbl_a_t.   "期初余额（交易货币）
      ls_result-beginbl_t = ls_old-endbl_t.                             "期初余额（交易货币）

      IF lv_fiscalperiod <> 1.
        ls_result-debitbl_a_t = ls_old-debitbl_a_t.                       "借方累计金额（交易货币）
        ls_result-creditbl_a_t = ls_old-creditbl_a_t.                     "贷方累计金额（交易货币）
      ENDIF.

      IF ls_old-profitlossaccounttype IS NOT INITIAL AND lv_fiscalperiod = 1.
        CLEAR: ls_result-beginbl, ls_result-beginbl_t.
      ENDIF.

      "特殊科目
      IF ls_result-br_acc_cod = '4104050000'.

        READ TABLE lt_sykm INTO ls_sykm WITH KEY glaccount = ls_result-br_acc_cod
                                                 transactioncurrency = ls_result-currency_t
                                                 BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-beginbl_y = ls_sykm-amountincompanycodecurrency.   "年初余额（本位币）
          ls_result-beginbl_y_t = ls_sykm-amountinbalancetransaccrcy.   "年初余额（交易货币）
          CLEAR: ls_sykm.
        ENDIF.

        IF lv_fiscalperiod = 1.
          ls_result-beginbl = ls_result-beginbl_y.  "期初余额（本位币）
          ls_result-beginbl_t = ls_result-beginbl_y_t.  "期初余额（交易货币）
        ELSE.
          ls_result-beginbl = ls_old-endbl.  "期初余额（本位币）
          ls_result-beginbl_t = ls_old-endbl_t.  "期初余额（交易货币）
        ENDIF.

        ls_result-endbl = ls_result-beginbl + ls_result-debitbl + ls_result-creditbl.   "期末余额（本位币）
        ls_result-endbl_t = ls_result-beginbl_t + ls_result-debitbl_t + ls_result-creditbl_t.   "期末余额（交易货币）

      ELSE.
        ls_result-endbl = ls_result-beginbl_y + ls_result-debitbl_a + ls_result-creditbl_a.   "期末余额（本位币）
        ls_result-endbl_t = ls_result-beginbl_y + ls_result-debitbl_a_t + ls_result-creditbl_a_t.   "期末余额（交易货币）
      ENDIF.

      ls_result-uuid = ls_result-currency_t && '-' && ls_result-br_acc_cod && '-' &&
                       ls_result-br_ent_cod && '-' && ls_result-zzyear && '-' && ls_result-zzmonth && '-' && ls_result-br_acc_area.

      APPEND ls_result TO lt_result.
      SORT lt_result BY br_acc_cod currency_t br_acc_area.
    ENDLOOP.

    "损益科目特殊逻辑
    IF lv_fiscalperiod = 1.
      DATA(lt_data_sy) = lt_data.
      DATA(lt_old_sy) = lt_old.

      DELETE lt_data_sy WHERE glaccount <> '4104050000'.
      DELETE lt_old_sy WHERE br_acc_cod <> '4104050000'.

      IF lt_data_sy IS INITIAL AND lt_old_sy IS INITIAL.

        CLEAR: ls_result.
        LOOP AT lt_sykm INTO ls_sykm.
          DATA(ls_save2) = ls_sykm.

          ls_result-beginbl_y = ls_result-beginbl_y + ls_sykm-amountincompanycodecurrency.   "年初余额（本位币）
          ls_result-beginbl_y_t = ls_result-beginbl_y_t + ls_sykm-amountinbalancetransaccrcy.   "年初余额（交易货币）

          AT END OF transactioncurrency.
            ls_result-zzyear = lv_fiscalyear.
            ls_result-zzmonth = lv_fiscalperiod.
            ls_result-br_ent_cod = lv_companycode.
            ls_result-br_ent_des = lv_companycodename.
            ls_result-br_acc_cod = ls_save2-glaccount.
            ls_result-currency = ls_save2-companycodecurrency.       "本位币
            ls_result-currency_t = ls_save2-transactioncurrency.   "交易货币
            ls_result-gp_ent_cod = 'G392'.
            ls_result-gp_ent_des = '启境智能汽车科技（广州）有限公司'.
            ls_result-sys_id = '启境SAP S4HC'.
            ls_result-dateupd = sy-datum && sy-uzeit.

            ls_result-beginbl = ls_result-beginbl_y.  "期初余额（本位币）
            ls_result-beginbl_t = ls_result-beginbl_y_t.  "期初余额（交易货币）

            ls_result-endbl = ls_result-beginbl + ls_result-debitbl - ls_result-creditbl.   "期末余额（本位币）
            ls_result-endbl_t = ls_result-beginbl_t + ls_result-debitbl_t - ls_result-creditbl_t.   "期末余额（交易货币）

            "科目名称
            READ TABLE lt_glaccounttext INTO ls_glaccounttext WITH KEY glaccount = ls_result-br_acc_cod BINARY SEARCH.
            IF sy-subrc = 0.
              ls_result-br_acc_des = ls_glaccounttext-glaccountname.
              CLEAR: ls_glaccounttext.
            ENDIF.

            ls_result-uuid = ls_result-currency_t && '-' && ls_result-br_acc_cod && '-' &&
                             ls_result-br_ent_cod && '-' && ls_result-zzyear && '-' && ls_result-zzmonth && '-' && ls_result-br_acc_area.

            APPEND ls_result TO lt_result.
            CLEAR: ls_result.
          ENDAT.
        ENDLOOP.
      ENDIF.
    ENDIF.

    SORT lt_result BY br_acc_cod currency_t br_acc_area.

    et_result = lt_result.
    et_companycode = lv_companycode.
    et_fiscalyear = lv_fiscalyear.
    et_fiscalperiod = lv_fiscalperiod.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI005'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
