CLASS zzcl_api_sd005 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_emailaddress,
             emailaddress TYPE string,  "收票邮箱
           END OF ty_emailaddress,
           BEGIN OF ty_phonenumber,
             phonenumber TYPE string,   "收票手机号
           END OF ty_phonenumber,

           BEGIN OF ty_businesspartneraddres,
             country          TYPE string,  "国家
             language         TYPE string,  "语言
             streetname       TYPE string,  "地址1
             streetprefixname TYPE string,  "地址2
             streetsuffixname TYPE string,  "发票抬头
             to_phonenumber   TYPE TABLE OF ty_phonenumber WITH EMPTY KEY,
             to_emailaddress  TYPE TABLE OF ty_emailaddress WITH EMPTY KEY,
           END OF ty_businesspartneraddres,

           BEGIN OF ty_businesspartnertax,
             bptaxtype       TYPE string,   "税码
             bptaxlongnumber TYPE string,   "客户税号
           END OF ty_businesspartnertax,

           BEGIN OF ty_businesspartnerrole,
             businesspartnerrole TYPE string,   "业务角色
           END OF ty_businesspartnerrole,

           "新增成功后单独创建
           BEGIN OF ty_partnerfunction,
             partnerfunction  TYPE string,  "伙伴职能
             bpcustomernumber TYPE string,  "合作伙伴代码
           END OF ty_partnerfunction,

           BEGIN OF ty_salesareatax,
             departurecountry          TYPE string,     "启运国家/地区
             customertaxcategory       TYPE string,     "税收条件类型
             customertaxclassification TYPE string,     "税分类
           END OF ty_salesareatax,

           BEGIN OF ty_businesspartnerbank,
             bankcountrykey           TYPE string,  "国家
             banknumber               TYPE string,  "银行代码
             bankaccount              TYPE string,  "银行账户
             bankaccountreferencetext TYPE string,  "银行相关文本
           END OF ty_businesspartnerbank,

           BEGIN OF ty_customersalesarea,
             businesspartner                TYPE string,    "客户代码
             salesorganization              TYPE string,    "销售组织
             distributionchannel            TYPE string,    "分销渠道
             division                       TYPE string,    "产品组
             currency                       TYPE string,    "货币
             customeraccountassignmentgroup TYPE string,    "客户科目分配组
             incotermsclassification        TYPE string,    "国际贸易条款
             incotermslocation1             TYPE string,    "国贸条款位置
             customerpricingprocedure       TYPE string,    "客户定价过程
             slsdocisrlvtforproofofdeliv    TYPE abap_bool, "POD相关
             customerpaymentterms           TYPE string,    "付款条款
             to_salesareatax                TYPE TABLE OF ty_salesareatax WITH EMPTY KEY,
             to_partnerfunction             TYPE TABLE OF ty_partnerfunction WITH EMPTY KEY,
           END OF ty_customersalesarea,

           BEGIN OF ty_customercompany,
             companycode           TYPE string,     "公司代码
             paymentterms          TYPE string,     "付款条件
             reconciliationaccount TYPE string,     "统驭科目
           END OF ty_customercompany,

           BEGIN OF ty_customer,
             to_customersalesarea TYPE TABLE OF ty_customersalesarea WITH EMPTY KEY,
             to_customercompany   TYPE TABLE OF ty_customercompany WITH EMPTY KEY,
           END OF ty_customer,

           BEGIN OF ty_data,
             businesspartner           TYPE string,     "客户代码
             businesspartnergrouping   TYPE string,     "客户账户组
             businesspartnercategory   TYPE string,     "业务伙伴类别
             organizationbpname1       TYPE char40,     "名称1
             organizationbpname2       TYPE char40,     "名称2
             organizationbpname3       TYPE char40,     "名称3
             organizationbpname4       TYPE char40,     "名称4
             searchterm1               TYPE char20,     "搜索词1
             searchterm2               TYPE char20,     "搜索词2
             formofaddress             TYPE string,     "称谓
             businesspartnerisblocked  TYPE abap_bool,  "客户冻结
             to_businesspartneraddress TYPE TABLE OF ty_businesspartneraddres WITH EMPTY KEY,
             to_businesspartnertax     TYPE TABLE OF ty_businesspartnertax WITH EMPTY KEY,
             to_businesspartnerrole    TYPE TABLE OF ty_businesspartnerrole WITH EMPTY KEY,
             to_businesspartnerbank    TYPE TABLE OF ty_businesspartnerbank WITH EMPTY KEY,
             to_customer               TYPE ty_customer,
           END OF ty_data.

    TYPES: tty_customersalesarea TYPE TABLE OF ty_customersalesarea WITH EMPTY KEY.

    TYPES: BEGIN OF ty_function_delete,
             businesspartner     TYPE string,    "客户代码
             salesorganization   TYPE string,    "销售组织
             distributionchannel TYPE string,    "分销渠道
             division            TYPE string,    "产品组
             partnercounter      TYPE string,    "合作伙伴计数器
             partnerfunction     TYPE string,    "合作伙伴职能
           END OF ty_function_delete.

    TYPES: tty_function_delete TYPE TABLE OF ty_function_delete WITH EMPTY KEY.

    TYPES: BEGIN OF ty_phone,
             addressid   TYPE string,
             phonenumber TYPE string,
           END OF ty_phone.

    TYPES: BEGIN OF ty_email,
             addressid    TYPE string,
             emailaddress TYPE string,
           END OF ty_email.

    DATA: gt_mapping       TYPE /ui2/cl_json=>name_mappings.
    DATA: gs_http_req  TYPE zzs_http_req,
          gs_http_resp TYPE zzs_http_resp.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_sdi005_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS zzfunction
      IMPORTING
        i_req  TYPE tty_customersalesarea OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS zzfunction_delete
      IMPORTING
        i_req  TYPE tty_function_delete OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS zzphone
      IMPORTING
        i_req  TYPE ty_phone OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS zzemail
      IMPORTING
        i_req  TYPE ty_email OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_SD005 IMPLEMENTATION.


  METHOD inbound.

    DATA: lv_json TYPE string.
    DATA: ls_data TYPE ty_data.
    DATA: lv_flag TYPE abap_boolean.
    DATA: ls_businesspartneraddres TYPE ty_businesspartneraddres.
    DATA: lt_function TYPE tty_customersalesarea.
    DATA: lt_function_delete TYPE tty_function_delete.
    DATA: ls_resp TYPE zzs_rest_out.
    DATA: ls_phone TYPE ty_phone.
    DATA: ls_email TYPE ty_email.

    DATA(ls_req) = i_req-req.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

    SELECT COUNT(*)
      FROM i_businesspartner WITH PRIVILEGED ACCESS
     WHERE businesspartner = @ls_req-businesspartner.
    IF sy-subrc <> 0.

      "默认值------BEGIN-------
      "基础视图
      ls_data-businesspartner = ls_req-businesspartner. "客户代码
      ls_data-businesspartnercategory = '2'. "业务伙伴类别
      ls_data-businesspartnergrouping = ls_req-businesspartnergrouping. "客户账户组
      ls_data-formofaddress = '0003'. "称谓
      ls_data-organizationbpname1 = ls_req-organizationbpname1. "组织名称 1
      ls_data-organizationbpname2 = ls_req-organizationbpname2. "组织名称 2
      ls_data-organizationbpname3 = ls_req-organizationbpname3. "组织名称 3
      ls_data-organizationbpname4 = ls_req-organizationbpname4. "组织名称 4
      ls_data-searchterm1 = ls_req-searchterm1. "搜索项 1
      ls_data-searchterm2 = ls_req-searchterm2. "搜索项 2
      ls_data-businesspartnerisblocked = ls_req-businesspartnerisblocked. "客户冻结

      "国家
      ls_businesspartneraddres-country = ls_req-country.
      IF ls_businesspartneraddres-country IS INITIAL.
        ls_businesspartneraddres-country = 'CN'.
      ENDIF.

      "语言
      ls_businesspartneraddres-language = ls_req-language.
      IF ls_businesspartneraddres-language IS INITIAL.
        ls_businesspartneraddres-language = 'ZH'.
      ENDIF.
      "地址1
      ls_businesspartneraddres-streetname = ls_req-streetname.
      "地址2
      ls_businesspartneraddres-streetprefixname = ls_req-streetprefixname.
      "发票抬头
      ls_businesspartneraddres-streetsuffixname = ls_req-streetsuffixname.
      "邮箱
      IF ls_req-emailaddress IS NOT INITIAL.
        APPEND VALUE #( emailaddress = ls_req-emailaddress
                   ) TO ls_businesspartneraddres-to_emailaddress.
      ENDIF.
      "电话
      APPEND VALUE #( phonenumber = ls_req-phonenumber
                 ) TO ls_businesspartneraddres-to_phonenumber.

      APPEND ls_businesspartneraddres TO ls_data-to_businesspartneraddress.

      "税号
      IF ls_req-bptaxlongnumber IS NOT INITIAL.
        APPEND VALUE #( bptaxtype       = ls_req-bptaxtype
                        bptaxlongnumber = ls_req-bptaxlongnumber
                   ) TO ls_data-to_businesspartnertax.
      ENDIF.

      "业务角色
      APPEND VALUE #( businesspartnerrole = 'FLCU01' ) TO ls_data-to_businesspartnerrole.
      APPEND VALUE #( businesspartnerrole = 'FLCU00' ) TO ls_data-to_businesspartnerrole.

      "银行视图
      IF ls_req-bankaccount IS NOT INITIAL.
        APPEND VALUE #( bankcountrykey = ls_businesspartneraddres-country             "银行国家
                        banknumber     = ls_req-banknumber                            "银行代码
                        bankaccount    = ls_req-bankaccount                           "银行账号
                        bankaccountreferencetext = ls_req-bankaccountreferencetext    "参考明细
         ) TO ls_data-to_businesspartnerbank.
      ENDIF.

      "销售视图
      CLEAR: lt_function.
      LOOP AT ls_req-salesview INTO DATA(ls_salesorganization).
        APPEND VALUE #(
                salesorganization              = ls_salesorganization-salesorganization                "销售组织
                distributionchannel            = ls_salesorganization-distributionchannel              "分销渠道
                division                       = ls_salesorganization-division                         "产品组
                currency                       = ls_salesorganization-currency                         "货币
                customeraccountassignmentgroup = ls_salesorganization-customeraccountassignmentgroup   "客户科目分配组
                customerpaymentterms           = '0001'                                                "客户付款条件
                incotermsclassification        = ls_salesorganization-incotermsclassification          "国际贸易条款
                incotermslocation1             = ls_salesorganization-incotermslocation1               "国际贸易条款位置1
                customerpricingprocedure       = ls_salesorganization-customerpricingprocedure         "客户定价过程
                slsdocisrlvtforproofofdeliv    = abap_true                                             "POD相关
                to_salesareatax = VALUE #( ( departurecountry          = ls_salesorganization-departurecountry            "启运国家/地区
                                             customertaxcategory       = ls_salesorganization-customertaxcategory         "税收条件类型
                                             customertaxclassification = ls_salesorganization-customertaxclassification   "税分类
                                           ) )
         ) TO ls_data-to_customer-to_customersalesarea.

        IF ls_salesorganization-function IS NOT INITIAL.
          LOOP AT ls_salesorganization-function INTO DATA(ls_function).
            APPEND VALUE #( businesspartner     = ls_req-businesspartner                      "客户代码
                            salesorganization   = ls_salesorganization-salesorganization      "销售组织
                            distributionchannel = ls_salesorganization-distributionchannel    "分销渠道
                            division            = ls_salesorganization-division               "产品组
                            to_partnerfunction  = VALUE #( ( partnerfunction  = ls_function-partnerfunction    "伙伴职能
                                                             bpcustomernumber = ls_function-bpcustomernumber   "合作伙伴代码
                                                           ) )
            ) TO lt_function.
          ENDLOOP.
        ENDIF.

      ENDLOOP.

      "公司代码视图
      LOOP AT ls_req-companyview INTO DATA(ls_company).
        APPEND VALUE #(
             companycode            = ls_company-companycode               "公司代码
             paymentterms           = '0001'                               "付款条件
             reconciliationaccount  = ls_company-reconciliationaccount     "统驭科目
         ) TO ls_data-to_customer-to_customercompany.
      ENDLOOP.
      "默认值------END-------

