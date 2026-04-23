CLASS zzcl_api_mm014_parallel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "接口传入结构
    TYPES:BEGIN OF ty_entry,
            token  TYPE string,
            zguid  TYPE string,
            matnr  TYPE string,
            lifnr  TYPE string,
            ekorg  TYPE string,
            werks  TYPE string,
            kschl  TYPE string,
            esokz  TYPE string,
            meins  TYPE string,
            aplfz  TYPE string,
            mwskz  TYPE string,
            ekgrp  TYPE string,
            waers  TYPE string,
            netpr  TYPE string,
            peinh  TYPE string,
            bprme  TYPE string,
            datab  TYPE string,
            datbi  TYPE string,
            loekz  TYPE string,
            zcggcs TYPE string,
            zfllx  TYPE string,
            zflje  TYPE string,
            zcx    TYPE string,
            zyl001 TYPE string,
            verkf  TYPE string,
            telf1  TYPE string,
          END OF ty_entry,
          BEGIN OF ty_billbody,
            entry TYPE TABLE OF ty_entry WITH EMPTY KEY,
          END OF ty_billbody,
          BEGIN OF ty_bill,
            billbody TYPE ty_billbody,
          END OF ty_bill,
          BEGIN OF ty_data,
            bill TYPE ty_bill,
          END OF ty_data.

    DATA:gt_mapping       TYPE /ui2/cl_json=>name_mappings,
         gt_mapping_entry TYPE /ui2/cl_json=>name_mappings.

    DATA:gv_language TYPE i_language-languageisocode.


    DATA: gs_entry TYPE ty_entry.
    DATA: gs_resp TYPE zzs_mmi014_out.

    INTERFACES if_abap_parallel.
    METHODS constructor
      IMPORTING is_entry TYPE ty_entry.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_mm014_parallel IMPLEMENTATION.



  METHOD constructor.

    gs_entry = is_entry.

  ENDMETHOD.

  METHOD if_abap_parallel~do.


    DATA: ls_data TYPE ty_billbody.
    DATA: lr_mm009 TYPE REF TO zzcl_api_mm009.
    DATA: ls_req TYPE zzs_mmi009_req.
    DATA: ls_res TYPE zzs_rest_out.
    DATA: ls_basic TYPE zzs_mmi009_basic_in.
    DATA: ls_orgplant TYPE zzs_mmi009_org_in.
    DATA: ls_out TYPE zzs_mmi014_out.

    DATA(ls_entry) = gs_entry.
    CREATE OBJECT lr_mm009.
    "循环处理

    CLEAR: ls_req,ls_basic,ls_orgplant,ls_out.
    gs_resp-zguid = ls_entry-zguid.

    ls_basic-material = ls_entry-matnr.
    ls_basic-supplier = ls_entry-lifnr.
    ls_orgplant-purchasingorganization = ls_entry-ekorg.
    ls_orgplant-plant = ls_entry-werks.

    ls_orgplant-purchasinginforecordcategory = ls_entry-esokz.
    ls_basic-orderitemqtytobaseqtydnmntr  = '1'.
    ls_basic-orderitemqtytobaseqtynmrtr  = '1'.
    ls_basic-baseunit  = ls_entry-meins.
    ls_basic-purgdocorderquantityunit  = ls_entry-meins.
    ls_basic-supplierrespsalespersonname  = ls_entry-verkf.
    ls_basic-supplierphonenumber  = ls_entry-telf1.

    ls_orgplant-materialplanneddeliverydurn  = ls_entry-aplfz.
    IF ls_orgplant-materialplanneddeliverydurn = '0' OR ls_orgplant-materialplanneddeliverydurn = ''.
      ls_orgplant-materialplanneddeliverydurn = '1'.
    ENDIF.

    "税码
    SELECT SINGLE *
      FROM i_taxcoderate WITH PRIVILEGED ACCESS AS a
     WHERE a~country = 'CN'
       AND a~cndnrecordvaliditystartdate <= @sy-datum
       AND a~cndnrecordvalidityenddate >= @sy-datum
       AND a~taxtype = 'V'
       AND a~conditionrateratio = @ls_entry-mwskz
      INTO @DATA(ls_taxcoderate).
    IF sy-subrc = 0.
      ls_orgplant-taxcode  = ls_taxcoderate-taxcode.
    ENDIF.

    ls_orgplant-timedependenttaxvalidfromdate  = '20260101'.
    ls_orgplant-purchasinggroup  = ls_entry-ekgrp.
    ls_orgplant-standardpurchaseorderquantity  = '1'.
    IF ls_entry-ekgrp IS INITIAL AND ls_entry-zyl001 = 'GPM'.
      ls_orgplant-purchasinggroup = 'G01'.
    ENDIF.

    ls_orgplant-condition-conditiontype = ls_entry-kschl.
    "货币
    IF ls_entry-waers IS INITIAL.
      ls_entry-waers  = 'CNY'.
    ENDIF.
    ls_orgplant-currency  = ls_entry-waers.
    ls_orgplant-condition-conditioncurrency  = ls_entry-waers.
    "条件价格
    ls_orgplant-netpriceamount  = ls_entry-netpr.
    ls_orgplant-condition-conditionrateamount  = ls_entry-netpr.
    "价格单位
