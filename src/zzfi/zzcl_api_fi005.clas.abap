CLASS zzcl_api_fi005 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii004_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI005 IMPLEMENTATION.


  METHOD inbound.

    DATA:ls_data TYPE zzs_fii004_in.
    DATA:lt_zztfi001 TYPE TABLE OF zztfi001,
         ls_zztfi001 TYPE zztfi001,
         lt_zztfi002 TYPE TABLE OF zztfi002,
         ls_zztfi002 TYPE zztfi002.

    DATA: lv_num TYPE i.
    DATA: lv_assignmentreference(30).
    DATA: lv_total_head TYPE p LENGTH 11 DECIMALS 2.
    DATA: lv_total_item TYPE p LENGTH 11 DECIMALS 2.

    ls_data = i_req-data.

    "数据校验
    IF ls_data-header-zdjbh IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请输入单据号'.
      RETURN.
    ENDIF.
    IF ls_data-header-kunnr IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请输入门店编码'.
      RETURN.
    ENDIF.

    SELECT a~product
    FROM i_product WITH PRIVILEGED ACCESS AS a
    JOIN @ls_data-item AS b ON a~product = b~matnr
    INTO TABLE @DATA(lt_product).
    SORT lt_product BY product.
    DELETE ADJACENT DUPLICATES FROM lt_product COMPARING product.

    "行项目数据
    LOOP AT ls_data-item ASSIGNING FIELD-SYMBOL(<fs_item>).
      IF <fs_item>-matnr IS INITIAL.
        o_resp-msgty = 'E'.
        o_resp-msgtx = '请输入物料号'.
        RETURN.
      ELSE.
        READ TABLE lt_product TRANSPORTING NO FIELDS WITH KEY product = <fs_item>-matnr BINARY SEARCH.
        IF sy-subrc <> 0.
          o_resp-msgty = 'E'.
          o_resp-msgtx = |物料号{ <fs_item>-matnr }不存在|.
          RETURN.
        ENDIF.
      ENDIF.
      lv_total_item = lv_total_item + <fs_item>-wrbtr.
    ENDLOOP.

    lv_total_head = ls_data-header-wrbtr.
    IF lv_total_item <> lv_total_head.
      o_resp-msgty = 'E'.
      o_resp-msgtx = |头返利金额与行返利合计金额不一致|.
      RETURN.
    ENDIF.

    "抬头数据
    CLEAR: ls_zztfi001.
    ls_zztfi001-reference1indocumentheader = ls_data-header-zdjbh.
    ls_zztfi001-datasource = 'A04'.
    ls_zztfi001-originalreferencedocumenttype = 'BKPFF'.
    ls_zztfi001-businesstransactiontype = 'RFBU'.
    ls_zztfi001-companycode = ls_data-header-bukrs.
    ls_zztfi001-accountingdocumenttype = 'SA'.
    ls_zztfi001-postingdate = ls_data-header-budat.
    ls_zztfi001-documentdate = ls_data-header-budat.
    ls_zztfi001-transactioncurrency = ls_data-header-waers.
    ls_zztfi001-exchangerate = ''.
    ls_zztfi001-accountingdoccreatedbyuser = ''.
    ls_zztfi001-accountingdocumentheadertext = ls_data-header-kunnr && '门店' && ls_data-header-zfllx.
    APPEND ls_zztfi001 TO lt_zztfi001.


    SELECT SINGLE *
      FROM i_custsalespartnerfunc WITH PRIVILEGED ACCESS AS a
     WHERE a~salesorganization = 'GH00'
       AND a~partnerfunction = 'WE'
       AND a~bpcustomernumber = @ls_data-header-kunnr
       AND a~customer <> @ls_data-header-kunnr
      INTO @DATA(ls_func_customer).

    SELECT SINGLE customer,tradingpartner
      FROM i_customer WITH PRIVILEGED ACCESS
     WHERE customer =  @ls_func_customer-customer
      INTO @DATA(ls_customer).
    IF ls_customer-tradingpartner IS INITIAL.
      ls_customer-tradingpartner  = 'Z999'.
    ENDIF.

    SELECT SINGLE supplier,tradingpartner
      FROM i_supplier WITH PRIVILEGED ACCESS
     WHERE supplier =  @ls_func_customer-customer
      INTO @DATA(ls_supplier).
    IF ls_supplier-tradingpartner IS INITIAL.
      ls_supplier-tradingpartner  = 'Z999'.
    ENDIF.

    IF ls_data-header-zfllx  = '10'.
      lv_assignmentreference = '10 销售返利'.
    ELSEIF ls_data-header-zfllx  = '20'.
      lv_assignmentreference = '20 保修补偿'.
    ENDIF.


    "行项目数据
    LOOP AT ls_data-item INTO DATA(ls_item).
      lv_num = lv_num + 1.
      CLEAR: ls_zztfi002.
      ls_zztfi002-reference1indocumentheader = ls_data-header-zdjbh.
      ls_zztfi002-datasource = 'A04'.
      ls_zztfi002-accountingdocumentitem = lv_num.
      ls_zztfi002-glaccount = '6001120401'.
      ls_zztfi002-amountintransactioncurrency = ls_item-wrbtr.
      IF ls_item-wrbtr > 0.
        ls_zztfi002-debitcreditcode = 'S'.
      ELSE.
        ls_zztfi002-debitcreditcode = 'H'.
        ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
      ENDIF.
      ls_zztfi002-documentitemtext = ls_item-zflsm.
      ls_zztfi002-assignmentreference = lv_assignmentreference.
      ls_zztfi002-profitcenter = 'PGH00'.
      ls_zztfi002-customer = ls_customer-customer.
      ls_zztfi002-tradingpartner = ls_customer-tradingpartner.

      ls_zztfi002-zz005 = ls_item-zz005.
      ls_zztfi002-salesorder = ls_item-vbeln.
      ls_zztfi002-salesorderitem = ls_item-posnr.
      ls_zztfi002-plant = 'GH00'.
      ls_zztfi002-material = ls_item-matnr.
      ls_zztfi002-reference3idbybusinesspartner = ls_item-zywdh.
      APPEND ls_zztfi002 TO lt_zztfi002.

    ENDLOOP.

