CLASS zzcl_api_sd001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_price,
             conditiontype         TYPE string,
             conditionquantity     TYPE string,
             conditionratevalue    TYPE string,
             conditionquantityunit TYPE string,
             transactioncurrency   TYPE string,
           END OF ty_price,
           BEGIN OF ty_partner,
             partnerfunction TYPE string,
             customer        TYPE string,
             supplier        TYPE string,
             personnel       TYPE string,
             contactperson   TYPE string,
           END OF ty_partner,
           BEGIN OF ty_partners,
             results TYPE TABLE OF ty_partner WITH EMPTY KEY,
           END OF ty_partners.

    DATA: gv_salesdocumenttype TYPE i_salesdocument-salesdocumenttype.
    DATA: gv_salesdocument TYPE i_salesdocument-salesdocument.
    DATA: gs_data TYPE zzs_sdi001_in.

    DATA: gt_mapping  TYPE /ui2/cl_json=>name_mappings,
          gv_language TYPE i_language-languageisocode,
          gv_json     TYPE string.

    DATA:gs_http_req  TYPE zzs_http_req,
         gs_http_resp TYPE zzs_http_resp.

    METHODS:constructor. "静态构造方法

    METHODS inbound
      IMPORTING
        i_req  TYPE zzs_sdi001_req OPTIONAL
      EXPORTING
        o_resp TYPE zzs_rest_out.

    METHODS do_or
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS do_cbre
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS do_cbfd
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS do_cr
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS do_dr
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

    METHODS do_jf
      RETURNING
        VALUE(o_resp) TYPE zzs_rest_out.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_api_sd001 IMPLEMENTATION.


  METHOD inbound.

    gs_data = i_req-data.
    gv_salesdocumenttype = i_req-data-header-salesdocumenttype.

    SELECT a~product,
           a~baseunit,
           b~unitofmeasurecommercialname
      FROM i_product WITH PRIVILEGED ACCESS AS a
      JOIN i_unitofmeasuretext WITH PRIVILEGED ACCESS AS b ON b~unitofmeasure = a~baseunit
                                                          AND b~language = 1
      INTO TABLE @DATA(lt_unit).

    IF gs_data-header-doflag = 'I'.
      SELECT SINGLE a~salesdocument
        FROM i_salesdocument WITH PRIVILEGED ACCESS AS a
        WHERE purchaseorderbycustomer = @gs_data-header-purchaseorderbycustomer
        INTO @DATA(ls_salesdocument).
      IF sy-subrc = 0.
        o_resp-msgty = 'S'.
        o_resp-msgtx = 'success'.
        o_resp-sapnum = ls_salesdocument.
        RETURN.
      ENDIF.
    ENDIF.


    IF gs_data-header-doflag = 'U'.

      SELECT a~salesdocument,
             a~salesdocumentitem
        FROM i_salesdocumentitem WITH PRIVILEGED ACCESS AS a
        JOIN @gs_data-body AS b ON a~salesdocument = b~referencesddocument
        INTO TABLE @DATA(lt_salesdocumentitem).
      SORT lt_salesdocumentitem BY salesdocument salesdocumentitem.
      DELETE ADJACENT DUPLICATES FROM lt_salesdocumentitem COMPARING salesdocument salesdocumentitem.

      LOOP AT gs_data-body INTO DATA(ls_body).
        IF ls_body-doflag = 'U' OR ls_body-doflag = 'D'.
          READ TABLE lt_salesdocumentitem INTO DATA(ls_salesdocumentitem) WITH KEY
                                  salesdocument = ls_body-referencesddocument
                                  salesdocumentitem = ls_body-referencesddocumentitem BINARY SEARCH.
          IF sy-subrc <> 0.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '单据不存在'.
            RETURN.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDIF.




    CASE gv_salesdocumenttype.
      WHEN 'OR'."标准订单 API_SALES_ORDER_SRV
        o_resp = me->do_or( ).
      WHEN 'CBRE'."退货订单 API_CUSTOMER_RETURN_SRV
        o_resp = me->do_cbre( ).
      WHEN 'CBFD'."免费订单 API_SALES_ORDER_WITHOUT_CHARGE_SRV
        o_resp = me->do_cbfd( ).
      WHEN 'CR'."贷项凭证申请  API_CREDIT_MEMO_REQUEST_SRV
        o_resp = me->do_cr( ).
      WHEN 'DR'."借项凭证申请  API_DEBIT_MEMO_REQUEST_SRV
        o_resp = me->do_dr( ).
    ENDCASE.

    DATA: lt_zztsd001 TYPE TABLE OF zztsd001,
          ls_zztsd001 TYPE zztsd001,
          lt_zztsd002 TYPE TABLE OF zztsd002,
          ls_zztsd002 TYPE zztsd002.
    "存自建表
    IF o_resp-msgty = 'S'.

      IF gs_data-header-doflag = 'I' .
        CLEAR: ls_zztsd001.
        MOVE-CORRESPONDING gs_data-header TO ls_zztsd001.
        ls_zztsd001-fsysid =  i_req-fsysid.
        ls_zztsd001-salesdocument =  o_resp-sapnum.
        ls_zztsd001-created_by = sy-uname.
        GET TIME STAMP FIELD ls_zztsd001-created_at.

        LOOP AT gs_data-body INTO DATA(ls_item).
          CLEAR: ls_zztsd002.
          MOVE-CORRESPONDING ls_item TO ls_zztsd002.
          ls_zztsd002-purchaseorderbycustomer = ls_zztsd001-purchaseorderbycustomer.
          ls_zztsd002-salesdocumentitem = ls_item-referencesddocumentitem.
          APPEND ls_zztsd002 TO lt_zztsd002.
        ENDLOOP.

        MODIFY zztsd001 FROM @ls_zztsd001.
        MODIFY zztsd002 FROM TABLE @lt_zztsd002.

      ENDIF.


      "判断是否为积分订单
      SELECT SINGLE *
        FROM zztsd003
       WHERE salesorganization = @gs_data-header-salesorganization
         AND fsysid = @i_req-fsysid
         AND zdmssotype = @gs_data-header-zdmssotype
         AND zzxflag = @abap_true
        INTO @DATA(ls_zztsd003).
      IF sy-subrc = 0.
        o_resp = me->do_jf( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD do_cbfd.
    TYPES: BEGIN OF ty_item,
             salesorderwithoutchargeitem TYPE string,
             material                    TYPE string,
             requestedquantity           TYPE string,
             requestedquantityunit       TYPE string,
             shippingpoint               TYPE string,
             productionplant             TYPE string,
           END OF ty_item,
           BEGIN OF ty_items,
             results TYPE TABLE OF ty_item WITH EMPTY KEY,
           END OF ty_items,
           BEGIN OF ty_data,
             salesorderwithoutchargetype TYPE string,
             salesorganization           TYPE string,
             distributionchannel         TYPE string,
             organizationdivision        TYPE string,
             soldtoparty                 TYPE string,
             transactioncurrency         TYPE string,
             purchaseorderbycustomer     TYPE string,
             incotermsclassification     TYPE string,
             incotermslocation1          TYPE string,
             sddocumentreason            TYPE string,
             to_item                     TYPE ty_items,
           END OF ty_data.
    DATA: ls_cdata TYPE ty_data,
          ls_item  TYPE ty_item,
          lt_item  TYPE TABLE OF ty_item.

    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

    CASE gs_data-header-doflag.
      WHEN 'I'.
        ls_cdata = CORRESPONDING #( gs_data-header ).
        ls_cdata-salesorderwithoutchargetype = gs_data-header-salesdocumenttype.
        LOOP AT gs_data-body INTO DATA(ls_item_req).
          ls_item = CORRESPONDING #( ls_item_req ).
          ls_item-salesorderwithoutchargeitem = ls_item_req-referencesddocumentitem.
          SELECT SINGLE *
            FROM i_product WITH PRIVILEGED ACCESS
           WHERE product = @ls_item_req-product
            INTO @DATA(ls_product).
          ls_item-material = ls_item_req-product.
          ls_item-requestedquantity = ls_item_req-orderquantity.
          ls_item-requestedquantityunit = ls_product-baseunit.
          ls_item-productionplant = ls_item_req-plant.
          APPEND ls_item TO lt_item.
        ENDLOOP.
        ls_cdata-to_item-results = lt_item.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/API_SALES_ORDER_WITHOUT_CHARGE_SRV/A_SalesOrderWithoutCharge?sap-language={ gv_language }|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

        IF gs_http_resp-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  salesorderwithoutcharge     TYPE string,
                  salesorderwithoutchargetype TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          o_resp-sapnum = ls_ress-d-salesorderwithoutcharge.
          o_resp-field1 = ls_ress-d-salesorderwithoutchargetype.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  =  gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message-value .
        ENDIF.

      WHEN 'U'.

        LOOP AT gs_data-body INTO DATA(ls_body).
          CASE ls_body-doflag .
            WHEN 'D'.
              MODIFY ENTITIES OF i_salesorderwithoutchargetp PRIVILEGED
              ENTITY salesorderwithoutchargeitem
              UPDATE
              FIELDS ( salesdocumentrjcnreason )
                WITH VALUE #(
               ( salesdocumentrjcnreason = '01'
                 %key-salesorderwithoutcharge = ls_body-referencesddocument
                 %key-salesorderwithoutchargeitem = ls_body-referencesddocumentitem ) )
                  FAILED DATA(ls_failed)
                  REPORTED DATA(ls_reported).
            WHEN 'U'.
              MODIFY ENTITIES OF i_salesorderwithoutchargetp PRIVILEGED
              ENTITY salesorderwithoutchargeitem
              UPDATE
              FIELDS ( requestedquantity )
                WITH VALUE #(
                    ( requestedquantity = ls_body-orderquantity
                      %key-salesorderwithoutcharge = ls_body-referencesddocument
                      %key-salesorderwithoutchargeitem = ls_body-referencesddocumentitem ) )
                FAILED ls_failed
                REPORTED ls_reported.

          ENDCASE.

          IF ls_reported IS NOT INITIAL.
            ROLLBACK ENTITIES.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '更新失败'.
          ELSE.
            COMMIT WORK.
            o_resp-msgty = 'S'.
            o_resp-msgtx = 'success'.
          ENDIF.
        ENDLOOP.



      WHEN 'D'.

        MODIFY ENTITIES OF i_salesorderwithoutchargetp PRIVILEGED
             ENTITY salesorderwithoutchargeitem
             UPDATE
             FIELDS ( salesdocumentrjcnreason )
             WITH VALUE #(
             FOR ls_body2 IN gs_data-body
              ( salesdocumentrjcnreason = '01'
               %key-salesorderwithoutcharge = ls_body2-referencesddocument
               %key-salesorderwithoutchargeitem = ls_body2-referencesddocumentitem ) )
             FAILED ls_failed
             REPORTED ls_reported.

        IF ls_reported IS NOT INITIAL.
          ROLLBACK ENTITIES.
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Delete  error'.
        ELSE.
          COMMIT WORK.
          o_resp-msgty = 'S'.
          o_resp-msgtx = 'success'.
        ENDIF.

    ENDCASE.
  ENDMETHOD.


  METHOD do_cbre.
    TYPES: BEGIN OF ty_prices,
             results TYPE TABLE OF ty_price WITH EMPTY KEY,
           END  OF ty_prices,
           BEGIN OF ty_item,
             customerreturnitem    TYPE string,
             material              TYPE string,
             requestedquantity     TYPE string,
             requestedquantityunit TYPE string,
             productionplant       TYPE string,
             shippingpoint         TYPE string,
