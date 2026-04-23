CLASS zzcl_api_mm007 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES : BEGIN OF ty_businesspartnerbank,
              businesspartner          TYPE string,
              bankidentification       TYPE string,
              bankcountrykey           TYPE string,
              bankaccountname          TYPE string,
              banknumber               TYPE string,
              bankaccountholdername    TYPE string,
              bankaccount              TYPE string,
              bankaccountreferencetext TYPE string,
            END OF ty_businesspartnerbank.

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



CLASS ZZCL_API_MM007 IMPLEMENTATION.


  METHOD inbound.

    TYPES:BEGIN OF ty_entry,
            vendorcode   TYPE string,
            bankaccount  TYPE string,
            accountname  TYPE string,
            bankname     TYPE string,
            cnaps        TYPE string,
            defaultit    TYPE string,
            flag         TYPE string,
            sourcesystem TYPE string,
            sourceid     TYPE string,
            uuid         TYPE string,
          END OF ty_entry,

          BEGIN OF ty_interface,
            entry TYPE TABLE OF ty_entry WITH EMPTY KEY,
          END OF ty_interface.
    DATA: ls_interface TYPE ty_interface.
    DATA: lv_partner TYPE i_businesspartner-businesspartner.

    /ui2/cl_json=>deserialize( EXPORTING json        = i_req-data
                                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                              CHANGING  data        = ls_interface ).


    LOOP AT ls_interface-entry INTO DATA(ls_entry).
      DATA(ls_req) = ls_entry.

      APPEND INITIAL LINE TO o_resp-out ASSIGNING FIELD-SYMBOL(<fs_out>).
      <fs_out>-uuid = ls_req-uuid.

      lv_partner = ls_req-vendorcode.
      SELECT *
        FROM i_businesspartnerbank WITH PRIVILEGED ACCESS
       WHERE businesspartner = @lv_partner
        INTO TABLE @DATA(lt_bank).
      IF sy-subrc = 0.
        "先删除
        MODIFY ENTITIES OF i_businesspartnertp_3 PRIVILEGED
        ENTITY businesspartnerbank
        DELETE FROM VALUE #( FOR ls_bank IN lt_bank
                             ( %key-businesspartner = ls_bank-businesspartner
                               %key-bankidentification = ls_bank-bankidentification ) )
         REPORTED DATA(reported)
         FAILED DATA(failed).

        COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
        FAILED DATA(failed_commit)
        REPORTED DATA(reported_commit).
      ENDIF.

      "新增
      DATA: ls_businesspartnerbank TYPE ty_businesspartnerbank.
      ls_businesspartnerbank-bankaccountholdername = ls_req-accountname.
      ls_businesspartnerbank-bankaccountname = ls_req-bankname.
      ls_businesspartnerbank-banknumber = ls_req-cnaps.
      IF strlen( ls_req-bankaccount ) > 18.
        ls_businesspartnerbank-bankaccount = ls_req-bankaccount+0(18).
        ls_businesspartnerbank-bankaccountreferencetext = ls_req-bankaccount+18.
      ELSE.
        ls_businesspartnerbank-bankaccount = ls_req-bankaccount.
      ENDIF.

      ls_businesspartnerbank-bankidentification =  '1'.
      ls_businesspartnerbank-bankcountrykey =  'CN'.

      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'POST'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartner('{ lv_partner }')/to_BusinessPartnerBank?sap-language={ gv_language }|.
      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_businesspartnerbank
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

        <fs_out>-msgty  = 'S'.
        <fs_out>-msgtx  = 'success'.
        <fs_out>-sapnum = |{ ls_ress-d-businesspartner }|.


      ELSE.
        DATA:ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        <fs_out>-msgty = 'E'.
        <fs_out>-msgtx = ls_rese-error-message-value .

      ENDIF.

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
         ( abap = 'BankIdentification'          json = 'BankIdentification'      )
         ( abap = 'BankCountryKey'              json = 'BankCountryKey'      )
         ( abap = 'BankNumber'                  json = 'BankNumber'          )
         ( abap = 'BankControlKey'              json = 'BankControlKey'                  )
         ( abap = 'BankAccountHolderName'       json = 'BankAccountHolderName'                )
         ( abap = 'BankAccountName'             json = 'BankAccountName'     )
         ( abap = 'BankAccount'                 json = 'BankAccount'     )
         ( abap = 'BankAccountReferenceText'    json = 'BankAccountReferenceText'     )


    ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.
  ENDMETHOD.
ENDCLASS.
