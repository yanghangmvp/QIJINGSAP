CLASS zzcl_job_vl_process DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:BEGIN OF ty_deliverydocumentitem,
            actualdeliveredqtyinbaseunit TYPE string,
            actualdeliveryquantity       TYPE string,
            batch                        TYPE string,
            deliverydocument             TYPE string,
            deliverydocumentitemtext     TYPE string,
            deliveryquantityunit         TYPE string,
            eudeliveryitemarcstatus      TYPE string,
            inventoryvaluationtype       TYPE string,
            itemgrossweight              TYPE string,
            itemnetweight                TYPE string,
            itemvolume                   TYPE string,
            itemvolumeunit               TYPE string,
            itemweightunit               TYPE string,
            manufacturedate              TYPE string,
            materialbycustomer           TYPE string,
            referencesddocument          TYPE string,
            referencesddocumentitem      TYPE string,
            shelflifeexpirationdate      TYPE string,
            storagelocation              TYPE string,
            serialnumber                 TYPE string,
          END OF ty_deliverydocumentitem,
          BEGIN OF tty_deliverydocumentitem,
            results TYPE TABLE OF ty_deliverydocumentitem WITH EMPTY KEY,
          END OF tty_deliverydocumentitem,
          BEGIN OF ty_deliverydocumenthead,
            actualgoodsmovementdate    TYPE string,
            billoflading               TYPE string,
            deliveryblockreason        TYPE string,
            deliverydate               TYPE string,
            deliverydocumentbysupplier TYPE string,
            deliverypriority           TYPE string,
            deliverytime               TYPE string,
            goodsissuetime             TYPE string,
            headergrossweight          TYPE string,
            headernetweight            TYPE string,
            headervolume               TYPE string,
            headervolumeunit           TYPE string,
            headerweightunit           TYPE string,
            incotermsclassification    TYPE string,
            incotermstransferlocation  TYPE string,
            loadingdate                TYPE string,
            loadingtime                TYPE string,
            meansoftransport           TYPE string,
            meansoftransporttype       TYPE string,
            pickingdate                TYPE string,
            pickingtime                TYPE string,
            plannedgoodsissuedate      TYPE string,
            proposeddeliveryroute      TYPE string,
            shippingpoint              TYPE string,
            transportationplanningdate TYPE string,
            transportationplanningtime TYPE string,
            unloadingpointname         TYPE string,
            to_deliverydocumentitem    TYPE tty_deliverydocumentitem,
          END OF ty_deliverydocumenthead.
    TYPES:BEGIN OF ty_data,
            deliverydocument       TYPE  i_deliverydocumentitem-deliverydocument,
            deliverydocumentitem   TYPE  i_deliverydocumentitem-deliverydocumentitem,
            salesdocument          TYPE  i_salesdocumentitem-salesdocument,
            salesdocumentitem      TYPE  i_salesdocumentitem-salesdocumentitem,
            storagelocation        TYPE  i_deliverydocumentitem-storagelocation,
            actualdeliveryquantity TYPE  i_deliverydocumentitem-actualdeliveryquantity,
            batch                  TYPE  i_deliverydocumentitem-batch,
            deliveryquantityunit   TYPE  i_deliverydocumentitem-baseunit,
          END OF ty_data.
    TYPES:BEGIN OF ty_create,
            referencesddocument     TYPE i_deliverydocumentitem-deliverydocument,
            referencesddocumentitem TYPE i_deliverydocumentitem-deliverydocumentitem,
            actualdeliveryquantity  TYPE i_deliverydocumentitem-actualdeliveryquantity,
            deliveryquantityunit    TYPE i_deliverydocumentitem-deliveryquantityunit,
          END OF ty_create.

    TYPES:BEGIN OF ty_control,
            defaultbillingdocumentdate    TYPE string,
            defaultbillingdocumenttype    TYPE string,
            autompostingtoacctgisdisabled TYPE string,
            cutoffbillingdocumentdate     TYPE string,
          END OF ty_control,
          BEGIN OF ty_reference,
            sddocument          TYPE string,
            billingdocumenttype TYPE string,
            billingdocumentdate TYPE string,
            destinationcountry  TYPE string,
            salesorganization   TYPE string,
            sddocumentcategory  TYPE string,
          END OF ty_reference,
          BEGIN OF ty_grdata,
            _control   TYPE ty_control,
            _reference TYPE TABLE OF ty_reference WITH EMPTY KEY,
          END OF ty_grdata.


    DATA:gv_srv TYPE string.
    DATA:gv_flowhead TYPE string.
    DATA:gv_flowitem TYPE string.
    DATA:gv_deliverydocument TYPE i_deliverydocument-deliverydocument.
    DATA:gv_salesdocument    TYPE i_salesdocument-salesdocument.
    DATA:gv_sddocumentcategory TYPE i_deliverydocument-sddocumentcategory.
    DATA:gv_num TYPE zztsd001-purchaseorderbycustomer.
    DATA:gs_data TYPE ty_data.
    DATA:gt_create TYPE TABLE OF ty_create.
    DATA:gs_head TYPE ty_deliverydocumenthead.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    METHODS:constructor
      IMPORTING
        iv_num TYPE zztsd001-purchaseorderbycustomer. "静态构造方法

    METHODS create_vl
      RETURNING VALUE(o_resp) TYPE zzs_rest_out.

    METHODS pick_vl
      RETURNING VALUE(o_resp) TYPE zzs_rest_out.

    METHODS post_vl
      RETURNING VALUE(o_resp) TYPE zzs_rest_out.

    METHODS pod_vl
      RETURNING VALUE(o_resp) TYPE zzs_rest_out.

    METHODS create_gr
      RETURNING VALUE(o_resp) TYPE zzs_rest_out.

    METHODS post_gr
      RETURNING VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_JOB_VL_PROCESS IMPLEMENTATION.


  METHOD create_vl.
    "创建交货单
    DATA:lv_json TYPE string.
    DATA:ls_cdata  TYPE ty_deliverydocumenthead.


    SELECT SINGLE *
      FROM zztsd001
     WHERE purchaseorderbycustomer = @gv_num
      INTO @DATA(ls_zztsd001).

    CHECK ls_zztsd001-zzxzt = ''.

    SELECT *
       FROM zztsd002
      WHERE purchaseorderbycustomer = @gv_num
       INTO TABLE @DATA(lt_zztsd002).

    "获取销售订单类型
    SELECT a~salesdocument,
           a~salesdocumentitem,
           a~sddocumentcategory,
           a~orderquantityunit,
           a~baseunit,
           a~product,
           a~ordertobasequantitydnmntr,
           a~ordertobasequantitynmrtr
      FROM i_salesdocumentitem WITH PRIVILEGED ACCESS AS a
     WHERE a~salesdocument = @ls_zztsd001-salesdocument
      INTO TABLE @DATA(lt_salesdocumentitem).

    LOOP AT lt_zztsd002 INTO DATA(ls_zztsd002).
      APPEND INITIAL LINE TO ls_cdata-to_deliverydocumentitem-results ASSIGNING FIELD-SYMBOL(<fs_item>).
      <fs_item>-referencesddocument = ls_zztsd001-salesdocument.
      <fs_item>-referencesddocumentitem = ls_zztsd002-salesdocumentitem.
      <fs_item>-actualdeliveryquantity = ls_zztsd002-orderquantity.
      <fs_item>-deliveryquantityunit = ls_zztsd002-orderquantityunit.

      IF ls_zztsd002-orderquantityunit IS INITIAL.
        READ TABLE lt_salesdocumentitem INTO DATA(ls_salesdocumentitem) WITH KEY salesdocument = ls_zztsd001-salesdocument
                                                                           salesdocumentitem = ls_zztsd002-salesdocumentitem.
        IF sy-subrc = 0.
          <fs_item>-deliveryquantityunit = ls_salesdocumentitem-orderquantityunit.
        ENDIF.
      ENDIF.

      CONDENSE <fs_item>-actualdeliveryquantity NO-GAPS.
    ENDLOOP.

    IF gv_sddocumentcategory = 'C'.
      ls_cdata-shippingpoint = '1000'.
    ELSEIF gv_sddocumentcategory = 'H'.
      ls_cdata-shippingpoint = '100R'.
    ENDIF.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/{ gv_srv };v=0002/| && gv_flowhead &&
                      |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping )..

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '201'.
      TYPES:BEGIN OF ty_heads,
              deliverydocument TYPE string,
            END OF ty_heads,
            BEGIN OF ty_ress,
              d TYPE ty_heads,
            END OF  ty_ress.
      DATA:ls_ress TYPE ty_ress.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_ress ).

      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.

      gv_deliverydocument = ls_ress-d-deliverydocument.
      gv_deliverydocument = |{ gv_deliverydocument ALPHA = IN }|.

      GET TIME STAMP FIELD ls_zztsd001-last_changed_at.
      UPDATE zztsd001 SET deliverydocument = @gv_deliverydocument,
                          msgty = 'S',
                          zzxzt = '01',
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
       WHERE purchaseorderbycustomer = @gv_num.

    ELSE.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = '创建交货单出错:' && ls_rese-error-message-value .

      UPDATE zztsd001 SET  msgty = 'E',
                           msgtx = @o_resp-msgtx,
                           last_changed_by  = @sy-uname,
                           last_changed_at  = @ls_zztsd001-last_changed_at
       WHERE purchaseorderbycustomer = @gv_num.
    ENDIF.

  ENDMETHOD.


  METHOD pick_vl.

    SELECT SINGLE *
      FROM zztsd001
     WHERE purchaseorderbycustomer = @gv_num
      INTO @DATA(ls_zztsd001).

    GET TIME STAMP FIELD ls_zztsd001-last_changed_at.
    CHECK ls_zztsd001-zzxzt = '01'.

    gv_deliverydocument = ls_zztsd001-deliverydocument.

    SELECT *
       FROM zztsd002
      WHERE purchaseorderbycustomer = @gv_num
       INTO TABLE @DATA(lt_zztsd002).

    "获取已创建的交货单
    SELECT deliverydocument,
           deliverydocumentitem,
           referencesddocument,
           referencesddocumentitem,
           material
      FROM i_deliverydocumentitem WITH PRIVILEGED ACCESS
     WHERE deliverydocument = @ls_zztsd001-deliverydocument
       AND goodsmovementstatus = 'A'
      INTO TABLE @DATA(lt_lips).


    LOOP AT lt_lips INTO DATA(ls_lips).
      READ TABLE lt_zztsd002 INTO DATA(ls_zztsd002) WITH KEY salesdocumentitem = ls_lips-referencesddocumentitem.

      "更新序列号
      IF ls_zztsd002-serialnumber IS NOT INITIAL.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'GET'.
        gs_http_req-url = |/{ gv_srv };v=0002/A_OutbDeliveryItem(| &&
                          |DeliveryDocument='{ ls_lips-deliverydocument }',| &&
                          |DeliveryDocumentItem='{ ls_lips-deliverydocumentitem }')|  .
        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
        DATA(lv_etag) = gs_http_resp-etag.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-etag = lv_etag.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/{ gv_srv };v=0002/AddSerialNumberToDeliveryItem?| &&
                          |DeliveryDocument='{ ls_lips-deliverydocument }'&| &&
                          |DeliveryDocumentItem='{ ls_lips-deliverydocumentitem }'&|  &&
                          |SerialNumber='{ ls_zztsd002-serialnumber }'&|  &&
                          |?sap-language={ gv_language }|..
        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
        IF gs_http_resp-code <> '200'.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = '序列号更新失败:' && ls_rese-error-message-value .

          UPDATE zztsd001 SET  msgty = 'E',
                    msgtx = @o_resp-msgtx,
                    last_changed_by  = @sy-uname,
                    last_changed_at  = @ls_zztsd001-last_changed_at
           WHERE purchaseorderbycustomer = @gv_num.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.


