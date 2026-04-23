CLASS zzcl_job_fi010 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_defaults .
    INTERFACES if_apj_rt_run .

*    DATA : company_code TYPE RANGE OF zc_query_fi012-companycode,
*           post_date    TYPE RANGE OF  zc_query_fi012-postdate.

DATA : company_code TYPE cl_apj_rt_api=>tt_value_range,
       post_date    TYPE cl_apj_rt_api=>tt_value_range.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_job_fi010 IMPLEMENTATION.


  METHOD if_apj_dt_defaults~fill_attribute_defaults.
*    company_code = VALUE #(
*    ( sign = 'I' option = 'EQ' low = 'GH00' )
*   ).
*    post_date = VALUE #(
*    ( sign = 'I' option = 'EQ' low = SY-DATUM  )
*   ).

* INSERT VALUE #( sign = 'I' option = 'EQ' low = 'GH00' ) INTO TABLE company_code.
*  INSERT VALUE #( sign = 'I' option = 'EQ' low = SY-DATUM ) INTO TABLE post_date.

  ENDMETHOD.


  METHOD if_apj_rt_run~execute.

     DATA:lv_bgdat        TYPE datum,
         lv_eddat        TYPE datum,
         lv_postdate     TYPE datum,
         lv_companycode  TYPE bukrs,
         lr_postdate     TYPE RANGE OF  datum,
         lr_pcompanycode TYPE RANGE OF  bukrs,
         lr_fi012        TYPE REF TO zzcl_api_fi012.

    IF company_code[] IS NOT INITIAL.
      LOOP AT post_date INTO DATA(ls_postdate).
        IF ls_postdate-low IS NOT INITIAL.
          lv_bgdat = ls_postdate-low.
        ENDIF.
        IF ls_postdate-high IS NOT INITIAL.
          lv_eddat = ls_postdate-high.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF company_code[] IS NOT INITIAL.
      LOOP AT company_code INTO DATA(ls_companycode).
        IF ls_companycode-low IS NOT INITIAL.
          lv_companycode = ls_companycode-low.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_companycode IS INITIAL.
        lv_companycode  = 'GH00'.
    ENDIF.

    IF lv_bgdat IS INITIAL.
        lv_bgdat  = '20260407'.
    ENDIF.

    CREATE OBJECT lr_fi012.
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

      lr_fi012->process( iv_begin = lv_postdate iv_bukrs = lv_companycode ).

      lv_postdate = lv_postdate + 1.
    ENDDO.


  ENDMETHOD.
ENDCLASS.