*&---接口HTTP 链接调用
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_uri_path) = |/API_BUSINESS_PARTNER/A_BusinessPartner?sap-language=zh|.

          lv_uri_path = lv_uri_path .
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
          lo_http_client->set_csrf_token(  ).

          lo_request->set_content_type( 'application/json' ).
          "传入数据转JSON
          lv_json = /ui2/cl_json=>serialize(
                data          = ls_data
                compress      = abap_true
                name_mappings = gt_mapping ).

          lo_request->set_text( lv_json ).

*&---执行http post 方法
          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
          DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
          DATA(status) = lo_response->get_status( ).
          IF status-code = '201'.
            TYPES:BEGIN OF ty_heads,
                    businesspartner TYPE string,
                  END OF ty_heads,
                  BEGIN OF ty_ress,
                    d TYPE ty_heads,
                  END OF  ty_ress.
            DATA:ls_ress TYPE ty_ress.
            /ui2/cl_json=>deserialize( EXPORTING json = lv_res
                                       CHANGING  data = ls_ress ).

            o_resp-sapnum = ls_ress-d-businesspartner.

            IF lt_function IS NOT INITIAL.

              me->zzfunction(
                  EXPORTING
                      i_req  = lt_function
                  IMPORTING
                      o_resp = ls_resp
              ).

              IF ls_resp-msgty = 'S'.
                o_resp-msgty = ls_resp-msgty.
                o_resp-msgtx = ls_resp-msgtx.
              ELSE.
                o_resp-msgty = ls_resp-msgty.
                o_resp-msgtx = ls_resp-msgtx.
                o_resp-field1 = '业务伙伴创建成功，合作伙伴职能创建失败'.
              ENDIF.

            ENDIF.

          ELSE.
            DATA:ls_rese TYPE zzs_odata_fail.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_rese ).
            o_resp-msgty = 'E'.
            o_resp-sapnum = ls_req-businesspartner.
            LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
              o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
            ENDLOOP.

          ENDIF.

          lo_http_client->close( ).
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
          RETURN.
      ENDTRY.

    ELSE.

      DATA: lv_component TYPE string VALUE 'businesspartner'.

      "基础视图
      READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner
      ALL FIELDS WITH VALUE #( (
          businesspartner = ls_req-businesspartner
      ) ) RESULT DATA(partner).

      IF ls_req-organizationbpname1 IS NOT INITIAL
        OR ls_req-organizationbpname2 IS NOT INITIAL
        OR ls_req-organizationbpname3 IS NOT INITIAL
        OR ls_req-organizationbpname4 IS NOT INITIAL
        OR ls_req-searchterm1 IS NOT INITIAL
        OR ls_req-searchterm2 IS NOT INITIAL
        .
