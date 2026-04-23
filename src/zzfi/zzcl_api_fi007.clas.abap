CLASS zzcl_api_fi007 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_general,
            fixedassetdescription      TYPE string,
            assetadditionaldescription TYPE string,
            assetserialnumber          TYPE string,
            baseunitsapcode            TYPE string,
            baseunitisocode            TYPE string,
          END OF ty_general,
          BEGIN OF ty_accountassignment,
            validitystartdate          TYPE string,
            fixedassetobjectactioncode TYPE string,
            costcenter                 TYPE string,
            wbselementexternalid       TYPE string,
            profitcenter               TYPE string,
            segment                    TYPE string,
            plant                      TYPE string,
            assetlocation              TYPE string,
            room                       TYPE string,
            vehiclelicenseplatenumber  TYPE string,
            taxjurisdiction            TYPE string,
            businessplace              TYPE string,
            fund                       TYPE string,
            grantid                    TYPE string,
            functionalarea             TYPE string,
          END OF ty_accountassignment,
          BEGIN OF ty_origin,
            supplier             TYPE string,
            assetcountryoforigin TYPE string,
          END OF ty_origin,
          BEGIN OF ty_globtimebasedmasterdata,
            validitystartdate          TYPE string,
            fixedassetobjectactioncode TYPE string, "Action indicator for 01create, 02change, and 03delete
          END OF ty_globtimebasedmasterdata,
          BEGIN OF ty_ledger,
            ledger                  TYPE string,
            assetcapitalizationdate TYPE string,
          END OF ty_ledger,
          BEGIN OF ty_data,
            companycode                  TYPE string,
            assetclass                   TYPE string,
            masterfixedasset             TYPE string,
            fixedasset                   TYPE string,
            assetisforpostcapitalization TYPE string,
            _general                     TYPE ty_general,
            _accountassignment           TYPE ty_accountassignment,
            _origin                      TYPE ty_origin,
            _globtimebasedmasterdata     TYPE TABLE OF ty_globtimebasedmasterdata  WITH EMPTY KEY,
            _ledger                      TYPE TABLE OF ty_ledger  WITH EMPTY KEY,
          END OF ty_data,
          BEGIN OF ty_udata,
            _general           TYPE ty_general,
            _accountassignment TYPE TABLE OF ty_accountassignment WITH EMPTY KEY,
            _origin            TYPE ty_origin,
          END OF ty_udata.


    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.

    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii007_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI007 IMPLEMENTATION.


  METHOD inbound.

    DATA: ls_req TYPE zzs_fii007_in.
    DATA: ls_data TYPE ty_data.
    DATA: ls_udata TYPE ty_udata.
    DATA: ls_startdate TYPE string.


    ls_req = i_req-data.

    IF ls_req-costcenter IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '输入成本中心'.
      RETURN.
    ENDIF.

    ls_req-masterfixedasset = |{ ls_req-masterfixedasset ALPHA = IN }|.
    ls_startdate = |{ ls_req-validitystartdate+0(4) }-{ ls_req-validitystartdate+4(2) }-{ ls_req-validitystartdate+6(2) }|.

    CASE ls_req-doflag.
      WHEN 'I'.
        "公司代码
        ls_data-companycode = ls_req-companycode.
        "资产分类
        ls_data-assetclass = ls_req-assetclass.
        "资产描述
        ls_data-_general-fixedassetdescription = ls_req-fixedassetdescription.
        ls_data-_general-assetadditionaldescription = ls_req-assetadditionaldescription.
        "序列号
        ls_data-_general-assetserialnumber = ls_req-assetserialnumber.
        "单位
        ls_data-_general-baseunitsapcode = ls_req-baseunit.
        ls_data-_general-baseunitisocode = ls_req-baseunit.

        "时间数据
        APPEND VALUE #( validitystartdate = ls_startdate
         )
               TO ls_data-_globtimebasedmasterdata.


        "时间相关数据
        "成本中心
        ls_data-_accountassignment-costcenter = ls_req-costcenter.
        "WBS
        ls_data-_accountassignment-wbselementexternalid = ls_req-wbselement.
        "位置
        ls_data-_accountassignment-assetlocation = ls_req-assetlocation.
        "房间
        ls_data-_accountassignment-room = ls_req-room.
        "利润中心
        ls_data-_accountassignment-profitcenter = 'PGH00'.
        "细分
        ls_data-_accountassignment-segment = '1000_A'.

        "来源
        ls_data-_origin-supplier = ls_req-supplier.

        "分类帐
        APPEND VALUE #( ledger = '0L' ) TO ls_data-_ledger.
        APPEND VALUE #( ledger = '2L' ) TO ls_data-_ledger.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV4'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/api_fixedasset/srvd_a2x/sap/fixedasset/0001/FixedAsset/SAP__self.CreateMasterFixedAsset?sap-language={ gv_language }|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_data
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
        IF gs_http_resp-code = '201'.
          TYPES:BEGIN OF ty_ress,
                  companycode      TYPE string,
                  masterfixedasset TYPE string,
                  fixedasset       TYPE string,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = |公司代码{ ls_ress-companycode }资产{ ls_ress-masterfixedasset }创建成功！|.
          o_resp-sapnum = |{ ls_ress-companycode }/{ ls_ress-masterfixedasset  }|.


        ELSE.
          DATA:ls_rese TYPE zzs_odata4_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message .

        ENDIF.

      WHEN 'U'.
        DATA: ls_accountassignment TYPE ty_accountassignment.

        IF ls_req-costcenter IS NOT INITIAL.
          IF ls_req-validitystartdate IS INITIAL.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '输入有效期'.
            RETURN.
          ENDIF.
        ENDIF.

        "资产描述
        ls_udata-_general-fixedassetdescription = ls_req-fixedassetdescription.
        ls_udata-_general-assetadditionaldescription = ls_req-assetadditionaldescription.
        "序列号
        ls_udata-_general-assetserialnumber = ls_req-assetserialnumber.
        "单位
        ls_udata-_general-baseunitsapcode = ls_req-baseunit.
        ls_udata-_general-baseunitisocode = ls_req-baseunit.

        "时间相关数据
        SELECT SINGLE *
          FROM i_fixedassetassgmt WITH PRIVILEGED ACCESS AS a
         WHERE companycode = @ls_req-companycode
           AND masterfixedasset = @ls_req-masterfixedasset
           AND fixedasset = '0000'
           AND validitystartdate = @ls_req-validitystartdate
          INTO @DATA(ls_assgmt).
        IF sy-subrc = 0.
          ls_accountassignment-fixedassetobjectactioncode = '02'.
        ELSE.
          ls_accountassignment-fixedassetobjectactioncode = '01'.
        ENDIF.

        ls_accountassignment-validitystartdate = ls_startdate.
        "成本中心
        ls_accountassignment-costcenter = ls_req-costcenter.
        "WBS
        ls_accountassignment-wbselementexternalid = ls_req-wbselement.
        "位置
        ls_accountassignment-assetlocation = ls_req-assetlocation.
        "房间
        ls_accountassignment-room = ls_req-room.
        "利润中心
        ls_accountassignment-profitcenter = 'PGH00'.
        "细分
        ls_accountassignment-segment = '1000_A'.

        APPEND ls_accountassignment TO ls_udata-_accountassignment.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV4'.
        gs_http_req-method = 'POST'.
        gs_http_req-etag = '*'.
        gs_http_req-url = |/api_fixedasset/srvd_a2x/sap/fixedasset/0001/FixedAsset/{ ls_req-companycode }/{ ls_req-masterfixedasset }/0000/| &&
                          |SAP__self.Change?sap-language={ gv_language }|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_udata
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
        IF gs_http_resp-code = '200'.
          o_resp-msgty = 'S'.
          o_resp-msgtx = '更新成功'.
        ELSE.
          /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                                     CHANGING  data = ls_rese ).
          o_resp-msgty = 'E'.
          LOOP AT ls_rese-error-details INTO DATA(ls_details).
            o_resp-msgtx  = o_resp-msgtx  && ls_details-message.
          ENDLOOP.

          IF o_resp-msgtx IS INITIAL.
            o_resp-msgtx = ls_rese-error-message.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
           ( abap = 'FixedAssetObjectActionCode'        json = 'FixedAssetObjectActionCode'                )
           ( abap = 'CompanyCode'                       json = 'CompanyCode'                )
           ( abap = 'AssetClass'                        json = 'AssetClass'                 )
           ( abap = 'MasterFixedAsset'                  json = 'MasterFixedAsset'           )
           ( abap = 'FixedAsset'                        json = 'FixedAsset'                 )
           ( abap = 'AssetIsForPostCapitalization'      json = 'AssetIsForPostCapitalization'     )

           ( abap = '_AccountAssignment'                json = '_AccountAssignment'                 )
           ( abap = 'CostCenter'                        json = 'CostCenter'                 )
           ( abap = 'WBSElementExternalID'              json = 'WBSElementExternalID'                 )
           ( abap = 'ProfitCenter'                      json = 'ProfitCenter'                 )
           ( abap = 'Segment'                           json = 'Segment'                 )
           ( abap = 'Plant'                             json = 'Plant'                 )
           ( abap = 'AssetLocation'                     json = 'AssetLocation'                 )
           ( abap = 'Room'                              json = 'Room'                 )
           ( abap = 'VehicleLicensePlateNumber'         json = 'VehicleLicensePlateNumber'                 )
           ( abap = 'TaxJurisdiction'                   json = 'TaxJurisdiction'                 )
           ( abap = 'BusinessPlace'                     json = 'BusinessPlace'                 )
           ( abap = 'Fund'                              json = 'Fund'                 )
           ( abap = 'GrantID'                           json = 'GrantID'                 )
           ( abap = 'FunctionalArea'                    json = 'FunctionalArea'                 )

           ( abap = '_General'                          json = '_General'                 )
           ( abap = 'FixedAssetDescription'             json = 'FixedAssetDescription'                 )
           ( abap = 'AssetAdditionalDescription'        json = 'AssetAdditionalDescription'                 )
           ( abap = 'AssetSerialNumber'                 json = 'AssetSerialNumber'                 )
           ( abap = 'BaseUnitSAPCode'                   json = 'BaseUnitSAPCode'                 )
           ( abap = 'BaseUnitISOCode'                   json = 'BaseUnitISOCode'                 )

           ( abap = '_Origin'                           json = '_Origin'                 )
           ( abap = 'Supplier'                          json = 'Supplier'                 )

           ( abap = '_GlobTimeBasedMasterData'          json = '_GlobTimeBasedMasterData'                 )
           ( abap = 'ValidityStartDate'                 json = 'ValidityStartDate'                 )

           ( abap = '_Ledger'                           json = '_Ledger'                 )
           ( abap = 'Ledger'                            json = 'Ledger'                 )
           ( abap = 'AssetCapitalizationDate'           json = 'AssetCapitalizationDate'                 )

                           ).
    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.
  ENDMETHOD.
ENDCLASS.
