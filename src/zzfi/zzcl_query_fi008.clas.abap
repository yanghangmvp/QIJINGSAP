CLASS zzcl_query_fi008 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_result TYPE TABLE OF zc_query_fi008.

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



CLASS ZZCL_QUERY_FI008 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi008.

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
    DATA: lt_result TYPE TABLE OF zc_query_fi008,
          ls_result TYPE zc_query_fi008.

    DATA: lv_flag TYPE zc_query_fi008-hasitbeenprocessed.

    DATA: lv_companycode TYPE zc_query_fi008-companycode,
          lv_year        TYPE zc_query_fi008-fiscalyear,
          lv_period      TYPE zc_query_fi008-fiscalperiod,
          lr_uuid        TYPE RANGE OF zc_query_fi008-uuid.


    "当期年度期间
    DATA: lv_fiscalyear   TYPE i_accountingdocumentjournal-fiscalyear,
          lv_fiscalperiod TYPE i_accountingdocumentjournal-fiscalperiod.

    DATA: lv_date(5) TYPE p.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'HASITBEENPROCESSED'.
          lv_flag = ls_filter-range[ 1 ]-low.
        WHEN 'COMPANYCODE'.
          lv_companycode = ls_filter-range[ 1 ]-low.
        WHEN 'FISCALYEAR'.
          lv_year = ls_filter-range[ 1 ]-low..
        WHEN 'FISCALPERIOD'.
          lv_period = ls_filter-range[ 1 ]-low.

      ENDCASE.
    ENDLOOP.

    "未处理，取标准表
    IF lv_flag = abap_false.
      SELECT *
        FROM zztfi013
       WHERE companycode = @lv_companycode
         AND fiscalyear = @lv_year
         AND fiscalperiod = @lv_period
        INTO TABLE @DATA(lt_zztfi013).
      IF sy-subrc = 0.
        RETURN.
      ENDIF.

      "获取当月时间范围
      SELECT SINGLE *
        FROM i_calendardate
       WHERE calendaryear = @lv_year
         AND calendarmonth = @lv_period
        INTO @DATA(ls_calendardate).
      "获取评估范围
      SELECT SINGLE *
        FROM i_jvavaluationarea
       WHERE companycode = @lv_companycode
        INTO @DATA(ls_valuationarea).

      SELECT a~deliverydocument,
             a~deliverydocumentitem,
             a~referencesddocument,
             a~referencesddocumentitem,
             c~soldtoparty,
             d~customername,
             a~plant,
             a~material,
             a~actualdeliveryquantity,
             b~orderquantity,
             a~deliveryquantityunit,
             b~netamount,
             b~taxamount,
             b~transactioncurrency,
             a~proofofdeliverystatus,
             a~deliveryrelatedbillingstatus,
             a~deliverydocumentitemtext,
             e~accountdetnproductgroup,
             a~creationdate
        FROM i_deliverydocumentitem AS a
        LEFT OUTER JOIN i_salesorderitem AS b ON a~referencesddocument = b~salesorder
                                             AND a~referencesddocumentitem = b~salesorderitem
        LEFT OUTER JOIN i_salesorder AS c ON b~salesorder = c~salesorder
        LEFT OUTER JOIN i_customer AS d ON c~soldtoparty = d~customer
        LEFT OUTER JOIN i_productsalesdelivery AS e ON a~material = e~product
                                                   AND c~salesorganization = e~productsalesorg
                                                   AND e~productdistributionchnl = '00'
       WHERE a~plant = @ls_valuationarea-valuationarea
         AND a~creationdate <= @ls_calendardate-lastdayofmonthdate
         AND a~creationdate >= @ls_calendardate-firstdayofmonthdate
         AND a~proofofdeliverystatus = 'C'
         AND a~deliveryrelatedbillingstatus = 'A'
        INTO TABLE @DATA(lt_documentitem).
      IF sy-subrc = 0.
        LOOP AT lt_documentitem INTO DATA(ls_documentitem).
          CLEAR: ls_result.
          MOVE-CORRESPONDING ls_documentitem TO ls_result.
          ls_result-companycode = lv_companycode.
          ls_result-fiscalyear = lv_year.
          ls_result-fiscalperiod = lv_period.
          ls_result-totalsalesamount = ls_result-netamount + ls_result-taxamount.
          ls_result-estimatedrevenue = ls_result-netamount / ls_result-orderquantity * ls_result-actualdeliveryquantity.
          ls_result-estimatedtaxamount = ls_result-taxamount / ls_result-orderquantity * ls_result-actualdeliveryquantity.
          ls_result-estimatedtotalamount = ls_result-estimatedrevenue + ls_result-estimatedtaxamount.
          APPEND ls_result TO lt_result.

        ENDLOOP.
      ENDIF.

    ELSE.
      SELECT *
           FROM zztfi013
          WHERE companycode = @lv_companycode
            AND fiscalyear = @lv_year
            AND fiscalperiod = @lv_period
           INTO TABLE @lt_zztfi013.
      MOVE-CORRESPONDING lt_zztfi013 TO lt_result.
    ENDIF.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
      <fs_result>-uuid =  lv_companycode && lv_year && lv_period && <fs_result>-deliverydocument && <fs_result>-deliverydocumentitem .
      <fs_result>-hasitbeenprocessed = lv_flag.
    ENDLOOP.

    et_result =  lt_result.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI008'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
