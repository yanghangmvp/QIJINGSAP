FUNCTION zzfm_sd_001.
*"----------------------------------------------------------------------
*"*"本地接口：
*"  IMPORTING
*"     REFERENCE(IV_NUM) TYPE  ZZTSD001-PURCHASEORDERBYCUSTOMER
*"----------------------------------------------------------------------

  DATA ls_req TYPE zzs_sdi003_req.
  DATA o_resp TYPE zzs_rest_out.
  DATA lr_sd003 TYPE REF TO zzcl_api_sd003.

  SELECT SINGLE *
    FROM zztsd001
   WHERE purchaseorderbycustomer = @iv_num
    INTO @DATA(ls_zztsd001).


  GET TIME STAMP FIELD ls_zztsd001-last_changed_at.
  CHECK ls_zztsd001-zzxzt = '03'.

  ls_req-data-deliverydocument = ls_zztsd001-deliverydocument.
  ls_req-data-proofofdeliverydate = xco_cp=>sy->date( )->as( xco_cp_time=>format->iso_8601_basic )->value.
  ls_req-data-proofofdeliverytime = xco_cp=>sy->time( )->as( xco_cp_time=>format->iso_8601_basic )->value.

  CREATE OBJECT lr_sd003.
  CALL METHOD lr_sd003->inbound
    EXPORTING
      i_req  = ls_req
    IMPORTING
      o_resp = o_resp.


ENDFUNCTION.
