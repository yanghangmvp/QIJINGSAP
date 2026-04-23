CLASS zzcl_query_fi002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_fi002.

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



CLASS ZZCL_QUERY_FI002 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_fi002,
          ls_result TYPE zc_query_fi002.

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
    DATA: lt_result TYPE TABLE OF zc_query_fi002,
          ls_result TYPE zc_query_fi002.

    DATA: lr_companycode  TYPE RANGE OF zc_query_fi002-companycode,
          lr_creationdate TYPE RANGE OF zc_query_fi002-creationdate,
          lr_uuid         TYPE RANGE OF zc_query_fi002-uuid.

    DATA: lv_companycode(35)  TYPE c,
          lv_creationdate(35) TYPE c.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'COMPANYCODE'.
          lr_companycode = CORRESPONDING #( ls_filter-range ).
        WHEN 'CREATIONDATE'.
          lr_creationdate = CORRESPONDING #( ls_filter-range ).
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).

          SPLIT lr_uuid[ 1 ]  AT '-' INTO TABLE DATA(lt_range).
          READ TABLE lt_range INTO DATA(ls_range) INDEX 3.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            APPEND VALUE #( sign = ls_range(1)
                            option = ls_range+1(2)
                            low = ls_range+3(4)
                       ) TO lr_companycode.
          ENDIF.

          READ TABLE lt_range INTO ls_range INDEX 4.
          IF sy-subrc = 0 AND ls_range IS NOT INITIAL.
            APPEND VALUE #( sign = ls_range(1)
                            option = ls_range+1(2)
                            low = ls_range+3(8)
                            high = ls_range+11(8)
                       ) TO lr_creationdate.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    READ TABLE lr_companycode INTO DATA(lrs_companycode) INDEX 1.
    IF sy-subrc = 0.
      lv_companycode = lrs_companycode.
    ENDIF.

    READ TABLE lr_creationdate INTO DATA(lrs_creationdate) INDEX 1.
    IF sy-subrc = 0.
      lv_creationdate = lrs_creationdate.
    ENDIF.

    SELECT a~customer,
           a~customername,
           a~vatregistration,
           a~country,
           a~cityname,
           b~companycode,
           a~creationdate
      FROM i_customer AS a
      JOIN i_customercompany AS b ON a~customer = b~customer
     WHERE b~companycode IN @lr_companycode
       AND a~creationdate IN @lr_creationdate
      INTO TABLE @DATA(lt_customer).
    SORT lt_customer BY customer.

    SELECT a~supplier,
           a~suppliername,
           a~vatregistration,
           a~country,
           a~cityname,
           b~companycode,
           a~creationdate
      FROM i_supplier AS a
      JOIN i_suppliercompany AS b ON a~supplier = b~supplier
     WHERE b~companycode IN @lr_companycode
       AND a~creationdate IN @lr_creationdate
      INTO TABLE @DATA(lt_supplier).
    SORT lt_supplier BY supplier.

    IF lt_customer IS NOT INITIAL.
      "统一社会信用代码
      SELECT a~businesspartner,
             a~bptaxlongnumber
        FROM i_businesspartnertaxnumber AS a
        JOIN @lt_customer AS b ON a~businesspartner = b~customer
        INTO TABLE @DATA(lt_bptaxnumber).
    ENDIF.

    IF lt_supplier IS NOT INITIAL.
      SELECT a~businesspartner,
             a~bptaxlongnumber
        FROM i_businesspartnertaxnumber AS a
        JOIN @lt_supplier AS b ON a~businesspartner = b~supplier
        APPENDING TABLE @lt_bptaxnumber.
    ENDIF.
    SORT lt_bptaxnumber BY businesspartner.

    LOOP AT lt_customer INTO DATA(ls_customer).
      CLEAR: ls_result.
      ls_result-type = 'C'.
      ls_result-br_ctp_key = ls_customer-customer.
      ls_result-br_ctp_cod = ls_customer-customer.
      ls_result-br_ctp_des = ls_customer-customername.
      ls_result-country = ls_customer-country.
      ls_result-city = ls_customer-cityname.
      ls_result-sys_id = '启境SAP S4HC'.
      ls_result-companycode = ls_customer-companycode.
      ls_result-creationdate = ls_customer-creationdate.

      "统一社会信用代码
      READ TABLE lt_bptaxnumber INTO DATA(ls_bptaxnumber) WITH KEY businesspartner = ls_result-br_ctp_key BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-credit_num = ls_bptaxnumber-bptaxlongnumber.
        CLEAR: ls_bptaxnumber.
      ENDIF.

      ls_result-uuid = ls_result-type && '-' && ls_result-br_ctp_key && '-' && lv_companycode && '-' && lv_creationdate.
      ls_result-dateupd = sy-datum && sy-uzeit.

      APPEND ls_result TO lt_result.
    ENDLOOP.

    LOOP AT lt_supplier INTO DATA(ls_supplier).
      CLEAR: ls_result.
      ls_result-type = 'S'.
      ls_result-br_ctp_key = ls_supplier-supplier.
      ls_result-br_ctp_cod = ls_supplier-supplier.
      ls_result-br_ctp_des = ls_supplier-suppliername.
      ls_result-country = ls_supplier-country.
      ls_result-city = ls_supplier-cityname.
      ls_result-sys_id = '启境SAP S4HC'.
      ls_result-companycode = ls_supplier-companycode.
      ls_result-creationdate = ls_supplier-creationdate.

      "统一社会信用代码
      READ TABLE lt_bptaxnumber INTO ls_bptaxnumber WITH KEY businesspartner = ls_result-br_ctp_key BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-credit_num = ls_bptaxnumber-bptaxlongnumber.
        CLEAR: ls_bptaxnumber.
      ENDIF.

      ls_result-uuid = ls_result-type && '-' && ls_result-br_ctp_key && '-' && lv_companycode && '-' && lv_creationdate.
      ls_result-dateupd = sy-datum && sy-uzeit.

      APPEND ls_result TO lt_result.
    ENDLOOP.

    et_result = lt_result.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_FI002'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
        RETURN.
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
        RETURN.
      CATCH cx_sy_open_sql_db.
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
