CLASS zzcl_api_fi009 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.

    METHODS:constructor. "静态构造方法

    METHODS process
      IMPORTING
        iv_begin      TYPE sy-datum OPTIONAL
        iv_bukrs      TYPE bukrs OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS push
      IMPORTING
        i_req         TYPE zzt_fii009_in OPTIONAL
        job_ranges    TYPE if_rap_query_filter=>tt_name_range_pairs OPTIONAL
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_FI009 IMPLEMENTATION.


  METHOD process.

    DATA:lt_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA:ls_ranges LIKE LINE OF lt_ranges.
    DATA:lt_range TYPE if_rap_query_filter=>tt_range_option.
    DATA:ls_range LIKE LINE OF lt_range.


    IF iv_begin IS INITIAL OR iv_bukrs IS INITIAL.
      EXIT.
    ENDIF.

    CLEAR ls_range.
    CLEAR lt_range.
    CLEAR ls_ranges.
    CLEAR lt_ranges.
    ls_range-sign = 'I'.
    ls_range-option = 'EQ'.
    ls_range-low = iv_begin.
    APPEND ls_range TO lt_range.
    ls_ranges-name = 'POSTDATE'.
    ls_ranges-range = lt_range.
    APPEND ls_ranges TO lt_ranges.

    CLEAR ls_range.
    CLEAR lt_range.
    CLEAR ls_ranges.
    ls_range-sign = 'I'.
    ls_range-option = 'EQ'.
    ls_range-low = iv_bukrs.
    APPEND ls_range TO lt_range.
    ls_ranges-name = 'COMPANYCODE'.
    ls_ranges-range = lt_range.
    APPEND ls_ranges TO lt_ranges.

    me->push( job_ranges = lt_ranges ).

  ENDMETHOD.


  METHOD push.

    TYPES: BEGIN OF typ_records,
             channel       TYPE string,
             channelname   TYPE string,
             companycode   TYPE string,
             companyname   TYPE string,
             year          TYPE string,
             month         TYPE string,
             glaccount     TYPE string,
             glaccountname TYPE string,
             bankaccount   TYPE string,
             currency      TYPE string,
             beginbalance  TYPE string,
             begindirect   TYPE string,
             endbalance    TYPE string,
             enddirect     TYPE string,
             balancedate   TYPE string,
             timestamp     TYPE string,
           END OF typ_records.

    DATA:lt_records TYPE TABLE OF typ_records,
         ls_records TYPE  typ_records.

    tyPES:BEGIN OF TYP_data,
          records like lt_records,
          enD OF TYP_data.

    daTA :lv_datajson tYPE TYP_data.



    TYPES: BEGIN OF typ_json,
             code       TYPE string,
             batchno    TYPE zzeuuid,
             channelid  TYPE string,
             data       TYPE STRING,
*             fingercode TYPE string,
             sign       TYPE string,
           END OF typ_json.

    DATA:lt_data TYPE TABLE OF typ_json,
         ls_data TYPE  typ_json.

    DATA:lv_json_data TYPE string.
    DATA: lr_fi009 TYPE REF TO zzcl_query_fi009.
    DATA:lv_oref TYPE zzefname,
         lt_ptab TYPE abap_parmbind_tab.
    DATA:lv_numb TYPE zzenumb VALUE 'FII009'.
    DATA:lv_data TYPE string.
    DATA:lv_msgty TYPE bapi_mtype,
         lv_msgtx TYPE bapi_msg,
         lv_resp  TYPE string.

    "获取数据
    DATA:it_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA:lt_range TYPE if_rap_query_filter=>tt_range_option.
    LOOP AT i_req INTO DATA(ls_key).
      APPEND VALUE #( low = ls_key
                      sign = 'I'
                      option = 'EQ'  ) TO lt_range.
    ENDLOOP.
    IF lt_range IS NOT INITIAL.
      APPEND VALUE #(  name = 'UUID'
                       range = lt_range
      ) TO it_ranges.
    ENDIF.

    IF job_ranges IS NOT INITIAL.
      MOVE-CORRESPONDING job_ranges TO it_ranges.
    ENDIF.

    "获取数据
    CREATE OBJECT lr_fi009.
    CALL METHOD lr_fi009->get_data
      EXPORTING
        it_ranges = it_ranges
      IMPORTING
        et_data   = DATA(lt_result).

    DATA:lv_channelname      TYPE string,
         lv_channel          TYPE string,
         lv_code             TYPE string,
         lv_channelid        TYPE string,
         lv_channel_id       TYPE string,
         lv_finger_code_salt TYPE string,
         lv_aes_key          TYPE string.


    SELECT * FROM zc_zt_rest_append
    WHERE zznumb = @lv_numb
    AND zzappac = 'PUSH'
    INTO TABLE @DATA(lt_append).

    LOOP AT lt_append INTO DATA(ls_append).
      CASE ls_append-zzappkey.
        WHEN 'CHANNELNAME'."系统名称
          lv_channelname = ls_append-zzappvalue.
        WHEN 'CHANNEL'."系统编号
          lv_channel = ls_append-zzappvalue.
        WHEN 'CHANNELID'."发起渠道
          lv_channelid = ls_append-zzappvalue.
        WHEN 'CODE'."接口编号 RPM_TX001
          lv_code = ls_append-zzappvalue.
        WHEN 'CHANNEL_ID'."MD5渠道号
          lv_channel_id = ls_append-zzappvalue.
        WHEN 'FINGER_CODE_SALT'."MD5盐值
          lv_finger_code_salt = ls_append-zzappvalue.
        WHEN 'AES_KEY'."AESKEY
          lv_aes_key = ls_append-zzappvalue.
      ENDCASE.
    ENDLOOP.



    "整理数据
    LOOP AT  lt_result INTO DATA(ls_result).
      CLEAR: ls_data.
      MOVE-CORRESPONDING ls_result TO ls_records.
      ls_records-channel = lv_channel. "'GHSAP'.
      ls_records-channelname = lv_channelname."'华望SAP'.
      ls_records-year = ls_result-postdate(4).
      ls_records-month = ls_result-postdate(6).
      ls_records-balancedate = ls_result-postdate.
      CONDENSE ls_records-beginbalance NO-GAPS.
      CONDENSE ls_records-endbalance NO-GAPS.
      APPEND ls_records TO lt_records.
    ENDLOOP.

