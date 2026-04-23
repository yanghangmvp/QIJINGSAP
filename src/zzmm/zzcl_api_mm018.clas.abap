CLASS zzcl_api_mm018 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS push
      IMPORTING
        i_req         TYPE zzt_mmi018_in OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm018 IMPLEMENTATION.


  METHOD push.
    TYPES: BEGIN OF ty_entry,
             doflag            TYPE string, "条目状态
             cdate             TYPE string, "创建日期
             ctime             TYPE string, "创建时间
             token             TYPE string,
             zguid             TYPE string,
             sfrom             TYPE string, "来源系统
             comp              TYPE string, "工厂代码
             orderno           TYPE string, "订单号
             orderrowno        TYPE string, "订单行号
             orderrowseqno     TYPE string, "行序号
             orderrecseqno     TYPE string, "收货行序号
             orderpayableseqno TYPE string, "应付行序号
             usedate           TYPE string, "过账日期
             price             TYPE string, "单价
             priceunit         TYPE string, "单位
             payablenum        TYPE string, "应付数量
             payableamount     TYPE string, "应付金额
             invoicenum        TYPE string, "
             invoiceamount     TYPE string, "
             componentno       TYPE string, "零件号
             receiveno         TYPE string, "收货单号
             taxrate           TYPE string, "
             supplierno        TYPE string, "供应商
             invoicestatus     TYPE string, "
             zsbd              TYPE string, "
             xmlpath           TYPE string, "
             zprsta            TYPE string, "价格类型
             zpara1            TYPE string, "采购组
             zpara2            TYPE string, "
             zpara3            TYPE string, "
             resultstatus      TYPE string, "
             resultmsg         TYPE string, "
             deleteflag        TYPE string, "
           END OF ty_entry.

    DATA: lr_mm004 TYPE REF TO zzcl_query_mm004.
    DATA: lr_xml TYPE REF TO zzcl_xml_builder.
    DATA: lt_entry TYPE TABLE OF ty_entry,
          ls_entry TYPE ty_entry.
    DATA: lv_xml TYPE string.

    DATA: lv_oref TYPE zzefname,
          lt_ptab TYPE abap_parmbind_tab.
    DATA: lv_numb TYPE zzenumb VALUE 'MMI018'.
    DATA: lv_msgty TYPE bapi_mtype,
          lv_msgtx TYPE bapi_msg,
          lv_resp  TYPE string.
    DATA: lv_uuid TYPE zzeuuid.

    DATA: lt_zztmm006 TYPE TABLE OF zztmm006.

    "获取数据
    DATA:lt_filters TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA:lt_range TYPE if_rap_query_filter=>tt_range_option.
    LOOP AT i_req INTO DATA(ls_key).
      APPEND VALUE #( low = ls_key
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.
    ENDLOOP.

    APPEND VALUE #( name = 'UUID'
                    range = lt_range
               ) TO lt_filters.

    "获取数据
    CREATE OBJECT lr_mm004.
    CALL METHOD lr_mm004->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_result).
      CLEAR: ls_entry.
      ls_entry = CORRESPONDING #( ls_result ).
      ls_entry-cdate = sy-datlo.
      ls_entry-ctime = sy-timlo.

      TRY .
          DATA(lv_uuid_c32) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
          ls_entry-token = ls_entry-zguid = lv_uuid_c32.
        CATCH cx_uuid_error.
          IF 1 = 1 .
          ENDIF.
      ENDTRY.

      CONDENSE ls_entry-price NO-GAPS.
      CONDENSE ls_entry-payablenum NO-GAPS.
      CONDENSE ls_entry-payableamount NO-GAPS.
      CONDENSE ls_entry-taxrate NO-GAPS.

      APPEND ls_entry TO lt_entry.
    ENDLOOP.

    "转xml
    TRY .
        DATA(lv_uuid_xml) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
        lv_uuid = lv_uuid_xml.
      CATCH cx_uuid_error.
        IF 1 = 1 .
        ENDIF.
    ENDTRY.

    CREATE OBJECT lr_xml.
    lv_xml = lr_xml->build_xml(
        it_table = lt_entry
        iv_uuid = CONV string( lv_uuid_xml )
        iv_numb = 'OfficialPayData_4P02'
    ).

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
            iv_uuid  = lv_uuid
            iv_data  = lv_xml
          CHANGING
            ev_resp  = lv_resp
            ev_msgty = lv_msgty
            ev_msgtx = lv_msgtx.
      CATCH cx_root INTO DATA(lr_root).
    ENDTRY.

    IF lv_msgty = 'S'.
      lt_zztmm006 = CORRESPONDING #( lt_result ).
      MODIFY zztmm006 FROM TABLE @lt_zztmm006.
    ENDIF.

    o_resp-msgty = lv_msgty.
    o_resp-msgtx = lv_msgtx.
  ENDMETHOD.
ENDCLASS.
