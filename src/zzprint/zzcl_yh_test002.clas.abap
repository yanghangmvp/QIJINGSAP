CLASS zzcl_yh_test002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_yh_test002 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DELETE FROM zztfi007a WHERE recorddate = '20260401'.

    DELETE FROM zztmm007.
*    DATA: lv_data TYPE string.
*    DATA: lv_authorization TYPE string.
**    DATA: lv_user TYPE string VALUE 'QJDMS-WFFLAJ1N'.
**    DATA: lv_password TYPE string VALUE '9803mxsYs4S2Pm50rL2q1dBwqNw4S8uy'.
*
*    DATA: lv_user TYPE string VALUE 'FARWON_SAP-7W1S1P4G'.
*    DATA: lv_password TYPE string VALUE '25bA7Q40e627Yj433UD4lr6Q495M9Tw2'.
*
*    DATA(lv_unix_timestamp) = xco_cp=>sy->unix_timestamp( )->value.
*
*    lv_data = |date: { lv_unix_timestamp }|.
*    TRY.
** create the signature with the key and the request string
*        cl_abap_hmac=>calculate_hmac_for_char(
*          EXPORTING
*            if_algorithm           = 'SHA256'                                            "Hash Algorithm
**            if_algorithm           = 'S256'                                            "Hash Algorithm
*            if_key                 = cl_abap_hmac=>string_to_xstring( lv_password )     "HMAC Key
*            if_data                = lv_data
*          IMPORTING
*            ef_hmacb64string       = DATA(signature)                                      "HMAC value as base64-encoded string
*        ).
*      CATCH cx_abap_message_digest INTO DATA(lo_digest).
*        DATA(lv_error_text) = lo_digest->if_message~get_text( ).
*
*    ENDTRY.
*
**    lv_authorization = |hmac username="{ lv_user }",algorithm="hmac-s256", headers="date", signature="{ signature }"|.
*    lv_authorization = |hmac username="{ lv_user }",algorithm="HS256", headers="date", signature="{ signature }"|.
*
*    out->write( lv_data ).
*    out->write( lv_authorization ).
  ENDMETHOD.
ENDCLASS.