*          OR ls_tmp-language IS NOT INITIAL
*          OR ls_tmp-deletionisblocked IS NOT INITIAL.
        LOOP AT partner ASSIGNING FIELD-SYMBOL(<new_partner>).
          <new_partner>-%is_draft = if_abap_behv=>mk-off.

          IF ls_req-organizationbpname1 IS NOT INITIAL.
            <new_partner>-organizationbpname1 = ls_req-organizationbpname1.
          ENDIF.

          IF ls_req-organizationbpname2 IS NOT INITIAL.
            <new_partner>-organizationbpname2 = ls_req-organizationbpname2.
          ENDIF.

          IF ls_req-organizationbpname3 IS NOT INITIAL.
            <new_partner>-organizationbpname3 = ls_req-organizationbpname3.
          ENDIF.

          IF ls_req-organizationbpname4 IS NOT INITIAL.
            <new_partner>-organizationbpname4 = ls_req-organizationbpname4.
          ENDIF.

          IF ls_req-searchterm1 IS NOT INITIAL.
            <new_partner>-searchterm1 = ls_req-searchterm1.
          ENDIF.

          IF ls_req-searchterm2 IS NOT INITIAL.
            <new_partner>-searchterm2 = ls_req-searchterm2.
          ENDIF.

          MODIFY ENTITY PRIVILEGED i_businesspartnertp_3
         UPDATE FROM VALUE #( ( VALUE #(
          %data-organizationbpname1 = <new_partner>-organizationbpname1
          %data-organizationbpname2 = <new_partner>-organizationbpname2
          %data-organizationbpname3 = <new_partner>-organizationbpname3
          %data-organizationbpname4 = <new_partner>-organizationbpname4
          %data-searchterm1 = <new_partner>-searchterm1
          %data-searchterm2 = <new_partner>-searchterm2
