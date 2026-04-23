CLASS zzcl_dyr_test001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_DYR_TEST001 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA create_partner TYPE TABLE FOR CREATE i_businesspartnertp_3.
*    create_partner = VALUE #( (
*     %cid = 'bp1'
*     businesspartnercategory = '1'
*     %control-businesspartnercategory = if_abap_behv=>mk-on
*     lastname = 'Test_BP5'
*     %control-lastname = if_abap_behv=>mk-on
*     ) ).
    MODIFY ENTITIES OF i_businesspartnertp_3
     ENTITY businesspartner
     CREATE FROM create_partner
     CREATE BY \_bpaddrindependentphone
     FIELDS ( phonenumber isdefaultphonenumber ) WITH VALUE #( (
     %cid_ref = 'GDA001'
     %target = VALUE #(
     (
     %cid = 'GDA001'
     phonenumber = '99988123'
     isdefaultphonenumber = 'X'
     )
     )
     ) )
    MAPPED DATA(mapped)
     REPORTED DATA(reported)
     FAILED DATA(failed).
    COMMIT ENTITIES
     RESPONSE OF i_businesspartnertp_3
     FAILED DATA(failed_commit)
     REPORTED DATA(reported_commit).
    DATA(lv_msg) = zzcl_comm_tool=>get_bo_msg( is_reported = failed iv_component = 'buspartphonenumber' ).
  ENDMETHOD.
ENDCLASS.
