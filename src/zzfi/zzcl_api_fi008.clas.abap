CLASS zzcl_api_fi008 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_emailaddress,
             emailaddress TYPE string,
           END OF ty_emailaddress,
           BEGIN OF ty_phonenumber,
             phonenumber TYPE string,
           END OF ty_phonenumber,

           BEGIN OF ty_businesspartneraddres,
             country         TYPE string,
             language        TYPE string,
             streetname      TYPE string,
             region          TYPE string,
             postalcode      TYPE string,
             cityname        TYPE string,
             to_phonenumber  TYPE TABLE OF ty_phonenumber WITH EMPTY KEY,
             to_emailaddress TYPE TABLE OF ty_emailaddress WITH EMPTY KEY,
           END OF ty_businesspartneraddres,
           BEGIN OF ty_businesspartnertax,
             bptaxtype       TYPE string,
             bptaxlongnumber TYPE string,
           END OF ty_businesspartnertax,
           BEGIN OF ty_businesspartnerrole,
             businesspartnerrole TYPE string,
           END OF ty_businesspartnerrole,
           BEGIN OF ty_partnerfunction,
             partnerfunction TYPE string,
           END OF ty_partnerfunction,
           BEGIN OF ty_salesareatax,
             departurecountry          TYPE string,
             customertaxcategory       TYPE string,
             customertaxclassification TYPE string,
           END OF ty_salesareatax,
           BEGIN OF ty_businesspartnerbank,
             businesspartner          TYPE string,
             bankidentification       TYPE string,
             bankcountrykey           TYPE string,
             banknumber               TYPE string,
             bankaccount              TYPE string,
             bankaccountreferencetext TYPE string,
           END OF ty_businesspartnerbank,

           BEGIN OF ty_customersalesarea,
             customeraccountgroup           TYPE string,
             salesorganization              TYPE string,
             distributionchannel            TYPE string,
             division                       TYPE string,
             currency                       TYPE string,
             customeraccountassignmentgroup TYPE string,
             customerpaymentterms           TYPE string,
             incotermsclassification        TYPE string,
             incotermslocation1             TYPE string,
             shippingcondition              TYPE string,
             customerpricingprocedure       TYPE string,
             supplyingplant                 TYPE string,
             to_salesareatax                TYPE TABLE OF ty_salesareatax    WITH EMPTY KEY,
             to_partnerfunction             TYPE TABLE OF ty_partnerfunction WITH EMPTY KEY,
           END OF ty_customersalesarea,
           BEGIN OF ty_customercompany,
             companycode                   TYPE string,
             paymentterms                  TYPE string,
             reconciliationaccount         TYPE string,
             layoutsortingrule             TYPE string,
             supplierclerkidbysupplier     TYPE string,
             postingisblocked              TYPE string,
             isdoubleinvoice               TYPE string,
             paymentmethodslist            TYPE string,
             recordpaymenthistoryindicator TYPE abap_bool,
             deletionindicator             TYPE abap_bool,
             physicalinventoryblockind     TYPE abap_bool,
           END OF ty_customercompany,

           BEGIN OF ty_customer,
             customeraccountgroup TYPE string,
             to_customersalesarea TYPE TABLE OF ty_customersalesarea WITH EMPTY KEY,
             to_customercompany   TYPE TABLE OF ty_customercompany WITH EMPTY KEY,
           END OF ty_customer,

           BEGIN OF ty_suppliercompany,
             supplier                  TYPE string,
             companycode               TYPE string,
             paymentterms              TYPE string,
             reconciliationaccount     TYPE string,
             layoutsortingrule         TYPE string,
             supplierclerkidbysupplier TYPE string,
             postingisblocked          TYPE string,
             isdoubleinvoice           TYPE string,
             paymentmethodslist        TYPE string,
           END OF ty_suppliercompany,
           BEGIN OF ty_supplierpurchasingorg,
             supplier                      TYPE string,
             purchasingorganization        TYPE string,
             purchaseordercurrency         TYPE string,
             paymentterms                  TYPE string,
             invoiceisgoodsreceiptbased    TYPE string,
             purchasingisblocked           TYPE string,
             purordautogenerationisallowed TYPE string,
           END OF ty_supplierpurchasingorg,
           BEGIN OF ty_supplier,
             postingisblocked         TYPE abap_bool,
             purchasingisblocked      TYPE abap_bool,
             to_suppliercompany       TYPE TABLE OF ty_suppliercompany WITH EMPTY KEY,
             to_supplierpurchasingorg TYPE TABLE OF ty_supplierpurchasingorg WITH EMPTY KEY,
           END OF ty_supplier,

           BEGIN OF ty_data,
             businesspartner           TYPE string,
             businesspartnergrouping   TYPE string,
             businesspartnercategory   TYPE string,
             organizationbpname1       TYPE string,
             searchterm1               TYPE string,
             formofaddress             TYPE string,
             businesspartnerisblocked  TYPE abap_bool,  "客户冻结
             to_businesspartneraddress TYPE TABLE OF ty_businesspartneraddres WITH EMPTY KEY,
             to_businesspartnertax     TYPE TABLE OF ty_businesspartnertax WITH EMPTY KEY,
             to_businesspartnerrole    TYPE TABLE OF ty_businesspartnerrole WITH EMPTY KEY,
             to_businesspartnerbank    TYPE TABLE OF ty_businesspartnerbank WITH EMPTY KEY,
             to_customer               TYPE ty_customer,
             to_supplier               TYPE ty_supplier,
           END OF ty_data.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.

    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii008_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI008 IMPLEMENTATION.


  METHOD inbound.

    DATA: ls_data  TYPE ty_data.
    DATA(ls_tmp) = i_req-data.


    CASE ls_tmp-doflag.
      WHEN 'I'.
        DATA:ls_businesspartneraddres TYPE ty_businesspartneraddres.
        "默认值------BEGIN-------
        "基础视图
        ls_data-businesspartner = ls_tmp-customer. "合作伙伴编码
        ls_data-businesspartnercategory = '2'. "业务伙伴类别
        ls_data-formofaddress = '0003'. "称谓
        ls_data-businesspartnergrouping = ls_tmp-customeraccountgroup. "业务伙伴分组
        ls_data-organizationbpname1 = ls_tmp-customername. "组织名称 1
        ls_data-searchterm1 = ls_tmp-sortfield. "搜索项 1