*            %data-language = <new_partner>-language

          %control-organizationbpname1 = cl_abap_behv=>flag_changed
          %control-organizationbpname2 = cl_abap_behv=>flag_changed
          %control-organizationbpname3 = cl_abap_behv=>flag_changed
          %control-organizationbpname4 = cl_abap_behv=>flag_changed
          %control-searchterm1 = cl_abap_behv=>flag_changed
          %control-searchterm2 = cl_abap_behv=>flag_changed
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

*        COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*          FAILED DATA(failed_commit)
*          REPORTED DATA(reported_commit).
*        IF failed_commit IS NOT INITIAL.
*          lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*          o_resp-msgty = 'E'.
*          o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*        ENDIF.
      ENDIF.

      "地址
      IF ls_req-streetname IS NOT INITIAL
          OR ls_req-streetprefixname IS NOT INITIAL
          OR ls_req-streetsuffixname IS NOT INITIAL
          .

        CLEAR: reported, failed.
*               failed_commit, reported_commit.

        READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner BY \_businesspartneraddress
        ALL FIELDS WITH VALUE #( (
            %tky = partner[ 1 ]-%tky
         ) )
         RESULT DATA(curr_addr).

        LOOP AT curr_addr ASSIGNING FIELD-SYMBOL(<new_addr>).
          <new_addr>-%is_draft = if_abap_behv=>mk-off.

          IF ls_req-streetname IS NOT INITIAL.
            <new_addr>-streetname = ls_req-streetname.
          ENDIF.

          IF ls_req-streetprefixname IS NOT INITIAL.
            <new_addr>-streetprefixname = ls_req-streetprefixname.
          ENDIF.

          IF ls_req-streetsuffixname IS NOT INITIAL.
            <new_addr>-streetsuffixname = ls_req-streetsuffixname.
          ENDIF.

          MODIFY ENTITY PRIVILEGED i_businesspartneraddresstp_3
         UPDATE FROM VALUE #( ( VALUE #(
          %data-streetname = <new_addr>-streetname
          %data-streetprefixname = <new_addr>-streetprefixname
*            %data-country = <new_addr>-country
          %data-streetsuffixname = <new_addr>-streetsuffixname

          %control-streetname = cl_abap_behv=>flag_changed
          %control-streetprefixname = cl_abap_behv=>flag_changed
*            %control-country = cl_abap_behv=>flag_changed
          %control-streetsuffixname = cl_abap_behv=>flag_changed

          %is_draft = if_abap_behv=>mk-off
          %tky = CORRESPONDING #( <new_addr>-%tky )
          ) ) ) REPORTED DATA(reported_address) FAILED DATA(failed_address).

          IF failed-businesspartner IS NOT INITIAL.
            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
            o_resp-msgty = 'E'.
            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
          ENDIF.

        ENDLOOP.