*             referencesddocument     TYPE string,
*             referencesddocumentitem TYPE string,
             to_pricingelement     TYPE ty_prices,
           END OF ty_item,
           BEGIN OF ty_items,
             results TYPE TABLE OF ty_item WITH EMPTY KEY,
           END OF ty_items,
           BEGIN OF ty_data,
             customerreturntype      TYPE string,
             customerreturndate      TYPE string,
             salesorganization       TYPE string,
             distributionchannel     TYPE string,
             organizationdivision    TYPE string,
             soldtoparty             TYPE string,
             transactioncurrency     TYPE string,
             customerpaymentterms    TYPE string,
             purchaseorderbycustomer TYPE string,
             referencesddocument     TYPE string,
             sddocumentreason        TYPE string,
             to_item                 TYPE ty_items,
             to_partner              TYPE ty_partners,
           END OF ty_data.
    DATA: ls_cdata TYPE ty_data,
          ls_item  TYPE ty_item,
          lt_item  TYPE TABLE OF ty_item,
          ls_price TYPE ty_price,
          lt_price TYPE TABLE OF ty_price..
    DATA(lo_dest) = zzcl_comm_tool=>get_dest( ).

    CASE gs_data-header-doflag.
      WHEN 'I'.

        ls_cdata = CORRESPONDING #( gs_data-header ).
        ls_cdata-customerreturntype = gs_data-header-salesdocumenttype.
        ls_cdata-customerreturndate = zzcl_comm_tool=>date2iso( gs_data-header-salesdocumentdate ).

        IF gs_data-header-shcustomer IS NOT INITIAL.
          APPEND VALUE #( partnerfunction = 'SH' customer = gs_data-header-shcustomer  ) TO ls_cdata-to_partner-results.
        ENDIF.
        IF gs_data-header-pycustomer IS NOT INITIAL.
          APPEND VALUE #( partnerfunction = 'PY' customer = gs_data-header-pycustomer  ) TO ls_cdata-to_partner-results.
        ENDIF.
        LOOP AT gs_data-body INTO DATA(ls_item_req).
          ls_item = CORRESPONDING #( ls_item_req ).
          SELECT SINGLE *
            FROM i_product WITH PRIVILEGED ACCESS
           WHERE product = @ls_item_req-product
            INTO @DATA(ls_product).

          CLEAR: ls_price, lt_price.
          ls_price = CORRESPONDING #( ls_item_req ).
          ls_price-transactioncurrency = 'CNY'.
          ls_price-conditionquantityunit = ls_product-baseunit.
          APPEND ls_price TO lt_price.
          ls_price-conditiontype = 'ZPR9'.
          ls_price-conditionratevalue = ls_item_req-conditionamount.
          APPEND ls_price TO lt_price.


          ls_item-customerreturnitem = ls_item_req-referencesddocumentitem.
          ls_item-material = ls_item_req-product.
          ls_item-requestedquantity = ls_item_req-orderquantity.
          ls_item-requestedquantityunit = ls_product-baseunit.
          ls_item-productionplant = ls_item_req-plant.

          ls_item-to_pricingelement-results = lt_price.
          APPEND ls_item TO lt_item.


        ENDLOOP.
        ls_cdata-to_item-results = lt_item.

        "传入数据转JSON
        gv_json = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).


        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/API_CUSTOMER_RETURN_SRV/A_CustomerReturn?sap-language={ gv_language }|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

        IF gs_http_resp-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  customerreturn     TYPE string,
                  customerreturntype TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          gv_salesdocument = ls_ress-d-customerreturn..
          o_resp-sapnum = ls_ress-d-customerreturn.
          o_resp-field1 = ls_ress-d-customerreturntype.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = ls_rese-error-message-value .
        ENDIF.



      WHEN 'U'.

        LOOP AT gs_data-body INTO DATA(ls_body).
          CASE ls_body-doflag .
            WHEN 'D'.
              MODIFY ENTITIES OF i_customerreturntp PRIVILEGED
              ENTITY customerreturnitem
              UPDATE
              FIELDS ( salesdocumentrjcnreason )
                WITH VALUE #(
               ( salesdocumentrjcnreason = '00'
                 %key-customerreturn = ls_body-referencesddocument
                 %key-customerreturnitem = ls_body-referencesddocumentitem ) )
                  FAILED DATA(ls_failed)
                  REPORTED DATA(ls_reported).

            WHEN 'U'.
              MODIFY ENTITIES OF i_customerreturntp PRIVILEGED
              ENTITY customerreturnitem
              UPDATE
              FIELDS ( requestedquantity )
                WITH VALUE #(
                    ( requestedquantity = ls_body-orderquantity
                      %key-customerreturn = ls_body-referencesddocument
                      %key-customerreturnitem = ls_body-referencesddocumentitem ) )
                FAILED ls_failed
                REPORTED ls_reported.

          ENDCASE.

          IF ls_failed IS NOT INITIAL.
            ROLLBACK ENTITIES.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '更新失败'.
          ELSE.
            COMMIT WORK.
            o_resp-msgty = 'S'.
            o_resp-msgtx = 'success'.
          ENDIF.
        ENDLOOP.

      WHEN 'D'.

        MODIFY ENTITIES OF i_customerreturntp PRIVILEGED
                   ENTITY customerreturnitem
                   UPDATE
                   FIELDS ( salesdocumentrjcnreason )
                   WITH VALUE #(
                   FOR ls_body2 IN gs_data-body
                    ( salesdocumentrjcnreason = '00'
                     %key-customerreturn = ls_body2-referencesddocument
                     %key-customerreturnitem = ls_body2-referencesddocumentitem ) )
                   FAILED ls_failed
                   REPORTED ls_reported.

        IF ls_failed IS NOT INITIAL.
          ROLLBACK ENTITIES.
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Delete  error'.
        ELSE.
          COMMIT ENTITIES.
          o_resp-msgty = 'S'.
          o_resp-msgtx = 'Success'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD do_cr.
    TYPES: BEGIN OF ty_prices,
             results TYPE TABLE OF ty_price WITH EMPTY KEY,
           END  OF ty_prices,
           BEGIN OF ty_item,
             creditmemorequestitem TYPE string,
             material              TYPE string,
             requestedquantity     TYPE string,
             requestedquantityunit TYPE string,
             productionplant       TYPE string,
             shippingpoint         TYPE string,
             batch                 TYPE string,
             plant                 TYPE string,
             storagelocation       TYPE string,
             to_pricingelement     TYPE ty_prices,
           END OF ty_item,
           BEGIN OF ty_items,
             results TYPE TABLE OF ty_item WITH EMPTY KEY,
           END OF ty_items,
           BEGIN OF ty_cdata,
             creditmemorequesttype   TYPE string,
             creditmemorequestdate   TYPE string,
             salesorganization       TYPE string,
             distributionchannel     TYPE string,
             organizationdivision    TYPE string,
             soldtoparty             TYPE string,
             transactioncurrency     TYPE string,
             customerpaymentterms    TYPE string,
             purchaseorderbycustomer TYPE string,
             incotermsclassification TYPE string,
             incotermslocation1      TYPE string,
             to_item                 TYPE ty_items,
           END OF ty_cdata.
    DATA: ls_cdata TYPE ty_cdata,
          ls_item  TYPE ty_item,
          lt_item  TYPE TABLE OF ty_item,
          ls_price TYPE ty_price,
          lt_price TYPE TABLE OF ty_price.

    CASE gs_data-header-doflag.
      WHEN 'I'.
        ls_cdata = CORRESPONDING #( gs_data-header ).
        ls_cdata-creditmemorequesttype = gs_data-header-salesdocumenttype.
        ls_cdata-creditmemorequestdate = zzcl_comm_tool=>date2iso( gs_data-header-salesdocumentdate ).

        LOOP AT gs_data-body INTO DATA(ls_item_req).
          CLEAR: ls_price, lt_price.
          ls_price = CORRESPONDING #( ls_item_req ).
          APPEND ls_price TO lt_price.

          ls_item = CORRESPONDING #( ls_item_req ).
          ls_item-creditmemorequestitem = ls_item_req-referencesddocumentitem.
          ls_item-to_pricingelement-results = lt_price.
          APPEND ls_item TO lt_item.

        ENDLOOP.
        ls_cdata-to_item-results = lt_item.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/API_CREDIT_MEMO_REQUEST_SRV/A_CreditMemoRequest|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

        IF gs_http_resp-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  creditmemorequest TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).
          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          o_resp-sapnum = ls_ress-d-creditmemorequest.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Sale Order error:' && ls_rese-error-message-value .

        ENDIF.


      WHEN 'U'.

        LOOP AT gs_data-body INTO DATA(ls_body).
          CASE ls_body-doflag .
            WHEN 'D'.
              MODIFY ENTITIES OF i_creditmemorequesttp PRIVILEGED
              ENTITY creditmemorequestitem
              UPDATE
              FIELDS ( salesdocumentrjcnreason )
                WITH VALUE #(
               ( salesdocumentrjcnreason = '01'
                 %key-creditmemorequest = ls_body-referencesddocument
                 %key-creditmemorequestitem = ls_body-referencesddocumentitem ) )
                  FAILED DATA(ls_failed)
                  REPORTED DATA(ls_reported).
            WHEN 'U'.
              MODIFY ENTITIES OF i_creditmemorequesttp PRIVILEGED
              ENTITY creditmemorequestitem
              UPDATE
              FIELDS ( requestedquantity )
                WITH VALUE #(
                    ( requestedquantity = ls_body-orderquantity
                      %key-creditmemorequest = ls_body-referencesddocument
                      %key-creditmemorequestitem = ls_body-referencesddocumentitem ) )
               FAILED ls_failed
             REPORTED ls_reported.

          ENDCASE.

          IF ls_failed IS NOT INITIAL.
            ROLLBACK ENTITIES.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '更新失败'.
          ELSE.
            COMMIT WORK.
            o_resp-msgty = 'S'.
            o_resp-msgtx = 'Success'.
          ENDIF.
        ENDLOOP.


      WHEN 'D'.

        MODIFY ENTITIES OF i_creditmemorequesttp PRIVILEGED
               ENTITY creditmemorequestitem
               UPDATE
               FIELDS ( salesdocumentrjcnreason )
               WITH VALUE #(
               FOR ls_body2 IN gs_data-body
                ( salesdocumentrjcnreason = '01'
                  %key-creditmemorequest = ls_body2-referencesddocument
                  %key-creditmemorequestitem = ls_body2-referencesddocumentitem ) )
               FAILED ls_failed
               REPORTED ls_reported.

        IF ls_failed IS NOT INITIAL.
          ROLLBACK ENTITIES.
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Delete CBRE item error'.
        ELSE.
          COMMIT WORK.
          o_resp-msgty = 'S'.
          o_resp-msgtx = 'success'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD do_dr.

    TYPES: BEGIN OF ty_prices,
             results TYPE TABLE OF ty_price WITH EMPTY KEY,
           END  OF ty_prices,
           BEGIN OF ty_item,
             debitmemorequestitem  TYPE string,
             material              TYPE string,
             requestedquantity     TYPE string,
             requestedquantityunit TYPE string,
             productionplant       TYPE string,
             shippingpoint         TYPE string,
             batch                 TYPE string,
             plant                 TYPE string,
             storagelocation       TYPE string,
             to_pricingelement     TYPE ty_prices,
           END OF ty_item,
           BEGIN OF ty_items,
             results TYPE TABLE OF ty_item WITH EMPTY KEY,
           END OF ty_items,
           BEGIN OF ty_cdata,
             debitmemorequesttype    TYPE string,
             debitmemorequestdate    TYPE string,
             salesorganization       TYPE string,
             distributionchannel     TYPE string,
             organizationdivision    TYPE string,
             soldtoparty             TYPE string,
             transactioncurrency     TYPE string,
             customerpaymentterms    TYPE string,
             purchaseorderbycustomer TYPE string,
             incotermsclassification TYPE string,
             incotermslocation1      TYPE string,
             to_item                 TYPE ty_items,
           END OF ty_cdata.
    DATA: ls_cdata TYPE ty_cdata,
          ls_item  TYPE ty_item,
          lt_item  TYPE TABLE OF ty_item,
          ls_price TYPE ty_price,
          lt_price TYPE TABLE OF ty_price.

    CASE gs_data-header-doflag.
      WHEN 'I'.
        ls_cdata = CORRESPONDING #( gs_data-header ).
        ls_cdata-debitmemorequesttype = gs_data-header-salesdocumenttype.
        ls_cdata-debitmemorequestdate = zzcl_comm_tool=>date2iso( gs_data-header-salesdocumentdate ).

        LOOP AT gs_data-body INTO DATA(ls_item_req).
          CLEAR: ls_price, lt_price.
          ls_price = CORRESPONDING #( ls_item_req ).
          APPEND ls_price TO lt_price.
          ls_item = CORRESPONDING #( ls_item_req ).
          ls_item-debitmemorequestitem = ls_item_req-referencesddocumentitem.
          ls_item-to_pricingelement-results = lt_price.
          APPEND ls_item TO lt_item.
        ENDLOOP.
        ls_cdata-to_item-results = lt_item.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/API_DEBIT_MEMO_REQUEST_SRV/A_DebitMemoRequest|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

        IF gs_http_resp-code = '201'.
          TYPES:BEGIN OF ty_heads,
                  debitmemorequest TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).

          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          o_resp-sapnum = ls_ress-d-debitmemorequest.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Sale Order error:' && ls_rese-error-message-value .

        ENDIF.



      WHEN 'U'.

        LOOP AT gs_data-body INTO DATA(ls_body).
          CASE ls_body-doflag .
            WHEN 'D'.
              MODIFY ENTITIES OF i_debitmemorequesttp PRIVILEGED
              ENTITY debitmemorequestitem
              UPDATE
              FIELDS ( salesdocumentrjcnreason )
                WITH VALUE #(
               ( salesdocumentrjcnreason = '01'
                 %key-debitmemorequest = ls_body-referencesddocument
                 %key-debitmemorequestitem = ls_body-referencesddocumentitem ) )
                  FAILED DATA(ls_failed)
                  REPORTED DATA(ls_reported).
            WHEN 'U'.
              MODIFY ENTITIES OF i_debitmemorequesttp PRIVILEGED
              ENTITY debitmemorequestitem
              UPDATE
              FIELDS ( requestedquantity )
                WITH VALUE #(
                    ( requestedquantity = ls_body-orderquantity
                      %key-debitmemorequest = ls_body-referencesddocument
                      %key-debitmemorequestitem = ls_body-referencesddocumentitem ) )
                FAILED ls_failed
                REPORTED ls_reported.

          ENDCASE.

          IF ls_failed IS NOT INITIAL.
            ROLLBACK ENTITIES.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '更新失败'.
          ELSE.
            COMMIT WORK.
            o_resp-msgty = 'S'.
            o_resp-msgtx = 'Success'.
          ENDIF.
        ENDLOOP.


      WHEN 'D'.

        MODIFY ENTITIES OF i_debitmemorequesttp PRIVILEGED
               ENTITY debitmemorequestitem
               UPDATE
               FIELDS ( salesdocumentrjcnreason )
               WITH VALUE #(
               FOR ls_body2 IN gs_data-body
                ( salesdocumentrjcnreason = '01'
                  %key-debitmemorequest = ls_body2-referencesddocument
                  %key-debitmemorequestitem = ls_body2-referencesddocumentitem ) )
               FAILED ls_failed
               REPORTED ls_reported.

        IF ls_failed IS NOT INITIAL.
          ROLLBACK ENTITIES.
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Delete item error'.
        ELSE.
          COMMIT WORK.
          o_resp-msgty = 'S'.
          o_resp-msgtx = 'Success'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD do_or.

    TYPES: BEGIN OF ty_prices,
             results TYPE TABLE OF ty_price WITH EMPTY KEY,
           END  OF ty_prices,
           BEGIN OF ty_item,
             salesorderitem         TYPE string,
             salesorderitemcategory TYPE string,
             material               TYPE string,
             requestedquantity      TYPE string,
             requestedquantityunit  TYPE string,
             productionplant        TYPE string,
             shippingpoint          TYPE string,
             batch                  TYPE string,
             storagelocation        TYPE string,
             to_pricingelement      TYPE ty_prices,
           END OF ty_item,
           BEGIN OF ty_items,
             results TYPE TABLE OF ty_item WITH EMPTY KEY,
           END OF ty_items,
           BEGIN OF ty_cdata,
             salesordertype          TYPE string,
             salesorderdate          TYPE string,
             salesorganization       TYPE string,
             distributionchannel     TYPE string,
             organizationdivision    TYPE string,
             soldtoparty             TYPE string,
             transactioncurrency     TYPE string,
             customerpaymentterms    TYPE string,
             purchaseorderbycustomer TYPE string,
             incotermsclassification TYPE string,
             incotermslocation1      TYPE string,
             to_item                 TYPE ty_items,
             to_partner              TYPE ty_partners,
           END OF ty_cdata.
    DATA: ls_cdata TYPE ty_cdata,
          ls_item  TYPE ty_item,
          lt_item  TYPE TABLE OF ty_item,
          ls_price TYPE ty_price,
          lt_price TYPE TABLE OF ty_price.

    CASE gs_data-header-doflag.
      WHEN 'I'.
        ls_cdata = CORRESPONDING #( gs_data-header ).
        ls_cdata-salesordertype =  gs_data-header-salesdocumenttype.
        ls_cdata-salesorderdate = zzcl_comm_tool=>date2iso( gs_data-header-salesdocumentdate ).
        IF gs_data-header-shcustomer IS NOT INITIAL.
          APPEND VALUE #( partnerfunction = 'SH' customer = gs_data-header-shcustomer  ) TO ls_cdata-to_partner-results.
        ENDIF.
        IF gs_data-header-pycustomer IS NOT INITIAL.
          APPEND VALUE #( partnerfunction = 'PY' customer = gs_data-header-pycustomer  ) TO ls_cdata-to_partner-results.
        ENDIF.
        LOOP AT gs_data-body INTO DATA(ls_item_req).
          CLEAR: ls_price, lt_price.
          ls_price = CORRESPONDING #( ls_item_req ).

          ls_price-transactioncurrency = 'CNY'.
          SELECT SINGLE *
            FROM i_product WITH PRIVILEGED ACCESS
           WHERE product = @ls_item_req-product
          INTO @DATA(ls_product).
          ls_price-conditionquantityunit = ls_product-baseunit.
          APPEND ls_price TO lt_price.

          "含税总额
          ls_price-conditiontype = 'ZPR9'.
          ls_price-conditionratevalue = ls_item_req-conditionamount.
          APPEND ls_price TO lt_price.

          "积分值
          IF ls_item_req-zdua1 IS NOT INITIAL.
            CLEAR: ls_price.
            ls_price-conditiontype = 'ZPR1'.
            ls_price-conditionratevalue = ls_item_req-zdua1.
            CONDENSE  ls_price-conditionratevalue  NO-GAPS.
            APPEND ls_price TO lt_price.
          ENDIF.

          ls_item = CORRESPONDING #( ls_item_req ).
          ls_item-salesorderitem = ls_item_req-referencesddocumentitem.
          ls_item-material = ls_item_req-product.
          ls_item-salesorderitemcategory = ls_item_req-salesdocumentitemcategory.
          ls_item-requestedquantity = ls_item_req-orderquantity.
          ls_item-requestedquantityunit = ls_product-baseunit.
          ls_item-productionplant = ls_item_req-plant.
          ls_item-to_pricingelement-results = lt_price.
          APPEND ls_item TO lt_item.

        ENDLOOP.
        ls_cdata-to_item-results = lt_item.

        CLEAR: gs_http_req,gs_http_resp.
        gs_http_req-version = 'ODATAV2'.
        gs_http_req-method = 'POST'.
        gs_http_req-url = |/API_SALES_ORDER_SRV/A_SalesOrder?sap-language={ gv_language }|.
        "传入数据转JSON
        gs_http_req-body = /ui2/cl_json=>serialize(
              data          = ls_cdata
              compress      = abap_true
              name_mappings = gt_mapping ).

        gs_http_resp = zzcl_comm_tool=>http( gs_http_req ).

        IF gs_http_resp-code  =  '201'.
          TYPES:BEGIN OF ty_heads,
                  salesorder     TYPE string,
                  salesordertype TYPE string,
                END OF ty_heads,
                BEGIN OF ty_ress,
                  d TYPE ty_heads,
                END OF  ty_ress.
          DATA:ls_ress TYPE ty_ress.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_ress ).
          o_resp-msgty  = 'S'.
          o_resp-msgtx  = 'success'.
          gv_salesdocument = ls_ress-d-salesorder.
          o_resp-sapnum = ls_ress-d-salesorder.
          o_resp-field1 = ls_ress-d-salesordertype.
        ELSE.
          DATA:ls_rese TYPE zzs_odata_fail.
          /ui2/cl_json=>deserialize( EXPORTING json  = gs_http_resp-body
                                      CHANGING data  = ls_rese ).
          o_resp-msgty = 'E'.
          o_resp-msgtx =  ls_rese-error-message-value .
        ENDIF.


      WHEN 'U'.

        LOOP AT gs_data-body INTO DATA(ls_body).
          CASE ls_body-doflag .
            WHEN 'D'.
              MODIFY ENTITIES OF i_salesordertp PRIVILEGED
              ENTITY salesorderitem
              UPDATE
              FIELDS ( salesdocumentrjcnreason )
                WITH VALUE #(
               ( salesdocumentrjcnreason = '00'
                 %key-salesorder = ls_body-referencesddocument
                 %key-salesorderitem = ls_body-referencesddocumentitem ) )
                  FAILED DATA(ls_failed)
                  REPORTED DATA(ls_reported).
            WHEN 'U'.
              MODIFY ENTITIES OF i_salesordertp PRIVILEGED
              ENTITY salesorderitem
              UPDATE
              FIELDS ( requestedquantity )
                WITH VALUE #(
                    ( requestedquantity = ls_body-orderquantity
                      %key-salesorder = ls_body-referencesddocument
                      %key-salesorderitem = ls_body-referencesddocumentitem ) )
                FAILED ls_failed
                REPORTED ls_reported.

          ENDCASE.

          IF ls_failed IS NOT INITIAL.
            ROLLBACK ENTITIES.
            o_resp-msgty = 'E'.
            o_resp-msgtx = '更新失败'.
          ELSE.
            COMMIT ENTITIES.
            o_resp-msgty = 'S'.
            o_resp-msgtx = 'success'.
          ENDIF.
        ENDLOOP.


      WHEN 'D'.

        MODIFY ENTITIES OF i_salesordertp PRIVILEGED
               ENTITY salesorderitem
               UPDATE
               FIELDS ( salesdocumentrjcnreason )
               WITH VALUE #(
               FOR ls_body2 IN gs_data-body
                ( salesdocumentrjcnreason = '00'
                  %key-salesorder = ls_body2-referencesddocument
                  %key-salesorderitem = ls_body2-referencesddocumentitem ) )
               FAILED ls_failed
               REPORTED ls_reported.

        IF ls_failed IS NOT INITIAL.
          ROLLBACK ENTITIES.
          o_resp-msgty = 'E'.
          o_resp-msgtx = 'Delete CBRE item error'.
        ELSE.
          COMMIT WORK.
          o_resp-msgty = 'S'.
          o_resp-msgtx = 'success'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD constructor.

