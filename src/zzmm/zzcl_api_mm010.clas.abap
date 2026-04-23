CLASS zzcl_api_mm010 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.

    METHODS:constructor. "静态构造方法

    METHODS push
      IMPORTING
        i_req         TYPE zzt_mmi010_in OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM010 IMPLEMENTATION.


  METHOD push.

    TYPES:BEGIN OF ty_bankdetails,
            accountno   TYPE string,
            bankname    TYPE string,
            account     TYPE string,
            accountname TYPE string,
          END OF ty_bankdetails,
          BEGIN OF ty_supplier,
            suppliertype TYPE string,
            suppliercode TYPE string,
            suppliername TYPE string,
            currency     TYPE string,
            taxno        TYPE string,
            province     TYPE string,
            city         TYPE string,
            contact      TYPE string,
            contactno    TYPE string,
            bankdetails  TYPE TABLE OF ty_bankdetails WITH EMPTY KEY,
          END OF ty_supplier.

    DATA:lt_data TYPE TABLE OF ty_supplier,
         ls_data TYPE  ty_supplier.
    DATA:lv_json_data TYPE string.
    DATA: lr_mm001 TYPE REF TO zzcl_query_mm001.
    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb VALUE 'DMS002'.
    DATA:lv_data TYPE string.
    DATA:lv_msgty TYPE bapi_mtype,
         lv_msgtx TYPE bapi_msg,
         lv_resp  TYPE string.

    "获取数据
    DATA:lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA:lt_range TYPE if_rap_query_filter=>tt_range_option.
    LOOP AT i_req INTO DATA(ls_key).
      APPEND VALUE #( low = ls_key
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.
    ENDLOOP.

    APPEND VALUE #(  name = 'SUPPLIER'
                     range = lt_range
    ) TO lt_filters.

    "获取数据
    CREATE OBJECT lr_mm001.
    CALL METHOD lr_mm001->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = DATA(lt_result)
        et_bank    = DATA(lt_bank).

    "整理数据
    LOOP AT  lt_result INTO DATA(ls_result).
      CLEAR: ls_data.
      ls_data-suppliertype =  ls_result-businesspartnergroupingtext.
      ls_data-suppliercode =  ls_result-supplier.
      ls_data-suppliername =  ls_result-suppliername.
      ls_data-currency =  ls_result-PurchaseOrderCurrency.
      ls_data-taxno =  ls_result-taxnumberresponsible.
      ls_data-province =  ls_result-regionname.
      ls_data-city =  ls_result-cityname.
      ls_data-contact =  ls_result-businesspartnergroupingtext.
      ls_data-contactno =  ls_result-phonenumber2.

      READ TABLE lt_bank TRANSPORTING NO FIELDS WITH KEY businesspartner = ls_result-supplier BINARY SEARCH.
      IF sy-subrc = 0.
        LOOP AT lt_bank INTO DATA(ls_bank) FROM sy-tabix.
          IF ls_bank-businesspartner = ls_result-supplier.
            APPEND VALUE #(
                       accountno    = ls_bank-banknumber
                       bankname     = ls_bank-bankname
                       account      = ls_bank-bankaccount && ls_bank-bankaccountreferencetext
                       accountname  = ls_bank-bankaccountholdername
             ) TO ls_data-bankdetails.

          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      APPEND ls_data TO lt_data.
    ENDLOOP.



    lv_json_data = /ui2/cl_json=>serialize( EXPORTING data          = lt_data
                                                      compress      = abap_true
                                                      name_mappings = gt_mapping ).
    "获取调用类
    SELECT SINGLE zzcname
      FROM zr_vt_rest_conf
     WHERE zznumb = @lv_numb
      INTO @lv_oref.
    CHECK lv_oref IS NOT INITIAL.

* *&--调用实例化接口
    DATA:lo_oref TYPE REF TO object.

    lt_ptab = VALUE #( ( name  = 'IV_NUMB' kind  = cl_abap_objectdescr=>exporting value = REF #( lv_numb ) ) ).
    TRY .
        CREATE OBJECT lo_oref TYPE (lv_oref) PARAMETER-TABLE lt_ptab.
        CALL METHOD lo_oref->('OUTBOUND')
          EXPORTING
            iv_data  = lv_json_data
          CHANGING
            ev_resp  = lv_resp
            ev_msgty = lv_msgty
            ev_msgtx = lv_msgtx.
      CATCH cx_root INTO DATA(lr_root).
    ENDTRY.

    o_resp-msgty = lv_msgty.
    o_resp-msgtx = lv_msgtx.

  ENDMETHOD.


  METHOD constructor.

    gt_mapping = VALUE #(
         ( abap = 'supplierType'                       json = 'supplierType'                )
         ( abap = 'supplierCode'                       json = 'supplierCode'                )
         ( abap = 'supplierName'                       json = 'supplierName'                )
         ( abap = 'currency'                           json = 'currency'                    )
         ( abap = 'taxNo'                              json = 'taxNo'                       )
         ( abap = 'province'                           json = 'province'                    )
         ( abap = 'city'                               json = 'city'                        )
         ( abap = 'contact'                            json = 'contact'                     )
         ( abap = 'contactNo'                          json = 'contactNo'                   )
         ( abap = 'bankDetails'                        json = 'bankDetails'                 )
         ( abap = 'accountNo'                          json = 'accountNo'                   )
         ( abap = 'bankName'                           json = 'bankName'                    )
         ( abap = 'account'                            json = 'account'                     )
         ( abap = 'accountName'                        json = 'accountName'                 )
         ).

  ENDMETHOD.
ENDCLASS.