*        COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*          FAILED DATA(failed_commit_address)
*          REPORTED DATA(reported_commit_address).
*        IF failed_commit IS NOT INITIAL.
*          lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*          o_resp-msgty = 'E'.
*          o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*        ENDIF.
      ENDIF.

      "银行
      IF ls_req-banknumber IS NOT INITIAL
          OR ls_req-bankaccount IS NOT INITIAL
          OR ls_req-bankaccountreferencetext IS NOT INITIAL
          .

        CLEAR: reported, failed.
*               failed_commit, reported_commit.

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

          IF ls_req-banknumber IS NOT INITIAL.
            <new_bank>-banknumber = ls_req-banknumber.
          ENDIF.

          IF ls_req-bankaccount IS NOT INITIAL.
            <new_bank>-bankaccount = ls_req-bankaccount.
          ENDIF.

          IF ls_req-bankaccountreferencetext IS NOT INITIAL.
            <new_bank>-bankaccountreferencetext = ls_req-bankaccountreferencetext.
          ENDIF.

          MODIFY ENTITY PRIVILEGED i_businesspartnerbanktp_3
         UPDATE FROM VALUE #( ( VALUE #(
*            %data-bankcountrykey = <new_bank>-bankcountrykey
          %data-banknumber = <new_bank>-banknumber
          %data-bankaccount = <new_bank>-bankaccount
          %data-bankaccountreferencetext = <new_bank>-bankaccountreferencetext

*            %control-bankcountrykey = cl_abap_behv=>flag_changed
          %control-banknumber = cl_abap_behv=>flag_changed
          %control-bankaccount = cl_abap_behv=>flag_changed
          %control-bankaccountreferencetext = cl_abap_behv=>flag_changed

          %is_draft = if_abap_behv=>mk-off
          %tky = CORRESPONDING #( <new_bank>-%tky )
          ) ) ) REPORTED reported FAILED failed.

          IF failed-businesspartner IS NOT INITIAL.
            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
            o_resp-msgty = 'E'.
            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
          ENDIF.

        ENDLOOP.

*        COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*          FAILED failed_commit
*          REPORTED reported_commit.
*
*        IF failed_commit IS NOT INITIAL.
*          lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*          o_resp-msgty = 'E'.
*          o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*        ENDIF.
      ENDIF.

      "税号
      IF ls_req-bptaxlongnumber IS NOT INITIAL.

        CLEAR: reported, failed.
*               failed_commit, reported_commit.

        READ ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY businesspartner BY \_businesspartnertaxnumber
        ALL FIELDS WITH VALUE #( (
         %tky = partner[ 1 ]-%tky
         ) )
         RESULT DATA(curr_taxnum).
        LOOP AT curr_taxnum ASSIGNING FIELD-SYMBOL(<new_taxnum>).
          <new_taxnum>-%is_draft = if_abap_behv=>mk-off.

          IF ls_req-bptaxlongnumber IS NOT INITIAL.
            <new_taxnum>-bptaxlongnumber = ls_req-bptaxlongnumber.
          ENDIF.

          MODIFY ENTITY PRIVILEGED i_businesspartnertaxnumbertp_3
         UPDATE FROM VALUE #( ( VALUE #(
          %data-bptaxlongnumber = <new_taxnum>-bptaxlongnumber

          %control-bptaxlongnumber = cl_abap_behv=>flag_changed

          %is_draft = if_abap_behv=>mk-off
          %tky = CORRESPONDING #( <new_taxnum>-%tky )
          ) ) ) REPORTED reported FAILED failed.

          IF failed-businesspartner IS NOT INITIAL.
            lv_component = 'businesspartner'.
            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = lv_component ).
            o_resp-msgty = 'E'.
            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
          ENDIF.

          EXIT.
        ENDLOOP.

*        COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
*          FAILED failed_commit
*          REPORTED reported_commit.
*        IF failed_commit IS NOT INITIAL.
*          lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
*          o_resp-msgty = 'E'.
*          o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*        ENDIF.
      ENDIF.

      "收票手机号
      IF ls_req-phonenumber IS NOT INITIAL.

        CLEAR: reported, failed.
*               failed_commit, reported_commit.

        SELECT SINGLE
               addressid
          FROM i_buspartaddress WITH PRIVILEGED ACCESS
         WHERE businesspartner = @ls_req-businesspartner
          INTO @DATA(lv_addressid).

        SELECT SINGLE
               addressid,
               addresspersonid,
               commmediumsequencenumber
          FROM i_addressphonenumber_2 WITH PRIVILEGED ACCESS
         WHERE addressid = @lv_addressid
          INTO @DATA(ls_phonenumber).
        IF sy-subrc = 0.
          "修改
          MODIFY ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY buspartphonenumber
              UPDATE
              FIELDS ( phonenumber )
              WITH VALUE #( ( phonenumber = ls_req-phonenumber
                  %tky-%is_draft = if_abap_behv=>mk-off
                  %tky-businesspartner = ls_req-businesspartner
                  %tky-addressnumber = ls_phonenumber-addressid
                  %tky-ordinalnumber = ls_phonenumber-commmediumsequencenumber
                  %tky-person = ls_phonenumber-addresspersonid
              ) )
              FAILED failed MAPPED DATA(mapped) REPORTED reported.
          IF failed IS NOT INITIAL.
            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = 'buspartphonenumber' ).
            o_resp-msgty = 'E'.
            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
          ENDIF.