*    DATA(lv_unix_timestamp) = xco_cp=>sy->unix_timestamp( )->value.

    TRY .
        DATA(lv_uuid_c32) = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
      CATCH cx_uuid_error.
        IF 1 = 1 .
        ENDIF.
    ENDTRY.
    ls_data-batchno = lv_uuid_c32."接口UUID
    ls_data-code = lv_code."'AIMS-QY003'.接口名
    ls_data-channelid = lv_channelid."'ERP'.渠道编号
*    ls_data-data-records = lt_records.
    lv_datajson-records = lt_records.

*    DATA JSON
    lv_json_data = /ui2/cl_json=>serialize( EXPORTING data          = lv_datajson
                                                      compress      = abap_true
                                                      name_mappings = gt_mapping ).

    "MD5
    IF lv_channel_id IS NOT INITIAL AND lv_finger_code_salt IS NOT INITIAL.
      DATA lv_md5 TYPE string.
      lv_md5 = lv_channel_id && lv_finger_code_salt.
      TRY.
          cl_abap_message_digest=>calculate_hash_for_char(
            EXPORTING
               if_algorithm     = 'MD5'
               if_data          = lv_md5
*             if_length        = v_zip_size
             IMPORTING
              ef_hashstring    = ls_data-sign

                 ).
        CATCH cx_abap_message_digest .
      ENDTRY.

    ENDIF.

    TRANSLATE ls_data-sign TO LOWER CASE.

    IF lv_aes_key IS NOT INITIAL AND  lv_json_data IS NOT INITIAL.
      DATA :lv_input_xs      TYPE xstring,
            lv_key_xs        TYPE xstring,
            lv_key_xs16      TYPE x LENGTH 16,
            lv_key_xs_string TYPE string,
            lv_padded        TYPE xstring,
            lv_encrypted     TYPE xstring, " 加密结果
            lv_base64        TYPE string.   " 最终输出（传给接口）


      lv_input_xs = /ui2/cl_json=>string_to_raw(
       EXPORTING iv_string   = lv_json_data
       iv_encoding = '4110' ).

*      lv_key_xs = /ui2/cl_json=>string_to_raw(
*       EXPORTING iv_string   = lv_aes_key
*       iv_encoding = '4110' ).
*
*      lv_key_xs16 = lv_key_xs.
*      lv_key_xs = lv_key_xs16.
       lv_key_xs = lv_aes_key.


      CALL METHOD zcl_aes_utility=>encrypt_xstring
        EXPORTING
          i_key              = lv_key_xs
          i_data             = lv_input_xs
          i_encryption_mode  = zcl_aes_utility=>mc_encryption_mode_ecb  " ECB 模式
          i_padding_standard = zcl_byte_padding_utility=>mc_padding_standard_pkcs_7
        IMPORTING
          e_data             = lv_encrypted.

      lv_base64 = cl_web_http_utility=>encode_x_base64( lv_encrypted ).

    ENDIF.

    ls_data-data = lv_base64.

*   完整报文JSON
    CLEAR lv_json_data.
    lv_json_data = /ui2/cl_json=>serialize( EXPORTING data          = ls_data
                                                      compress      = abap_true
                                                      name_mappings = gt_mapping ).

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
            iv_data  = lv_json_data
            iv_uuid  = ls_data-batchno
          CHANGING
            ev_resp  = lv_resp
            ev_msgty = lv_msgty
            ev_msgtx = lv_msgtx.
      CATCH cx_root INTO DATA(lr_root).
    ENDTRY.

    o_resp-msgty = lv_msgty.
    o_resp-msgtx = lv_msgtx.

  ENDMETHOD.


  METHOD constructor.

    gt_mapping = VALUE #(
         ( abap = 'channel'         json = 'channel'      )
         ( abap = 'channelName'     json = 'channelName'  )
         ( abap = 'companycode'     json = 'unitNo'       )
         ( abap = 'companyname'     json = 'unitName'     )
         ( abap = 'year'            json = 'year'         )
         ( abap = 'month'           json = 'month'        )
         ( abap = 'glaccount'       json = 'dispcode'     )
         ( abap = 'glaccountname'   json = 'dispname'     )
         ( abap = 'bankaccount'     json = 'bankaccsub'   )
         ( abap = 'currency'        json = 'currencyNo'   )
         ( abap = 'beginBalance'    json = 'beginBalance' )
         ( abap = 'begindirect'     json = 'beginDirect'  )
         ( abap = 'endbalance'      json = 'endBalance'   )
         ( abap = 'enddirect'       json = 'endDirect'    )
         ( abap = 'timestamp'       json = 'ts'           )
         ( abap = 'code'            json = 'code'         )
         ( abap = 'batchno'         json = 'batchNo'      )
         ( abap = 'channelid'       json = 'channelId'    )
         ( abap = 'data'            json = 'data'         )
         ( abap = 'balancedate'     json = 'balanceDate'  )
         ( abap = 'sign'            json = 'sign'  )
         ( abap = 'records'         json = 'records'  )

         ).

  ENDMETHOD.
ENDCLASS.
