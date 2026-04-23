CLASS zzcl_api_mm013 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.

    METHODS:constructor. "静态构造方法

    METHODS push
      IMPORTING
        i_infnr       TYPE zzt_mmi013_in OPTIONAL
        i_uuid        TYPE zzt_mmi013_1_in OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM013 IMPLEMENTATION.


  METHOD push.

    TYPES: BEGIN OF ty_data,
             partno          TYPE string,
             suppliercode    TYPE string,
             purchasinggroup TYPE string,
             plant           TYPE string,
             recordno        TYPE string,
             pricetype       TYPE string,
             price           TYPE string,
             type            TYPE string,
             tax             TYPE string,
             taxprice        TYPE string,
             begindate       TYPE string,
             enddate         TYPE string,
           END OF ty_data.
    DATA:lt_data TYPE TABLE OF ty_data,
         ls_data TYPE ty_data.

    DATA:lv_json_data TYPE string.
    DATA: lr_mm003 TYPE REF TO zzcl_query_mm003.
    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb VALUE 'DMS005'.
    DATA:lv_data TYPE string.
    DATA:lv_msgty TYPE bapi_mtype,
         lv_msgtx TYPE bapi_msg,
         lv_resp  TYPE string.

    "获取数据
    DATA:lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA:lt_range TYPE if_rap_query_filter=>tt_range_option.

    IF i_infnr IS NOT INITIAL.
      CLEAR: lt_range.
      LOOP AT i_infnr INTO DATA(ls_infnr).
        APPEND VALUE #( low = ls_infnr
                        sign = 'I'
                        option = 'EQ'  ) TO lt_range.
      ENDLOOP.
      APPEND VALUE #(  name = 'PURCHASINGINFORECORD'
                       range = lt_range
      ) TO lt_filters.
    ENDIF.

    IF i_uuid IS NOT INITIAL.
      CLEAR: lt_range.
      LOOP AT i_uuid INTO DATA(ls_uuid).
        APPEND VALUE #( low = ls_uuid
                        sign = 'I'
                        option = 'EQ'  ) TO lt_range.
      ENDLOOP.
      APPEND VALUE #(  name = 'UUID'
                       range = lt_range
      ) TO lt_filters.
    ENDIF.

    "获取数据
    CREATE OBJECT lr_mm003.
    CALL METHOD lr_mm003->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_result).
      CLEAR: ls_data.
      ls_data-partno = ls_result-material.
      ls_data-suppliercode = ls_result-supplier.
      ls_data-purchasinggroup = ls_result-purchasingorganization.
      ls_data-plant = ls_result-plant.
      ls_data-recordno = ls_result-conditionrecord.
      ls_data-pricetype = ls_result-pricetype.
      ls_data-price = ls_result-conditionvalueofbaseunit.
      ls_data-type = ls_result-producttype.
      ls_data-tax = ls_result-taxrate.
      ls_data-taxprice = ls_result-conditiontaxvalueofbaseunit.
      ls_data-begindate = ls_result-conditionvaliditystartdate.
      ls_data-enddate = ls_result-conditionvalidityenddate.
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
            ( abap = 'partNo'                            json = 'partNo' )
            ( abap = 'supplierCode'                      json = 'supplierCode' )
            ( abap = 'purchasingGroup'                   json = 'purchasingGroup' )
            ( abap = 'plant'                             json = 'plant' )
            ( abap = 'recordNo'                          json = 'recordNo' )
            ( abap = 'priceType'                         json = 'priceType' )
            ( abap = 'price'                             json = 'price' )
            ( abap = 'type'                              json = 'type' )
            ( abap = 'tax'                               json = 'tax' )
            ( abap = 'taxprice'                          json = 'taxprice' )
            ( abap = 'beginDate'                         json = 'beginDate' )
            ( abap = 'endDate'                           json = 'endDate' )

            ).



  ENDMETHOD.
ENDCLASS.
