CLASS zzcl_api_mm006 DEFINITION
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
             businesspartner     TYPE string,
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
             companycode               TYPE string,
             paymentterms              TYPE string,
             reconciliationaccount     TYPE string,
             layoutsortingrule         TYPE string,
             supplierclerkidbysupplier TYPE string,
             postingisblocked          TYPE string,
             isdoubleinvoice           TYPE string,
             paymentmethodslist        TYPE string,
           END OF ty_customercompany,

           BEGIN OF ty_customer,
             to_customersalesarea TYPE TABLE OF ty_customersalesarea WITH EMPTY KEY,
             to_customercompany   TYPE TABLE OF ty_customercompany WITH EMPTY KEY,
           END OF ty_customer,

           BEGIN OF ty_suppliercompany,
             supplier                   TYPE string,
             companycode                TYPE string,
             paymentterms               TYPE string,
             reconciliationaccount      TYPE string,
             layoutsortingrule          TYPE string,
             supplierclerkidbysupplier  TYPE string,
             postingisblocked           TYPE abap_bool,
             istobecheckedforduplicates TYPE abap_bool,
             paymentmethodslist         TYPE string,
           END OF ty_suppliercompany,
           BEGIN OF ty_supplierpurchasingorg,
             supplier                      TYPE string,
             purchasingorganization        TYPE string,
             purchaseordercurrency         TYPE string,
             paymentterms                  TYPE string,
             invoiceisgoodsreceiptbased    TYPE abap_bool,
             purchasingisblocked           TYPE abap_bool,
             purordautogenerationisallowed TYPE abap_bool,
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
        i_req  TYPE zzs_rest_cpi OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi005_resp.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM006 IMPLEMENTATION.


  METHOD inbound.

    TYPES:BEGIN OF ty_entry,
            flag              TYPE string,
            uuid              TYPE string,
            vendortype        TYPE string,
            vendorname        TYPE string,
            vendorsimplename  TYPE string,
            vendorcode        TYPE string,
            creditcode        TYPE string,
            dunsnumber        TYPE string,
            registeredaddress TYPE string,
            registereddate    TYPE string,
            registercatipal   TYPE string,
            legalbody         TYPE string,
            countrycode       TYPE string,
            province          TYPE string,
            city              TYPE string,
            district          TYPE string,
            postcode          TYPE string,
            shareholder       TYPE string,
            businessscope     TYPE string,
            taxrate           TYPE string,
            taxrecordbank     TYPE string,
            taxrecordaccount  TYPE string,
            taxrecordphone    TYPE string,
            vendrosource      TYPE string,
            vendorstatus      TYPE string,
            suptypeaion       TYPE string,
          END OF ty_entry.

    TYPES:BEGIN OF ty_req,
            entry TYPE TABLE OF ty_entry WITH EMPTY KEY,
          END OF ty_req.

    DATA: ls_data  TYPE ty_data.
    DATA: ls_out TYPE zzs_rest_out.
    DATA: ls_interface TYPE ty_req.
    DATA: ls_supplier  TYPE ty_supplier.
    DATA: lv_partner TYPE i_businesspartner-businesspartner.

    /ui2/cl_json=>deserialize( EXPORTING json        = i_req-data
                                          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                CHANGING  data        = ls_interface ).

    LOOP AT ls_interface-entry INTO DATA(ls_entry).

      DATA(ls_req) = ls_entry.
      CLEAR: ls_out.
      ls_out-uuid = ls_req-uuid.

      lv_partner = ls_req-vendorcode.

      SELECT SINGLE *
        FROM i_businesspartner WITH PRIVILEGED ACCESS
       WHERE businesspartner = @lv_partner
        INTO @DATA(ls_businesspartner).
      IF sy-subrc <> 0.
        ls_req-flag = '1'.
      ELSE.
        IF  ls_req-flag = '1'.
          ls_req-flag = '2'.
        ENDIF.
      ENDIF.

      CASE ls_req-flag.
        WHEN '1'.
          DATA:ls_businesspartneraddres TYPE ty_businesspartneraddres.
          "默认值------BEGIN-------
          "基础视图
          ls_data-businesspartner = ls_req-vendorcode. "合作伙伴编码
          ls_data-businesspartnercategory = '2'. "业务伙伴类别
          ls_data-formofaddress = '0003'. "称谓
          ls_data-businesspartnergrouping = 'Z002'. "业务伙伴分组
          ls_data-organizationbpname1 = ls_req-vendorname. "组织名称 1
          ls_data-searchterm1 = ls_req-vendorsimplename. "搜索项 1

          "国家
          SELECT SINGLE country
            FROM i_country
            WHERE countrythreeletterisocode =  @ls_req-countrycode
             INTO @ls_businesspartneraddres-country.
          IF ls_businesspartneraddres-country IS INITIAL.
            ls_businesspartneraddres-country = 'CN'.
          ENDIF.

          "语言
          IF ls_businesspartneraddres-language IS INITIAL.
            ls_businesspartneraddres-language = 'ZH'.
          ENDIF.
          "地址
          ls_businesspartneraddres-cityname = ls_req-city.
          ls_businesspartneraddres-streetname = ls_req-registeredaddress.
          ls_businesspartneraddres-postalcode = ls_req-postcode.
