CLASS zzcl_query_fi004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_fi004.

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



CLASS ZZCL_QUERY_FI004 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi004,
          ls_result TYPE zc_query_fi004.

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
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD read_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi004,
          ls_result TYPE zc_query_fi004.

    DATA: lr_companycode TYPE RANGE OF zc_query_fi004-ent_cod,
          lr_zzyear      TYPE RANGE OF zc_query_fi004-zzyear,
          lr_zzmonth     TYPE RANGE OF zc_query_fi004-zzmonth,
          lr_uuid        TYPE RANGE OF zc_query_fi004-uuid.

    DATA: lv_companycode(35) TYPE c,
          lv_zzyear(35)      TYPE c,
          lv_zzmonth(35)     TYPE c.

    DATA: lv_num TYPE numc4 VALUE 1.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'ENT_COD'.
          lr_companycode = CORRESPONDING #( ls_filter-range ).
        WHEN 'ZZYEAR'.
          lr_zzyear = CORRESPONDING #( ls_filter-range ).
        WHEN 'ZZMONTH'.
          lr_zzmonth = CORRESPONDING #( ls_filter-range ).
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).

          SPLIT lr_uuid[ 1 ]  AT '-' INTO TABLE DATA(lt_range).

          READ TABLE lt_range INTO DATA(ls_range) INDEX 5.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            APPEND VALUE #( sign = ls_range(1)
                            option = ls_range+1(2)
                            low = ls_range+3(4)
                       ) TO lr_companycode.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 6.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            APPEND VALUE #( sign = ls_range(1)
                            option = ls_range+1(2)
                            low = ls_range+3(4)
                       ) TO lr_zzyear.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 7.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            APPEND VALUE #( sign = ls_range(1)
                            option = ls_range+1(2)
                            low = ls_range+3(2)
                       ) TO lr_zzmonth.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    READ TABLE lr_companycode INTO DATA(lrs_companycode) INDEX 1.
    IF sy-subrc = 0.
      lv_companycode = lrs_companycode.
    ENDIF.

    READ TABLE lr_zzyear INTO DATA(lrs_zzyear) INDEX 1.
    IF sy-subrc = 0.
      lv_zzyear = lrs_zzyear.
    ENDIF.

    READ TABLE lr_zzmonth INTO DATA(lrs_zzmonth) INDEX 1.
    IF sy-subrc = 0.
      lv_zzmonth = lrs_zzmonth.
    ENDIF.

    SELECT fiscalyear,
           fiscalperiod,
           companycode,
           accountingdocument,
           ledgergllineitem,
           wbselementexternalid,
           debitamountincocodecrcy,
           creditamountincocodecrcy,
           documentitemtext,
           glaccount
      FROM i_accountingdocumentjournal
     WHERE ledger = '0L'
       AND companycode IN @lr_companycode
       AND fiscalyear IN @lr_zzyear
       AND fiscalperiod IN @lr_zzmonth
      INTO TABLE @DATA(lt_accountingdocumentjournal).
    SORT lt_accountingdocumentjournal BY fiscalyear fiscalperiod accountingdocument ledgergllineitem.

    "公司名称
    SELECT SINGLE
           companycodename
      FROM i_companycodevh
     WHERE companycode IN @lr_companycode
      INTO @DATA(lv_companycodename).

    IF lt_accountingdocumentjournal IS NOT INITIAL.
      "项目数据
      SELECT *
        FROM zztfi011
        INTO TABLE @DATA(lt_ztfi011).
      SORT lt_ztfi011 BY glaccount_from glaccount_to zzitemtype zzcode.

      "修改数据
      SELECT *
        FROM zztfi012
         FOR ALL ENTRIES IN @lt_accountingdocumentjournal
       WHERE fiscalyear = @lt_accountingdocumentjournal-fiscalyear
         AND companycode = @lt_accountingdocumentjournal-companycode
         AND accountingdocument = @lt_accountingdocumentjournal-accountingdocument
         AND ledgergllineitem = @lt_accountingdocumentjournal-ledgergllineitem
        INTO TABLE @DATA(lt_ztfi012).
      SORT lt_ztfi012 BY fiscalyear companycode accountingdocument ledgergllineitem zzitemtype zzcode.

    ENDIF.

    LOOP AT lt_accountingdocumentjournal INTO DATA(ls_accountingdocumentjournal).
      CLEAR: ls_result.

      ls_result-ent_des = lv_companycodename.
      ls_result-zzyear = ls_accountingdocumentjournal-fiscalyear.
      ls_result-zzmonth = ls_accountingdocumentjournal-fiscalperiod.
      ls_result-gp_ent_cod = 'G392'.
      ls_result-gp_ent_des = '启境智能汽车科技（广州）有限公司'.
      ls_result-ent_cod = ls_accountingdocumentjournal-companycode.
      ls_result-voucher = ls_accountingdocumentjournal-accountingdocument.
      ls_result-line = ls_accountingdocumentjournal-ledgergllineitem.
      ls_result-sys_id = '启境SAP S4HC'.

      READ TABLE lt_ztfi011 TRANSPORTING NO FIELDS WITH KEY glaccount_from = ls_accountingdocumentjournal-glaccount BINARY SEARCH.
      IF sy-subrc = 0.
        "精确查询
        LOOP AT lt_ztfi011 INTO DATA(ls_ztfi011) FROM sy-tabix.
          IF ls_ztfi011-glaccount_from = ls_accountingdocumentjournal-glaccount.

            ls_result-type = ls_ztfi011-zzitemtype.
