CLASS zzcl_api_fi006 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_fii006_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_fii006_res.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI006 IMPLEMENTATION.


  METHOD inbound.

    DATA(ls_req) = i_req-data.

    IF ls_req-product IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请输入物料'.
      RETURN.
    ENDIF.

    IF ls_req-valuationarea IS INITIAL.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '请输入工厂'.
      RETURN.
    ENDIF.

    SELECT SINGLE
           product,
           valuationarea,
           standardprice,
           priceunitqty,
           fiscalyearcurrentperiod,
           fiscalmonthcurrentperiod

      FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
     WHERE product = @ls_req-product
       AND valuationarea =  @ls_req-valuationarea
      INTO @DATA(ls_productvaluation).

    IF sy-subrc = 0.
      o_resp-msgty = 'S'.
      o_resp-msgtx = '查询成功'.

      o_resp-msgdetail-fiscalyearcurrentperiod = ls_productvaluation-fiscalyearcurrentperiod.
      o_resp-msgdetail-fiscalmonthcurrentperiod = ls_productvaluation-fiscalmonthcurrentperiod.
      o_resp-msgdetail-product = ls_productvaluation-product.
      o_resp-msgdetail-valuationarea = ls_productvaluation-valuationarea.
      o_resp-msgdetail-quantityinbaseunit = ls_req-quantityinbaseunit.

      o_resp-msgdetail-zbzjg = ls_productvaluation-standardprice / ls_productvaluation-priceunitqty * ls_req-quantityinbaseunit.
    ELSE.
      o_resp-msgty = 'E'.
      o_resp-msgtx = '无数据'.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
