CLASS zzcl_api_mm011 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.

    METHODS:constructor. "静态构造方法

    METHODS push
      IMPORTING
        i_req         TYPE zzt_mmi011_in OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM011 IMPLEMENTATION.


  METHOD push.
    TYPES: BEGIN OF ty_data,
             partno           TYPE string,  "零件编码
             partname         TYPE string,  "零件名称
             ispurchase       TYPE string,  "是否可采购
             issale           TYPE string,  "是否可销售
             partpropertycode TYPE string,  "零件属性
             partpropertyname TYPE string,  "零件属性名称
             parttypecode     TYPE string,  "零件类别
             parttypename     TYPE string,  "零件类别名称
             unit             TYPE string,  "计量单位
             ordersnp         TYPE string,  "订购SNP
             dealersnp        TYPE string,  "对门店SNP（销售）
             ownercode        TYPE string,  "归属公司(货主)
             warehousecode    TYPE string,  "工厂（采购收货仓库）编码
             isengraving      TYPE string,  "是否打刻件
             isdirectsend     TYPE string,  "是否直供
             qualityperiod    TYPE string,  "保质期
             minsaleqty       TYPE string,  "最小销售数
             partenname       TYPE string,  "零件英文名称
             remark           TYPE string,  "备注
           END OF ty_data.

    DATA: lt_data TYPE TABLE OF ty_data,
          ls_data TYPE ty_data.

    DATA: lv_json_data TYPE string.
    DATA: lv_oref TYPE zzefname,
          lt_ptab TYPE abap_parmbind_tab.
    DATA: lv_numb TYPE zzenumb VALUE 'DMS003'.
    DATA: lv_data TYPE string.
    DATA: lv_msgty TYPE bapi_mtype,
          lv_msgtx TYPE bapi_msg,
          lv_resp  TYPE string.
    DATA: lr_mm002 TYPE REF TO zzcl_query_mm002.

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
    CREATE OBJECT lr_mm002.
    CALL METHOD lr_mm002->read_data
      EXPORTING
        it_filters = lt_filters
      IMPORTING
        et_result  = DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_result).
      CLEAR: ls_data.
      ls_data-partno = ls_result-product.
      ls_data-partname = ls_result-yy1_partver_prd.
      ls_data-ispurchase = ls_result-ispurchase.
      ls_data-issale = ls_result-issale.
      ls_data-unit = ls_result-baseunit.
      ls_data-ownercode = ls_result-companycode.
      ls_data-warehousecode = ls_result-plant.
      ls_data-partenname = ls_result-yy1_partver_en_prd.
      ls_data-remark = ls_result-lastchangedatetime.
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
         ( abap = 'partNo'                                    json = 'partNo' )
         ( abap = 'partName'                                  json = 'partName' )
         ( abap = 'isPurchase'                                json = 'isPurchase' )
         ( abap = 'isSale'                                    json = 'isSale' )
         ( abap = 'partPropertyCode'                          json = 'partPropertyCode' )
         ( abap = 'partPropertyName'                          json = 'partPropertyName' )
         ( abap = 'partTypeCode'                              json = 'partTypeCode' )
         ( abap = 'partTypeName'                              json = 'partTypeName' )
         ( abap = 'unit'                                      json = 'unit' )
         ( abap = 'orderSnp'                                  json = 'orderSnp' )
         ( abap = 'dealerSnp'                                 json = 'dealerSnp' )
         ( abap = 'ownerCode'                                 json = 'ownerCode' )
         ( abap = 'warehouseCode'                             json = 'warehouseCode' )
         ( abap = 'isEngraving'                               json = 'isEngraving' )
         ( abap = 'isDirectSend'                              json = 'isDirectSend' )
         ( abap = 'qualityPeriod'                             json = 'qualityPeriod' )
         ( abap = 'minSaleQty'                                json = 'minSaleQty' )
         ( abap = 'remark'                                    json = 'remark' )
         ( abap = 'partEnName'                                json = 'partEnName' )
         ).

  ENDMETHOD.
ENDCLASS.
