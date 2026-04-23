CLASS zzcl_job_fi008 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_defaults .
    INTERFACES if_apj_rt_run .
    INTERFACES if_oo_adt_classrun .
*    DATA : companycode TYPE RANGE OF zc_query_fi009-companycode,
*           postdate    TYPE RANGE OF  zc_query_fi009-postdate.
DATA : companycode TYPE cl_apj_rt_api=>tt_value_range,
       postdate    TYPE cl_apj_rt_api=>tt_value_range.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_JOB_FI008 IMPLEMENTATION.


  METHOD if_apj_dt_defaults~fill_attribute_defaults.
*    companycode = VALUE #(
*    ( sign = 'I' option = 'EQ' low = 'GH00' )
*   ).
*    postdate = VALUE #(
*    ( sign = 'I' option = 'EQ' low = SY-DATUM  )
*   ).
* INSERT VALUE #( sign = 'I' option = 'EQ' low = 'GH00' ) INTO TABLE companycode.
*  INSERT VALUE #( sign = 'I' option = 'EQ' low = '20260420' ) INTO TABLE postdate.

  ENDMETHOD.


  METHOD if_apj_rt_run~execute.

    DATA:lv_bgdat        TYPE datum,
         lv_eddat        TYPE datum,
         lv_postdate     TYPE datum,
         lv_companycode  TYPE bukrs,
         lr_postdate     TYPE RANGE OF  datum,
         lr_pcompanycode TYPE RANGE OF  bukrs,
         lr_fi009        TYPE REF TO zzcl_api_fi009.

    IF companycode[] IS NOT INITIAL.
      LOOP AT postdate INTO DATA(ls_postdate).
        IF ls_postdate-low IS NOT INITIAL.
          lv_bgdat = ls_postdate-low.
        ENDIF.
        IF ls_postdate-high IS NOT INITIAL.
          lv_eddat = ls_postdate-high.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF companycode[] IS NOT INITIAL.
      LOOP AT companycode INTO DATA(ls_companycode).
        IF ls_companycode-low IS NOT INITIAL.
          lv_companycode = ls_companycode-low.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_companycode IS INITIAL.
        lv_companycode  = 'GH00'.
    ENDIF.

    IF lv_bgdat IS INITIAL.
        lv_bgdat  = SY-DATUM.
    ENDIF.

    CREATE OBJECT lr_fi009.
    IF lv_eddat IS INITIAL.
      lv_eddat = lv_bgdat.
    ENDIF.

    lv_postdate = lv_bgdat.

    DO .
      IF lv_postdate IS INITIAL.
        EXIT.
      ENDIF.

      IF lv_postdate > lv_eddat.
        EXIT.
      ENDIF.

      lr_fi009->process( iv_begin = lv_postdate iv_bukrs = lv_companycode ).

      lv_postdate = lv_postdate + 1.
    ENDDO.

  ENDMETHOD.

    METHOD if_oo_adt_classrun~main.


    TRY.
        me->if_apj_rt_run~execute( ).
      CATCH cx_apj_rt_content.
        "handle exception
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