*        ls_data-businesspartnerisblocked = ls_tmp-deletionisblocked. "客户冻结

        "国家
        ls_businesspartneraddres-country  = ls_tmp-country.
        IF ls_businesspartneraddres-country IS INITIAL.
          ls_businesspartneraddres-country = 'CN'.
        ENDIF.

        "语言
        ls_businesspartneraddres-language = ls_tmp-language.
        IF ls_businesspartneraddres-language IS INITIAL.
          ls_businesspartneraddres-language = 'ZH'.
        ENDIF.
        "地址
        ls_businesspartneraddres-region = ls_tmp-region.
        ls_businesspartneraddres-streetname = ls_tmp-streetname.
        ls_businesspartneraddres-postalcode = ls_tmp-postalcode.
*    "邮箱
*    IF ls_req-emailaddress IS NOT INITIAL.
*      APPEND VALUE #(
*       emailaddress = ls_req-emailaddress
*      ) TO ls_businesspartneraddres-to_emailaddress.
*    ENDIF.
*    "电话
*        APPEND VALUE #(
*                        phonenumber = ls_req-taxrecordphone
*        ) TO ls_businesspartneraddres-to_phonenumber.
*
        APPEND ls_businesspartneraddres TO ls_data-to_businesspartneraddress.

        "税号
        IF ls_tmp-bptaxnumber IS NOT INITIAL.
          IF ls_tmp-bptaxtype IS INITIAL.
            ls_tmp-bptaxtype = 'CN5'.
          ENDIF.
          APPEND VALUE #(
                    bptaxtype       = ls_tmp-bptaxtype
                    bptaxlongnumber = ls_tmp-bptaxnumber
           ) TO ls_data-to_businesspartnertax.
        ENDIF.

        "角色
        APPEND VALUE #(
                businesspartnerrole       = 'FLCU00'
          ) TO ls_data-to_businesspartnerrole.
