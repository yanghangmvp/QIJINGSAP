CLASS zzcl_yh_test001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_YH_TEST001 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DATA lt_table TYPE TABLE OF string.
*    DATA: lv_sql TYPE string,
*          o_resp TYPE zzs_rest_out.
*    APPEND  '12345'  TO lt_table.
*
*    lv_sql = concat_lines_of( table = lt_table sep = ','  ).
*
*    "推送数据
*    o_resp =  zzcl_jdbc_ta_process=>send_ta( lv_sql ).
    " UI URL of the current tenant.
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
    DATA(lo_ui_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).

    " The protocol of the UI URL (Type string).
    DATA(lv_ui_url_protocol) = lo_ui_url->get_protocol( ).

    " The host (including the domain) of the UI URL (Type string).
    DATA(lv_ui_url_host) = lo_ui_url->get_host( ).

    " The port of the UI URL (Type i).
    DATA(lv_ui_url_port) = lo_ui_url->get_port( ).

    DATA: lv_url TYPE string.
    lv_url = 'https://esbtest.qijingauto.com:30900/qijing/QJDMS/QJDMS_fundsAccount_048'.

    TYPES:BEGIN OF ty_token,
            access_token TYPE string,
          END OF ty_token.
    DATA:lr_client TYPE REF TO if_web_http_client.
    DATA:ls_token TYPE ty_token.
    TRY.
        lr_client = cl_web_http_client_manager=>create_by_http_destination(
                    i_destination = cl_http_destination_provider=>create_by_url( i_url = lv_url  ) ).

        DATA(lo_request) = lr_client->get_http_request(   ).
        "设置请求内容格式
        lo_request->set_header_field( i_name =  'Content-type'
                                      i_value = 'application/x-www-form-urlencoded' ).
        "设置请求内容
        lo_request->set_form_field( i_name = 'grant_type' i_value = 'client_credentials' ).


*        "设置验证方式
*        lo_request->set_authorization_basic(
*                        i_username = CONV string( 'b839bad729aa864caa188e7058e9662e0d92' )
*                        i_password = CONV string( '4e8351e575eab8422378b59d938b018c2c5c' ) ).

        "设置请求方式
        DATA(lo_response) = lr_client->execute( if_web_http_client=>post ).

        "返回HTTP JSON报文
        DATA(status) = lo_response->get_status( ).
        IF status-code = '200'.
          DATA(lv_res) = lo_response->get_text( ).
          /ui2/cl_json=>deserialize( EXPORTING json = lv_res CHANGING data = ls_token ).

        ENDIF.

        "关闭连接
        CALL METHOD lr_client->close.

      CATCH cx_root INTO DATA(lr_root).
        DATA(msg) = lr_root->get_longtext( ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
