CLASS zzcl_query_fi006 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_result TYPE TABLE OF zc_query_fi006.

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
        et_companycode  TYPE  i_operationalacctgdocitem-companycode
        et_fiscalyear   TYPE  i_operationalacctgdocitem-fiscalyear
        et_fiscalperiod TYPE  i_operationalacctgdocitem-fiscalperiod .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_FI006 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result       TYPE TABLE OF zc_query_fi006,
          lt_old          TYPE TABLE OF zztta005_old,
          lv_companycode  TYPE i_operationalacctgdocitem-companycode,
          lv_fiscalyear   TYPE i_operationalacctgdocitem-fiscalyear,
          lv_fiscalperiod TYPE i_operationalacctgdocitem-fiscalperiod.

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
        DELETE FROM zztta005_old WHERE zzyear = @lv_fiscalyear
                                   AND zzmonth = @lv_fiscalperiod
                                   AND br_ent_cod = @lv_companycode.

        "将当期数据存入表中
        MODIFY zztta005_old FROM TABLE @lt_old.

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
    DATA: lt_result TYPE TABLE OF zc_query_fi006,
          ls_result TYPE zc_query_fi006.

    DATA: lr_companycode TYPE RANGE OF zc_query_fi006-br_ent_cod,
          lr_zzyear      TYPE RANGE OF zc_query_fi006-zzyear,
          lr_zzmonth     TYPE RANGE OF zc_query_fi006-zzmonth,
          lr_uuid        TYPE RANGE OF zc_query_fi006-uuid.

    DATA: lv_companycode TYPE zc_query_fi006-br_ent_cod.

    "当期年度期间
    DATA: lv_fiscalyear   TYPE i_operationalacctgdocitem-fiscalyear,
          lv_fiscalperiod TYPE i_operationalacctgdocitem-fiscalperiod.

    "期初年度期间
    DATA: lv_fiscalyear_old   TYPE i_operationalacctgdocitem-fiscalyear,
          lv_fiscalperiod_old TYPE i_operationalacctgdocitem-fiscalperiod.

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

          READ TABLE lt_range INTO DATA(ls_range) INDEX 4.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_companycode = ls_range.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 5.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_fiscalyear = ls_range.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 6.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            lv_fiscalperiod = ls_range.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    IF lv_fiscalperiod = 1.
      lv_fiscalyear_old = lv_fiscalyear - 1.
      lv_fiscalperiod_old = 12.
    ELSE.
      lv_fiscalyear_old = lv_fiscalyear.
      lv_fiscalperiod_old = lv_fiscalperiod - 1.
    ENDIF.

    "当期数据
    SELECT companycode,
           fiscalyear,
           fiscalperiod,
           glaccount,
           paymentdifferencereason,
           transactioncurrency,     "交易货币
           companycodecurrency,     "本位币
           debitcreditcode,
      CASE isnegativeposting
      WHEN 'X' THEN 0 - absoluteamountincocodecrcy
      ELSE absoluteamountincocodecrcy
       END AS absoluteamountincocodecrcy,

      CASE isnegativeposting
      WHEN 'X' THEN 0 - absoluteamountintransaccrcy
      ELSE absoluteamountintransaccrcy
       END AS absoluteamountintransaccrcy

      FROM i_operationalacctgdocitem
     WHERE companycode = @lv_companycode
       AND fiscalyear = @lv_fiscalyear
       AND fiscalperiod = @lv_fiscalperiod
       AND paymentdifferencereason IS NOT INITIAL
      INTO TABLE @DATA(lt_data).
    SORT lt_data BY companycode fiscalyear fiscalperiod glaccount paymentdifferencereason transactioncurrency.

    "期初数据
    SELECT *
      FROM zztta005_old
     WHERE br_ent_cod = @lv_companycode
       AND zzyear = @lv_fiscalyear_old
       AND zzmonth = @lv_fiscalperiod_old
       AND sys_id = '华望SAP S4HC'
      INTO TABLE @DATA(lt_old).
    SORT lt_old BY br_acc_cod cf_cod currency_t.

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

      "现金流量名称
      WITH +i AS ( SELECT DISTINCT paymentdifferencereason FROM @lt_data AS i )
      SELECT a~paymentdifferencereason,
             a~paymentdifferencereasondesc
        FROM i_paymentdifferencereasont AS a
        JOIN +i AS i ON a~paymentdifferencereason = i~paymentdifferencereason
       WHERE a~companycode = @lv_companycode
         AND a~language = @sy-langu
        INTO TABLE @DATA(lt_paymentdifferencereason).
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

      WITH +i AS ( SELECT DISTINCT cf_cod FROM @lt_old AS i )
      SELECT a~paymentdifferencereason,
             a~paymentdifferencereasondesc
        FROM i_paymentdifferencereasont AS a
        JOIN +i AS i ON a~paymentdifferencereason = i~cf_cod
       WHERE a~companycode = @lv_companycode
         AND a~language = @sy-langu
         APPENDING TABLE @lt_paymentdifferencereason.
    ENDIF.

    SORT lt_glaccounttext BY glaccount.
    DELETE ADJACENT DUPLICATES FROM lt_glaccounttext COMPARING glaccount.

    SORT lt_paymentdifferencereason BY paymentdifferencereason.
    DELETE ADJACENT DUPLICATES FROM lt_paymentdifferencereason COMPARING paymentdifferencereason.


    "处理当期数据
    CLEAR: ls_result.
    LOOP AT lt_data INTO DATA(ls_data).

      DATA(ls_save) = ls_data.

      IF ls_data-debitcreditcode = 'S'.
        ls_result-debitbl = ls_result-debitbl + ls_data-absoluteamountincocodecrcy.    "本期借方金额（本位币）
        ls_result-debitbl_t = ls_result-debitbl_t + ls_data-absoluteamountintransaccrcy. "本期借方金额（交易货币）
      ENDIF.

      IF ls_data-debitcreditcode = 'H'.
        ls_result-creditbl = ls_result-creditbl + ls_data-absoluteamountincocodecrcy.     "本期贷方金额（本位币）
        ls_result-creditbl_t = ls_result-creditbl_t + ls_data-absoluteamountintransaccrcy.  "本期贷方金额（交易货币）
      ENDIF.

      AT END OF transactioncurrency.

        ls_result-zzyear = ls_save-fiscalyear.
        ls_result-zzmonth = ls_save-fiscalperiod.
        ls_result-br_ent_cod = ls_save-companycode.
        ls_result-br_ent_des = lv_companycodename.
        ls_result-br_acc_cod = ls_save-glaccount.
        ls_result-cf_cod = ls_save-paymentdifferencereason.
        ls_result-currency = ls_save-companycodecurrency.     "本位币
        ls_result-currency_t = ls_save-transactioncurrency.   "交易货币
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

        "现金流量名称
        READ TABLE lt_paymentdifferencereason INTO DATA(ls_paymentdifferencereason) WITH KEY paymentdifferencereason = ls_result-cf_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-cf_des = ls_paymentdifferencereason-paymentdifferencereasondesc.
          CLEAR: ls_paymentdifferencereason.
        ENDIF.

        ls_result-debitbl_a = ls_result-debitbl.      "借方累计金额（本位币）
        ls_result-creditbl_a = ls_result-creditbl.    "贷方累计金额（本位币）

        ls_result-debitbl_a_t = ls_result-debitbl_t.      "借方累计金额（交易货币）
        ls_result-creditbl_a_t = ls_result-creditbl_t.    "贷方累计金额（交易货币）

        READ TABLE lt_old INTO DATA(ls_old) WITH KEY br_acc_cod = ls_result-br_acc_cod
                                                     cf_cod = ls_result-cf_cod
                                                     currency_t = ls_result-currency_t
                                                     BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-debitbl_a = ls_old-debitbl_a + ls_result-debitbl_a.      "借方累计金额（本位币）
          ls_result-creditbl_a = ls_old-creditbl_a + ls_result-creditbl_a.   "贷方累计金额（本位币）

          ls_result-debitbl_a_t = ls_old-debitbl_a_t + ls_result-debitbl_a_t.      "借方累计金额（交易货币）
          ls_result-creditbl_a_t = ls_old-creditbl_a_t + ls_result-creditbl_a_t.   "贷方累计金额（交易货币）
          CLEAR: ls_old.
        ENDIF.

        ls_result-uuid = ls_result-currency_t && '-' && ls_result-br_acc_cod && '-' && ls_result-cf_cod && '-' &&
                         ls_result-br_ent_cod && '-' && ls_result-zzyear && '-' && ls_result-zzmonth.

        APPEND ls_result TO lt_result.
        CLEAR: ls_result.
      ENDAT.

    ENDLOOP.

    SORT lt_result BY br_acc_cod cf_cod currency_t.

    "处理上期且不包含当期的数据
    LOOP AT lt_old INTO ls_old.
      READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY br_acc_cod = ls_old-br_acc_cod
                                                           cf_cod = ls_old-cf_cod
                                                           currency_t = ls_old-currency_t
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
      ls_result-cf_cod = ls_old-cf_cod.
      ls_result-currency = ls_old-currency.     "本位币
      ls_result-currency_t = ls_old-currency_t.   "交易货币
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

      "现金流量名称
      READ TABLE lt_paymentdifferencereason INTO ls_paymentdifferencereason WITH KEY paymentdifferencereason = ls_result-cf_cod BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-cf_des = ls_paymentdifferencereason-paymentdifferencereasondesc.
        CLEAR: ls_paymentdifferencereason.
      ENDIF.

      ls_result-debitbl_a = ls_old-debitbl_a.           "借方累计金额（本位币）
      ls_result-creditbl_a = ls_old-creditbl_a.         "贷方累计金额（本位币）
      ls_result-debitbl_a_t = ls_old-debitbl_a_t.       "借方累计金额（交易货币）
      ls_result-creditbl_a_t = ls_old-creditbl_a_t.     "贷方累计金额（交易货币）

      ls_result-uuid = ls_result-currency_t && '-' && ls_result-br_acc_cod && '-' && ls_result-cf_cod && '-' &&
                         ls_result-br_ent_cod && '-' && ls_result-zzyear && '-' && ls_result-zzmonth.

      APPEND ls_result TO lt_result.

      SORT lt_result BY br_acc_cod cf_cod currency_t.

    ENDLOOP.

    et_result = lt_result.
    et_companycode = lv_companycode.
    et_fiscalyear = lv_fiscalyear.
    et_fiscalperiod = lv_fiscalperiod.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI006'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