*        APPEND VALUE #(
*                businesspartnerrole       = 'FLCU01'
*          ) TO ls_data-to_businesspartnerrole.

        "银行视图
        IF ls_tmp-bankaccount IS NOT INITIAL.
          APPEND VALUE #(
                      bankidentification = '0001'      "标识
                      bankcountrykey = ls_tmp-bankcountrykey            "银行国家
                      banknumber = ls_tmp-banknumber   "银行代码
                      bankaccount = ls_tmp-bankaccount "银行账号
*                      bankaccountreferencetext = ls_tmp-bankaccountreferencetext "参考明细
           ) TO ls_data-to_businesspartnerbank.
        ENDIF.
*    "销售视图
*    SELECT salesorganization
*      FROM i_salesorganization WITH PRIVILEGED ACCESS
*      INTO TABLE @DATA(lt_salesorganization).
*    LOOP AT ls_req-salesview INTO DATA(ls_salesorganization).
*      APPEND VALUE #(
*              customeraccountgroup = 'CUST'           "客户科目组
*              salesorganization    = ls_salesorganization-salesorganization           "销售组织
*              distributionchannel  = '10'             "分销渠道
*              division             = '00'             "产品组
*              currency             = ls_salesorganization-currency            "货币
*              customeraccountassignmentgroup = ls_salesorganization-customeraccountassignmentgroup   "客户科目分配组
*              customerpaymentterms = '0001'           "客户付款条件
*              incotermsclassification = ls_salesorganization-incotermsclassification         "国际贸易条款
*              incotermslocation1   = ls_salesorganization-incotermslocation1                "国际贸易条款位置1
*              shippingcondition    = '01'             "装运条件
*              customerpricingprocedure = ls_salesorganization-customerpricingprocedure         "Cust.Pric.过程
**                  supplyingplant       = '1100'           "装运工厂
*              to_salesareatax = SWITCH #( ls_salesorganization-salesorganization
*                        WHEN '1210' THEN   VALUE #( ( departurecountry          = 'FR'
*                                                      customertaxcategory       = 'FTX1'
*                                                      customertaxclassification = '1'
*                                                    )
*                                                    ( departurecountry          = 'FR'
*                                                      customertaxcategory       = 'LCFR'
*                                                      customertaxclassification = '1'
*                                                    )
*                                                  )
*                         ELSE
*                                           VALUE #( ( departurecountry          = ls_salesorganization-departurecountry
*                                                      customertaxcategory       = ls_salesorganization-customertaxcategory
*                                                      customertaxclassification = ls_salesorganization-customertaxclassification
*                                                   ) )
*                        )
*
*
*
*
*              to_partnerfunction = VALUE #( ( partnerfunction = 'SP' )
*                                            ( partnerfunction = 'BP' )
*                                            ( partnerfunction = 'PY' )
*                                            ( partnerfunction = 'SH' )
*               )
*       ) TO ls_data-to_customer-to_customersalesarea.
*    ENDLOOP.

