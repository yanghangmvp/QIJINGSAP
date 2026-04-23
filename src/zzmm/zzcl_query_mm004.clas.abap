CLASS zzcl_query_mm004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:tt_result TYPE TABLE OF zc_query_mm004.


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



CLASS zzcl_query_mm004 IMPLEMENTATION.


  METHOD get_data.
    DATA: lt_result TYPE TABLE OF zc_query_mm004,
          ls_result TYPE zc_query_mm004.

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
    DATA: lt_result TYPE TABLE OF zc_query_mm004,
          ls_result TYPE zc_query_mm004.

    DATA: lr_purchaseordertype TYPE RANGE OF zc_query_mm004-purchaseordertype,
          lr_zpara1            TYPE RANGE OF zc_query_mm004-zpara1,
          lr_componentno       TYPE RANGE OF zc_query_mm004-componentno,
          lr_comp              TYPE RANGE OF zc_query_mm004-comp,
          lr_usedate           TYPE RANGE OF zc_query_mm004-usedate,
          lr_uuid              TYPE RANGE OF zc_query_mm004-uuid.

*   过滤器
    LOOP AT it_filters INTO DATA(ls_filter).
      TRANSLATE ls_filter-name TO UPPER CASE.
      CASE ls_filter-name.
        WHEN 'PURCHASEORDERTYPE'.
          lr_purchaseordertype = CORRESPONDING #( ls_filter-range ).
        WHEN 'ZPARA1'.
          lr_zpara1 = CORRESPONDING #( ls_filter-range ).
        WHEN 'COMPONENTNO'.
          lr_componentno = CORRESPONDING #( ls_filter-range ).
        WHEN 'COMP'.
          lr_comp = CORRESPONDING #( ls_filter-range ).
        WHEN 'USEDATE'.
          lr_usedate = CORRESPONDING #( ls_filter-range ).
        WHEN 'UUID'.
          lr_uuid = CORRESPONDING #( ls_filter-range ).
      ENDCASE.
    ENDLOOP.

    SELECT b~purchaseordertype,
           b~purchasingorganization,
           b~purchasinggroup,
           b~companycode,
           a~plant,
           a~purchaseorder,
           a~purchaseorderitem,
           a~purchasinghistorydocument,
           a~purchasinghistorydocumentitem,
           a~material,
           b~invoicingparty,
           a~postingdate,
           c~conditionratevalue,
           c~conditionquantity,
           c~conditionquantityunit,
           c~conditiontype,
      CASE a~debitcreditcode
           WHEN 'S' THEN quantityinbaseunit
           WHEN 'H' THEN 0 - quantityinbaseunit
       END AS quantityinbaseunit,
           a~purchaseorderamount,
           a~currency,
           e~yy1_purchaseorderitem_pdi,
           e~taxcode
      FROM i_purchaseorderhistoryapi01 AS a
      JOIN i_purchaseorderapi01 AS b ON a~purchaseorder = b~purchaseorder
      LEFT JOIN i_purorditmpricingelementapi01 AS c ON a~purchaseorder = c~purchaseorder
                                                   AND a~purchaseorderitem = c~purchaseorderitem
                                                   AND c~conditioninactivereason IS INITIAL
                                                   AND c~conditioncategory = 'H'
      JOIN zc_purchaseorder_timst AS d ON a~purchasinghistorydocument = d~purchasinghistorydocument
                                      AND a~purchasinghistorydocumentitem = d~purchasinghistorydocumentitem
      JOIN i_purchaseorderitemapi01 AS e ON a~purchaseorder = e~purchaseorder
                                        AND a~purchaseorderitem = e~purchaseorderitem
     WHERE b~purchaseordertype IN @lr_purchaseordertype
       AND a~material IN @lr_componentno
       AND b~purchasinggroup IN @lr_zpara1
       AND a~plant IN @lr_comp
       AND a~postingdate IN @lr_usedate
       AND d~uuid IN @lr_uuid
       AND a~purchasinghistorycategory = 'E'
       AND a~postingdate >= '20260101'
      INTO TABLE @DATA(lt_purchaseorder).
    SORT lt_purchaseorder BY purchasinghistorydocument purchasinghistorydocumentitem.

    IF lt_purchaseorder IS NOT INITIAL.
      SELECT a~purchasinghistorydocument,
             a~purchasinghistorydocumentitem,
             a~referencedocument,
             a~referencedocumentitem
        FROM i_purchaseorderhistoryapi01 AS a
        JOIN @lt_purchaseorder AS b ON a~referencedocument = b~purchasinghistorydocument
                                   AND a~referencedocumentitem = b~purchasinghistorydocumentitem
       WHERE a~purchasinghistorycategory = 'Q'
        INTO TABLE @DATA(lt_reference).

      LOOP AT lt_reference INTO DATA(ls_reference).
        IF ls_reference-purchasinghistorydocumentitem MOD 2 = 0.
          DELETE lt_reference.
        ENDIF.
      ENDLOOP.

      SORT lt_reference BY referencedocument referencedocumentitem.

      SELECT receiveno,
             orderrecseqno
        FROM zztmm006
         FOR ALL ENTRIES IN @lt_purchaseorder
       WHERE receiveno = @lt_purchaseorder-purchasinghistorydocument
         AND orderrecseqno = @lt_purchaseorder-purchasinghistorydocumentitem
        INTO TABLE @DATA(lt_zztmm006).
      SORT lt_zztmm006 BY receiveno orderrecseqno.

      "税率
      WITH +i AS ( SELECT DISTINCT taxcode FROM @lt_purchaseorder AS i WHERE taxcode IS NOT INITIAL )
      SELECT a~taxcode,
             a~conditionrateratio
        FROM i_taxcoderate AS a
        JOIN +i AS i ON a~taxcode = i~taxcode
       WHERE a~cndnrecordvalidityenddate >= @sy-datum
         AND a~accountkeyforglaccount = 'VST'
         AND country = 'CN'
        INTO TABLE @DATA(lt_taxcoderate).
      SORT lt_taxcoderate BY taxcode.
    ENDIF.

    LOOP AT lt_purchaseorder INTO DATA(ls_purchaseorder).

      READ TABLE lt_reference INTO ls_reference WITH KEY referencedocument = ls_purchaseorder-purchasinghistorydocument
                                                         referencedocumentitem = ls_purchaseorder-purchasinghistorydocumentitem
                                                         BINARY SEARCH.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR: ls_result.
      ls_result-purchaseordertype = ls_purchaseorder-purchaseordertype.
      ls_result-ekorg = ls_purchaseorder-purchasingorganization.
      ls_result-zpara1 = ls_purchaseorder-purchasinggroup.
      ls_result-compcode = ls_purchaseorder-companycode.
      ls_result-comp = ls_purchaseorder-plant.
      ls_result-orderno = ls_purchaseorder-purchaseorder.
      ls_result-orderrowno = ls_purchaseorder-purchaseorderitem.
      ls_result-orderrowseqno = ls_purchaseorder-yy1_purchaseorderitem_pdi.
      ls_result-receiveno = ls_purchaseorder-purchasinghistorydocument.
      ls_result-orderrecseqno = ls_purchaseorder-purchasinghistorydocumentitem.
      ls_result-orderpayableseqno = 1.
      ls_result-componentno = ls_purchaseorder-material.
      ls_result-supplierno = ls_purchaseorder-invoicingparty.
      ls_result-usedate = ls_purchaseorder-postingdate.
      ls_result-price = ls_purchaseorder-conditionratevalue / ls_purchaseorder-conditionquantity.
      ls_result-priceunit = ls_purchaseorder-conditionquantityunit.
      ls_result-zprsta = ls_purchaseorder-conditiontype.
      ls_result-payablenum = ls_purchaseorder-quantityinbaseunit.
      ls_result-payableamount = ls_purchaseorder-purchaseorderamount.
      ls_result-documentcurrency = ls_purchaseorder-currency.
      ls_result-sfrom = 'QJSAP'.

      READ TABLE lt_zztmm006 INTO DATA(ls_zztmm006) WITH KEY receiveno = ls_result-receiveno
                                                             orderrecseqno = ls_result-orderrecseqno
                                                             BINARY SEARCH.
      IF sy-subrc = 0.
        ls_result-doflag = 'U'.
      ELSE.
        ls_result-doflag = 'I'.
      ENDIF.

      IF ls_purchaseorder-taxcode IS NOT INITIAL.
        READ TABLE lt_taxcoderate INTO DATA(ls_taxcoderate) WITH KEY taxcode = ls_purchaseorder-taxcode BINARY SEARCH.
        IF sy-subrc = 0.
          ls_result-taxrate = ls_taxcoderate-conditionrateratio.
          CLEAR: ls_taxcoderate.
        ENDIF.
      ENDIF.

      ls_result-uuid = ls_result-receiveno && ls_result-orderrecseqno.

      APPEND ls_result TO lt_result.
    ENDLOOP.

    et_result = lt_result.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.

        CASE io_request->get_entity_id( ).
          WHEN 'ZC_QUERY_MM004'.
            get_data( io_request  = io_request
                      io_response = io_response ).

        ENDCASE.

      CATCH cx_root INTO DATA(lr_root).
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