*          COMMIT ENTITIES
*          RESPONSE OF i_businesspartnertp_3
*           FAILED failed_commit
*           REPORTED reported_commit.
*          IF failed_commit IS NOT INITIAL.
*            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = 'buspartphonenumber' ).
*            o_resp-msgty = 'E'.
*            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*          ENDIF.
        ELSE.
          "新建
          CLEAR: ls_phone, ls_resp.
          ls_phone-addressid = lv_addressid.
          ls_phone-phonenumber = ls_req-phonenumber.
          me->zzphone(
            EXPORTING
                i_req  = ls_phone
            IMPORTING
                o_resp = ls_resp
          ).

          IF ls_resp-msgty = 'E'.
            o_resp-msgty = ls_resp-msgty.
            o_resp-msgtx = o_resp-msgtx && '/' && ls_resp-msgtx.
          ENDIF.

        ENDIF.
      ENDIF.

      "收票邮箱
      IF ls_req-emailaddress IS NOT INITIAL.

        CLEAR: reported, failed, mapped.
*               failed_commit, reported_commit.

        SELECT SINGLE
                addressid
           FROM i_buspartaddress WITH PRIVILEGED ACCESS
          WHERE businesspartner = @ls_req-businesspartner
           INTO @lv_addressid.

        SELECT SINGLE
               addressid,
               addresspersonid,
               commmediumsequencenumber
          FROM i_addressemailaddress_2 WITH PRIVILEGED ACCESS
         WHERE addressid = @lv_addressid
          INTO @DATA(ls_emailaddress).
        IF sy-subrc = 0.
          "修改
          MODIFY ENTITIES OF i_businesspartnertp_3 PRIVILEGED ENTITY buspartemailaddress
              UPDATE
              FIELDS ( emailaddress )
              WITH VALUE #( ( emailaddress = ls_req-emailaddress
                  %tky-%is_draft = if_abap_behv=>mk-off
                  %tky-businesspartner = ls_req-businesspartner
                  %tky-addressnumber = ls_emailaddress-addressid
                  %tky-ordinalnumber = ls_emailaddress-commmediumsequencenumber
                  %tky-person = ls_emailaddress-addresspersonid
              ) )
              FAILED failed MAPPED mapped REPORTED reported.
          IF failed IS NOT INITIAL.
            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported iv_component = 'buspartemailaddress' ).
            o_resp-msgty = 'E'.
            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
          ENDIF.
