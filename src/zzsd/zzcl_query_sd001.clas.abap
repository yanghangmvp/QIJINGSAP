CLASS zzcl_query_sd001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_sd001.
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
        et_result  TYPE  tt_result.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_SD001 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_sd001,
          ls_result TYPE zc_query_sd001.

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
    DATA: lt_result TYPE TABLE OF zc_query_sd001,
          ls_result TYPE zc_query_sd001.

    DATA: lr_customer     TYPE RANGE OF zc_query_sd001-customer.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'CUSTOMER'.
          lr_customer = CORRESPONDING #( ls_filter-range ).
      ENDCASE.
    ENDLOOP.

    SELECT a~businesspartner,
           a~businesspartnername,
           a~businesspartnercategory,
           a~businesspartnergrouping,
           a~formofaddress,
           b~lastchangedatetime,
           c~streetname,
           c~postalcode,
           c~cityname,
           c~language,
           c~telephonenumber1,
           c~telephonenumber2,
           c~faxnumber,
           c~customeraccountgroup,
           c~addresssearchterm1,
           c~country,
           c~region,
           h~businesspartnergroupingtext,
           i~regionname
      FROM i_businesspartner WITH PRIVILEGED ACCESS AS a
      JOIN zc_bp_timst WITH PRIVILEGED ACCESS AS b ON a~businesspartner = b~businesspartner
      JOIN i_customer WITH PRIVILEGED ACCESS AS c ON a~businesspartner = c~customer
      LEFT OUTER JOIN i_businesspartnergroupingtext WITH PRIVILEGED ACCESS AS h ON h~businesspartnergrouping = a~businesspartnergrouping
                                                                               AND h~language = 1
      LEFT OUTER JOIN i_regiontext WITH PRIVILEGED ACCESS AS i ON i~country = c~country
                                                              AND i~region = c~region
                                                              AND i~language = 1

     WHERE a~businesspartner IN @lr_customer
      INTO TABLE @DATA(lt_data).

    IF lt_data IS NOT INITIAL.
      "DUNS编号
      SELECT a~businesspartner,
             a~bpidentificationnumber
        FROM i_bupaidentification WITH PRIVILEGED ACCESS AS a
        JOIN @lt_data AS b ON a~businesspartner = b~businesspartner
       WHERE a~bpidentificationtype = 'BUP001'
        INTO TABLE @DATA(lt_bupaidentification).
      SORT lt_bupaidentification BY businesspartner.

      "地址
      SELECT a~businesspartner,
             a~floor
        FROM i_businesspartneraddresstp_3 WITH PRIVILEGED ACCESS AS a
        JOIN @lt_data AS b ON a~businesspartner = b~businesspartner
        INTO TABLE @DATA(lt_address).
      SORT lt_address BY businesspartner.

      "销售组织
      SELECT a~customer,
             a~salesorganization,
             a~currency
        FROM i_customersalesarea WITH PRIVILEGED ACCESS AS a
        JOIN @lt_data AS b ON a~customer = b~businesspartner
        INTO TABLE @DATA(lt_salesarea).
      SORT lt_salesarea BY customer.

      "电子邮箱
      SELECT a~businesspartner,
             a~emailaddress
        FROM i_buspartemailaddresstp_3 WITH PRIVILEGED ACCESS AS a
        JOIN @lt_data AS b ON a~businesspartner = b~businesspartner
        INTO TABLE @DATA(lt_emailaddress).
      SORT lt_emailaddress BY businesspartner.

      "统一社会信用代码
      SELECT a~*
        FROM i_businesspartnertaxnumber WITH PRIVILEGED ACCESS AS a
        JOIN @lt_data AS b ON a~businesspartner = b~businesspartner
       WHERE a~bptaxtype = 'CN5'
        INTO TABLE @DATA(lt_tax).
      SORT lt_tax BY businesspartner.

      "主店代码
      SELECT a~*
        FROM i_custsalespartnerfunc WITH PRIVILEGED ACCESS AS a
         JOIN @lt_data AS b ON a~customer = b~businesspartner
        WHERE a~partnerfunction = 'WE'
        INTO TABLE @DATA(lt_custsalespartnerfunc).
      SORT lt_custsalespartnerfunc BY customer.

      "银行
      SELECT a~*
        FROM i_businesspartnerbank WITH PRIVILEGED ACCESS AS a
        JOIN @lt_data AS b ON a~businesspartner = b~businesspartner
        INTO TABLE @DATA(lt_bank).
      SORT lt_bank BY businesspartner.

    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data).
      CLEAR: ls_result.
      ls_result-customer = ls_data-businesspartner.
      ls_result-customername = ls_data-businesspartnername.
      ls_result-businesspartnercategory = ls_data-businesspartnercategory.
      ls_result-businesspartnergrouping = ls_data-businesspartnergrouping.
      ls_result-businesspartnergroupingtext = ls_data-businesspartnergroupingtext.
      ls_result-customeraccountgroup = ls_data-customeraccountgroup.
      ls_result-addresssearchterm1 = ls_data-addresssearchterm1.
      ls_result-country = ls_data-country.
      ls_result-region = ls_data-region.
      ls_result-regionname = ls_data-regionname.
      ls_result-streetname = ls_data-streetname.
      ls_result-postalcode = ls_data-postalcode.
      ls_result-cityname = ls_data-cityname.
      ls_result-language = ls_data-language.
      ls_result-phonenumber1 = ls_data-telephonenumber1.
      ls_result-phonenumber2 = ls_data-telephonenumber2.
      ls_result-faxnumber = ls_data-faxnumber.
      ls_result-lastchangedatetime = ls_data-lastchangedatetime.

      "邮箱
      READ TABLE lt_emailaddress INTO DATA(ls_emailaddress) WITH KEY businesspartner = ls_result-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-emailaddress = ls_emailaddress-emailaddress.
        CLEAR: ls_emailaddress.
      ENDIF.

      "税号
      READ TABLE lt_tax INTO DATA(ls_tax) WITH KEY businesspartner = ls_result-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-taxnumbertype = ls_tax-bptaxtype.
        ls_result-taxnumberresponsible = ls_tax-bptaxlongnumber.
        CLEAR: ls_tax.
      ENDIF.

      "银行
      READ TABLE lt_bank INTO DATA(ls_bank) WITH KEY businesspartner = ls_result-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-bankidentification      = ls_bank-bankidentification.
        ls_result-bankcountrykey          = ls_bank-bankcountrykey.
        ls_result-banknumber              = ls_bank-banknumber.
        ls_result-bankname                = ls_bank-bankname.
        ls_result-bankaccountholdername   = ls_bank-bankaccountholdername.
        ls_result-bankaccount             = ls_bank-bankaccount.
        ls_result-bankaccountreferencetext = ls_bank-bankaccountreferencetext.
        ls_result-bankaccountfull         = ls_bank-bankaccount && ls_bank-bankaccountreferencetext.
        CLEAR: ls_bank.
      ENDIF.

      "DUNS编号
      READ TABLE lt_bupaidentification INTO DATA(ls_bupaidentification) WITH KEY businesspartner = ls_result-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-bpidentificationnumber = ls_bupaidentification-bpidentificationnumber.
        CLEAR: ls_bupaidentification.
      ENDIF.

      "销售组织
      READ TABLE lt_salesarea INTO DATA(ls_salesarea) WITH KEY customer = ls_result-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-salesorganization = ls_salesarea-salesorganization.
        ls_result-purchaseordercurrency = ls_salesarea-currency.
        CLEAR: ls_salesarea.
      ENDIF.

      "主店代码
      READ TABLE lt_custsalespartnerfunc INTO DATA(ls_custsalespartnerfunc) WITH KEY customer = ls_result-customer BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-bpcustomernumber = ls_custsalespartnerfunc-bpcustomernumber.
        CLEAR: ls_custsalespartnerfunc.
      ENDIF.

      APPEND ls_result TO lt_result.

    ENDLOOP.

    et_result = lt_result.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_SD001'.
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
