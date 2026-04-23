CLASS zzcl_api_fi002 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii002_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_fii002_res.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI002 IMPLEMENTATION.


  METHOD inbound.

    DATA r_time TYPE RANGE OF i_enterpriseprojectelement-lastchangedatetime.
    DATA:ls_time TYPE zzs_rest_timestamp.
    DATA: lv_bstamp TYPE i_enterpriseprojectelement-lastchangedatetime,
          lv_estamp TYPE i_enterpriseprojectelement-lastchangedatetime.
    DATA:ls_out TYPE zzs_fii002_out.

    ls_time = i_req-data.
    lv_bstamp = zzcl_comm_tool=>iso2timestamp( iv_iso = ls_time-startoftime ).
    IF ls_time-endoftime IS NOT INITIAL.
      lv_estamp = zzcl_comm_tool=>iso2timestamp( iv_iso = ls_time-endoftime ).
    ELSE.
      GET TIME STAMP FIELD lv_estamp .
    ENDIF.

    r_time = VALUE #( ( low = lv_bstamp high = lv_estamp option = 'BT' sign = 'I' ) )."range 表



    SELECT a~projectelement,
           a~projectelementdescription,
           a~companycode,
           b~companycodename,
           a~processingstatus,
           a~lastchangedatetime,
           a~wbsisstatisticalwbselement,
           d~projecttypename

      FROM i_enterpriseprojectelement WITH PRIVILEGED ACCESS AS a
      LEFT OUTER JOIN i_companycode WITH PRIVILEGED ACCESS AS b ON a~companycode = b~companycode
      LEFT OUTER JOIN i_enterpriseproject WITH PRIVILEGED ACCESS AS c ON a~projectuuid = c~projectuuid
      LEFT OUTER JOIN i_projecttypetext WITH PRIVILEGED ACCESS AS d ON c~enterpriseprojecttype = d~projecttype
                                                                     AND d~language = 1
     WHERE a~lastchangedatetime IN @r_time
      INTO TABLE @DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data).
      CLEAR: ls_out .
      MOVE-CORRESPONDING ls_data TO ls_out.
      APPEND ls_out TO o_resp-msgdetail.
    ENDLOOP.

    IF o_resp-msgdetail IS NOT INITIAL.
      o_resp-msgty = 'S'.
      o_resp-msgtx = '查询成功'.
    ELSE.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '无数据'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
