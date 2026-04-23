CLASS zzcl_query_fi011 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_result TYPE TABLE OF zc_query_fi011.

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
        et_result  TYPE  tt_result
        et_flag    TYPE c.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_query_fi011 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi011.

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
    DATA: lt_result TYPE TABLE OF zc_query_fi011,
          ls_result TYPE zc_query_fi011.

    DATA: lv_flag TYPE zc_query_fi011-zsfyft.

    DATA: lv_plant  TYPE zc_query_fi011-werks,
          lv_year   TYPE zc_query_fi011-gjahr,
          lv_period TYPE zc_query_fi011-monat,
          lr_uuid   TYPE RANGE OF zc_query_fi011-uuid.

    DATA: lv_dmbtr4 TYPE p LENGTH 13 DECIMALS 2.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'ZSFYFT'.
          lv_flag = ls_filter-range[ 1 ]-low.
        WHEN 'WERKS'.
          lv_plant = ls_filter-range[ 1 ]-low.
        WHEN 'GJAHR'.
          lv_year = ls_filter-range[ 1 ]-low..
        WHEN 'MONAT'.
          lv_period = ls_filter-range[ 1 ]-low.

      ENDCASE.
    ENDLOOP.

    IF lv_flag = abap_false.
      SELECT *
        FROM zztfi015
       WHERE werks = @lv_plant
         AND gjahr = @lv_year
         AND monat = @lv_period
        INTO TABLE @DATA(lt_zztfi015).
      IF sy-subrc = 0.
        RETURN.
      ENDIF.

      SELECT c~plant,
             d~product,
             b~companycode,
             b~fiscalyear,
             b~fiscalperiod,
             b~glaccount,
             b~debitamountincocodecrcy,
             b~creditamountincocodecrcy,
             c~debitcreditcode,
             d~yy1_partver_prd,
             c~quantityinbaseunit,
             c~totalgoodsmvtamtincccrcy,
             b~companycodecurrency,
             c~materialbaseunit,
             c~goodsmovementtype
        FROM i_jvavaluationarea AS a
        JOIN i_accountingdocumentjournal( p_language = '1' ) AS b ON a~companycode = b~companycode
        LEFT JOIN i_materialdocumentitem_2 AS c ON a~valuationarea = c~plant
                                               AND b~fiscalyear = c~materialdocumentyear
                                               AND b~fiscalperiod = substring( c~fiscalyearperiod, 5, 3 )
                                               AND c~goodsmovementrefdoctype = 'B'
                                               AND c~goodsmovementtype IN ( '101', '102' )
        JOIN i_product AS d ON c~material = d~product
                           AND d~producttype = 'Z001'
       WHERE a~valuationarea = @lv_plant
         AND b~fiscalyear = @lv_year
         AND b~fiscalperiod = @lv_period
         AND b~ledger = '0L'
         AND b~glaccount = '1408010000'
         AND b~assignmentreference = '制费成本结转'
        INTO TABLE @DATA(lt_accounting).
      SORT lt_accounting BY plant product.

      IF lt_accounting IS NOT INITIAL.
        "科目名称
        SELECT glaccount,
               glaccountname
          FROM i_glaccounttext
           FOR ALL ENTRIES IN @lt_accounting
         WHERE glaccount = @lt_accounting-glaccount
           AND chartofaccounts = 'YCOA'
           AND language = '1'
          INTO TABLE @DATA(lt_glaccounttext).
        SORT lt_glaccounttext BY glaccount.

        SELECT
          SUM( CASE a~debitcreditcode
               WHEN 'H' THEN 0 - a~totalgoodsmvtamtincccrcy
               WHEN 'S' THEN a~totalgoodsmvtamtincccrcy END )
            AS totalgoodsmvtamtincccrcy
          FROM @lt_accounting AS a
          INTO @DATA(lv_totalgoodsmvtamtincccrcy).
      ENDIF.

      CLEAR: lv_dmbtr4.

      LOOP AT lt_accounting INTO DATA(ls_accounting).
        DATA(ls_temp) = ls_accounting.

        ls_result-dmbtr = ls_temp-debitamountincocodecrcy + ls_temp-creditamountincocodecrcy.

        IF ls_result-dmbtr = 0.
          CONTINUE.
        ENDIF.

        IF ls_temp-debitcreditcode = 'H'.
          ls_result-menge = ls_result-menge - ls_temp-quantityinbaseunit.
          ls_result-dmbtr2 = ls_result-dmbtr2 - ls_temp-totalgoodsmvtamtincccrcy.
        ELSE.
          ls_result-menge = ls_result-menge + ls_temp-quantityinbaseunit.
          ls_result-dmbtr2 = ls_result-dmbtr2 + ls_temp-totalgoodsmvtamtincccrcy.
        ENDIF.

        AT END OF product.
          ls_result-zsfyft = lv_flag.
          ls_result-bukrs = ls_temp-companycode.
          ls_result-gjahr = ls_temp-fiscalyear.
          ls_result-monat = ls_temp-fiscalperiod+1(2).
          ls_result-hkont = ls_temp-glaccount.
          ls_result-werks = ls_temp-plant.
          ls_result-matnr = ls_temp-product.
          ls_result-maktx = ls_temp-yy1_partver_prd.
          ls_result-dmbtr3 = lv_totalgoodsmvtamtincccrcy.

          ls_result-zftxs = ls_result-dmbtr2 / ls_result-dmbtr3.

          ls_result-dmbtr4 = ls_result-dmbtr * ls_result-zftxs.

          lv_dmbtr4 = lv_dmbtr4 + ls_result-dmbtr4.

          ls_result-hwaer = ls_temp-companycodecurrency.
          ls_result-meins = ls_temp-materialbaseunit.

          "科目名称
          READ TABLE lt_glaccounttext INTO DATA(ls_glaccounttext) WITH KEY glaccount = ls_result-hkont BINARY SEARCH.
          IF sy-subrc = 0.
            ls_result-txt50 = ls_glaccounttext-glaccountname.
            CLEAR: ls_glaccounttext.
          ENDIF.

          ls_result-uuid = lv_plant && lv_year && lv_period && ls_result-matnr.

          AT LAST.
            ls_result-dmbtr4 = ls_result-dmbtr - ( lv_dmbtr4 - ls_result-dmbtr4 ).
          ENDAT.

          APPEND ls_result TO lt_result.
          CLEAR: ls_result.

        ENDAT.
      ENDLOOP.

    ELSE.
      SELECT *
        FROM zztfi015
       WHERE werks = @lv_plant
         AND gjahr = @lv_year
         AND monat = @lv_period
        INTO TABLE @lt_zztfi015.
      SORT lt_zztfi015 BY matnr.
      MOVE-CORRESPONDING lt_zztfi015 TO lt_result.

      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
        <fs_result>-uuid = lv_plant && lv_year && lv_period && <fs_result>-matnr.
        <fs_result>-zsfyft = lv_flag.
      ENDLOOP.
    ENDIF.

    et_result =  lt_result.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI011'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