*          COMMIT ENTITIES
*          RESPONSE OF i_businesspartnertp_3
*           FAILED failed_commit
*           REPORTED reported_commit.
*          IF failed_commit IS NOT INITIAL.
*            lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = 'buspartemailaddress' ).
*            o_resp-msgty = 'E'.
*            o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
*          ENDIF.

        ELSE.
          "新建
          CLEAR: ls_email, ls_resp.
          ls_email-addressid = lv_addressid.
          ls_email-emailaddress = ls_req-emailaddress.
          me->zzemail(
            EXPORTING
                i_req  = ls_email
            IMPORTING
                o_resp = ls_resp
          ).

          IF ls_resp-msgty = 'E'.
            o_resp-msgty = ls_resp-msgty.
            o_resp-msgtx = o_resp-msgtx && '/' && ls_resp-msgtx.
          ENDIF.

        ENDIF.
      ENDIF.

      COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
          FAILED DATA(failed_commit)
          REPORTED DATA(reported_commit).
      IF failed_commit IS NOT INITIAL.
        lv_msg = zzcl_comm_tool=>get_bo_msg( is_reported = reported_commit iv_component = lv_component ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx  && '/' && lv_msg.
      ENDIF.

      "合作伙伴职能
      FREE: lt_function, lt_function_delete.
      LOOP AT ls_req-salesview INTO ls_salesorganization.
        IF ls_salesorganization-function IS NOT INITIAL.
          "删除已有合作伙伴
          SELECT customer AS businesspartner,
                 salesorganization,
                 distributionchannel,
                 division,
                 partnercounter,
                 partnerfunction
            FROM i_custsalespartnerfunc WITH PRIVILEGED ACCESS
           WHERE customer = @ls_req-businesspartner
             AND salesorganization = @ls_salesorganization-salesorganization
             AND distributionchannel = @ls_salesorganization-distributionchannel
             AND division = @ls_salesorganization-division
             AND bpcustomernumber <> @ls_salesorganization-salesorganization
             APPENDING CORRESPONDING FIELDS OF TABLE @lt_function_delete.

          "新建合作伙伴
          LOOP AT ls_salesorganization-function INTO ls_function.
            APPEND VALUE #( businesspartner     = ls_req-businesspartner                      "客户代码
                            salesorganization   = ls_salesorganization-salesorganization      "销售组织
                            distributionchannel = ls_salesorganization-distributionchannel    "分销渠道
                            division            = ls_salesorganization-division               "产品组
                            to_partnerfunction  = VALUE #( ( partnerfunction  = ls_function-partnerfunction    "伙伴职能
                                                             bpcustomernumber = ls_function-bpcustomernumber   "合作伙伴代码
                                                           ) )
            ) TO lt_function.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

      IF lt_function_delete IS NOT INITIAL.
        CLEAR: ls_resp.
        me->zzfunction_delete(
            EXPORTING
                i_req  = lt_function_delete
            IMPORTING
                o_resp = ls_resp
        ).

        IF ls_resp-msgty = 'E'.
          o_resp-msgty = ls_resp-msgty.
          o_resp-msgtx = o_resp-msgtx && '/' && ls_resp-msgtx.
        ENDIF.
      ENDIF.

      IF lt_function IS NOT INITIAL.
        CLEAR: ls_resp.
        me->zzfunction(
            EXPORTING
                i_req  = lt_function
            IMPORTING
                o_resp = ls_resp
        ).

        IF ls_resp-msgty = 'E'.
          o_resp-msgty = ls_resp-msgty.
          o_resp-msgtx = o_resp-msgtx && '/' && ls_resp-msgtx.
        ENDIF.

      ENDIF.

      IF o_resp-msgty <> 'E'.
        o_resp-msgty = 'S'.
        o_resp-msgtx = |公司代码GH00的客户{ ls_req-businesspartner }已修改成功|.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD zzfunction.
    DATA: ls_function TYPE ty_partnerfunction.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    DATA: lv_json TYPE string.

    LOOP AT i_req INTO DATA(ls_req).
      LOOP AT ls_req-to_partnerfunction INTO DATA(ls_partnerfunction).
        CLEAR: ls_function, lv_json.

        ls_function = CORRESPONDING #( ls_partnerfunction ).

*&---接口http 链接调用
        TRY.
            DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
            DATA(lo_request) = lo_http_client->get_http_request(   ).
            lo_http_client->enable_path_prefix( ).
            DATA(lv_uri_path) = |/API_BUSINESS_PARTNER/A_CustomerSalesArea| &&
                                |(Customer='{ ls_req-businesspartner }',| &&
                                |SalesOrganization='{ ls_req-salesorganization }',| &&
                                |DistributionChannel='{ ls_req-distributionchannel }',| &&
                                |Division='{ ls_req-division }')| &&
                                |/to_PartnerFunction?sap-language=zh|.

            lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
            lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
            "lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
            lo_http_client->set_csrf_token(  ).

            lo_request->set_content_type( 'application/json' ).
            "传入数据转JSON
            lv_json = /ui2/cl_json=>serialize(
                  data          = ls_function
                  compress      = abap_true
                  name_mappings = gt_mapping ).

            lo_request->set_text( lv_json ).

