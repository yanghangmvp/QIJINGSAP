CLASS zzcl_api_fi001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: gs_data TYPE zzs_fii001_in.

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii001_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS check_data
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    CLASS-METHODS  post
      IMPORTING
        is_data       TYPE zztfi001 OPTIONAL
        iv_flag       TYPE abap_boolean OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    CLASS-METHODS  push_dms
      IMPORTING
        is_data       TYPE zztfi001 OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_fi001 IMPLEMENTATION.


  METHOD inbound.

    DATA:lt_zztfi001 TYPE TABLE OF zztfi001,
         ls_zztfi001 TYPE zztfi001,
         lt_zztfi002 TYPE TABLE OF zztfi002,
         ls_zztfi002 TYPE zztfi002.

    gs_data = i_req-data.

    "数据校验
    o_resp = me->check_data( ).
    CHECK o_resp-msgty <> 'E'.


    DATA lv_numc(20).
    TRY.
        CALL METHOD cl_numberrange_runtime=>number_get
          EXPORTING
            nr_range_nr = '01'
            object      = 'ZZNROFI001'
          IMPORTING
            number      = DATA(lv_number)
            returncode  = DATA(lv_rcode).

        lv_numc = lv_number.
        lv_numc = |{ lv_numc ALPHA = OUT }|.
      CATCH cx_root INTO DATA(lr_root).
    ENDTRY.

    CLEAR: ls_zztfi001.
    MOVE-CORRESPONDING gs_data-header TO ls_zztfi001.
    GET TIME STAMP FIELD ls_zztfi001-created_at.
    ls_zztfi001-created_by = sy-uname.
    ls_zztfi001-virtualnum = lv_numc.

    DELETE FROM zztfi001 WHERE reference1indocumentheader = @ls_zztfi001-reference1indocumentheader
                           AND datasource = @ls_zztfi001-datasource.
    DELETE FROM zztfi002 WHERE reference1indocumentheader = @ls_zztfi001-reference1indocumentheader
                           AND datasource = @ls_zztfi001-datasource.


    SELECT *
       FROM zztfi003
       INTO TABLE @DATA(lt_zztfi003).
    SORT lt_zztfi003 BY krzky.

    LOOP AT gs_data-item INTO DATA(ls_item).
      CLEAR: ls_zztfi002.
      MOVE-CORRESPONDING ls_item TO ls_zztfi002.
      GET TIME STAMP FIELD ls_zztfi002-created_at.
      ls_zztfi002-created_by = sy-uname.

      ls_zztfi002-reference1indocumentheader = ls_zztfi001-reference1indocumentheader.
      ls_zztfi002-datasource = ls_zztfi001-datasource.
      ls_zztfi002-accountingdocumentitem =  ls_item-referencedocumentitem.

      IF ls_item-specialglcode IS NOT INITIAL AND ls_item-altvrecnclnaccts IS INITIAL.
        READ TABLE lt_zztfi003 INTO DATA(ls_zztfi003) WITH KEY krzky = ls_item-specialglcode BINARY SEARCH.
        IF sy-subrc = 0.
          ls_zztfi002-altvrecnclnaccts = ls_zztfi003-zzkhont_bx.
        ENDIF.
      ENDIF.

      APPEND ls_zztfi002 TO lt_zztfi002.
    ENDLOOP.

    MODIFY zztfi001 FROM @ls_zztfi001.
    MODIFY zztfi002 FROM TABLE @lt_zztfi002.

    o_resp-msgty = 'S'.
    o_resp-msgtx = '数据接收成功'.

    o_resp-sapnum = lv_numc.


  ENDMETHOD.


  METHOD post.

    SELECT SINGLE *
      FROM zztfi001
     WHERE reference1indocumentheader = @is_data-reference1indocumentheader
       AND datasource = @is_data-datasource
      INTO @DATA(ls_zztfi001).

    SELECT *
      FROM zztfi002
     WHERE reference1indocumentheader = @is_data-reference1indocumentheader
       AND datasource = @is_data-datasource
      INTO TABLE @DATA(lt_zztfi002).

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
        IF proxy IS NOT BOUND.
          o_resp-msgty = 'E'.
          o_resp-msgtx = '服务端口创建异常，请联系管理员!'.
          RETURN.
        ENDIF.
      CATCH cx_root INTO DATA(lo_root).
        o_resp-msgty = 'E'.
        o_resp-msgtx = lo_root->get_text( ).
    ENDTRY.



    DATA ls_tab TYPE zjournal_entry_create_request.
    DATA ls_req TYPE zjournal_entry_create_reques18.
    DATA ls_item TYPE zjournal_entry_create_request9.
    DATA ls_debtor_item TYPE zjournal_entry_create_reques13.  "应收"
    DATA ls_creditor_item TYPE zjournal_entry_create_reques16.  "应付"
    DATA lv_itm TYPE n LENGTH 3.
    DATA(request) = VALUE zjournal_entry_bulk_create_req( ).


    ls_req-original_reference_document_ty = ls_zztfi001-originalreferencedocumenttype.
    ls_req-business_transaction_type = ls_zztfi001-businesstransactiontype.
    ls_req-accounting_document_type = ls_zztfi001-accountingdocumenttype.
    ls_req-company_code = ls_zztfi001-companycode.
    ls_req-document_date = ls_zztfi001-documentdate.
    ls_req-posting_date = ls_zztfi001-postingdate.
    ls_req-created_by_user = ls_zztfi001-accountingdoccreatedbyuser.
    ls_req-posting_fiscal_period = ls_zztfi001-fiscalperiod+1(2).
    IF ls_req-created_by_user IS INITIAL.
      ls_req-created_by_user = sy-uname.
    ENDIF.
    ls_req-document_header_text = ls_zztfi001-accountingdocumentheadertext.
    ls_req-reference1in_document_header = ls_zztfi001-reference1indocumentheader.


    SELECT a~glaccount,
           a~glaccounttype,
           a~reconciliationaccounttype
     FROM i_glaccount WITH PRIVILEGED ACCESS AS a
     JOIN @lt_zztfi002 AS b ON a~glaccount = b~glaccount
    WHERE a~companycode = @ls_zztfi001-companycode
     INTO TABLE @DATA(lt_glaccount).
    SORT lt_glaccount BY glaccount.

    LOOP AT lt_zztfi002 INTO DATA(ls_item_req).


      READ TABLE lt_glaccount INTO DATA(ls_glaccount) WITH KEY glaccount = ls_item_req-glaccount BINARY SEARCH.

      CASE ls_glaccount-reconciliationaccounttype.
        WHEN 'S' OR ''.
          "总帐
          CLEAR:ls_item.

          ls_item-reference_document_item = ls_item_req-accountingdocumentitem.
          ls_item-glaccount-content = ls_item_req-glaccount.
          ls_item-amount_in_transaction_currency-content = ls_item_req-amountintransactioncurrency.
          ls_item-amount_in_transaction_currency-currency_code = ls_zztfi001-transactioncurrency.
          ls_item-debit_credit_code = ls_item_req-debitcreditcode.
          ls_item-document_item_text = ls_item_req-documentitemtext.
          ls_item-reason_code = ls_item_req-reasoncode.
          ls_item-assignment_reference = ls_item_req-assignmentreference.
          ls_item-trading_partner = ls_item_req-tradingpartner.
          ls_item-yy1_zz005 = ls_item_req-zz005.
          ls_item-reference3idby_business_partne = ls_item_req-reference3idbybusinesspartner.
          ls_item-material = ls_item_req-material.
          ls_item-plant = ls_item_req-plant.

          "账户分配
          ls_item-account_assignment-profit_center = ls_item_req-profitcenter.
          ls_item-account_assignment-cost_center = ls_item_req-costcenter.
          ls_item-account_assignment-functional_area = ls_item_req-functionalarea.
          ls_item-account_assignment-sales_order = ls_item_req-salesorder.
          ls_item-account_assignment-sales_order_item = ls_item_req-salesorderitem.
          ls_item-account_assignment-wbselement = ls_item_req-wbselement.
          APPEND ls_item TO ls_req-item.
          "客户
        WHEN 'D'.
          CLEAR:ls_debtor_item.
          ls_debtor_item-reference_document_item = ls_item_req-accountingdocumentitem..
          ls_debtor_item-debtor = ls_item_req-customer.
          ls_debtor_item-altv_recncln_accts-content = ls_item_req-altvrecnclnaccts.

          ls_debtor_item-amount_in_transaction_currency-content = ls_item_req-amountintransactioncurrency .
          ls_debtor_item-amount_in_transaction_currency-currency_code = ls_zztfi001-transactioncurrency..
          ls_debtor_item-debit_credit_code = ls_item_req-debitcreditcode.

          ls_debtor_item-assignment_reference = ls_item_req-assignmentreference.
          ls_debtor_item-document_item_text = ls_item_req-documentitemtext.
          ls_debtor_item-yy1_zz005 = ls_item_req-zz005.
          ls_debtor_item-reference3idby_business_partne = ls_item_req-reference3idbybusinesspartner.
          APPEND ls_debtor_item TO ls_req-debtor_item.
          "供应商
        WHEN 'K'.
          CLEAR:ls_creditor_item.
          ls_creditor_item-reference_document_item = ls_item_req-accountingdocumentitem..
          ls_creditor_item-creditor = ls_item_req-vendor.
          ls_creditor_item-altv_recncln_accts-content = ls_item_req-altvrecnclnaccts.
          ls_creditor_item-amount_in_transaction_currency-content = ls_item_req-amountintransactioncurrency .
          ls_creditor_item-amount_in_transaction_currency-currency_code = ls_zztfi001-transactioncurrency..
          ls_creditor_item-debit_credit_code = ls_item_req-debitcreditcode.

          ls_creditor_item-assignment_reference = ls_item_req-assignmentreference.
          ls_creditor_item-document_item_text = ls_item_req-documentitemtext.
          ls_creditor_item-yy1_zz005 = ls_item_req-zz005.
          ls_creditor_item-reference3idby_business_partne = ls_item_req-reference3idbybusinesspartner.
          APPEND ls_creditor_item TO ls_req-creditor_item.

      ENDCASE.

    ENDLOOP.

    ls_tab-journal_entry = ls_req.

    IF iv_flag = abap_true.
      ls_tab-message_header-test_data_indicator = iv_flag.
    ENDIF.

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
    IF iv_flag = abap_true.
      "模拟
      DATA(lv_code) = response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-log-maximum_log_item_severity_code.
      IF lv_code = '1'.
        o_resp-msgty = 'S'.
      ELSE.
        o_resp-msgty = 'E'.
      ENDIF.

      LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-log-item INTO DATA(ls_item_log).
        o_resp-msgtx = o_resp-msgtx && ls_item_log-note && '/'.
      ENDLOOP.

    ELSE.
      "真实
      IF lv_accounting_document <> '0000000000'.
        o_resp-msgty = 'S'.
        o_resp-msgtx = 'Success'.
        o_resp-sapnum = lv_accounting_document.

        "更新表
        IF ls_zztfi001-datasource = 'A03'.
          UPDATE zztfi007a SET status = '30',
                              accountingdocument = @lv_accounting_document,
                              fiscalyear = @ls_zztfi001-postingdate+0(4),
                              postdata = @ls_zztfi001-postingdate
                        WHERE recordid = @ls_zztfi001-reference1indocumentheader
                          AND unitno = @ls_zztfi001-companycode .
        ENDIF.

      ELSE.
        o_resp-msgty = 'E'.
        LOOP AT response-journal_entry_bulk_create_conf-journal_entry_create_confirmat[ 1 ]-log-item INTO ls_item_log.
          o_resp-msgtx = o_resp-msgtx && ls_item_log-note && '/'.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD push_dms.

    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb.
    DATA:lv_data TYPE string.
    DATA:lv_msgty TYPE bapi_mtype,
         lv_msgtx TYPE bapi_msg,
         lv_resp  TYPE string.

    DATA: lt_mapping TYPE /ui2/cl_json=>name_mappings.


    TYPES: BEGIN OF ty_reqbj   ,
             companycode TYPE string,
             dealercode  TYPE string,
             dealername  TYPE string,
             date        TYPE string,
             time        TYPE string,
             flowno      TYPE string,
             operator    TYPE string,
             accounttype TYPE string,
             amount      TYPE string,
             hb          TYPE string,
             remark      TYPE string,
           END OF ty_reqbj.

    TYPES: BEGIN OF ty_zcin,
             bukrs  TYPE string,
             kunnr  TYPE string,
             name1  TYPE string,
             budat  TYPE string,
             cputm  TYPE string,
             zyhlsh TYPE string,
             usnam  TYPE string,
             zzhlx  TYPE string,
             wrbtr  TYPE string,
             waers  TYPE string,
             zbz    TYPE string,
             zuda1  TYPE string,
             zuda2  TYPE string,
             zuda3  TYPE string,
             zuda4  TYPE string,
             zuda5  TYPE string,
           END OF ty_zcin,
           BEGIN OF ty_reqzc   ,
             uuid   TYPE string,
             znumb  TYPE string,
             fsysid TYPE string,
             data   TYPE ty_zcin,
           END OF ty_reqzc.

    lt_mapping = VALUE #(
     ( abap = 'companyCode'   json = 'companyCode'        )
     ( abap = 'dealerCode'    json = 'dealerCode'         )
     ( abap = 'dealerName'    json = 'dealerName'         )
     ( abap = 'date'          json = 'date'               )
     ( abap = 'time'          json = 'time'               )
     ( abap = 'flowNo'        json = 'flowNo'             )
     ( abap = 'operator'      json = 'operator'           )
     ( abap = 'accountType'   json = 'accountType'        )
     ( abap = 'amount'        json = 'amount'             )
     ( abap = 'hb'            json = 'hb'                 )
     ( abap = 'remark'        json = 'remark'             )

     ( abap = 'BUKRS'         json = 'BUKRS'             )
     ( abap = 'KUNNR'         json = 'KUNNR'             )
     ( abap = 'NAME1'         json = 'NAME1'             )
     ( abap = 'BUDAT'         json = 'BUDAT'             )
     ( abap = 'CPUTM'         json = 'CPUTM'             )
     ( abap = 'ZYHLSH'        json = 'ZYHLSH'             )
     ( abap = 'USNAM'         json = 'USNAM'             )
     ( abap = 'ZZHLX'         json = 'ZZHLX'             )
     ( abap = 'WRBTR'         json = 'WRBTR'             )
     ( abap = 'WAERS'         json = 'WAERS'             )
     ( abap = 'ZBZ'           json = 'ZBZ'              )
     ( abap = 'uuid'          json = 'uuid'             )
     ( abap = 'znumb'         json = 'znumb'             )
     ( abap = 'fsysid'        json = 'fsysid'             )
     ( abap = 'data'          json = 'data'             )
     ).

    SELECT SINGLE *
      FROM zztfi007a
     WHERE recordid = @is_data-reference1indocumentheader
       AND unitno = @is_data-companycode
      INTO @DATA(ls_data).

    DATA: ls_reqbj TYPE ty_reqbj.
    DATA: ls_reqzc TYPE ty_reqzc.
    DATA: ls_zcin TYPE ty_zcin.

    IF ls_data-receivablestype = 'A1'."整车
      lv_numb = 'DMS004'.
      TRY .
          DATA(lv_uuid_c32) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
          ls_reqzc-uuid = lv_uuid_c32.
        CATCH cx_uuid_error.
      ENDTRY.
      ls_reqzc-znumb = 'CUST_PAYMENT_NOTIFY'.
      ls_reqzc-fsysid = 'FINANCE_SYSTEM_001'.
      ls_zcin-bukrs = ls_data-unitno.
      ls_zcin-kunnr = ls_data-storecode.
      ls_zcin-name1 = ls_data-storename.
      IF ls_data-recorddate IS NOT INITIAL.
        ls_zcin-budat = |{ ls_data-recorddate+0(4) }-{ ls_data-recorddate+4(2) }-{ ls_data-recorddate+6(2) } |.
        CONDENSE ls_zcin-budat NO-GAPS.
      ENDIF.
      IF ls_data-hosttime IS NOT INITIAL.
        ls_zcin-cputm = |{ ls_data-hosttime+0(2) }:{ ls_data-hosttime+2(2) }:{ ls_data-hosttime+4(2) } |.
        CONDENSE ls_zcin-cputm NO-GAPS.
      ENDIF.
      ls_zcin-zyhlsh = ls_data-hostid.
      ls_zcin-usnam =  sy-uname.
      ls_zcin-zzhlx =  ls_data-accounttype.
      ls_zcin-wrbtr = abs( ls_data-amount ) .
      IF ls_data-amount  < 0.
        ls_zcin-wrbtr  = |-{ ls_zcin-wrbtr  }|.
      ENDIF.
      CONDENSE ls_zcin-wrbtr NO-GAPS.
      ls_zcin-waers = 'CNY'.
      ls_zcin-zbz = ls_data-remark.

      ls_reqzc-data = ls_zcin.
      lv_data = /ui2/cl_json=>serialize( EXPORTING data          = ls_reqzc
                                                   compress      = abap_true
                                                   name_mappings = lt_mapping ).
    ELSEIF ls_data-receivablestype = 'A2'."零部件
      lv_numb = 'DMS001'.
      ls_reqbj-companycode = ls_data-unitno.

      ls_reqbj-dealercode = ls_data-storecode.
      ls_reqbj-dealername = ls_data-storename.
      ls_reqbj-date = ls_data-recorddate.
      ls_reqbj-time = ls_data-hosttime.
      REPLACE ALL OCCURRENCES OF ':' IN ls_reqbj-time  WITH ''.
      ls_reqbj-flowno = ls_data-hostid.
      ls_reqbj-operator = sy-uname.
      ls_reqbj-accounttype =  ls_data-accounttype..
      ls_reqbj-amount = abs( ls_data-amount ).
      IF ls_data-amount < 0.
        ls_reqbj-amount  = |-{ ls_reqbj-amount  }|.
      ENDIF.
      CONDENSE ls_reqbj-amount  NO-GAPS.
      ls_reqbj-hb = 'CNY'.
      ls_reqbj-remark = ls_data-remark.

      lv_data = /ui2/cl_json=>serialize( EXPORTING data          = ls_reqbj
                                                   compress      = abap_true
                                                   name_mappings = lt_mapping ).
    ENDIF.


    "获取调用类
    SELECT SINGLE zzcname
      FROM zr_vt_rest_conf
     WHERE zznumb = @lv_numb
      INTO @lv_oref.
    CHECK lv_oref IS NOT INITIAL.