*            ls_result-proj_cod = ls_ztfi011-zzitemtype && lv_num.
            ls_result-proj_cod = ls_accountingdocumentjournal-glaccount.
            ls_result-proj_name = ls_ztfi011-zzitemname.
            ls_result-sub_cod = ls_ztfi011-zzcode.
            ls_result-sub_des = ls_ztfi011-zzcodename.
            ls_result-amount = ls_ztfi011-zzdefault_dec.
            ls_result-note = ls_ztfi011-zzdefault.
            ls_result-zzedit = ls_ztfi011-zzedit.
            ls_result-zzmandatory = ls_ztfi011-zzmandatory.

            READ TABLE lt_ztfi012 INTO DATA(ls_ztfi012) WITH KEY fiscalyear = ls_result-zzyear
                                                                 companycode = ls_result-ent_cod
                                                                 accountingdocument = ls_result-voucher
                                                                 ledgergllineitem = ls_result-line
                                                                 zzitemtype = ls_result-type
                                                                 zzcode = ls_result-sub_cod
                                                                 BINARY SEARCH.
            IF sy-subrc = 0.
              ls_result-amount = ls_ztfi012-zzdefault_dec.
              ls_result-note = ls_ztfi012-zzdefault.
              CLEAR: ls_ztfi012.
            ENDIF.

            ls_result-uuid = ls_result-zzyear && '-' && ls_result-zzmonth && '-' &&
                             ls_result-voucher  && '-' && ls_result-line && '-' &&
                             lv_companycode && '-' && lv_zzyear && '-' && lv_zzmonth && '-' && ls_result-sub_cod.

            ls_result-dateupd = sy-datum && sy-uzeit.

            APPEND ls_result TO lt_result.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSE.
        "模糊查询
        LOOP AT lt_ztfi011 INTO ls_ztfi011 WHERE glaccount_from <= ls_accountingdocumentjournal-glaccount
                                             AND glaccount_to >= ls_accountingdocumentjournal-glaccount.

          ls_result-type = ls_ztfi011-zzitemtype.
*          ls_result-proj_cod = ls_ztfi011-zzitemtype && lv_num.
          ls_result-proj_cod = ls_accountingdocumentjournal-glaccount.
          ls_result-proj_name = ls_ztfi011-zzitemname.
          ls_result-sub_cod = ls_ztfi011-zzcode.
          ls_result-sub_des = ls_ztfi011-zzcodename.
          ls_result-amount = ls_ztfi011-zzdefault_dec.
          ls_result-note = ls_ztfi011-zzdefault.
          ls_result-zzedit = ls_ztfi011-zzedit.
          ls_result-zzmandatory = ls_ztfi011-zzmandatory.

          READ TABLE lt_ztfi012 INTO ls_ztfi012 WITH KEY fiscalyear = ls_result-zzyear
                                                         companycode = ls_result-ent_cod
                                                         accountingdocument = ls_result-voucher
                                                         ledgergllineitem = ls_result-line
                                                         zzitemtype = ls_result-type
                                                         zzcode = ls_result-sub_cod
                                                         BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-amount = ls_ztfi012-zzdefault_dec.
            ls_result-note = ls_ztfi012-zzdefault.
            CLEAR: ls_ztfi012.
          ENDIF.

          ls_result-uuid = ls_result-zzyear && '-' && ls_result-zzmonth && '-' &&
                           ls_result-voucher  && '-' && ls_result-line && '-' &&
                           lv_companycode && '-' && lv_zzyear && '-' && lv_zzmonth && '-' &&
                           ls_result-type && '-' && ls_result-sub_cod.

          ls_result-dateupd = sy-datum && sy-uzeit.

          APPEND ls_result TO lt_result.

        ENDLOOP.
      ENDIF.

      IF sy-subrc = 0.
        lv_num = lv_num + 1.
      ENDIF.

    ENDLOOP.

    et_result = lt_result.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI004'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
