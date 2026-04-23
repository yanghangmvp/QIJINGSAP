CLASS zzcl_api_sd002 DEFINITION
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

    DATA:gv_srv TYPE string.
    DATA:gv_flowhead TYPE string.
    DATA:gv_flowitem TYPE string.
    DATA:gv_deliverydocument TYPE i_deliverydocument-deliverydocument.
    DATA:gv_salesdocument    TYPE i_salesdocument-salesdocument.
    DATA:gv_sddocumentcategory TYPE i_deliverydocument-sddocumentcategory.
    DATA:gs_data TYPE ty_data.
    DATA:gt_create TYPE TABLE OF ty_create.
    DATA:gs_head TYPE ty_deliverydocumenthead.

    DATA:gt_mapping TYPE /ui2/cl_json=>name_mappings.
    DATA:gv_language TYPE i_language-languageisocode.
    DATA:gs_tmp TYPE zzs_sdi002_in.


    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_sdi002_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    "创建交货单
    METHODS create
      EXPORTING
        o_resp TYPE zzs_rest_out.

    "批次拆分
    METHODS split
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "行项目更新
    METHODS item
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "抬头更新
    METHODS head
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "删除交货单
    METHODS delete
      EXPORTING
        o_resp TYPE zzs_rest_out.
    "交货单过账
    METHODS post
      EXPORTING
        o_resp TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_API_SD002 IMPLEMENTATION.


  METHOD inbound.
    gs_tmp = i_req-data.

    LOOP AT gs_tmp-body ASSIGNING FIELD-SYMBOL(<fs_tmp>).
      <fs_tmp>-referencesddocument = |{ <fs_tmp>-referencesddocument ALPHA = IN }|.
    ENDLOOP.
    READ TABLE gs_tmp-body INTO DATA(ls_tmp) INDEX 1.
    gv_salesdocument = ls_tmp-referencesddocument.

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
     WHERE a~salesdocument = @gv_salesdocument
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
    ELSE.
      SELECT a~purchaseorder AS salesdocument,
             a~purchaseorderitem AS salesdocumentitem,
             a~purchaseordercategory AS sddocumentcategory,
             a~purchaseorderquantityunit AS orderquantityunit,
             a~baseunit,
             a~material AS product,
             a~orderitemqtytobaseqtynmrtr AS ordertobasequantitydnmntr,
             a~orderitemqtytobaseqtydnmntr AS ordertobasequantitynmrtr
        FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS AS a
       WHERE a~purchaseorder = @gv_salesdocument
        INTO TABLE @lt_salesdocumentitem.
      IF sy-subrc = 0.
        READ TABLE lt_salesdocumentitem INTO ls_salesdocumentitem INDEX 1.
        gv_sddocumentcategory = ls_salesdocumentitem-sddocumentcategory.
        CASE gv_sddocumentcategory.
          WHEN 'F'."标准外向交货
            gv_srv = 'API_OUTBOUND_DELIVERY_SRV'.
            gv_flowhead = 'A_OutbDeliveryHeader'.
            gv_flowitem = 'A_OutbDeliveryItem'.
        ENDCASE.
      ELSE.
        o_resp-msgty = 'E'.
        o_resp-msgtx = '订单不存在！'.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(lt_item) = gs_tmp-body.
    "单位转换
    SELECT b~salesdocument,
           b~salesdocumentitem,
           a~unitofmeasurecommercialname
      FROM i_unitofmeasuretext WITH PRIVILEGED ACCESS AS a
      JOIN @lt_salesdocumentitem AS b ON a~unitofmeasure = b~baseunit
     WHERE a~language = 1
       INTO TABLE @DATA(lt_unit).
    DATA: lv_input  TYPE p DECIMALS 3,
          lv_result TYPE p DECIMALS 3.

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY salesdocumentitem = <fs_item>-referencesddocumentitem.
      <fs_item>-deliveryquantityunit = ls_unit-unitofmeasurecommercialname.
      IF ls_unit-unitofmeasurecommercialname <> <fs_item>-deliveryquantityunit.
        lv_input = <fs_item>-actualdeliveryquantity.
        READ TABLE lt_salesdocumentitem INTO ls_salesdocumentitem WITH KEY salesdocumentitem = <fs_item>-referencesddocumentitem.

        SELECT SINGLE a~quantitynumerator,a~quantitydenominator
          FROM i_productunitsofmeasure WITH PRIVILEGED ACCESS AS a
          JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS b ON a~alternativeunit = b~unitofmeasure
                                                                        AND b~language = @gv_language
         WHERE product = @ls_salesdocumentitem-product
           AND unitofmeasurecommercialname = @<fs_item>-deliveryquantityunit
          INTO @DATA(ls_measure).

        lv_result = lv_input * ls_measure-quantitynumerator / ls_measure-quantitydenominator.
        <fs_item>-actualdeliveryquantity =  lv_result.

        <fs_item>-deliveryquantityunit = ls_unit-unitofmeasurecommercialname.
      ENDIF.
    ENDLOOP.


    "合并数量
    SELECT a~referencesddocument,
           a~referencesddocumentitem,
      SUM( a~actualdeliveryquantity ) AS actualdeliveryquantity,
          a~deliveryquantityunit
    FROM @lt_item AS a ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT
    GROUP BY a~referencesddocument,a~referencesddocumentitem,a~deliveryquantityunit
    INTO TABLE @gt_create.

    "创建交货单
    me->create( IMPORTING o_resp = o_resp ).
    CHECK o_resp-msgty <> 'E'.

    "获取已创建的交货单
    SELECT deliverydocument,
           deliverydocumentitem,
           referencesddocument,
           referencesddocumentitem,
           material
      FROM i_deliverydocumentitem WITH PRIVILEGED ACCESS
     WHERE referencesddocument = @gv_salesdocument
       AND goodsmovementstatus = 'A'
      INTO TABLE @DATA(lt_lips).

    "更新交货单
    DATA lt_sub LIKE gs_tmp-body.
    LOOP AT gs_tmp-body INTO ls_tmp GROUP BY ( referencesddocumentitem = ls_tmp-referencesddocumentitem
                                          count = GROUP SIZE ) INTO DATA(ls_group).
      IF ls_group-count <> 1.
        LOOP AT GROUP ls_group INTO DATA(ls_sub).
          APPEND ls_sub TO lt_sub.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    SORT lt_sub BY referencesddocumentitem.
    DELETE ADJACENT DUPLICATES FROM lt_sub COMPARING referencesddocumentitem.

    LOOP AT gs_tmp-body INTO ls_tmp .
      CLEAR:gs_data.
      READ TABLE lt_lips INTO DATA(ls_lips) WITH KEY referencesddocument     = ls_tmp-referencesddocument
                                                     referencesddocumentitem = ls_tmp-referencesddocumentitem.
      IF sy-subrc = 0.
        gs_data-deliverydocument = ls_lips-deliverydocument.
        gs_data-deliverydocumentitem = ls_lips-deliverydocumentitem.
        gs_data-salesdocument = ls_lips-referencesddocument.
        gs_data-salesdocumentitem = ls_lips-referencesddocumentitem.
      ENDIF.

      gs_data-actualdeliveryquantity = ls_tmp-actualdeliveryquantity.
      gs_data-deliveryquantityunit = ls_tmp-deliveryquantityunit.
      gs_data-storagelocation = ls_tmp-storagelocation.
      gs_data-batch = ls_tmp-batch.

      "批次拆分
      READ TABLE lt_sub TRANSPORTING NO FIELDS WITH KEY referencesddocumentitem = ls_tmp-referencesddocumentitem  BINARY SEARCH.
      IF sy-subrc = 0.
        "批次拆分行，先拆批次，再更改库存地点
        me->split( IMPORTING o_resp = o_resp ).
      ELSE.
        "非批次拆分行，先直接更改批次,库存地点
        me->item( IMPORTING o_resp = o_resp ).
      ENDIF.

      IF o_resp-msgty = 'E'.
        EXIT.
      ENDIF.
    ENDLOOP.

    "创建的交货单可能会存在多个
    DATA(lt_lips_tmp) = lt_lips.
    SORT lt_lips_tmp BY deliverydocument.
    DELETE ADJACENT DUPLICATES FROM lt_lips_tmp COMPARING deliverydocument.

    LOOP AT lt_lips_tmp INTO DATA(ls_lips_tmp).
      IF o_resp-msgty = 'E'.
        me->delete( IMPORTING o_resp = o_resp ).
        CONTINUE.
      ENDIF.
      CLEAR:gs_head.
      gv_deliverydocument = ls_lips_tmp-deliverydocument.
      "更新抬头日期
      gs_head-actualgoodsmovementdate = gs_tmp-header-actualgoodsmovementdate.
      gs_head-deliverydocumentbysupplier = gs_tmp-header-deliverydocumentbysupplier.

      IF gs_head IS NOT INITIAL.
        gs_head-actualgoodsmovementdate = zzcl_comm_tool=>date2iso( gs_head-actualgoodsmovementdate ).
        me->head( IMPORTING o_resp = o_resp ).
      ENDIF.

      IF o_resp-msgty = 'E'.
        me->delete( IMPORTING o_resp = o_resp ).
        CONTINUE.
      ENDIF.
      "交货单过账
      me->post( IMPORTING o_resp = o_resp ).

      IF o_resp-msgty = 'E'.
        me->delete( IMPORTING o_resp = o_resp ).
      ELSE.
        o_resp-sapnum = |{ o_resp-sapnum }/{ gv_deliverydocument }|.
      ENDIF.

    ENDLOOP.

    IF o_resp-sapnum  IS NOT INITIAL.
      o_resp-sapnum  = o_resp-sapnum+1.
    ENDIF.
  ENDMETHOD.


  METHOD create.
    "创建交货单
    DATA:lv_json TYPE string.
    DATA:ls_cdata  TYPE ty_deliverydocumenthead.

    LOOP AT gt_create INTO DATA(gs_create).
      APPEND INITIAL LINE TO ls_cdata-to_deliverydocumentitem-results ASSIGNING FIELD-SYMBOL(<fs_item>).
      MOVE-CORRESPONDING gs_create TO <fs_item>.
      CONDENSE <fs_item>-actualdeliveryquantity NO-GAPS.
    ENDLOOP.

    IF gv_sddocumentcategory = 'C'.
      ls_cdata-shippingpoint = '1000'.
    ELSEIF gv_sddocumentcategory = 'H'.
      ls_cdata-shippingpoint = '100R'.
    ENDIF.