*    "邮箱
*    IF ls_req-emailaddress IS NOT INITIAL.
*      APPEND VALUE #(
*       emailaddress = ls_req-emailaddress
*      ) TO ls_businesspartneraddres-to_emailaddress.
*    ENDIF.
*    "电话
          APPEND VALUE #(
                          phonenumber = ls_req-taxrecordphone
          ) TO ls_businesspartneraddres-to_phonenumber.

          APPEND ls_businesspartneraddres TO ls_data-to_businesspartneraddress.

          "税号
          IF ls_req-creditcode IS NOT INITIAL.
            APPEND VALUE #(
                      bptaxtype       = 'CN5'
                      bptaxlongnumber = ls_req-creditcode
             ) TO ls_data-to_businesspartnertax.
          ENDIF.

          "角色
          APPEND VALUE #(
                  businesspartnerrole       = 'FLVN00'
            ) TO ls_data-to_businesspartnerrole.
          APPEND VALUE #(
                  businesspartnerrole       = 'FLVN01'
            ) TO ls_data-to_businesspartnerrole.

          "采购组织视图
          SELECT purchasingorganization
            FROM i_purchasingorganization WITH PRIVILEGED ACCESS
            INTO TABLE @DATA(lt_purchasingorg).
          LOOP AT lt_purchasingorg INTO DATA(ls_purchasingorg).
            APPEND VALUE #(
              purchasingorganization = ls_purchasingorg-purchasingorganization
              purchaseordercurrency = 'CNY'
              paymentterms = '0001'
              invoiceisgoodsreceiptbased = 'X'
              purchasingisblocked = ''
              purordautogenerationisallowed = 'X'
              ) TO ls_data-to_supplier-to_supplierpurchasingorg.
          ENDLOOP.

          "公司代码视图
          SELECT companycode
            FROM i_companycode WITH PRIVILEGED ACCESS
            INTO TABLE @DATA(lt_companycode).
          LOOP AT lt_companycode INTO DATA(ls_company).
            APPEND VALUE #(
                 companycode            = ls_company-companycode               "公司代码
                 paymentterms           = '0001'                               "付款条件
                 reconciliationaccount  = '2202020113'    "统驭科目
                 layoutsortingrule      = '012'
                 postingisblocked       = ''
                 istobecheckedforduplicates        = 'X'
                 paymentmethodslist     = 'T'
             ) TO ls_data-to_supplier-to_suppliercompany.
          ENDLOOP.
          "默认值------END-------

          CLEAR: gs_http_req,gs_http_resp.
          gs_http_req-version = 'ODATAV2'.
          gs_http_req-method = 'POST'.
          gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartner?sap-language={ gv_language }|.
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

            ls_out-msgty  = 'S'.
            ls_out-msgtx  = 'success'.
            ls_out-sapnum = |{ ls_ress-d-businesspartner }|.


          ELSE.
            DATA:ls_rese TYPE zzs_odata_fail.
            /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                        CHANGING data  = ls_rese ).
            ls_out-msgty = 'E'.
            ls_out-msgtx = ls_rese-error-message-value .

          ENDIF.

        WHEN '2'.

          SELECT SINGLE *
            FROM i_supplier WITH PRIVILEGED ACCESS AS a
           WHERE supplier = @lv_partner
            INTO @DATA(ls_tmp).
          "客户转供应商
          IF sy-subrc <> 0.
            "添加角色
            DATA: lt_role TYPE TABLE OF ty_businesspartnerrole.
            APPEND VALUE #( businesspartner = lv_partner   businesspartnerrole = 'FLVN00' ) TO lt_role.
            APPEND VALUE #( businesspartner = lv_partner   businesspartnerrole = 'FLVN01' ) TO lt_role.
            LOOP AT lt_role INTO DATA(ls_role).
              CLEAR: gs_http_req,gs_http_resp.
              gs_http_req-version = 'ODATAV2'.
              gs_http_req-method = 'POST'.
              gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartner('{ lv_partner }')/to_BusinessPartnerRole?sap-language={ gv_language }|.
              "传入数据转JSON
              gs_http_req-body = /ui2/cl_json=>serialize(
                    data          = ls_role
                    compress      = abap_true
                    name_mappings = gt_mapping ).

              gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
            ENDLOOP.

            "添加视图采购组织视图
            DATA: ls_supplierpurchasingorg TYPE ty_supplierpurchasingorg.
            SELECT purchasingorganization
              FROM i_purchasingorganization WITH PRIVILEGED ACCESS
              INTO TABLE @lt_purchasingorg.
            LOOP AT lt_purchasingorg INTO ls_purchasingorg.
              CLEAR: ls_supplierpurchasingorg.
              ls_supplierpurchasingorg = VALUE #(
                purchasingorganization = ls_purchasingorg-purchasingorganization
                purchaseordercurrency = 'CNY'
                paymentterms = '0001'
                invoiceisgoodsreceiptbased = 'X'
                purchasingisblocked = ''
                purordautogenerationisallowed = 'X'
                ) .

              CLEAR: gs_http_req,gs_http_resp.
              gs_http_req-version = 'ODATAV2'.
              gs_http_req-method = 'POST'.
              gs_http_req-url = |/API_BUSINESS_PARTNER/A_Supplier('{ lv_partner }')/to_SupplierPurchasingOrg?sap-language={ gv_language }|.
              "传入数据转JSON
              gs_http_req-body = /ui2/cl_json=>serialize(
                    data          = ls_supplierpurchasingorg
                    compress      = abap_true
                    name_mappings = gt_mapping ).

              gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
            ENDLOOP.

            "添加公司代码视图
            "公司代码视图
            DATA: ls_suppliercompany TYPE ty_suppliercompany.
            SELECT companycode
              FROM i_companycode WITH PRIVILEGED ACCESS
              INTO TABLE @lt_companycode.
            LOOP AT lt_companycode INTO ls_company.
              CLEAR: ls_suppliercompany.
              ls_suppliercompany =  VALUE #(
                   companycode            = ls_company-companycode               "公司代码
                   paymentterms           = '0001'                               "付款条件
                   reconciliationaccount  = '2202020113'    "统驭科目
                   layoutsortingrule      = '012'
                   postingisblocked       = ''
                   istobecheckedforduplicates        = 'X'
                   paymentmethodslist     = 'T'
               ).

              CLEAR: gs_http_req,gs_http_resp.
              gs_http_req-version = 'ODATAV2'.
              gs_http_req-method = 'POST'.
              gs_http_req-url = |/API_BUSINESS_PARTNER/A_Supplier('{ lv_partner }')/to_SupplierCompany?sap-language={ gv_language }|.
              "传入数据转JSON
              gs_http_req-body = /ui2/cl_json=>serialize(
                    data          = ls_suppliercompany
                    compress      = abap_true
                    name_mappings = gt_mapping ).

              gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
            ENDLOOP.
          ENDIF.

          "更新基本视图
          CLEAR: ls_data.
          ls_data-organizationbpname1 = ls_req-vendorname. "组织名称 1
          ls_data-searchterm1 = ls_req-vendorsimplename. "搜索项 1

          CLEAR: gs_http_req,gs_http_resp.
          gs_http_req-version = 'ODATAV2'.
          gs_http_req-method = 'PATCH'.
          gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartner('{ lv_partner }')?sap-language={ gv_language }|.
          "传入数据转JSON
          gs_http_req-body = /ui2/cl_json=>serialize(
                data          = ls_data
                compress      = abap_true
                name_mappings = gt_mapping ).

          gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

          IF gs_http_resp-code = '204'.
            ls_out-msgty  = 'S'.
            ls_out-msgtx  = 'success'.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                        CHANGING data  = ls_rese ).
            ls_out-msgty = 'E'.
            ls_out-msgtx = ls_rese-error-message-value .
          ENDIF.



          CLEAR: ls_supplier.
          ls_supplier-postingisblocked = abap_undefined.
          ls_supplier-purchasingisblocked = abap_undefined.

          CLEAR: gs_http_req,gs_http_resp.
          gs_http_req-version = 'ODATAV2'.
          gs_http_req-method = 'PATCH'.
          gs_http_req-url = |/API_BUSINESS_PARTNER/A_Supplier('{ lv_partner }')?sap-language={ gv_language }|.
          "传入数据转JSON
          gs_http_req-body = /ui2/cl_json=>serialize(
                data          = ls_supplier
                compress      = abap_true
                name_mappings = gt_mapping ).

          gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

          IF gs_http_resp-code = '204'.
            ls_out-msgty  = 'S'.
            ls_out-msgtx  = 'success'.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                        CHANGING data  = ls_rese ).
            ls_out-msgty = 'E'.
            ls_out-msgtx = ls_rese-error-message-value .
          ENDIF.

        WHEN '3'.

          CLEAR: ls_supplier.
          ls_supplier-postingisblocked = abap_true.
          ls_supplier-purchasingisblocked = abap_true.

          CLEAR: gs_http_req,gs_http_resp.
          gs_http_req-version = 'ODATAV2'.
          gs_http_req-method = 'PATCH'.
          gs_http_req-url = |/API_BUSINESS_PARTNER/A_Supplier('{ lv_partner }')?sap-language={ gv_language }|.
          "传入数据转JSON
          gs_http_req-body = /ui2/cl_json=>serialize(
                data          = ls_supplier
                compress      = abap_true
                name_mappings = gt_mapping ).

          gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

          IF gs_http_resp-code = '204'.
            ls_out-msgty  = 'S'.
            ls_out-msgtx  = 'success'.
          ELSE.
            /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                        CHANGING data  = ls_rese ).
            ls_out-msgty = 'E'.
            ls_out-msgtx = ls_rese-error-message-value .
          ENDIF.

      ENDCASE.

      APPEND ls_out TO o_resp-out.
    ENDLOOP.

    IF line_exists( o_resp-out[ msgty = 'E' ] ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = '存在失败数据'.
    ELSE.
      o_resp-msgty = 'S'.
      o_resp-msgtx = 'success'.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
*&---导入结构JSON MAPPING
    gt_mapping = VALUE #(
         ( abap = 'BusinessPartner'                      json = 'BusinessPartner'      )
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
         ( abap = 'CityName'                             json = 'CityName'                   )
         ( abap = 'PostalCode'                           json = 'PostalCode'                   )
         ( abap = 'to_PhoneNumber'                       json = 'to_PhoneNumber'               )
         ( abap = 'PhoneNumber'                          json = 'PhoneNumber'                  )
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
         ( abap = 'PaymentMethodsList'                   json = 'PaymentMethodsList'            )
         ( abap = 'IsToBeCheckedForDuplicates'           json = 'IsToBeCheckedForDuplicates'     )
         ( abap = 'PurchasingOrganization'               json = 'PurchasingOrganization'        )
         ( abap = 'PurchaseOrderCurrency'                json = 'PurchaseOrderCurrency'         )
         ( abap = 'InvoiceIsGoodsReceiptBased'           json = 'InvoiceIsGoodsReceiptBased'    )
         ( abap = 'PurOrdAutoGenerationIsAllowed'        json = 'PurOrdAutoGenerationIsAllowed' )
    ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.

  ENDMETHOD.
ENDCLASS.