*        ls_data-to_customer-customeraccountgroup = ls_tmp-customeraccountgroup. "客户科目组

        "公司代码视图
        IF ls_tmp-companycode IS NOT INITIAL.
          APPEND VALUE #(
               companycode            = ls_tmp-companycode             "公司代码
               reconciliationaccount  = ls_tmp-reconciliationaccount     "统驭科目
               layoutsortingrule      = ls_tmp-layoutsortingrule
               paymentterms           = ls_tmp-paymentterms
               recordpaymenthistoryindicator  = ls_tmp-recordpaymenthistoryindicator
           ) TO ls_data-to_customer-to_customercompany.
        ENDIF.



        "默认值------END-------

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartner?sap-language=zh|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_data
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
        IF gs_http_resp-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  businesspartner TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = |公司代码GH00的客户{ ls_ress-d-businesspartner }已创建成功|.
          o_resp-sapnum = |{ ls_ress-d-businesspartner }|.


        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-sapnum = |{ ls_ress-d-businesspartner }|.
          LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
            o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
          ENDLOOP.

        ENDIF.

      WHEN 'U'.
        DATA: lv_component TYPE string VALUE 'businesspartner'.

        "基础视图
        READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner
        ALL FIELDS WITH VALUE #( (
            businesspartner = ls_tmp-customer
        ) ) RESULT DATA(partner).

        IF ls_tmp-customername IS NOT INITIAL
          OR ls_tmp-sortfield IS NOT INITIAL.
*          OR ls_tmp-language IS NOT INITIAL
*          OR ls_tmp-deletionisblocked IS NOT INITIAL.
          LOOP AT partner ASSIGNING FIELD-SYMBOL(<new_partner>).
            <new_partner>-%is_draft = if_abap_behv=>mk-off.

            IF ls_tmp-customername IS NOT INITIAL.
              <new_partner>-organizationbpname1 = ls_tmp-customername.
            ENDIF.

            IF ls_tmp-sortfield IS NOT INITIAL.
              <new_partner>-searchterm1 = ls_tmp-sortfield.
            ENDIF.

*            IF ls_tmp-language IS NOT INITIAL.
*              <new_partner>-language = ls_tmp-language.
*            ENDIF.

            MODIFY ENTITY PRIVILEGED i_businesspartnertp_3
           UPDATE FROM VALUE #( ( VALUE #(
            %data-organizationbpname1 = <new_partner>-organizationbpname1
            %data-searchterm1 = <new_partner>-searchterm1
*            %data-language = <new_partner>-language

            %control-organizationbpname1 = cl_abap_behv=>flag_changed
            %control-searchterm1 = cl_abap_behv=>flag_changed
*            %control-language = cl_abap_behv=>flag_changed

            %is_draft = if_abap_behv=>mk-off
            %tky = CORRESPONDING #( <new_partner>-%tky )
            ) ) ) REPORTED DATA(reported) FAILED DATA(failed).

            IF failed-businesspartner IS NOT INITIAL.
              DATA(lv_msg) = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
              o_resp-msgty = 'E'.
              o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
            ENDIF.

            EXIT.
          ENDLOOP.

*          COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*            FAILED DATA(failed_commit)
*            REPORTED DATA(reported_commit).
*          IF failed_commit IS NOT INITIAL.
*            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*            o_resp-msgty = 'E'.
*            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*          ENDIF.
        ENDIF.

        "地址
        IF ls_tmp-streetname IS NOT INITIAL
            OR ls_tmp-postalcode IS NOT INITIAL
*            OR ls_tmp-country IS NOT INITIAL
            OR ls_tmp-region IS NOT INITIAL.

          READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner BY \_businesspartneraddress
          ALL FIELDS WITH VALUE #( (
              %tky = partner[ 1 ]-%tky
           ) )
           RESULT DATA(curr_addr).

          LOOP AT curr_addr ASSIGNING FIELD-SYMBOL(<new_addr>).
            <new_addr>-%is_draft = if_abap_behv=>mk-off.

            IF ls_tmp-streetname IS NOT INITIAL.
              <new_addr>-streetname = ls_tmp-streetname.
            ENDIF.

            IF ls_tmp-postalcode IS NOT INITIAL.
              <new_addr>-postalcode = ls_tmp-postalcode.
            ENDIF.

