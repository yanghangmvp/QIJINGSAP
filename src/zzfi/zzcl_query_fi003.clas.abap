CLASS zzcl_query_fi003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_fi003.

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



CLASS ZZCL_QUERY_FI003 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi003,
          ls_result TYPE zc_query_fi003.

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
    DATA: lt_result TYPE TABLE OF zc_query_fi003,
          ls_result TYPE zc_query_fi003.

    DATA: lr_companycode TYPE RANGE OF zc_query_fi003-ent_cod,
          lr_zzyear      TYPE RANGE OF zc_query_fi003-zzyear,
          lr_zzmonth     TYPE RANGE OF zc_query_fi003-zzmonth,
          lr_uuid        TYPE RANGE OF zc_query_fi003-uuid.

    DATA: lv_companycode(35) TYPE c,
          lv_zzyear(35)      TYPE c,
          lv_zzmonth(35)     TYPE c.

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
                            low = ls_range+3(3)
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
           substring( ledgergllineitem, 4, 3 ) AS accountingdocumentitem,
           postingdate,
           documentdate,
           debitcreditcode,
           glaccount,
           customer,
           supplier,
           documentitemtext,
           companycodecurrency,
           transactioncurrency,
           functionalarea,
           financialaccounttype,
           partnercompany,
      CASE debitcreditcode
      WHEN 'S' THEN debitamountincocodecrcy
      WHEN 'H' THEN 0 - creditamountincocodecrcy
       END AS amount,

      CASE debitcreditcode
      WHEN 'S' THEN debitamountintranscrcy
      WHEN 'H' THEN 0 - creditamountintranscrcy
       END AS amount_t

      FROM i_accountingdocumentjournal( p_language = @sy-langu )
     WHERE ledger = '0L'
       AND companycode IN @lr_companycode
       AND fiscalyear IN @lr_zzyear
       AND fiscalperiod IN @lr_zzmonth
      INTO TABLE @DATA(lt_data).
    SORT lt_data BY fiscalyear fiscalperiod accountingdocument accountingdocumentitem.

    "公司名称
    SELECT SINGLE
           companycodename
      FROM i_companycodevh
     WHERE companycode IN @lr_companycode
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

      "科目与变动维度映射表
      WITH +i AS ( SELECT DISTINCT glaccount FROM @lt_data AS i )
      SELECT a~*
        FROM zztfi009 AS a
        JOIN +i AS i ON a~glaccount = i~glaccount
        INTO TABLE @DATA(lt_zztfi009).
      SORT lt_zztfi009 BY glaccount.

      "客户数据
      WITH +i AS ( SELECT DISTINCT customer FROM @lt_data AS i WHERE customer IS NOT INITIAL )
      SELECT a~customer,
             a~customername,
             a~tradingpartner,
             a~vatregistration
        FROM i_customer AS a
        JOIN +i AS i ON a~customer = i~customer
        INTO TABLE @DATA(lt_customer).
      SORT lt_customer BY customer.

      "供应商数据
      WITH +i AS ( SELECT DISTINCT supplier FROM @lt_data AS i WHERE supplier IS NOT INITIAL )
      SELECT a~supplier,
             a~suppliername,
             a~tradingpartner,
             a~vatregistration
        FROM i_supplier AS a
        JOIN +i AS i ON a~supplier = i~supplier
        INTO TABLE @DATA(lt_supplier).
      SORT lt_supplier BY supplier.

      "现金流量编码
      SELECT a~companycode,
             a~fiscalyear,
             a~accountingdocument,
             a~accountingdocumentitem,
             a~paymentdifferencereason
        FROM i_operationalacctgdocitem AS a
        JOIN @lt_data AS b ON a~companycode = b~companycode
                          AND a~fiscalyear = b~fiscalyear
                          AND a~accountingdocument = b~accountingdocument
                          AND a~accountingdocumentitem = b~accountingdocumentitem
        INTO TABLE @DATA(lt_operationalacctgdocitem).
      SORT lt_operationalacctgdocitem BY companycode fiscalyear accountingdocument accountingdocumentitem.


      IF lt_customer IS NOT INITIAL.
        "集团统一客商编码描述
        SELECT a~company,
               a~companyname
          FROM i_globalcompany AS a
          JOIN @lt_customer AS b ON a~company = b~tradingpartner
          INTO TABLE @DATA(lt_globalcompany).

        "统一社会信用代码
        SELECT a~businesspartner,
               a~bptaxlongnumber
          FROM i_businesspartnertaxnumber AS a
          JOIN @lt_customer AS b ON a~businesspartner = b~customer
          INTO TABLE @DATA(lt_bptaxnumber).

      ENDIF.

      IF lt_supplier IS NOT INITIAL.
        SELECT a~company,
               a~companyname
          FROM i_globalcompany AS a
          JOIN @lt_supplier AS b ON a~company = b~tradingpartner
          APPENDING TABLE @lt_globalcompany.

        SELECT a~businesspartner,
               a~bptaxlongnumber
          FROM i_businesspartnertaxnumber AS a
          JOIN @lt_supplier AS b ON a~businesspartner = b~supplier
          APPENDING TABLE @lt_bptaxnumber.
      ENDIF.

      SELECT company,
             companyname
        FROM i_globalcompany
       WHERE company = 'Z999'
       APPENDING TABLE @lt_globalcompany.
      SORT lt_globalcompany BY company.
      SORT lt_bptaxnumber BY businesspartner.

      "非往来科目贸易伙伴
      SELECT company,
             companyname
        FROM i_globalcompany
         FOR ALL ENTRIES IN @lt_data
       WHERE company = @lt_data-partnercompany
        INTO TABLE @DATA(lt_partnercompany).
      SORT lt_partnercompany BY company.
    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data).
      CLEAR: ls_result.

      ls_result-ent_des = lv_companycodename.
      ls_result-zzyear = ls_data-fiscalyear.
      ls_result-zzmonth = ls_data-fiscalperiod.
      ls_result-gp_ent_cod = 'G392'.
      ls_result-gp_ent_des = '启境汽车技术（广州）有限公司'.
      ls_result-ent_cod = ls_data-companycode.
      ls_result-voucher = ls_data-accountingdocument.
      ls_result-line = ls_data-accountingdocumentitem.
      ls_result-post_date = ls_data-postingdate.
      ls_result-doc_date = ls_data-documentdate.
      ls_result-br_acc_cod = ls_data-glaccount.
      ls_result-br_cus_cod = ls_data-customer.
      ls_result-br_sup_cod = ls_data-supplier.
      ls_result-text = ls_data-documentitemtext.
      ls_result-currency = ls_data-companycodecurrency.
      ls_result-amount = ls_data-amount.
      ls_result-currency_t = ls_data-transactioncurrency.
      ls_result-amount_t = ls_data-amount_t.
      ls_result-br_acc_area = ls_data-functionalarea.
      ls_result-sys_id = '启境SAP S4HC'.

      CASE ls_data-debitcreditcode.
        WHEN 'S'.
          ls_result-direction = 'DR'.
          READ TABLE lt_zztfi009 INTO DATA(ls_zztfi009) WITH KEY glaccount = ls_result-br_acc_cod BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-zzmove = ls_zztfi009-zzmove_s.
            CLEAR: ls_zztfi009.
          ENDIF.

        WHEN 'H'.
          ls_result-direction = 'CR'.
          READ TABLE lt_zztfi009 INTO ls_zztfi009 WITH KEY glaccount = ls_result-br_acc_cod BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-zzmove = ls_zztfi009-zzmove_h.
            CLEAR: ls_zztfi009.
          ENDIF.

      ENDCASE.

      "现金流量编码
      READ TABLE lt_operationalacctgdocitem INTO DATA(ls_operationalacctgdocitem) WITH KEY companycode = ls_result-ent_cod
                                                                                           fiscalyear = ls_result-zzyear
                                                                                           accountingdocument = ls_result-voucher
                                                                                           accountingdocumentitem = ls_result-line
                                                                                           BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-cf_cod = ls_operationalacctgdocitem-paymentdifferencereason.
        CLEAR: ls_operationalacctgdocitem.
      ENDIF.

      READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext) WITH KEY glaccount = ls_result-br_acc_cod BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-br_acc_des = ls_glaccounttext-glaccountname.
        CLEAR: ls_glaccounttext.
      ENDIF.

      IF ls_result-br_cus_cod IS NOT INITIAL.
        ls_result-br_ctp_key = ls_result-br_cus_cod.

        READ TABLE lt_customer INTO DATA(ls_customer) WITH KEY customer = ls_result-br_cus_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-br_cus_des = ls_customer-customername.
          ls_result-gp_ctp_cod = ls_customer-tradingpartner.

          IF ls_result-gp_ctp_cod IS INITIAL.
            ls_result-gp_ctp_cod = 'Z999'.
          ENDIF.

          CLEAR: ls_customer.
        ENDIF.

        READ TABLE lt_bptaxnumber INTO DATA(ls_bptaxnumber) WITH KEY businesspartner = ls_result-br_cus_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-credit_num = ls_bptaxnumber-bptaxlongnumber.
          CLEAR: ls_bptaxnumber.
        ENDIF.

      ELSEIF ls_result-br_sup_cod IS NOT INITIAL.
        ls_result-br_ctp_key = ls_result-br_sup_cod.
        READ TABLE lt_supplier INTO DATA(ls_supplier) WITH KEY supplier = ls_result-br_sup_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-br_sup_des = ls_supplier-suppliername.
          ls_result-gp_ctp_cod = ls_supplier-tradingpartner.

          IF ls_result-gp_ctp_cod IS INITIAL.
            ls_result-gp_ctp_cod = 'Z999'.
          ENDIF.

          CLEAR: ls_supplier.
        ENDIF.

        READ TABLE lt_bptaxnumber INTO ls_bptaxnumber WITH KEY businesspartner = ls_result-br_sup_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-credit_num = ls_bptaxnumber-bptaxlongnumber.
          CLEAR: ls_bptaxnumber.
        ENDIF.
      ENDIF.

      "集团统一客商编码描述
      IF ls_result-gp_ctp_cod IS NOT INITIAL.
        READ TABLE lt_globalcompany INTO DATA(ls_globalcompany) WITH KEY company = ls_result-gp_ctp_cod BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-gp_ctp_des = ls_globalcompany-companyname.
          CLEAR: ls_globalcompany.
        ENDIF.
      ENDIF.

      IF ls_data-financialaccounttype <> 'D' AND ls_data-financialaccounttype <> 'K'.
        IF ls_data-partnercompany IS NOT INITIAL.
          ls_result-gp_ctp_cod = ls_data-partnercompany.

          READ TABLE lt_partnercompany INTO DATA(ls_partnercompany) WITH KEY company = ls_result-gp_ctp_cod BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-gp_ctp_des = ls_partnercompany-companyname.
            CLEAR: ls_partnercompany.
          ENDIF.
        ENDIF.
      ENDIF.

      IF ls_result-br_acc_cod = '1002010301'.
        ls_result-br_ctp_key = 'G082'.
      ENDIF.

      IF ls_result-br_cus_cod IS INITIAL
         AND ls_result-br_sup_cod IS INITIAL
         AND ls_result-br_acc_cod <> '1002010301'.
        CLEAR: ls_result-gp_ctp_cod, ls_result-gp_ctp_des.
      ENDIF.

      ls_result-uuid = ls_result-zzyear && '-' && ls_result-zzmonth && '-' &&
                       ls_result-voucher  && '-' && ls_result-line && '-' &&
                       lv_companycode && '-' && lv_zzyear && '-' && lv_zzmonth.

      ls_result-dateupd = sy-datum && sy-uzeit.

      APPEND ls_result TO lt_result.

    ENDLOOP.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>) WHERE br_acc_cod = '1002010301'.
      READ TABLE lt_result TRANSPORTING NO FIELDS WITH KEY voucher = <fs_result>-voucher BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_result INTO ls_result FROM sy-tabix.
          IF ls_result-voucher = <fs_result>-voucher.
            IF ls_result-gp_ctp_cod IS NOT INITIAL.
              <fs_result>-gp_ctp_cod = ls_result-gp_ctp_cod.
              <fs_result>-gp_ctp_des = ls_result-gp_ctp_des.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    et_result = lt_result.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI003'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
