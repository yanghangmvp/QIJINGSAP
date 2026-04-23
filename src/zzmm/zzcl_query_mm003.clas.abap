CLASS zzcl_query_mm003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_mm003.


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
        et_result  TYPE  tt_result .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_QUERY_MM003 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_mm003,
          ls_result TYPE zc_query_mm003.

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
    DATA: lt_result TYPE TABLE OF zc_query_mm003,
          ls_result TYPE zc_query_mm003.

    DATA: lr_record TYPE RANGE OF zc_query_mm003-purchasinginforecord.
    DATA: lr_organization    TYPE RANGE OF zc_query_mm003-purchasingorganization.
    DATA: lr_category  TYPE RANGE OF zc_query_mm003-purchasinginforecordcategory.
    DATA: lr_conditiontype  TYPE RANGE OF zc_query_mm003-conditiontype.
    DATA: lr_supplier  TYPE RANGE OF zc_query_mm003-supplier.
    DATA: lr_material  TYPE RANGE OF zc_query_mm003-material.
    DATA: lr_uuid  TYPE RANGE OF zc_query_mm003-uuid.

    DATA lv_tax TYPE p LENGTH 11 DECIMALS 2.
    DATA lv_price TYPE p LENGTH 11 DECIMALS 6.
*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'PURCHASINGINFORECORD'.
          lr_record = CORRESPONDING #( ls_filter-range ).
        WHEN 'PURCHASINGORGANIZATION'.
          lr_organization = CORRESPONDING #( ls_filter-range ).
        WHEN 'PURCHASINGINFORECORDCATEGORY'.
          lr_category = CORRESPONDING #( ls_filter-range ).
        WHEN 'CONDITIONTYPE'.
          lr_conditiontype = CORRESPONDING #( ls_filter-range ).
        WHEN 'SUPPLIER'.
          lr_supplier = CORRESPONDING #( ls_filter-range ).
        WHEN 'MATERIAL'.
          lr_material = CORRESPONDING #( ls_filter-range ).
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).
      ENDCASE.
    ENDLOOP.

    "获取主数据
    SELECT u~uuid,
           a~purchasinginforecord,
           a~conditionrecord,
           a~purchasingorganization,
           a~purchasinginforecordcategory,
           a~plant,
           a~conditionsequentialnumbershort,
           a~conditiontype,
           a~conditionvalidityenddate,
           a~conditionvaliditystartdate,
           a~conditionratevalue,
           a~conditionratevalueunit,
           a~conditionquantity,
           a~conditionquantityunit,
           a~conditionapplication,
           a~conditioncalculationtypeshort,
           a~conditionisdeleted,
           a~conditiontobaseqtynmrtr,
           a~conditiontobaseqtydnmntr,
           a~conditioncurrency,
           b~supplier,
           b~purchasinginforecorddesc,
           b~material,
           b~materialgroup,
           d~producttype,
           b~purgdocorderquantityunit,
           b~orderitemqtytobaseqtynmrtr,
           b~orderitemqtytobaseqtydnmntr,
           b~baseunit,
           b~creationdate,
           c~purchasinggroup,
           c~taxcode,
           c~incotermsclassification,
           c~incotermstransferlocation,
           c~pricingdatecontrol

      FROM c_purginforecdpricecndndex WITH PRIVILEGED ACCESS AS a
      JOIN i_purchasinginforecordapi01 WITH PRIVILEGED ACCESS AS b ON a~purchasinginforecord = b~purchasinginforecord
      JOIN i_purginforecdorgplntdataapi01 WITH PRIVILEGED ACCESS AS c ON a~purchasinginforecord = c~purchasinginforecord
                                                                     AND a~purchasingorganization = c~purchasingorganization
                                                                     AND a~purchasinginforecordcategory = c~purchasinginforecordcategory
                                                                     AND a~plant = c~plant
      JOIN zc_purinforecord_uuid  WITH PRIVILEGED ACCESS AS u ON a~purchasinginforecord = u~purchasinginforecord
                                                             AND a~conditionrecord = u~conditionrecord
                                                             AND a~ConditionValidityEndDate = u~ConditionValidityEndDate
      LEFT OUTER JOIN i_product  WITH PRIVILEGED ACCESS AS d ON a~material = d~product
     WHERE a~purchasinginforecord IN @lr_record
       AND a~purchasingorganization IN @lr_organization
       AND a~purchasinginforecordcategory IN @lr_category
       AND a~conditiontype IN @lr_conditiontype
       AND b~supplier IN @lr_supplier
       AND b~material IN @lr_material
       AND u~uuid IN @lr_uuid
      INTO TABLE @DATA(lt_main).

    "税率
    WITH +taxcode AS ( SELECT DISTINCT taxcode FROM @lt_main AS a )
    SELECT a~*
     FROM i_taxcoderate AS a
     JOIN +taxcode  AS b ON a~taxcode = b~taxcode
    WHERE country = 'CN'
      AND cndnrecordvaliditystartdate <= @sy-datum
      AND cndnrecordvalidityenddate >=  @sy-datum
     INTO TABLE @DATA(lt_taxcoderate).
    SORT lt_taxcoderate BY taxcode.


    LOOP AT lt_main INTO DATA(ls_main).
      CLEAR: ls_result,lv_tax.
      MOVE-CORRESPONDING ls_main TO ls_result.

      READ TABLE lt_taxcoderate INTO DATA(ls_taxcoderate) WITH KEY taxcode = ls_result-taxcode BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-taxrate = ls_taxcoderate-conditionrateratio.
        lv_tax = 1 + ls_result-taxrate / 100 .
      ELSE.
        lv_tax = 1.
      ENDIF.

      IF ls_main-conditiontype = 'ZPR0'.
        ls_result-pricetype = '2'.
      ELSEIF ls_main-conditiontype = 'ZPR1'.
        ls_result-pricetype = '1'.
      ENDIF.


      IF ls_main-conditiontobaseqtydnmntr <> 0 AND ls_main-conditionquantity <> 0.
        CLEAR: lv_price.
        lv_price =  ( ls_main-conditionratevalue / ls_main-conditionquantity )  *
                    ( ls_main-conditiontobaseqtynmrtr / ls_main-conditiontobaseqtydnmntr ).
        ls_result-conditionvalueofbaseunit = lv_price.

        CLEAR: lv_price.
        lv_price =  ( ls_main-conditionratevalue / ls_main-conditionquantity )  *
                    ( ls_main-conditiontobaseqtynmrtr / ls_main-conditiontobaseqtydnmntr ) * lv_tax.
        ls_result-conditiontaxvalueofbaseunit = lv_price.
      ELSE.
        CLEAR: lv_price.
        lv_price = ls_main-conditionratevalue  .
        ls_result-conditionvalueofbaseunit = lv_price.
        CLEAR: lv_price.
        lv_price = ls_main-conditionratevalue  * lv_tax.
        ls_result-conditiontaxvalueofbaseunit = lv_price.
      ENDIF.

      CONDENSE ls_result-conditionvalueofbaseunit NO-GAPS.
      CONDENSE ls_result-conditiontaxvalueofbaseunit NO-GAPS.
      APPEND ls_result TO lt_result.
    ENDLOOP.

    et_result = lt_result.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_MM003'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
