CLASS zzcl_query_mm002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_mm002.

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



CLASS ZZCL_QUERY_MM002 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_mm002,
          ls_result TYPE zc_query_mm002.

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
    DATA: lt_result TYPE TABLE OF zc_query_mm002,
          ls_result TYPE zc_query_mm002.

    DATA: lr_product     TYPE RANGE OF zc_query_mm002-product,
          lr_plant       TYPE RANGE OF zc_query_mm002-plant,
          lr_producttype TYPE RANGE OF zc_query_mm002-producttype,
          lr_uuid        TYPE RANGE OF zc_query_mm002-uuid.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'PRODUCT'.
          lr_product = CORRESPONDING #( ls_filter-range ).
        WHEN 'PLANT'.
          lr_plant = CORRESPONDING #( ls_filter-range ).
        WHEN 'PRODUCTTYPE'.
          lr_producttype = CORRESPONDING #( ls_filter-range ).
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).
      ENDCASE.
    ENDLOOP.

    SELECT a~product,
           b~plant,
           a~producttype,
*           a~baseunit,
           a~yy1_partver_prd,
           a~yy1_modelcode_prd,
           a~yy1_configversion_prd,
           a~yy1_salescode_prd,
           a~yy1_partstatusdesc_prd,
           a~yy1_weight_prd,
           a~yy1_rawnum_prd,
           a~yy1_cost_prd,
           a~yy1_modelctrcode_prd,
           a~yy1_keypart_prd,
           a~yy1_hardwarecode_prd,
           a~yy1_softwarecode_prd,
           a~yy1_parttype_prd,
           a~yy1_materialtype_prd,
           a~yy1_partver_en_prd,
           b~serialnumberprofile,
           a~lastchangedatetime,
           a~ismarkedfordeletion,
           b~ismarkedfordeletion AS ismarkedfordeletion_plant,
           c~companycode,
           e~unitofmeasure_e AS baseunit
      FROM i_product WITH PRIVILEGED ACCESS AS a
      JOIN i_productplantbasic WITH PRIVILEGED ACCESS AS b ON a~product = b~product
      JOIN zc_product_timst WITH PRIVILEGED ACCESS AS d ON b~product = d~product
                                                       AND b~plant = d~plant
      LEFT JOIN i_valuationarea WITH PRIVILEGED ACCESS AS c ON b~plant = c~valuationarea
      LEFT JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS e ON a~baseunit = e~unitofmeasure
                                                               AND e~language = '1'
     WHERE a~product IN @lr_product
       AND b~plant IN @lr_plant
       AND a~producttype IN @lr_producttype
       AND d~uuid IN @lr_uuid
      INTO TABLE @DATA(lt_data).
    SORT lt_data BY product plant.

    LOOP AT lt_data INTO DATA(ls_data).
      CLEAR: ls_result.
      ls_result = CORRESPONDING #( ls_data ).

      IF ls_data-ismarkedfordeletion IS INITIAL AND ls_data-ismarkedfordeletion_plant IS INITIAL.
        ls_result-ispurchase = 'Y'.
        ls_result-issale = 'Y'.
      ELSE.
        ls_result-ispurchase = 'N'.
        ls_result-issale = 'N'.
      ENDIF.

      ls_result-uuid = ls_data-product && ls_data-plant.

      APPEND ls_result TO lt_result.
    ENDLOOP.

    et_result = lt_result.

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_MM002'.
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