*      ls_orgplant-materialpriceunitqty  = ls_entry-peinh.
    ls_orgplant-condition-conditionquantity  = ls_entry-peinh.
    "订单价格单位

    "单位转化
    IF ls_entry-bprme IS INITIAL.
      ls_entry-bprme = ls_entry-meins.
    ELSE.
      IF ls_entry-bprme <> ls_entry-meins.
        SELECT SINGLE a~product,
                      a~alternativeunit ,
                      a~quantitynumerator,
                      a~quantitydenominator,
                      b~unitofmeasure_e
          FROM i_productunitsofmeasure WITH PRIVILEGED ACCESS AS a
          JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS b ON a~alternativeunit = b~unitofmeasure
                                                              AND b~language = 1
         WHERE a~product = @ls_entry-matnr
           AND b~unitofmeasure_e = @ls_entry-bprme
          INTO @DATA(lt_measure).
        IF sy-subrc = 0.
          ls_orgplant-orderpriceunittoorderunitnmrtr = lt_measure-quantitynumerator.
          ls_orgplant-ordpriceunittoorderunitdnmntr = lt_measure-quantitydenominator.
          CONDENSE ls_orgplant-orderpriceunittoorderunitnmrtr NO-GAPS.
          CONDENSE ls_orgplant-ordpriceunittoorderunitdnmntr NO-GAPS.
        ELSE.
          gs_resp-msgty = 'E'.
          gs_resp-msgtx = |价格未维护 { ls_entry-meins }单位与 { ls_entry-bprme }单位转换关系|.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.


    ls_orgplant-purchaseorderpriceunit  = ls_entry-bprme.
    ls_orgplant-condition-conditionquantityunit  = ls_entry-bprme.
    "开始生效日期
    ls_orgplant-condition-conditionvaliditystartdate  = ls_entry-datab.
    "有效截至日期
    ls_orgplant-condition-conditionvalidityenddate  = ls_entry-datbi.
    IF ls_entry-datab IS INITIAL OR  ls_entry-datbi IS INITIAL.
      gs_resp-msgty = 'E'.
      gs_resp-msgtx = '价格有效期缺失'.
      RETURN.
    ENDIF.

    ls_orgplant-condition-conditionisdeleted = ls_entry-loekz.
    ls_req-req-basic = ls_basic.
    ls_req-req-orgplant = ls_orgplant.

    "调用采购信息记录接口
    lr_mm009->inbound( EXPORTING i_req = ls_req IMPORTING o_resp = ls_res  ).


    gs_resp-infnr = ls_res-sapnum.
    gs_resp-msgty = ls_res-msgty.
    gs_resp-msgtx = ls_res-msgtx.

  ENDMETHOD.

ENDCLASS.
