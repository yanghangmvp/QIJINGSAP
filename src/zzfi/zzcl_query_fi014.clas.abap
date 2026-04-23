CLASS zzcl_query_fi014 DEFINITION
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



CLASS zzcl_query_fi014 IMPLEMENTATION.

  METHOD get_data.

    DATA: lt_result     TYPE TABLE OF zc_query_fi014,
          lt_result_tmp TYPE TABLE OF zc_query_fi014,
          ls_result     TYPE zc_query_fi014,
          ls_result_tmp TYPE zc_query_fi014.

    DATA:lv_bukrs TYPE zc_query_fi014-companycode .
*    DATA:lv_zndqj TYPE zc_query_fi014-during .
    DATA:lv_gjahr TYPE gjahr,
         lv_monat TYPE monat.

    DATA:lv_uuid TYPE i .

    DATA: lr_matnr TYPE RANGE OF zc_query_fi014-material.
    DATA: lr_kunnr TYPE RANGE OF zc_query_fi014-customer.

    DATA:lv_first_day TYPE sy-datum .
    DATA:lv_last_day TYPE sy-datum .


    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
              lv_bukrs = ls_filter-range[ 1 ]-low.
            WHEN 'GJAHR'.
              lv_gjahr = ls_filter-range[ 1 ]-low.
            WHEN 'MONAT'.
              lv_monat = ls_filter-range[ 1 ]-low.
            WHEN 'MATERIAL'.
              lr_matnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'CUSTOMER'.
              lr_kunnr = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.
      CATCH cx_root INTO DATA(lr_root).
        DATA(lv_msg) = lr_root->get_longtext( ).
    ENDTRY.

    lv_first_day = lv_gjahr && lv_monat && '01'.
    lv_first_day = lv_first_day + 32.             " 跳到下个月
    lv_first_day+6(2) = '01'.                " 下个月第一天
    lv_last_day = lv_first_day - 1.              " 当月最后一天

    SELECT companycode ,
           customer ,
           product AS material ,
           yy1_zz005_jei ,
           SUM( quantity ) AS quantity ,
           baseunit
      FROM i_journalentryitem WITH PRIVILEGED ACCESS AS a
     WHERE ledger = '0L'
       AND companycode = @lv_bukrs
       AND fiscalyear  = @lv_gjahr
       AND fiscalperiod = @lv_monat
       AND product IS NOT NULL
       AND glaccount BETWEEN '6001000000' AND '6001999999'
       GROUP BY companycode , customer , product , baseunit , yy1_zz005_jei
      INTO TABLE @DATA(lt_data) .

    SORT lt_data BY companycode customer material .

*收入金额（本币）
    SELECT companycode ,
           customer ,
           product AS material ,
           yy1_zz005_jei ,
           SUM( amountincompanycodecurrency ) AS amount
      FROM i_journalentryitem WITH PRIVILEGED ACCESS AS a
     WHERE ledger = '0L'
       AND companycode = @lv_bukrs
       AND fiscalyear  = @lv_gjahr
       AND fiscalperiod = @lv_monat
       AND product IS NOT NULL
       AND glaccount BETWEEN '6001000000' AND '6001999999'
       GROUP BY companycode , customer , product , yy1_zz005_jei
      INTO TABLE @DATA(lt_data_sr) .

    SORT lt_data_sr BY companycode customer material .

*成本金额（本币）
    SELECT companycode ,
           customer ,
           product AS material ,
           yy1_zz005_jei ,
           SUM( amountincompanycodecurrency ) AS amount
      FROM i_journalentryitem WITH PRIVILEGED ACCESS AS a
     WHERE ledger = '0L'
       AND companycode = @lv_bukrs
       AND fiscalyear  = @lv_gjahr
       AND fiscalperiod = @lv_monat
       AND product IS NOT NULL
       AND glaccount BETWEEN '6401000000' AND '6401999999'
       GROUP BY companycode , customer , product ,yy1_zz005_jei
      INTO TABLE @DATA(lt_data_cb) .

    SORT lt_data_cb BY companycode customer material .

    IF lt_data IS NOT INITIAL .

* 公司代码描述
      SELECT companycode ,
             companycodename
        FROM i_companycode WITH PRIVILEGED ACCESS AS a
         FOR ALL ENTRIES IN @lt_data
       WHERE companycode = @lt_data-companycode
        INTO TABLE @DATA(lt_companycodename) .

      SORT lt_companycodename BY companycode .

* 客户描述
      SELECT customer ,
             customername
        FROM i_customer WITH PRIVILEGED ACCESS AS a
         FOR ALL ENTRIES IN @lt_data
        WHERE customer = @lt_data-customer
         INTO TABLE @DATA(lt_customername) .

      SORT lt_customername BY customer .

* 物料描述
      SELECT product AS material,
             productdescription
         FROM i_productdescription
          FOR ALL ENTRIES IN @lt_data
        WHERE product = @lt_data-material
          AND language = @sy-langu
         INTO TABLE @DATA(lt_materialname) .

      SORT lt_materialname BY material .