*            IF ls_tmp-country IS NOT INITIAL.
*              <new_addr>-country = ls_tmp-country.
*            ENDIF.

            IF ls_tmp-region IS NOT INITIAL.
              <new_addr>-region = ls_tmp-region.
            ENDIF.

            MODIFY ENTITY PRIVILEGED i_businesspartneraddresstp_3
           UPDATE FROM VALUE #( ( VALUE #(
            %data-streetname = <new_addr>-streetname
            %data-postalcode = <new_addr>-postalcode
*            %data-country = <new_addr>-country
            %data-region = <new_addr>-region

            %control-streetname = cl_abap_behv=>flag_changed
            %control-postalcode = cl_abap_behv=>flag_changed
*            %control-country = cl_abap_behv=>flag_changed
            %control-region = cl_abap_behv=>flag_changed

            %is_draft = if_abap_behv=>mk-off
            %tky = CORRESPONDING #( <new_addr>-%tky )
            ) ) ) REPORTED reported FAILED failed.

            IF failed-buspartaddress IS NOT INITIAL.
              lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
              o_resp-msgty = 'E'.
              o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
            ENDIF.

          ENDLOOP.

*          COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*            FAILED failed_commit
*            REPORTED reported_commit.
*          IF failed_commit IS NOT INITIAL.
*            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*            o_resp-msgty = 'E'.
*            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*          ENDIF.
        ENDIF.

        "银行
        IF ls_tmp-banknumber IS NOT INITIAL
            OR ls_tmp-bankaccount IS NOT INITIAL.


          READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner BY \_businesspartnerbank
          ALL FIELDS WITH VALUE #( (
              %tky = partner[ 1 ]-%tky
           ) )
           RESULT DATA(curr_bank).
          LOOP AT curr_bank ASSIGNING FIELD-SYMBOL(<new_bank>).
            <new_bank>-%is_draft = if_abap_behv=>mk-off.

*            IF ls_tmp-bankcountrykey IS NOT INITIAL.
*              <new_bank>-bankcountrykey = ls_tmp-bankcountrykey.
*            ENDIF.

            IF ls_tmp-banknumber IS NOT INITIAL.
              <new_bank>-banknumber = ls_tmp-banknumber.
            ENDIF.

            IF ls_tmp-bankaccount IS NOT INITIAL.
              <new_bank>-bankaccount = ls_tmp-bankaccount.
            ENDIF.

            MODIFY ENTITY PRIVILEGED i_businesspartnerbanktp_3
           UPDATE FROM VALUE #( ( VALUE #(
*            %data-bankcountrykey = <new_bank>-bankcountrykey
            %data-banknumber = <new_bank>-banknumber
            %data-bankaccount = <new_bank>-bankaccount

*            %control-bankcountrykey = cl_abap_behv=>flag_changed
            %control-banknumber = cl_abap_behv=>flag_changed
            %control-bankaccount = cl_abap_behv=>flag_changed

            %is_draft = if_abap_behv=>mk-off
            %tky = CORRESPONDING #( <new_bank>-%tky )
            ) ) ) REPORTED reported FAILED failed.

            IF failed-businesspartnerbank IS NOT INITIAL.
              lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
              o_resp-msgty = 'E'.
              o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
            ENDIF.

          ENDLOOP.

*          COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*            FAILED failed_commit
*            REPORTED reported_commit.
*
*          IF failed_commit IS NOT INITIAL.
*            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*            o_resp-msgty = 'E'.
*            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*          ENDIF.
        ENDIF.

        "税号
        IF ls_tmp-bptaxnumber IS NOT INITIAL.


          READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner BY \_businesspartnertaxnumber
          ALL FIELDS WITH VALUE #( (
           %tky = partner[ 1 ]-%tky
           ) )
           RESULT DATA(curr_taxnum).
          LOOP AT curr_taxnum ASSIGNING FIELD-SYMBOL(<new_taxnum>).
            <new_taxnum>-%is_draft = if_abap_behv=>mk-off.

