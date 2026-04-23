CLASS zzcl_api_fi011 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: gt_mapping TYPE /ui2/cl_json=>name_mappings.
    METHODS:constructor. "静态构造方法
    METHODS  push
      IMPORTING
        it_data       TYPE zzt_fii011_in OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI011 IMPLEMENTATION.


  METHOD push.

    TYPES:BEGIN OF ty_paydetailrefillattrs,
            amount            TYPE string,
            budgetaccountcode TYPE string,
            budgetaccountname TYPE string,
            ledgertitleno     TYPE string,
            ledgertitlename   TYPE string,
            businessfeeamount TYPE string,
            createtime        TYPE string,
            departmentname    TYPE string,
            departmentno      TYPE string,
            lastupdatetime    TYPE string,
            memo              TYPE string,
            propname          TYPE string,
            propno            TYPE string,
            rplsplanid        TYPE string,
            lcno              TYPE string,
            voucherno         TYPE string,
          END OF ty_paydetailrefillattrs,
          BEGIN OF ty_reqdata,
            applychannel         TYPE string,
            applychannelname     TYPE string,
            erpid                TYPE string,
            recordids            TYPE string,
            paydetailrefillattrs TYPE TABLE OF ty_paydetailrefillattrs WITH EMPTY KEY,
          END OF ty_reqdata,
          BEGIN OF ty_ptmsfilllist,
            ptmsfilllist TYPE TABLE OF ty_reqdata WITH EMPTY KEY,
          END OF ty_ptmsfilllist,
          BEGIN OF ty_req,
            code      TYPE string,
            batchno   TYPE string,
            channelid TYPE string,
*            data      TYPE TABLE OF ty_reqdata WITH EMPTY KEY,
            data      TYPE string,
            sign      TYPE string,
          END OF ty_req,
          BEGIN OF ty_res,
            code       TYPE string,
            batchno    TYPE string,
            channelid  TYPE string,
            resultcode TYPE string,
            resultmsg  TYPE string,
          END OF ty_res.
    DATA:ls_req                  TYPE ty_req,
         ls_req_json             TYPE string,
         ls_res                  TYPE ty_res,
         ls_res_json             TYPE string,
         ls_reqdata              TYPE ty_reqdata,
         ls_paydetailrefillattrs TYPE ty_paydetailrefillattrs,
         lv_msgty                TYPE bapi_mtype,
         lv_msgtx                TYPE bapi_msg,
         lv_aes_json             TYPE string.
    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb VALUE 'FII011'.
    DATA: lt_reqdata  TYPE TABLE OF ty_reqdata,
          lt_tempdata TYPE TABLE OF ty_reqdata.
    DATA: ls_ptmsfilllist TYPE ty_ptmsfilllist.
    DATA: lv_begin TYPE n,
          lv_end   TYPE n,
          lv_line  TYPE n,
          lv_time  TYPE n.

    "获取调用类
    SELECT SINGLE *
      FROM zr_vt_rest_conf
     WHERE zznumb = @lv_numb
      INTO @DATA(ls_conf).
    lv_oref = ls_conf-zzcname.
    CHECK lv_oref IS NOT INITIAL.
