CLASS zzcl_api_sd004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_control,
            defaultbillingdocumentdate    TYPE string,
            defaultbillingdocumenttype    TYPE string,
            autompostingtoacctgisdisabled TYPE abap_bool,
            cutoffbillingdocumentdate     TYPE string,
            yy1_fphm_bdh                  TYPE string,
            yy1_jsdh_bdh                  TYPE string,
          END OF ty_control,
          BEGIN OF ty_reference,
            sddocument          TYPE string,
            billingdocumenttype TYPE string,
            billingdocumentdate TYPE string,
            destinationcountry  TYPE string,
            salesorganization   TYPE string,
            sddocumentcategory  TYPE string,
          END OF ty_reference,
          BEGIN OF ty_data,
            _control   TYPE ty_control,
            _reference TYPE TABLE OF ty_reference WITH EMPTY KEY,
          END OF ty_data.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gs_tmp TYPE zzs_sdi004_in.
    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_sdi004_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_SD004 IMPLEMENTATION.


  METHOD inbound.

    DATA: lv_json TYPE string.
    DATA ls_data TYPE ty_data.
    DATA lv_billingdocument TYPE i_billingdocument-billingdocument.

    DATA(ls_tmp) = i_req-data.
    "抬头
    ls_data-_control-defaultbillingdocumentdate = ls_tmp-header-billingdocumentdate.
    ls_data-_control-defaultbillingdocumenttype = ls_tmp-header-billingdocumenttype.
    ls_data-_control-autompostingtoacctgisdisabled = ls_tmp-header-autompostingtoacctgisdisabled.

    "行项目
    LOOP AT ls_tmp-item INTO DATA(ls_item).
      APPEND VALUE #(
              sddocument = ls_item-sddocument
       ) TO ls_data-_reference.
    ENDLOOP.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV4'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/SAP__self.CreateFromSDDocument| &&
                        |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize( data          = ls_data
                                   compress      = abap_true
                                   name_mappings = gt_mapping ).

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '200'.
      TYPES:BEGIN OF ty_value,
              billingdocument TYPE string,
            END OF ty_value.
      TYPES: BEGIN OF ty_ress,
               value TYPE TABLE OF ty_value WITH EMPTY KEY,
             END OF  ty_ress.
      DATA ls_ress TYPE ty_ress.
      /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                                 CHANGING  data = ls_ress ).
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.
      o_resp-sapnum = ls_ress-value[ 1 ]-billingdocument.
      lv_billingdocument = ls_ress-value[ 1 ]-billingdocument.
    ELSE.
      DATA ls_rese TYPE zzs_odata4_fail.
      /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                                 CHANGING  data = ls_rese ).
      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-details INTO DATA(ls_details).
        o_resp-msgtx  = o_resp-msgtx  && ls_details-message.
      ENDLOOP.
      RETURN.
    ENDIF.

    "更新自定义字段
    CLEAR: gs_http_req,gs_http_resp.
    DATA: ls_head TYPE ty_control.
    ls_head-yy1_fphm_bdh =  ls_tmp-header-zfphm.
    ls_head-yy1_jsdh_bdh =  ls_tmp-header-zjsdh.
    gs_http_req-body = /ui2/cl_json=>serialize( data          = ls_head
                                   compress      = abap_true
                                   name_mappings = gt_mapping ).
    gs_http_req-version = 'ODATAV4'.
    gs_http_req-method = 'PATCH'.
    gs_http_req-url = |/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/{ lv_billingdocument }| &&
                  |?sap-language={ gv_language }|.
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).


    "过账
    IF ls_tmp-header-autompostingtoacctgisdisabled = abap_true.
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV4'.
      gs_http_req-method = 'POST'.
      "销售发票过账
      gs_http_req-etag = '*'.
      gs_http_req-url = |/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/{ lv_billingdocument }/SAP__self.PostToAccounting| &&
                          |?sap-language={ gv_language }|.

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
          ( abap = '_Control'                      json = '_Control' )
          ( abap = 'DefaultBillingDocumentDate'    json = 'DefaultBillingDocumentDate' )
          ( abap = 'DefaultBillingDocumentType'    json = 'DefaultBillingDocumentType' )
          ( abap = 'AutomPostingToAcctgIsDisabled' json = 'AutomPostingToAcctgIsDisabled' )
          ( abap = 'CutOffBillingDocumentDate'     json = 'CutOffBillingDocumentDate' )
          ( abap = 'YY1_FPHM_BDH'                  json = 'YY1_FPHM_BDH' )
          ( abap = 'YY1_JSDH_BDH'                  json = 'YY1_JSDH_BDH' )
          ( abap = '_Reference'                    json = '_Reference' )
          ( abap = 'SDDocument'                    json = 'SDDocument' )
          ( abap = 'BillingDocumentType'           json = 'BillingDocumentType' )
          ( abap = 'BillingDocumentDate'           json = 'BillingDocumentDate' )
          ( abap = 'DestinationCountry'            json = 'DestinationCountry' )
          ( abap = 'SalesOrganization'             json = 'SalesOrganization' )
          ( abap = 'SDDocumentCategory'            json = 'SDDocumentCategory' )

  ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.

  ENDMETHOD.
ENDCLASS.