*
*    lv_num = lv_num + 1.
*    CLEAR: ls_zztfi002.
*    ls_zztfi002-reference1indocumentheader = ls_data-header-zdjbh.
*    ls_zztfi002-datasource = 'A04'.
*    ls_zztfi002-accountingdocumentitem = lv_num.
*    ls_zztfi002-glaccount = '1122020110'.
*    ls_zztfi002-amountintransactioncurrency = ls_data-header-wrbtr.
*    IF ls_data-header-wrbtr > 0.
*      ls_zztfi002-debitcreditcode = 'H'.
*      ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
*    ELSE.
*      ls_zztfi002-debitcreditcode = 'S'.
*    ENDIF.
*    ls_zztfi002-customer = ls_customer-customer.
*    ls_zztfi002-tradingpartner = ls_customer-tradingpartner.
*    ls_zztfi002-documentitemtext = ls_data-header-kunnr && '门店' && ls_data-header-zfllx..
*    ls_zztfi002-assignmentreference = lv_assignmentreference.
*    ls_zztfi002-profitcenter = 'PGH00'.
*    APPEND ls_zztfi002 TO lt_zztfi002.
*
*    lv_num = lv_num + 1.
*    CLEAR: ls_zztfi002.
*    ls_zztfi002-reference1indocumentheader = ls_data-header-zdjbh.
*    ls_zztfi002-datasource = 'A04'.
*    ls_zztfi002-accountingdocumentitem = lv_num.
*    ls_zztfi002-glaccount = '1122020110'.
*    ls_zztfi002-amountintransactioncurrency = ls_data-header-wrbtr.
*    IF ls_data-header-wrbtr > 0.
*      ls_zztfi002-debitcreditcode = 'S'.
*    ELSE.
*      ls_zztfi002-debitcreditcode = 'H'.
*      ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
*    ENDIF.
*    ls_zztfi002-customer = ls_customer-customer.
*    ls_zztfi002-tradingpartner = ls_customer-tradingpartner.
*    ls_zztfi002-documentitemtext = ls_data-header-kunnr && '门店' && ls_data-header-zfllx.
*    ls_zztfi002-assignmentreference = lv_assignmentreference.
*    ls_zztfi002-profitcenter = 'PGH00'.
*    APPEND ls_zztfi002 TO lt_zztfi002.


    lv_num = lv_num + 1.
    CLEAR: ls_zztfi002.
    ls_zztfi002-reference1indocumentheader = ls_data-header-zdjbh.
    ls_zztfi002-datasource = 'A04'.
    ls_zztfi002-accountingdocumentitem = lv_num.
    ls_zztfi002-glaccount = '2202020113'.
    ls_zztfi002-amountintransactioncurrency = ls_data-header-wrbtr.
    IF ls_data-header-wrbtr > 0.
      ls_zztfi002-debitcreditcode = 'H'.
      ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
    ELSE.
      ls_zztfi002-debitcreditcode = 'S'.
    ENDIF.
    ls_zztfi002-vendor = ls_supplier-supplier.
    ls_zztfi002-tradingpartner = ls_supplier-tradingpartner.
    ls_zztfi002-documentitemtext = ls_data-header-kunnr && '门店' && ls_data-header-zfllx.
    ls_zztfi002-assignmentreference = lv_assignmentreference.
    ls_zztfi002-profitcenter = 'PGH00'.
    ls_zztfi002-altvrecnclnaccts = '2202029901'.
    APPEND ls_zztfi002 TO lt_zztfi002.

    MODIFY zztfi001 FROM TABLE @lt_zztfi001.
    MODIFY zztfi002 FROM TABLE @lt_zztfi002.

    o_resp-msgty = 'S'.
    o_resp-msgtx = '数据接收成功'.

  ENDMETHOD.
ENDCLASS.
