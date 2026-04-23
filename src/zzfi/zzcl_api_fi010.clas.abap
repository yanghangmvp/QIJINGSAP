CLASS zzcl_api_fi010 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA: gv_begin TYPE sy-datum .
    DATA: gv_end TYPE sy-datum .
    DATA: gv_current TYPE i.
    DATA: gv_times TYPE i.

    DATA: gt_zztfi007a TYPE TABLE OF zztfi007a,
          gs_zztfi007a TYPE zztfi007a.

    METHODS:constructor. "静态构造方法

    METHODS process
      IMPORTING
        iv_begin      TYPE sy-datum OPTIONAL
        iv_end        TYPE sy-datum OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS  push
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.


    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI010 IMPLEMENTATION.


  METHOD process.
    gv_begin = iv_begin.
    gv_end = iv_end.

    gv_current = 1.
    me->push( ).

    IF gv_times <> 1.
      gv_current =  gv_current + 1.
      WHILE gv_current <= gv_times.

        me->push( ).
        gv_current = gv_current + 1.
      ENDWHILE.
    ENDIF.

    "保存数据库
    "如果表里已经获取过，就删掉
    SELECT zztfi007a~*
      FROM zztfi007a
      JOIN @gt_zztfi007a AS a ON zztfi007a~recordid = a~recordid
      INTO TABLE @DATA(lt_zztfi007a).
    SORT lt_zztfi007a BY recordid.
    LOOP AT gt_zztfi007a INTO gs_zztfi007a.
      READ TABLE lt_zztfi007a TRANSPORTING NO FIELDS WITH KEY recordid = gs_zztfi007a-recordid BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE gt_zztfi007a.
      ENDIF.
    ENDLOOP.

    IF gt_zztfi007a IS NOT INITIAL.
      MODIFY zztfi007a FROM TABLE @gt_zztfi007a.
    ENDIF.

  ENDMETHOD.


  METHOD push.

    TYPES: BEGIN OF ty_reqdata,
             pagesize        TYPE i,
             pagenum         TYPE i,
             dealstate       TYPE i,
             recorddatestart TYPE string,
             recorddateend   TYPE string,
             unitno          TYPE string,
             accountno       TYPE string,
           END OF ty_reqdata,
           BEGIN OF ty_req,
             code      TYPE string,
             batchno   TYPE string,
             channelid TYPE string,
             sign      TYPE string,
             data      TYPE string,
           END OF ty_req.

    TYPES: BEGIN OF ty_accountrecordlist,
             recordid         TYPE string,
             unitno           TYPE string,
             unitname         TYPE string,
             accountno        TYPE string,
             accountname      TYPE string,
             accouttype       TYPE string,
             bankno           TYPE string,
             bankname         TYPE string,
             recorddate       TYPE string,
             balancedir       TYPE string,
             currencyno       TYPE string,
             amount           TYPE string,
             balance          TYPE string,
             opaccountno      TYPE string,
             opaccountname    TYPE string,
             opbranchbankname TYPE string,
             hostid           TYPE string,
             ticketn          TYPE string,
             summary          TYPE string,
             remark           TYPE string,
             postscript       TYPE string,
             hosttime         TYPE string,
           END OF ty_accountrecordlist,
           BEGIN OF ty_resdata,
             totalsize         TYPE string,
             pagesize          TYPE string,
             accountrecordlist TYPE TABLE OF ty_accountrecordlist WITH EMPTY KEY,
           END OF ty_resdata,
           BEGIN OF ty_res,
             code       TYPE string,
             batchno    TYPE string,
             channelid  TYPE string,
             resultcode TYPE string,
             resultmsg  TYPE string,
             data       TYPE ty_resdata,
           END OF ty_res.


    DATA:ls_req      TYPE ty_req,
         ls_req_data TYPE ty_reqdata,
         ls_req_json TYPE string,
         ls_res      TYPE ty_res,
         ls_res_json TYPE string,
         lv_msgty    TYPE bapi_mtype,
         lv_msgtx    TYPE bapi_msg.
    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb VALUE 'FII010'.


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

    ls_req_data-recorddatestart = |{ gv_begin+0(4) }-{  gv_begin+4(2) }-{ gv_begin+6(2) }|.
    ls_req_data-recorddateend = |{ gv_end+0(4) }-{  gv_end+4(2) }-{ gv_end+6(2) }|.
    ls_req_data-pagesize = '500'.
    ls_req_data-pagenum = gv_current.
    ls_req_data-dealstate = 1.
    ls_req_data-unitno = 'GH00'.

    DATA(lv_unix_timestamp) = xco_cp=>sy->unix_timestamp( )->value.
    ls_req-code = 'AIMS-QY003'.
    ls_req-batchno = 'QY003' && lv_unix_timestamp.
    ls_req-channelid = ls_conf-zztkurl.

    DATA(lv_data) =  /ui2/cl_json=>serialize( data          = ls_req_data
                                              compress      = abap_true
                                              name_mappings = gt_mapping ).

    ls_req-sign = lo_sk->get_fingercode( ).
    ls_req-data = lo_sk->get_encrypt( lv_data ).

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



    /ui2/cl_json=>deserialize( EXPORTING json        = ls_res_json
                                           pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                 CHANGING  data      = ls_res ).

    LOOP AT ls_res-data-accountrecordlist INTO DATA(ls_list).
      CLEAR: gs_zztfi007a.
      MOVE-CORRESPONDING ls_list TO gs_zztfi007a.
      gs_zztfi007a-recorddate = ls_list-recorddate+0(4) && ls_list-recorddate+5(2) && ls_list-recorddate+8(2).
      IF ls_list-hosttime IS NOT INITIAL.
        gs_zztfi007a-hosttime = ls_list-hosttime+11(2) && ls_list-hosttime+14(2) && ls_list-hosttime+17(2).
      ENDIF.

      IF gs_zztfi007a-unitno IS INITIAL.
        gs_zztfi007a-unitno = 'GH00'.
      ENDIF.
      gs_zztfi007a-status = '10'.
      APPEND gs_zztfi007a TO gt_zztfi007a.
    ENDLOOP.

    IF gv_times = 0.
      gv_times = ceil( CONV decfloat16( ls_res-data-totalsize / 500 ) ).
    ENDIF.
