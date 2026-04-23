CLASS zzcl_api_mm008 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_phone,
            addressid                  TYPE string,
            person                     TYPE string,
            ordinalnumber              TYPE string,
            phonenumber                TYPE string,
            destinationlocationcountry TYPE string,
          END OF ty_phone,
          BEGIN OF tty_phone,
            results TYPE TABLE OF ty_phone WITH EMPTY KEY,
          END OF tty_phone.
    TYPES:BEGIN OF ty_email,
            addressid     TYPE string,
            person        TYPE string,
            ordinalnumber TYPE string,
            emailaddress  TYPE string,
          END OF ty_email,
          BEGIN OF tty_email,
            results TYPE TABLE OF ty_phone WITH EMPTY KEY,
          END OF tty_email.


    TYPES:BEGIN OF ty_entry,
            flag            TYPE string,
            uuid            TYPE string,
            vendorcode      TYPE string,
            contacts        TYPE string,
            contactsaddress TYPE string,
            contactsduties  TYPE string,
            phone           TYPE string,
            mobilephone     TYPE string,
            email           TYPE string,
            defaultit       TYPE string,
            sourceid        TYPE string,
          END OF ty_entry,

          BEGIN OF ty_interface,
            entry TYPE TABLE OF ty_entry WITH EMPTY KEY,
          END OF ty_interface.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.

    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    DATA: gs_entry TYPE ty_entry.
    DATA: gs_addressusage TYPE i_businesspartneraddressusage.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_rest_cpi OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi005_resp.

    METHODS process_phone
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS process_mobliephone
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS process_email
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_MM008 IMPLEMENTATION.


  METHOD inbound.

    DATA: ls_interface TYPE ty_interface.
    DATA: ls_out TYPE zzs_rest_out.

    DATA lv_partner TYPE i_businesspartner-businesspartner.

    /ui2/cl_json=>deserialize( EXPORTING json        = i_req-data
                                        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                              CHANGING  data        = ls_interface ).
    LOOP AT ls_interface-entry INTO gs_entry.

      APPEND INITIAL LINE TO o_resp-out ASSIGNING FIELD-SYMBOL(<fs_out>).
      <fs_out>-uuid = gs_entry-uuid.
      lv_partner = gs_entry-vendorcode.

      SELECT SINGLE *
        FROM i_businesspartneraddressusage WITH PRIVILEGED ACCESS AS a
       WHERE businesspartner = @lv_partner
         AND addressusage = 'XXDEFAULT'
        INTO @gs_addressusage.
      IF sy-subrc <> 0.
        <fs_out>-msgty =  'E'.
        <fs_out>-msgtx =  '供应商不存在'.
        RETURN.
      ENDIF.

      DATA: lt_u_address TYPE TABLE FOR UPDATE i_businesspartneraddresstp_3.
      APPEND INITIAL LINE TO lt_u_address ASSIGNING FIELD-SYMBOL(<fs_u_address>).
      <fs_u_address>-%is_draft = if_abap_behv=>mk-off.
      "主键
      <fs_u_address>-%key-businesspartner = gs_addressusage-businesspartner.
      <fs_u_address>-%key-addressnumber = gs_addressusage-addressnumber.

      IF gs_entry-contacts IS NOT INITIAL.
        <fs_u_address>-%data-floor = gs_entry-contacts.
        <fs_u_address>-%control-floor = cl_abap_behv=>flag_changed.
      ENDIF.
      IF gs_entry-contactsaddress IS NOT INITIAL.
        <fs_u_address>-%data-streetname = gs_entry-contactsaddress.
        <fs_u_address>-%control-streetname = cl_abap_behv=>flag_changed.
      ENDIF.

      "更改地址信息
      MODIFY ENTITY PRIVILEGED i_businesspartneraddresstp_3
      UPDATE FROM lt_u_address
      REPORTED DATA(reported_address)
      FAILED DATA(failed_address).

      IF failed_address IS NOT INITIAL.
        ls_out-msgty =  'E'.
        ls_out-msgtx =  '标准地址更新失败'.
      ENDIF.

      COMMIT ENTITIES RESPONSE OF i_businesspartnertp_3
      FAILED DATA(failed_caddress)
      REPORTED DATA(reported_caddress).

      "更改电话
      IF gs_entry-phone IS NOT INITIAL.
        ls_out =  me->process_phone( ).
      ENDIF.
      "更改移动电话
      IF gs_entry-mobilephone IS NOT INITIAL.
        ls_out =  me->process_mobliephone( ).
      ENDIF.
      "更改邮箱
      IF gs_entry-email IS NOT INITIAL.
        ls_out =  me->process_email( ).
      ENDIF.

      IF ls_out-msgty <>  'E'.
        ls_out-msgty =  'S'.
        ls_out-msgtx =  'Success'.
      ENDIF.

      <fs_out>-msgty = ls_out-msgty.
      <fs_out>-msgtx = ls_out-msgtx.

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
         ( abap = 'HouseNumber'                 json = 'HouseNumber'      )
         ( abap = 'StreetName'                  json = 'StreetName'       )
         ( abap = 'A_BusinessPartnerAddress'    json = 'A_BusinessPartnerAddress'       )
         ( abap = 'to_EmailAddress'             json = 'to_EmailAddress'       )
         ( abap = 'PhoneNumber'                 json = 'PhoneNumber'       )
         ( abap = 'EmailAddress'                json = 'EmailAddress'       )
         ( abap = 'MobilePhoneNumber'           json = 'MobilePhoneNumber'       )

    ).

    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.
  ENDMETHOD.


  METHOD process_email.
    DATA: ls_email TYPE ty_email.

    ls_email-emailaddress = gs_entry-email.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'GET'.
    gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartnerAddress| &&
                      |(BusinessPartner='{ gs_addressusage-businesspartner }',AddressID='{ gs_addressusage-addressnumber }')/to_EmailAddress|.

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    TYPES: BEGIN OF ty_ress,
             d TYPE tty_email,
           END OF  ty_ress.
    DATA ls_emailress TYPE ty_ress.
    /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                               CHANGING  data = ls_emailress ).
    IF ls_emailress-d-results IS NOT INITIAL.
      "更新
      READ TABLE ls_emailress-d-results INTO DATA(ls_email1) INDEX 1.
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'PATCH'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_AddressEmailAddress| &&
                        |(AddressID='{ ls_email1-addressid }',Person='{ ls_email1-person }',OrdinalNumber='{ ls_email1-ordinalnumber }')|.

      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_email
            compress      = abap_true
            name_mappings = gt_mapping ).

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '204'.

      ELSE.
        DATA:ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx && '邮箱更新失败：' && ls_rese-error-message-value .
      ENDIF.

    ELSE.
      "新建
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'POST'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartnerAddress| &&
                        |(BusinessPartner='{ gs_addressusage-businesspartner }',AddressID='{ gs_addressusage-addressnumber }')/to_EmailAddress|.
      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_email
            compress      = abap_true
            name_mappings = gt_mapping ).

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '201'.

      ELSE.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx && '邮箱更新失败：' && ls_rese-error-message-value .
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD process_mobliephone.
    DATA: ls_phone TYPE ty_phone.

    CLEAR: ls_phone.
    ls_phone-phonenumber = gs_entry-mobilephone.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'GET'.
    gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartnerAddress| &&
                      |(BusinessPartner='{ gs_addressusage-businesspartner }',AddressID='{ gs_addressusage-addressnumber }')/to_MobilePhoneNumber|.

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    TYPES: BEGIN OF ty_ress,
             d TYPE tty_phone,
           END OF  ty_ress.
    DATA ls_phoneress TYPE ty_ress.
    /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                               CHANGING  data = ls_phoneress ).
    IF ls_phoneress-d-results IS NOT INITIAL.
      "更新
      READ TABLE ls_phoneress-d-results INTO DATA(ls_phone1) INDEX 1.
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'PATCH'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_AddressPhoneNumber| &&
                        |(AddressID='{ ls_phone1-addressid }',Person='{ ls_phone1-person }',OrdinalNumber='{ ls_phone1-ordinalnumber }')|.

      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_phone
            compress      = abap_true
            name_mappings = gt_mapping ).

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '204'.

      ELSE.
        DATA:ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx && '移动电话更新失败：' && ls_rese-error-message-value .
      ENDIF.

    ELSE.
      "新建
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'POST'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartnerAddress| &&
                        |(BusinessPartner='{ gs_addressusage-businesspartner }',AddressID='{ gs_addressusage-addressnumber }')/to_MobilePhoneNumber|.
      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_phone
            compress      = abap_true
            name_mappings = gt_mapping ).

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '201'.

      ELSE.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx && '移动电话更新失败：' && ls_rese-error-message-value .
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD process_phone.
    DATA: ls_phone TYPE ty_phone.

    CLEAR: ls_phone.
    ls_phone-phonenumber = gs_entry-phone.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'GET'.
    gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartnerAddress| &&
                      |(BusinessPartner='{ gs_addressusage-businesspartner }',AddressID='{ gs_addressusage-addressnumber }')/to_PhoneNumber|.

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    TYPES: BEGIN OF ty_ress,
             d TYPE tty_phone,
           END OF  ty_ress.
    DATA ls_phoneress TYPE ty_ress.
    /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                               CHANGING  data = ls_phoneress ).
    IF ls_phoneress-d-results IS NOT INITIAL.
      "更新
      READ TABLE ls_phoneress-d-results INTO DATA(ls_phone1) INDEX 1.
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'PATCH'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_AddressPhoneNumber| &&
                        |(AddressID='{ ls_phone1-addressid }',Person='{ ls_phone1-person }',OrdinalNumber='{ ls_phone1-ordinalnumber }')|.

      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_phone
            compress      = abap_true
            name_mappings = gt_mapping ).

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '204'.

      ELSE.
        DATA:ls_rese TYPE zzs_odata_fail.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx && '电话更新失败：' && ls_rese-error-message-value .
      ENDIF.

    ELSE.
      "新建
      CLEAR: gs_http_req,gs_http_resp.
      gs_http_req-version = 'ODATAV2'.
      gs_http_req-method = 'POST'.
      gs_http_req-url = |/API_BUSINESS_PARTNER/A_BusinessPartnerAddress| &&
                        |(BusinessPartner='{ gs_addressusage-businesspartner }',AddressID='{ gs_addressusage-addressnumber }')/to_PhoneNumber|.
      "传入数据转JSON
      gs_http_req-body = /ui2/cl_json=>serialize(
            data          = ls_phone
            compress      = abap_true
            name_mappings = gt_mapping ).

      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

      IF gs_http_resp-code = '201'.

      ELSE.
        /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                    CHANGING data  = ls_rese ).
        o_resp-msgty = 'E'.
        o_resp-msgtx = o_resp-msgtx && '电话更新失败：' && ls_rese-error-message-value .
      ENDIF.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