*&---接口http 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/{ gv_srv };v=0002/| && gv_flowhead &&
                            |?sap-language={ gv_language }|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_http_client->set_csrf_token(  ).

        "传入数据转JSON
        lv_json = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).

        lo_request->set_text( lv_json ).
*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  deliverydocument TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'Success'.

          gv_deliverydocument = ls_ress-d-deliverydocument.
          gv_deliverydocument = |{ gv_deliverydocument ALPHA = IN }|.

        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = '创建交货单出错:' && ls_rese-error-message-value .

        ENDIF.
        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD delete.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
*&---接口http 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).


        DATA(lv_uri_path) = |/{ gv_srv };v=0002/| && gv_flowhead && |('{ gv_deliverydocument }')| &&
                            |?sap-language={ gv_language }|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>delete ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code = '204'.

        ENDIF.
        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD head.
    DATA:lv_json TYPE string.
*&---接口http 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/{ gv_srv };v=0002/{ gv_flowhead }('{ gv_deliverydocument }')|  &&
                            |?sap-language={ gv_language }|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).


        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).
        "传入数据转JSON
        lv_json = /ui2/cl_json=>serialize(
              data          = gs_head
              compress      = abap_true
              name_mappings = gt_mapping ).

        lo_request->set_text( lv_json ).