*单位名称
      SELECT unitofmeasure AS baseunit ,
             unitofmeasurename
        FROM i_unitofmeasuretext
         FOR ALL ENTRIES IN @lt_data
       WHERE unitofmeasure = @lt_data-baseunit
         AND language = '1'
        INTO TABLE @DATA(lt_baseunitname) .

      SORT lt_baseunitname BY baseunit .


      SELECT SINGLE valuationarea
               FROM i_valuationarea
              WHERE companycode = @lv_bukrs
               INTO @DATA(lv_pgfw) .

      SELECT costestimate ,
             ledger,
             currencyrole,
             material ,
             standardprice ,
             materialpriceunitqty
        FROM i_inventorypricebykeydate_2( p_calendardate = @lv_last_day )
         FOR ALL ENTRIES IN @lt_data
       WHERE ledger = '0L'
         AND currencyrole = '10'
         AND valuationarea = @lv_pgfw
         AND inventoryspecialstocktype = ''
         AND materialpriceunitqty IS NOT NULL
         AND material = @lt_data-material
        INTO TABLE @DATA(lt_dtbzcb) .

* 单台标准成本
*      SELECT product AS material,
*             standardprice ,
*             taxbasedpricespriceunitqty
*        FROM i_productvaluationbasic
*        FOR ALL ENTRIES IN @lt_data
*      WHERE product = @lt_data-material
*        AND fiscalmonthcurrentperiod = @lv_zndqj+4(2)
*        AND fiscalyearcurrentperiod = @lv_zndqj+0(4)
*       INTO TABLE @DATA(lt_dtbzcb) .

      SORT lt_dtbzcb BY material .

      CLEAR lv_uuid .
      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) .
        lv_uuid = lv_uuid + 1 .
        ls_result-uuid = lv_uuid .
        ls_result-companycode = <lfs_data>-companycode .
*        ls_result-during = lv_zndqj .
        ls_result-gjahr = lv_gjahr .
        ls_result-monat = lv_monat .
        ls_result-customer = <lfs_data>-customer .
        ls_result-material = <lfs_data>-material .
*销量
        ls_result-quantity = <lfs_data>-quantity * -1 .
        ls_result-baseunit = <lfs_data>-baseunit .

*公司代码描述
        READ TABLE lt_companycodename INTO DATA(ls_companycodename) WITH KEY companycode = <lfs_data>-companycode BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-companycodename = ls_companycodename-companycodename .
        ENDIF .

*客户描述
        READ TABLE lt_customername INTO DATA(ls_customername) WITH KEY customer = <lfs_data>-customer BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-customername = ls_customername-customername .
        ENDIF .

*物料描述
        READ TABLE lt_materialname INTO DATA(ls_materialname) WITH KEY material = <lfs_data>-material BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-productdescription = ls_materialname-productdescription .
        ENDIF .

*单位描述
        READ TABLE lt_baseunitname INTO DATA(ls_baseunitname) WITH KEY baseunit = <lfs_data>-baseunit BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-unitofmeasurename = ls_baseunitname-unitofmeasurename .
        ENDIF .

*单台标准成本
        READ TABLE lt_dtbzcb INTO DATA(ls_dtbzcb) WITH KEY material = <lfs_data>-material BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-zdtbzcb = ls_dtbzcb-standardprice / ls_dtbzcb-materialpriceunitqty .
        ENDIF .

*收入金额（本币）
        READ TABLE lt_data_sr INTO DATA(ls_data_sr) WITH KEY companycode = <lfs_data>-companycode
                                                             customer    = <lfs_data>-customer
                                                             material    = <lfs_data>-material BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-zsrje_b = ls_data_sr-amount * -1 .
        ENDIF .

*成本金额（本币）
        READ TABLE lt_data_cb INTO DATA(ls_data_cb) WITH KEY companycode = <lfs_data>-companycode
                                                             customer    = <lfs_data>-customer
                                                             material    = <lfs_data>-material BINARY SEARCH .
        IF sy-subrc = 0 .
          ls_result-zcbje_b = ls_data_cb-amount .
        ENDIF .

        IF ls_result-quantity IS NOT INITIAL .
*销售单价
          ls_result-zxsdj = ls_result-zsrje_b / ls_result-quantity .
*单台实际成本
          ls_result-zdtsjcb = ls_result-zcbje_b / ls_result-quantity .
*单台毛利
          ls_result-zdtml = ( ls_result-zsrje_b - ls_result-zcbje_b ) / ls_result-quantity .
*毛利
        ENDIF .
        ls_result-zmaoli = ls_result-zsrje_b - ls_result-zcbje_b .
*毛利率
        IF ls_result-zsrje_b IS NOT INITIAL .
          ls_result-zmaolilv = ( ls_result-zmaoli / ls_result-zsrje_b ) * 100 .
        ENDIF .

        APPEND ls_result TO lt_result .

        CLEAR ls_result .

      ENDLOOP.





    ENDIF .

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
          WHEN 'ZC_QUERY_FI014'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