*            IF ls_tmp-bptaxtype IS NOT INITIAL.
*              <new_taxnum>-bptaxtype = ls_tmp-bptaxtype.
*            ENDIF.

            IF ls_tmp-bptaxnumber IS NOT INITIAL.
*              <new_taxnum>-bptaxnumber = ls_tmp-bptaxnumber.
              <new_taxnum>-bptaxlongnumber = ls_tmp-bptaxnumber.
            ENDIF.

            MODIFY ENTITY PRIVILEGED i_businesspartnertaxnumbertp_3
           UPDATE FROM VALUE #( ( VALUE #(
*            %data-bptaxtype = <new_taxnum>-bptaxtype
*            %data-bptaxnumber = <new_taxnum>-bptaxnumber
            %data-bptaxlongnumber = <new_taxnum>-bptaxlongnumber

*            %control-bptaxtype = cl_abap_behv=>flag_changed
*            %control-bptaxnumber = cl_abap_behv=>flag_changed
            %control-bptaxlongnumber = cl_abap_behv=>flag_changed

            %is_draft = if_abap_behv=>mk-off
            %tky = CORRESPONDING #( <new_taxnum>-%tky )
            ) ) ) REPORTED reported FAILED failed.

            IF failed-businesspartnertax IS NOT INITIAL.
              lv_component = 'businesspartner'.
              lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
              o_resp-msgty = 'E'.
              o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
            ENDIF.

            EXIT.
          ENDLOOP.

*          COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*            FAILED failed_commit
*            REPORTED reported_commit.
*          IF failed_commit IS NOT INITIAL.
*            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*            o_resp-msgty = 'E'.
*            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*          ENDIF.
        ENDIF.

        COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
            FAILED DATA(failed_commit)
            REPORTED DATA(reported_commit).
        IF failed_commit IS NOT INITIAL.
          lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
        ENDIF.

        IF ls_tmp-companycode IS NOT INITIAL.
          DATA: ls_companycode TYPE ty_customercompany.

          ls_companycode-layoutsortingrule = ls_tmp-layoutsortingrule.
          ls_companycode-paymentterms = ls_tmp-paymentterms.
          ls_companycode-reconciliationaccount = ls_tmp-reconciliationaccount.
          ls_companycode-recordpaymenthistoryindicator = ls_tmp-recordpaymenthistoryindicator.
          ls_companycode-physicalinventoryblockind = ls_tmp-deletionisblocked.

          IF ls_companycode IS NOT INITIAL.
            CLEAR: gs_http_req,gs_http_resp.
            gs_http_req-version = 'ODATAV2'.
            gs_http_req-method = 'PATCH'.
            gs_http_req-url = |/API_BUSINESS_PARTNER/A_CustomerCompany(Customer='{ ls_tmp-customer }',CompanyCode='{ ls_tmp-companycode }')?sap-language=zh|.
            "传入数据转JSON
            gs_http_req-body = /ui2/cl_json=>serialize(
                  data          = ls_companycode
                  compress      = abap_true
                  name_mappings = gt_mapping ).

            gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

            IF gs_http_resp-code <> '204'.

              /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                          CHANGING data  = ls_rese ).
              o_resp-msgty = 'E'.
              o_resp-sapnum = |{ ls_ress-d-businesspartner }|.
              LOOP AT ls_rese-error-innererror-errordetails INTO ls_errordetails WHERE severity = 'error'.
                o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
              ENDLOOP.

            ENDIF.
          ENDIF.
        ENDIF.

        IF o_resp-msgty <> 'E'.
          o_resp-msgty = 'S'.
          o_resp-msgtx = |公司代码GH00的客户{ ls_tmp-customer }已修改成功|.
        ENDIF.