*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>patch ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code <> '204'.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message-value .
        ENDIF.
        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD item.
    DATA:lv_json TYPE string.
    DATA:ls_cdata                TYPE ty_deliverydocumentitem,
         ls_deliverydocumentitem TYPE ty_deliverydocumentitem.

    ls_cdata-batch = gs_data-batch.
    ls_cdata-storagelocation = gs_data-storagelocation.

    IF ls_cdata IS INITIAL.
      RETURN.
    ENDIF.

*&---接口http 链接调用
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/{ gv_srv };v=0002/{ gv_flowitem }(| &&
                            |DeliveryDocument='{ gs_data-deliverydocument }',| &&
                            |DeliveryDocumentItem='{ gs_data-deliverydocumentitem }')|  &&
                            |?sap-language={ gv_language }|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).

        lv_json = /ui2/cl_json=>serialize(
                   data          = ls_cdata
                   compress      = abap_true
                   name_mappings = gt_mapping ).

        lo_request->set_text( lv_json ).
*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>patch ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code <> '204'.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = '交货单行更新失败:' && ls_rese-error-message-value .
        ENDIF.
        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.

    "更新序列号
    IF ls_cdata-serialnumber IS NOT INITIAL.
      TRY.
          lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          lo_request = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          lv_uri_path = |/{ gv_srv };v=0002/AddSerialNumberToDeliveryItem?| &&
                              |DeliveryDocument='{ gs_data-deliverydocument }'&| &&
                              |DeliveryDocumentItem='{ gs_data-deliverydocumentitem }'&|  &&
                              |SerialNumber='{ ls_cdata-serialnumber }'&|  &&
                              |?sap-language={ gv_language }|.
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
          lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
          lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
          lo_http_client->set_csrf_token(  ).
