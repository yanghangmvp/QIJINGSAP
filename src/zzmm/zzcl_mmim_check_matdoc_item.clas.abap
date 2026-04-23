CLASS zzcl_mmim_check_matdoc_item DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_badi_mmim_check_matdoc_item .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_MMIM_CHECK_MATDOC_ITEM IMPLEMENTATION.


  METHOD if_badi_mmim_check_matdoc_item~check_item.
    "取产品标准价格"
    IF item_matdoc-material IS NOT INITIAL.
      SELECT SINGLE standardprice
      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
      WHERE product                   = @item_matdoc-material
        AND valuationarea             = @item_matdoc-plant
        AND inventoryvaluationprocedure = 'S'
        INTO @DATA(lv_standardprice) .
      IF  sy-subrc = 0.
        "如果物料价格为0，则报错"
        IF lv_standardprice = 0.
          "取产品描述"
          SELECT SINGLE productdescription
            FROM i_productdescription_2 WITH PRIVILEGED ACCESS
           WHERE product = @item_matdoc-material
             AND language = @sy-langu
            INTO @DATA(lv_productdescription).
          DATA: ls_message TYPE if_badi_mmim_check_matdoc_item=>ts_matdoc_messages.
          ls_message-messagetype = 'E'.
          ls_message-messagetext = |{ item_matdoc-material }({ lv_productdescription }) 在 { item_matdoc-plant } 工厂的价格为 0,请联系财务发布价格|.
          APPEND ls_message TO messages.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