*        "更新基本视图
*        CLEAR: ls_data.
*        ls_data-organizationbpname1 = ls_req-vendorname. "组织名称 1
*        ls_data-searchterm1 = ls_req-vendorsimplename. "搜索项 1
*
*        CLEAR: gs_http_req,gs_http_resp.
*        gs_http_req-version = 'ODATAV2'.
*        gs_http_req-method = 'PATCH'.
*        gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartner('{ lv_partner }')?sap-language={ gv_language }|.
*        "传入数据转JSON
*        gs_http_req-body = /ui2/cl_json=>serialize(
*              data          = ls_data
*              compress      = abap_true
*              name_mappings = gt_mapping ).
*
*        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
*
*        IF gs_http_resp-code = '204'.
*          o_resp-msgty  = 'S'.
*          o_resp-msgtx  = 'success'.
*        ELSE.
*          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
*                                      CHANGING data  = ls_rese ).
*          o_resp-msgty = 'E'.
*          o_resp-msgtx = ls_rese-error-message-value .
*        ENDIF.
*
*
*
*        CLEAR: ls_supplier.
*        ls_supplier-postingisblocked = ''.
*        ls_supplier-purchasingisblocked = ''.
*
*        CLEAR: gs_http_req,gs_http_resp.
*        gs_http_req-version = 'ODATAV2'.
*        gs_http_req-method = 'PATCH'.
*        gs_http_req-url = |/API_BUSINESS_PARTNER/A_Supplier('{ lv_partner }')?sap-language={ gv_language }|.
*        "传入数据转JSON
*        gs_http_req-body = /ui2/cl_json=>serialize(
*              data          = ls_supplier
*              compress      = abap_true
*              name_mappings = gt_mapping ).
*
*        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
*
*        IF gs_http_resp-code = '204'.
*          o_resp-msgty  = 'S'.
*          o_resp-msgtx  = 'success'.
*        ELSE.
*          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
*                                      CHANGING data  = ls_rese ).
*          o_resp-msgty = 'E'.
*          o_resp-msgtx = ls_rese-error-message-value .
*        ENDIF.

    ENDCASE.
  ENDMETHOD.


  METHOD constructor.
