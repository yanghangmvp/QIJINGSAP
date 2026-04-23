CLASS lhc_zr_table_ztfi001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR fi001
        RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR fi001 RESULT result.

    METHODS zzpost FOR MODIFY
      IMPORTING keys FOR ACTION fi001~zzpost RESULT result.
    METHODS zzsend FOR MODIFY
      IMPORTING keys FOR ACTION fi001~zzsend RESULT result.
    METHODS zzcancel FOR MODIFY
      IMPORTING keys FOR ACTION fi001~zzcancel RESULT result.
    METHODS zztestpost FOR MODIFY
      IMPORTING keys FOR ACTION fi001~zztestpost RESULT result.
    METHODS zzrev FOR MODIFY
      IMPORTING keys FOR ACTION fi001~zzrev RESULT result.

ENDCLASS.

CLASS lhc_zr_table_ztfi001 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

    DATA: lv_auth(1).
    DATA: lv_abled_post TYPE abp_behv_op_ctrl.
    DATA: lv_abled_rev TYPE abp_behv_op_ctrl.
    DATA: lv_abled_dms TYPE abp_behv_op_ctrl.
    DATA: lv_abled_cancel TYPE abp_behv_op_ctrl.
    DATA: lv_disabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-disabled.
    DATA: lv_enabled TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.



    READ ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
    ENTITY fi001
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    TRY.
        DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
      CATCH cx_root INTO DATA(lr_root).
    ENDTRY.

    SELECT SINGLE i_user~userid,
           i_user~userdescription,
           addre~emailaddress
      FROM i_user WITH PRIVILEGED ACCESS
      JOIN i_addressemailaddress_2 WITH PRIVILEGED ACCESS AS addre
             ON i_user~addressid = addre~addressid AND  i_user~addresspersonid = addre~addresspersonid
     WHERE i_user~userid = @lv_user
     INTO @DATA(ls_user).
    ls_user-emailaddress = to_upper( ls_user-emailaddress  ).
    "获取权限表
    SELECT *
      FROM zztfi008
     WHERE zzuserid = @ls_user-emailaddress
      INTO TABLE @DATA(lt_008).
    SORT lt_008 BY datasource.
    READ TABLE lt_008 TRANSPORTING NO FIELDS WITH KEY datasource = '*' BINARY SEARCH.
    IF sy-subrc = 0.
      lv_auth = abap_true.
    ENDIF.

    LOOP AT results INTO DATA(ls_result).

      "已过账按钮不可编辑
      IF ls_result-flag = abap_true.
        lv_abled_post = lv_disabled.
        lv_abled_cancel = lv_disabled.
        lv_abled_rev = lv_enabled.
      ELSE.
        lv_abled_post = lv_enabled.
        lv_abled_cancel = lv_enabled.
        lv_abled_rev = lv_disabled.
      ENDIF.

      IF ls_result-datasource = 'A03'.
        lv_abled_dms = lv_enabled.
        IF ls_result-accountingdocument IS INITIAL.
          lv_abled_dms = lv_disabled.
        ELSE.
          IF ls_result-zztszt IS INITIAL.
            lv_abled_dms = lv_enabled.
          ELSE.
            lv_abled_dms = lv_disabled.
          ENDIF.
        ENDIF.
      ELSE.
        lv_abled_dms = lv_disabled.
      ENDIF.

      "权限校验
      IF lv_auth IS INITIAL.
        READ TABLE lt_008 TRANSPORTING NO FIELDS WITH KEY datasource = ls_result-datasource BINARY SEARCH.
        IF sy-subrc <> 0.
          lv_abled_post = lv_disabled.
          lv_abled_dms = lv_disabled.
          lv_abled_cancel = lv_disabled.
        ENDIF.
      ENDIF.


      APPEND VALUE #( %tky = ls_result-%tky
                      %action-zzrev = lv_abled_rev
                      %action-zzpost = lv_abled_post
                      %action-zzsend = lv_abled_dms
                      %action-zzcancel = lv_abled_cancel

                      )
      TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD zzpost.

    DATA: ls_out TYPE zzs_rest_out.
    DATA: ls_in TYPE zztfi001.

    "获取ui 界面实体数据内容
    READ  ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
    ENTITY fi001 ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    LOOP AT results ASSIGNING FIELD-SYMBOL(<fs_result>).

      CHECK  <fs_result>-flag IS INITIAL.
      CLEAR: ls_in,ls_out.
      ls_in-reference1indocumentheader = <fs_result>-reference1indocumentheader.
      ls_in-datasource = <fs_result>-datasource.

      ls_out = zzcl_api_fi001=>post( is_data = ls_in ).

      IF ls_out-msgty = 'S'.
        <fs_result>-accountingdocument = ls_out-sapnum+0(10).
        <fs_result>-fiscalyear = <fs_result>-postingdate+0(4).
        <fs_result>-msgty = ls_out-msgty.
        <fs_result>-msgtx = ls_out-msgtx.
        <fs_result>-flag = abap_true.
      ELSE.
        <fs_result>-msgty = ls_out-msgty.
        <fs_result>-msgtx = ls_out-msgtx.
      ENDIF.

    ENDLOOP.

    "会写前台界面
    result = VALUE #( FOR ls_tmp IN results ( %tky = ls_tmp-%tky
                                              %param    = ls_tmp
                                              )  ).

    " 更新数据实体把产生xsd 内容和对应字段更新到对应实体上
    MODIFY ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
        ENTITY fi001 UPDATE FIELDS ( accountingdocument fiscalyear msgty msgtx flag )
        WITH VALUE #( FOR ls_tmp IN results ( %tky        = ls_tmp-%tky
                                            accountingdocument   = ls_tmp-accountingdocument
                                            fiscalyear  = ls_tmp-fiscalyear
                                            msgty    = ls_tmp-msgty
                                            msgtx    = ls_tmp-msgtx
                                            flag    = ls_tmp-flag
                                             ) ).

  ENDMETHOD.

  METHOD zzsend.
    DATA: ls_out TYPE zzs_rest_out.
    DATA: ls_in TYPE zztfi001.
    "获取ui 界面实体数据内容
    READ  ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
    ENTITY fi001 ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    LOOP AT results ASSIGNING FIELD-SYMBOL(<fs_result>).
      CLEAR: ls_in.
      MOVE-CORRESPONDING <fs_result> TO ls_in.
      ls_out = zzcl_api_fi001=>push_dms( is_data = ls_in ).
      IF ls_out-msgty = 'S'.
        <fs_result>-zztszt = 'A'.
      ENDIF.
    ENDLOOP.

    "会写前台界面
    result = VALUE #( FOR ls_tmp IN results ( %tky = ls_tmp-%tky
                                              %param    = ls_tmp
                                              )  ).

    " 更新数据实体把产生xsd 内容和对应字段更新到对应实体上
    MODIFY ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
        ENTITY fi001 UPDATE FIELDS ( zztszt )
        WITH VALUE #( FOR ls_tmp IN results ( %tky        = ls_tmp-%tky
                                            zztszt   = ls_tmp-zztszt
                                             ) ).

  ENDMETHOD.


  METHOD zzcancel.
    "获取ui 界面实体数据内容
    READ  ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
  ENTITY fi001 ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(results).

    LOOP AT results ASSIGNING FIELD-SYMBOL(<fs_result>).


      DELETE FROM zztfi001 WHERE reference1indocumentheader = @<fs_result>-reference1indocumentheader
                             AND datasource = @<fs_result>-datasource.

      DELETE FROM zztfi002 WHERE reference1indocumentheader = @<fs_result>-reference1indocumentheader
                                AND datasource = @<fs_result>-datasource.

      IF <fs_result>-datasource = 'A03'.
        UPDATE zztfi007a SET status = '25'
                   WHERE recordid = @<fs_result>-reference1indocumentheader
                     AND unitno = @<fs_result>-companycode .
      ENDIF.
    ENDLOOP.

    "会写前台界面
