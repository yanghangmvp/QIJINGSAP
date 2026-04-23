CLASS zzcl_shp_save_document_prepare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_le_shp_save_doc_prepare .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SHP_SAVE_DOCUMENT_PREPARE IMPLEMENTATION.


  METHOD if_le_shp_save_doc_prepare~modify_fields.

    delivery_document_out = delivery_document_in.
    delivery_document_items_out = delivery_document_items_in.

    IF delivery_document_in-overallproofofdeliverystatus = 'A'.
      delivery_document_out-intcoextplndtransfofctrldtetme = '99991231000000'.
    ENDIF.

    IF delivery_document_in-overallproofofdeliverystatus = 'C'.
      DATA lv_num TYPE n LENGTH 2.
      DATA(lv_diff) = delivery_document_in-confirmationtime+0(2) - 8.
      DATA(lv_date_diff) = delivery_document_in-proofofdeliverydate.
      IF lv_diff < 0.
        lv_diff = lv_diff + 24.
        lv_date_diff = lv_date_diff - 1.
      ENDIF.
      lv_num = lv_diff.
      DATA(lv_time_diff) = lv_num && delivery_document_in-confirmationtime+2(4).
      delivery_document_out-intcoextactltransfofctrldtetme = lv_date_diff && lv_time_diff.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