*&---导入结构JSON MAPPING
    gt_mapping = VALUE #(
         ( abap = 'BusinessPartner'                      json = 'BusinessPartner'              )
         ( abap = 'BusinessPartnerGrouping'              json = 'BusinessPartnerGrouping'      )
         ( abap = 'BusinessPartnerCategory'              json = 'BusinessPartnerCategory'      )
         ( abap = 'OrganizationBPName1'                  json = 'OrganizationBPName1'          )
         ( abap = 'SearchTerm1'                          json = 'SearchTerm1'                  )
         ( abap = 'FormOfAddress'                        json = 'FormOfAddress'                )
         ( abap = 'BusinessPartnerIsBlocked'             json = 'BusinessPartnerIsBlocked'     )

         ( abap = 'to_BusinessPartnerAddress'            json = 'to_BusinessPartnerAddress'    )
         ( abap = 'Country'                              json = 'Country'                      )
         ( abap = 'Language'                             json = 'Language'                     )
         ( abap = 'StreetName'                           json = 'StreetName'                   )
         ( abap = 'CityName'                             json = 'CityName'                     )
         ( abap = 'PostalCode'                           json = 'PostalCode'                   )
         ( abap = 'to_PhoneNumber'                       json = 'to_PhoneNumber'               )
         ( abap = 'PhoneNumber'                          json = 'PhoneNumber'                  )
         ( abap = 'to_EmailAddress'                      json = 'to_EmailAddress'              )
         ( abap = 'EmailAddress'                         json = 'EmailAddress'                 )
         ( abap = 'Region'                               json = 'Region'                       )

         ( abap = 'to_BusinessPartnerTax'                json = 'to_BusinessPartnerTax'        )
         ( abap = 'BPTaxType'                            json = 'BPTaxType'                    )
         ( abap = 'BPTaxLongNumber'                      json = 'BPTaxLongNumber'              )

         ( abap = 'to_BusinessPartnerRole'               json = 'to_BusinessPartnerRole'       )
         ( abap = 'BusinessPartnerRole'                  json = 'BusinessPartnerRole'          )

         ( abap = 'to_Customer'                          json = 'to_Customer'                  )
         ( abap = 'to_CustomerSalesArea'                 json = 'to_CustomerSalesArea'         )
         ( abap = 'SalesOrganization'                    json = 'SalesOrganization'            )
         ( abap = 'DistributionChannel'                  json = 'DistributionChannel'          )
         ( abap = 'Division'                             json = 'Division'                     )
         ( abap = 'Currency'                             json = 'Currency'                     )
         ( abap = 'CustomerAccountAssignmentGroup'       json = 'CustomerAccountAssignmentGroup'  )
         ( abap = 'CustomerPaymentTerms'                 json = 'CustomerPaymentTerms'         )
         ( abap = 'CustomerPricingProcedure'             json = 'CustomerPricingProcedure'     )
         ( abap = 'ShippingCondition'                    json = 'ShippingCondition'            )
         ( abap = 'SupplyingPlant'                       json = 'SupplyingPlant'               )
         ( abap = 'IncotermsClassification'              json = 'IncotermsClassification'      )
         ( abap = 'IncotermsLocation1'                   json = 'IncotermsLocation1'           )
         ( abap = 'CustomerAccountGroup'                 json = 'CustomerAccountGroup'         )

         ( abap = 'to_SalesAreaTax'                      json = 'to_SalesAreaTax'              )
         ( abap = 'DepartureCountry'                     json = 'DepartureCountry'             )
         ( abap = 'CustomerTaxCategory'                  json = 'CustomerTaxCategory'          )
         ( abap = 'CustomerTaxClassification'            json = 'CustomerTaxClassification'    )

         ( abap = 'to_Supplier'                          json = 'to_Supplier'                  )
         ( abap = 'Supplier'                             json = 'Supplier'                     )
         ( abap = 'PostingIsBlocked'                     json = 'PostingIsBlocked'             )
         ( abap = 'PurchasingIsBlocked'                  json = 'PurchasingIsBlocked'          )
         ( abap = 'to_SupplierCompany'                   json = 'to_SupplierCompany'           )
         ( abap = 'to_SupplierPurchasingOrg'             json = 'to_SupplierPurchasingOrg'     )

         ( abap = 'to_PartnerFunction'                   json = 'to_PartnerFunction'           )
         ( abap = 'PartnerFunction'                      json = 'PartnerFunction'              )
         ( abap = 'PartnerCounter'                       json = 'PartnerCounter'               )

         ( abap = 'to_CustomerCompany'                   json = 'to_CustomerCompany'           )
         ( abap = 'CompanyCode'                          json = 'CompanyCode'                  )
         ( abap = 'PaymentTerms'                         json = 'PaymentTerms'                 )
         ( abap = 'ReconciliationAccount'                json = 'ReconciliationAccount'        )
         ( abap = 'LayoutSortingRule'                    json = 'LayoutSortingRule'            )
         ( abap = 'RecordPaymentHistoryIndicator'        json = 'RecordPaymentHistoryIndicator' )
         ( abap = 'DeletionIndicator'                    json = 'DeletionIndicator' )
         ( abap = 'PhysicalInventoryBlockInd'            json = 'PhysicalInventoryBlockInd' )

         ( abap = 'to_BusinessPartnerBank'               json = 'to_BusinessPartnerBank'       )
         ( abap = 'BankIdentification'                   json = 'BankIdentification'           )
         ( abap = 'BankCountryKey'                       json = 'BankCountryKey'               )
         ( abap = 'BankNumber'                           json = 'BankNumber'                   )
         ( abap = 'BankAccount'                          json = 'BankAccount'                  )
         ( abap = 'BankAccountReferenceText'             json = 'BankAccountReferenceText'     )

    ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.
  ENDMETHOD.
ENDCLASS.