*&---执行http post 方法
            DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
            DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
            DATA(status) = lo_response->get_status( ).
            IF status-code <> '201'.
              DATA:ls_rese TYPE zzs_odata_fail.
              /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                          CHANGING data  = ls_rese ).
              o_resp-msgty = 'E'.
              LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
                o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
              ENDLOOP.

            ENDIF.

            lo_http_client->close( ).
          CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
            RETURN.
        ENDTRY.
      ENDLOOP.
    ENDLOOP.

    IF o_resp-msgty <> 'E'.
      o_resp-msgty = 'S'.
      o_resp-msgtx  = 'success'.
    ENDIF.
  ENDMETHOD.


  METHOD zzfunction_delete.

    LOOP AT i_req INTO DATA(ls_req).
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'DELETE'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_CustSalesPartnerFunc| &&
                        |(Customer='{ ls_req-businesspartner }',| &&
                        |(SalesOrganization='{ ls_req-salesorganization }',| &&
                        |(DistributionChannel='{ ls_req-distributionchannel }',| &&
                        |(Division='{ ls_req-division }',| &&
                        |(PartnerCounter='{ ls_req-partnercounter }',| &&
                        |(PartnerFunction='{ ls_req-partnerfunction }')| &&
                        |?sap-language=zh|.
      "传入数据转JSON
      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code <> '204'.
        DATA: ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).

        o_resp-msgty = 'E'.
        LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails)  WHERE severity = 'error'.
          o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
        ENDLOOP.
        IF o_resp-msgtx IS INITIAL.
          o_resp-msgtx = o_resp-msgtx && '/' && ls_rese-error-message-value.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zzphone.
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/API_BUSINESS_PARTNER/A_AddressPhoneNumber?sap-language=zh|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize(
          data          = i_req
          compress      = abap_true
          name_mappings = gt_mapping ).

    "传入数据转JSON
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code <> '201'.
      DATA: ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).

      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
        o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
      ENDLOOP.
      IF o_resp-msgtx IS INITIAL.
        o_resp-msgtx = o_resp-msgtx && '/' && ls_rese-error-message-value.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zzemail.
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/API_BUSINESS_PARTNER/A_AddressEmailAddress?sap-language=zh|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize(
          data          = i_req
          compress      = abap_true
          name_mappings = gt_mapping ).

    "传入数据转JSON
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code <> '201'.
      DATA: ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).

      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-innererror-errordetails INTO DATA(ls_errordetails) WHERE severity = 'error'.
        o_resp-msgtx = o_resp-msgtx && '/' && ls_errordetails-message.
      ENDLOOP.
      IF o_resp-msgtx IS INITIAL.
        o_resp-msgtx = o_resp-msgtx && '/' && ls_rese-error-message-value.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
      ( abap = 'BusinessPartner'                      json = 'BusinessPartner'              )
      ( abap = 'BusinessPartnerGrouping'              json = 'BusinessPartnerGrouping'      )
      ( abap = 'BusinessPartnerCategory'              json = 'BusinessPartnerCategory'      )
      ( abap = 'OrganizationBPName1'                  json = 'OrganizationBPName1'          )
      ( abap = 'OrganizationBPName2'                  json = 'OrganizationBPName2'          )
      ( abap = 'OrganizationBPName3'                  json = 'OrganizationBPName3'          )
      ( abap = 'OrganizationBPName4'                  json = 'OrganizationBPName4'          )
      ( abap = 'SearchTerm1'                          json = 'SearchTerm1'                  )
      ( abap = 'SearchTerm2'                          json = 'SearchTerm2'                  )
      ( abap = 'FormOfAddress'                        json = 'FormOfAddress'                )
      ( abap = 'BusinessPartnerIsBlocked'             json = 'BusinessPartnerIsBlocked'     )

      ( abap = 'to_BusinessPartnerAddress'            json = 'to_BusinessPartnerAddress'    )
      ( abap = 'Country'                              json = 'Country'                      )
      ( abap = 'Language'                             json = 'Language'                     )
      ( abap = 'StreetName'                           json = 'StreetName'                   )
      ( abap = 'StreetPrefixName'                     json = 'StreetPrefixName'             )
      ( abap = 'StreetSuffixName'                     json = 'StreetSuffixName'             )
      ( abap = 'to_PhoneNumber'                       json = 'to_PhoneNumber'               )
      ( abap = 'PhoneNumber'                          json = 'PhoneNumber'                  )
      ( abap = 'AddressID'                            json = 'AddressID'                    )
      ( abap = 'to_EmailAddress'                      json = 'to_EmailAddress'              )
      ( abap = 'EmailAddress'                         json = 'EmailAddress'                 )

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
      ( abap = 'SlsDocIsRlvtForProofOfDeliv'          json = 'SlsDocIsRlvtForProofOfDeliv'  )

      ( abap = 'to_SalesAreaTax'                      json = 'to_SalesAreaTax'              )
      ( abap = 'DepartureCountry'                     json = 'DepartureCountry'             )
      ( abap = 'CustomerTaxCategory'                  json = 'CustomerTaxCategory'          )
      ( abap = 'CustomerTaxClassification'            json = 'CustomerTaxClassification'    )

      ( abap = 'to_PartnerFunction'                   json = 'to_PartnerFunction'           )
      ( abap = 'PartnerFunction'                      json = 'PartnerFunction'              )
      ( abap = 'PartnerCounter'                       json = 'PartnerCounter'               )
      ( abap = 'BPCustomerNumber'                     json = 'BPCustomerNumber'             )

      ( abap = 'to_CustomerCompany'                   json = 'to_CustomerCompany'           )
      ( abap = 'CompanyCode'                          json = 'CompanyCode'                  )
      ( abap = 'PaymentTerms'                         json = 'PaymentTerms'                 )
      ( abap = 'ReconciliationAccount'                json = 'ReconciliationAccount'        )
      ( abap = 'LayoutSortingRule'                    json = 'LayoutSortingRule'            )

      ( abap = 'to_BusinessPartnerBank'               json = 'to_BusinessPartnerBank'       )
      ( abap = 'BankIdentification'                   json = 'BankIdentification'           )
      ( abap = 'BankCountryKey'                       json = 'BankCountryKey'               )
      ( abap = 'BankNumber'                           json = 'BankNumber'                   )
      ( abap = 'BankAccount'                          json = 'BankAccount'                  )
      ( abap = 'BankAccountReferenceText'             json = 'BankAccountReferenceText'     )

    ).
  ENDMETHOD.
ENDCLASS.
