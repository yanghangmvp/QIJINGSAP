CLASS zcl_mmpur_pir_check_data_badi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_mmpur_pir_badi_check_data .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MMPUR_PIR_CHECK_DATA_BADI IMPLEMENTATION.


  METHOD if_mmpur_pir_badi_check_data~pir_data_validation.
    IF 1 = 1.
    ENDIF.
*    APPEND VALUE #( type = 'E'  message = '测试' ) TO ct_messages.
  ENDMETHOD.
ENDCLASS.