* *&--调用实例化接口
    DATA: lo_sk TYPE REF TO zzcl_rest_api_t20.
    CREATE OBJECT lo_sk EXPORTING iv_numb = lv_numb.

    DATA(lv_unix_timestamp) = xco_cp=>sy->unix_timestamp( )->value.
    ls_req-code = 'PTMS-TX004'.
    ls_req-batchno = 'TX004' && lv_unix_timestamp.
    ls_req-channelid = ls_conf-zztkurl.

    SELECT zztfi001~*
      FROM zztfi001
      JOIN @it_data AS a ON zztfi001~reference1indocumentheader = a~reference1indocumentheader
     WHERE zztfi001~datasource = 'A03'
      INTO TABLE @DATA(lt_zztfi001).

    IF lt_zztfi001 IS NOT INITIAL.
      SELECT zztfi002~amountintransactioncurrency,
             zztfi002~reference1indocumentheader,
             zztfi002~datasource,
             zztfi002~glaccount,
             zztfi002~last_changed_at,
            _altaccounttext~glaccountname
        FROM zztfi002
        JOIN @lt_zztfi001 AS a ON zztfi002~reference1indocumentheader = a~reference1indocumentheader
        LEFT OUTER JOIN i_glaccounttext AS _altaccounttext ON _altaccounttext~glaccount       = zztfi002~altvrecnclnaccts
                                                          AND _altaccounttext~chartofaccounts = 'YCOA'
                                                          AND _altaccounttext~language        = 1
       WHERE zztfi002~datasource = 'A03'
         AND zztfi002~glaccount LIKE '1002%'
        INTO TABLE @DATA(lt_zztfi002).
      SORT lt_zztfi002 BY reference1indocumentheader.

      SELECT DISTINCT
             a~companycode,
             a~fiscalyear,
             a~accountingdocument,
             a~creationdate
        FROM i_accountingdocumentjournal AS a
        JOIN @lt_zztfi001 AS b ON a~companycode = b~companycode
                              AND a~fiscalyear = b~fiscalyear
                              AND a~accountingdocument = b~accountingdocument
       WHERE a~ledger = '0L'
        INTO TABLE @DATA(lt_journal).
      SORT lt_journal BY companycode fiscalyear accountingdocument.
    ENDIF.

    LOOP AT lt_zztfi001 INTO DATA(ls_zztfi001).
      CLEAR: ls_reqdata.
      ls_reqdata-applychannel = 'NCC'.
      ls_reqdata-applychannelname = 'NCC'.
      ls_reqdata-erpid = ls_zztfi001-accountingdocument && ls_zztfi001-companycode && ls_zztfi001-fiscalyear  .
      ls_reqdata-recordids = ls_zztfi001-reference1indocumentheader.

      READ TABLE lt_zztfi002 TRANSPORTING NO FIELDS WITH KEY reference1indocumentheader = ls_zztfi001-reference1indocumentheader BINARY SEARCH.
      LOOP AT lt_zztfi002 INTO DATA(ls_zztfi002) FROM sy-tabix.
        IF ls_zztfi001-reference1indocumentheader = ls_zztfi002-reference1indocumentheader.
          CLEAR: ls_paydetailrefillattrs.
          ls_paydetailrefillattrs-ledgertitleno = ls_zztfi002-glaccount.
          ls_paydetailrefillattrs-ledgertitlename = ls_zztfi002-glaccountname.

          CONVERT TIME STAMP ls_zztfi002-last_changed_at TIME ZONE sy-zonlo
           INTO DATE DATA(lv_cdate) TIME DATA(lv_ctime).
          IF lv_cdate IS NOT INITIAL OR lv_cdate <> '00000000'.
            ls_paydetailrefillattrs-lastupdatetime = lv_cdate+0(4) && '-' && lv_cdate+4(2) && '-' && lv_cdate+6(2).
          ENDIF.

          ls_paydetailrefillattrs-memo = ls_zztfi001-accountingdocumentheadertext.
          ls_paydetailrefillattrs-amount = ls_zztfi002-amountintransactioncurrency.
          ls_paydetailrefillattrs-voucherno = ls_zztfi001-accountingdocument && ls_zztfi001-companycode && ls_zztfi001-fiscalyear.

          CONDENSE ls_paydetailrefillattrs-amount NO-GAPS.

          READ TABLE lt_journal INTO DATA(ls_journal) WITH KEY companycode = ls_zztfi001-companycode
                                                               fiscalyear = ls_zztfi001-fiscalyear
                                                               accountingdocument = ls_zztfi001-accountingdocument
                                                               BINARY SEARCH.
          IF sy-subrc = 0.
            ls_paydetailrefillattrs-createtime = ls_journal-creationdate+0(4) && '-' && ls_journal-creationdate+4(2) && '-' && ls_journal-creationdate+6(2).
            CLEAR: ls_journal.
          ENDIF.

          APPEND ls_paydetailrefillattrs TO ls_reqdata-paydetailrefillattrs.
        ELSE.
          EXIT.
        ENDIF.

        APPEND ls_reqdata TO ls_ptmsfilllist-ptmsfilllist.
      ENDLOOP.

    ENDLOOP.

    lv_aes_json = /ui2/cl_json=>serialize( EXPORTING data          = ls_ptmsfilllist
                                                     compress      = abap_true
                                                     name_mappings = gt_mapping ).

    ls_req-sign = lo_sk->get_fingercode( ).
    ls_req-data = lo_sk->get_encrypt( lv_aes_json ).

    ls_req_json = /ui2/cl_json=>serialize( EXPORTING data          = ls_req
                                                     compress      = abap_true
                                                     name_mappings = gt_mapping ).

    CALL METHOD lo_sk->outbound
      EXPORTING
        iv_uuid  = CONV zzeuuid( ls_req-batchno )
        iv_data  = ls_req_json
      CHANGING
        ev_resp  = ls_res_json
        ev_msgty = lv_msgty
        ev_msgtx = lv_msgtx.

    IF lv_msgty = 'S'.
      LOOP AT lt_zztfi001 ASSIGNING FIELD-SYMBOL(<fs_zztfi001>).
        <fs_zztfi001>-zzskzt = 'B'.
      ENDLOOP.

      MODIFY zztfi001 FROM TABLE @lt_zztfi001.
    ENDIF.

    o_resp-msgty = lv_msgty.
    o_resp-msgtx = lv_msgtx.

  ENDMETHOD.


  METHOD constructor.
    gt_mapping = VALUE #(
        ( abap = 'code'                                      json = 'code' )
        ( abap = 'batchNo'                                   json = 'batchNo' )
        ( abap = 'channelId'                                 json = 'channelId' )
        ( abap = 'sign'                                      json = 'sign' )
        ( abap = 'data'                                      json = 'data' )
        ( abap = 'applyChannel'                              json = 'applyChannel' )
        ( abap = 'applyChannelName'                          json = 'applyChannelName' )
        ( abap = 'erpId'                                     json = 'erpId' )
        ( abap = 'recordIds'                                 json = 'recordIds' )
        ( abap = 'payDetailRefillAttrs'                      json = 'payDetailRefillAttrs' )
        ( abap = 'amount'                                    json = 'amount' )
        ( abap = 'budgetAccountCode'                         json = 'budgetAccountCode' )
        ( abap = 'budgetAccountName'                         json = 'budgetAccountName' )
        ( abap = 'ledgerTitleNo'                             json = 'ledgerTitleNo' )
        ( abap = 'ledgerTitleName'                           json = 'ledgerTitleName' )
        ( abap = 'businessFeeAmount'                         json = 'businessFeeAmount' )
        ( abap = 'createTime'                                json = 'createTime' )
        ( abap = 'departmentName'                            json = 'departmentName' )
        ( abap = 'departmentNo'                              json = 'departmentNo' )
        ( abap = 'lastUpdateTime'                            json = 'lastUpdateTime' )
        ( abap = 'memo'                                      json = 'memo' )
        ( abap = 'propName'                                  json = 'propName' )
        ( abap = 'propNo'                                    json = 'propNo' )
        ( abap = 'rplsPlanId'                                json = 'rplsPlanId' )
        ( abap = 'lcNo'                                      json = 'lcNo' )
        ( abap = 'voucherNo'                                 json = 'voucherNo' )
        ( abap = 'ptmsFillList'                              json = 'ptmsFillList' )
        ).
  ENDMETHOD.
ENDCLASS.