* *&--调用实例化接口
    DATA:lo_oref TYPE REF TO object.

    lt_ptab = VALUE #( ( name  = 'IV_NUMB' kind  = cl_abap_objectdescr=>exporting value = REF #( lv_numb ) ) ).
    TRY .
        CREATE OBJECT lo_oref TYPE (lv_oref) PARAMETER-TABLE lt_ptab.
        CALL METHOD lo_oref->('OUTBOUND')
          EXPORTING
            iv_data  = lv_data
          CHANGING
            ev_resp  = lv_resp
            ev_msgty = lv_msgty
            ev_msgtx = lv_msgtx.
      CATCH cx_root INTO DATA(lr_root).
    ENDTRY.

    /ui2/cl_json=>deserialize( EXPORTING json        = lv_resp
                               CHANGING  data        = o_resp ).
    o_resp-msgty = lv_msgty.
    o_resp-msgtx = lv_msgtx.
    IF  o_resp-msgty = 'S'.
      "更新表
      IF is_data-datasource = 'A03'.
        UPDATE zztfi007a SET status = '40'
                       WHERE recordid = @is_data-reference1indocumentheader
                         AND unitno = @is_data-companycode .
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_data.
    IF gs_data-header-datasource IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请输入来源系统'.
      RETURN.
    ENDIF.

    IF gs_data-header-reference1indocumentheader  IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请输入参照单据号'.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zztfi001
       WHERE reference1indocumentheader = @gs_data-header-reference1indocumentheader
         AND datasource = @gs_data-header-datasource
         INTO @DATA(ls_tmp).
      IF  sy-subrc = 0.
        IF ls_tmp-flag = abap_true.
          o_resp-msgty = 'E'.
          o_resp-msgtx = '数据已过账，无法再次写入'.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    "其他数据校验
    IF gs_data-header-companycode IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '输入公司代码'.
      RETURN.
    ELSE.
      SELECT COUNT(*) FROM i_companycode WITH PRIVILEGED ACCESS
       WHERE companycode = @gs_data-header-companycode .
      IF sy-subrc <> 0.
        o_resp-msgty = 'E'.
        o_resp-msgtx = '公司代码不存在'.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT gs_data-item ASSIGNING FIELD-SYMBOL(<fs_item>).
      <fs_item>-glaccount = |{ <fs_item>-glaccount ALPHA = IN }|.
      <fs_item>-costcenter = |{ <fs_item>-costcenter ALPHA = IN }|.
      <fs_item>-customer = |{ <fs_item>-customer ALPHA = IN }|.
      <fs_item>-vendor = |{ <fs_item>-vendor ALPHA = IN }|.
      <fs_item>-salesorder = |{ <fs_item>-salesorder ALPHA = IN }|.
    ENDLOOP.

    SELECT a~companycode,
           a~glaccount
     FROM i_glaccount WITH PRIVILEGED ACCESS AS a
     JOIN @gs_data-item AS b ON a~glaccount = b~glaccount
     WHERE a~companycode = @gs_data-header-companycode
     INTO TABLE @DATA(lt_glaccount).
    SORT lt_glaccount BY glaccount.

    SELECT a~companycode,
           a~paymentdifferencereason
     FROM i_paymentdifferencereason WITH PRIVILEGED ACCESS AS a
     JOIN @gs_data-item AS b ON a~paymentdifferencereason = b~reasoncode
     WHERE a~companycode = @gs_data-header-companycode
     INTO TABLE @DATA(lt_reason).
    SORT lt_reason BY paymentdifferencereason.

    SELECT a~companycode,
           a~costcenter
      FROM i_costcenter WITH PRIVILEGED ACCESS AS a
      JOIN @gs_data-item AS b ON a~costcenter = b~costcenter
     WHERE a~companycode = @gs_data-header-companycode
       AND a~controllingarea = 'A000'
       AND a~validitystartdate <= @sy-datum
       AND a~validityenddate >= @sy-datum
      INTO TABLE @DATA(lt_costcenter).
    SORT lt_costcenter BY costcenter.

    SELECT a~project
     FROM i_enterpriseproject WITH PRIVILEGED ACCESS AS a
     JOIN @gs_data-item AS b ON a~project  = b~wbselement
    WHERE a~companycode = @gs_data-header-companycode
     INTO TABLE @DATA(lt_project).
    SORT lt_project BY project.

    SELECT a~functionalarea
     FROM i_functionalarea WITH PRIVILEGED ACCESS AS a
     JOIN @gs_data-item AS b ON a~functionalarea = b~functionalarea
     INTO TABLE @DATA(lt_functionalarea).
    SORT lt_functionalarea BY functionalarea.

    SELECT a~customer
     FROM i_customercompany WITH PRIVILEGED ACCESS AS a
     JOIN @gs_data-item AS b ON a~customer = b~customer
    WHERE a~companycode = @gs_data-header-companycode
     INTO TABLE @DATA(lt_customer).
    SORT lt_customer BY customer.

    SELECT a~supplier
      FROM i_suppliercompany WITH PRIVILEGED ACCESS AS a
      JOIN @gs_data-item AS b ON a~supplier = b~vendor
     WHERE a~companycode = @gs_data-header-companycode
      INTO TABLE @DATA(lt_supplier).
    SORT lt_supplier BY supplier.

    SELECT a~company
     FROM i_globalcompany WITH PRIVILEGED ACCESS AS a
     JOIN @gs_data-item AS b ON a~company = b~tradingpartner
     INTO TABLE @DATA(lt_globalcompany).
    SORT lt_globalcompany BY company.

    LOOP AT gs_data-item ASSIGNING <fs_item>.
      IF <fs_item>-glaccount IS INITIAL.
        o_resp-msgty = 'E'.
        o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 总账科目不能为空'|.
        RETURN.
      ELSE.
        READ TABLE lt_glaccount TRANSPORTING NO FIELDS WITH KEY glaccount = <fs_item>-glaccount BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 总账科目在公司代码下不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-reasoncode IS NOT INITIAL.
        READ TABLE lt_reason TRANSPORTING NO FIELDS WITH KEY paymentdifferencereason = <fs_item>-reasoncode BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 付款原因代码在公司代码下不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-costcenter IS NOT INITIAL.
        READ TABLE lt_costcenter TRANSPORTING NO FIELDS WITH KEY costcenter = <fs_item>-costcenter BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 成本中心在公司代码下不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-wbselement IS NOT INITIAL.
        READ TABLE lt_project TRANSPORTING NO FIELDS WITH KEY project = <fs_item>-wbselement BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } WBS元素（内部订单）在公司代码下不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-functionalarea  IS NOT INITIAL.
        READ TABLE lt_functionalarea TRANSPORTING NO FIELDS WITH KEY functionalarea  = <fs_item>-functionalarea  BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 职能范围不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-customer  IS NOT INITIAL.
        READ TABLE lt_customer TRANSPORTING NO FIELDS WITH KEY customer  = <fs_item>-customer  BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 客户编号在公司代码下不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-vendor  IS NOT INITIAL.
        READ TABLE lt_supplier TRANSPORTING NO FIELDS WITH KEY supplier  = <fs_item>-vendor  BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 供应商或债权人在公司代码下不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

      IF <fs_item>-tradingpartner  IS NOT INITIAL.
        READ TABLE lt_globalcompany TRANSPORTING NO FIELDS WITH KEY company  = <fs_item>-tradingpartner  BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |行{ <fs_item>-referencedocumentitem  } 贸易伙伴的公司标识不存在'|.
          RETURN.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