*    result = VALUE #( FOR ls_tmp IN results ( %tky = ls_tmp-%tky
*                                              %param    = ls_tmp
*                                              )  ).

  ENDMETHOD.

  METHOD zztestpost.

    DATA: ls_out TYPE zzs_rest_out.
    DATA: ls_in TYPE zztfi001.

    "获取ui 界面实体数据内容
    READ  ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
    ENTITY fi001 ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

    LOOP AT results ASSIGNING FIELD-SYMBOL(<fs_result>).

      CHECK  <fs_result>-flag IS INITIAL.
      CLEAR: ls_in,ls_out.
      ls_in-reference1indocumentheader = <fs_result>-reference1indocumentheader.
      ls_in-datasource = <fs_result>-datasource.

      ls_out = zzcl_api_fi001=>post( is_data = ls_in
                                     iv_flag = abap_true ).

      <fs_result>-msgty = ls_out-msgty.
      <fs_result>-msgtx = ls_out-msgtx.

    ENDLOOP.

    "会写前台界面
    result = VALUE #( FOR ls_tmp IN results ( %tky = ls_tmp-%tky
                                              %param    = ls_tmp
                                              )  ).

    " 更新数据实体把产生xsd 内容和对应字段更新到对应实体上
    MODIFY ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
        ENTITY fi001 UPDATE FIELDS ( accountingdocument fiscalyear msgty msgtx flag )
        WITH VALUE #( FOR ls_tmp IN results ( %tky        = ls_tmp-%tky
                                            accountingdocument   = ls_tmp-accountingdocument
                                            fiscalyear  = ls_tmp-fiscalyear
                                            msgty    = ls_tmp-msgty
                                            msgtx    = ls_tmp-msgtx
                                            flag    = ls_tmp-flag
                                             ) ).

  ENDMETHOD.

  METHOD zzrev.
    DATA(request) = VALUE zjournal_entry_bulk_create_req( ).

    DATA ls_tab TYPE zjournal_entry_create_request.
    DATA ls_req TYPE zjournal_entry_create_reques18.
    DATA o_resp TYPE zzs_rest_out.
    "获取配置表数据
    SELECT SINGLE *
      FROM zzt_rest_sysid
     WHERE zztsysid = 'SELF'
      INTO @DATA(ls_zzt_rest_sysid).
    DATA(lv_username) = ls_zzt_rest_sysid-zzuser.
    DATA(lv_password) = ls_zzt_rest_sysid-zzpwd.
    DATA(lv_url) = ls_zzt_rest_sysid-zztkurl && ls_zzt_rest_sysid-zzurl && '/sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi?sap-language=zh'.
    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_url(  i_url =  lv_url ).
        destination->set_basic_authentication( i_user = CONV #( lv_username ) i_password = CONV #( lv_password ) ).
        DATA(proxy) = NEW zco_journal_entry_create_reque( destination = destination ).
      CATCH cx_root INTO DATA(lo_root).
    ENDTRY.

    "获取ui 界面实体数据内容
    READ ENTITIES OF zr_table_ztfi001 IN LOCAL MODE
    ENTITY fi001 ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).
    READ TABLE keys INTO DATA(key) INDEX 1.

    LOOP AT results ASSIGNING FIELD-SYMBOL(<fs_result>).
      CLEAR: request,ls_req,ls_tab,o_resp.
      ls_req-original_reference_document_ty = 'BKPFF'.
      ls_req-business_transaction_type = 'RFBU'.
      ls_req-accounting_document_type = 'DA'.
      ls_req-posting_date = key-%param-postingdate..
      ls_req-company_code = <fs_result>-companycode.
      ls_req-created_by_user = sy-uname.
      ls_req-reversal_reference_document = <fs_result>-accountingdocument && <fs_result>-companycode && <fs_result>-postingdate+0(4) .
      ls_req-reversal_date = key-%param-postingdate.
      ls_req-reversal_reason = key-%param-reversalreason.
      ls_tab-journal_entry = ls_req.
      APPEND ls_tab TO request-journal_entry_bulk_create_requ-journal_entry_create_request.

      GET TIME STAMP FIELD request-journal_entry_bulk_create_requ-message_header-creation_date_time.
      TRY.
          proxy->journal_entry_create_request_c(
            EXPORTING
              input = request
            IMPORTING
              output = DATA(response)
            ).
        CATCH cx_ai_system_fault INTO DATA(lo_fault).
          o_resp-msgty = 'E'.
          o_resp-msgtx = lo_fault->get_text( ).
          RETURN.
      ENDTRY.

      DATA(lv_accounting_document) = response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-journal_entry_create_confirmat-accounting_document.
      IF lv_accounting_document = '0000000000'.
        o_resp-msgty = 'E'.
        LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-log-item INTO DATA(ls_item_log).
          o_resp-msgtx = o_resp-msgtx && ls_item_log-note && '/'.
        ENDLOOP.

        APPEND VALUE #(
                 %tky = <fs_result>-%tky
                 %msg      = new_message_with_text(
                         severity  = if_abap_behv_message=>severity-information
                         text      =  o_resp-msgtx
                     )
          )  TO reported-fi001.

      ELSE.

        DELETE FROM zztfi001 WHERE reference1indocumentheader = @<fs_result>-reference1indocumentheader
                               AND datasource = @<fs_result>-datasource.

        IF <fs_result>-datasource = 'A03'.
          UPDATE zztfi007a SET status = '35',
                               accountingdocument  = '',
                               fiscalyear  = '',
                               postdata  = 00000000
                         WHERE recordid = @<fs_result>-reference1indocumentheader
                           AND unitno = @<fs_result>-companycode.
        ENDIF.
      ENDIF.



    ENDLOOP.
  ENDMETHOD.



ENDCLASS.
