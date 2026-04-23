CLASS zzcl_api_fi003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii003_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_fii003_res.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI003 IMPLEMENTATION.


  METHOD inbound.
    DATA r_time TYPE RANGE OF i_fixedasset-lastchangedatetime.
    DATA: r_bukrs  TYPE RANGE OF i_fixedasset-companycode,
          r_anln1  TYPE RANGE OF i_fixedasset-masterfixedasset,
          r_anln2  TYPE RANGE OF i_fixedasset-fixedasset,
          r_class  TYPE RANGE OF i_fixedasset-assetclass,
          r_adate  TYPE RANGE OF i_fixedasset-assetcapitalizationdate,
          r_ledger TYPE RANGE OF i_assetvaluationforledger-ledger.

    DATA: ls_in TYPE zzs_fii003_in.
    DATA: lv_bstamp TYPE i_fixedasset-lastchangedatetime,
          lv_estamp TYPE i_fixedasset-lastchangedatetime.
    DATA:ls_out TYPE zzs_fii003_out.

    ls_in = i_req-data.
    lv_bstamp = zzcl_comm_tool=>iso2timestamp( iv_iso = ls_in-startoftime ).
    IF ls_in-endoftime IS NOT INITIAL.
      lv_estamp = zzcl_comm_tool=>iso2timestamp( iv_iso = ls_in-endoftime ).
    ELSE.
      GET TIME STAMP FIELD lv_estamp .
    ENDIF.
    r_time = VALUE #( ( low = lv_bstamp high = lv_estamp option = 'BT' sign = 'I' ) ).

    IF ls_in-companycode IS NOT INITIAL.
      r_bukrs = VALUE #( ( low = ls_in-companycode high = '' option = 'EQ' sign = 'I'  )  ).
    ENDIF.
    IF ls_in-masterfixedasset IS NOT INITIAL.
      r_anln1 = VALUE #( ( low = ls_in-masterfixedasset high = '' option = 'EQ' sign = 'I'  )  ).
    ENDIF.
    IF ls_in-fixedasset IS NOT INITIAL.
      r_anln2 = VALUE #( ( low = ls_in-fixedasset high = '' option = 'EQ' sign = 'I'  )  ).
    ENDIF.
    IF ls_in-assetclass IS NOT INITIAL.
      r_class = VALUE #( ( low = ls_in-assetclass high = '' option = 'EQ' sign = 'I'  )  ).
    ENDIF.
    IF ls_in-ledger IS NOT INITIAL.
      r_ledger = VALUE #( ( low = ls_in-ledger high = '' option = 'EQ' sign = 'I'  )  ).
    ENDIF.
    IF ls_in-assetdate_begin IS NOT INITIAL.
      IF ls_in-assetdate_end IS INITIAL.
        ls_in-assetdate_end  = sy-datum.
      ENDIF.
      r_adate = VALUE #( ( low = ls_in-assetdate_begin high = ls_in-assetdate_end option = 'BT' sign = 'I'  )  ).
    ENDIF.
    "I_FixedAsset  固定资产
    "I_FixedAssetAssgmt  固定资产时间相关数据
    "I_FixedAssetForLedger 分类账的固定资产

    SELECT a~companycode,
           a~masterfixedasset,
           a~fixedasset,
           a~fixedassetdescription,
           a~assetadditionaldescription,
           c~ledger,
           a~assetclass,
           b~validitystartdate,
           b~validityenddate,
*           a~assetcapitalizationdate,
           f~assetcapitalizationdate AS assetcapitalizationdate,
           a~assetdeactivationdate,
           b~costcenter,
           b~wbselementinternalid_2 AS wbselement,
           a~quantity,
           a~baseunit,
           b~assetlocation,
           b~room,
           a~supplier,
           a~assetmanufacturername,
           c~assetrealdepreciationarea AS assetdepreciationarea,
           c~depreciationkey,
           c~plannedusefullifeinyears,
           c~plannedusefullifeinperiods,
           a~createdbyuser,
           a~creationdate,
           a~lastchangedbyuser,
           a~lastchangedate
      FROM i_fixedasset WITH PRIVILEGED ACCESS AS a      "资产主数据
      JOIN zr_fixedasset_tim  WITH PRIVILEGED ACCESS AS time  ON a~companycode = time~companycode
                                                             AND a~masterfixedasset = time~masterfixedasset
                                                             AND a~fixedasset = time~fixedasset
      LEFT OUTER JOIN i_fixedassetassgmt WITH PRIVILEGED ACCESS AS b ON a~companycode = b~companycode
                                                                    AND a~masterfixedasset = b~masterfixedasset
                                                                    AND a~fixedasset = b~fixedasset
      LEFT OUTER JOIN i_fixedassetforledger WITH PRIVILEGED ACCESS AS f ON a~companycode = f~companycode
                                                                    AND a~masterfixedasset = f~masterfixedasset
                                                                    AND a~fixedasset = f~fixedasset
                                                                    AND f~ledger = '0L'
      LEFT OUTER JOIN i_assetvaluationforledger WITH PRIVILEGED ACCESS AS c
                                          ON a~companycode = c~companycode
                                          AND a~masterfixedasset = c~masterfixedasset
                                          AND a~fixedasset = c~fixedasset
                                          AND c~assetrealdepreciationarea = '01'
     WHERE time~lastchangedatetime IN @r_time
       AND a~companycode IN @r_bukrs
       AND a~masterfixedasset IN @r_anln1
       AND a~fixedasset IN @r_anln2
       AND a~assetclass IN @r_class
       AND c~ledger IN @r_ledger
       AND f~assetcapitalizationdate IN @r_adate
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