*    CLEAR: gs_http_req,gs_http_resp.
*    gs_http_req-version = 'ODATAV2'.
*    gs_http_req-method = 'POST'.
*    gs_http_req-etag = '*'.
*    gs_http_req-url = |/{ gv_srv };v=0002/| && |PickAllItems?DeliveryDocument={ gv_deliverydocument }| &&
*                      |&sap-language={ gv_language }|.
*    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
*
*    IF gs_http_resp-code <> '200'.
*      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
*                                  CHANGING data  = ls_rese ).
*      o_resp-msgty = 'E'.
*      o_resp-msgtx = '拣配失败:' && ls_rese-error-message-value .
*
*      UPDATE zztsd001 SET  msgty = 'E',
*                msgtx = @o_resp-msgtx,
*                last_changed_by  = @sy-uname,
*                last_changed_at  = @ls_zztsd001-last_changed_at
*       WHERE purchaseorderbycustomer = @gv_num.
*      RETURN.
*    ENDIF.
    IF o_resp-msgty <> 'E'.
      o_resp-msgty = 'S'.
      o_resp-msgtx  = 'Success'.
      UPDATE zztsd001 SET msgty = 'S',
                          zzxzt = '02',
                          msgtx = @o_resp-msgtx,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
      WHERE purchaseorderbycustomer = @gv_num.
    ENDIF.



  ENDMETHOD.


  METHOD post_vl.

    SELECT SINGLE *
      FROM zztsd001
     WHERE purchaseorderbycustomer = @gv_num
      INTO @DATA(ls_zztsd001).
    gv_deliverydocument = ls_zztsd001-deliverydocument.
    GET TIME STAMP FIELD ls_zztsd001-last_changed_at.
    CHECK ls_zztsd001-zzxzt = '02'.

    "更新抬头
    CLEAR: gs_head.
    gv_deliverydocument = ls_zztsd001-deliverydocument.
    "更新抬头日期
    gs_head-actualgoodsmovementdate = ls_zztsd001-salesdocumentdate.
    gs_head-actualgoodsmovementdate = zzcl_comm_tool=>date2iso( gs_head-actualgoodsmovementdate ).
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'PATCH'.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize(
              data          = gs_head
              compress      = abap_true
              name_mappings = gt_mapping )..
    gs_http_req-url = |/{ gv_srv };v=0002/{ gv_flowhead }('{ gv_deliverydocument }')|  &&
                               |?sap-language={ gv_language }|.
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).
    IF gs_http_resp-code <> '204'.
      DATA:ls_rese TYPE zzs_odata_fail.
      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = '抬头失败:' && ls_rese-error-message-value .

      UPDATE zztsd001 SET  msgty = 'E',
                           msgtx = @o_resp-msgtx,
                           last_changed_by  = @sy-uname,
                           last_changed_at  = @ls_zztsd001-last_changed_at
       WHERE purchaseorderbycustomer = @gv_num.
      RETURN.
    ENDIF.


    "过账
    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV2'.
    gs_http_req-method = 'POST'.
    gs_http_req-etag = '*'.

    CASE gv_srv.
      WHEN 'API_OUTBOUND_DELIVERY_SRV'.
        DATA(lv_uri_path) = |/{ gv_srv };v=0002/PostGoodsIssue?| &&
                            |DeliveryDocument='{ gv_deliverydocument }'| &&
                            |&sap-language={ gv_language }|.
      WHEN 'API_CUSTOMER_RETURNS_DELIVERY_SRV'.
        lv_uri_path = |/{ gv_srv };v=0002/PostGoodsReceipt?|  &&
                      |DeliveryDocument='{ gv_deliverydocument }'| &&
                      |&sap-language={ gv_language }|.
    ENDCASE.
    gs_http_req-url = lv_uri_path.
    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '200'.
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'Success'.

      UPDATE zztsd001 SET msgty = 'S',
                          zzxzt = '03',
                          msgtx  = @o_resp-msgtx,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
       WHERE purchaseorderbycustomer = @gv_num.
    ELSE.

      /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                  CHANGING data  = ls_rese ).
      o_resp-msgty = 'E'.
      o_resp-msgtx = '交货单过账失败:' && ls_rese-error-message-value .

      UPDATE zztsd001 SET msgty = 'E',
                          msgtx  = @o_resp-msgtx,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
        WHERE purchaseorderbycustomer = @gv_num.
    ENDIF.


  ENDMETHOD.


  METHOD pod_vl.

    DATA ls_req TYPE zzs_sdi003_req.
    DATA lr_sd003 TYPE REF TO zzcl_api_sd003.

    SELECT SINGLE *
      FROM zztsd001
     WHERE purchaseorderbycustomer = @gv_num
      INTO @DATA(ls_zztsd001).
    gv_deliverydocument = ls_zztsd001-deliverydocument.

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

    IF o_resp-msgty = 'S'.

      DO 10 TIMES.
        SELECT SINGLE deliverydocument,overallproofofdeliverystatus
          FROM i_deliverydocument WITH PRIVILEGED ACCESS
         WHERE deliverydocument = @ls_zztsd001-deliverydocument
          INTO @DATA(ls_delivery).
        IF ls_delivery-overallproofofdeliverystatus = 'C'.
          EXIT.
        ENDIF.
        WAIT UP TO 1 SECONDS.
      ENDDO.

      UPDATE zztsd001 SET msgty = 'S',
                          zzxzt = '04',
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
                    WHERE purchaseorderbycustomer = @gv_num.
    ELSE.
      UPDATE zztsd001 SET msgty = 'E',
                          msgtx = @o_resp-msgtx,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
                    WHERE purchaseorderbycustomer = @gv_num.
    ENDIF.

  ENDMETHOD.


  METHOD create_gr.

    TYPES:BEGIN OF ty_control,
            defaultbillingdocumentdate    TYPE string,
            defaultbillingdocumenttype    TYPE string,
            autompostingtoacctgisdisabled TYPE abap_bool,
            cutoffbillingdocumentdate     TYPE string,
            yy1_fphm_bdh                  TYPE string,
            yy1_jsdh_bdh                  TYPE string,
          END OF ty_control,
          BEGIN OF ty_reference,
            sddocument          TYPE string,
            billingdocumenttype TYPE string,
            billingdocumentdate TYPE string,
            destinationcountry  TYPE string,
            salesorganization   TYPE string,
            sddocumentcategory  TYPE string,
          END OF ty_reference,
          BEGIN OF ty_data,
            _control   TYPE ty_control,
            _reference TYPE TABLE OF ty_reference WITH EMPTY KEY,
          END OF ty_data.

    SELECT SINGLE *
      FROM zztsd001
     WHERE purchaseorderbycustomer = @gv_num
      INTO @DATA(ls_zztsd001).

    GET TIME STAMP FIELD ls_zztsd001-last_changed_at.
    CHECK ls_zztsd001-zzxzt = '04'.


    DATA: lv_json TYPE string.
    DATA ls_data TYPE ty_data.

    "抬头
    DATA(lv_data) = xco_cp=>sy->date( )->as( xco_cp_time=>format->iso_8601_extended )->value.
    ls_data-_control-defaultbillingdocumentdate = lv_data.
    ls_data-_control-autompostingtoacctgisdisabled = 'X'.
    "行项目

    APPEND VALUE #(
            sddocument = ls_zztsd001-deliverydocument
     ) TO ls_data-_reference.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV4'.
    gs_http_req-method = 'POST'.
    gs_http_req-url = |/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/SAP__self.CreateFromSDDocument| &&
                      |?sap-language={ gv_language }|.
    "传入数据转JSON
    gs_http_req-body = /ui2/cl_json=>serialize( data          = ls_data
                                   compress      = abap_true
                                   name_mappings = gt_mapping ).

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '200'.
      TYPES:BEGIN OF ty_value,
              billingdocument TYPE string,
            END OF ty_value.
      TYPES: BEGIN OF ty_ress,
               value TYPE TABLE OF ty_value WITH EMPTY KEY,
             END OF  ty_ress.
      DATA ls_ress TYPE ty_ress.
      /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                                 CHANGING  data = ls_ress ).
      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'success'.
      o_resp-sapnum = ls_ress-value[ 1 ]-billingdocument.
      ls_zztsd001-billingdocument = o_resp-sapnum .

      UPDATE zztsd001 SET msgty = 'S',
                          zzxzt = '05',
                          msgtx  = 'Success',
                          billingdocument = @ls_zztsd001-billingdocument,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
                    WHERE purchaseorderbycustomer = @gv_num.


      "更新附加字段
      "更新自定义字段
      CLEAR: gs_http_req,gs_http_resp.
      DATA: ls_head TYPE ty_control.
      ls_head-yy1_fphm_bdh =  ls_zztsd001-zfphm.
      ls_head-yy1_jsdh_bdh =  ls_zztsd001-purchaseorderbycustomer.
      gs_http_req-body = /ui2/cl_json=>serialize( data          = ls_head
                                     compress      = abap_true
                                     name_mappings = gt_mapping ).
      gs_http_req-version = 'ODATAV4'.
      gs_http_req-method = 'PATCH'.
      gs_http_req-url = |/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/{ ls_zztsd001-billingdocument }| &&
                    |?sap-language={ gv_language }|.
      gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    ELSE.
      DATA ls_rese TYPE zzs_odata4_fail.
      /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                                 CHANGING  data = ls_rese ).

      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-details INTO DATA(ls_details).
        o_resp-msgtx  = o_resp-msgtx  && ls_details-message.
      ENDLOOP.

      UPDATE zztsd001 SET msgty = 'E',
                          msgtx = @o_resp-msgtx,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
                    WHERE purchaseorderbycustomer = @gv_num.

    ENDIF.
  ENDMETHOD.


  METHOD post_gr.


    SELECT SINGLE *
      FROM zztsd001
     WHERE purchaseorderbycustomer = @gv_num
      INTO @DATA(ls_zztsd001).

    GET TIME STAMP FIELD ls_zztsd001-last_changed_at.
    CHECK ls_zztsd001-zzxzt = '05'.

    CLEAR: gs_http_req,gs_http_resp.
    gs_http_req-version = 'ODATAV4'.
    gs_http_req-method = 'POST'.
    gs_http_req-etag = '*'.
    gs_http_req-url = |/api_billingdocument/srvd_a2x/sap/billingdocument/0001/BillingDocument/{ ls_zztsd001-billingdocument }/SAP__self.PostToAccounting| &&
                        |?sap-language={ gv_language }|.

    gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

    IF gs_http_resp-code = '204'.

      o_resp-msgty  = 'S'.
      o_resp-msgtx  = 'success'.

      UPDATE zztsd001 SET msgty = 'S',
                          zzxzt = '06',
                          msgtx  = 'Success',
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
                    WHERE purchaseorderbycustomer = @gv_num.
    ELSE.
      DATA ls_rese TYPE zzs_odata4_fail.
      /ui2/cl_json=>deserialize( EXPORTING json = gs_http_resp-body
                                 CHANGING  data = ls_rese ).

      o_resp-msgty = 'E'.
      LOOP AT ls_rese-error-details INTO DATA(ls_details).
        o_resp-msgtx  = o_resp-msgtx  && ls_details-message.
      ENDLOOP.

      UPDATE zztsd001 SET msgty = 'E',
                          msgtx = @o_resp-msgtx,
                          last_changed_by  = @sy-uname,
                          last_changed_at  = @ls_zztsd001-last_changed_at
                    WHERE purchaseorderbycustomer = @gv_num.

    ENDIF.


  ENDMETHOD.


  METHOD constructor.

    gv_num = iv_num.

    gt_mapping = VALUE #(
        ( abap = 'ActualGoodsMovementDate'                   json = 'ActualGoodsMovementDate'                  )
        ( abap = 'BillOfLading'                              json = 'BillOfLading'                             )
        ( abap = 'DeliveryBlockReason'                       json = 'DeliveryBlockReason'                      )
        ( abap = 'DeliveryDate'                              json = 'DeliveryDate'                             )
        ( abap = 'DeliveryDocumentBySupplier'                json = 'DeliveryDocumentBySupplier'               )
        ( abap = 'DeliveryPriority'                          json = 'DeliveryPriority'                         )
        ( abap = 'DeliveryTime'                              json = 'DeliveryTime'                             )
        ( abap = 'GoodsIssueTime'                            json = 'GoodsIssueTime'                           )
        ( abap = 'HeaderGrossWeight'                         json = 'HeaderGrossWeight'                        )
        ( abap = 'HeaderNetWeight'                           json = 'HeaderNetWeight'                          )
        ( abap = 'HeaderVolume'                              json = 'HeaderVolume'                             )
        ( abap = 'HeaderVolumeUnit'                          json = 'HeaderVolumeUnit'                         )
        ( abap = 'HeaderWeightUnit'                          json = 'HeaderWeightUnit'                         )
        ( abap = 'IncotermsClassification'                   json = 'IncotermsClassification'                  )
        ( abap = 'IncotermsTransferLocation'                 json = 'IncotermsTransferLocation'                )
        ( abap = 'LoadingDate'                               json = 'LoadingDate'                              )
        ( abap = 'LoadingTime'                               json = 'LoadingTime'                              )
        ( abap = 'MeansOfTransport'                          json = 'MeansOfTransport'                         )
        ( abap = 'MeansOfTransportType'                      json = 'MeansOfTransportType'                     )
        ( abap = 'PickingDate'                               json = 'PickingDate'                              )
        ( abap = 'PickingTime'                               json = 'PickingTime'                              )
        ( abap = 'PlannedGoodsIssueDate'                     json = 'PlannedGoodsIssueDate'                    )
        ( abap = 'ProposedDeliveryRoute'                     json = 'ProposedDeliveryRoute'                    )
        ( abap = 'ShippingPoint'                             json = 'ShippingPoint'                            )
        ( abap = 'TransportationPlanningDate'                json = 'TransportationPlanningDate'               )
        ( abap = 'TransportationPlanningTime'                json = 'TransportationPlanningTime'               )
        ( abap = 'UnloadingPointName'                        json = 'UnloadingPointName'                       )

        ( abap = 'ActualDeliveredQtyInBaseUnit'              json = 'ActualDeliveredQtyInBaseUnit'             )
        ( abap = 'ActualDeliveryQuantity'                    json = 'ActualDeliveryQuantity'                   )
        ( abap = 'Batch'                                     json = 'Batch'                                    )
        ( abap = 'DeliveryDocument'                          json = 'DeliveryDocument'                         )
        ( abap = 'DeliveryDocumentItemText'                  json = 'DeliveryDocumentItemText'                 )
        ( abap = 'DeliveryQuantityUnit'                      json = 'DeliveryQuantityUnit'                     )
        ( abap = 'EUDeliveryItemARCStatus'                   json = 'EUDeliveryItemARCStatus'                  )
        ( abap = 'InventoryValuationType'                    json = 'InventoryValuationType'                   )
        ( abap = 'ItemGrossWeight'                           json = 'ItemGrossWeight'                          )
        ( abap = 'ItemNetWeight'                             json = 'ItemNetWeight'                            )
        ( abap = 'ItemVolume'                                json = 'ItemVolume'                               )
        ( abap = 'ItemVolumeUnit'                            json = 'ItemVolumeUnit'                           )
        ( abap = 'ItemWeightUnit'                            json = 'ItemWeightUnit'                           )
        ( abap = 'ManufactureDate'                           json = 'ManufactureDate'                          )
        ( abap = 'MaterialByCustomer'                        json = 'MaterialByCustomer'                       )
        ( abap = 'ReferenceSDDocument'                       json = 'ReferenceSDDocument'                      )
        ( abap = 'ReferenceSDDocumentItem'                   json = 'ReferenceSDDocumentItem'                  )
        ( abap = 'ShelfLifeExpirationDate'                   json = 'ShelfLifeExpirationDate'                  )
        ( abap = 'StorageLocation'                           json = 'StorageLocation'                          )
        ( abap = 'serialnumber'                              json = 'serialnumber'                             )

        ( abap = 'to_DeliveryDocumentItem'                   json = 'to_DeliveryDocumentItem'                  )
        ( abap = 'results'                                   json = 'results'                                  )

         ( abap = '_Control'                                 json = '_Control' )
         ( abap = 'DefaultBillingDocumentDate'               json = 'DefaultBillingDocumentDate' )
         ( abap = 'DefaultBillingDocumentType'               json = 'DefaultBillingDocumentType' )
         ( abap = 'AutomPostingToAcctgIsDisabled'            json = 'AutomPostingToAcctgIsDisabled' )
         ( abap = 'CutOffBillingDocumentDate'                json = 'CutOffBillingDocumentDate' )
         ( abap = 'YY1_FPHM_BDH'                             json = 'YY1_FPHM_BDH' )
         ( abap = 'YY1_JSDH_BDH'                             json = 'YY1_JSDH_BDH' )
         ( abap = '_Reference'                               json = '_Reference' )
         ( abap = 'SDDocument'                               json = 'SDDocument' )

    ).
    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.

    SELECT SINGLE *
       FROM zztsd001
      WHERE purchaseorderbycustomer = @gv_num
       INTO @DATA(ls_zztsd001).

    "获取销售订单类型
    SELECT a~salesdocument,
           a~salesdocumentitem,
           a~sddocumentcategory,
           a~orderquantityunit,
           a~baseunit,
           a~product,
           a~ordertobasequantitydnmntr,
           a~ordertobasequantitynmrtr
      FROM i_salesdocumentitem WITH PRIVILEGED ACCESS AS a
     WHERE a~salesdocument = @ls_zztsd001-salesdocument
      INTO TABLE @DATA(lt_salesdocumentitem).
    READ TABLE lt_salesdocumentitem INTO DATA(ls_salesdocumentitem) INDEX 1.
    gv_sddocumentcategory = ls_salesdocumentitem-sddocumentcategory.
    IF sy-subrc = 0.
      CASE gv_sddocumentcategory.
        WHEN 'C'."标准外向交货
          gv_srv = 'API_OUTBOUND_DELIVERY_SRV'.
          gv_flowhead = 'A_OutbDeliveryHeader'.
          gv_flowitem = 'A_OutbDeliveryItem'.
        WHEN 'H'."客户退货
          gv_srv = 'API_CUSTOMER_RETURNS_DELIVERY_SRV'.
          gv_flowhead = 'A_ReturnsDeliveryHeader'.
          gv_flowitem = 'A_ReturnsDeliveryItem'.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
