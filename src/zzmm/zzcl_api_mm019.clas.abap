CLASS zzcl_api_mm019 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:BEGIN OF ty_entry,
            zjsd   TYPE string,
            zbuzei TYPE string,
            zjslx  TYPE string,
            ebeln  TYPE ebeln,
            ebelp  TYPE ebelp,
            lfbnr  TYPE lfbnr,
            lfpos  TYPE lfpos,
            lfgja  TYPE lfgja,
            wrbtr1 TYPE p LENGTH 11 DECIMALS 2,
            mwskz1 TYPE string,
            wmwst1 TYPE p LENGTH 11 DECIMALS 2,
            menge  TYPE menge_d,
            sgtxt1 TYPE string,
          END OF ty_entry,
          BEGIN OF ty_billbody,
            entry TYPE TABLE OF ty_entry WITH EMPTY KEY,
          END OF ty_billbody,
          BEGIN OF ty_billheader,
            supplierinvoice TYPE string,
            fiscalyear      TYPE string,
            zjsd            TYPE string,
            bukrs           TYPE string,
            bldat           TYPE string,
            budat           TYPE string,
            sgtxt           TYPE string,
            lifnr           TYPE string,
            waers           TYPE string,
            wrbtr           TYPE p LENGTH 11 DECIMALS 2,
            zuonr           TYPE string,
            zfplx           TYPE string,
            zterm           TYPE string,
            wmwst           TYPE p LENGTH 11 DECIMALS 2,
          END OF ty_billheader,
          BEGIN OF ty_bill,
            billheader TYPE ty_billheader,
            billbody   TYPE ty_billbody,
          END OF ty_bill.



    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_rest_cpi OPTIONAL
      EXPORTING
        o_resp TYPE zzs_mmi017_resp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm019 IMPLEMENTATION.


  METHOD inbound.

    DATA: ls_data TYPE ty_bill.
    DATA: ls_req TYPE zzs_mmi003_req.
    DATA: ls_head TYPE zzs_mmi003_head_in.
    DATA: ls_body TYPE zzs_mmi003_body_in.
    DATA: ls_tax  TYPE zzs_mmi003_tax_in.
    DATA: ls_res TYPE zzs_rest_out.
    DATA: lr_mm003 TYPE REF TO  zzcl_api_mm003.
    DATA: lv_index TYPE c_supplierinvoiceitemdex-supplierinvoiceitem.

    /ui2/cl_json=>deserialize( EXPORTING json          = i_req-data
                                         pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data          = ls_data ).

    SELECT *
      FROM zztmm005
     WHERE relsystem = 'PSSC'
      INTO TABLE @DATA(lt_zztmm005).

    CLEAR: ls_head.
    ls_head-documentheadertext = ls_data-billheader-zjsd.
    ls_head-companycode = ls_data-billheader-bukrs.
    ls_head-documentdate = ls_data-billheader-bldat.
    ls_head-postingdate = ls_data-billheader-budat.
    ls_head-supplierpostinglineitemtext = ls_data-billheader-sgtxt.
    ls_head-invoicingparty = ls_data-billheader-lifnr.
    ls_head-documentcurrency = ls_data-billheader-waers.
    ls_head-invoicegrossamount = abs( ls_data-billheader-wrbtr ) + abs( ls_data-billheader-wmwst ).
    CONDENSE ls_head-invoicegrossamount NO-GAPS.
    ls_head-assignmentreference = ls_data-billheader-zuonr.

    IF ls_data-billheader-zfplx = 'X'.
      ls_head-supplierinvoiceiscreditmemo = '2'.
    ENDIF.

    IF ls_data-billheader-supplierinvoice IS NOT INITIAL.
      ls_head-supplierinvoice = ls_data-billheader-supplierinvoice.
      IF ls_data-billheader-fiscalyear IS NOT INITIAL.
        ls_head-fiscalyear = ls_data-billheader-fiscalyear.
      ELSE.
        ls_head-fiscalyear = ls_data-billheader-budat+0(4).
      ENDIF.
      ls_head-reversalreason = '01'.
    ELSE.
      SELECT COUNT(*)
        FROM c_supplierinvoicedex WITH PRIVILEGED ACCESS
       WHERE documentheadertext = @ls_data-billheader-zjsd
         AND reversedocument IS INITIAL.
      IF sy-subrc = 0.
        o_resp-msgty = 'E'.
        o_resp-msgtx = '该开票通知单已生成发票，不可重复开票'.
        RETURN.
      ENDIF.
    ENDIF.

    READ TABLE lt_zztmm005 INTO DATA(ls_zztmm005) WITH KEY conftype = 'PAYMENTTERMS'
                                                        transvalue  = ls_data-billheader-zterm.
    IF sy-subrc = 0.
      ls_head-paymentterms = ls_zztmm005-sapvalue.
    ENDIF.

    DATA(lt_item) = ls_data-billbody-entry.

    "税码
    SELECT *
      FROM i_taxcoderate WITH PRIVILEGED ACCESS AS a
     WHERE a~country = 'CN'
       AND a~cndnrecordvaliditystartdate <= @sy-datum
       AND a~cndnrecordvalidityenddate >= @sy-datum
       AND a~taxtype = 'V'
      INTO TABLE @DATA(lt_taxcoderate).
    SORT lt_taxcoderate BY conditionrateratio.

    "采购订单单位
    SELECT a~purchaseorder,
           a~purchaseorderitem,
           a~purchaseorderquantityunit
      FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS a
      JOIN @lt_item AS b ON a~purchaseorder = b~ebeln
                        AND a~purchaseorderitem = b~ebelp
      INTO TABLE @DATA(lt_quantityunit).
    SORT lt_quantityunit BY purchaseorder purchaseorderitem.

    "采购订单历史
    SELECT a~*
      FROM i_purchaseorderhistoryapi01 WITH PRIVILEGED ACCESS AS a
      JOIN @lt_item AS b ON a~purchaseorder = b~ebeln
                        AND a~purchaseorderitem = b~ebelp
                        AND a~purchasinghistorydocument = b~lfbnr
                        AND a~purchasinghistorydocumentitem = b~lfpos
     WHERE a~purchasinghistorycategory = 'E'
      INTO TABLE @DATA(lt_history).
    SORT lt_history BY purchaseorder purchaseorderitem purchasinghistorydocument purchasinghistorydocumentitem.
    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      READ TABLE lt_history INTO DATA(ls_history) WITH KEY purchaseorder = <fs_item>-ebeln
                                                           purchaseorderitem = <fs_item>-ebelp
                                                           purchasinghistorydocument = <fs_item>-lfbnr
                                                           purchasinghistorydocumentitem = <fs_item>-lfpos BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_item>-lfbnr = ls_history-referencedocument.
        <fs_item>-lfgja = ls_history-referencedocumentfiscalyear.
        <fs_item>-lfpos = ls_history-referencedocumentitem.

        IF ls_history-debitcreditcode = 'H'.
          <fs_item>-wrbtr1 = 0 - abs( <fs_item>-wrbtr1 ).
          <fs_item>-menge = 0 - abs( <fs_item>-menge ).
          <fs_item>-wmwst1 = 0 - abs( <fs_item>-wmwst1 ).
        ENDIF.
      ENDIF.