*&---导入结构json MAPPING
    gt_mapping = VALUE #(
         ( abap = 'SalesOrderType'               json = 'SalesOrderType'      )
         ( abap = 'SalesOrderDate'               json = 'SalesOrderDate'      )
         ( abap = 'SalesOrderWithoutChargeType'  json = 'SalesOrderWithoutChargeType'      )
         ( abap = 'SalesOrderWithoutChargeDate'  json = 'SalesOrderWithoutChargeDate'      )
         ( abap = 'CustomerReturnType'           json = 'CustomerReturnType'      )
         ( abap = 'CustomerReturnDate'           json = 'CustomerReturnDate'      )
         ( abap = 'CreditMemoRequestType'        json = 'CreditMemoRequestType'      )
         ( abap = 'CreditMemoRequestDate'        json = 'CreditMemoRequestDate'      )
         ( abap = 'DebitMemoRequestType'         json = 'DebitMemoRequestType'      )
         ( abap = 'DebitMemoRequestDate'         json = 'DebitMemoRequestDate'      )
         ( abap = 'SalesOrganization'            json = 'SalesOrganization'       )
         ( abap = 'DistributionChannel'          json = 'DistributionChannel'         )
         ( abap = 'OrganizationDivision'         json = 'OrganizationDivision'          )
         ( abap = 'SoldToParty'                  json = 'SoldToParty'      )
         ( abap = 'TransactionCurrency'          json = 'TransactionCurrency'      )
         ( abap = 'CustomerPaymentTerms'         json = 'CustomerPaymentTerms'      )
         ( abap = 'PurchaseOrderByCustomer'      json = 'PurchaseOrderByCustomer'      )
         ( abap = 'IncotermsClassification'      json = 'IncotermsClassification'      )
         ( abap = 'IncotermsLocation1'           json = 'IncotermsLocation1'      )

         ( abap = 'to_Partner'                   json = 'to_Partner'      )
         ( abap = 'PartnerFunction'              json = 'PartnerFunction'      )
         ( abap = 'Customer'                     json = 'Customer'      )
         ( abap = 'Supplier'                     json = 'Supplier'      )
         ( abap = 'Personnel'                    json = 'Personnel'      )

         ( abap = 'to_Item'                      json = 'to_Item'      )
         ( abap = 'Plant'                        json = 'Plant'             )
         ( abap = 'results'                      json = 'results'      )
         ( abap = 'SalesOrderItemCategory'       json = 'SalesOrderItemCategory'      )
         ( abap = 'SalesOrderItem'               json = 'SalesOrderItem'      )
         ( abap = 'SalesOrderWithoutChargeItem'  json = 'SalesOrderWithoutChargeItem'      )
         ( abap = 'CustomerReturnItem'           json = 'CustomerReturnItem'      )
         ( abap = 'CreditMemoRequestItem'        json = 'CreditMemoRequestItem'      )
         ( abap = 'Material'                     json = 'Material'      )
         ( abap = 'RequestedQuantity'            json = 'RequestedQuantity'      )
         ( abap = 'RequestedQuantityUnit'        json = 'RequestedQuantityUnit'      )
         ( abap = 'ProductionPlant'              json = 'ProductionPlant'      )
         ( abap = 'ShippingPoint'                json = 'ShippingPoint'      )
         ( abap = 'StorageLocation'              json = 'StorageLocation'      )

         ( abap = 'to_PricingElement'            json = 'to_PricingElement'      )
         ( abap = 'ConditionType'                json = 'ConditionType'      )
         ( abap = 'ConditionRateValue'           json = 'ConditionRateValue'      )
         ( abap = 'ConditionCurrency'            json = 'ConditionCurrency'      )
         ( abap = 'ConditionQuantity'            json = 'ConditionQuantity'      )
         ( abap = 'ConditionAmount'              json = 'ConditionAmount'      )

         ( abap = 'ConditionQuantityUnit'        json = 'ConditionQuantityUnit'      )
       ).


    "获取语言
    SELECT SINGLE languageisocode
      FROM i_language WITH PRIVILEGED ACCESS
     WHERE language = 1
      INTO @gv_language.
  ENDMETHOD.


  METHOD do_jf.
    DATA:lt_zztfi001 TYPE TABLE OF zztfi001,
         ls_zztfi001 TYPE zztfi001,
         lt_zztfi002 TYPE TABLE OF zztfi002,
         ls_zztfi002 TYPE zztfi002.
    DATA: lv_num TYPE i.
    DATA: lv_total_ze TYPE p LENGTH 11 DECIMALS 2.
    DATA: lv_total_se TYPE p LENGTH 11 DECIMALS 2.

    CLEAR: ls_zztfi001.
    ls_zztfi001-reference1indocumentheader = gs_data-header-purchaseorderbycustomer.
    ls_zztfi001-datasource = 'B01'.
    ls_zztfi001-originalreferencedocumenttype = 'BKPFF'.
    ls_zztfi001-businesstransactiontype = 'RFBU'.
    ls_zztfi001-companycode = gs_data-header-salesorganization.
    ls_zztfi001-accountingdocumenttype = 'DA'.
    ls_zztfi001-postingdate = sy-datum.
    ls_zztfi001-documentdate = gs_data-header-salesdocumentdate.
    ls_zztfi001-transactioncurrency = gs_data-header-transactioncurrency.
    ls_zztfi001-exchangerate = ''.
    ls_zztfi001-accountingdoccreatedbyuser = ''.
    ls_zztfi001-accountingdocumentheadertext = '精品积分兑换'.

    IF ls_zztfi001-transactioncurrency IS INITIAL.
      ls_zztfi001-transactioncurrency = 'CNY'.
    ENDIF.
    IF ls_zztfi001-documentdate  IS INITIAL.
      ls_zztfi001-documentdate  = sy-datum.
    ENDIF.

    APPEND ls_zztfi001 TO lt_zztfi001.

    SELECT SINGLE *
      FROM zztsd004
     WHERE waers = @ls_zztfi001-transactioncurrency
       AND zzbegin <= @ls_zztfi001-documentdate
       AND zzend >= @ls_zztfi001-documentdate
      INTO @DATA(ls_zztsd004).
    IF ls_zztsd004-zzbl = 0.
      ls_zztsd004-zzbl = 10.
    ENDIF.

    LOOP AT gs_data-body INTO DATA(ls_body).
      CLEAR: ls_zztfi002.
      lv_num = lv_num + 1.
      ls_zztfi002-reference1indocumentheader = gs_data-header-purchaseorderbycustomer.
      ls_zztfi002-datasource = 'B01'.
      ls_zztfi002-accountingdocumentitem = lv_num.
      ls_zztfi002-glaccount = '6001020821'.
      ls_zztfi002-amountintransactioncurrency = ls_body-zdua1 / ls_zztsd004-zzbl.
      ls_zztfi002-amountintransactioncurrency = ls_zztfi002-amountintransactioncurrency * -1.
      IF ls_zztfi002-amountintransactioncurrency > 0.
        ls_zztfi002-debitcreditcode = 'S'.
      ELSE.
        ls_zztfi002-debitcreditcode = 'H'.
      ENDIF.
      ls_zztfi002-documentitemtext = ls_body-zbeizu.
      ls_zztfi002-profitcenter = 'PGH00'.
      ls_zztfi002-salesorder =      gv_salesdocument.
      ls_zztfi002-salesorderitem =      ls_body-referencesddocumentitem.
      ls_zztfi002-plant = ls_body-plant.
      ls_zztfi002-material = ls_body-product.
      APPEND ls_zztfi002 TO lt_zztfi002.

      lv_total_ze = lv_total_ze +  ls_body-zdua1 / ls_zztsd004-zzbl .
      lv_total_se = lv_total_se +  ls_zztfi002-amountintransactioncurrency * '0.13'.
    ENDLOOP.


    SELECT SINGLE customer,tradingpartner
      FROM i_customer WITH PRIVILEGED ACCESS
     WHERE businesspartnername2 =  @gs_data-header-soldtoparty
      INTO @DATA(ls_customer).
    IF ls_customer-tradingpartner IS INITIAL.
      ls_customer-tradingpartner  = 'Z999'.
    ENDIF.
    "分录2
    CLEAR: ls_zztfi002.
    lv_num = lv_num + 1.
    ls_zztfi002-reference1indocumentheader = gs_data-header-purchaseorderbycustomer.
    ls_zztfi002-accountingdocumentitem = lv_num.
    ls_zztfi002-datasource = 'B01'.
    ls_zztfi002-glaccount = '1122020110'.
    ls_zztfi002-amountintransactioncurrency = lv_total_ze * '1.13'.
    IF ls_zztfi002-amountintransactioncurrency > 0.
      ls_zztfi002-debitcreditcode = 'S'.
    ELSE.
      ls_zztfi002-debitcreditcode = 'H'.
    ENDIF.
    ls_zztfi002-documentitemtext = ls_body-zbeizu.
    ls_zztfi002-profitcenter = 'PGH00'.
    ls_zztfi002-customer = gs_data-header-soldtoparty.
    ls_zztfi002-altvrecnclnaccts = '2204100101'.
    ls_zztfi002-tradingpartner = ls_customer-tradingpartner.
    APPEND ls_zztfi002 TO lt_zztfi002.

    "分录3
    CLEAR: ls_zztfi002.
    lv_num = lv_num + 1.
    ls_zztfi002-accountingdocumentitem = lv_num.
    ls_zztfi002-reference1indocumentheader = gs_data-header-purchaseorderbycustomer.
    ls_zztfi002-datasource = 'B01'.
    ls_zztfi002-glaccount = '2221160401'.
    ls_zztfi002-amountintransactioncurrency = lv_total_se.
    IF ls_zztfi002-amountintransactioncurrency > 0.
      ls_zztfi002-debitcreditcode = 'S'.
    ELSEIF ls_zztfi002-amountintransactioncurrency  < 0.
      ls_zztfi002-debitcreditcode = 'H'.
    ENDIF.

    ls_zztfi002-documentitemtext = ls_body-zbeizu.
    ls_zztfi002-profitcenter = 'PGH00'.
    APPEND ls_zztfi002 TO lt_zztfi002.

    MODIFY zztfi001 FROM TABLE @lt_zztfi001.
    MODIFY zztfi002 FROM TABLE @lt_zztfi002.

    o_resp-msgty = 'S'.
    o_resp-msgtx = '数据接收成功'.

  ENDMETHOD.
ENDCLASS.
