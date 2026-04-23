CLASS zzcl_rest_api_pssc DEFINITION
  PUBLIC
  INHERITING FROM zzcl_rest_api
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS zzif_rest_api~restrans  REDEFINITION .
    METHODS outbound REDEFINITION .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_rest_api_pssc IMPLEMENTATION.
  METHOD outbound.
    DATA:lr_client TYPE REF TO if_web_http_client.
    DATA:lv_json   TYPE string.
    DATA:lv_token  TYPE string.
    DATA:ls_log TYPE zzt_rest_log,
         ls_out TYPE zzs_rest_out.

    lv_json = iv_data.

    IF iv_uuid IS INITIAL.
      TRY .
          DATA(lv_uuid_c32) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
          me->zzif_rest_api~ms_log-uuid = lv_uuid_c32.
        CATCH cx_uuid_error.
          IF 1 = 1 .
          ENDIF.
      ENDTRY.
    ELSE.
      me->zzif_rest_api~ms_log-uuid  = iv_uuid.
    ENDIF.

    ls_out-uuid     = me->zzif_rest_api~ms_log-uuid.
    ls_log-uuid     = me->zzif_rest_api~ms_log-uuid.
    ls_log-zznumb   = me->zzif_rest_api~ms_conf-zznumb.
    ls_log-zzname   = me->zzif_rest_api~ms_conf-zzname.
    ls_log-zzfsysid  = 'SAP'.
    ls_log-zztsysid  = me->zzif_rest_api~ms_conf-zztsysid.
    ls_log-zzrequest = /ui2/cl_json=>string_to_raw( EXPORTING iv_string   = lv_json ).
    ls_log-mimetype = 'application/xml'.
    ls_log-ernam   = sy-uname.
    GET TIME STAMP FIELD ls_log-btstmpl.
    me->zzif_rest_api~set_log( is_log = ls_log ).

    TRY.
        lr_client = cl_web_http_client_manager=>create_by_http_destination(
                    i_destination = cl_http_destination_provider=>create_by_url( i_url = CONV string( me->zzif_rest_api~ms_conf-zzurlc ) ) ).

        DATA(lo_request) = lr_client->get_http_request(   ).
        "设置请求内容格式
        lo_request->set_header_field( i_name =  'Content-type'
                                      i_value = 'application/xml' ).
        "设置请求体
        lo_request->set_text( i_text = lv_json ).

        DATA: lv_data TYPE string.
        DATA: lv_authorization TYPE string.
        DATA(lv_unix_timestamp) = xco_cp=>sy->unix_timestamp( )->value.
        TRY.
* create the signature with the key and the request string
            cl_abap_hmac=>calculate_hmac_for_char(
              EXPORTING
                if_algorithm           = 'SHA256'
                if_key                 = cl_abap_hmac=>string_to_xstring( CONV string( me->zzif_rest_api~ms_conf-zzpwd ) )
                if_data                = |date: { lv_unix_timestamp }|
              IMPORTING
                ef_hmacb64string       = DATA(signature)
            ).
          CATCH cx_abap_message_digest INTO DATA(lo_digest).
            DATA(lv_error_text) = lo_digest->if_message~get_text( ).
        ENDTRY.

        lv_authorization = |hmac username="{ me->zzif_rest_api~ms_conf-zzuser }",algorithm="HS256", headers="date", signature="{ signature }"|.
        lo_request->set_header_field( i_name  = 'date' i_value = CONV string( lv_unix_timestamp ) ).
        lo_request->set_header_field( i_name  = 'Authorization' i_value = lv_authorization ).

        "设置请求方式
        DATA(lo_response) = lr_client->execute( if_web_http_client=>post ).

        "返回HTTP JSON报文
        DATA(status) = lo_response->get_status( ).
        DATA(lv_res) = lo_response->get_text( ).

        ls_log-zzresponse =  /ui2/cl_json=>string_to_raw( EXPORTING iv_string   = lv_res ).

        ev_resp = lv_res.
        "返回消息转换
        me->zzif_rest_api~restrans(
         EXPORTING
            iv_json = lv_res
          CHANGING
             cv_msgty = ev_msgty
             cv_msgtx = ev_msgtx
             cs_log = ls_log
              ).
        "关闭连接
        CALL METHOD lr_client->close.
      CATCH cx_web_http_client_error cx_http_dest_provider_error.
        IF 1 = 1 .
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD zzif_rest_api~restrans.
    TYPES: BEGIN OF ty_entry,
             result  TYPE string,
             message TYPE string,
           END OF ty_entry.

    TYPES: BEGIN OF ty_msg,
             entry TYPE ty_entry,
           END OF ty_msg.

    DATA: ls_msg TYPE ty_msg.

    DATA: lv_cdata TYPE string.

    FIND FIRST OCCURRENCE OF REGEX |<!\\[CDATA\\[([^]]*)\\]\\]>|
      IN iv_json
      SUBMATCHES lv_cdata.

    TRY.
        CALL TRANSFORMATION zzt_xml
                 SOURCE XML lv_cdata
                     RESULT msg = ls_msg.
      CATCH cx_root INTO DATA(lr_root).
        IF 1 = 1.
        ENDIF.
    ENDTRY.

    cv_msgty = cs_log-msgty = ls_msg-entry-result.
    cv_msgtx = ls_msg-entry-message.

    GET TIME STAMP FIELD cs_log-rtstmpl.
    me->zzif_rest_api~set_log( is_log = cs_log ).
  ENDMETHOD.
ENDCLASS.
