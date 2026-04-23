CLASS zzcl_query_mm005 DEFINITION
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



CLASS zzcl_query_mm005 IMPLEMENTATION.

  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_mm005,
          ls_result TYPE zc_query_mm005.
    DATA: r_documentdate TYPE RANGE OF i_materialdocumentitem_2-documentdate.
    DATA: r_bwart TYPE RANGE OF zc_query_mm005-goodsmovementtype.
    DATA: r_bukrs TYPE RANGE OF zc_query_mm005-companycode.
    DATA: r_plant TYPE RANGE OF zc_query_mm005-plant.
    DATA: r_matnr TYPE RANGE OF zc_query_mm005-material.
    DATA:lt_zztmm007     TYPE TABLE OF zztmm007,
         lt_zztmm007_tmp TYPE TABLE OF zztmm007,
         ls_zztmm007     TYPE zztmm007.


*   过滤器
    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).     "CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).  "ABAP range
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
              r_bukrs = CORRESPONDING #( ls_filter-range ).
            WHEN 'PLANT'.
              r_plant = CORRESPONDING #( ls_filter-range ).
            WHEN 'MATERIAL'.
              r_matnr = CORRESPONDING #( ls_filter-range ).
            WHEN 'GOODSMOVEMENTTYPE'.
              r_bwart = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.
      CATCH cx_root INTO DATA(lr_root).
        DATA(lv_msg) = lr_root->get_longtext( ).
    ENDTRY.



    SELECT SINGLE MAX( documentdate ) AS documentdate
      FROM zztmm007
      INTO @DATA(lv_max_date).
    APPEND VALUE #( low = lv_max_date high = sy-datum sign = 'I' option = 'BT' ) TO r_documentdate.

    "自建表新增数据
    SELECT *
      FROM i_materialdocumentitem_2 WITH PRIVILEGED ACCESS AS a
     WHERE a~documentdate IN @r_documentdate
       AND a~goodsmovementiscancelled = ''
       AND a~debitcreditcode = 'S'
       AND a~goodsmovementtype IN @r_bwart
      INTO TABLE @DATA(lt_add).
    IF lt_add IS NOT INITIAL.
      SELECT a~*
        FROM i_serialnumbermaterialdoc_2 WITH PRIVILEGED ACCESS AS a
        JOIN @lt_add AS b ON a~materialdocument = b~materialdocument
         AND a~materialdocumentitem = b~materialdocumentitem
         AND a~materialdocumentyear = b~materialdocumentyear
         INTO TABLE @DATA(lt_serial).
      SORT lt_serial BY materialdocument materialdocumentitem materialdocumentyear.

      LOOP AT lt_add INTO DATA(ls_add).
        CLEAR: ls_zztmm007.
        MOVE-CORRESPONDING ls_add TO ls_zztmm007.

        READ TABLE lt_serial INTO DATA(ls_serial) WITH KEY materialdocument = ls_add-materialdocument
        materialdocumentitem = ls_add-materialdocumentitem
        materialdocumentyear = ls_add-materialdocumentyear BINARY SEARCH.
        IF sy-subrc = 0.
          ls_zztmm007-serialnumber = ls_serial-serialnumber.
        ENDIF.
        APPEND ls_zztmm007 TO lt_zztmm007.
      ENDLOOP.

      MODIFY zztmm007 FROM TABLE @lt_zztmm007.
    ENDIF.

    "已冲销的数据
    SELECT a~*
      FROM zztmm007 AS a
      JOIN i_materialdocumentitem_2 AS b ON a~materialdocument = b~materialdocument
                                        AND a~materialdocumentitem = b~materialdocumentitem
                                        AND a~materialdocumentyear = b~materialdocumentyear
     WHERE b~goodsmovementiscancelled = 'X'
     INTO TABLE @DATA(lt_cancelled).
    IF sy-subrc = 0.
      LOOP AT lt_cancelled ASSIGNING FIELD-SYMBOL(<fs_zztmm007>).
        <fs_zztmm007>-goodsmovementiscancelled = 'X'.
      ENDLOOP.
      DELETE zztmm007 FROM TABLE @lt_cancelled.
    ENDIF.


    "获取库存
    SELECT a~product,
           a~plant,
           c~serialnumberprofile,
           SUM( a~matlwrhsstkqtyinmatlbaseunit ) AS stkqty
      FROM i_stockquantitycurrentvalue_2( p_displaycurrency = 'CNY' ) WITH PRIVILEGED ACCESS AS a
      JOIN i_productplantbasic AS c  ON a~product = c~product
                                  AND a~plant = c~plant
     WHERE a~product IN @r_matnr
       AND a~plant IN @r_plant
       AND a~valuationareatype = '1'
       AND a~matlwrhsstkqtyinmatlbaseunit > 0
     GROUP BY a~product,a~plant,c~serialnumberprofile
      INTO TABLE @DATA(lt_stock).
    SORT lt_stock BY product plant.
    DATA(lt_stock_tmp) = lt_stock.
    "获取价格
    SELECT a~product,
           b~plant,
           t1~productname AS productdescription_zh,
           t2~productname AS productdescription_en,
           m~productgroup,
           m~producttype,
           a~inventoryvaluationprocedure,
           a~movingaverageprice,
           a~standardprice,
           a~priceunitqty,
           CAST( 0 AS DEC( 13,6 ) ) AS price
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS AS a
      LEFT OUTER JOIN i_product AS m ON a~product = m~product
      LEFT OUTER JOIN i_producttext AS t1 ON a~product = t1~product AND t1~language = '1'
      LEFT OUTER JOIN i_producttext AS t2 ON a~product = t2~product AND t1~language = 'E'
      JOIN @lt_stock AS b ON a~product = b~product
                         AND a~valuationarea = b~plant
     INTO TABLE @DATA(lt_valuationbasic).
    SORT lt_valuationbasic BY product plant.
    LOOP AT lt_valuationbasic ASSIGNING FIELD-SYMBOL(<fs_valuationbasic>).
      CLEAR:  <fs_valuationbasic>-price .
      CASE <fs_valuationbasic>-inventoryvaluationprocedure.
        WHEN 'S'.
          <fs_valuationbasic>-price = <fs_valuationbasic>-standardprice / <fs_valuationbasic>-priceunitqty.
        WHEN 'V'.
          <fs_valuationbasic>-price = <fs_valuationbasic>-movingaverageprice / <fs_valuationbasic>-priceunitqty.
      ENDCASE.
    ENDLOOP.

    "获取自建表数据
    SELECT *
      FROM zztmm007 WITH PRIVILEGED ACCESS AS a
     WHERE a~material IN @r_matnr
       AND a~plant IN @r_plant
       AND a~companycode IN @r_bukrs
       AND a~goodsmovementiscancelled = ''
      INTO TABLE @lt_zztmm007.
    SORT lt_zztmm007 BY material plant postingdate DESCENDING materialdocument DESCENDING.

    SELECT c~*
      FROM i_serialnumberstocksegment WITH PRIVILEGED ACCESS AS a
      JOIN @lt_zztmm007 AS c ON a~serialnumber = c~serialnumber
                            AND a~material = c~material
     INTO TABLE @DATA(lt_stocksegment).
    SORT lt_stocksegment BY material plant.

    "有序列号库存
    LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<fs_stock>) WHERE serialnumberprofile = 'ZS01'.
      READ TABLE lt_stock_tmp INTO DATA(ls_stock_tmp) WITH KEY product = <fs_stock>-product
                                                                           plant = <fs_stock>-plant BINARY SEARCH.
      READ TABLE lt_valuationbasic INTO DATA(ls_valuationbasic) WITH KEY product = <fs_stock>-product
                                                                         plant = <fs_stock>-plant BINARY SEARCH.

      READ TABLE lt_stocksegment TRANSPORTING NO FIELDS WITH KEY material = <fs_stock>-product
                                                                 plant = <fs_stock>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_stocksegment INTO DATA(ls_stocksegment) FROM sy-tabix.
          IF ls_stocksegment-material = <fs_stock>-product
              AND ls_stocksegment-plant = <fs_stock>-plant.
            CLEAR: ls_result.
            MOVE-CORRESPONDING ls_stocksegment TO ls_result.
            MOVE-CORRESPONDING ls_valuationbasic TO ls_result.
            ls_result-totalstock = ls_stock_tmp-stkqty.
            ls_result-receivedate = ls_stocksegment-postingdate.
            ls_result-inventoryagedate = sy-datum -  ls_result-receivedate.
            ls_result-stockquantity = 1.


            IF  <fs_stock>-stkqty - ls_stocksegment-quantityinbaseunit <= 0.
              ls_result-stockquantity  = <fs_stock>-stkqty.
              <fs_stock>-stkqty  = 0.
            ELSE.
              ls_result-stockquantity  = ls_stocksegment-quantityinbaseunit.
              <fs_stock>-stkqty = <fs_stock>-stkqty - ls_stocksegment-quantityinbaseunit.
            ENDIF.

            ls_result-stockvalue = ls_result-stockquantity * ls_result-price.
            APPEND ls_stocksegment TO lt_zztmm007_tmp.
            APPEND ls_result TO lt_result.
            IF <fs_stock>-stkqty = 0.
              EXIT.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CLEAR: ls_valuationbasic.
    ENDLOOP.


    LOOP AT lt_stock ASSIGNING <fs_stock> WHERE stkqty <> 0.
      READ TABLE lt_stock_tmp INTO ls_stock_tmp WITH KEY product = <fs_stock>-product
                                                           plant = <fs_stock>-plant BINARY SEARCH.
      READ TABLE lt_valuationbasic INTO ls_valuationbasic WITH KEY product = <fs_stock>-product
                                                                   plant = <fs_stock>-plant BINARY SEARCH.
      READ TABLE lt_zztmm007 TRANSPORTING NO FIELDS WITH KEY material = <fs_stock>-product
                                                                plant = <fs_stock>-plant BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_zztmm007 INTO ls_zztmm007 FROM sy-tabix.
          IF ls_zztmm007-material = <fs_stock>-product
              AND ls_zztmm007-plant = <fs_stock>-plant.
            CLEAR: ls_result.
            MOVE-CORRESPONDING ls_zztmm007 TO ls_result.
            MOVE-CORRESPONDING ls_valuationbasic TO ls_result.
            ls_result-totalstock = ls_stock_tmp-stkqty.
            ls_result-receivedate = ls_zztmm007-postingdate.
            ls_result-inventoryagedate = sy-datum - ls_result-receivedate.

            IF  <fs_stock>-stkqty - ls_zztmm007-quantityinbaseunit <= 0.
              ls_result-stockquantity = <fs_stock>-stkqty.
              <fs_stock>-stkqty  = 0.
            ELSE.
              ls_result-stockquantity  = ls_zztmm007-quantityinbaseunit.
              <fs_stock>-stkqty = <fs_stock>-stkqty - ls_zztmm007-quantityinbaseunit.
            ENDIF.

            ls_result-stockvalue = ls_result-stockquantity * ls_result-price.
            APPEND ls_zztmm007 TO lt_zztmm007_tmp.

            APPEND ls_result TO lt_result.
            IF <fs_stock>-stkqty = 0.
              EXIT.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CLEAR: ls_valuationbasic.
    ENDLOOP.

    IF lt_zztmm007_tmp IS NOT INITIAL.
      SORT lt_zztmm007_tmp BY materialdocumentyear materialdocument materialdocumentitem.
      LOOP AT lt_zztmm007 INTO ls_zztmm007.
        DATA(lv_tabix) = sy-tabix.
        READ TABLE lt_zztmm007_tmp TRANSPORTING NO FIELDS WITH KEY materialdocumentyear = ls_zztmm007-materialdocumentyear
        materialdocument = ls_zztmm007-materialdocument
        materialdocumentitem = ls_zztmm007-materialdocumentitem BINARY SEARCH.
        IF sy-subrc = 0.
          DELETE lt_zztmm007 INDEX lv_tabix.
        ENDIF.
      ENDLOOP.

      DELETE zztmm007 FROM TABLE @lt_zztmm007.
    ENDIF.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      <fs_result>-uuid =  sy-tabix.
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
          WHEN 'ZC_QUERY_MM005'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