*&---接口日志---BEGIN---
    "处理特殊返回结构
*    DATA:ls_log TYPE zzt_rest_log.
*    ls_log = lo_sk->zzif_rest_api~ms_log.
*
*    IF ls_res-resultcode = '000000'.
*      ls_log-msgty = 'S'.
*    ENDIF.
*
*    CALL METHOD lo_sk->zzif_rest_api~set_log
*      EXPORTING
*        is_log = ls_log.
*&---接口日志---END---

  ENDMETHOD.


  METHOD constructor.
*&---导入结构JSON MAPPING
    gt_mapping = VALUE #(
         ( abap = 'recordDateStart'                    json = 'recordDateStart'   )
         ( abap = 'recordDateEnd'                      json = 'recordDateEnd'     )
         ( abap = 'dealState'                          json = 'dealState'     )
         ( abap = 'data'                               json = 'data'              )
         ( abap = 'channelId'                          json = 'channelId'         )
         ( abap = 'accountNo'                          json = 'accountNo'         )
         ( abap = 'code'                               json = 'code'              )
         ( abap = 'batchNo'                            json = 'batchNo'           )
         ( abap = 'fingerCode'                         json = 'fingerCode'        )
         ( abap = 'pageSize'                           json = 'pageSize'          )
         ( abap = 'pageNum'                            json = 'pageNum'           )
         ( abap = 'sign'                               json = 'sign'              )
         ( abap = 'unitNo'                             json = 'unitNo'              )
         ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    me->process( iv_begin = '20260401'  iv_end = '20260418' ).
  ENDMETHOD.
ENDCLASS.
