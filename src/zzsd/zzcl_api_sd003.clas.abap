CLASS zzcl_api_sd003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_sdi003_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_sd003 IMPLEMENTATION.


  METHOD inbound.

    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_comm_arrangement(
         comm_scenario  = 'ZZHTTP_INBOUND_API'
         service_id     = 'ZZOS_SD_001_SPRX'
         comm_system_id = 'SELF'
       ).

*        DATA(destination) = cl_soap_destination_provider=>create_by_url(  i_url =  lv_url ).
*        destination->set_basic_authentication( i_user = CONV #( lv_username ) i_password = CONV #( lv_password ) ).
        DATA(proxy) = NEW zco_proof_of_delivery_request( destination = destination ).
        IF proxy IS NOT BOUND.
          o_resp-msgty = 'E'.
          o_resp-msgtx = '服务端口创建异常，请联系管理员!'.
          RETURN.
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_root->get_text( ).
    ENDTRY.

    DATA(request) = VALUE zproof_of_delivery_request( ).
    DATA(ls_tmp) = i_req-data.
    ls_tmp-deliverydocument = |{ ls_tmp-deliverydocument  ALPHA = IN }|.

    GET TIME STAMP FIELD  request-proof_of_delivery_request-message_header-creation_date_time.
    request-proof_of_delivery_request-proof_of_delivery-delivery_document = ls_tmp-deliverydocument."交货凭证编号
    request-proof_of_delivery_request-proof_of_delivery-proof_of_delivery_date = ls_tmp-proofofdeliverydate."交货证明的日期
    request-proof_of_delivery_request-proof_of_delivery-proof_of_delivery_time = ls_tmp-proofofdeliverytime."发送交货证明的时间

    "获取已创建的交货单
    SELECT deliverydocument,
           deliverydocumentitem,
           proofofdeliverystatus
      FROM i_deliverydocumentitem WITH PRIVILEGED ACCESS
     WHERE deliverydocument = @ls_tmp-deliverydocument
      INTO TABLE @DATA(lt_lips).
    SORT lt_lips BY deliverydocument deliverydocumentitem.
    IF sy-subrc <> 0.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '交货单不存在'.
      RETURN.

    ELSE.
      IF ls_tmp-item IS INITIAL.
        LOOP AT lt_lips INTO DATA(ls_lips).
          APPEND VALUE #( delivery_document_item =  ls_lips-deliverydocumentitem ) TO request-proof_of_delivery_request-proof_of_delivery-proof_of_delivery_item.
        ENDLOOP.
      ELSE.
        LOOP AT ls_tmp-item INTO DATA(ls_item).

          READ TABLE lt_lips INTO ls_lips WITH KEY deliverydocumentitem = ls_item-deliverydocumentitem BINARY SEARCH.
          IF  sy-subrc = 0.
            IF ls_lips-proofofdeliverystatus = 'C'.
              o_resp-msgty = 'E'.
              o_resp-msgtx = |行{ ls_item-deliverydocumentitem }已签收！|.
              RETURN.
            ENDIF.
          ELSE.
            o_resp-msgty = 'E'.
            o_resp-msgtx = |行{ ls_item-deliverydocumentitem }不存在！|.
            RETURN.
          ENDIF.

          APPEND VALUE #( delivery_document_item =  ls_item-deliverydocumentitem )
          TO request-proof_of_delivery_request-proof_of_delivery-proof_of_delivery_item.
        ENDLOOP.
      ENDIF.
    ENDIF.



    TRY.
        proxy->proof_of_delivery_request_in(
          EXPORTING
            input = request
        ).

        " trigger async call
        COMMIT WORK.
      CATCH cx_ai_system_fault INTO DATA(lr_fault).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lr_fault->get_text( ).
        RETURN.
    ENDTRY.

    o_resp-msgty = 'S'.
    o_resp-msgtx = 'POD成功'.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA: ls_req TYPE zzs_sdi003_req.
    DATA: ls_res TYPE zzs_rest_out.
    ls_req-data-deliverydocument = '8000000018'.
    ls_req-data-proofofdeliverydate = '20260227'.

    me->inbound( EXPORTING i_req = ls_req
                 IMPORTING o_resp =  ls_res  ).
  ENDMETHOD.
ENDCLASS.