*      READ TABLE lt_taxcoderate INTO DATA(ls_taxcoderate) WITH KEY conditionrateratio = <fs_item>-mwskz1 BINARY SEARCH.
*      IF sy-subrc = 0.
*        <fs_item>-mwskz1 = ls_taxcoderate-taxcode.
*      ENDIF.
      CLEAR:<fs_item>-zjsd,<fs_item>-zbuzei,<fs_item>-zjslx.
    ENDLOOP.

    SELECT ebeln,
           ebelp,
           lfbnr,
           lfgja,
           lfpos,
      SUM( menge ) AS menge,
      SUM( wrbtr1 ) AS wrbtr1,
      SUM( wmwst1 ) AS wmwst1
      FROM @lt_item AS a
     GROUP BY ebeln,ebelp,lfbnr,lfgja,lfpos
      INTO TABLE @DATA(lt_item_sum).

    CLEAR: lv_index.
    LOOP AT lt_item_sum INTO DATA(ls_item_sum).
      CLEAR: ls_body.
      READ TABLE lt_item INTO DATA(ls_item) WITH KEY ebeln = ls_item_sum-ebeln ebelp = ls_item_sum-ebelp.

      IF ls_item_sum-menge = 0.
        CONTINUE.
      ENDIF.

      lv_index = lv_index + 1.
      ls_body-purchaseorder = ls_item_sum-ebeln.
      ls_body-purchaseorderitem = ls_item_sum-ebelp.
      ls_body-referencedocument = ls_item_sum-lfbnr.
      ls_body-referencedocumentfiscalyear = ls_item_sum-lfgja.
      ls_body-referencedocumentitem = ls_item_sum-lfpos.
      ls_body-supplierinvoiceitem = lv_index.
      ls_body-supplierinvoiceitemamount = abs( ls_item_sum-wrbtr1 ).
      ls_body-quantityinpurchaseorderunit = abs( ls_item_sum-menge ).

      ls_body-supplierinvoiceitemtext = ls_item-sgtxt1.
      ls_body-taxcode = ls_item-mwskz1.
      ls_body-taxcountry = 'CN'.
      ls_body-documentcurrency = ls_data-billheader-waers.

      READ TABLE lt_quantityunit INTO DATA(ls_quantityunit) WITH KEY purchaseorder = ls_body-purchaseorder
                                                                     purchaseorderitem = ls_body-purchaseorderitem
                                                                     BINARY SEARCH.
      IF sy-subrc = 0.
        ls_body-purchaseorderquantityunit = ls_quantityunit-purchaseorderquantityunit.
      ENDIF.

      CONDENSE ls_body-supplierinvoiceitemamount NO-GAPS.
      CONDENSE ls_body-quantityinpurchaseorderunit NO-GAPS.

      ls_tax-taxcode = ls_item-mwskz1.
*      ls_tax-taxamount += ls_item_sum-wmwst1.

      APPEND ls_body TO ls_req-data-body.

    ENDLOOP.

*    ls_tax-taxamount = abs( ls_tax-taxamount ).
    ls_tax-taxamount = abs( ls_data-billheader-wmwst ).
    ls_tax-documentcurrency = ls_data-billheader-waers.
    ls_tax-taxcountry = 'CN'.
    CONDENSE ls_tax-taxamount NO-GAPS.
    APPEND ls_tax TO ls_req-data-tax.
    ls_req-data-header = ls_head.

    CREATE OBJECT lr_mm003.
    "调用发票预制接口
    lr_mm003->inbound( EXPORTING i_req = ls_req IMPORTING o_resp = ls_res  ).

    o_resp-msgty = o_resp-out-resultstatus = ls_res-msgty.
    o_resp-msgtx = o_resp-out-resultmsg = ls_res-msgtx.
    o_resp-sapnum = ls_res-sapnum.

  ENDMETHOD.
ENDCLASS.