*&---执行http post 方法
          lo_response = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
          lv_res = lo_response->get_text(  ).
*&---确定http 状态
          status = lo_response->get_status( ).
          IF status-code <> '204'.
            /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                        CHANGING data  = ls_rese ).
            o_resp-msgty = 'E'.
            o_resp-msgtx = '交货单行更新失败:' && ls_rese-error-message-value .
          ENDIF.
          lo_http_client->close( ).
        CATCH cx_web_http_client_error INTO lx_web_http_client_error.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD post.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).
*&---接口http 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

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

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
        IF status-code = '200'.
          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'Success'.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = '交货单过账失败:' && ls_rese-error-message-value .

        ENDIF.
        lo_http_client->close( ).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD split.
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

*&---接口http 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_deliveryquantityunit) = cl_web_http_utility=>escape_url( CONV #( gs_data-deliveryquantityunit ) ).

        DATA(lv_uri_path) = |/{ gv_srv };v=0002/CreateBatchSplitItem?| &&
                            |Batch='{ gs_data-batch }'&| &&
                            |DeliveryDocument='{ gs_data-deliverydocument }'&| &&
                            |DeliveryDocumentItem='{ gs_data-deliverydocumentitem }'&| &&
                            |ActualDeliveryQuantity={ gs_data-actualdeliveryquantity }M&|  &&
                            |DeliveryQuantityUnit='{ lv_deliveryquantityunit }'&| &&
                            |?sap-language={ gv_language }|.
        .
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
        lo_http_client->set_csrf_token(  ).

*&---执行http post 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
*&---获取http reponse 数据
        DATA(lv_res) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).

        lo_http_client->close( ).
        FREE:lo_http_client,lo_request,lo_response.
        IF status-code = '200'.
          TYPES:BEGIN OF ty_item,
                  deliverydocument     TYPE string,
                  deliverydocumentitem TYPE string,
                END OF ty_item,
                BEGIN OF ty_heads,
                  createbatchsplititem TYPE ty_item,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_ress ).
          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'Success'.

          IF gs_data-storagelocation IS NOT INITIAL.
            "更新库存地点
            gs_data-deliverydocumentitem = ls_ress-d-createbatchsplititem-deliverydocumentitem.
            me->item( IMPORTING o_resp = o_resp ).
          ENDIF.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = lv_res
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = '交货单批次拆分失败:' && ls_rese-error-message-value .

        ENDIF.

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.
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
    ).
    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = '1'
      INTO @gv_language.
  ENDMETHOD.
ENDCLASS.
