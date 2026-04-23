CLASS zzcl_query_mm001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_mm001.
    TYPES:tt_bank TYPE TABLE OF i_businesspartnerbank.

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
        et_bank    TYPE  tt_bank .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_MM001 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_mm001,
          ls_result TYPE zc_query_mm001.

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

    DATA: lt_result TYPE TABLE OF zc_query_mm001,
          ls_result TYPE zc_query_mm001.

    DATA: lr_supplier     TYPE RANGE OF zc_query_mm001-supplier.
    DATA: lr_timst    TYPE RANGE OF zc_query_mm001-lastchangedatetime.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'SUPPLIER'.
          lr_supplier = CORRESPONDING #( ls_filter-range ).
        WHEN 'LASTCHANGEDATETIME'.
          lr_timst = CORRESPONDING #( ls_filter-range ).
      ENDCASE.
    ENDLOOP.


    SELECT c~supplier,
           c~suppliername,
           a~businesspartnercategory,
           a~businesspartnergrouping,
           h~businesspartnergroupingtext,
           c~supplieraccountgroup,
           c~addresssearchterm1,
           c~country,
           c~region,
           i~regionname,
           c~streetname,
           c~postalcode,
           c~cityname,
           c~supplierlanguage,
           c~phonenumber1,
           c~phonenumber2,
           c~faxnumber,

           b~lastchangedatetime
      FROM i_businesspartner WITH PRIVILEGED ACCESS AS a
      JOIN zc_bp_timst WITH PRIVILEGED ACCESS AS b ON a~businesspartner = b~businesspartner
      JOIN i_supplier WITH PRIVILEGED ACCESS AS c ON a~businesspartner = c~supplier
      LEFT OUTER JOIN i_businesspartnergroupingtext WITH PRIVILEGED ACCESS AS h ON h~businesspartnergrouping = a~businesspartnergrouping
                                                                               AND h~language = 1
      LEFT OUTER JOIN i_regiontext WITH PRIVILEGED ACCESS AS i ON i~country = c~country
                                                              AND i~region = c~region
                                                              AND i~language = 1

     WHERE a~businesspartner  IN @lr_supplier
       AND b~lastchangedatetime IN @lr_timst
      INTO TABLE @DATA(lt_main).
    "默认地址编号
    SELECT a~businesspartner,
           a~addressnumber
      FROM i_businesspartneraddressusage WITH PRIVILEGED ACCESS AS a
      JOIN @lt_main AS b ON a~businesspartner = b~supplier
     WHERE addressusage = 'XXDEFAULT'
      INTO TABLE @DATA(lt_usage).
    SORT lt_usage BY businesspartner.
    "地址
    SELECT a~businesspartner,
           a~floor
      FROM i_businesspartneraddresstp_3 WITH PRIVILEGED ACCESS AS a
      JOIN @lt_main AS b ON a~businesspartner = b~supplier
      INTO TABLE @DATA(lt_address).

    "邮箱
    SELECT a~*
      FROM i_addressemailaddress_2 WITH PRIVILEGED ACCESS AS a
      JOIN @lt_usage AS b ON a~addressid = b~addressnumber
      INTO TABLE @DATA(lt_email).
    SORT lt_email BY addressid.
    "税号
    SELECT a~*
      FROM i_businesspartnertaxnumber WITH PRIVILEGED ACCESS AS a
      JOIN @lt_main AS b ON a~businesspartner = b~supplier
      INTO TABLE @DATA(lt_tax).
    SORT lt_tax BY businesspartner.

    "银行
    SELECT a~*
      FROM i_businesspartnerbank WITH PRIVILEGED ACCESS AS a
      JOIN @lt_main AS b ON a~businesspartner = b~supplier
      INTO TABLE @DATA(lt_bank).
    SORT lt_bank BY businesspartner.

    "采购组织
    SELECT a~supplier,
           a~purchasingorganization,
           a~purchaseordercurrency
      FROM i_supplierpurchasingorg WITH PRIVILEGED ACCESS AS a
      JOIN @lt_main AS b ON a~supplier = b~supplier
      INTO TABLE @DATA(lt_purchasingorg).
    SORT lt_purchasingorg BY supplier.

    LOOP AT lt_main INTO DATA(ls_main).
      CLEAR: ls_result.
      MOVE-CORRESPONDING ls_main TO ls_result.

      READ TABLE lt_usage INTO DATA(ls_usage) WITH KEY businesspartner = ls_main-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_email INTO DATA(ls_email) WITH KEY addressid =   ls_usage-addressnumber BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-emailaddress = ls_email-emailaddress.
        ENDIF.
      ENDIF.

      "税号
      READ TABLE lt_tax INTO DATA(ls_tax) WITH KEY businesspartner = ls_main-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-taxnumbertype = ls_tax-bptaxtype.
        ls_result-taxnumberresponsible = ls_tax-bptaxlongnumber.
      ENDIF.

      READ TABLE lt_purchasingorg INTO DATA(ls_purchasingorg) WITH KEY supplier = ls_main-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-purchaseordercurrency = ls_purchasingorg-purchaseordercurrency.
      ELSE.
        ls_result-purchaseordercurrency = 'CNY'.
      ENDIF.

      "银行
      READ TABLE lt_bank INTO DATA(ls_bank) WITH KEY businesspartner = ls_main-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-bankidentification      = ls_bank-bankidentification.
        ls_result-bankcountrykey          = ls_bank-bankcountrykey.
        ls_result-banknumber              = ls_bank-banknumber.
        ls_result-bankname                = ls_bank-bankname.
        ls_result-bankaccountholdername   = ls_bank-bankaccountholdername.
        ls_result-bankaccount             = ls_bank-bankaccount.
        ls_result-bankaccountreferencetext      = ls_bank-bankaccountreferencetext.
        ls_result-bankaccountfull         = ls_bank-bankaccount && ls_bank-bankaccountreferencetext.
      ENDIF.



      APPEND ls_result TO lt_result.
    ENDLOOP.

    et_result = lt_result.
    et_bank = lt_bank.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_MM001'.
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
